import AppKit
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, battery, keepAwake, brightness, fans, temperatures, speedTest, ports, sound, keyboard, mouse, windows, dock, finder, animations, uninstaller, background, games, pet, permissions, about

    var id: Self { self }

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .battery: String(localized: "Battery")
        case .keepAwake: String(localized: "Keep Awake")
        case .brightness: String(localized: "Brightness")
        case .fans: String(localized: "Fans")
        case .temperatures: String(localized: "Temperature")
        case .speedTest: String(localized: "Speed Test")
        case .ports: String(localized: "Ports")
        case .sound: String(localized: "Sound")
        case .keyboard: String(localized: "Keyboard")
        case .mouse: String(localized: "Mouse")
        case .windows: String(localized: "Windows")
        case .dock: String(localized: "Dock")
        case .finder: String(localized: "Finder")
        case .animations: String(localized: "Animations")
        case .uninstaller: String(localized: "Uninstaller")
        case .background: String(localized: "Background Tasks")
        case .games: String(localized: "Games")
        case .pet: String(localized: "Pet")
        case .permissions: String(localized: "Permissions")
        case .about: String(localized: "About")
        }
    }

    private var symbol: String {
        switch self {
        case .general: "gearshape.fill"
        case .battery: "battery.100percent"
        case .keepAwake: "cup.and.saucer.fill"
        case .brightness: "sun.max.fill"
        case .fans: "fan"
        case .temperatures: "thermometer.medium"
        case .speedTest: "speedometer"
        case .ports: "network"
        case .sound: "speaker.wave.2.fill"
        case .keyboard: "keyboard.fill"
        case .mouse: "computermouse.fill"
        case .windows: "macwindow.on.rectangle"
        case .dock: "dock.rectangle"
        case .finder: "folder.fill"
        case .animations: "hare.fill"
        case .uninstaller: "xmark.bin.fill"
        case .background: "gearshape.2.fill"
        case .games: "gamecontroller.fill"
        case .pet: "pawprint.fill"
        case .permissions: "hand.raised.fill"
        case .about: "info.circle.fill"
        }
    }

    private var color: Color {
        switch self {
        case .general, .dock, .about: .gray
        case .keyboard, .mouse, .permissions: .blue
        case .windows: .indigo
        case .finder: .cyan
        case .games: .purple
        case .animations, .sound: .pink
        case .uninstaller: .brown
        case .background: .mint
        case .keepAwake: .orange
        case .brightness: .yellow
        case .fans: .teal
        case .pet, .temperatures: .red
        case .speedTest, .battery: .green
        case .ports: .blue
        }
    }

    var isAvailable: Bool {
        if self == .battery { return Battery.isPresent }
        if self == .sound, #unavailable(macOS 14.2) { return false }
        #if APPSTORE
        return ![.fans, .uninstaller, .dock, .ports].contains(self)
        #else
        return true
        #endif
    }

    static var iconSize: CGFloat {
        switch UserDefaults.standard.integer(forKey: "NSTableViewDefaultSizeMode") {
        case 1: 18
        case 3: 24
        default: 20
        }
    }

    func icon(size: CGFloat = iconSize) -> some View {
        SectionIcon(symbol: symbol, color: color, size: size)
    }
}

struct SettingsItem: Identifiable {
    let tab: SettingsTab
    let title: String
    var synonyms = ""
    var target: String?
    var detail: String?
    var keys = ""

    var id: String { target ?? title }

    static func shortcut(_ entry: SystemGameShortcut) -> SettingsItem {
        SettingsItem(tab: .games, title: entry.name,
                     synonyms: [entry.rawName, entry.sectionName, entry.group.title, entry.group.detail, entry.description.text, entry.supportsBackground ? String(localized: "Switch language") + ", Switch language" : "", "game games gaming", String(entry.id)].joined(separator: ", "),
                     target: entry.anchor, detail: [entry.group.title, entry.text ?? (entry.pointer == nil ? String(localized: "No key assigned") : entry.pointer?.detail)].compactMap { $0 }.joined(separator: " · "), keys: entry.text ?? "")
    }

    static var all: [SettingsItem] {
        #if APPSTORE
        let hidden = [
            String(localized: "Stay in the background after Quit"), String(localized: "Repeat a held key"),
            String(localized: "Tracking speed"), String(localized: "iCloud Drive"),
            String(localized: "Check for updates automatically"), String(localized: "Buy me a coffee"),
            String(localized: "Fan control"), String(localized: "Full Disk Access"),
            String(localized: "Open archives with this app"),
            String(localized: "Green button enlarges the window"), String(localized: "Green button works as usual in these apps"),
            String(localized: "Quit when the last window closes"), String(localized: "Never quit these apps"), String(localized: "Minimize or hide with a click in the Dock"), String(localized: "A click on the icon"),
            String(localized: "Fix words as you type"), String(localized: "Fix the last word or selected text"), String(localized: "Don’t fix text in these apps"),
            String(localized: "Enter opens files in Finder"), String(localized: "Delete removes files in Finder"),
            String(localized: "Animation speed"), String(localized: "Delay before the Dock appears"), String(localized: "How fast the Dock slides out"),
            String(localized: "Opening windows"), String(localized: "Save dialogs and resizing"), String(localized: "Quick Look"),
            String(localized: "Columns in Finder"), String(localized: "Finder animations"),
            String(localized: "Dim the picture instead"),
        ] + (SettingsSync.isAvailable ? [] : [String(localized: "Sync settings with iCloud")])
            + (ToolRegistry.shared.tools.contains { $0 is ArchiveTool } ? [] : [String(localized: "Archives in Finder")])
        return allItems.filter { $0.tab.isAvailable && !hidden.contains($0.title) } + [
            SettingsItem(tab: .animations, title: String(localized: "Hide the Dock automatically"), synonyms: "autohide, hide Dock, delay, wait"),
            SettingsItem(tab: .permissions, title: String(localized: "Folders"), synonyms: "privacy, security, access, files, save, home"),
            SettingsItem(tab: .about, title: String(localized: "Say thanks"), synonyms: "support, donate, donation, tip, sponsor, thanks"),
        ] + Permissions.privacyLists.map {
            SettingsItem(tab: .permissions, title: $0.title, target: $0.pane, detail: String(localized: "Other apps’ permissions"))
        }
        #else
        return allItems.filter { $0.tab.isAvailable }
        #endif
    }

