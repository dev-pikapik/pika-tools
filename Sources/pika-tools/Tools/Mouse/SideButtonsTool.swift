import Carbon
import SwiftUI

@Observable
final class SideButtonsTool: Tool {
    let id = "side-buttons"
    let icon = "arrow.left.arrow.right"
    var title: String { String(localized: "Side buttons go back and forward") }
    let tab = SettingsTab.mouse

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var swapsButtons: Bool {
        didSet { UserDefaults.standard.set(swapsButtons, forKey: "side-buttons-swap") }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        swapsButtons = UserDefaults.standard.bool(forKey: "side-buttons-swap")
    }

    var settingsView: AnyView {
        AnyView(SideButtonsSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && !swapsButtons }

    func reset() {
        isEnabled = false
        swapsButtons = false
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.otherMouseDown, .otherMouseUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: sideButtonsCallback,
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

    fileprivate func press(forward: Bool) {
        let key = CGKeyCode((forward != swapsButtons) ? kVK_ANSI_RightBracket : kVK_ANSI_LeftBracket)
        for down in [true, false] {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: down)
            event?.flags = .maskCommand
            event?.post(tap: .cghidEventTap)
        }
    }
}

private func sideButtonsCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<SideButtonsTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .otherMouseDown, .otherMouseUp:
        let button = event.getIntegerValueField(.mouseEventButtonNumber)
        guard button == 3 || button == 4 else { break }
        if type == .otherMouseDown { tool.press(forward: button == 4) }
        return nil
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct SideButtonsSettings: View {
    @Bindable var tool: SideButtonsTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Buttons 4 and 5 work like ⌘[ and ⌘] in every app"),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Toggle(isOn: $tool.swapsButtons) {
                Text("Swap the side buttons")
                Text(tool.swapsButtons ? "Button 4 goes forward, button 5 goes back" : "Button 4 goes back, button 5 goes forward")
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Swap the side buttons"))
        }
    }
}
