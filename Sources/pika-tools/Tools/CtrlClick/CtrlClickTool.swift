import CoreGraphics
import SwiftUI

@Observable
final class CtrlClickTool: Tool {
    let id = "ctrl-click"
    let name = "Ctrl+Click"
    let icon = "cursorarrow.click.2"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? true
    }

    var settingsView: AnyView {
        AnyView(CtrlClickSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: ctrlClickCallback,
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

private func ctrlClickCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let refcon {
            let tool = Unmanaged<CtrlClickTool>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.async { tool.refresh() }
        }
    default:
        if event.flags.contains(.maskControl) {
            event.flags.remove(.maskControl)
        }
    }
    return Unmanaged.passUnretained(event)
}

private struct CtrlClickSettings: View {
    @Bindable var tool: CtrlClickTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: "Блокировать Ctrl+Click",
            subtitle: "Ctrl+клик — обычный клик, без меню",
            isOn: $tool.isEnabled
        )
    }
}
