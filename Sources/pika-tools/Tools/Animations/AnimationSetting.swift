import Foundation
import Observation

enum AnimationSetting: String, CaseIterable {
    case dockDelay = "dock-delay", dockSpeed = "dock-speed", minimize, bounce
    case windowOpen = "window-open", resize, quickLook = "quick-look"
    case finderColumns = "finder-columns", finder

    enum Kind { case seconds, multiplier, flag, choice }
    enum Apply { case dock, apps, finder }

    static let effects = ["genie", "scale", "suck"]
    static let magnet = 0.04

    var domain: CFString {
        switch self {
        case .dockDelay, .dockSpeed, .minimize, .bounce: "com.apple.dock" as CFString
        case .finder: "com.apple.finder" as CFString
        case .windowOpen, .resize, .quickLook, .finderColumns: kCFPreferencesAnyApplication
        }
    }

    var key: String {
        switch self {
        case .dockDelay: "autohide-delay"
        case .dockSpeed: "autohide-time-modifier"
        case .minimize: "mineffect"
        case .bounce: "no-bouncing"
        case .windowOpen: "NSAutomaticWindowAnimationsEnabled"
        case .resize: "NSWindowResizeTime"
        case .quickLook: "QLPanelAnimationDuration"
        case .finderColumns: "NSBrowserColumnAnimationSpeedMultiplier"
        case .finder: "DisableAllAnimations"
        }
    }

    var kind: Kind {
        switch self {
        case .dockDelay, .dockSpeed, .resize, .quickLook: .seconds
        case .finderColumns: .multiplier
        case .bounce, .windowOpen, .finder: .flag
        case .minimize: .choice
        }
    }

    var apply: Apply {
        switch self {
        case .dockDelay, .dockSpeed, .minimize, .bounce: .dock
        case .windowOpen, .resize, .quickLook, .finderColumns: .apps
        case .finder: .finder
        }
    }

    var macOS: Double {
        switch self {
        case .dockDelay, .resize, .quickLook: 0.2
        case .dockSpeed: 0.5
        case .minimize: 0
        case .bounce, .windowOpen, .finder, .finderColumns: 1
        }
    }

    var upper: Double {
        switch self {
        case .resize, .quickLook: 0.6
        case .finderColumns: 3
        default: 1
        }
    }

    var step: Double { kind == .multiplier ? 0.25 : 0.05 }

    var isSpeed: Bool { self != .minimize && self != .bounce }

    var mark: Double { position(of: macOS) }

    func position(of value: Double) -> Double {
        min(max(1 - value / upper, 0), 1)
    }

    func value(at position: Double) -> Double {
        let position = min(max(position, 0), 1)
        if abs(position - mark) < Self.magnet { return macOS }
        return Self.round((upper * (1 - position) / step).rounded() * step)
    }

    func label(_ value: Double) -> AnimationLabel {
        if abs(value - macOS) < 0.0005 { return .macOS }
        switch kind {
        case .seconds: return value < 0.005 ? .instant : .seconds(value)
        case .multiplier: return value < 0.005 ? .instant : value < 1 ? .faster(1 / value) : .slower(value)
        case .flag, .choice: return .custom
        }
    }

    func plist(_ value: Double) -> CFPropertyList {
        switch self {
        case .dockDelay, .dockSpeed, .quickLook, .finderColumns: value as NSNumber
        case .resize: max(value, 0.001) as NSNumber
        case .bounce, .finder: (value == 0) as NSNumber
        case .windowOpen: (value != 0) as NSNumber
        case .minimize: Self.effects[min(max(Int(value), 0), Self.effects.count - 1)] as NSString
        }
    }

    func value(from plist: Any) -> Double? {
        switch kind {
        case .seconds, .multiplier:
            guard let number = (plist as? NSNumber)?.doubleValue else { return nil }
            return number < 0.005 ? 0 : Self.round(number)
        case .flag:
            guard let flag = (plist as? NSNumber)?.boolValue else { return nil }
            return (self == .windowOpen ? flag : !flag) ? 1 : 0
        case .choice:
            return (plist as? String).flatMap { Self.effects.firstIndex(of: $0) }.map(Double.init)
        }
    }

    func read() -> Double? {
        CFPreferencesAppSynchronize(domain)
        return CFPreferencesCopyAppValue(key as CFString, domain).flatMap { value(from: $0) }
    }

    func write(_ value: Double?) {
        CFPreferencesSetAppValue(key as CFString, value.map(plist), domain)
        CFPreferencesAppSynchronize(domain)
    }

    static func round(_ value: Double) -> Double {
        (value * 1000).rounded() / 1000
    }

