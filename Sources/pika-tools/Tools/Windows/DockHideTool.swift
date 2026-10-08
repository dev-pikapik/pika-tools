import AppKit
import ApplicationServices
import SwiftUI

@Observable
final class DockHideTool: Tool {
    let id = "dock-hide"
    let icon = "dock.rectangle"
    var title: String { String(localized: "Hide with a click in the Dock") }
    let tab = SettingsTab.dock

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var swallowsMouseUp = false

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(DockHideSettings(tool: self))
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
        swallowsMouseUp = false
        isActive = false
    }

    fileprivate func appToHide(at point: CGPoint) -> NSRunningApplication? {
        guard let front = NSWorkspace.shared.frontmostApplication,
              let dock = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first
        else { return nil }
        let dockElement = AXUIElementCreateApplication(dock.processIdentifier)
        AXUIElementSetMessagingTimeout(dockElement, 0.25)
        var hit: AXUIElement?
        guard AXUIElementCopyElementAtPosition(dockElement, Float(point.x), Float(point.y), &hit) == .success, let hit,
              Self.value(hit, kAXSubroleAttribute) as? String == "AXApplicationDockItem",
              let url = Self.value(hit, kAXURLAttribute) as? URL,
              url.standardizedFileURL == front.bundleURL?.standardizedFileURL,
              Self.hasVisibleWindows(front.processIdentifier)
        else { return nil }
        return front
    }

    private static func value(_ element: AXUIElement, _ attribute: String) -> CFTypeRef? {
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success ? value : nil
    }

    private static func hasVisibleWindows(_ pid: pid_t) -> Bool {
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        return list.contains {
            $0[kCGWindowOwnerPID as String] as? pid_t == pid && $0[kCGWindowLayer as String] as? Int == 0
        }
    }
}

private func dockHideCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<DockHideTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .leftMouseDown:
        tool.swallowsMouseUp = false
        guard event.flags.isDisjoint(with: [.maskCommand, .maskControl, .maskAlternate, .maskShift]),
              let app = tool.appToHide(at: event.location)
        else { break }
        tool.swallowsMouseUp = true
        DispatchQueue.main.async { app.hide() }
        return nil
    case .leftMouseUp:
        if tool.swallowsMouseUp {
            tool.swallowsMouseUp = false
            return nil
        }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct DockHideArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.2, 1.1, 0.15, 1.2, 0.15, 1.3]

    var body: some View {
        let step = reduceMotion ? 3 : tick % Self.durations.count
        let hidden = on && (3...4).contains(step)
        let aimed = step != 0
        IllustrationRow {
            Stage {
                ArtWindow {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .scaleEffect(hidden ? 0.12 : 1, anchor: .bottom)
                .offset(y: hidden ? 38 : 0)
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
        .loop($tick, Self.durations)
    }
}

private struct DockHideSettings: View {
    @Bindable var tool: DockHideTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { DockHideArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Click the icon of the open app to hide it"),
            hint: Text("Click again to bring it back"),
            help: Text("Click the icon of the app you’re in to hide it. Click again to bring it back."),
            isOn: $tool.isEnabled
        )
    }
}
