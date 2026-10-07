import AppKit
import Carbon
import IOKit.pwr_mgt
import SwiftUI

@Observable
final class GameModeTool: Tool {
    static let shared = GameModeTool()

    let id = "game-mode"
    let icon = "gamecontroller"
    var title: String { String(localized: "Game Mode") }
    let tab = SettingsTab.games

    private static let gamesKey = "game-mode-games"
    private static let notGamesKey = "game-mode-not-games"

    private(set) var isActive = false
    private(set) var game: NSRunningApplication?
    private(set) var suggestions: [String] = []
    var isPlaying: Bool { game != nil }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var blocksSearch: Bool {
        didSet { save(blocksSearch, "game-mode-search") }
    }

    var blocksSwitching: Bool {
        didSet { save(blocksSwitching, "game-mode-switching") }
    }

    var blocksQuit: Bool {
        didSet { save(blocksQuit, "game-mode-quit") }
    }

    var fencesCursor: Bool {
        didSet { save(fencesCursor, "game-mode-cursor") }
    }

    var keepsLayout: Bool {
        didSet { save(keepsLayout, "game-mode-layout") }
    }

    var keepsDisplayOn: Bool {
        didSet { save(keepsDisplayOn, "game-mode-display") }
    }

    var games: [String] {
        didSet {
            UserDefaults.standard.set(games, forKey: Self.gamesKey)
            suggestions.removeAll(where: games.contains)
            update()
        }
    }

    var notGames: [String] {
        didSet {
            UserDefaults.standard.set(notGames, forKey: Self.notGamesKey)
            suggestions.removeAll(where: notGames.contains)
        }
    }

    @ObservationIgnored fileprivate var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var tabs = DoublePress()
    @ObservationIgnored private var escaped: pid_t?
    @ObservationIgnored private var fence: CursorFence?
    @ObservationIgnored private var fenceTimer: Timer?
    @ObservationIgnored private var lockedLayout: String?
    @ObservationIgnored private var assertion: IOPMAssertionID?
    @ObservationIgnored private let trace = HotKeyTrace()

