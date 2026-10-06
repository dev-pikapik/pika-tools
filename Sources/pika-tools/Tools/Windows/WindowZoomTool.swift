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

private struct WindowZoomSettings: View {
    @Bindable var tool: WindowZoomTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Click the green button to fill the screen, click again to go back. Full screen stays in the button’s menu and on ⌃⌘F."),
            hint: Text("Full screen: ⌃⌘F or the button’s menu"),
            isOn: $tool.isEnabled
        )
        AppExclusions(
            title: String(localized: "Green button works as usual in these apps"),
            apps: $tool.excluded,
            isEnabled: tool.isEnabled
        )
    }
}
