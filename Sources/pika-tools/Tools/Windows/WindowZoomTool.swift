import AppKit
import ApplicationServices
import SwiftUI

@Observable
final class WindowZoomTool: Tool {
    let id = "window-zoom"
    let icon = "arrow.up.left.and.arrow.down.right"
    var title: String { String(localized: "Green button enlarges the window") }
    let tab = SettingsTab.windows

    private static let excludedKey = "window-zoom-excluded"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var excluded: [String] {
        didSet { UserDefaults.standard.set(excluded, forKey: Self.excludedKey) }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var pending: (window: AXUIElement, button: CGRect)?
    @ObservationIgnored private let queue = DispatchQueue(label: "window-zoom", qos: .userInitiated)
    @ObservationIgnored private var saved: [AXUIElement: (previous: CGRect, zoomed: CGRect)] = [:]

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
    }

    func load() {
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(WindowZoomSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && excluded.isEmpty }

    func reset() {
        isEnabled = false
        excluded = []
    }

    func refresh() {
        stop()
        if isEnabled, AXIsProcessTrusted() { start() }
    }

    private func start() {
        let types: [CGEventType] = [.leftMouseDown, .leftMouseUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: windowZoomCallback,
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
        pending = nil
        queue.async { [self] in saved.removeAll() }
        isActive = false
    }

    fileprivate func press(at point: CGPoint) -> Bool {
        guard AXIsProcessTrusted(), Self.visibleFrame(at: point)?.contains(point) == true,
              let pid = Self.titleBarOwner(at: point), pid != getpid(),
              !excluded.contains(NSRunningApplication(processIdentifier: pid)?.bundleIdentifier ?? "")
        else { return false }
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.2)
        var hit: AXUIElement?
        guard AXUIElementCopyElementAtPosition(app, Float(point.x), Float(point.y), &hit) == .success, let hit,
              !CFEqual(hit, app),
              Self.value(hit, kAXSubroleAttribute) as? String == kAXFullScreenButtonSubrole as String,
              let window = Self.value(hit, kAXWindowAttribute), CFGetTypeID(window) == AXUIElementGetTypeID(),
              case let window = window as! AXUIElement,
              Self.isSettable(window, kAXSizeAttribute),
              let button = Self.frame(of: hit)
        else { return false }
        pending = (window, button)
        return true
    }

    fileprivate func release(at point: CGPoint) {
        guard let (window, button) = pending else { return }
        pending = nil
        guard button.insetBy(dx: -8, dy: -8).contains(point), let target = Self.visibleFrame(at: point) else { return }
        queue.async { [self] in toggle(window, to: target) }
    }

    private func toggle(_ window: AXUIElement, to target: CGRect) {
        AXUIElementSetMessagingTimeout(window, 0.5)
        guard let current = Self.frame(of: window) else { return }
        if let state = saved.removeValue(forKey: window), Self.near(current, state.zoomed) {
            Self.set(state.previous, on: window)
            return
        }
        Self.set(target, on: window)
        let applied = Self.frame(of: window)
        saved[window] = (current, applied.map { Self.near($0, current) ? target : $0 } ?? target)
    }

    private static func titleBarOwner(at point: CGPoint) -> pid_t? {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [NSDictionary] ?? []
        for info in windows {
            guard let bounds = (info[kCGWindowBounds] as? NSDictionary).flatMap({ CGRect(dictionaryRepresentation: $0 as CFDictionary) }),
                  bounds.contains(point), info[kCGWindowOwnerName] as? String != "Dock"
            else { continue }
            guard info[kCGWindowLayer] as? Int == 0, point.x - bounds.minX < 120, point.y - bounds.minY < 50 else { return nil }
            return info[kCGWindowOwnerPID] as? pid_t
        }
        return nil
    }

    private static func visibleFrame(at point: CGPoint) -> CGRect? {
        guard let height = NSScreen.screens.first?.frame.height else { return nil }
        let cocoa = CGPoint(x: point.x, y: height - point.y)
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(cocoa) }) ?? NSScreen.main else { return nil }
        let visible = screen.visibleFrame
        return CGRect(x: visible.minX, y: height - visible.maxY, width: visible.width, height: visible.height)
    }

    private static func near(_ a: CGRect, _ b: CGRect) -> Bool {
        [a.minX - b.minX, a.minY - b.minY, a.width - b.width, a.height - b.height].allSatisfy { abs($0) <= 4 }
    }

    private static func value(_ element: AXUIElement, _ attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success ? value : nil
    }

    private static func isSettable(_ element: AXUIElement, _ attribute: String) -> Bool {
        var settable: DarwinBoolean = false
        return AXUIElementIsAttributeSettable(element, attribute as CFString, &settable) == .success && settable.boolValue
    }

    private static func frame(of element: AXUIElement) -> CGRect? {
        var origin = CGPoint.zero
        var size = CGSize.zero
        guard let position = value(element, kAXPositionAttribute), CFGetTypeID(position) == AXValueGetTypeID(),
              let dimensions = value(element, kAXSizeAttribute), CFGetTypeID(dimensions) == AXValueGetTypeID(),
              AXValueGetValue(position as! AXValue, .cgPoint, &origin),
              AXValueGetValue(dimensions as! AXValue, .cgSize, &size)
        else { return nil }
        return CGRect(origin: origin, size: size)
    }

    private static func set(_ frame: CGRect, on window: AXUIElement) {
        var origin = frame.origin
        var size = frame.size
        guard let position = AXValueCreate(.cgPoint, &origin), let dimensions = AXValueCreate(.cgSize, &size) else { return }
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, dimensions)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, dimensions)
    }
}

