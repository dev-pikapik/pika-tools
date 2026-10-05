import SwiftUI

struct PikaToolsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    private let registry = ToolRegistry.shared

    var body: some Scene {
        MenuBarExtra {
            MenuView(registry: registry)
        } label: {
            Image(systemName: registry.status.icon)
                .accessibilityLabel("pika-tools: \(registry.status.title)")
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "launchedBefore") {
            defaults.set(true, forKey: "launchedBefore")
            LoginItem.shared.set(true)
        }

        let permissions = Permissions.shared
        permissions.onChange = { ToolRegistry.shared.refresh() }
        ToolRegistry.shared.refresh()
        Updater.shared.start()

        if !permissions.allGranted {
            permissions.request()
            PermissionsWindow.show()
        }
    }
}
