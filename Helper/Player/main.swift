import AppKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var players: [PlayerController] = []
    private let displays = NSMenu()
    private let displaysItem = NSMenuItem()
    private var audioMenu: NSMenu?
    private var subtitleMenu: NSMenu?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.mainMenu = makeMenu()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.players.isEmpty { self.show(nil) }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        players.forEach { $0.remember() }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu === audioMenu || menu === subtitleMenu {
            menu.items.filter { $0.tag == PlayerController.trackItemTag }.forEach(menu.removeItem)
            let player = (NSApp.keyWindow ?? NSApp.mainWindow)?.windowController as? PlayerController
            let items = menu === audioMenu ? player?.audioItems() : player?.subtitleItems()
            for (index, item) in (items ?? []).enumerated() { menu.insertItem(item, at: index) }
            return
        }
        displaysItem.isHidden = NSScreen.screens.count < 2
        displays.removeAllItems()
        for screen in NSScreen.screens {
            let item = NSMenuItem(title: screen.localizedName, action: #selector(PlayerController.moveToScreen(_:)), keyEquivalent: "")
            item.representedObject = screen
            displays.addItem(item)
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
        panel.canChooseDirectories = true
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
        func command(_ title: String, _ action: PlayerAction, _ selector: Selector = #selector(PlayerController.menuAction(_:))) -> NSMenuItem {
            let binding = PlayerAction.bindings.first { $0.action == action }
            let entry = item(title, selector, binding?.key ?? "", binding?.modifiers ?? [])
            entry.representedObject = action
            return entry
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
            command(String(localized: "Save Frame…"), .snapshot),
            .separator(),
            item(String(localized: "Close"), #selector(NSWindow.performClose), "w"),
        ])
        _ = submenu(String(localized: "View"), [
            command(String(localized: "Enter Full Screen"), .fullScreen, #selector(NSWindow.toggleFullScreen)),
        ])
        _ = submenu(String(localized: "Playback"), [
            command(String(localized: "Play"), .playPause),
            command(String(localized: "Next in Folder"), .next),
            command(String(localized: "Previous in Folder"), .previous),
            .separator(),
            command(String(localized: "Back 5 Seconds"), .back),
            command(String(localized: "Forward 5 Seconds"), .forward),
            command(String(localized: "Back 5 Seconds"), .skipBack),
            command(String(localized: "Forward 5 Seconds"), .skipForward),
            command(String(localized: "Back 10 Seconds"), .longBack),
            command(String(localized: "Forward 10 Seconds"), .longForward),
            .separator(),
            command(String(localized: "Previous Frame"), .frameBack),
            command(String(localized: "Next Frame"), .frameForward),
            .separator(),
            command(String(localized: "Go to Beginning"), .start),
            command(String(localized: "Go to End"), .end),
            command(String(localized: "Start Over"), .startOver),
            .separator(),
            command(String(localized: "Volume Up"), .louder),
            command(String(localized: "Volume Down"), .quieter),
            command(String(localized: "Mute"), .mute),
        ])
        let speeds = PlayerSpeed.all.map { speed in
            let entry = item("\(speed.formatted())×", #selector(PlayerController.chooseSpeed(_:)))
            entry.representedObject = speed
            return entry
        }
        _ = submenu(String(localized: "Speed"), speeds + [
            .separator(),
            command(String(localized: "Slower"), .slower),
            command(String(localized: "Faster"), .faster),
            command(String(localized: "Normal Speed"), .normalSpeed),
        ])
        audioMenu = submenu(String(localized: "Audio"), [
            command(String(localized: "Next Audio Track"), .nextAudio),
        ])
        subtitleMenu = submenu(String(localized: "Subtitles"), [
            .separator(),
            command(String(localized: "Next Subtitle Track"), .nextSubtitle),
            item(String(localized: "Add Subtitle File…"), #selector(PlayerController.addSubtitleFile(_:))),
            .separator(),
            command(String(localized: "Subtitles Earlier"), .subtitleEarlier),
            command(String(localized: "Subtitles Later"), .subtitleLater),
            command(String(localized: "Larger Subtitles"), .subtitleLarger),
            command(String(localized: "Smaller Subtitles"), .subtitleSmaller),
        ])
        audioMenu?.delegate = self
        subtitleMenu?.delegate = self
        displaysItem.title = String(localized: "Move to Display")
        displaysItem.submenu = displays
        let windowMenu = submenu(String(localized: "Window"), [
            item(String(localized: "Minimize"), #selector(NSWindow.performMiniaturize), "m"),
            item(String(localized: "Zoom"), #selector(NSWindow.performZoom)),
            .separator(),
            command(String(localized: "Float on Top"), .floatOnTop),
            displaysItem,
        ])
        windowMenu.delegate = self
        NSApp.windowsMenu = windowMenu
        return main
    }
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
