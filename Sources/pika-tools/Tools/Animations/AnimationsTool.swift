import AppKit
import SwiftUI

@Observable
final class AnimationsTool: Tool {
    static let shared = AnimationsTool()

    let id = "animations"
    let icon = "hare"
    var title: String { String(localized: "Animations") }
    var tab: SettingsTab { .animations }
    var isActive: Bool { isEnabled }
    var isDefault: Bool { owned.isEmpty }

    var isEnabled: Bool {
        get { !owned.isEmpty }
        set { if !newValue { reset() } }
    }

    private(set) var owned: [AnimationSetting: Double]
    private(set) var own: [AnimationSetting: Double]
    private(set) var system: [AnimationSetting: Double] = [:]
    private(set) var storedSpeed: Double?
    private(set) var autohide = false
    private(set) var appsPending = false
    private(set) var finderPending = false
    @ObservationIgnored private var dockRestart: DispatchWorkItem?

    private static let dock = "com.apple.dock" as CFString
    private static let speedKey = "animations-speed"
    private static let ownKey = "animations-own"

    private init() {
        owned = Self.saved()
        own = Self.originals()
        storedSpeed = UserDefaults.standard.object(forKey: Self.speedKey) as? Double
        reload()
    }

    var settingsView: AnyView {
        AnyView(AnimationsPage())
    }

    var values: [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.map { ($0, value($0)) })
    }

    var speed: Double? {
        AnimationSpeed.speed(of: values, stored: storedSpeed, baseline: baseline)
    }

    var baseline: [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.map { ($0, baseline($0)) })
    }

    func value(_ setting: AnimationSetting) -> Double {
        owned[setting] ?? system[setting] ?? setting.macOS
    }

    func baseline(_ setting: AnimationSetting) -> Double {
        (owned[setting] == nil ? system[setting] : own[setting]) ?? setting.macOS
    }

    func reload() {
        system = Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.compactMap { setting in setting.read().map { (setting, $0) } })
        CFPreferencesAppSynchronize(Self.dock)
        autohide = CFPreferencesCopyAppValue("autohide" as CFString, Self.dock) as? Bool ?? false
    }

    func set(_ setting: AnimationSetting, _ value: Double) {
        var new = owned
        new[setting] = abs(value - baseline(setting)) < 0.0005 ? nil : value
        storedSpeed = nil
        apply(new)
    }

    func setSpeed(_ speed: Double) {
        var new = owned
        for (setting, value) in AnimationSpeed.preset(speed, baseline: baseline) {
            new[setting] = abs(value - baseline(setting)) < 0.0005 ? nil : value
        }
        storedSpeed = speed > 0 ? speed : nil
        apply(new)
    }

    func setAutohide(_ on: Bool) {
        CFPreferencesSetAppValue("autohide" as CFString, on as CFBoolean, Self.dock)
        CFPreferencesAppSynchronize(Self.dock)
        autohide = on
        restartDock()
    }

    func restartFinder() {
        finderPending = false
        Self.killall("Finder")
    }

    func reset() {
        storedSpeed = nil
        apply([:])
    }

    func refresh() {
        reload()
        apply(owned)
    }

    func load() {
        storedSpeed = UserDefaults.standard.object(forKey: Self.speedKey) as? Double
        reload()
        apply(Self.saved())
    }

    static func uninstall() {
        let own = originals()
        let settings = saved().keys
        settings.forEach { $0.write(own[$0]) }
        if settings.contains(where: { $0.apply == .dock }) { killall("Dock", wait: true) }
    }

    private func apply(_ new: [AnimationSetting: Double]) {
        let changes = AnimationSetting.changes(from: owned, to: new, system: system, own: own)
        own = AnimationSetting.originals(own, owned: owned, new: new, system: system)
        owned = new
        let defaults = UserDefaults.standard
        let originals = own.isEmpty ? nil : Dictionary(uniqueKeysWithValues: own.map { ($0.key.rawValue, $0.value) })
        if defaults.dictionary(forKey: Self.ownKey) as? [String: Double] != originals {
            defaults.set(originals, forKey: Self.ownKey)
        }
        for setting in AnimationSetting.allCases where defaults.object(forKey: Self.key(setting)) as? Double != new[setting] {
            defaults.set(new[setting], forKey: Self.key(setting))
        }
        if defaults.object(forKey: Self.speedKey) as? Double != storedSpeed {
            defaults.set(storedSpeed, forKey: Self.speedKey)
        }
        guard !changes.isEmpty else { return }
        changes.forEach { $0.0.write($0.1) }
        reload()
        if changes.contains(where: { $0.0.apply == .dock && (autohide || !$0.0.isSpeed) }) { restartDock() }
        if changes.contains(where: { $0.0.apply == .apps }) { appsPending = true }
        if changes.contains(where: { $0.0.apply != .dock }) { finderPending = true }
    }

    private func restartDock() {
        dockRestart?.cancel()
        let work = DispatchWorkItem { Self.killall("Dock") }
        dockRestart = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    private static func key(_ setting: AnimationSetting) -> String {
        "animations-\(setting.rawValue)"
    }

    private static func saved() -> [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.compactMap { setting in
            (UserDefaults.standard.object(forKey: key(setting)) as? Double).map { (setting, $0) }
        })
    }

    private static func originals() -> [AnimationSetting: Double] {
        let saved = UserDefaults.standard.dictionary(forKey: ownKey) as? [String: Double] ?? [:]
        return Dictionary(uniqueKeysWithValues: saved.compactMap { key, value in AnimationSetting(rawValue: key).map { ($0, value) } })
    }

    private static func killall(_ name: String, wait: Bool = false) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        process.arguments = [name]
        guard (try? process.run()) != nil else { return }
        if wait { process.waitUntilExit() }
    }
}

