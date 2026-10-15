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
    var needs: [Permission] { [] }
    var isDefault: Bool { owned.isEmpty }

    var isEnabled: Bool {
        get { !owned.isEmpty }
        set { if !newValue { reset() } }
    }

    private(set) var owned: [AnimationSetting: Double]
    private(set) var own: [AnimationSetting: Double]
    private(set) var ours: [AnimationSetting: Double]
    private(set) var system: [AnimationSetting: Double] = [:]
    private(set) var storedSpeed: Double?
    private(set) var autohide = false
    private(set) var appsPending = false
    private(set) var finderPending = false
    @ObservationIgnored private var dockRestart: DispatchWorkItem?

    private static let dock = "com.apple.dock" as CFString
    private static let speedKey = "animations-speed"
    private static let ownKey = "animations-own"
    private static let oursKey = "animations-ours"
    private static let autohideKey = "animations-autohide-original"
    private static let wantedAutohideKey = "animations-autohide-wanted"
    private static let dockKey = "animations-dock-pending"

    private init() {
        owned = Self.saved()
        own = Self.originals()
        ours = Self.written()
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
        system[setting] ?? setting.macOS
    }

    func baseline(_ setting: AnimationSetting) -> Double {
        (ours[setting] == nil ? system[setting] : own[setting]) ?? setting.macOS
    }

    func reload() {
        system = Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.compactMap { setting in setting.read().map { (setting, $0) } })
        autohide = Self.readAutohide()
        own = Self.originals()
        ours = Self.written()
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
        guard MainCopy.canAct else { return }
        OriginalValue.set(Self.autohideKey, intent: Self.wantedAutohideKey, journal: MainCopy.journal, current: Self.readAutohide(), to: on, write: Self.writeAutohide)
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
        guard MainCopy.canAct else {
            if !MainCopy.takesOver { putBack() } else { handOverDock() }
            return
        }
        apply(owned)
        resumeAutohide()
    }

    private func resumeAutohide() {
        let journal = MainCopy.journal
        switch OriginalValue.resume(OriginalValue.load(Self.wantedAutohideKey), journal: OriginalValue.load(Self.autohideKey, journal: journal), current: autohide) {
        case .write(let value): setAutohide(value)
        case .forget:
            OriginalValue.save(nil, Self.wantedAutohideKey)
            OriginalValue.save(nil, Self.autohideKey, journal: journal)
        case .keep: break
        }
    }

    private func handOverDock() {
        guard let work = dockRestart else { return }
        work.cancel()
        dockRestart = nil
        MainCopy.journal.set(true, forKey: Self.dockKey)
    }

    private func putBack() {
        let written = ours.filter { setting, value in system[setting].map { abs($0 - value) < 0.0005 } ?? false }
        let changes = AnimationSetting.changes(from: written, to: [:], system: system, own: own)
        let dock = Self.putBackAutohide()
        changes.forEach { $0.0.write($0.1) }
        remember(own: [:], ours: [:])
        reload()
        guard dock || changes.contains(where: { $0.0.apply == .dock }) else { return }
        dockRestart?.cancel()
        Self.killall("Dock", wait: true)
    }

    func load() {
        storedSpeed = UserDefaults.standard.object(forKey: Self.speedKey) as? Double
        reload()
        apply(Self.saved())
    }

    static func uninstall() {
        let own = originals()
        let settings = written().filter { setting, value in setting.read().map { abs($0 - value) < 0.0005 } ?? false }.keys
        settings.forEach { $0.write(own[$0]) }
        let journal = MainCopy.journal
        store(nil, ownKey, journal)
        store([:], oursKey, journal)
        if putBackAutohide() || settings.contains(where: { $0.apply == .dock }) { killall("Dock", wait: true) }
    }

    private static func putBackAutohide() -> Bool {
        let journal = MainCopy.journal
        let entry = OriginalValue.load(autohideKey, journal: journal)
        let value = OriginalValue.putBack(entry, current: readAutohide())
        if let value { writeAutohide(value) } else if entry != nil { OriginalValue.save(nil, wantedAutohideKey) }
        OriginalValue.save(nil, autohideKey, journal: journal)
        return value != nil
    }

    private static func readAutohide() -> Bool {
        CFPreferencesAppSynchronize(dock)
        return CFPreferencesCopyAppValue("autohide" as CFString, dock) as? Bool ?? false
    }

    private static func writeAutohide(_ on: Bool) {
        CFPreferencesSetAppValue("autohide" as CFString, on as CFBoolean, dock)
        CFPreferencesAppSynchronize(dock)
    }

    private func apply(_ new: [AnimationSetting: Double]) {
        guard MainCopy.canAct else {
            owned = new
            return remember(owned: new)
        }
        let changes = AnimationSetting.changes(from: ours, to: new, system: system, own: own)
        let originals = AnimationSetting.originals(own, owned: ours, new: new, system: system)
        remember(own: own.merging(originals) { $1 }, ours: ours.merging(new) { $1 })
        remember(owned: new)
        own = originals
        ours = new
        owned = new
        changes.forEach { $0.0.write($0.1) }
        remember(own: own, ours: ours)
        let waiting = MainCopy.journal.bool(forKey: Self.dockKey)
        guard !changes.isEmpty || waiting else { return }
        reload()
        if waiting || AnimationSetting.restartsDock(changes, autohide: autohide) { restartDock() }
        if waiting { MainCopy.journal.removeObject(forKey: Self.dockKey) }
        if changes.contains(where: { $0.0.apply == .apps }) { appsPending = true }
        if changes.contains(where: { $0.0.apply != .dock }) { finderPending = true }
    }

    private func remember(own: [AnimationSetting: Double], ours: [AnimationSetting: Double]) {
        let journal = MainCopy.journal
        Self.store(own.isEmpty ? nil : own, Self.ownKey, journal)
        Self.store(ours, Self.oursKey, journal)
    }

    private func remember(owned: [AnimationSetting: Double]) {
        let defaults = UserDefaults.standard
        for setting in AnimationSetting.allCases where defaults.object(forKey: Self.key(setting)) as? Double != owned[setting] {
            defaults.set(owned[setting], forKey: Self.key(setting))
        }
        if defaults.object(forKey: Self.speedKey) as? Double != storedSpeed {
            defaults.set(storedSpeed, forKey: Self.speedKey)
        }
    }

    func restartDock() {
        dockRestart?.cancel()
        let work = DispatchWorkItem { [self] in
            dockRestart = nil
            Self.killall("Dock")
        }
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

    private static func journaled(_ key: String) -> [AnimationSetting: Double]? {
        (MainCopy.journal.dictionary(forKey: key) as? [String: Double]).map { saved in
            Dictionary(uniqueKeysWithValues: saved.compactMap { key, value in AnimationSetting(rawValue: key).map { ($0, value) } })
        }
    }

    private static func originals() -> [AnimationSetting: Double] {
        journaled(ownKey) ?? [:]
    }

    private static func written() -> [AnimationSetting: Double] {
        journaled(oursKey) ?? saved()
    }

    private static func store(_ values: [AnimationSetting: Double]?, _ key: String, _ journal: UserDefaults) {
        let raw = values.map { Dictionary(uniqueKeysWithValues: $0.map { ($0.key.rawValue, $0.value) }) }
        if journal.dictionary(forKey: key) as? [String: Double] != raw { journal.set(raw, forKey: key) }
    }

    static func killall(_ name: String, wait: Bool = false) {
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
                SystemSettingsRow(title: String(localized: "Even calmer: Reduce Motion in Accessibility"), url: SettingsGuide.reduceMotionLink, guide: .reduceMotion)
            }
            RestoreDefaultsSection(
                message: tool.own.isEmpty
                    ? String(localized: "All animations will be as in macOS again.")
                    : String(localized: "Animations will be as they were before pikapik."),
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
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in tool.reload() }
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
                    Button("Restart Finder") { FinderRestart.shared.restart() }
                        .help(Text("Finder closes its windows and opens again. Wait until files finish copying."))
                }
            }
            .noticeBar()
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
        case .dockSpeed: DockSpeedArt(delay: tool.value(.dockDelay), speed: tool.value(.dockSpeed))
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