private func windowZoomCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<WindowZoomTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .leftMouseDown:
        tool.pending = nil
        guard event.flags.isDisjoint(with: [.maskCommand, .maskControl, .maskAlternate, .maskShift]),
              tool.press(at: event.location)
        else { break }
        return nil
    case .leftMouseUp:
        guard tool.pending != nil else { break }
        tool.release(at: event.location)
        return nil
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct WindowZoomArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.7, 1.6, 0.9]
    private static let screen = CGRect(x: 24, y: 8, width: 252, height: 112)
    private static let zoomed = CGRect(x: 28, y: 18, width: 244, height: 98)
    private static let fullScreen = CGRect(x: 24, y: -6, width: 252, height: 126)
    private static let small = CGRect(x: 96, y: 36, width: 108, height: 64)

    private func green(_ frame: CGRect) -> CGPoint {
        CGPoint(x: frame.minX + 30, y: frame.minY + 7)
    }

    var body: some View {
        let step = reduceMotion ? 2 : tick % Self.durations.count
        let frame = step >= 2 ? (on ? Self.zoomed : Self.fullScreen) : Self.small
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            Stage {
                ZStack {
                    LinearGradient(colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    HStack(spacing: 5) {
                        Circle().fill(Color.primary.opacity(0.35)).frame(width: 4, height: 4)
                        ForEach([14, 18], id: \.self) { Capsule().fill(Color.primary.opacity(0.25)).frame(width: CGFloat($0), height: 2.5) }
                        Spacer(minLength: 0)
                        Capsule().fill(Color.primary.opacity(0.25)).frame(width: 12, height: 2.5)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 8)
                    .background(Color(nsColor: .windowBackgroundColor).opacity(0.7))
                    .frame(maxHeight: .infinity, alignment: .top)
                    ArtWindow(size: frame.size) {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                    }
                    .position(x: frame.midX - Self.screen.minX, y: frame.midY - Self.screen.minY)
                }
                .frame(width: Self.screen.width, height: Self.screen.height)
                .clipShape(shape)
                .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
                .position(x: Self.screen.midX, y: Self.screen.midY)
                if step == 2 {
                    ArtRipple()
                        .position(green(Self.small))
                }
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 206, y: 100) : green(step == 3 ? frame : Self.small))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
        .loop($tick, Self.durations)
    }
}

private struct WindowZoomSettings: View {
    @Bindable var tool: WindowZoomTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { WindowZoomArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Click again to go back"),
            hint: Text("Click again to go back"),
            help: Text("Click the green button to fill the screen, click again to go back. Full screen stays in the button’s menu and on ⌃⌘F."),
            isOn: $tool.isEnabled
        )
        AppExclusions(
            title: String(localized: "Green button works as usual in these apps"),
            apps: $tool.excluded,
            isEnabled: tool.isEnabled
        )
    }
}