    private init() {
        let defaults = UserDefaults.standard
        isEnabled = defaults.bool(forKey: "game-mode")
        blocksSearch = defaults.object(forKey: "game-mode-search") as? Bool ?? true
        blocksSwitching = defaults.object(forKey: "game-mode-switching") as? Bool ?? true
        blocksQuit = defaults.object(forKey: "game-mode-quit") as? Bool ?? true
        fencesCursor = defaults.object(forKey: "game-mode-cursor") as? Bool ?? true
        keepsLayout = defaults.object(forKey: "game-mode-layout") as? Bool ?? true
        keepsDisplayOn = defaults.object(forKey: "game-mode-display") as? Bool ?? true
        games = defaults.stringArray(forKey: Self.gamesKey) ?? []
        notGames = defaults.stringArray(forKey: Self.notGamesKey) ?? []

        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didActivateApplicationNotification, NSWorkspace.didTerminateApplicationNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { _ in GameModeTool.shared.update() }
        }
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { _ in GameModeTool.shared.leave() }
        }
        let observer = Unmanaged.passUnretained(self).toOpaque()
        for name in ["com.apple.screenIsLocked", "com.apple.screenIsUnlocked", kTISNotifySelectedKeyboardInputSourceChanged as String] {
            CFNotificationCenterAddObserver(
                CFNotificationCenterGetDistributedCenter(), observer, gameModeNotification, name as CFString, nil, .deliverImmediately
            )
        }
    }

    func load() {
        let defaults = UserDefaults.standard
        blocksSearch = defaults.object(forKey: "game-mode-search") as? Bool ?? true
        blocksSwitching = defaults.object(forKey: "game-mode-switching") as? Bool ?? true
        blocksQuit = defaults.object(forKey: "game-mode-quit") as? Bool ?? true
        fencesCursor = defaults.object(forKey: "game-mode-cursor") as? Bool ?? true
        keepsLayout = defaults.object(forKey: "game-mode-layout") as? Bool ?? true
        keepsDisplayOn = defaults.object(forKey: "game-mode-display") as? Bool ?? true
        games = defaults.stringArray(forKey: Self.gamesKey) ?? []
        notGames = defaults.stringArray(forKey: Self.notGamesKey) ?? []
        isEnabled = defaults.bool(forKey: id)
    }

    var isDefault: Bool {
        !isEnabled && blocksSearch && blocksSwitching && blocksQuit && fencesCursor && keepsLayout && keepsDisplayOn
            && games.isEmpty && notGames.isEmpty
    }

    func reset() {
        isEnabled = false
        blocksSearch = true
        blocksSwitching = true
        blocksQuit = true
        fencesCursor = true
        keepsLayout = true
        keepsDisplayOn = true
        games = []
        notGames = []
    }

    var settingsView: AnyView {
        AnyView(GameModeSettings(tool: self))
    }

    func refresh() {
        leave()
        stopTap()
        if isEnabled { startTap() }
        update()
    }

    func confirm(_ key: String) {
        if !games.contains(key) { games.append(key) }
    }

    func dismiss(_ key: String) {
        if !notGames.contains(key) { notGames.append(key) }
    }

    func keepsOpen(_ app: NSRunningApplication) -> Bool {
        games.contains(Self.key(app)) || GameRules.launchers.contains(app.bundleIdentifier ?? "")
            || Self.looksLikeGame(app.bundleIdentifier, app.bundleURL ?? app.executableURL)
    }

    func refreshSuggestions() {
        let files = FileManager.default
        let home = files.homeDirectoryForCurrentUser
        let folders = [
            URL(fileURLWithPath: "/Applications"), URL(fileURLWithPath: "/System/Applications"),
            home.appendingPathComponent("Applications"),
            home.appendingPathComponent("Library/Application Support/Steam/steamapps/common"),
        ]
        let contents = { (url: URL) in (try? files.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? [] }
        let bundles = folders.flatMap(contents).flatMap { $0.pathExtension == "app" ? [$0] : contents($0).filter { $0.pathExtension == "app" } }
        let installed = bundles.compactMap { url -> String? in
            let id = Bundle(url: url)?.bundleIdentifier
            return Self.looksLikeGame(id, url) ? id : nil
        }
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && Self.looksLikeGame($0.bundleIdentifier, $0.bundleURL ?? $0.executableURL) }
            .map(Self.key)
        var seen = Set(games + notGames + [""])
        suggestions = (running + installed).filter { seen.insert($0).inserted }
    }

    fileprivate func update() {
        let app = NSWorkspace.shared.frontmostApplication
        if app?.processIdentifier != escaped { escaped = nil }
        guard isEnabled, let app, escaped == nil, games.contains(Self.key(app)), !Self.screenLocked else { return leave() }
        guard app.processIdentifier != game?.processIdentifier else { return }
        leave()
        enter(app)
    }

    private func enter(_ app: NSRunningApplication) {
        game = app
        trace.disable(GameRules.hotKeys(search: blocksSearch, switching: blocksSwitching, layout: keepsLayout, appSwitcher: tap != nil))
        if fencesCursor || blocksSwitching { moveFence() }
        if fencesCursor {
            fenceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in GameModeTool.shared.moveFence() }
        }
        if keepsLayout { lockedLayout = Self.currentLayout }
        if keepsDisplayOn {
            var id = IOPMAssertionID(0)
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), "pika-tools Game Mode" as CFString, &id
            )
            if result == kIOReturnSuccess { assertion = id }
        }
        refreshCommandKeys()
    }

    func leave() {
        fenceTimer?.invalidate()
        fenceTimer = nil
        fence?.stop()
        fence = nil
        lockedLayout = nil
        if let assertion { IOPMAssertionRelease(assertion) }
        assertion = nil
        trace.restore()
        guard game != nil else { return }
        game = nil
        refreshCommandKeys()
    }

    fileprivate func escape(shift: Bool) {
        guard let game else { return }
        escaped = game.processIdentifier
        leave()
        let source = CGEventSource(stateID: .hidSystemState)
        for down in [true, false] {
            let press = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Tab), keyDown: down)
            press?.flags = shift ? [.maskCommand, .maskShift] : .maskCommand
            press?.post(tap: .cghidEventTap)
        }
    }

    fileprivate func received(_ name: String) {
        switch name {
        case "com.apple.screenIsLocked":
            leave()
        case "com.apple.screenIsUnlocked":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.update() }
        default:
            guard let id = GameRules.layoutToRestore(locked: lockedLayout, current: Self.currentLayout),
                  let source = (TISCreateInputSourceList([kTISPropertyInputSourceID: id] as CFDictionary, false)?
                      .takeRetainedValue() as? [TISInputSource])?.first
            else { return }
            TISSelectInputSource(source)
        }
    }

    private func moveFence() {
        guard let game else { return }
        let frame = fencesCursor ? Self.screen(of: game.processIdentifier) ?? fence?.frame : nil
        guard fence == nil || fence?.frame != frame else { return }
        fence?.stop()
        fence = CursorFence(frame: frame, dropsSwipes: blocksSwitching)
    }

    private func save(_ value: Bool, _ key: String) {
        UserDefaults.standard.set(value, forKey: key)
        leave()
        update()
    }

    private func refreshCommandKeys() {
        ToolRegistry.shared.tools.forEach { ($0 as? CommandKeysTool)?.refresh() }
    }

    private func startTap() {
        let types: [CGEventType] = [.keyDown, .keyUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: gameModeCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        isActive = true
    }

    private func stopTap() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        isActive = false
    }

    static func key(_ app: NSRunningApplication) -> String {
        app.bundleIdentifier ?? app.localizedName ?? ""
    }

    private static func looksLikeGame(_ id: String?, _ url: URL?) -> Bool {
        let info = url.flatMap { NSDictionary(contentsOf: $0.appendingPathComponent("Contents/Info.plist")) }
        return GameRules.looksLikeGame(
            id: id,
            category: info?["LSApplicationCategoryType"] as? String,
            supportsGameMode: info?["LSSupportsGameMode"] as? Bool ?? false,
            path: url?.path ?? ""
        )
    }

    private static var screenLocked: Bool {
        let session = CGSessionCopyCurrentDictionary() as? [String: Any]
        return session?["CGSSessionScreenIsLocked"] as? Bool == true || session?[kCGSessionOnConsoleKey] as? Bool == false
    }

    private static var currentLayout: String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        return InputSwitchTool.string(source, kTISPropertyInputSourceID)
    }

    private static func screen(of pid: pid_t) -> CGRect? {
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        let windows = list.compactMap { info -> CGRect? in
            guard info[kCGWindowOwnerPID as String] as? pid_t == pid,
                  info[kCGWindowLayer as String] as? Int == 0,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary
            else { return nil }
            return CGRect(dictionaryRepresentation: bounds)
        }
        guard let window = windows.max(by: { $0.width * $0.height < $1.width * $1.height }) else { return nil }
        var display = CGDirectDisplayID(0)
        var count: UInt32 = 0
        CGGetDisplaysWithPoint(CGPoint(x: window.midX, y: window.midY), 1, &display, &count)
        return count > 0 ? CGDisplayBounds(display) : nil
    }
}

