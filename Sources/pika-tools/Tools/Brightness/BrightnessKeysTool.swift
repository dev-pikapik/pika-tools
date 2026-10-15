import AppKit
import SwiftUI

@Observable
final class BrightnessKeysTool: Tool {
    static let shared = BrightnessKeysTool()

    let id = "brightness-keys"
    let icon = "sun.max"
    var title: String { String(localized: "Brightness keys") }
    let tab = SettingsTab.brightness
    var needs: [Permission] { [.accessibility] }

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var held: Set<Int> = []

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(BrightnessKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled, MainCopy.canAct, AXIsProcessTrusted() { start() }
    }

    private func start() {
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << 14),
            callback: brightnessKeysCallback,
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
        held = []
        isActive = false
    }

    fileprivate func handle(_ event: CGEvent) -> Bool {
        guard let event = NSEvent(cgEvent: event), event.type == .systemDefined, event.subtype.rawValue == 8 else { return false }
        let key = (event.data1 & 0xFFFF0000) >> 16, state = (event.data1 & 0xFF00) >> 8
        guard key == 2 || key == 3 else { return false }
        if state == 0xB { return held.remove(key) != nil }
        guard state == 0xA, !GameModeTool.shared.isPlaying,
              let screen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) })
        else { return false }
        let fine = event.modifierFlags.contains([.option, .shift])
        let changed = MainActor.assumeIsolated {
            guard let level = Brightness.shared.step(screen.displayID, up: key == 2, fine: fine) else { return false }
            BrightnessHUD.show(level, on: screen)
            return true
        }
        if changed { held.insert(key) }
        return changed
    }
}

private func brightnessKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<BrightnessKeysTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    default:
        if tool.handle(event) { return nil }
    }
    return Unmanaged.passUnretained(event)
}

@MainActor
private enum BrightnessHUD {
    private static let view = NSHostingView(rootView: BrightnessHUDView(level: 0))
    private static let panel = makePanel()
    private static var shown = 0

    static func show(_ level: Double, on screen: NSScreen) {
        view.rootView = BrightnessHUDView(level: level)
        let size = view.fittingSize
        panel.setFrame(NSRect(x: screen.visibleFrame.maxX - size.width, y: screen.visibleFrame.maxY - size.height, width: size.width, height: size.height), display: false)
        let fade = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.2
        if !panel.isVisible { panel.alphaValue = 0 }
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { $0.duration = fade; panel.animator().alphaValue = 1 }
        shown += 1
        let mark = shown
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            MainActor.assumeIsolated {
                guard mark == shown else { return }
                NSAnimationContext.runAnimationGroup { $0.duration = fade; panel.animator().alphaValue = 0 } completionHandler: {
                    MainActor.assumeIsolated { if mark == shown { panel.orderOut(nil) } }
                }
            }
        }
        NSAccessibility.post(element: NSApplication.shared, notification: .announcementRequested, userInfo: [
            .announcement: "\(String(localized: "Brightness")) \(level.formatted(.percent.precision(.fractionLength(0))))",
            .priority: NSAccessibilityPriorityLevel.high.rawValue,
        ])
    }

    private static func makePanel() -> NSPanel {
        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = view
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        return panel
    }
}

private struct BrightnessHUDView: View {
    let level: Double

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            Capsule()
                .fill(.quaternary)
                .frame(width: 120, height: 6)
                .overlay(alignment: .leading) {
                    Capsule().fill(.primary).frame(width: 120 * min(max(level, 0), 1))
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 22)
        .padding(12)
        .accessibilityHidden(true)
    }
}

struct BrightnessArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.4, 0.3, 0.7, 0.3, 1.1, 1.2, 0.3, 0.7, 0.3, 1.1]
    private static let levels = [1, 0.6, 0.6, 0.25, 0.25, 0.25, 0.6, 0.6, 1, 1]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 4 : tick % Self.durations.count
            let level = on ? Self.levels[step] : 1
            let shown = on && step != 0 && step != 5
            Stage {
                ArtMonitor(glow: level, dock: false) {
                    ZStack(alignment: .bottom) {
                        GeometryReader { ArtLandscape(size: $0.size) }
                        Color.black.opacity((1 - level) * 0.7)
                        hud(level)
                            .scaleEffect(shown ? 1 : 0.9, anchor: .bottom)
                            .opacity(shown ? 1 : 0)
                            .padding(.bottom, 7)
                    }
                }
                .position(x: 88, y: 64)
                HStack(spacing: 10) {
                    ArtKey(down: step == 1 || step == 3, width: 44, height: 30) { Image(systemName: "sun.min") }
                    ArtKey(down: step == 6 || step == 8, width: 44, height: 30) { Image(systemName: "sun.max") }
                }
                .animation(reduceMotion ? nil : .smooth(duration: 0.15), value: step)
                .position(x: 222, y: 58)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
    }

    private func hud(_ level: Double) -> some View {
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
        return HStack(spacing: 4) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(Color.primary)
            Capsule()
                .fill(Color.primary.opacity(0.18))
                .frame(width: 36, height: 3)
                .overlay(alignment: .leading) {
                    Capsule().fill(Color.primary).frame(width: 36 * level)
                }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4.5)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.9), in: shape)
        .overlay(shape.hairline(Color.primary.opacity(0.14)))
        .shadow(color: .black.opacity(0.22), radius: 4.5, y: 2)
    }
}

private struct BrightnessKeysSettings: View {
    @Bindable var tool: BrightnessKeysTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { BrightnessArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Adjust the monitor under the pointer with the brightness keys."),
            isOn: $tool.isEnabled
        )
    }
}
