import SwiftUI

struct PikaToolsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    private let registry = ToolRegistry.shared
    private let background = Background.shared
    @AppStorage(Background.key) private var keepRunning = true
    private static let logo = menuBarLogo(opacity: 1)
    private static let logoOff = menuBarLogo(opacity: 0.45)

    private static func menuBarLogo(opacity: CGFloat) -> NSImage {
        let svg = Bundle.main.url(forResource: "pikapik", withExtension: "svg").flatMap { NSImage(contentsOf: $0) }
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            svg?.draw(in: rect.insetBy(dx: -4.2, dy: -4.2), from: .zero, operation: .sourceOver, fraction: opacity)
            return true
        }
        image.isTemplate = true
        return image
    }

    var body: some Scene {
        MenuBarExtra(isInserted: Binding(get: { background.iconShown }, set: { background.iconShown = $0 })) {
            MenuView(registry: registry)
        } label: {
            Group {
                if let symbol = registry.status.symbol {
                    Image(systemName: symbol)
                } else {
                    Image(nsImage: registry.status == .off ? Self.logoOff : Self.logo)
                }
            }
            .accessibilityLabel("pikapik: \(registry.status.title)")
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { SettingsWindow.show() }
                    .keyboardShortcut(",")
            }
            CommandGroup(after: .appTermination) {
                if keepRunning {
                    Button("Quit Completely") { Background.quitCompletely() }
                        .keyboardShortcut("q", modifiers: [.command, .option])
                }
            }
            CommandGroup(replacing: .help) {}
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var signals: [DispatchSourceSignal] = []

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURL(_:reply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    @objc private func handleURL(_ event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        guard let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
              let url = URL(string: string)
        else { return }
        NewFile.handle(url)
        Compress.handle(url)
        KeepAwake.shared.handle(url)
        SpeedTest.shared.handle(url)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        let path = Bundle.main.bundlePath
        let moved = Updater.isNewPlace(path, last: defaults.string(forKey: "app-path"), launchedBefore: defaults.bool(forKey: "launchedBefore"))
        defaults.set(path, forKey: "app-path")
        LoginItem.shared.restore(moved: moved)
        if moved { FinderExtension.register() }
        FinderRestart.shared.check()
        FinderExtension.refreshFinderRecord()
        defaults.set(true, forKey: "launchedBefore")
        ["double-space", "double-space-interval"].forEach(defaults.removeObject)
        for id in ["convert", "finder-cut", "finder-delete", "finder-open", "game-mode", "home-end", "speed-test", "window-zoom"] where !defaults.bool(forKey: "quick-hidden-\(id)") {
            if let hidden = defaults.string(forKey: "quick-hidden"), id != "convert" || hidden.split(separator: ",").contains("compress") {
                defaults.set(hidden + ",\(id)", forKey: "quick-hidden")
            }
            defaults.set(true, forKey: "quick-hidden-\(id)")
        }

        Appearance.saved.apply()
        let permissions = Permissions.shared
        permissions.onChange = { ToolRegistry.shared.refresh() }
        ToolRegistry.shared.refresh()
        SettingsSync.shared.refresh()
        Updater.shared.start()
        StatusMenu.shared.start()
        KeepAwake.shared.resume()
        KeepAwake.shared.restoreLidSleepIfNeeded()
        signals = [SIGTERM, SIGINT, SIGHUP].map { number in
            signal(number, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: number, queue: .main)
            source.setEventHandler { Background.quit() }
            source.resume()
            return source
        }

        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willPowerOffNotification, object: nil, queue: .main) { _ in
            Background.shared.quitting = true
        }

        if !permissions.allGranted {
            permissions.request()
            SettingsWindow.show(.permissions)
        } else if CommandLine.arguments.contains("--settings") {
            SettingsWindow.show()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Background.shared.iconShown = true
        SettingsWindow.show()
        return false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let background = Background.shared
        if background.quitting || Background.isOutsideQuit { return .terminateNow }
        guard Background.isOn, !NSEvent.modifierFlags.contains(.option) else {
            KeepAwake.shared.set(.off)
            return .terminateNow
        }
        background.hide()
        return .terminateCancel
    }

    func applicationWillTerminate(_ notification: Notification) {
        KeepAwake.shared.handOff()
        SpeedTest.shared.cancel()
        ToolRegistry.shared.tools.forEach { ($0 as? PointerTool)?.restore() }
        GameModeTool.shared.leave()
    }
}
