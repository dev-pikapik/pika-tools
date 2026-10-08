import Carbon
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

    var quitKeys: Shortcut {
        didSet {
            Self.save(quitKeys, .quit, "command-keys-quit-shortcut")
            refresh()
        }
    }

    var closeKeys: Shortcut {
        didSet {
            Self.save(closeKeys, .close, "command-keys-close-shortcut")
            refresh()
        }
    }

    static var quit: Shortcut { shared?.quitKeys ?? .quit }
    static var close: Shortcut { shared?.closeKeys ?? .close }
    private static var shared: CommandKeysTool? { ToolRegistry.shared.tools.lazy.compactMap { $0 as? CommandKeysTool }.first }

    var isDefault: Bool { !isEnabled && quitKeys == .quit && closeKeys == .close }

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
    @ObservationIgnored fileprivate var triggers: [Shortcut: Int64] = [:]
    @ObservationIgnored fileprivate var held: (key: Int64, target: Int64)?

    init() {
        protectsQuit = UserDefaults.standard.bool(forKey: "command-keys-quit")
        protectsClose = UserDefaults.standard.bool(forKey: "command-keys-close")
        quitKeys = Shortcut(stored: UserDefaults.standard.object(forKey: "command-keys-quit-shortcut")) ?? .quit
        closeKeys = Shortcut(stored: UserDefaults.standard.object(forKey: "command-keys-close-shortcut")) ?? .close
    }

    func load() {
        protectsQuit = UserDefaults.standard.bool(forKey: "command-keys-quit")
        protectsClose = UserDefaults.standard.bool(forKey: "command-keys-close")
        quitKeys = Shortcut(stored: UserDefaults.standard.object(forKey: "command-keys-quit-shortcut")) ?? .quit
        closeKeys = Shortcut(stored: UserDefaults.standard.object(forKey: "command-keys-close-shortcut")) ?? .close
    }

    func reset() {
        isEnabled = false
        quitKeys = .quit
        closeKeys = .close
    }

    private static func save(_ shortcut: Shortcut, _ standard: Shortcut, _ key: String) {
        if shortcut == standard {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(shortcut.stored, forKey: key)
        }
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
        let targets = [(quitKeys, Int64(kVK_ANSI_Q)), (closeKeys, Int64(kVK_ANSI_W))].filter { keys.contains($0.1) }
        triggers = Dictionary(targets) { first, _ in first }
        held = nil
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
        if type == .keyUp, let held = tool.held, held.key == code {
            tool.held = nil
            post(held.target, down: false, proxy)
            return nil
        }
        if type == .keyDown, let target = tool.triggers[Shortcut(key: UInt16(truncatingIfNeeded: code), modifiers: flags.rawValue)] {
            guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else { return nil }
            tool.held = (code, target)
            post(target, down: true, proxy)
            return nil
        }
        guard tool.blocked.contains(code),
              flags.contains(.maskCommand),
              flags.isDisjoint(with: [.maskControl, .maskAlternate, .maskShift])
        else { break }
        if type == .keyDown { GameModeTool.shared.hint() }
        return nil
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private func post(_ code: Int64, down: Bool, _ proxy: CGEventTapProxy) {
    guard let key = CGEvent(keyboardEventSource: CGEventSource(stateID: .privateState), virtualKey: CGKeyCode(code), keyDown: down) else { return }
    key.flags = .maskCommand
    key.tapPostEvent(proxy)
}

private struct CommandKeysSettings: View {
    @Bindable var tool: CommandKeysTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            row("Q", String(localized: "Quit app"), isOn: $tool.protectsQuit, keys: $tool.quitKeys, standard: .quit, other: (String(localized: "Close window"), tool.closeKeys))
                .settingAnchor(String(localized: "Protect quitting and closing"))
            row("W", String(localized: "Close window"), isOn: $tool.protectsClose, keys: $tool.closeKeys, standard: .close, other: (String(localized: "Quit app"), tool.quitKeys))
        } else {
            ToggleRow(
                icon: tool.icon,
                title: tool.title,
                subtitle: Text("Quit and close need one more key"),
                hint: Text("Quit and close need one more key"),
                keys: tool.quitKeys == .quit && tool.closeKeys == .close ? ["⇧"] : [tool.quitKeys.text, tool.closeKeys.text],
                isOn: $tool.isEnabled
            )
        }
    }

    private func row(
        _ letter: String, _ title: String, isOn: Binding<Bool>, keys: Binding<Shortcut>, standard: Shortcut, other: (title: String, keys: Shortcut)
    ) -> some View {
        Toggle(isOn: isOn) {
            Group {
                if isOn.wrappedValue {
                    ShortcutLabel(
                        shortcut: keys,
                        standard: standard,
                        title: Text(title),
                        subtitle: keys.wrappedValue == standard ? Text("Only with all three keys") : Text("Only with these keys"),
                        others: [(String(localized: "Already used for “\(other.title)”"), other.keys)]
                    )
                } else {
                    KeyLabel(keys: ["⌘" + letter], title: Text(title), subtitle: Text("Works as usual"))
                }
            }
            .settingAnchor(title)
        }
    }
}
