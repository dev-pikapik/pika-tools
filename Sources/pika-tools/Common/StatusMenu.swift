import AppKit

@MainActor final class StatusMenu: NSObject {
    static let shared = StatusMenu()

    private var monitor: Any?

    func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDown, .leftMouseDown]) { [weak self] event in
            guard let self, let window = event.window,
                  NSStringFromClass(type(of: window)).contains("StatusBarWindow")
            else { return event }
            guard event.type == .rightMouseDown || event.modifierFlags.contains(.control),
                  let button = window.contentView?.hitTest(event.locationInWindow) ?? window.contentView
            else { return event }
            menu().popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
            return nil
        }

        var keyedAt = Date.distantPast
        let center = NotificationCenter.default
        center.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main) { note in
            if Self.isPanel(note.object as? NSWindow) { keyedAt = Date() }
        }
        center.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: .main) { note in
            guard let panel = note.object as? NSWindow, Self.isPanel(panel), Date().timeIntervalSince(keyedAt) < 0.5 else { return }
            DispatchQueue.main.async { if panel.isVisible { panel.makeKey() } }
        }

        #if !APPSTORE
        if #available(macOS 27, *) { Self.openPanelOnPress() }
        #endif
    }

    nonisolated static func isPanel(_ window: NSWindow?) -> Bool {
        window.map { NSStringFromClass(type(of: $0)).contains("MenuBarExtraWindow") } ?? false
    }

    #if !APPSTORE
    @available(macOS 27, *)
    private static func openPanelOnPress() {
        let press = #selector(NSStatusBarButton.accessibilityPerformPress)
        guard let method = class_getInstanceMethod(NSStatusBarButton.self, press) else { return }
        typealias Press = @convention(c) (NSStatusBarButton, Selector) -> Bool
        let original = unsafeBitCast(method_getImplementation(method), to: Press.self)
        let block: @convention(block) (NSStatusBarButton) -> Bool = { button in
            (Thread.isMainThread && MainActor.assumeIsolated { togglePanel(from: button) }) || original(button, press)
        }
        class_replaceMethod(NSStatusBarButton.self, press, imp_implementationWithBlock(block), method_getTypeEncoding(method))
    }

    @available(macOS 27, *)
    private static func togglePanel(from button: NSStatusBarButton) -> Bool {
        let request = NSSelectorFromString("_requestExpandedInterfaceSession"), cancel = NSSelectorFromString("cancel")
        guard button.action == nil, let window = button.window, window.responds(to: NSSelectorFromString("statusItem")),
              let item = window.value(forKey: "statusItem") as? NSStatusItem, item.button === button, item.responds(to: request),
              ["expandedInterfaceDelegate", "expandedInterfaceSession"].allSatisfy({ item.responds(to: NSSelectorFromString($0)) }),
              item.value(forKey: "expandedInterfaceDelegate") != nil
        else { return false }
        if let session = item.value(forKey: "expandedInterfaceSession") as? NSObject {
            guard session.responds(to: cancel) else { return false }
            session.perform(cancel)
        } else { item.perform(request) }
        return true
    }
    #endif

    private func menu() -> NSMenu {
        let menu = NSMenu()
        let keepAwake = KeepAwake.shared
        item(menu, String(localized: "Keep Awake"), #selector(toggleKeepAwake)).state = keepAwake.isOn ? .on : .off
        menu.addItem(.separator())
        item(menu, String(localized: "Settings…"), #selector(openSettings), key: ",")
        if !Permissions.shared.allGranted {
            item(menu, String(localized: "Permissions needed"), #selector(openPermissions))
        }
        #if !APPSTORE
        if case .available(let version) = Updater.shared.state {
            item(menu, String(localized: "Update to \(version)"), #selector(installUpdate))
        } else {
            item(menu, String(localized: "Check for Updates"), #selector(checkUpdates))
        }
        #endif
        item(menu, String(localized: "About"), #selector(openAbout))
        menu.addItem(.separator())
        item(menu, String(localized: "Open at Login"), #selector(toggleLogin)).state = LoginItem.shared.isOn ? .on : .off
        menu.addItem(.separator())
        item(menu, String(localized: "Quit"), #selector(quit), key: "q")
        #if !APPSTORE
        let full = item(menu, String(localized: "Quit Completely"), #selector(quitCompletely), key: "q")
        full.keyEquivalentModifierMask = [.command, .option]
        full.isAlternate = true
        #endif
        return menu
    }

    @discardableResult
    private func item(_ menu: NSMenu, _ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let item = menu.addItem(withTitle: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func toggleKeepAwake() { KeepAwake.shared.isOn.toggle() }
    @objc private func openSettings() { SettingsWindow.show() }
    @objc private func openPermissions() { SettingsWindow.show(.permissions) }
    @objc private func openAbout() { SettingsWindow.show(.about) }
    @objc private func toggleLogin() { LoginItem.shared.set(!LoginItem.shared.isOn) }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func quitCompletely() { Background.quitCompletely() }

    #if !APPSTORE
    @objc private func checkUpdates() {
        SettingsWindow.show(.about)
        Task { await Updater.shared.check() }
    }

    @objc private func installUpdate() {
        Task { await Updater.shared.install() }
    }
    #endif
}
