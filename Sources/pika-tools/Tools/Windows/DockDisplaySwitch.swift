/// The Dock's own `allow-display-switching` key: nil is a missing key, which the Dock reads as true.
enum DockDisplaySwitch {
    static func plan(on: Bool, current: Bool?, owned: Bool, before: Bool?) -> (value: Bool?, before: Bool?, restart: Bool) {
        let old = owned ? before : current
        let value = on ? false : old
        return (value, on ? old : nil, (value ?? true) != (current ?? true))
    }
}