    private static var allItems: [SettingsItem] {
        [
            SettingsItem(tab: .general, title: String(localized: "Open at Login"), synonyms: "launch, startup, autostart, login items"),
            SettingsItem(tab: .general, title: String(localized: "Stay in the background after Quit"), synonyms: "background, quit, close, exit, hide, menu bar icon, option"),
            SettingsItem(tab: .general, title: String(localized: "Appearance"), synonyms: "theme, dark mode, light mode, colors"),
            SettingsItem(tab: .general, title: String(localized: "Language"), synonyms: "localization, translation"),
            SettingsItem(tab: .general, title: String(localized: "Settings file"), synonyms: "backup, export, import, restore, JSON"),
            SettingsItem(tab: .general, title: String(localized: "Sync settings with iCloud"), synonyms: "iCloud Drive, another Mac, backup"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Keep your Mac awake"), synonyms: "sleep, caffeine, insomnia"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Duration"), synonyms: "time, timer, days, hours, minutes, seconds"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Display"), synonyms: "screen, monitor, dim, screen saver"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Turn off the display now"), synonyms: "screen, monitor, dim, screen saver"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Buttons in Control Center and widgets"), synonyms: "widget, Control Center, Shortcuts, menu bar, button"),
        ] + (KeepAwake.shared.hasLid ? [
            SettingsItem(tab: .keepAwake, title: String(localized: "Work with the lid closed"), synonyms: "clamshell, laptop, MacBook, external display"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Stop when battery is below \(0.2.formatted(.percent))"), synonyms: "battery, power, charge"),
        ] : []) + [
            SettingsItem(tab: .brightness, title: String(localized: "Brightness"), synonyms: "monitor, display, screen, external display, dim, dimmer, brighter, darker, DDC, backlight"),
            SettingsItem(tab: .brightness, title: String(localized: "Brightness keys"), synonyms: "keyboard, F1, F2, brightness up, brightness down, keys, monitor, display"),
            SettingsItem(tab: .brightness, title: String(localized: "Dim the picture instead"), synonyms: "gamma, dim, darker, software dimming, monitor, display, screen"),
            SettingsItem(tab: .battery, title: String(localized: "Battery Health"), synonyms: "battery, condition, maximum capacity, cycle count, cycles, wear, service, replace"),
            SettingsItem(tab: .battery, title: String(localized: "Power Adapter"), synonyms: "charger, charging, watts, power use, adapter, plug"),
            SettingsItem(tab: .battery, title: String(localized: "Keep It Healthy"), synonyms: "charge limit, 80%, optimized battery charging, charging on hold, heat, temperature, storage, tips"),
            SettingsItem(tab: .fans, title: String(localized: "Fan speed"), synonyms: "fan, rpm, cooling, cooler, hot, heat, noise, quiet, loud, temperature, thermal"),
            SettingsItem(tab: .permissions, title: String(localized: "Fan control"), synonyms: "allow, helper, password, administrator, install, remove"),
            SettingsItem(tab: .temperatures, title: String(localized: "Temperature"), synonyms: "heat, hot, warm, thermal, sensors, CPU, GPU, processor, graphics, memory, RAM, SSD, storage, battery, Wi-Fi, degrees, Celsius, Fahrenheit, overheating"),
            SettingsItem(tab: .speedTest, title: String(localized: "Check Speed"), synonyms: "internet, Wi-Fi, network, bandwidth, ping, Mbps, speedtest"),
            SettingsItem(tab: .speedTest, title: String(localized: "What it’s good for"), synonyms: "4K, video, calls, games, downloads"),
            SettingsItem(tab: .ports, title: String(localized: "Free a port"), synonyms: "port, server, localhost, listen, kill, lsof, address in use, EADDRINUSE, process, 3000, 8080, 5000, AirPlay"),
            SettingsItem(tab: .sound, title: String(localized: "App Volume"), synonyms: "mixer, mute app, per-app volume, volume, sound, audio, quiet, loud"),
            SettingsItem(tab: .keyboard, title: String(localized: "Switch language"), synonyms: "keyboard layout, input source, option, shift, alt"),
            SettingsItem(tab: .keyboard, title: String(localized: "Repeat a held key"), synonyms: "key repeat, hold, accent menu, games, typing"),
            SettingsItem(tab: .keyboard, title: String(localized: "Home and End go to the start and end of a line"), synonyms: "home, end, line, cursor, beginning, select, text, typing"),
            SettingsItem(tab: .keyboard, title: String(localized: "Home and End work as usual in these apps"), synonyms: "exceptions, exclude, list, terminal, virtual machine, remote desktop"),
            SettingsItem(tab: .keyboard, title: String(localized: "Retype words you typed in the wrong language"), synonyms: "wrong layout, keyboard layout, language, switch, convert, typo, gibberish, Services"),
            SettingsItem(tab: .keyboard, title: String(localized: "Fix words as you type"), synonyms: "automatic, auto, Space, Return, layout"),
            SettingsItem(tab: .keyboard, title: String(localized: "Fix the last word or selected text"), synonyms: "shortcut, undo, convert, selection, layout"),
            SettingsItem(tab: .keyboard, title: String(localized: "Don’t fix text in these apps"), synonyms: "exceptions, exclude, list, layout"),
            SettingsItem(tab: .mouse, title: String(localized: "Turn off pointer acceleration"), synonyms: "linear, mouse acceleration, sensitivity"),
            SettingsItem(tab: .mouse, title: String(localized: "Tracking speed"), synonyms: "pointer speed, sensitivity, fast, slow"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll by lines"), synonyms: "wheel, scrolling speed, acceleration"),
            SettingsItem(tab: .mouse, title: String(localized: "Distance per click"), synonyms: "scrolling speed, wheel, notch"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll by"), synonyms: "pixels, lines, wheel, games, scrolling mode, notch"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll direction for trackpad and mouse"), synonyms: "natural scrolling, classic, reverse, invert, Universal Control, trackpad, mouse, Magic Mouse, wheel, direction"),
            SettingsItem(tab: .mouse, title: String(localized: "Trackpad direction"), synonyms: "natural, classic, reverse, invert, trackpad, two fingers, Magic Mouse, up, down"),
            SettingsItem(tab: .mouse, title: String(localized: "Mouse wheel direction"), synonyms: "natural, classic, reverse, invert, wheel, up, down"),
            SettingsItem(tab: .mouse, title: String(localized: "Side buttons go back and forward"), synonyms: "buttons 4 and 5, browser, navigation, thumb buttons"),
            SettingsItem(tab: .mouse, title: String(localized: "Swap the side buttons"), synonyms: "reverse, back, forward"),
            SettingsItem(tab: .mouse, title: String(localized: "Mouse button hides the current app"), synonyms: "hide, ⌘H, cmd H, middle button, button 4, button 5, mouse button"),
            SettingsItem(tab: .windows, title: String(localized: "Green button enlarges the window"), synonyms: "zoom, maximize, full screen, green button, option click"),
            SettingsItem(tab: .windows, title: String(localized: "Green button works as usual in these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .windows, title: String(localized: "Protect quitting and closing"), synonyms: "quit, close, command, accidental, shortcut"),
            SettingsItem(tab: .windows, title: String(localized: "Quit app"), synonyms: "change shortcut, record keys, Command Shift Q"),
            SettingsItem(tab: .windows, title: String(localized: "Close window"), synonyms: "change shortcut, record keys, Command Shift W"),
            SettingsItem(tab: .windows, title: String(localized: "Quit when the last window closes"), synonyms: "close button, red button, terminate, exit"),
            SettingsItem(tab: .windows, title: String(localized: "Never quit these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .dock, title: String(localized: "Minimize or hide with a click in the Dock"), synonyms: "Dock, minimize, hide, taskbar"),
            SettingsItem(tab: .dock, title: String(localized: "A click on the icon"), synonyms: "Dock, minimize, hide, taskbar"),
            SettingsItem(tab: .dock, title: String(localized: "Keep the Dock on one display"), synonyms: "Dock, display, monitor, screen, jump, move"),
            SettingsItem(tab: .dock, title: String(localized: "Main display"), synonyms: "primary, main screen, Displays settings"),
            SettingsItem(tab: .finder, title: String(localized: "New File in Finder"), synonyms: "create, text file, txt, right-click, context menu, Desktop"),
            SettingsItem(tab: .finder, title: String(localized: "Smaller Copy in Finder"), synonyms: "compress, shrink, smaller, reduce size, optimize, image, photo, picture, video, audio, music, PNG, JPEG, JPG, HEIC, TIFF, PDF, GIF, MP4, MOV, M4A, WAV, AIFF, TinyPNG"),
            SettingsItem(tab: .finder, title: String(localized: "Convert in Finder"), synonyms: "convert, format, export, save as, image, photo, picture, video, audio, music, PNG, JPEG, JPG, HEIC, TIFF, PDF, GIF, MP4, MOV, M4A, WAV, AIFF"),
            SettingsItem(tab: .finder, title: String(localized: "Archives in Finder"), synonyms: "archive, extract, unzip, unpack, zip, rar, 7z, tar, password, split, right-click, context menu"),
            SettingsItem(tab: .finder, title: String(localized: "Open archives with this app"), synonyms: "archive, default app, open with, double-click, unzip, zip, 7z"),
            SettingsItem(tab: .finder, title: String(localized: "Enter opens files in Finder"), synonyms: "return, enter, open, rename, F2, keyboard"),
            SettingsItem(tab: .finder, title: String(localized: "Cut files in Finder"), synonyms: "cut, paste, move, files, folders, command X"),
            SettingsItem(tab: .finder, title: String(localized: "Delete removes files in Finder"), synonyms: "delete, backspace, trash, remove, files, folders, keyboard"),
            SettingsItem(tab: .finder, title: String(localized: "Hide desktop icons"), synonyms: "desktop, icons, files, folders, clean, hide, presentation, screen sharing, recording, screenshot, Stage Manager"),
            SettingsItem(tab: .finder, title: String(localized: "Show hidden files"), synonyms: "hidden, invisible, dot files, system files, Library, show all files, Command Shift Period"),
            SettingsItem(tab: .uninstaller, title: String(localized: "Remove an app"), synonyms: "uninstall, remove app, delete app, delete, remove, app, application, cleaner, clean up, leftovers, trash, reset, put back, restore, undo"),
            SettingsItem(tab: .uninstaller, title: String(localized: "Offer to clean up when an app goes to the Trash"), synonyms: "uninstall, remove app, delete app, leftovers, clean up, Trash, bin, watch, automatic, offer, notify"),
            SettingsItem(tab: .background, title: String(localized: "What runs in the background"), synonyms: "login items, open at login, launch agents, launch daemons, daemons, startup, autostart, helpers, running, services, leftovers, background, turn off"),
            SettingsItem(tab: .animations, title: String(localized: "Animation speed"), synonyms: "animations, motion, fast, faster, instant, speed up"),
            SettingsItem(tab: .animations, title: String(localized: "Delay before the Dock appears"), synonyms: "autohide, hide Dock, delay, wait"),
            SettingsItem(tab: .animations, title: String(localized: "How fast the Dock slides out"), synonyms: "autohide, hide Dock, speed"),
            SettingsItem(tab: .animations, title: String(localized: "Minimize effect"), synonyms: "genie, scale, suck, minimize"),
            SettingsItem(tab: .animations, title: String(localized: "Bouncing icons"), synonyms: "bounce, jump, attention, Dock"),
            SettingsItem(tab: .animations, title: String(localized: "Opening windows"), synonyms: "window animation, new window, zoom"),
            SettingsItem(tab: .animations, title: String(localized: "Save dialogs and resizing"), synonyms: "sheet, save, print, resize, panel"),
            SettingsItem(tab: .animations, title: String(localized: "Quick Look"), synonyms: "preview, Space bar"),
            SettingsItem(tab: .animations, title: String(localized: "Columns in Finder"), synonyms: "column view, scroll"),
            SettingsItem(tab: .animations, title: String(localized: "Finder animations"), synonyms: "folder, Get Info, info window"),
            SettingsItem(tab: .animations, title: String(localized: "Even calmer: Reduce Motion in Accessibility"), synonyms: "reduce motion, accessibility, motion sickness"),
            SettingsItem(tab: .games, title: String(localized: "Game Mode"), synonyms: "game, games, gaming, play, Steam, full screen"),
            SettingsItem(tab: .games, title: String(localized: "The game doesn’t close"), synonyms: "quit, close, exit"),
            SettingsItem(tab: .games, title: String(localized: "The game window doesn’t close")),
            SettingsItem(tab: .games, title: String(localized: "Apps and windows don’t switch"), synonyms: "Command Tab, app switcher"),
            SettingsItem(tab: .games, title: String(localized: "The game doesn’t hide")),
            SettingsItem(tab: .games, title: String(localized: "Search doesn’t pop up"), synonyms: "Spotlight"),
            SettingsItem(tab: .games, title: String(localized: "Siri and voice typing don’t start")),
            SettingsItem(tab: .games, title: String(localized: "The app grid doesn’t open"), synonyms: "Launchpad"),
            SettingsItem(tab: .games, title: String(localized: "The view of all windows doesn’t open"), synonyms: "Mission Control, Spaces, Notification Center, Stage Manager"),
            SettingsItem(tab: .games, title: String(localized: "The view of the game’s windows doesn’t open"), synonyms: "App Exposé"),
            SettingsItem(tab: .games, title: String(localized: "The game doesn’t slide off the screen"), synonyms: "Show Desktop"),
            SettingsItem(tab: .games, title: String(localized: "Desktops don’t switch"), synonyms: "Spaces, swipe, gestures, trackpad"),
            SettingsItem(tab: .games, title: String(localized: "Desktops don’t switch by number"), synonyms: "Spaces, swipe, gestures, trackpad"),
            SettingsItem(tab: .games, title: String(localized: "Gestures don’t leave the game"), synonyms: "Spaces, swipe, pinch, gestures, trackpad, Magic Mouse, Mission Control, Notification Center"),
            SettingsItem(tab: .games, title: String(localized: "Emoji don’t open"), synonyms: "symbols, dictionary"),
            SettingsItem(tab: .games, title: String(localized: "The dictionary doesn’t pop up"), synonyms: "Look Up"),
            SettingsItem(tab: .games, title: String(localized: "The keyboard stays in the game"), synonyms: "keyboard focus, function keys, Control Space, Ctrl, Shift, Option, input source, language"),
            SettingsItem(tab: .games, title: String(localized: "🌐 shortcuts are paused"), synonyms: "fn, globe key"),
            SettingsItem(tab: .games, title: String(localized: "⌃-click works as a plain click"), synonyms: "ctrl, control key, shortcuts, right-click, context menu"),
            SettingsItem(tab: .games, title: String(localized: "The pointer stays in the game"), synonyms: "mouse, cursor, Dock, menu bar, hot corners, edges, second display"),
            SettingsItem(tab: .games, title: String(localized: "The screen stays on")),
            SettingsItem(tab: .games, title: String(localized: "Your games")),
            SettingsItem(tab: .games, title: String(localized: "Show FPS"), synonyms: "frame rate, frames per second, counter, performance, lag, screen recording"),
            SettingsItem(tab: .games, title: String(localized: "Corner for FPS")),
            SettingsItem(tab: .games, title: String(localized: "System keyboard shortcuts")),
            SettingsItem(tab: .games, title: String(localized: "Game safeguards")),
            SettingsItem(tab: .pet, title: String(localized: "Pet on the desktop"), synonyms: "pet, buddy, friend, character, mascot, desktop, jump, Space"),
            SettingsItem(tab: .pet, title: String(localized: "Talks sometimes"), synonyms: "phrases, speech bubble, talk, say, messages, updates"),
            SettingsItem(tab: .pet, title: String(localized: "Follows your rhythm"), synonyms: "sleep, nap, doze, tired, energy, typing, away, idle, wake"),
            SettingsItem(tab: .pet, title: String(localized: "Ball"), synonyms: "toy, football, soccer, kick, play, throw, selection, platform"),
            SettingsItem(tab: .pet, title: String(localized: "Wardrobe"), synonyms: "clothes, outfit, costume, dress up, hats, glasses, scarf, shoes, cape, wings"),
            SettingsItem(tab: .pet, title: String(localized: "Looks"), synonyms: "outfit, costume, wizard, pirate, astronaut, superhero, cowboy, fairy, king, gentleman, scientist, detective"),
            SettingsItem(tab: .pet, title: String(localized: "Awards"), synonyms: "medals, achievements, trophies, badges, rewards, progress, unlock, earned"),
            SettingsItem(tab: .pet, title: String(localized: "Erase Progress…"), synonyms: "reset, delete, clear, start over, privacy"),
            SettingsItem(tab: .permissions, title: Permission.accessibilityTitle, synonyms: "privacy, security, access, accessibility, device control, data access"),
            SettingsItem(tab: .permissions, title: String(localized: "Input Monitoring"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "Screen Recording"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "iCloud Drive"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "Finder Extensions"), synonyms: "privacy, security, access, right-click, menu, extension"),
            SettingsItem(tab: .permissions, title: String(localized: "Full Disk Access"), synonyms: "privacy, security, access, files, disk"),
            SettingsItem(tab: .permissions, title: String(localized: "Left by deleted apps"), synonyms: "permissions, privacy, deleted apps, cleanup, tcc"),
            SettingsItem(tab: .about, title: String(localized: "Check for updates automatically"), synonyms: "update, new version, software update"),
            SettingsItem(tab: .about, title: String(localized: "What’s New"), synonyms: "changelog, release notes, version"),
            SettingsItem(tab: .about, title: String(localized: "Report a Problem"), synonyms: "bug, issue, feedback, support"),
            SettingsItem(tab: .about, title: String(localized: "License (MIT)"), synonyms: "open source, legal"),
            SettingsItem(tab: .about, title: String(localized: "Buy me a coffee"), synonyms: "support, donate, donation, tip, sponsor, thanks"),
            SettingsItem(tab: .about, title: "GitHub", synonyms: "open source, legal"),
        ] + (SettingsTab.sound.isAvailable ? [
            SettingsItem(tab: .permissions, title: String(localized: "System Audio Recording"), synonyms: "privacy, security, access"),
        ] : []) + GameShortcutGroup.allCases.map { SettingsItem(tab: .games, title: $0.title, synonyms: $0.detail) }
    }

    func matches(_ query: String) -> Bool {
        let words = synonyms + ", " + Bundle.main.localizedString(forKey: synonyms, value: nil, table: nil)
        return (target == nil || SettingsSearch.matchesKeys(query, keys: keys)) && SettingsSearch.matches(query, fields: [title, words, tab.title, keys])
    }
}

enum SettingsWindow {
    @Observable
    final class Model {
        var selection: SettingsTab? = .general {
            didSet {
                guard !navigating, let oldValue, oldValue != selection else { return }
                back.append(oldValue)
                forward = []
            }
        }
        var search = ""
        var highlight: String?
        var systemShortcuts: [SystemGameShortcut] = []
        var confirmingReset = false
        private(set) var back: [SettingsTab] = []
        private(set) var forward: [SettingsTab] = []
        @ObservationIgnored private var navigating = false

        var searchItems: [SettingsItem] { SettingsItem.all + systemShortcuts.map(SettingsItem.shortcut) }
        var highlightedShortcut: SystemGameShortcut? { systemShortcuts.first { $0.anchor == highlight } }

        func refreshShortcuts() { systemShortcuts = SystemShortcutCatalog.load().filter(\.listed) }

        func goBack() {
            guard let tab = back.popLast() else { return }
            selection.map { forward.append($0) }
            move(to: tab)
        }

        func goForward() {
            guard let tab = forward.popLast() else { return }
            selection.map { back.append($0) }
            move(to: tab)
        }

        private func move(to tab: SettingsTab) {
            navigating = true
            selection = tab
            navigating = false
        }

        func open(_ item: SettingsItem) {
            selection = item.tab
            highlight = nil
            highlight = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if self.highlight == item.id { self.highlight = nil }
            }
        }
    }

    static let model = Model()
    private(set) static var window: NSWindow?

    static var preview: some View { SettingsView() }

    static let minSize = NSSize(width: 660, height: 460)

    static func show(_ tab: SettingsTab? = nil) {
        if let tab {
            model.search = ""
            model.selection = tab
        }
        if window == nil { create() }
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            guard !NSApp.isActive, window?.isVisible == true else { return }
            NSApp.bringForward()
            window?.makeKeyAndOrderFront(nil)
        }
    }

    private static func create() {
        let width: CGFloat = 860
        let height = min(800, (NSScreen.main?.visibleFrame.height ?? 900) - 40)
        let host = NSHostingController(rootView: SettingsView())
        host.sceneBridgingOptions = [.toolbars, .title]
        let window = NSWindow(contentViewController: host)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.toolbarStyle = .unified
        window.collectionBehavior.insert(.fullScreenNone)
        window.isReleasedWhenClosed = false
        window.contentMinSize = minSize
        window.title = (model.selection ?? .general).title
        window.setContentSize(NSSize(width: width, height: height))
        window.center()
        window.setFrameAutosaveName("Settings Frame")
        let saved = window.contentRect(forFrameRect: window.frame).size
        window.setContentSize(NSSize(width: max(saved.width, minSize.width), height: max(saved.height, minSize.height)))
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
            NewMarks.shared.leave((model.selection ?? .general).rawValue)
            NSApp.setActivationPolicy(.accessory)
        }
        self.window = window
    }

    static func restart(opening argument: String = "--settings", resetting service: String? = nil) {
        #if APPSTORE
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = [argument]
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, error in
            DispatchQueue.main.async { if error == nil { Background.quit() } }
        }
        #else
        let helper = Process()
        helper.executableURL = URL(fileURLWithPath: "/bin/bash")
        helper.arguments = ["-c", "while kill -0 \"$1\" 2>/dev/null; do sleep 0.2; done; [ -z \"$4\" ] || /usr/bin/tccutil reset \"$4\" \"$3\"; open \"$2\" --args \"$5\"",
                            "pika-restart", String(ProcessInfo.processInfo.processIdentifier), Bundle.main.bundleURL.path,
                            Bundle.main.bundleIdentifier ?? "", service ?? "", argument]
        try? helper.run()
        Background.quit()
        #endif
    }
}

