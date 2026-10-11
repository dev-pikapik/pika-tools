import Foundation

enum GameShortcutGroup: String, CaseIterable, Identifiable {
    case language, windows, desktops, screenshots, keyboard, accessibility, system, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .language: String(localized: "Language")
        case .windows: String(localized: "Apps and windows")
        case .desktops: String(localized: "Desktops")
        case .screenshots: String(localized: "Screenshots")
        case .keyboard: String(localized: "Keyboard")
        case .accessibility: String(localized: "Accessibility")
        case .system: String(localized: "System controls")
        case .other: String(localized: "Other macOS actions")
        }
    }

    var detail: String {
        switch self {
        case .language: String(localized: "Switch languages without leaving the game.")
        case .windows: String(localized: "Switch apps, arrange windows and exit safely.")
        case .desktops: String(localized: "Mission Control, Spaces and the desktop.")
        case .screenshots: String(localized: "Pictures of the screen and screen recording.")
        case .keyboard: String(localized: "Keyboard focus, emoji and the Globe key.")
        case .accessibility: String(localized: "Zoom, colours, spoken feedback and captions.")
        case .system: String(localized: "Search, sound, brightness and other Mac controls.")
        case .other: String(localized: "Actions whose purpose macOS doesn’t publish.")
        }
    }

    var symbol: String {
        switch self {
        case .language: "globe"
        case .windows: "macwindow.on.rectangle"
        case .desktops: "rectangle.3.group"
        case .screenshots: "camera"
        case .keyboard: "keyboard"
        case .accessibility: "accessibility"
        case .system: "slider.horizontal.3"
        case .other: "ellipsis"
        }
    }
}

enum GameShortcutDescription: Equatable {
    case language, windows, desktops, screenshot, capture, zoom, contrast, invert, voice, captions, presenter, focus, brightness, volume, note, notifications, forceQuit, apps, spotlight, siri, launchpad, emoji, dictionary, keyboard, globe, quit, close, click, cursor, display, swipes, dock, named, other

    var text: String {
        switch self {
        case .language: String(localized: "Changes the keyboard input language.")
        case .windows: String(localized: "Moves or resizes the active window.")
        case .desktops: String(localized: "Shows open windows or moves to another desktop.")
        case .screenshot: String(localized: "Saves a picture of the screen or copies it to the clipboard.")
        case .capture: String(localized: "Opens the screenshot and screen recording controls.")
        case .zoom: String(localized: "Magnifies the screen to make details easier to see.")
        case .contrast: String(localized: "Changes the contrast of text and controls.")
        case .invert: String(localized: "Reverses the screen colours.")
        case .voice: String(localized: "Reads screen content or text aloud.")
        case .captions: String(localized: "Shows live captions for spoken audio.")
        case .presenter: String(localized: "Shows you over the content shared in a video call.")
        case .focus: String(localized: "Turns Do Not Disturb on or off.")
        case .brightness: String(localized: "Changes the display brightness.")
        case .volume: String(localized: "Changes the sound level.")
        case .note: String(localized: "Opens a Quick Note over the current app.")
        case .notifications: String(localized: "Opens Notification Centre and widgets.")
        case .forceQuit: String(localized: "Opens Force Quit so you can leave an unresponsive app.")
        case .apps: String(localized: "Switches apps or changes which windows are visible.")
        case .spotlight: String(localized: "Opens search over the current app.")
        case .siri: String(localized: "Starts Siri or voice input.")
        case .launchpad: String(localized: "Shows the app grid.")
        case .emoji: String(localized: "Opens the emoji and symbol picker.")
        case .dictionary: String(localized: "Looks up the word under the pointer.")
        case .keyboard: String(localized: "Moves keyboard focus between menus, controls and windows.")
        case .globe: String(localized: "Runs the macOS action assigned to the Globe key.")
        case .quit: String(localized: "Prevents an accidental quit shortcut from ending the game.")
        case .close: String(localized: "Prevents an accidental close shortcut from closing the game window.")
        case .click: String(localized: "Lets you hold Control and click without opening a context menu.")
        case .cursor: String(localized: "The Dock, menu bar and hot corners don’t pop up, and the pointer doesn’t slip onto another screen")
        case .display: String(localized: "The display doesn’t dim or sleep while you play")
        case .swipes: String(localized: "Keeps trackpad swipes from moving the game to another desktop.")
        case .dock: String(localized: "Shows or hides the Dock.")
        case .named: String(localized: "Runs the named macOS action. Keep it paused if it interrupts your game.")
        case .other: String(localized: "macOS provides the keys but doesn’t name this action. You can still choose how it behaves in games.")
        }
    }
}