extension AnimationLabel {
    var text: String {
        switch self {
        case .macOS: String(localized: "As in macOS")
        case .instant: String(localized: "Instant")
        case .custom: String(localized: "Custom")
        case .seconds(let seconds):
            Measurement(value: seconds, unit: UnitDuration.seconds)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...2))))
        case .faster(let factor):
            factor >= 5 ? String(localized: "Almost instant") : String(localized: "\(Self.format(factor)) times faster")
        case .slower(let factor):
            String(localized: "\(Self.format(factor)) times slower")
        }
    }

    private static func format(_ factor: Double) -> String {
        factor.formatted(.number.precision(.fractionLength(0...1)))
    }
}

extension AnimationSetting {
    var title: String {
        switch self {
        case .dockDelay: String(localized: "Delay before the Dock appears")
        case .dockSpeed: String(localized: "How fast the Dock slides out")
        case .minimize: String(localized: "Minimize effect")
        case .bounce: String(localized: "Bouncing icons")
        case .windowOpen: String(localized: "Opening windows")
        case .resize: String(localized: "Save dialogs and resizing")
        case .quickLook: String(localized: "Quick Look")
        case .finderColumns: String(localized: "Columns in Finder")
        case .finder: String(localized: "Finder animations")
        }
    }

    var subtitle: String {
        switch self {
        case .minimize: String(localized: "How a window goes into the Dock")
        case .bounce: String(localized: "When an app needs your attention")
        case .windowOpen: String(localized: "A new window grows into place")
        case .finder: String(localized: "Opening folders and info windows")
        default: ""
        }
    }

    var help: Text {
        switch self {
        case .dockDelay: Text("How long the pointer rests at the screen edge before the hidden Dock slides out.")
        case .dockSpeed: Text("How long the hidden Dock takes to slide out and back.")
        case .minimize: Text("How a window flies into the Dock when you minimize it.")
        case .bounce: Text("When this is off, Dock icons stay still even when an app needs you.")
        case .windowOpen: Text("When this is off, new windows appear at once.")
        case .resize: Text("How fast Save and Print panels slide out and windows change size.")
        case .quickLook: Text("How fast a preview opens when you press Space on a file.")
        case .finderColumns: Text("How fast Finder moves to the next column in column view.")
        case .finder: Text("When this is off, Finder windows and info windows open at once.")
        }
    }
}

struct AnimationsPage: View {
    @Bindable private var tool = AnimationsTool.shared
    @State private var offersAutohide = false

    private static let motion = URL(string: "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Display")!

