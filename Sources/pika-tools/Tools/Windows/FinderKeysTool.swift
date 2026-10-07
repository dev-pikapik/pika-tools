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
    @ObservationIgnored private var held: (key: Int, target: Int, flags: CGEventFlags)?
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
            eventsOfInterest: 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue,
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

    fileprivate func handle(_ event: CGEvent, up: Bool, proxy: CGEventTapProxy) -> Bool {
        let key = Int(event.getIntegerValueField(.keyboardEventKeycode))
        if up {
            guard let held, held.key == key else { return false }
            self.held = nil
            Self.send(held.target, held.flags, down: false, proxy)
            return true
        }
        if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 { return key == held?.key }
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

        let target: (key: Int, flags: CGEventFlags)
        switch key {
        case kVK_F2:
            target = (kVK_Return, [])
        case kVK_Return, kVK_ANSI_KeypadEnter:
            target = (kVK_DownArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad])
        case kVK_ANSI_X:
            let before = NSPasteboard.general.changeCount
            cancelCut()
            watchCopy(since: before, attempts: 20)
            target = (kVK_ANSI_C, .maskCommand)
        default:
            let moves = NSPasteboard.general.changeCount == cutCount
            cancelCut()
            guard moves else { return false }
            target = (kVK_ANSI_V, [.maskCommand, .maskAlternate])
        }
        held = (key, target.key, target.flags)
        Self.send(target.key, target.flags, down: true, proxy)
        return true
    }

    private static func send(_ key: Int, _ flags: CGEventFlags, down: Bool, _ proxy: CGEventTapProxy) {
        guard let event = CGEvent(keyboardEventSource: CGEventSource(stateID: .privateState), virtualKey: CGKeyCode(key), keyDown: down) else { return }
        event.flags = flags
        event.tapPostEvent(proxy)
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
        let windowSubrole = value(window as! AXUIElement, kAXSubroleAttribute).0 as? String
        return windowSubrole == kAXStandardWindowSubrole || windowSubrole == "AXDesktop"
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
    case .keyDown, .keyUp:
        if keys.handle(event, up: type == .keyUp, proxy: proxy) { return nil }
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
    let tab = SettingsTab.finder

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
    let tab = SettingsTab.finder

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

private struct ArtFinder<Content: View>: View {
    var size = CGSize(width: 112, height: 70)
    @ViewBuilder var content: Content

    var body: some View {
        ArtWindow(size: size) {
            HStack(spacing: 4) { content }
        }
    }
}

struct FinderOpenArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.4, 1.5, 0.4, 1.5]

    var body: some View {
        let step = reduceMotion ? 2 : tick % Self.durations.count
        let opened = on && step == 2
        let renaming = on ? step == 4 : step >= 2
        IllustrationRow {
            Stage {
                ArtFinder(size: CGSize(width: 150, height: 86)) {
                    ArtFile()
                    ArtFile(selected: true, renaming: renaming)
                    ArtFile()
                }
                .position(x: 88, y: 62)
                ArtWindow(size: CGSize(width: 96, height: 62)) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .scaleEffect(opened ? 1 : 0.5, anchor: .leading)
                .opacity(opened ? 1 : 0)
                .position(x: 186, y: 52)
                ArtKey(down: step == 1, width: 38) { Image(systemName: "return") }
                    .position(x: 268, y: 40)
                ArtKey(down: step == 3, width: 38) { Text(verbatim: "F2") }
                    .position(x: 268, y: 82)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.35), value: step)
        }
        .loop($tick, Self.durations)
    }
}

struct FinderCutArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.6, 0.6, 1.6]

    var body: some View {
        let step = reduceMotion ? 1 : tick % Self.durations.count
        let moved = on && step >= 2
        IllustrationRow {
            Stage {
                ArtFinder {
                    if !moved { ArtFile(selected: true).opacity(on && step == 1 ? 0.4 : 1) }
                    ArtFile()
                }
                .position(x: 70, y: 48)
                ArtFinder {
                    ArtFile()
                    if moved { ArtFile(selected: true).transition(.scale(scale: 0.6).combined(with: .opacity)) }
                }
                .position(x: 230, y: 48)
                ArtKey(down: step == 1) { Text(verbatim: "⌘X") }
                    .position(x: 120, y: 106)
                ArtKey(down: step == 2) { Text(verbatim: "⌘V") }
                    .position(x: 180, y: 106)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.4), value: step)
        }
        .loop($tick, Self.durations)
    }
}

private struct FinderOpenSettings: View {
    @Bindable var tool: FinderOpenTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { FinderOpenArt(on: tool.isEnabled) }
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
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { FinderCutArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("In Finder, ⌘X cuts the selected files and ⌘V moves them into the folder you paste in, like on Windows. ⌘C cancels the cut."),
            hint: Text("⌘X cuts, ⌘V moves"),
            isOn: $tool.isEnabled
        )
    }
}
