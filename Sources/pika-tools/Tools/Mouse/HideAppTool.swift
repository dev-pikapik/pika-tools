import AppKit
import SwiftUI

@Observable
final class HideAppTool: Tool {
    let id = "hide-app"
    let icon = "eye.slash"
    var title: String { String(localized: "Mouse button hides the current app") }
    let tab = SettingsTab.mouse

    static var taken: Int64?
    static var isRecording = false

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var button: Int {
        didSet {
            UserDefaults.standard.set(button, forKey: "hide-app-button")
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var held = false

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        button = UserDefaults.standard.integer(forKey: "hide-app-button")
    }

    func load() {
        button = UserDefaults.standard.integer(forKey: "hide-app-button")
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(HideAppSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && button == 0 }

    func reset() {
        isEnabled = false
        button = 0
    }

    func refresh() {
        stop()
        if isEnabled, AXIsProcessTrusted() { start() }
    }

    private func start() {
        let types: [CGEventType] = [.otherMouseDown, .otherMouseUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: hideAppCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        Self.taken = Int64(button)
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
        Self.taken = nil
        held = false
        isActive = false
    }

    fileprivate func handle(_ event: CGEvent, down: Bool) -> Bool {
        guard Int(event.getIntegerValueField(.mouseEventButtonNumber)) == button,
              event.getIntegerValueField(.eventSourceUserData) != SideButtonsTool.tag
        else { return false }
        guard down else {
            defer { held = false }
            return held
        }
        held = !Self.isRecording && !GameModeTool.shared.isPlaying
        if held, let app = NSWorkspace.shared.frontmostApplication {
            DispatchQueue.main.async { app.hide() }
        }
        return held
    }
}

private func hideAppCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<HideAppTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .otherMouseDown, .otherMouseUp:
        if tool.handle(event, down: type == .otherMouseDown) { return nil }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct HideAppArt: View {
    let on: Bool
    let button: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.5, 0.4, 1.3]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 1 : tick % Self.durations.count
            let pressed = step == 1
            let hidden = on && step > 0
            let side = button == 3 || button == 4
            let animation: Animation = [.smooth(duration: 0.5), .easeOut(duration: 0.18), .smooth(duration: 0.3)][step]
            Stage {
                ArtMouse(wheel: pressed && !side, sideButtons: side, back: pressed && button == 3, forward: pressed && button == 4)
                    .artScale(2.1)
                    .position(x: 62, y: 66)
                ArtWindow {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .scaleEffect(hidden ? 0.9 : 1)
                .opacity(hidden ? (reduceMotion ? 0.4 : 0) : 1)
                .position(x: 204, y: 44)
                ArtDock()
                    .position(x: 204, y: 102)
            }
            .animation(reduceMotion ? nil : animation, value: step)
        }
    }
}

private struct HideAppSettings: View {
    @Bindable var tool: HideAppTool
    @Environment(\.inSettings) private var inSettings
    @State private var monitor: Any?

    private var buttonName: Text {
        tool.button == 2 ? Text("Middle button") : Text("Button \(tool.button + 1)")
    }

    var body: some View {
        if inSettings { HideAppArt(on: tool.isEnabled, button: tool.button) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Like ⌘H, the app stays open"),
            hint: tool.button > 0 ? buttonName : Text("Like ⌘H, the app stays open"),
            help: Text("Press the chosen mouse button to hide the app in front, like ⌘H."),
            isOn: Binding(get: { tool.isEnabled }, set: {
                tool.isEnabled = $0
                if $0, tool.button == 0, !inSettings { SettingsWindow.show(.mouse) }
            })
        )
        .onChange(of: tool.isEnabled, initial: true) {
            if !tool.isEnabled { finish() } else if inSettings, tool.button == 0 { record() }
        }
        .onDisappear(perform: finish)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in finish() }
        if inSettings, monitor != nil || tool.button > 0 {
            LabeledContent {
                if monitor == nil {
                    Button("Change…", action: record)
                } else {
                    Button("Cancel", action: finish)
                }
            } label: {
                RowLabel(monitor == nil ? buttonName : Text("Press a mouse button over this window"))
            }
            .disabled(!tool.isEnabled)
        }
    }

    private func record() {
        guard monitor == nil else { return }
        HideAppTool.isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .otherMouseDown) { event in
            tool.button = event.buttonNumber
            finish()
            return nil
        }
    }

    private func finish() {
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
        HideAppTool.isRecording = false
        if tool.button == 0 { tool.isEnabled = false }
    }
}
