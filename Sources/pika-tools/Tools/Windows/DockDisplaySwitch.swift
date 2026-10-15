import CoreGraphics
import Foundation

/// The Dock's own `allow-display-switching` key: nil is a missing key, which the Dock reads as true.
enum DockDisplaySwitch {
    static let ownedKey = "dock-display-owned", beforeKey = "dock-display-before"

    static func plan(on: Bool, current: Bool?, owned: Bool, before: Bool?) -> (value: Bool?, before: Bool?, restart: Bool) {
        let old = owned ? before : current
        let value = on ? false : (owned && current != false ? current : old)
        return (value, on ? old : nil, (value ?? true) != (current ?? true))
    }

    static func apply(_ on: Bool, current: Bool?, write: (Bool?) -> Void) -> Bool {
        let defaults = UserDefaults.standard
        let result = plan(on: on, current: current, owned: defaults.bool(forKey: ownedKey), before: defaults.object(forKey: beforeKey) as? Bool)
        if on {
            defaults.set(true, forKey: ownedKey)
            defaults.set(result.before, forKey: beforeKey)
        }
        if result.value != current { write(result.value) }
        if !on {
            defaults.set(false, forKey: ownedKey)
            defaults.removeObject(forKey: beforeKey)
        }
        return result.restart
    }
}

/// Display origins by display UUID: the main display always sits at (0, 0), and the others keep their place relative to it.
enum MainDisplay {
    static func moved(_ origins: [String: CGPoint], to main: String) -> [String: CGPoint]? {
        guard let anchor = origins[main], anchor != .zero else { return nil }
        return origins.mapValues { CGPoint(x: $0.x - anchor.x, y: $0.y - anchor.y) }
    }

    static func remembered(_ saved: [String: CGPoint], now: [String: CGPoint]) -> [String: CGPoint] {
        Set(saved.keys) == Set(now.keys) ? saved : now
    }

    static func restored(_ saved: [String: CGPoint], now: [String: CGPoint]) -> [String: CGPoint]? {
        Set(saved.keys) == Set(now.keys) && saved != now ? saved : nil
    }
}
