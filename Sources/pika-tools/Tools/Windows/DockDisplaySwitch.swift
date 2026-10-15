import CoreGraphics

/// The Dock's own `allow-display-switching` key: nil is a missing key, which the Dock reads as true.
enum DockDisplaySwitch {
    static func plan(on: Bool, current: Bool?, owned: Bool, before: Bool?) -> (value: Bool?, before: Bool?, restart: Bool) {
        let old = owned ? before : current
        let value = on ? false : old
        return (value, on ? old : nil, (value ?? true) != (current ?? true))
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