private final class CursorFence {
    let frame: CGRect?
    let dropsSwipes: Bool
    fileprivate private(set) var tap: CFMachPort?
    private var loop: CFRunLoop?

    init(frame: CGRect?, dropsSwipes: Bool) {
        self.frame = frame
        self.dropsSwipes = dropsSwipes
        let moves: [CGEventType] = frame == nil ? [] : [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        let mask = moves.reduce(CGEventMask(dropsSwipes ? 1 << 30 : 0)) { $0 | (1 << $1.rawValue) }
        guard mask != 0 else { return }
        let ready = DispatchSemaphore(value: 0)
        let thread = Thread { [self] in
            if let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: mask,
                callback: cursorFenceCallback,
                userInfo: Unmanaged.passUnretained(self).toOpaque()
            ) {
                CFRunLoopAddSource(CFRunLoopGetCurrent(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
                self.tap = tap
                loop = CFRunLoopGetCurrent()
            }
            ready.signal()
            if tap != nil { CFRunLoopRun() }
        }
        thread.qualityOfService = .userInteractive
        thread.start()
        ready.wait()
    }

    func stop() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let loop { CFRunLoopStop(loop) }
    }
}

private func gameModeNotification(
    center: CFNotificationCenter?,
    observer: UnsafeMutableRawPointer?,
    name: CFNotificationName?,
    object: UnsafeRawPointer?,
    userInfo: CFDictionary?
) {
    guard let observer, let name else { return }
    Unmanaged<GameModeTool>.fromOpaque(observer).takeUnretainedValue().received(name.rawValue as String)
}

private func gameModeCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<GameModeTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let tap = tool.tap { CGEvent.tapEnable(tap: tap, enable: true) }
    case .keyDown, .keyUp:
        let key = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        guard tool.isPlaying, tool.blocksSwitching, flags.contains(.maskCommand), !flags.contains(.maskControl),
              [kVK_Tab, kVK_ANSI_H, kVK_ANSI_M].contains(key)
        else { break }
        if type == .keyDown, key == kVK_Tab, event.getIntegerValueField(.keyboardEventAutorepeat) == 0,
           tool.tabs.press(at: TimeInterval(event.timestamp) / 1_000_000_000) {
            DispatchQueue.main.async { tool.escape(shift: flags.contains(.maskShift)) }
        }
        return nil
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private func cursorFenceCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let fence = Unmanaged<CursorFence>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let tap = fence.tap { CGEvent.tapEnable(tap: tap, enable: true) }
    case .mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
        if let frame = fence.frame, let point = GameRules.fence(event.location, in: frame) {
            event.location = point
            CGWarpMouseCursorPosition(point)
        }
    default:
        if fence.dropsSwipes, type.rawValue == 30,
           event.getIntegerValueField(CGEventField(rawValue: 110)!) == 23,
           event.getIntegerValueField(CGEventField(rawValue: 123)!) == 1 {
            return nil
        }
    }
    return Unmanaged.passUnretained(event)
}

