import AppKit
import SwiftUI

@Observable
final class MiddleClickTool: Tool {
    let id = "middle-click"
    let icon = "hand.tap"
    var title: String { String(localized: "Middle click on the trackpad") }
    var needs: [Permission] { [.accessibility, .inputMonitoring] }
    let tab = SettingsTab.mouse

    private static let fingersKey = "middle-click-fingers"
    private static let gestureKind = CGEventField(rawValue: 110)!

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var fingers: Int {
        didSet { UserDefaults.standard.set(fingers, forKey: Self.fingersKey) }
    }

    @ObservationIgnored private var taps: [CFMachPort] = []
    @ObservationIgnored private var sources: [CFRunLoopSource] = []
    @ObservationIgnored private var gesture = MiddleClickGesture()
    @ObservationIgnored private var pressing = false

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        fingers = Self.savedFingers
    }

    private static var savedFingers: Int {
        UserDefaults.standard.integer(forKey: fingersKey) == 4 ? 4 : 3
    }

    func load() {
        fingers = Self.savedFingers
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(MiddleClickSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && fingers == 3 }

    func reset() {
        isEnabled = false
        fingers = 3
    }

    func refresh() {
        stop()
        guard isEnabled, AXIsProcessTrusted(), Permissions.shared.inputMonitoring else { return }
        start()
    }

    private func start() {
        gesture.reset()
        pressing = false
        let touches = CGEventMask(1) << NSEvent.EventType.gesture.rawValue
        let clicks = [CGEventType.leftMouseDown, .leftMouseUp, .leftMouseDragged, .rightMouseDown, .rightMouseUp, .rightMouseDragged]
            .reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }
        let me = Unmanaged.passUnretained(self).toOpaque()
        taps = [
            CGEvent.tapCreate(tap: .cgSessionEventTap, place: .tailAppendEventTap, options: .listenOnly, eventsOfInterest: touches, callback: middleClickTouches, userInfo: me),
            CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: clicks, callback: middleClickPresses, userInfo: me),
        ].compactMap { $0 }
        guard taps.count == 2 else { return stop() }
        for tap in taps {
            guard let source = CFMachPortCreateRunLoopSource(nil, tap, 0) else { return stop() }
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            sources.append(source)
        }
        isActive = true
    }

    private func stop() {
        for tap in taps {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        for source in sources {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        taps = []
        sources = []
        isActive = false
    }

    /// Fingers come in frames; scroll and pressure frames carry none and are skipped.
    fileprivate func touched(_ event: CGEvent) {
        guard event.getIntegerValueField(Self.gestureKind) == 0, let frame = NSEvent(cgEvent: event) else { return }
        let touches = frame.allTouches()
            .filter { !$0.isResting && NSTouch.Phase.touching.contains($0.phase) }
            .map { MiddleClickGesture.Touch(id: $0.identity.hash, position: $0.normalizedPosition) }
        guard gesture.update(touches, at: frame.timestamp, fingers: fingers), !pressing, TrackpadSystem.read().taps(fingers) else { return }
        Self.click()
    }

    /// A press with the chosen number of fingers turns into the middle button, down, drag and up.
    fileprivate func pressed(_ event: CGEvent, _ type: CGEventType) {
        switch type {
        case .leftMouseDown, .rightMouseDown:
            gesture.press()
            guard !pressing, gesture.count == fingers, TrackpadSystem.read().clicks(fingers) else { return }
            pressing = true
            event.type = .otherMouseDown
        case .leftMouseDragged, .rightMouseDragged:
            guard pressing else { return }
            event.type = .otherMouseDragged
        default:
            guard pressing else { return }
            pressing = false
            event.type = .otherMouseUp
        }
        event.setIntegerValueField(.mouseEventButtonNumber, value: Int64(CGMouseButton.center.rawValue))
    }

    private static func click() {
        guard let location = CGEvent(source: nil)?.location else { return }
        for type in [CGEventType.otherMouseDown, .otherMouseUp] {
            let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: location, mouseButton: .center)
            event?.setIntegerValueField(.mouseEventClickState, value: 1)
            event?.post(tap: .cghidEventTap)
        }
    }
}

private func middleClickTouches(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<MiddleClickTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    default:
        tool.touched(event)
    }
    return Unmanaged.passUnretained(event)
}

private func middleClickPresses(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<MiddleClickTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    default:
        tool.pressed(event, type)
    }
    return Unmanaged.passUnretained(event)
}

/// What System Settings already does with three fingers, read fresh each time it matters.
struct TrackpadSystem: Equatable {
    var tapToClick = false
    var threeFingerDrag = false
    var threeFingerLookUp = false