private struct SettingsView: View {
    @Bindable private var model = SettingsWindow.model
    @State private var columns = NavigationSplitViewVisibility.all

    var body: some View {
        let tab = model.selection ?? .general
        NavigationSplitView(columnVisibility: $columns) {
            List(selection: $model.selection) {
                if model.search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    #if APPSTORE
                    Section { rows([.general]) }
                    Section { rows([.battery, .keepAwake, .brightness, .temperatures, .speedTest]) }
                    Section { rows([.sound, .keyboard, .mouse, .windows, .finder, .animations]) }
                    Section { rows([.background, .games, .pet]) }
                    #else
                    Section { rows([.general]) }
                    Section { rows([.battery, .keepAwake, .brightness, .fans, .temperatures, .speedTest, .ports]) }
                    Section { rows([.sound, .keyboard, .mouse, .windows, .dock, .finder, .animations]) }
                    Section { rows([.uninstaller, .background, .games, .pet]) }
                    #endif
                    Section { rows([.permissions, .about]) }
                } else {
                    results
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 320)
        } detail: {
            detail(tab)
                .navigationSplitViewColumnWidth(min: 440, ideal: 520)
                .navigationTitle(tab.title)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            withAnimation { columns = columns == .detailOnly ? .all : .detailOnly }
                        } label: { Label("Sidebar", systemImage: "sidebar.left") }
                        .help(Text("Sidebar"))
                    }
                    ToolbarItem(placement: .navigation) {
                        ControlGroup {
                            Button { model.goBack() } label: { Label("Back", systemImage: "chevron.backward") }
                                .keyboardShortcut("[")
                                .disabled(model.back.isEmpty)
                            Button { model.goForward() } label: { Label("Forward", systemImage: "chevron.forward") }
                                .keyboardShortcut("]")
                                .disabled(model.forward.isEmpty)
                        }
                        .controlGroupStyle(.navigation)
                    }
                }
        }
        .searchable(text: $model.search, placement: .sidebar)
        .frame(minWidth: SettingsWindow.minSize.width, minHeight: SettingsWindow.minSize.height)
        .onChange(of: tab, initial: true) { old, tab in
            if old != tab { NewMarks.shared.leave(old.rawValue) }
            NewMarks.shared.open(tab.rawValue)
            SettingsWindow.window?.title = tab.title
            PetProgress.shared.mark("page:\(tab.rawValue)")
            if tab == .pet { PetProgress.shared.add(.visits) }
        }
        .onAppear { model.refreshShortcuts() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in model.refreshShortcuts() }
        #if !APPSTORE
        .environment(\.openURL, OpenURLAction { url in
            if url.host == "github.com", url.pathComponents.dropFirst().first == "dev-pikapik" { PetProgress.shared.add(.github) }
            return .systemAction(url)
        })
        #endif
    }

    private func rows(_ tabs: [SettingsTab]) -> some View {
        ForEach(tabs.filter(\.isAvailable)) { tab in
            Label {
                HStack(spacing: 6) {
                    Text(tab.title)
                    if NewMarks.shared.isNew(tab: tab.rawValue) { NewDot() }
                }
            } icon: { tab.icon() }
                .tag(tab)
                .badge(tab == .pet ? PetProgress.shared.freshAwards : 0)
        }
    }

    @ViewBuilder
    private var results: some View {
        let query = model.search.trimmingCharacters(in: .whitespacesAndNewlines)
        let items = model.searchItems.filter { $0.matches(query) }.sorted {
            let left = SettingsSearch.score(query, title: $0.title, keys: $0.keys)
            let right = SettingsSearch.score(query, title: $1.title, keys: $1.keys)
            return left == right ? $0.id.localizedStandardCompare($1.id) == .orderedAscending : left > right
        }
        let tabs = SettingsTab.allCases.filter { tab in
            tab.isAvailable && (tab.title.localizedStandardContains(query) || items.contains { $0.tab == tab })
        }
        if tabs.isEmpty {
            Text("No Results")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
        ForEach(tabs) { tab in
            Label { Text(tab.title) } icon: { tab.icon() }
                .tag(tab)
            ForEach(items.filter { $0.tab == tab }) { item in
                Button { model.open(item) } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title).foregroundStyle(.secondary).lineLimit(2)
                        if let detail = item.detail {
                            Text(verbatim: detail).font(.caption).foregroundStyle(.tertiary).lineLimit(2)
                        }
                    }
                        .padding(.leading, SettingsTab.iconSize + 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func detail(_ tab: SettingsTab) -> some View {
        switch tab {
        case .general: GeneralSettings()
        case .keepAwake: KeepAwakeSettings()
        case .brightness: BrightnessSettings()
        case .fans:
            #if APPSTORE
            EmptyView()
            #else
            FanSettings()
            #endif
        case .battery: BatterySettings()
        case .temperatures: TemperatureSettings()
        case .speedTest: SpeedTestSettings()
        case .ports: PortsPage()
        case .sound: ToolsSettings(tab: .sound, text: String(localized: "Each app gets its own volume"))
        case .keyboard: ToolsSettings(tab: .keyboard, text: String(localized: "Switch language, fix wrong layout, Home and End"))
        case .mouse: ToolsSettings(tab: .mouse, text: String(localized: "Scrolling, side buttons and pointer speed"))
        case .windows:
            ToolsSettings(
                tab: .windows,
                text: String(localized: "Fixes for windows and quitting apps"),
                headings: ["window-zoom": "Size", "quit-on-close": "Closing and Quitting"]
            )
        case .dock: ToolsSettings(tab: .dock, text: String(localized: "Hide apps with a click and keep the Dock on one display"))
        case .finder: ToolsSettings(tab: .finder, text: String(localized: "Create, convert and compress files right in Finder"))
        case .animations:
            #if APPSTORE
            AnimationLinksPage()
            #else
            AnimationsPage()
            #endif
        case .uninstaller:
            #if APPSTORE
            EmptyView()
            #else
            UninstallerPage()
            #endif
        case .background: BackgroundPage()
        case .games: GameModePage()
        case .pet: PetPage()
        case .permissions: PermissionsView()
        case .about: AboutView()
        }
    }
}

extension View {
    func settingAnchor(_ id: String) -> some View {
        modifier(SettingAnchor(id: id))
    }

    func settingsPage() -> some View {
        modifier(SettingsPage())
    }

    func whileShown(in window: @escaping (NSWindow) -> Bool = { $0 === SettingsWindow.window }, _ shown: @escaping (Bool) -> Void) -> some View {
        modifier(WhileShown(window: window, shown: shown))
    }
}

private struct WhileShown: ViewModifier {
    let window: (NSWindow) -> Bool
    let shown: (Bool) -> Void
    @State private var on = false

    private func set(_ value: Bool) {
        guard value != on else { return }
        on = value
        shown(value)
    }

    func body(content: Content) -> some View {
        content
            .onAppear { set(true) }
            .onDisappear { set(false) }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification)) { note in
                guard let changed = note.object as? NSWindow, window(changed) else { return }
                set(changed.occlusionState.contains(.visible))
            }
    }
}

