import ServiceManagement

@Observable
final class LoginItem {
    static let shared = LoginItem()
    private static let key = "open-at-login"

    private(set) var status = SMAppService.mainApp.status

    var isOn: Bool {
        get { status == .enabled }
        set { set(newValue) }
    }

    var needsApproval: Bool { status == .requiresApproval }

    private init() {}

    func set(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: Self.key)
        apply(on)
    }

    func restore(moved: Bool = false) {
        let defaults = UserDefaults.standard
        let wanted = defaults.object(forKey: Self.key) as? Bool ?? (!defaults.bool(forKey: "launchedBefore") || status == .enabled)
        defaults.set(wanted, forKey: Self.key)
        if moved, wanted, status == .enabled { try? SMAppService.mainApp.unregister() }
        apply(wanted)
    }

    func apply(_ on: Bool) {
        if on {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
        refresh()
    }

    func refresh() {
        status = SMAppService.mainApp.status
    }
}
