import AppKit
import SwiftUI

/// Stops the Dock from following the pointer to another display with the Dock's own switch, which the Dock reads only when it starts.
@Observable
final class DockDisplayTool: Tool {
    let id = "dock-display"
    let icon = "display.2"
    var title: String { String(localized: "Keep the Dock on one display") }
    let tab = SettingsTab.dock
    let needs: [Permission] = []

    var isActive: Bool { isEnabled }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    private static let dock = "com.apple.dock" as CFString, key = "allow-display-switching" as CFString
    private static let ownedKey = "dock-display-owned", beforeKey = "dock-display-before"

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(DockDisplaySettings(tool: self))
    }

    func refresh() {
        if Self.apply(isEnabled) { AnimationsTool.shared.restartDock() }
    }

    static func uninstall() {
        if apply(false) { AnimationsTool.killall("Dock", wait: true) }
    }

    private static func apply(_ on: Bool) -> Bool {
        let defaults = UserDefaults.standard
        CFPreferencesAppSynchronize(dock)
        let current = CFPreferencesCopyAppValue(key, dock) as? Bool
        let plan = DockDisplaySwitch.plan(on: on, current: current, owned: defaults.bool(forKey: ownedKey), before: defaults.object(forKey: beforeKey) as? Bool)
        if plan.value != current {
            CFPreferencesSetAppValue(key, plan.value.map { $0 as CFBoolean }, dock)
            CFPreferencesAppSynchronize(dock)
        }
        defaults.set(on, forKey: ownedKey)
        defaults.set(plan.before, forKey: beforeKey)
        return plan.restart
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
            Stage {
                ArtMonitor(glow: 0.8, dock: false) { dock(shown: !jumped) }
                    .position(x: 84, y: 64)
                ArtMonitor(glow: 0.8, dock: false) { dock(shown: jumped) }
                    .position(x: 216, y: 64)
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 104, y: 46) : CGPoint(x: 222, y: 67))
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
    private static let displays = URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension")!

    var body: some View {
        if inSettings { DockDisplayArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("To move it, make another display the main one"),
            hint: Text("To move it, make another display the main one"),
            help: Text("The Dock no longer jumps to another display when the pointer hits its bottom edge, however fast you move. To move the Dock, make another display the main one. Turning this on or off restarts the Dock."),
            isOn: $tool.isEnabled
        )
        if inSettings { SystemSettingsRow(title: String(localized: "Main display"), subtitle: Text("Click the display you want, then choose “Main display” in “Use as”"), url: Self.displays) }
    }
}
