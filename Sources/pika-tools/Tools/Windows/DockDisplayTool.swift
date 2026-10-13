import AppKit
import ApplicationServices
import SwiftUI

/// Keeps the Dock on the display it's on. macOS moves the Dock to whichever display's bottom edge the pointer pushes
/// against; on the other displays the pointer steps back from that edge before the push adds up.
/// Watching and moving the pointer needs no permission.
@Observable
final class DockDisplayTool: Tool {
    let id = "dock-display"
    let icon = "display.2"
    var title: String { String(localized: "Keep the Dock on one display") }
    let tab = SettingsTab.dock
    let needs: [Permission] = []

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            if !isEnabled { UserDefaults.standard.removeObject(forKey: Self.anchorKey) }
            refresh()
        }
    }

    #if !APPSTORE
    /// Pushes the Dock back after sleep or a display change. Pushing for the user needs Accessibility.
    var returnsDock: Bool {
        didSet {
            UserDefaults.standard.set(returnsDock, forKey: Self.returnKey)
            refresh()
        }
    }

    var isDefault: Bool { !isEnabled && !returnsDock }
    #endif

    private static let anchorKey = "dock-display-anchor", returnKey = "dock-display-return"

    @ObservationIgnored private var monitors: [Any] = []
    @ObservationIgnored private var observer: NSObjectProtocol?
    @ObservationIgnored private var displays: [DockFence.Display] = []
    @ObservationIgnored private var anchor: DockFence.Display?
    @ObservationIgnored private var dockID: CGDirectDisplayID?
    @ObservationIgnored private var edge = DockFence.Edge.bottom
    @ObservationIgnored private var checked = Date.distantPast
    @ObservationIgnored private var moving: (id: CGDirectDisplayID, since: Date)?
    @ObservationIgnored private var looking = false
    @ObservationIgnored private var streak = 0
    @ObservationIgnored private var lastHit = Date.distantPast
    #if !APPSTORE
    @ObservationIgnored private var push: Timer?
    #endif

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        #if !APPSTORE
        returnsDock = UserDefaults.standard.bool(forKey: Self.returnKey)
        #endif
    }

    var settingsView: AnyView {
        AnyView(DockDisplaySettings(tool: self))
    }

    func reset() {
        isEnabled = false
        #if !APPSTORE
        returnsDock = false
        #endif
    }

    func load() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        #if !APPSTORE
        returnsDock = UserDefaults.standard.bool(forKey: Self.returnKey)
        #endif
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        update()
        let kinds: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        monitors = [
            NSEvent.addGlobalMonitorForEvents(matching: kinds) { [weak self] _ in self?.moved() },
            NSEvent.addLocalMonitorForEvents(matching: kinds) { [weak self] event in
                self?.moved()
                return event
            },
        ].compactMap { $0 }
        observer = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            self?.update()
            self?.bringBackSoon()
        }
        isActive = true
        bringBackSoon()
    }

    private func stop() {
        monitors.forEach(NSEvent.removeMonitor)
        monitors = []
        if let observer { NotificationCenter.default.removeObserver(observer) }
        observer = nil
        isActive = false
    }

    /// Reads the displays, which one has the Dock, and which one the Dock belongs on.
    private func update() {
        checked = Date()
        let screens = NSScreen.screens
        displays = screens.map { DockFence.Display(id: $0.displayID, frame: CGDisplayBounds($0.displayID)) }
        if let dock = DockFence.dock(screens.map {
            let frame = $0.frame, visible = $0.visibleFrame
            return (id: $0.displayID, bottom: visible.minY - frame.minY, left: visible.minX - frame.minX, right: frame.maxX - visible.maxX)
        }) {
            dockID = dock.id
            edge = dock.edge
        }
        let defaults = UserDefaults.standard
        if let moving, Date().timeIntervalSince(moving.since) > 5 { self.moving = nil }
        if let moving, moving.id == dockID, let uuid = Self.uuid(moving.id) {
            defaults.set(uuid, forKey: Self.anchorKey)
            self.moving = nil
        }
        if defaults.string(forKey: Self.anchorKey) == nil, let uuid = Self.uuid(dockID ?? CGMainDisplayID()) {
            defaults.set(uuid, forKey: Self.anchorKey)
        }
        let saved = defaults.string(forKey: Self.anchorKey)
        anchor = displays.first { Self.uuid($0.id) == saved }
    }

    private func moved() {
        guard let point = CGEvent(source: nil)?.location, DockFence.pressing(point, displays) != nil else { return }
        if Date().timeIntervalSince(checked) > 0.5 { update() }
        guard let anchor, let hit = DockFence.pressing(point, displays), hit.edge == edge, hit.display.id != anchor.id else { return }
        if NSEvent.modifierFlags.contains(.option) { return follow(hit.display.id) }
        guard hit.display.id != dockID else { return }
        // ponytail: the pointer is moved after the event, so pushes that keep coming step back further each time.
        let now = Date()
        streak = now.timeIntervalSince(lastHit) < 0.4 ? min(streak + 1, 3) : 0
        lastHit = now
        CGEventSource(stateID: .combinedSessionState)?.localEventsSuppressionInterval = 0
        CGWarpMouseCursorPosition(DockFence.away(point, from: hit.edge, of: hit.display.frame, by: DockFence.gap * CGFloat(1 << streak)))
    }

    /// With ⌥ held the push goes through, and the display the Dock lands on becomes its new one.
    private func follow(_ id: CGDirectDisplayID) {
        moving = (id, Date())
        if !looking { look() }
    }

    private func look() {
        looking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            update()
            if isActive, let moving, Date().timeIntervalSince(moving.since) < 3 { look() } else { looking = false }
        }
    }

    #if !APPSTORE
    private func bringBackSoon() {
        guard returnsDock else { return }
        for delay in [2.0, 6.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.bringBack() }
        }
    }

    /// Pushes the pointer against the edge of the Dock's display until the Dock comes back, then puts the pointer back.
    private func bringBack() {
        update()
        guard isActive, returnsDock, push == nil, AXIsProcessTrusted(), NSEvent.pressedMouseButtons == 0,
              NSScreen.screensHaveSeparateSpaces, let anchor, dockID != anchor.id,
              let spot = DockFence.spot(on: anchor, edge: edge, displays),
              let back = CGEvent(source: nil)?.location else { return }
        let source = CGEventSource(stateID: .hidSystemState)
        source?.localEventsSuppressionInterval = 0
        let toward: (x: Int64, y: Int64) = switch edge {
        case .bottom: (0, 4)
        case .left: (-4, 0)
        case .right: (4, 0)
        }
        let end = Date().addingTimeInterval(1.5)
        push = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            update()
            let done = !isActive || dockID == anchor.id || Date() > end
            let point = done ? back : spot
            CGWarpMouseCursorPosition(point)
            if let event = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) {
                if !done {
                    event.setIntegerValueField(.mouseEventDeltaX, value: toward.x)
                    event.setIntegerValueField(.mouseEventDeltaY, value: toward.y)
                }
                event.post(tap: .cghidEventTap)
            }
            if done {
                timer.invalidate()
                push = nil
            }
        }
    }
    #else
    private func bringBackSoon() {}
    #endif

    private static func uuid(_ id: CGDirectDisplayID) -> String? {
        guard let uuid = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil, uuid) as String?
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }
}

