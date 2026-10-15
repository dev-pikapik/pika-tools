import AppKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var players: [PlayerController] = []
    private var pictures: [ImageController] = []
    private var videoOnly: [NSMenuItem] = []
    private var pictureOnly: [NSMenuItem] = []
    private let displays = NSMenu()
    private let displaysItem = NSMenuItem()

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
        NSApp.mainMenu = makeMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(keyWindowChanged), name: NSWindow.didBecomeKeyNotification, object: nil)
    }

    @objc private func keyWindowChanged(_ notification: Notification) {
        let picture = (notification.object as? NSWindow)?.windowController is ImageController
        videoOnly.forEach { $0.isHidden = picture }
        pictureOnly.forEach { $0.isHidden = !picture }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.players.isEmpty && self.pictures.isEmpty { self.show(nil) }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        players.forEach { $0.remember() }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
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
        open(urls)
    }

    private func open(_ urls: [URL]) {
        let (images, rest) = ImageList.split(urls)
        if !images.isEmpty { showPictures(images) }
        for url in rest { show(url) }
    }

    private func showPictures(_ urls: [URL]) {
        if urls.count == 1, pictures.contains(where: { $0.focus(urls[0]) }) { return }
        let viewer = ImageController()
        viewer.onOpen = { [weak self] urls in self?.open(urls) }
        viewer.onClose = { [weak self] closed in self?.pictures.removeAll { $0 === closed } }
        pictures.append(viewer)
        viewer.show(urls)
        viewer.showWindow(nil)
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
        panel.allowedContentTypes = PlayerFormats.extensions.compactMap { UTType(filenameExtension: $0) } + ImageFormats.types + [.folder]
        guard panel.runModal() == .OK else { return }
        open(panel.urls)
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
        func picture(_ title: String, _ action: ImageAction) -> NSMenuItem {
            let binding = ImageAction.bindings.first { $0.action == action }
            let entry = item(title, #selector(ImageController.imageAction(_:)), binding?.key ?? "", binding?.modifiers ?? [])
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
        let zoomItems = [
            .separator(),
            picture(String(localized: "Zoom In"), .zoomIn),
            picture(String(localized: "Zoom Out"), .zoomOut),
            picture(String(localized: "Actual Size"), .actualSize),
            picture(String(localized: "Fit to Window"), .fit),
            .separator(),
            picture(String(localized: "Rotate Left"), .rotateLeft),
            picture(String(localized: "Rotate Right"), .rotateRight),
        ]
        _ = submenu(String(localized: "View"), [
            command(String(localized: "Enter Full Screen"), .fullScreen, #selector(NSWindow.toggleFullScreen)),
        ] + zoomItems)
        _ = submenu(String(localized: "Go"), [
            picture(String(localized: "Previous Image"), .previous),
            picture(String(localized: "Next Image"), .next),
            .separator(),
            picture(String(localized: "Start Slideshow"), .slideshow),
        ])
        pictureOnly = zoomItems + main.items.suffix(1)
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
        videoOnly = Array(main.items.suffix(1))
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
        videoOnly += main.items.suffix(1)
        pictureOnly.forEach { $0.isHidden = true }
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
