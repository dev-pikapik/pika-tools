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
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { SettingsWindow.show() }
                    .keyboardShortcut(",")
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        LoginItem.shared.restore()
        defaults.set(true, forKey: "launchedBefore")
        ["double-space", "double-space-interval"].forEach(defaults.removeObject)

        Appearance.saved.apply()
        let permissions = Permissions.shared
        permissions.onChange = { ToolRegistry.shared.refresh() }
        ToolRegistry.shared.refresh()
        Updater.shared.start()
        KeepAwake.shared.restoreLidSleepIfNeeded()

        if !permissions.allGranted {
            permissions.request()
            SettingsWindow.show(.permissions)
        } else if CommandLine.arguments.contains("--settings") {
            SettingsWindow.show()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindow.show()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeepAwake.shared.set(.off)
    }
}
