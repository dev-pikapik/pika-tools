import CoreGraphics
import SwiftUI

@Observable
final class CtrlKeysTool: Tool {
    let id = "ctrl-keys"
    let icon = "control"

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
        AnyView(CtrlKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp, .leftMouseDown, .leftMouseUp, .leftMouseDragged]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: ctrlKeysCallback,
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

private func ctrlKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let refcon {
            let tool = Unmanaged<CtrlKeysTool>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.async { tool.refresh() }
        }
    case .keyDown, .keyUp, .leftMouseDown, .leftMouseUp, .leftMouseDragged:
        if event.flags.contains(.maskControl) {
            event.flags.remove(.maskControl)
            if event.flags.contains(.maskCommand) {
                event.flags.remove(.maskCommand)
            }
        }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct CtrlKeysSettings: View {
    @Bindable var tool: CtrlKeysTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: String(localized: "Block Ctrl shortcuts"),
            subtitle: String(localized: "Ctrl works as a plain key: no shortcuts, no Ctrl-click menu"),
            isOn: $tool.isEnabled
        )
    }
}
