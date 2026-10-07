import Foundation

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
        case .windowOpen, .resize, .quickLook: .apps
        case .finderColumns, .finder: .finder
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

    static func changes(from old: [Self: Double], to new: [Self: Double], system: [Self: Double]) -> [(Self, Double?)] {
        allCases.compactMap { setting in
            if let value = new[setting] {
                if let current = system[setting], abs(current - value) < 0.0005 { return nil }
                return (setting, value)
            }
            return old[setting] != nil && system[setting] != nil ? (setting, nil) : nil
        }
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

    static func preset(_ speed: Double) -> [AnimationSetting: Double] {
        var values: [AnimationSetting: Double] = [:]
        for setting in AnimationSetting.allCases where setting.isSpeed {
            values[setting] = setting.kind == .flag
                ? (speed >= 1 ? 0 : 1)
                : AnimationSetting.round(setting.macOS * (1 - speed))
        }
        return values
    }

    static func speed(of values: [AnimationSetting: Double], stored: Double?) -> Double? {
        func matches(_ preset: [AnimationSetting: Double]) -> Bool {
            preset.allSatisfy { setting, value in abs((values[setting] ?? setting.macOS) - value) < 0.002 }
        }
        if matches(preset(0)) { return 0 }
        if let stored, matches(preset(stored)) { return stored }
        return nil
    }

    static func label(_ speed: Double?) -> AnimationLabel {
        guard let speed else { return .custom }
        if speed == 0 { return .macOS }
        if speed >= 1 { return .instant }
        return .faster(1 / (1 - speed))
    }
}