    static func changes(from old: [Self: Double], to new: [Self: Double], system: [Self: Double], own: [Self: Double] = [:]) -> [(Self, Double?)] {
        allCases.compactMap { setting in
            guard new[setting] != nil || old[setting] != nil else { return nil }
            let target = new[setting] ?? own[setting]
            if let current = system[setting], let target { return abs(current - target) < 0.0005 ? nil : (setting, target) }
            return target == nil && system[setting] == nil ? nil : (setting, target)
        }
    }

    static func restartsDock(_ changes: [(Self, Double?)], autohide: Bool) -> Bool {
        changes.contains { $0.0.apply == .dock && (autohide || !$0.0.isSpeed) }
    }

    static func originals(_ own: [Self: Double], owned: [Self: Double], new: [Self: Double], system: [Self: Double]) -> [Self: Double] {
        new.keys.reduce(into: [:]) { result, setting in
            result[setting] = own[setting] ?? (owned[setting] == nil ? system[setting] : nil)
        }
    }

    static func set(_ new: [Self: Double], own: [Self: Double], ours: [Self: Double], system: [Self: Double], remember: (_ own: [Self: Double], _ ours: [Self: Double]) -> Void, willWrite: ([(Self, Double?)]) -> Void, write: (Self, Double?) -> Void) -> (own: [Self: Double], ours: [Self: Double], changes: [(Self, Double?)]) {
        let changes = Self.changes(from: ours, to: new, system: system, own: own)
        let originals = Self.originals(own, owned: ours, new: new, system: system)
        remember(own.merging(originals) { $1 }, ours.merging(new) { $1 })
        willWrite(changes)
        changes.forEach { write($0.0, $0.1) }
        remember(originals, new)
        return (originals, new, changes)
    }

    static func putBack(own: [Self: Double], ours: [Self: Double], system: [Self: Double], remember: (_ own: [Self: Double], _ ours: [Self: Double]) -> Void, write: (Self, Double?) -> Void) -> [(Self, Double?)] {
        let written = ours.filter { setting, value in system[setting].map { abs($0 - value) < 0.0005 } ?? false }
        let changes = Self.changes(from: written, to: [:], system: system, own: own)
        changes.forEach { write($0.0, $0.1) }
        remember([:], [:])
        return changes
    }
}

final class DockRestart {
    static let key = "animations-dock-pending"

    private let journal: () -> UserDefaults
    private let later: (DispatchWorkItem) -> Void
    private let kill: (Bool) -> Void
    private var work: DispatchWorkItem?

    init(journal: @escaping () -> UserDefaults, later: @escaping (DispatchWorkItem) -> Void, kill: @escaping (Bool) -> Void) {
        (self.journal, self.later, self.kill) = (journal, later, kill)
    }

    var isPending: Bool { journal().bool(forKey: Self.key) }

    func restart(for changes: [(AnimationSetting, Double?)], autohide: Bool) {
        if isPending || AnimationSetting.restartsDock(changes, autohide: autohide) { schedule() }
    }

    func schedule() {
        work?.cancel()
        journal().set(true, forKey: Self.key)
        let item = DispatchWorkItem { [self] in fire() }
        work = item
        later(item)
    }

    func handOver() {
        work?.cancel()
        work = nil
    }

    func now() {
        handOver()
        kill(true)
        Self.clear(journal())
    }

    static func clear(_ journal: UserDefaults) {
        journal.removeObject(forKey: key)
    }

    private func fire() {
        work = nil
        kill(false)
        Self.clear(journal())
    }
}

struct AnimationsHost {
    let me: RunningCopy
    let canAct: () -> Bool
    let peers: () -> [RunningCopy]
    let poweringOff: () -> Bool
    let journal: () -> UserDefaults
    let local: UserDefaults
    let read: (AnimationSetting) -> Double?
    let write: (AnimationSetting, Double?) -> Void
    let readAutohide: () -> Bool
    let writeAutohide: (Bool) -> Void
    let later: (DispatchWorkItem) -> Void
    let kill: (String, Bool) -> Void
    let exclusive: (() -> Void) -> Void
}

@Observable
class AnimationsEngine {
    private(set) var owned: [AnimationSetting: Double]
    private(set) var own: [AnimationSetting: Double]
    private(set) var ours: [AnimationSetting: Double]
    private(set) var system: [AnimationSetting: Double] = [:]
    private(set) var storedSpeed: Double?
    private(set) var autohide = false
    private(set) var appsPending = false
    private(set) var finderPending = false
    @ObservationIgnored private let host: AnimationsHost
    @ObservationIgnored private let dockRestart: DockRestart

    private static let speedKey = "animations-speed"
    private static let ownKey = "animations-own"
    private static let oursKey = "animations-ours"
    private static let autohideKey = "animations-autohide-original"
    private static let wantedAutohideKey = "animations-autohide-wanted"
    private static let leavingPrefix = "animations-leaving-"

