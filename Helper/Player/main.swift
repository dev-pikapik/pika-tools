import AppKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var players: [PlayerController] = []

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = makeMenu()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.players.isEmpty { self.show(nil) }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { show(url) }
    }

    private func show(_ url: URL?) {
        if let url, let open = players.first(where: { $0.window?.representedURL?.standardizedFileURL == url.standardizedFileURL }) {
            open.window?.deminiaturize(nil)
            open.showWindow(nil)
            return
        }
        let player = players.first(where: \.isEmpty) ?? {
            let player = PlayerController()
            player.onClose = { [weak self] closed in self?.players.removeAll { $0 === closed } }
            players.append(player)
            return player
        }()
        player.showWindow(nil)
        if let url { player.load(url) }
    }

    @objc func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = PlayerFormats.extensions.compactMap { UTType(filenameExtension: $0) }
        guard panel.runModal() == .OK else { return }
        for url in panel.urls { show(url) }
    }

    private func makeMenu() -> NSMenu {
        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "pikapik Player"
        let main = NSMenu()
        func submenu(_ title: String, _ items: [NSMenuItem]) -> NSMenu {
            let menu = NSMenu(title: title)
            items.forEach(menu.addItem)
            let holder = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            holder.submenu = menu
            main.addItem(holder)
            return menu
        }
        func item(_ title: String, _ action: Selector?, _ key: String = "", _ modifiers: NSEvent.ModifierFlags = .command) -> NSMenuItem {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
            item.keyEquivalentModifierMask = modifiers
            return item
        }
        let others = item(String(localized: "Hide Others"), #selector(NSApplication.hideOtherApplications), "h", [.command, .option])
        _ = submenu(name, [
            item(String(localized: "About \(name)"), #selector(NSApplication.orderFrontStandardAboutPanel(_:))),
            .separator(),
            item(String(localized: "Hide \(name)"), #selector(NSApplication.hide), "h"),
            others,
            item(String(localized: "Show All"), #selector(NSApplication.unhideAllApplications)),
            .separator(),
            item(String(localized: "Quit \(name)"), #selector(NSApplication.terminate), "q"),
        ])
        _ = submenu(String(localized: "File"), [
            item(String(localized: "Open…"), #selector(openDocument), "o"),
            .separator(),
            item(String(localized: "Close"), #selector(NSWindow.performClose), "w"),
        ])
        _ = submenu(String(localized: "View"), [
            item(String(localized: "Enter Full Screen"), #selector(NSWindow.toggleFullScreen), "f", [.command, .control]),
        ])
        let arrow = { (key: Int) in String(Character(UnicodeScalar(key)!)) }
        _ = submenu(String(localized: "Playback"), [
            item(String(localized: "Play"), #selector(PlayerController.playPause), " ", []),
            .separator(),
            item(String(localized: "Back 5 Seconds"), #selector(PlayerController.skipBack), arrow(NSLeftArrowFunctionKey), []),
            item(String(localized: "Forward 5 Seconds"), #selector(PlayerController.skipForward), arrow(NSRightArrowFunctionKey), []),
            .separator(),
            item(String(localized: "Volume Up"), #selector(PlayerController.volumeUp), arrow(NSUpArrowFunctionKey), []),
            item(String(localized: "Volume Down"), #selector(PlayerController.volumeDown), arrow(NSDownArrowFunctionKey), []),
        ])
        NSApp.windowsMenu = submenu(String(localized: "Window"), [
            item(String(localized: "Minimize"), #selector(NSWindow.performMiniaturize), "m"),
            item(String(localized: "Zoom"), #selector(NSWindow.performZoom)),
        ])
        return main
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