private struct SettingAnchor: ViewModifier {
    let id: String
    private let model = SettingsWindow.model

    func body(content: Content) -> some View {
        content
            .id(id)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(model.highlight == id ? 0.25 : 0))
                    .padding(.horizontal, -8)
                    .padding(.vertical, -6)
                    .animation(.easeInOut(duration: 0.4), value: model.highlight)
            }
    }
}

private struct SettingsPage: ViewModifier {
    private let model = SettingsWindow.model

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .labeledContentStyle(CenteredLabeledContentStyle())
                .toggleStyle(CenteredSwitchStyle())
                .labelStyle(.titleAndIcon)
                .modifier(AppDropPage())
                .onAppear { scroll(proxy) }
                .onChange(of: model.highlight) { scroll(proxy) }
        }
    }

    private func scroll(_ proxy: ScrollViewProxy) {
        guard let id = model.highlight else { return }
        DispatchQueue.main.async {
            withAnimation { proxy.scrollTo(id, anchor: .center) }
        }
    }
}

struct RestoreDefaultsSection: View {
    let message: String
    let isDefault: Bool
    let reset: () -> Void
    @Bindable private var model = SettingsWindow.model

    var body: some View {
        Section {
        } footer: {
            HStack {
                Spacer()
                Button("Restore Defaults…", systemImage: "arrow.counterclockwise") { model.confirmingReset = true }
                    .disabled(isDefault)
            }
        }
        .alert("Restore default settings?", isPresented: $model.confirmingReset) {
            Button("Restore Defaults", action: reset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

struct SettingsHeader: View {
    let tab: SettingsTab
    var title: String?
    let text: String
    var appIcon: NSImage?

    var body: some View {
        Section {
            VStack(spacing: 0) {
                Group {
                    if let appIcon {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(-6)
                            .accessibilityHidden(true)
                    } else {
                        tab.icon(size: 48)
                    }
                }
                .padding(.bottom, 12)
                Text(title ?? tab.title)
                    .font(.title.bold())
                    .padding(.bottom, 4)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .padding(.horizontal, 24)
        }
    }
}

enum Appearance: String, CaseIterable {
    case system, light, dark

    static var saved: Appearance {
        Appearance(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "") ?? .system
    }

    var title: String {
        switch self {
        case .system: String(localized: "System")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
        }
    }

    func apply() {
        switch self {
        case .system: NSApp.appearance = nil
        case .light: NSApp.appearance = NSAppearance(named: .aqua)
        case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

@Observable
final class Language {
    static let shared = Language()
    static let codes = ["en", "ru", "uk", "de", "fr", "es", "it", "pt-BR", "nl", "sv", "pl", "cs", "ro", "tr", "ja", "zh-Hans", "zh-Hant", "ko", "ar", "hi", "th", "vi", "id"]

    let atLaunch: String
    var selected: String {
        didSet {
            if selected.isEmpty {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.set([selected], forKey: "AppleLanguages")
            }
        }
    }

    private init() {
        atLaunch = Self.saved
        selected = atLaunch
    }

    private static var saved: String {
        let domain = UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        return (domain?["AppleLanguages"] as? [String])?.first ?? ""
    }

    func load() {
        selected = Self.saved
    }

    static func name(_ code: String) -> String {
        let name = Locale(identifier: code).localizedString(forIdentifier: code) ?? code
        return name.prefix(1).uppercased() + name.dropFirst()
    }
}

private struct GeneralSettings: View {
    @Bindable private var loginItem = LoginItem.shared
    @AppStorage("appearance") private var appearance = Appearance.system
    @AppStorage(Background.key) private var keepRunning = true
    @Bindable private var language = Language.shared
    @Bindable private var sync = SettingsSync.shared

    @ViewBuilder private var backupButtons: some View {
        Button("Import Settings…", systemImage: "square.and.arrow.down") { SettingsBackup.chooseImport() }
        Button("Export Settings…", systemImage: "square.and.arrow.up") { SettingsBackup.export() }
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .general, text: String(localized: "How pikapik starts and looks."))
            Section {
                if loginItem.needsApproval { SettingsGuide.loginItems }
                Toggle(isOn: $loginItem.isOn) {
                    HStack {
                        RowLabel(Text("Open at Login"), Text(loginItem.needsApproval
                             ? String(localized: "Allow it in System Settings › General › Login Items")
                             : String(localized: "Starts on its own when you log in")))
                        if loginItem.needsApproval {
                            Spacer()
                            Button("Open", systemImage: "arrow.up.forward.app") { BackgroundTasks.openLoginItems() }
                        }
                    }
                }
                .settingAnchor(String(localized: "Open at Login"))
                #if !APPSTORE
                Toggle(isOn: $keepRunning) {
                    RowLabel(Text("Stay in the background after Quit"), Text("Shortcuts and Keep Awake keep working. Hold Option to quit completely"))
                }
                .settingAnchor(String(localized: "Stay in the background after Quit"))
                #endif
                LabeledContent("Appearance") {
                    AppearancePicker(selection: Binding(get: { appearance }, set: { appearance = $0; $0.apply() }))
                        .fixedSize()
                }
                .settingAnchor(String(localized: "Appearance"))
                Picker("Language", selection: $language.selected) {
                    Text("System").tag("")
                    Divider()
                    ForEach(Language.codes, id: \.self) { Text(verbatim: Language.name($0)).tag($0) }
                }
                .settingAnchor(String(localized: "Language"))
                if language.selected != language.atLaunch {
                    LabeledContent("Restart pikapik to apply") {
                        Button("Restart", systemImage: "arrow.clockwise") { SettingsWindow.restart() }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            Section("Backup") {
                VStack(alignment: .leading, spacing: 10) {
                    RowLabel(Text("Settings file"), Text("Save all settings to a file, or load them from one"))
                    ViewThatFits(in: .horizontal) {
                        HStack { backupButtons }
                        VStack(alignment: .leading) { backupButtons }
                    }
                }
                .padding(.vertical, 2)
                .settingAnchor(String(localized: "Settings file"))
                if SettingsSync.isAvailable {
                    Toggle(isOn: $sync.isEnabled) {
                        RowLabel(Text("Sync settings with iCloud"), Text(syncStatus))
                    }
                    .settingAnchor(String(localized: "Sync settings with iCloud"))
                }
                #if !APPSTORE
                if sync.state == .noDrive {
                    LabeledContent("Turn on iCloud Drive in System Settings") {
                        Button("Open", systemImage: "arrow.up.forward.app") { sync.openSettings() }
                    }
                    .foregroundStyle(.secondary)
                } else if sync.state == .noAccess {
                    LabeledContent("Needs a permission. Click to allow it.") {
                        Button("Allow") { Permissions.shared.ask([.iCloud]) }
                    }
                    .foregroundStyle(.secondary)
                }
                #endif
            }
            RestoreDefaultsSection(
                message: resetMessage,
                isDefault: appearance == .system && language.selected.isEmpty && !sync.isEnabled
            ) {
                sync.isEnabled = false
                appearance = .system
                Appearance.system.apply()
                language.selected = ""
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .onAppear { loginItem.refresh() }
        .alert(Text(verbatim: sync.alert?.title ?? ""), isPresented: Binding(get: { sync.alert != nil }, set: { if !$0 { sync.alert = nil } })) {
            Button("OK") {}
        } message: {
            Text(verbatim: sync.alert?.message ?? "")
        }
        .alert("Replace your settings?", isPresented: Binding(get: { sync.pendingImport != nil }, set: { if !$0 { sync.pendingImport = nil } }), presenting: sync.pendingImport) { item in
            Button("Replace") { sync.confirmImport(item) }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("All pikapik settings will be replaced with the ones from “\(item.name)”.")
        }
    }

    private var resetMessage: String {
        #if APPSTORE
        SettingsSync.isAvailable
            ? String(localized: "Appearance and Language will follow the system again, and iCloud sync will turn off. Open at Login and the settings saved in iCloud stay as they are.")
            : String(localized: "Appearance and Language will follow the system again. Open at Login stays as it is.")
        #else
        String(localized: "Appearance and Language will follow the system again, and iCloud sync will turn off. Open at Login and the settings saved in iCloud Drive stay as they are.")
        #endif
    }

    private var syncStatus: String {
        switch sync.state {
        case .off: String(localized: "Same settings on all your Macs")
        case .synced(let date): String(localized: "Last synced at \(date.formatted(date: .omitted, time: .shortened))")
        case .noDrive: String(localized: "iCloud Drive is turned off on this Mac")
        case .noAccess: String(localized: "pikapik isn’t allowed to open iCloud Drive")
        case .failed(let message): String(localized: "Can’t sync: \(message)")
        }
    }
}

private struct AppearancePicker: View {
    @Binding var selection: Appearance

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(Appearance.allCases, id: \.self) { item in
                ChoiceTile(title: item.title, selected: item == selection, action: { selection = item }) {
                    preview(item)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func preview(_ item: Appearance) -> some View {
        switch item {
        case .light: MiniWindow(dark: false)
        case .dark: MiniWindow(dark: true)
        case .system:
            MiniWindow(dark: false)
                .overlay { MiniWindow(dark: true).mask(Diagonal()) }
        }
    }
}

private struct MiniWindow: View {
    let dark: Bool

    var body: some View {
        let wallpaper = dark
            ? [Color(red: 0.16, green: 0.18, blue: 0.42), Color(red: 0.36, green: 0.20, blue: 0.48)]
            : [Color(red: 0.60, green: 0.78, blue: 0.97), Color(red: 0.88, green: 0.93, blue: 1.0)]
        let bar = Color(white: dark ? 0.36 : 0.82)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 1.5) {
                    ForEach([Color.red, .yellow, .green], id: \.self) { Circle().fill($0).frame(width: 3, height: 3) }
                }
                .padding(.bottom, 2)
                ForEach(0..<3, id: \.self) { _ in Capsule().fill(bar).frame(width: 12, height: 2) }
                Spacer(minLength: 0)
            }
            .padding(4)
            .frame(width: 22)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(white: dark ? 0.22 : 0.93))
            VStack(alignment: .leading, spacing: 4) {
                ForEach([30, 22, 30, 16], id: \.self) { Capsule().fill(bar).frame(width: CGFloat($0), height: 2) }
                Spacer(minLength: 0)
            }
            .padding(.top, 9)
            .padding(.leading, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(white: dark ? 0.13 : 1))
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3))
        .padding(.leading, 9)
        .padding(.top, 8)
        .background(LinearGradient(colors: wallpaper, startPoint: .topLeading, endPoint: .bottomTrailing))
        .environment(\.colorScheme, dark ? .dark : .light)
        .accessibilityHidden(true)
    }
}

private struct Diagonal: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct ToolsSettings: View {
    let tab: SettingsTab
    let text: String
    var headings: [String: LocalizedStringKey] = [:]

    private var tools: [any Tool] { ToolRegistry.shared.tools.filter { $0.tab == tab } }

    var body: some View {
        Form {
            SettingsHeader(tab: tab, text: text)
            #if APPSTORE
            if tab == .mouse {
                Section {
                    SystemSettingsRow(
                        title: String(localized: "Turn off pointer acceleration"),
                        subtitle: Text("Same distance as your hand, at any speed"),
                        url: URL(string: "x-apple.systempreferences:com.apple.Mouse-Settings.extension")!,
                        guide: SettingsGuide(pane: .mouse, steps: [.button("Advanced…"), .toggle("Pointer acceleration", on: false)])
                    )
                }
            }
            #endif
            ForEach(tools, id: \.id) { tool in
                if headings[tool.id] != nil || NewMarks.shared.isNew(row: tool.id) {
                    Section { tool.settingsView.needs(tool.needs) } header: { NewTitle(title: headings[tool.id], row: tool.id) }
                } else {
                    Section { tool.settingsView.needs(tool.needs) }
                }
            }
            #if APPSTORE
            if tab == .finder { Section { HiddenFilesHint() } }
            #endif
            RestoreDefaultsSection(
                message: String(localized: "These will turn off and go back to their default options: \(tools.filter { !$0.isDefault }.map(\.title).formatted(.list(type: .and)))"),
                isDefault: tools.allSatisfy(\.isDefault)
            ) {
                tools.forEach { $0.reset() }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                PermissionBar(permissions: tools.flatMap(\.needs))
                if tab == .finder { FinderRestartBar() }
            }
        }
        .environment(\.inSettings, true)
    }
}

struct SystemSettingsRow: View {
    let title: String
    var subtitle: Text?
    let url: URL
    var guide: SettingsGuide?

    var body: some View {
        if let guide { guide }
        LabeledContent {
            Button("Open", systemImage: "arrow.up.forward.app") { NSWorkspace.shared.open(url) }
        } label: {
            RowLabel(Text(title), subtitle)
        }
        .settingAnchor(title)
    }
}

#if APPSTORE
private struct AnimationLinksPage: View {
    private static let desktop = URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension")!

    var body: some View {
        Form {
            SettingsHeader(tab: .animations, text: String(localized: "Change animations in System Settings. Each button opens the right place."))
            Section {
                SystemSettingsRow(
                    title: String(localized: "Minimize effect"),
                    subtitle: Text("Choose “Scale Effect” for a quicker animation"),
                    url: Self.desktop,
                    guide: SettingsGuide(pane: .desktop, steps: [.popup(nil, from: "Genie Effect", to: "Scale Effect")])
                )
            }
            Section {
                SystemSettingsRow(
                    title: String(localized: "Bouncing icons"),
                    subtitle: Text("Turn off “Animate opening applications”"),
                    url: Self.desktop,
                    guide: SettingsGuide(pane: .desktop, steps: [.toggle("Animate opening applications", on: false)])
                )
            }
            Section {
                SystemSettingsRow(
                    title: String(localized: "Hide the Dock automatically"),
                    subtitle: Text("Turn on “Automatically hide and show the Dock”"),
                    url: Self.desktop,
                    guide: SettingsGuide(pane: .desktop, steps: [.toggle("Automatically hide and show the Dock", on: true)])
                )
            }
            Section {
                SystemSettingsRow(title: String(localized: "Even calmer: Reduce Motion in Accessibility"), url: SettingsGuide.reduceMotionLink, guide: .reduceMotion)
            }
        }
        .formStyle(.grouped)
        .settingsPage()
    }
}
#endif

private struct AboutView: View {
    private static let github = Bundle.main.url(forResource: "github", withExtension: "svg").flatMap { NSImage(contentsOf: $0) }
    #if APPSTORE
    private static let source = "https://github.com/dev-pikapik/pika-tools/tree/main/Sources/pika-tools"
    private static let edition = "Mac%20App%20Store"
    #else
    private static let source = "https://github.com/dev-pikapik/pika-tools"
    private static let edition = "Website%20%2F%20GitHub%20%2F%20Homebrew"
    #endif

    private static var whatsNew: String {
        let code = Bundle.main.preferredLocalizations.first ?? "en"
        let page = code != "en" && Language.codes.contains(code) ? "README.\(code).md" : "README.md"
        return "https://github.com/dev-pikapik/pika-tools/blob/main/docs/whats-new/\(page)"
    }

    #if !APPSTORE
    @Bindable private var updater = Updater.shared
    #endif
    private let info = Bundle.main.infoDictionary ?? [:]
    private var version: String {
        "\(info["CFBundleShortVersionString"] ?? "")"
    }
    private var icon: NSImage {
        _ = IconStyle.shared.theme
        return NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .about, title: "pikapik", text: String(localized: "Small tools that make your Mac nicer to use"), appIcon: icon)

            #if APPSTORE
            Section { LabeledContent { EmptyView() } label: { RowLabel(Text("Version \(version)")) } }
            #else
            Section("Updates") {
                Toggle("Check for updates automatically", isOn: $updater.checksAutomatically)
                    .settingAnchor(String(localized: "Check for updates automatically"))
                LabeledContent {
                    if case .available(let version) = updater.state {
                        Button("Update to \(version)", systemImage: "arrow.down.circle") { Task { await updater.install() } }
                            .buttonStyle(.borderedProminent)
                            .accessibilityElement(children: .contain)
                    } else {
                        Button("Check Now", systemImage: "arrow.triangle.2.circlepath") { Task { await updater.check() } }
                            .disabled(updater.state == .checking || updater.state == .installing)
                            .accessibilityElement(children: .contain)
                    }
                } label: {
                    RowLabel(Text("Version \(version)"), updater.state.title.map { Text($0) })
                        .textSelection(.enabled)
                }
            }
            #endif

            #if APPSTORE
            TipJarSection()
            #endif

            Section {
                link("GitHub", Self.source, symbol: "chevron.left.forwardslash.chevron.right", color: .gray, template: Self.github)
                link(String(localized: "What’s New"), Self.whatsNew, symbol: "newspaper.fill", color: .blue)
                link(String(localized: "Report a Problem"), "https://github.com/dev-pikapik/pika-tools/issues/new?template=bug_report.yml&edition=\(Self.edition)&version=\(version)", symbol: "ladybug.fill", color: .red)
                link(String(localized: "License (MIT)"), "https://github.com/dev-pikapik/pika-tools/blob/main/LICENSE", symbol: "doc.text.fill", color: .green)
            } footer: {
                VStack(spacing: 4) {
                    Text(verbatim: info["NSHumanReadableCopyright"] as? String ?? "")
                    #if !APPSTORE
                    CoffeeLine()
                    #endif
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
            #if !APPSTORE
            RestoreDefaultsSection(
                message: String(localized: "pikapik will check for updates automatically again."),
                isDefault: updater.checksAutomatically
            ) {
                updater.checksAutomatically = true
            }
            #endif
        }
        .formStyle(.grouped)
        .settingsPage()
    }

    private func link(_ title: String, _ url: String, symbol: String, color: Color, template: NSImage? = nil) -> some View {
        Link(destination: URL(string: url)!) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.secondary)
            } label: {
                HStack(spacing: 10) {
                    SectionIcon(symbol: symbol, color: color, size: SettingsTab.iconSize, template: template)
                    Text(verbatim: title)
                        .foregroundStyle(.primary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingAnchor(title)
    }
}

#if !APPSTORE
private struct CoffeeLine: View {
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 5) {
            Text("Made with care")
            Text(verbatim: "·")
                .accessibilityHidden(true)
            Link(destination: URL(string: "https://buymeacoffee.com/pikapik")!) {
                HStack(spacing: 4) {
                    Image(systemName: "cup.and.saucer.fill")
                        .imageScale(.small)
                        .accessibilityHidden(true)
                    Text("Buy me a coffee")
                }
                .foregroundStyle(hovering ? HierarchicalShapeStyle.primary : HierarchicalShapeStyle.secondary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { inside in
                hovering = inside
                if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .onDisappear {
                if hovering { NSCursor.pop() }
            }
            .settingAnchor(String(localized: "Buy me a coffee"))
        }
    }
}
#endif

extension NSApplication {
    func bringForward() {
        activate(ignoringOtherApps: true)
    }
}
