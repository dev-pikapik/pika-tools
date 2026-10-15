import Foundation

enum DockHideMigration {
    static func run(_ defaults: UserDefaults, switchKey: String, actionKey: String) {
        guard defaults.object(forKey: actionKey) == nil else { return }
        defaults.set(defaults.bool(forKey: switchKey) ? "hide" : "minimize", forKey: actionKey)
    }
}
