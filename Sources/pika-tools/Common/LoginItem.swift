import ServiceManagement

@Observable
final class LoginItem {
    static let shared = LoginItem()

    private(set) var status = SMAppService.mainApp.status

    var isOn: Bool {
        get { status == .enabled }
        set { set(newValue) }
    }

    var needsApproval: Bool { status == .requiresApproval }

    private init() {}

    func set(_ on: Bool) {
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
