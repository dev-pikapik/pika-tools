import Carbon
import SwiftUI

@Observable
final class CommandKeysTool: Tool {
    let id = "command-keys"
    let icon = "command"
    var title: String { String(localized: "Protect ⌘Q and ⌘W") }

    private(set) var isActive = false

    var protectsQuit: Bool {
        didSet {
            UserDefaults.standard.set(protectsQuit, forKey: "command-keys-quit")
            refresh()
        }
    }

    var protectsClose: Bool {
        didSet {
            UserDefaults.standard.set(protectsClose, forKey: "command-keys-close")
            refresh()
        }
    }

    var isEnabled: Bool {
        get { protectsQuit || protectsClose }
        set {
            protectsQuit = newValue
            protectsClose = newValue
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var keys: Set<Int64> = []

    init() {
        protectsQuit = UserDefaults.standard.bool(forKey: "command-keys-quit")
        protectsClose = UserDefaults.standard.bool(forKey: "command-keys-close")
    }

    var settingsView: AnyView {
        AnyView(CommandKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        keys = Set((protectsQuit ? [Int64(kVK_ANSI_Q)] : []) + (protectsClose ? [Int64(kVK_ANSI_W)] : []))
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: commandKeysCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        isActive = true
    }

    private func stop() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        isActive = false
    }
}

private func commandKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<CommandKeysTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .keyDown, .keyUp:
        let flags = event.flags
        guard tool.keys.contains(event.getIntegerValueField(.keyboardEventKeycode)),
              flags.contains(.maskCommand),
              flags.isDisjoint(with: [.maskControl, .maskAlternate])
        else { break }
        guard flags.contains(.maskShift) else { return nil }
        event.flags.remove(.maskShift)
        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(maxStringLength: chars.count, actualStringLength: &length, unicodeString: &chars)
        let lower = Array(String(utf16CodeUnits: chars, count: length).lowercased().utf16)
        event.keyboardSetUnicodeString(stringLength: lower.count, unicodeString: lower)
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct CommandKeysSettings: View {
    @Bindable var tool: CommandKeysTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            VStack(alignment: .leading, spacing: 2) {
                Text("Protect ⌘Q and ⌘W")
                Text("Add ⇧ to quit or close. ⌘Q and ⌘W alone do nothing, in every app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .settingAnchor(String(localized: "Protect ⌘Q and ⌘W"))
            row(key: "Q", title: String(localized: "Quit app"), isOn: $tool.protectsQuit)
            row(key: "W", title: String(localized: "Close window"), isOn: $tool.protectsClose)
        } else {
            ToggleRow(
                icon: tool.icon,
                title: tool.title,
                subtitle: Text("Add ⇧ to quit or close"),
                isOn: $tool.isEnabled
            )
        }
    }

    private func row(key: String, title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                HStack(spacing: 3) {
                    KeyCap(symbol: "⌘")
                    KeyCap(symbol: key)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(isOn.wrappedValue ? "Only with ⇧⌘\(key)" : "With ⌘\(key), as usual")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct KeyCap: View {
    let symbol: String

    var body: some View {
        Text(verbatim: symbol)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .frame(minWidth: 24, minHeight: 24)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
    }
}
