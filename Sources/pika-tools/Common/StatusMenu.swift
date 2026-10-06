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
    }

    private nonisolated static func isPanel(_ window: NSWindow?) -> Bool {
        window.map { NSStringFromClass(type(of: $0)).contains("MenuBarExtraWindow") } ?? false
    }

    private func menu() -> NSMenu {
        let menu = NSMenu()
        let keepAwake = KeepAwake.shared
        item(menu, String(localized: "Keep Awake"), #selector(toggleKeepAwake)).state = keepAwake.isOn ? .on : .off
        menu.addItem(.separator())
        item(menu, String(localized: "Settings…"), #selector(openSettings), key: ",")
        if !Permissions.shared.allGranted {
            item(menu, String(localized: "Permissions needed"), #selector(openPermissions))
        }
        if case .available(let version) = Updater.shared.state {
            item(menu, String(localized: "Update to \(version)"), #selector(installUpdate))
        } else {
            item(menu, String(localized: "Check for Updates"), #selector(checkUpdates))
        }
        item(menu, String(localized: "About"), #selector(openAbout))
        menu.addItem(.separator())
        item(menu, String(localized: "Open at Login"), #selector(toggleLogin)).state = LoginItem.shared.isOn ? .on : .off
        menu.addItem(.separator())
        item(menu, String(localized: "Quit"), #selector(quit), key: "q")
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

    @objc private func checkUpdates() {
        SettingsWindow.show(.about)
        Task { await Updater.shared.check() }
    }

    @objc private func installUpdate() {
        Task { await Updater.shared.install() }
    }
}