    init(_ host: AnimationsHost) {
        self.host = host
        dockRestart = DockRestart(journal: host.journal, later: host.later, kill: { host.kill("Dock", $0) })
        owned = Self.saved(host.local)
        own = Self.originals(host.journal())
        ours = Self.written(host.journal(), host.local)
        storedSpeed = host.local.object(forKey: Self.speedKey) as? Double
        Self.clearLeaving(host)
        reload()
    }

    var baseline: [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.map { ($0, baseline($0)) })
    }

    func baseline(_ setting: AnimationSetting) -> Double {
        (ours[setting] == nil ? system[setting] : own[setting]) ?? setting.macOS
    }

    func reload() {
        system = Self.snapshot(host)
        autohide = host.readAutohide()
        own = Self.originals(host.journal())
        ours = Self.written(host.journal(), host.local)
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
        guard host.canAct() else { return }
        restartDock()
        OriginalValue.set(Self.autohideKey, intent: Self.wantedAutohideKey, journal: host.journal(), local: host.local, current: host.readAutohide(), to: on, write: host.writeAutohide)
        autohide = on
    }

    func restartDock() {
        dockRestart.schedule()
    }

    func restartFinder() {
        finderPending = false
        host.kill("Finder", false)
    }

    func reset() {
        storedSpeed = nil
        apply([:])
    }

    func refresh() {
        reload()
        guard host.canAct() else { return leave() }
        apply(owned)
        resumeAutohide()
    }

    func willQuit() {
        host.journal().set(host.me.launched, forKey: Self.leavingKey(host.me.pid))
        guard !host.canAct(), staying().isEmpty else { return }
        putBack()
    }

    func load() {
        storedSpeed = host.local.object(forKey: Self.speedKey) as? Double
        reload()
        apply(Self.saved(host.local))
    }

    static func uninstall(_ host: AnimationsHost) {
        guard putBack(host) else { return }
        host.kill("Dock", true)
        DockRestart.clear(host.journal())
    }

    private func leave() {
        if MainCopyChoice.takesOver(staying(), poweringOff: host.poweringOff()) { dockRestart.handOver() } else { putBack() }
    }

    private func staying() -> [RunningCopy] {
        let journal = host.journal()
        return host.peers().filter { !Self.isLeaving($0, journal) }
    }

    private func resumeAutohide() {
        let journal = host.journal()
        switch OriginalValue.resume(OriginalValue.load(Self.wantedAutohideKey, journal: host.local), journal: OriginalValue.load(Self.autohideKey, journal: journal), current: autohide) {
        case .write(let value): setAutohide(value)
        case .forget:
            OriginalValue.save(nil, Self.wantedAutohideKey, journal: host.local)
            OriginalValue.save(nil, Self.autohideKey, journal: journal)
        case .keep: break
        }
    }

    private func putBack() {
        let dock = Self.putBack(host)
        reload()
        if dock { dockRestart.now() }
    }

    private static func putBack(_ host: AnimationsHost) -> Bool {
        var dock = false
        host.exclusive {
            let journal = host.journal()
            let autohide = putBackAutohide(host)
            let changes = AnimationSetting.putBack(own: originals(journal), ours: written(journal, host.local), system: snapshot(host), remember: { remember($0, $1, journal) }, write: host.write)
            clearLeaving(host)
            dock = autohide || changes.contains { $0.0.apply == .dock }
        }
        return dock
    }

    private func apply(_ new: [AnimationSetting: Double]) {
        guard host.canAct() else {
            owned = new
            return remember(owned: new)
        }
        remember(owned: new)
        let applied = AnimationSetting.set(new, own: own, ours: ours, system: system, remember: remember(own:ours:), willWrite: { [self] in dockRestart.restart(for: $0, autohide: host.readAutohide()) }, write: host.write)
        (own, ours, owned) = (applied.own, applied.ours, new)
        let changes = applied.changes
        guard !changes.isEmpty else { return }
        reload()
        if changes.contains(where: { $0.0.apply == .apps }) { appsPending = true }
        if changes.contains(where: { $0.0.apply != .dock }) { finderPending = true }
    }

    private func remember(own: [AnimationSetting: Double], ours: [AnimationSetting: Double]) {
        Self.remember(own, ours, host.journal())
    }

    private func remember(owned: [AnimationSetting: Double]) {
        let defaults = host.local
        for setting in AnimationSetting.allCases where defaults.object(forKey: Self.key(setting)) as? Double != owned[setting] {
            defaults.set(owned[setting], forKey: Self.key(setting))
        }
        if defaults.object(forKey: Self.speedKey) as? Double != storedSpeed {
            defaults.set(storedSpeed, forKey: Self.speedKey)
        }
    }

    private static func remember(_ own: [AnimationSetting: Double], _ ours: [AnimationSetting: Double], _ journal: UserDefaults) {
        store(own.isEmpty ? nil : own, ownKey, journal)
        store(ours, oursKey, journal)
    }

    private static func snapshot(_ host: AnimationsHost) -> [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.compactMap { setting in host.read(setting).map { (setting, $0) } })
    }

    private static func putBackAutohide(_ host: AnimationsHost) -> Bool {
        let journal = host.journal()
        let entry = OriginalValue.load(autohideKey, journal: journal)
        let value = OriginalValue.putBack(entry, current: host.readAutohide())
        if let value { host.writeAutohide(value) } else if entry != nil { OriginalValue.save(nil, wantedAutohideKey, journal: host.local) }
        OriginalValue.save(nil, autohideKey, journal: journal)
        return value != nil
    }

    private static func leavingKey(_ pid: Int32) -> String {
        leavingPrefix + String(pid)
    }

    private static func isLeaving(_ copy: RunningCopy, _ journal: UserDefaults) -> Bool {
        (journal.object(forKey: leavingKey(copy.pid)) as? Date).map { abs($0.timeIntervalSince(copy.launched)) < 1 } ?? false
    }

    private static func clearLeaving(_ host: AnimationsHost) {
        let journal = host.journal()
        let kept = Set((host.peers() + [host.me]).filter { isLeaving($0, journal) }.map { leavingKey($0.pid) })
        journal.dictionaryRepresentation().keys.filter { $0.hasPrefix(leavingPrefix) && !kept.contains($0) }.forEach(journal.removeObject(forKey:))
    }

    private static func key(_ setting: AnimationSetting) -> String {
        "animations-\(setting.rawValue)"
    }

    private static func saved(_ local: UserDefaults) -> [AnimationSetting: Double] {
        Dictionary(uniqueKeysWithValues: AnimationSetting.allCases.compactMap { setting in
            (local.object(forKey: key(setting)) as? Double).map { (setting, $0) }
        })
    }

    private static func journaled(_ key: String, _ journal: UserDefaults) -> [AnimationSetting: Double]? {
        (journal.dictionary(forKey: key) as? [String: Double]).map { saved in
            Dictionary(uniqueKeysWithValues: saved.compactMap { key, value in AnimationSetting(rawValue: key).map { ($0, value) } })
        }
    }

    private static func originals(_ journal: UserDefaults) -> [AnimationSetting: Double] {
        journaled(ownKey, journal) ?? [:]
    }

    private static func written(_ journal: UserDefaults, _ local: UserDefaults) -> [AnimationSetting: Double] {
        journaled(oursKey, journal) ?? saved(local)
    }

    private static func store(_ values: [AnimationSetting: Double]?, _ key: String, _ journal: UserDefaults) {
        let raw = values.map { Dictionary(uniqueKeysWithValues: $0.map { ($0.key.rawValue, $0.value) }) }
        if journal.dictionary(forKey: key) as? [String: Double] != raw { journal.set(raw, forKey: key) }
    }
}

