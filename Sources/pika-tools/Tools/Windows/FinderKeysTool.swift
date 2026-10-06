import AppKit
import ApplicationServices
import Carbon.HIToolbox
import SwiftUI

@Observable
final class FinderKeys {
    static let shared = FinderKeys()

    private(set) var isActive = false

    @ObservationIgnored var opens = false
    @ObservationIgnored var cuts = false
    @ObservationIgnored private var cutCount: Int?
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var held: Int?
    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    private init() {}

    func refresh() {
        stop()
        if !cuts { cancelCut() }
        if opens || cuts, AXIsProcessTrusted() { start() }
    }

    private func start() {
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: 1 << CGEventType.keyDown.rawValue,
            callback: finderKeysCallback,
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

    fileprivate func handle(_ event: CGEvent) -> Bool {
        let key = Int(event.getIntegerValueField(.keyboardEventKeycode))
        if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 { return key == held }
        held = nil

        let flags = event.flags.intersection([.maskShift, .maskControl, .maskAlternate, .maskCommand])
        if cuts, flags == .maskCommand, key == kVK_ANSI_C { cancelCut() }

        let opening = opens && flags.isEmpty && [kVK_Return, kVK_ANSI_KeypadEnter, kVK_F2].contains(key)
        let cutting = cuts && flags == .maskCommand && (key == kVK_ANSI_X || (key == kVK_ANSI_V && cutCount != nil))
        guard opening || cutting,
              let finder = NSWorkspace.shared.frontmostApplication,
              finder.bundleIdentifier == "com.apple.finder",
              Self.isBrowsing(finder.processIdentifier)
        else { return false }

        switch key {
        case kVK_F2:
            Self.change(event, to: kVK_Return)
            event.flags.subtract([.maskSecondaryFn, .maskNumericPad])
        case kVK_Return, kVK_ANSI_KeypadEnter:
            Self.change(event, to: kVK_DownArrow)
            event.flags.formUnion([.maskCommand, .maskSecondaryFn, .maskNumericPad])
        case kVK_ANSI_X:
            let before = NSPasteboard.general.changeCount
            Self.change(event, to: kVK_ANSI_C)
            cancelCut()
            watchCopy(since: before, attempts: 20)
        default:
            if NSPasteboard.general.changeCount == cutCount { event.flags.insert(.maskAlternate) }
            cancelCut()
        }
        held = key
        return false
    }

    private static func change(_ event: CGEvent, to key: Int) {
        event.setIntegerValueField(.keyboardEventKeycode, value: Int64(key))
    }

    private func cancelCut() {
        cutCount = nil
        generation += 1
    }

    private func watchCopy(since count: Int, attempts: Int) {
        let mine = generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            guard generation == mine else { return }
            let now = NSPasteboard.general.changeCount
            if now != count {
                cutCount = now
            } else if attempts > 1 {
                watchCopy(since: count, attempts: attempts - 1)
            }
        }
    }

    private static func isBrowsing(_ pid: pid_t) -> Bool {
        let (focused, error) = value(AXUIElementCreateApplication(pid), kAXFocusedUIElementAttribute)
        if error == .noValue { return true }
        guard error == .success, let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else { return false }
        let element = focused as! AXUIElement

        let (role, roleError) = value(element, kAXRoleAttribute)
        guard roleError == .success, let role = role as? String else { return false }
        let subrole = value(element, kAXSubroleAttribute).0 as? String
        let typing = [kAXTextFieldRole, kAXTextAreaRole, kAXComboBoxRole].contains(role)
        if typing || subrole == kAXSearchFieldSubrole { return false }

        guard let window = value(element, kAXWindowAttribute).0, CFGetTypeID(window) == AXUIElementGetTypeID() else { return true }
        return value(window as! AXUIElement, kAXSubroleAttribute).0 as? String == kAXStandardWindowSubrole
    }

    private static func value(_ element: AXUIElement, _ attribute: String) -> (CFTypeRef?, AXError) {
        AXUIElementSetMessagingTimeout(element, 0.15)
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return (value, error)
    }
}

private func finderKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let keys = Unmanaged<FinderKeys>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { keys.refresh() }
    case .keyDown:
        if keys.handle(event) { return nil }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

@Observable
final class FinderOpenTool: Tool {
    let id = "finder-open"
    let icon = "return"
    var title: String { String(localized: "Enter opens files in Finder") }
    let tab = SettingsTab.windows

    var isActive: Bool { isEnabled && FinderKeys.shared.isActive }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(FinderOpenSettings(tool: self))
    }

    func refresh() {
        FinderKeys.shared.opens = isEnabled
        FinderKeys.shared.refresh()
    }
}

@Observable
final class FinderCutTool: Tool {
    let id = "finder-cut"
    let icon = "scissors"
    var title: String { String(localized: "⌘X cuts files in Finder") }
    let tab = SettingsTab.windows

    var isActive: Bool { isEnabled && FinderKeys.shared.isActive }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(FinderCutSettings(tool: self))
    }

    func refresh() {
        FinderKeys.shared.cuts = isEnabled
        FinderKeys.shared.refresh()
    }
}

private struct FinderOpenSettings: View {
    @Bindable var tool: FinderOpenTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("In Finder, Return and Enter open the selected files, and F2 or fn F2 renames them, like on Windows."),
            hint: Text("Return opens, F2 or fn F2 renames"),
            isOn: $tool.isEnabled
        )
    }
}

private struct FinderCutSettings: View {
    @Bindable var tool: FinderCutTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("In Finder, ⌘X cuts the selected files and ⌘V moves them into the folder you paste in, like on Windows. ⌘C cancels the cut."),
            hint: Text("⌘X cuts, ⌘V moves"),
            isOn: $tool.isEnabled
        )
    }
}
