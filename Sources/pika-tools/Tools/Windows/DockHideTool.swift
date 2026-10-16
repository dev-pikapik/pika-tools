import AppKit
import ApplicationServices
import SwiftUI

@Observable
final class DockHideTool: Tool {
    enum Action: String { case minimize, hide }

    fileprivate enum Move { case collapse, restore, hide }

    fileprivate struct Press {
        let down: CGEvent
        let app: NSRunningApplication
        let move: Move
    }

    let id = "dock-hide"
    let icon = "dock.rectangle"
    var title: String { String(localized: "Minimize or hide with a click in the Dock") }
    let tab = SettingsTab.dock
    private static let actionKey = "dock-hide-action"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var action: Action {
        didSet { UserDefaults.standard.set(action.rawValue, forKey: Self.actionKey) }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var press: Press?
    @ObservationIgnored fileprivate var ownsClick = false
    @ObservationIgnored fileprivate var ownedAt = Date.distantPast
    @ObservationIgnored fileprivate var swallowsUp = false
    @ObservationIgnored private var collapsed: [pid_t: Date] = [:]
    @ObservationIgnored private var tracked: [pid_t: [AXUIElement]] = [:]
    @ObservationIgnored private let queue = DispatchQueue(label: "dock-hide", qos: .userInitiated)

    init() {
        let defaults = UserDefaults.standard
        DockHideMigration.run(defaults, switchKey: id, actionKey: Self.actionKey)
        isEnabled = defaults.bool(forKey: id)
        action = Action(rawValue: defaults.string(forKey: Self.actionKey) ?? "") ?? .minimize
    }

    var isDefault: Bool { !isEnabled && action == .minimize }

    func reset() {
        isEnabled = false
        action = .minimize
    }

    func load() {
        DockHideMigration.run(.standard, switchKey: id, actionKey: Self.actionKey)
        isEnabled = UserDefaults.standard.bool(forKey: id)
        action = Action(rawValue: UserDefaults.standard.string(forKey: Self.actionKey) ?? "") ?? .minimize
    }

    var settingsView: AnyView {
        AnyView(DockHideSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled, MainCopy.canAct, AXIsProcessTrusted() { start() }
    }

    private func start() {
        let types: [CGEventType] = [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: dockHideCallback,
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
        press = nil
        ownsClick = false
        swallowsUp = false
        isActive = false
    }

    fileprivate func press(for event: CGEvent) -> Press? {
        guard let app = Self.dockApp(at: event.location),
              app.processIdentifier != ProcessInfo.processInfo.processIdentifier,
              let move = move(for: app),
              let down = event.copy()
        else { return nil }
        return Press(down: down, app: app, move: move)
    }

    private func move(for app: NSRunningApplication) -> Move? {
        let pid = app.processIdentifier
        let recent = collapsed[pid].map { $0.timeIntervalSinceNow > -1 }
        if recent == true { return .restore }
        if app.isActive, Self.hasWindows(pid) { return action == .hide ? .hide : .collapse }
        if recent == false, !Self.hasWindows(pid) { return .restore }
        return nil
    }

    fileprivate func hold(_ press: Press) {
        self.press = press
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self, self.press?.down === press.down,
                  CGEventSource.buttonState(.hidSystemState, button: .left)
            else { return }
            self.press = nil
            press.down.location = CGEvent(source: nil)?.location ?? press.down.location
            Self.replay([press.down])
        }
    }

    fileprivate func perform(_ press: Press, up: CGEvent?) {
        let app = press.app
        let click = [press.down, up].compactMap { $0 }
        switch press.move {
        case .hide: DispatchQueue.main.async { app.hide() }
        case .collapse: queue.async { self.collapse(app, click: click) }
        case .restore: queue.async { self.restore(app, click: click) }
        }
    }

    private func collapse(_ app: NSRunningApplication, click: [CGEvent]) {
        let pid = app.processIdentifier
        tracked = tracked.filter { NSRunningApplication(processIdentifier: $0.key) != nil }
        let fresh = Self.windows(of: pid).filter(Self.canMinimize)
        guard !fresh.isEmpty else {
            if tracked[pid] != nil { return restore(app, click: click) }
            report(pid, nil)
            return Self.replay(click)
        }
        for window in fresh {
            AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
        }
        tracked[pid] = fresh + (tracked[pid] ?? []).filter { !fresh.contains($0) && Self.isMinimized($0) }
        report(pid, Date())
        Self.activate(Self.nextApp(after: pid))
    }

    private func restore(_ app: NSRunningApplication, click: [CGEvent]) {
        let pid = app.processIdentifier
        report(pid, nil)
        let windows = (tracked.removeValue(forKey: pid) ?? []).filter(Self.isMinimized)
        guard let front = windows.first else { return Self.replay(click) }
        for window in windows.reversed() {
            AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanFalse)
        }
        AXUIElementPerformAction(front, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(front, kAXMainAttribute as CFString, kCFBooleanTrue)
        Self.activate(app)
    }

    private func report(_ pid: pid_t, _ date: Date?) {
        DispatchQueue.main.async {
            self.collapsed[pid] = date
            self.collapsed = self.collapsed.filter { NSRunningApplication(processIdentifier: $0.key) != nil }
        }
    }

    private static func nearEdge(_ point: CGPoint) -> Bool {
        var display: CGDirectDisplayID = 0
        var count: UInt32 = 0
        guard CGGetDisplaysWithPoint(point, 1, &display, &count) == .success, count > 0 else { return false }
        let bounds = CGDisplayBounds(display), reach: CGFloat = 200
        return point.y > bounds.maxY - reach || point.x < bounds.minX + reach || point.x > bounds.maxX - reach
    }

    private static func dockApp(at point: CGPoint) -> NSRunningApplication? {
        guard nearEdge(point),
              let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first
        else { return nil }
        let element = AXUIElementCreateApplication(dock.processIdentifier)
        AXUIElementSetMessagingTimeout(element, 0.25)
        var hit: AXUIElement?
        guard AXUIElementCopyElementAtPosition(element, Float(point.x), Float(point.y), &hit) == .success, let hit else { return nil }
        AXUIElementSetMessagingTimeout(hit, 0.25)
        guard value(hit, kAXSubroleAttribute) as? String == "AXApplicationDockItem",
              let url = value(hit, kAXURLAttribute) as? URL
        else { return nil }
        let path = url.resolvingSymlinksInPath().path
        return NSWorkspace.shared.runningApplications.first { $0.bundleURL?.resolvingSymlinksInPath().path == path }
    }

    private static func value(_ element: AXUIElement, _ attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success ? value : nil
    }

    private static func windows(of pid: pid_t) -> [AXUIElement] {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.5)
        let windows = value(app, kAXWindowsAttribute) as? [AXUIElement] ?? []
        windows.forEach { AXUIElementSetMessagingTimeout($0, 0.5) }
        return windows
    }

    private static func isMinimized(_ window: AXUIElement) -> Bool {
        value(window, kAXMinimizedAttribute) as? Bool == true
    }

    private static func canMinimize(_ window: AXUIElement) -> Bool {
        var settable: DarwinBoolean = false
        return [kAXStandardWindowSubrole, kAXDialogSubrole].contains(value(window, kAXSubroleAttribute) as? String ?? "")
            && value(window, kAXMinimizedAttribute) as? Bool == false
            && value(window, "AXFullScreen") as? Bool != true
            && AXUIElementIsAttributeSettable(window, kAXMinimizedAttribute as CFString, &settable) == .success
            && settable.boolValue
    }

    private static func windowOwners() -> [pid_t] {
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        return list.compactMap { info in
            guard info[kCGWindowLayer as String] as? Int == 0,
                  (info[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  let bounds = info[kCGWindowBounds as String] as? [String: CGFloat],
                  (bounds["Width"] ?? 0) >= 80, (bounds["Height"] ?? 0) >= 80
            else { return nil }
            return info[kCGWindowOwnerPID as String] as? pid_t
        }
    }

    private static func hasWindows(_ pid: pid_t) -> Bool {
        windowOwners().contains(pid)
    }

    private static func nextApp(after pid: pid_t) -> NSRunningApplication? {
        windowOwners().lazy
            .filter { $0 != pid }
            .compactMap { NSRunningApplication(processIdentifier: $0) }
            .first { $0.activationPolicy == .regular && !$0.isHidden }
            ?? NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first
    }

    private static func activate(_ app: NSRunningApplication?) {
        guard let app else { return }
        let element = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(element, 0.5)
        AXUIElementSetAttributeValue(element, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    }

    private static func replay(_ events: [CGEvent]) {
        for event in events {
            event.postPikapik()
        }
    }
}

private func dockHideCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon, !event.isPikapik else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<DockHideTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .leftMouseDown:
        tool.press = nil
        if event.getIntegerValueField(.mouseEventClickState) > 1, !tool.ownsClick || tool.ownedAt.timeIntervalSinceNow > -0.5 {
            tool.swallowsUp = tool.ownsClick
            if tool.ownsClick { return nil }
            break
        }
        tool.ownsClick = false
        tool.swallowsUp = false
        guard event.flags.isDisjoint(with: [.maskCommand, .maskControl, .maskAlternate, .maskShift]),
              let press = tool.press(for: event)
        else { break }
        tool.hold(press)
        return nil
    case .leftMouseDragged:
        guard let press = tool.press else { break }
        let from = press.down.location, to = event.location
        guard hypot(to.x - from.x, to.y - from.y) >= 5 else { return nil }
        tool.press = nil
        press.down.postPikapik(proxy)
    case .leftMouseUp:
        if tool.swallowsUp {
            tool.swallowsUp = false
            return nil
        }
        guard let press = tool.press else { break }
        tool.press = nil
        tool.ownsClick = true
        tool.ownedAt = Date()
        tool.perform(press, up: event.copy())
        return nil
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct DockHideArt: View {
    let on: Bool
    var action = DockHideTool.Action.minimize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.2, 1.1, 0.15, 1.2, 0.15, 1.3]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 3 : tick % Self.durations.count
            let hidden = on && (3...4).contains(step)
            let minimize = action == .minimize
            let aimed = step != 0
            Stage {
                ArtWindow {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .scaleEffect(hidden ? (minimize ? 0.12 : 0.96) : 1, anchor: .bottom)
                .offset(y: hidden && minimize ? 38 : 0)
                .opacity(hidden ? 0 : 1)
                .position(x: 150, y: 44)
                ArtDock()
                    .position(x: 150, y: 102)
                if step >= 2 {
                    ArtRipple()
                        .id(step < 4)
                        .position(x: 150, y: 100)
                }
                ArtCursor(pressed: step == 2 || step == 4)
                    .cursor(at: aimed ? CGPoint(x: 152, y: 98) : CGPoint(x: 216, y: 70))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.55), value: step)
        }
    }
}

private struct DockHideSettings: View {
    @Bindable var tool: DockHideTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        let minimize = tool.action == .minimize
        if inSettings { DockHideArt(on: tool.isEnabled, action: tool.action) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: minimize ? Text("Click the icon of the open app to minimize its windows") : Text("Click the icon of the open app to hide it"),
            hint: minimize ? Text("Click again to bring them back") : Text("Click again to bring it back"),
            help: minimize
                ? Text("Click the icon of the app you’re in, and all its windows go down to the Dock. Click again to bring them all back.")
                : Text("Click the icon of the app you’re in to hide it. Click again to bring it back."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            LabeledContent {
                Picker(selection: $tool.action) {
                    Text("Minimizes the windows").tag(DockHideTool.Action.minimize)
                    Text("Hides the app").tag(DockHideTool.Action.hide)
                } label: { Text("A click on the icon") }
                .labelsHidden()
                .fixedSize()
            } label: {
                RowLabel(
                    Text("A click on the icon"),
                    minimize ? Text("The windows go down to the Dock, like with the yellow button") : Text("The app hides with all its windows, like with ⌘H")
                )
            }
            .settingAnchor(String(localized: "A click on the icon"))
            .disabled(!tool.isEnabled)
        }
    }
}
