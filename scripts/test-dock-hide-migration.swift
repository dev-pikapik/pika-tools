import Foundation

@main
struct TestDockHideMigration {
    static func stored(_ switchOn: Bool?, _ action: String?, then enable: Bool = false) -> String? {
        let name = "test-dock-hide-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        if let switchOn { defaults.set(switchOn, forKey: "dock-hide") }
        if let action { defaults.set(action, forKey: "dock-hide-action") }
        DockHideMigration.run(defaults, switchKey: "dock-hide", actionKey: "dock-hide-action")
        if enable { defaults.set(true, forKey: "dock-hide") }
        DockHideMigration.run(defaults, switchKey: "dock-hide", actionKey: "dock-hide-action")
        return defaults.string(forKey: "dock-hide-action")
    }

    static func main() {
        precondition(stored(true, nil) == "hide")
        print("a switch that was already on before the choice existed keeps hiding: ok")

        precondition(stored(nil, nil) == "minimize")
        precondition(stored(false, nil) == "minimize")
        print("a switch that was off starts on minimize: ok")

        precondition(stored(nil, nil, then: true) == "minimize")
        precondition(stored(false, nil, then: true) == "minimize")
        print("turning the switch on later does not turn minimize into hide: ok")

        precondition(stored(true, "minimize") == "minimize")
        precondition(stored(false, "hide") == "hide")
        print("a choice the owner made is never overwritten: ok")
    }
}