    var body: some View {
        Form {
            SettingsHeader(tab: .animations, text: String(localized: "How fast things move on your Mac"))
            Section {
                AnimationsArt(values: tool.values)
                SpeedRow(tool: tool)
                if offersAutohide {
                    Toggle(isOn: Binding(get: { tool.autohide }, set: { tool.setAutohide($0) })) {
                        RowLabel(Text("Hide the Dock automatically"), Text("Dock speed only works when the Dock hides"))
                    }
                }
            }
            Section("Fine-tuning") {
                Group {
                    SliderRow(tool: tool, setting: .dockDelay)
                    SliderRow(tool: tool, setting: .dockSpeed)
                }
                .disabled(!tool.autohide)
                MinimizeRow(tool: tool)
                FlagRow(tool: tool, setting: .bounce)
            }
            Section {
                FlagRow(tool: tool, setting: .windowOpen)
                SliderRow(tool: tool, setting: .resize)
                SliderRow(tool: tool, setting: .quickLook)
            }
            Section {
                SliderRow(tool: tool, setting: .finderColumns)
                FlagRow(tool: tool, setting: .finder)
            }
            Section {
                Button(String(localized: "Even calmer: Reduce Motion in Accessibility")) { NSWorkspace.shared.open(Self.motion) }
                    .buttonStyle(.link)
                    .settingAnchor(String(localized: "Even calmer: Reduce Motion in Accessibility"))
            }
            RestoreDefaultsSection(
                message: tool.own.isEmpty
                    ? String(localized: "All animations will be as in macOS again.")
                    : String(localized: "Animations will be as they were before pika-tools."),
                isDefault: tool.isDefault
            ) {
                tool.reset()
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .safeAreaInset(edge: .bottom, spacing: 0) { ChangesBar(tool: tool) }
        .environment(\.inSettings, true)
        .onAppear {
            tool.reload()
            offersAutohide = offersAutohide || !tool.autohide
        }
    }
}

private struct ChangesBar: View {
    let tool: AnimationsTool

    var body: some View {
        if tool.appsPending || tool.finderPending {
            HStack(spacing: 12) {
                Image(systemName: "arrow.clockwise")
                    .accessibilityHidden(true)
                if tool.appsPending {
                    Text("Works in apps after you reopen them")
                } else {
                    Text("Finder picks up the changes after a restart")
                }
                Spacer(minLength: 0)
                if tool.finderPending {
                    Button("Restart Finder") { tool.restartFinder() }
                        .help(Text("Finder closes its windows and opens again. Wait until files finish copying."))
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
        }
    }
}

private struct SpeedRow: View {
    let tool: AnimationsTool
    @State private var drag: Double?

    var body: some View {
        let title = String(localized: "Animation speed")
        let shown = drag ?? tool.speed
        let value = AnimationSpeed.label(shown).text
        VStack(alignment: .leading, spacing: 8) {
            RowLabel(Text(title), Text(value))
            PaceSlider(
                title: title,
                value: value,
                marks: AnimationSpeed.presets,
                snap: AnimationSpeed.snapped,
                position: tool.speed ?? tool.storedSpeed ?? 0,
                drag: $drag
            ) { tool.setSpeed($0) }
            ZStack {
                preset(String(localized: "As in macOS"), 0, alignment: .leading)
                preset(String(localized: "Faster"), 0.5, alignment: .center)
                preset(String(localized: "Instant"), 1, alignment: .trailing)
            }
            .padding(.horizontal, 26)
        }
        .settingAnchor(title)
        .help(Text("Sets all the effects below at once."))
    }

    private func preset(_ title: String, _ speed: Double, alignment: Alignment) -> some View {
        Button(title) { tool.setSpeed(speed) }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(tool.speed == speed ? Color.accentColor : Color.secondary)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}

private struct SliderRow: View {
    let tool: AnimationsTool
    let setting: AnimationSetting
    @State private var drag: Double?
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let committed = tool.value(setting)
        let value = setting.label(drag.map(setting.value(at:)) ?? committed).text
        VStack(alignment: .leading, spacing: 10) {
            SettingArt(tool: tool, setting: setting)
                .opacity(isEnabled ? 1 : 0.5)
            VStack(alignment: .leading, spacing: 6) {
                RowLabel(Text(setting.title), Text(value))
                    .opacity(isEnabled ? 1 : 0.5)
                PaceSlider(
                    title: setting.title,
                    value: value,
                    marks: [setting.mark],
                    snap: { setting.position(of: setting.value(at: $0)) },
                    position: setting.position(of: committed),
                    drag: $drag
                ) { tool.set(setting, setting.value(at: $0)) }
            }
        }
        .settingAnchor(setting.title)
        .help(setting.help)
    }
}

private struct FlagRow: View {
    let tool: AnimationsTool
    let setting: AnimationSetting

    var body: some View {
        VStack(spacing: 10) {
            SettingArt(tool: tool, setting: setting)
            Toggle(isOn: Binding(get: { tool.value(setting) != 0 }, set: { tool.set(setting, $0 ? 1 : 0) })) {
                RowLabel(Text(setting.title), Text(setting.subtitle))
            }
        }
        .settingAnchor(setting.title)
        .help(setting.help)
    }
}

private struct MinimizeRow: View {
    let tool: AnimationsTool

    private static var names: [String] {
        [String(localized: "Genie"), String(localized: "Scale"), String(localized: "Suck")]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SettingArt(tool: tool, setting: .minimize)
            VStack(alignment: .leading, spacing: 6) {
                RowLabel(Text(AnimationSetting.minimize.title), Text(AnimationSetting.minimize.subtitle))
                Picker(AnimationSetting.minimize.title, selection: Binding(get: { Int(tool.value(.minimize)) }, set: { tool.set(.minimize, Double($0)) })) {
                    ForEach(Array(Self.names.enumerated()), id: \.offset) { index, name in
                        Text(verbatim: name).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
        .settingAnchor(AnimationSetting.minimize.title)
        .help(AnimationSetting.minimize.help)
    }
}

private struct SettingArt: View {
    let tool: AnimationsTool
    let setting: AnimationSetting

    var body: some View {
        switch setting {
        case .dockDelay: DockDelayArt(delay: tool.value(.dockDelay), speed: tool.value(.dockSpeed))
        case .dockSpeed: DockSpeedArt(speed: tool.value(.dockSpeed))
        case .bounce: BounceArt(on: tool.value(.bounce) != 0)
        case .windowOpen: WindowOpenArt(on: tool.value(.windowOpen) != 0)
        case .resize: ResizeArt(seconds: tool.value(.resize))
        case .quickLook: QuickLookArt(seconds: tool.value(.quickLook))
        case .finderColumns: FinderColumnsArt(multiplier: tool.value(.finderColumns))
        case .finder: FinderWindowArt(on: tool.value(.finder) != 0)
        case .minimize: MinimizeArt(effect: Int(tool.value(.minimize)))
        }
    }
}

private struct PaceSlider: View {
    let title: String
    let value: String
    let marks: [Double]
    let snap: (Double) -> Double
    let position: Double
    @Binding var drag: Double?
    let commit: (Double) -> Void
    @State private var editing = false
    @State private var pending: Task<Void, Never>?

    var body: some View {
        let binding = Binding<Double>(
            get: { drag ?? position },
            set: { raw in
                let old = drag ?? position
                let new = snap(raw)
                if marks.contains(where: { ($0 == new && old != new) || ($0 - old) * ($0 - new) < 0 }) {
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                }
                drag = new
                pending?.cancel()
                guard !editing else { return }
                pending = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.4))
                    guard !Task.isCancelled, !editing else { return }
                    finish()
                }
            }
        )
        HStack(spacing: 8) {
            Image(systemName: "tortoise.fill")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            slider(binding)
                .labelsHidden()
                .accessibilityValue(Text(value))
            Image(systemName: "hare.fill")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private func slider(_ binding: Binding<Double>) -> some View {
        if #available(macOS 26, *) {
            Slider(value: binding, in: 0...1) {
                Text(title)
            } ticks: {
                SliderTickContentForEach(marks, id: \.self) { SliderTick($0) }
            } onEditingChanged: { changed($0) }
        } else {
            Slider(value: binding, in: 0...1) {
                Text(title)
            } onEditingChanged: { changed($0) }
        }
    }

    private func changed(_ began: Bool) {
        editing = began
        if !began {
            pending?.cancel()
            finish()
        }
    }

    private func finish() {
        guard let drag else { return }
        commit(drag)
        self.drag = nil
    }
}