    static func read() -> TrackpadSystem {
        func on(_ key: String, _ value: Int) -> Bool {
            PointerShortcuts.trackpads.contains { domain in
                CFPreferencesAppSynchronize(domain as CFString)
                return (CFPreferencesCopyAppValue(key as CFString, domain as CFString) as? NSNumber)?.intValue == value
            }
        }
        return TrackpadSystem(
            tapToClick: on("Clicking", 1),
            threeFingerDrag: on("TrackpadThreeFingerDrag", 1),
            threeFingerLookUp: on("TrackpadThreeFingerTapGesture", 2)
        )
    }

    func clicks(_ fingers: Int) -> Bool { fingers != 3 || !threeFingerDrag }
    func taps(_ fingers: Int) -> Bool { tapToClick && clicks(fingers) && (fingers != 3 || !threeFingerLookUp) }
}

struct MiddleClickArt: View {
    let on: Bool
    var fingers = 3
    var taps = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.8, 0.35, 0.9, 0.8, 0.35, 0.9, 0.8]
    private static let link = CGPoint(x: 160, y: 74)
    private static let newTab = CGPoint(x: 199, y: 34)

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 2 : tick % Self.durations.count
            let touching = reduceMotion || step == 1 || step == 4
            let opened = on && (2...4).contains(step)
            let target = on && (3...5).contains(step) ? Self.newTab : Self.link
            Stage {
                ArtTrackpad(touch: touching, width: 92, fingers: fingers)
                    .scaleEffect(touching && !taps ? 0.96 : 1)
                    .position(x: 58, y: 66)
                ArtWindow(size: CGSize(width: 176, height: 104)) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 3) {
                            tab(Color.teal, active: true)
                            if opened {
                                tab(Color.accentColor, active: false)
                                    .transition(.scale(scale: 0.5, anchor: .leading).combined(with: .opacity))
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 6)
                        .frame(height: 16)
                        .background(Color.primary.opacity(0.04))
                        VStack(alignment: .leading, spacing: 6) {
                            line(110)
                            line(90)
                            Capsule().fill(Color.accentColor.opacity(0.8)).frame(width: 64, height: 4)
                            line(100)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .position(x: 206, y: 64)
                if on && touching && !reduceMotion { ArtRipple().position(target) }
                ArtCursor(pressed: touching && !reduceMotion).cursor(at: CGPoint(x: target.x - 2, y: target.y + 1))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }

    private func tab(_ color: Color, active: Bool) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color.opacity(0.7)).frame(width: 5, height: 5)
            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 26, height: 3)
        }
        .padding(.horizontal, 5)
        .frame(width: 48, height: 12, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 3, style: .continuous).fill(active ? Color(nsColor: .windowBackgroundColor) : Color.primary.opacity(0.06)))
    }

    private func line(_ width: CGFloat) -> some View {
        Capsule().fill(Color.primary.opacity(0.14)).frame(width: width, height: 4)
    }
}

private struct MiddleClickSettings: View {
    @Bindable var tool: MiddleClickTool
    @Environment(\.inSettings) private var inSettings
    @State private var system = TrackpadSystem.read()

    var body: some View {
        if inSettings { MiddleClickArt(on: tool.isEnabled, fingers: tool.fingers, taps: system.taps(tool.fingers)) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Like the middle mouse button"),
            hint: Text("Like the middle mouse button"),
            help: Text("Tap or click with three or four fingers to open a link in a new tab or close a tab, like the middle mouse button."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            LabeledContent {
                HStack(alignment: .top, spacing: 16) {
                    ForEach([3, 4], id: \.self) { count in
                        ChoiceTile(
                            title: count == 3 ? String(localized: "Three fingers") : String(localized: "Four fingers"),
                            selected: tool.fingers == count,
                            size: CGSize(width: 96, height: 60),
                            action: { tool.fingers = count }
                        ) {
                            ArtTrackpad(touch: true, width: 60, fingers: count)
                        }
                    }
                }
                .padding(.vertical, 6)
                .accessibilityElement(children: .contain)
            } label: {
                RowLabel(Text("Fingers"), status)
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Fingers"))
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in system = TrackpadSystem.read() }
        }
    }

    private var status: Text {
        if !system.clicks(tool.fingers) { return Text("Three-finger drag is on: choose four fingers") }
        if system.taps(tool.fingers) { return tool.fingers == 3 ? Text("Tap or click with three fingers") : Text("Tap or click with four fingers") }
        return system.tapToClick ? Text("Click only: a tap looks up the word") : Text("Click only: tap to click is off")
    }
}
