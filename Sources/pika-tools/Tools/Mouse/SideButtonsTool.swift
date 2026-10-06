import AppKit
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

    func load() {
        swapsButtons = UserDefaults.standard.bool(forKey: "side-buttons-swap")
        isEnabled = UserDefaults.standard.bool(forKey: id)
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

    private static let swipeApps = ["com.apple.", "com.binarynights.ForkLift", "org.mozilla.firefox", "com.operasoftware.Opera"]

    fileprivate func handle(_ event: CGEvent, down: Bool) -> Bool {
        let button = event.getIntegerValueField(.mouseEventButtonNumber)
        let pid = pid_t(event.getIntegerValueField(.eventTargetUnixProcessID))
        let app = pid > 0 ? NSRunningApplication(processIdentifier: pid) : NSWorkspace.shared.frontmostApplication
        let id = app?.bundleIdentifier ?? ""
        let swaps = swapsButtons
        guard Self.swipeApps.contains(where: id.hasPrefix) else {
            if swaps { event.setIntegerValueField(.mouseEventButtonNumber, value: button == 3 ? 4 : 3) }
            return false
        }
        if down { Self.swipe(forward: (button == 4) != swaps) }
        return true
    }

    private static func swipe(forward: Bool) {
        for phase: Int64 in [1, 4] {
            guard let event = CGEvent(source: nil), let type = CGEventType(rawValue: UInt32(NSEvent.EventType.gesture.rawValue)) else { return }
            event.type = type
            event.setIntegerValueField(CGEventField(rawValue: 110)!, value: 16)
            event.setIntegerValueField(CGEventField(rawValue: 132)!, value: phase)
            event.setIntegerValueField(CGEventField(rawValue: 115)!, value: forward ? 8 : 4)
            event.post(tap: .cgSessionEventTap)
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
        if tool.handle(event, down: type == .otherMouseDown) { return nil }
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
            subtitle: Text("Mouse buttons 4 and 5 go back and forward, like a trackpad swipe."),
            hint: Text("Like a trackpad swipe"),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Toggle(isOn: $tool.swapsButtons) {
                RowLabel(Text("Swap the side buttons"), Text(tool.swapsButtons ? "Button 4 goes forward, button 5 goes back" : "Button 4 goes back, button 5 goes forward"))
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Swap the side buttons"))
        }
    }
}