extension GameRule {
    var detail: String? {
        switch self {
        case .appSwitcher, .hide, .siri, .swipes: nil
        default: description.text
        }
    }

    var description: GameShortcutDescription {
        switch self {
        case .commandQ: .quit
        case .commandW: .close
        case .appSwitcher, .hide: .apps
        case .spotlight: .spotlight
        case .siri: .siri
        case .launchpad: .launchpad
        case .missionControl, .appWindows, .showDesktop, .desktops, .desktopNumbers: .desktops
        case .swipes: .swipes
        case .emoji: .emoji
        case .lookUp: .dictionary
        case .focusKeys: .keyboard
        case .globe: .globe
        case .controlClick: .click
        case .cursor: .cursor
        case .display: .display
        }
    }
}

extension SystemGameShortcut {
    var anchor: String { "system-shortcut:\(id)" }

    var detail: String? {
        if let controller, controller.detail == nil { return nil }
        return switch description {
        case .dock, .brightness, .volume, .contrast, .invert, .captions, .focus, .siri, .screenshot, .named: nil
        default: description.text
        }
    }

    func explanation(for choice: GameShortcutMode, rules: Set<GameRule>) -> String {
        switch choice {
        case .automatic:
            switch mode(rules: rules, overrides: [:]) {
            case .background: String(localized: "A quick shortcut switches language without a menu. Holding game keys prevents accidental switching.")
            case .automatic, .pause: String(localized: "Game Mode pauses this action according to its general protection rules.")
            case .system: String(localized: "Your game rules allow this action. It works as configured in macOS.")
            }
        case .pause: String(localized: "This macOS action is disabled while the game is in front. When you leave, it works as before.")
        case .background: String(localized: "Every press switches language without the system menu. The same keys still reach the game.")
        case .system: String(localized: "macOS runs the action normally, even if it opens a window or takes focus from the game.")
        }
    }

    var displayName: String { SystemShortcutCatalog.nonempty(name) ?? String(localized: "System action \(String(id))") }

    var description: GameShortcutDescription {
        if rawName.lowercased().contains("dock hiding") { return .dock }
        if rawName.lowercased().contains("siri") { return .siri }
        switch kind {
        case .language: return .language
        case .window: return .windows
        case .screenshot, .selection: return .screenshot
        case .capturePanel: return .capture
        case .zoom: return .zoom
        case .contrast: return .contrast
        case .invert: return .invert
        case .voice: return .voice
        case .captions: return .captions
        case .presenter: return .presenter
        case .focusMode: return .focus
        case .brightness: return .brightness
        case .volume: return .volume
        case .note: return .note
        case .notifications: return .notifications
        case .forceQuit: return .forceQuit
        case .existing: return controller?.description ?? .other
        case .other: return SystemShortcutCatalog.nonempty(rawName) == nil ? .other : .named
        }
    }

    var group: GameShortcutGroup {
        if section == "screenshots" { return .screenshots }
        return switch description {
        case .language: .language
        case .windows, .apps, .launchpad, .forceQuit, .quit, .close: .windows
        case .desktops, .swipes: .desktops
        case .screenshot, .capture: .screenshots
        case .keyboard, .emoji, .dictionary, .globe, .click: .keyboard
        case .zoom, .contrast, .invert, .voice, .captions: .accessibility
        case .spotlight, .siri, .brightness, .volume, .note, .notifications, .focus, .presenter, .dock, .cursor, .display: .system
        case .named:
            switch section {
            case "windows", "applications": .windows
            case "universalaccess": .accessibility
            case "keyboardnavigation": .keyboard
            case "expose": .desktops
            default: .system
            }
        case .other: .other
        }
    }

}
