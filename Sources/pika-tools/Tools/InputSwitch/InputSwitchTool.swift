import Carbon
import SwiftUI

@Observable
final class InputSwitchTool: Tool {
    let id = "input-switch"
    let icon = "globe"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var gesture = InputSwitchGesture()

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? false
    }

    var settingsView: AnyView {
        AnyView(InputSwitchSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.flagsChanged, .keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: inputSwitchCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        gesture = InputSwitchGesture()
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

    fileprivate static func select(_ direction: InputSwitchGesture.Direction) {
        let filter = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true,
            kTISPropertyInputSourceIsEnabled: true,
        ] as CFDictionary
        guard let all = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else { return }

        let types = [kTISTypeKeyboardLayout, kTISTypeKeyboardInputMode, kTISTypeKeyboardInputMethodWithoutModes]
            .map { $0! as String }
        let sources = all.filter { types.contains(string($0, kTISPropertyInputSourceType) ?? "") }
        guard sources.count > 1 else { return }

        let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue()
        let currentID = current.flatMap { string($0, kTISPropertyInputSourceID) }
        let target: Int
        if let index = sources.firstIndex(where: { string($0, kTISPropertyInputSourceID) == currentID }) {
            let step = direction == .next ? 1 : sources.count - 1
            target = (index + step) % sources.count
        } else {
            target = direction == .next ? 0 : sources.count - 1
        }
        TISSelectInputSource(sources[target])
    }

    private static func string(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let value = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
    }
}

private func inputSwitchCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<InputSwitchTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .flagsChanged:
        if let direction = tool.gesture.flagsChanged(event.flags) {
            DispatchQueue.main.async { InputSwitchTool.select(direction) }
        }
    default:
        tool.gesture.interrupt()
    }
    return Unmanaged.passUnretained(event)
}

private struct InputSwitchSettings: View {
    @Bindable var tool: InputSwitchTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: String(localized: "Switch language with ⌥⇧"),
            subtitle: Text("Hold ⌥ and tap ⇧: next language. Hold ⇧ and tap ⌥: previous"),
            isOn: $tool.isEnabled
        )
    }
}