private struct GameModeSettings: View {
    @Bindable var tool: GameModeTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Your Mac doesn’t pull you out of a game"),
            hint: Text("Your Mac doesn’t pull you out of a game"),
            help: Text("To leave a game, press ⌘Tab twice quickly. ⌥⌘Esc always works."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Group {
                ToggleRow(
                    icon: "magnifyingglass",
                    title: String(localized: "Search and Siri"),
                    subtitle: Text("Spotlight, Siri and the 🌐 key don’t open on top of the game"),
                    isOn: $tool.blocksSearch
                )
                ToggleRow(
                    icon: "rectangle.on.rectangle",
                    title: String(localized: "Other apps and desktops"),
                    subtitle: Text("⌘Tab, ⌘H, ⌘M, Mission Control, desktops and swipes don’t take you out of the game"),
                    isOn: $tool.blocksSwitching
                )
                ToggleRow(
                    icon: "xmark.app",
                    title: String(localized: "The game doesn’t close by accident"),
                    subtitle: Text("⌘Q and ⌘W don’t work in the game. To quit, press ⇧⌘Q"),
                    isOn: $tool.blocksQuit
                )
                ToggleRow(
                    icon: "cursorarrow.rays",
                    title: String(localized: "The pointer stays in the game"),
                    subtitle: Text("The Dock, menu bar and hot corners don’t pop up, and the pointer doesn’t slip onto another screen"),
                    isOn: $tool.fencesCursor
                )
                ToggleRow(
                    icon: "globe",
                    title: String(localized: "The keyboard language doesn’t change"),
                    subtitle: Text("If it switches by accident, it comes back right away"),
                    isOn: $tool.keepsLayout
                )
                ToggleRow(
                    icon: "sun.max",
                    title: String(localized: "The screen stays on"),
                    subtitle: Text("The display doesn’t dim or sleep while you play"),
                    isOn: $tool.keepsDisplayOn
                )
            }
            .disabled(!tool.isEnabled)
            AppExclusions(title: String(localized: "Your games"), apps: $tool.games, isEnabled: tool.isEnabled, addsRunning: true)
                .onAppear { tool.refreshSuggestions() }
            ForEach(tool.suggestions, id: \.self) { key in
                LabeledContent {
                    HStack {
                        Button("Not a Game") { tool.dismiss(key) }
                        Button("Add") { tool.confirm(key) }
                    }
                } label: {
                    AppLabel(id: key, subtitle: Text("Looks like a game"))
                }
            }
        }
    }
}