enum AnimationLabel: Equatable {
    case macOS, instant, custom
    case seconds(Double), faster(Double), slower(Double)
}

enum AnimationSpeed {
    static let presets = [0, 0.5, 1.0]

    static func snapped(_ position: Double) -> Double {
        let position = min(max(position, 0), 1)
        if let preset = presets.first(where: { abs($0 - position) < AnimationSetting.magnet }) { return preset }
        return AnimationSetting.round((position / 0.05).rounded() * 0.05)
    }

    static func preset(_ speed: Double, baseline: [AnimationSetting: Double] = [:]) -> [AnimationSetting: Double] {
        var values: [AnimationSetting: Double] = [:]
        for setting in AnimationSetting.allCases where setting.isSpeed {
            let value = setting.kind == .flag
                ? (speed >= 1 ? 0 : 1)
                : AnimationSetting.round(setting.macOS * (1 - speed))
            values[setting] = speed > 0 ? min(value, baseline[setting] ?? setting.macOS) : value
        }
        return values
    }

    static func speed(of values: [AnimationSetting: Double], stored: Double?, baseline: [AnimationSetting: Double] = [:]) -> Double? {
        func matches(_ preset: [AnimationSetting: Double]) -> Bool {
            preset.allSatisfy { setting, value in abs((values[setting] ?? setting.macOS) - value) < 0.002 }
        }
        if matches(preset(0)) { return 0 }
        if let stored, matches(preset(stored, baseline: baseline)) { return stored }
        return nil
    }

    static func label(_ speed: Double?) -> AnimationLabel {
        guard let speed else { return .custom }
        if speed == 0 { return .macOS }
        if speed >= 1 { return .instant }
        return .faster(1 / (1 - speed))
    }
}
