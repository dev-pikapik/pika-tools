import SwiftUI

@Observable
final class CommandKeysTool: Tool {
    let id = "command-keys"
    let icon = "command"
    var title: String { String(localized: "Protect quitting and closing") }
    let tab = SettingsTab.windows

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
    @ObservationIgnored fileprivate var blocked: Set<Int64> = []

    init() {
        protectsQuit = UserDefaults.standard.bool(forKey: "command-keys-quit")
        protectsClose = UserDefaults.standard.bool(forKey: "command-keys-close")
    }

    func load() {
        protectsQuit = UserDefaults.standard.bool(forKey: "command-keys-quit")
        protectsClose = UserDefaults.standard.bool(forKey: "command-keys-close")
    }

    var settingsView: AnyView {
        AnyView(CommandKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        (keys, blocked) = GameRules.commandKeys(
            quit: protectsQuit, close: protectsClose, playing: GameModeTool.shared.isPlaying,
            blocksQuit: GameModeTool.shared.rules.contains(.commandQ), blocksClose: GameModeTool.shared.rules.contains(.commandW)
        )
        if !keys.isEmpty { start() }
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
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        guard tool.keys.contains(code),
              flags.contains(.maskCommand),
              flags.isDisjoint(with: [.maskControl, .maskAlternate])
        else { break }
        guard flags.contains(.maskShift) else {
            guard tool.blocked.contains(code) else { break }
            if type == .keyDown { GameModeTool.shared.hint() }
            return nil
        }
        guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0,
              let key = CGEvent(
                  keyboardEventSource: CGEventSource(stateID: .privateState),
                  virtualKey: CGKeyCode(code),
                  keyDown: type == .keyDown
              )
        else { return nil }
        key.flags = .maskCommand
        key.tapPostEvent(proxy)
        return nil
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
            row(key: "Q", title: String(localized: "Quit app"), isOn: $tool.protectsQuit)
                .settingAnchor(String(localized: "Protect quitting and closing"))
            row(key: "W", title: String(localized: "Close window"), isOn: $tool.protectsClose)
        } else {
            ToggleRow(
                icon: tool.icon,
                title: tool.title,
                subtitle: Text("Quit and close need one more key"),
                hint: Text("Quit and close need one more key"),
                keys: ["⇧"],
                isOn: $tool.isEnabled
            )
        }
    }

    private func row(key: String, title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            KeyLabel(
                keys: [isOn.wrappedValue ? "⇧⌘" + key : "⌘" + key],
                title: Text(title),
                subtitle: isOn.wrappedValue ? Text("Only with all three keys") : Text("Works as usual")
            )
        }
    }
}