struct DockDisplayArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.0, 1.1, 1.4, 1.2]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 2 : tick % Self.durations.count
            let jumped = !on && step >= 2
            let bounced = on && step >= 2
            Stage {
                ArtMonitor(glow: 0.8, dock: false) { dock(shown: !jumped) }
                    .position(x: 84, y: 64)
                ArtMonitor(glow: 0.8, dock: false) {
                    ZStack(alignment: .bottom) {
                        dock(shown: jumped)
                        Capsule().fill(.white).frame(width: 46, height: 2)
                            .shadow(color: .white, radius: 3)
                            .padding(.bottom, 1)
                            .opacity(on && step == 2 ? 0.9 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .position(x: 216, y: 64)
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 104, y: 46) : CGPoint(x: 222, y: bounced ? 55 : 67))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
    }

    @ViewBuilder private func dock(shown: Bool) -> some View {
        if shown {
            ArtDock(appDot: false, icon: 7)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 2)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

private struct DockDisplaySettings: View {
    @Bindable var tool: DockDisplayTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { DockDisplayArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Hold ⌥ to move it on purpose"),
            hint: Text("Hold ⌥ to move it on purpose"),
            help: Text("The Dock stays on the display it’s on now, even when the pointer reaches the edge of another one. To move it, hold ⌥ and push the pointer against the edge of the other display."),
            isOn: $tool.isEnabled
        )
        #if !APPSTORE
        if inSettings {
            ToggleRow(
                icon: "arrow.uturn.backward",
                title: String(localized: "Bring the Dock back"),
                subtitle: Text("After sleep or when displays change"),
                isOn: $tool.returnsDock
            )
            .needs([.accessibility])
            .disabled(!tool.isEnabled)
        }
        #endif
    }
}
