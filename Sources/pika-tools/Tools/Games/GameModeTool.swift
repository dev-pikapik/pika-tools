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
    private static let systemShortcutsKey = "game-mode-system-shortcuts"
    private static let frameRateKey = "game-mode-fps"
    private static let frameRateCornerKey = "game-mode-fps-corner"
    private static let frameRateRecordingKey = "game-mode-fps-recording"

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

    var rules: Set<GameRule> {
        didSet {
            GameRule.allCases.filter { rules.contains($0) != oldValue.contains($0) }
                .forEach { UserDefaults.standard.set(rules.contains($0), forKey: $0.key) }
            leave()
            update()
        }
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

    var systemShortcuts: [String] {
        didSet {
            UserDefaults.standard.set(systemShortcuts, forKey: Self.systemShortcutsKey)
            leave()
            update()
        }
    }

    var showsFrameRate: Bool {
        didSet {
            UserDefaults.standard.set(showsFrameRate, forKey: Self.frameRateKey)
            syncFrameRate()
        }
    }

    var frameRateCorner: FrameRateCorner {
        didSet {
            UserDefaults.standard.set(frameRateCorner.rawValue, forKey: Self.frameRateCornerKey)
            syncFrameRate()
        }
    }

    var needsRecording: Bool {
        didSet { UserDefaults.standard.set(needsRecording, forKey: Self.frameRateRecordingKey) }
    }

    func setSystemShortcut(_ id: Int32, mode: GameShortcutMode) {
        systemShortcuts = systemShortcuts.filter { $0.split(separator: ":").first != Substring(String(id)) }
            + (mode == .automatic ? [] : ["\(id):\(mode.rawValue)"])
    }

    @ObservationIgnored fileprivate var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var combos: Set<UInt64> = []
    @ObservationIgnored private var hinted = false
    @ObservationIgnored private var fence: CursorFence?
    @ObservationIgnored private var fenceTimer: Timer?
    @ObservationIgnored private var swipes: (blocksAll: Bool, except: Set<Int64>, corners: Set<Int>) = (false, [], [])
    @ObservationIgnored private var assertion: IOPMAssertionID?
    @ObservationIgnored private let trace = HotKeyTrace()
    @ObservationIgnored fileprivate var languageBindings: [UInt64: (direction: InputSwitchGesture.Direction, automatic: Bool)] = [:]
    @ObservationIgnored fileprivate var inputIntent = GameInputIntent()
    @ObservationIgnored fileprivate var allowedAppShortcuts: Set<UInt64> = []

    func allowsLanguageGesture(flags: CGEventFlags, at time: UInt64) -> Bool {
        inputIntent.allowsGesture(flags: flags, at: time)
    }

    private init() {
        let defaults = UserDefaults.standard
        GameRules.migrateControl(defaults)
        GameRules.migrateGroups(defaults)
        isEnabled = defaults.bool(forKey: "game-mode")
        rules = Self.savedRules
        games = defaults.stringArray(forKey: Self.gamesKey) ?? []
        notGames = defaults.stringArray(forKey: Self.notGamesKey) ?? []
        systemShortcuts = defaults.stringArray(forKey: Self.systemShortcutsKey) ?? []
        showsFrameRate = defaults.bool(forKey: Self.frameRateKey)
        frameRateCorner = Self.savedCorner
        needsRecording = defaults.bool(forKey: Self.frameRateRecordingKey)

        let center = NSWorkspace.shared.notificationCenter
        for name in [
            NSWorkspace.didActivateApplicationNotification, NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification,
        ] {
            center.addObserver(forName: name, object: nil, queue: .main) { _ in GameModeTool.shared.update() }
        }
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { _ in GameModeTool.shared.leave() }
        }
        let observer = Unmanaged.passUnretained(self).toOpaque()
        for name in ["com.apple.screenIsLocked", "com.apple.screenIsUnlocked"] {
            CFNotificationCenterAddObserver(
                CFNotificationCenterGetDistributedCenter(), observer, gameModeNotification, name as CFString, nil, .deliverImmediately
            )
        }
    }

    func load() {
        let defaults = UserDefaults.standard
        rules = Self.savedRules
        games = defaults.stringArray(forKey: Self.gamesKey) ?? []
        notGames = defaults.stringArray(forKey: Self.notGamesKey) ?? []
        systemShortcuts = defaults.stringArray(forKey: Self.systemShortcutsKey) ?? []
        showsFrameRate = defaults.bool(forKey: Self.frameRateKey)
        frameRateCorner = Self.savedCorner
        isEnabled = defaults.bool(forKey: id)
        if game == nil { DockEdges.restore() }
    }

    var isDefault: Bool {
        !isEnabled && rules.count == GameRule.allCases.count && games.isEmpty && notGames.isEmpty && systemShortcuts.isEmpty
            && !showsFrameRate && frameRateCorner == .standard
    }

    func reset() {
        isEnabled = false
        rules = Set(GameRule.allCases)
        games = []
        notGames = []
        systemShortcuts = []
        showsFrameRate = false
        frameRateCorner = .standard
    }

    var settingsView: AnyView {
        AnyView(GameModeSettings(tool: self))
    }

    func refresh() {
        leave()
        stopTap()
        if isEnabled, AXIsProcessTrusted() { startTap() }
        update()
    }

    func confirm(_ key: String) {
        if !games.contains(key) { games.append(key) }
    }

    func add(_ url: URL) {
        Self.key(url).map(confirm)
    }

    static func choose() -> [URL] {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowsMultipleSelection = true
        panel.prompt = String(localized: "Add")
        NSApp.bringForward()
        return panel.runModal() == .OK ? panel.urls.filter { key($0) != nil } : []
    }

    func dismiss(_ key: String) {
        if !notGames.contains(key) { notGames.append(key) }
    }

    func keepsOpen(_ app: NSRunningApplication) -> Bool {
        games.contains(Self.key(app)) || isGame(app) || GameRules.launchers.contains(app.bundleIdentifier ?? "")
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
            return Self.looksLikeGame(id, url) || id == "com.mojang.minecraftlauncher" ? id : nil
        }
        let running = AppShelf.windowed
            .filter { Self.looksLikeGame($0.bundleIdentifier, $0.bundleURL ?? $0.executableURL)
                || GameRules.minecraft($0.executableURL?.path ?? "") != nil }
            .map(Self.key)
        var seen = Set(games + notGames + [""])
        suggestions = (running + installed).filter { seen.insert($0).inserted }
    }

    fileprivate func update() {
        let app = NSWorkspace.shared.frontmostApplication
        if let app {
            let upgraded = GameRules.upgraded(games, id: app.bundleIdentifier, name: app.localizedName, path: app.executableURL?.path ?? "")
            if upgraded != games { return games = upgraded }
        }
        guard isEnabled, let app, isGame(app), !Self.screenLocked else { return leave() }
        guard app.processIdentifier != game?.processIdentifier else { return }
        leave()
        enter(app)
    }

    private func enter(_ app: NSRunningApplication) {
        game = app
        let catalog = SystemShortcutCatalog.load()
        trace.disable(SystemShortcutCatalog.selected(catalog, rules: rules, values: systemShortcuts, appSwitcher: tap != nil))
        languageBindings = tap == nil ? [:] : SystemShortcutCatalog.languageBindings(catalog, rules: rules, values: systemShortcuts, disabled: Set(HotKeyTrace.ids(trace.defaults) ?? []))
        let choices = SystemGameShortcut.overrides(systemShortcuts)
        allowedAppShortcuts = Set(catalog.filter { $0.assigned && $0.mode(rules: rules, overrides: choices) == .system }.map { GameRules.combo(key: Int64($0.key), flags: $0.modifiers) })
        inputIntent = GameInputIntent(held: Set((0..<128).filter { ![54, 55, 56, 57, 58, 59, 60, 61, 62, 63].contains($0) && CGEventSource.keyState(.combinedSessionState, key: CGKeyCode($0)) }.map(Int64.init)))
        let pointerIDs = Set(catalog.filter { $0.pointer != nil }.map(\.id))
        combos = Set(
            (HotKeyTrace.ids(trace.defaults) ?? []).filter { !pointerIDs.contains($0) }.compactMap(SymbolicHotKeys.value)
                .filter { !GameRules.isGameInput($0.modifiers) && languageBindings[GameRules.combo(key: Int64($0.key), flags: $0.modifiers)] == nil }.map { GameRules.combo(key: Int64($0.key), flags: $0.modifiers) }
        )
        hinted = false
        let paused = PointerShortcuts.paused(catalog, rules: rules, values: systemShortcuts)
        swipes = (paused.blocksAll, paused.except, Set(PointerShortcuts.sides.indices).subtracting(paused.corners))
        if rules.contains(.cursor) || paused.blocksAll || !paused.except.isEmpty { moveFence() }
        DockEdges.calm(corners: paused.corners, hidesDock: rules.contains(.cursor))
        if rules.contains(.cursor) {
            fenceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in GameModeTool.shared.moveFence() }
        }
        if rules.contains(.display) {
            var id = IOPMAssertionID(0)
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), "pikapik Game Mode" as CFString, &id
            )
            if result == kIOReturnSuccess { assertion = id }
        }
        refreshCommandKeys()
        syncFrameRate()
    }

    func leave() {
        fenceTimer?.invalidate()
        fenceTimer = nil
        fence?.stop()
        fence = nil
        swipes = (false, [], [])
        DockEdges.restoreSoon()
        combos = []
        languageBindings = [:]
        inputIntent = GameInputIntent()
        allowedAppShortcuts = []
        if let assertion { IOPMAssertionRelease(assertion) }
        assertion = nil
        trace.restore()
        guard game != nil else { return }
        game = nil
        syncFrameRate()
        refreshCommandKeys()
    }

    private func syncFrameRate() {
        if showsFrameRate, let game {
            FrameRateMeter.shared.show(game.processIdentifier, corner: frameRateCorner)
        } else {
            FrameRateMeter.shared.hide()
        }
    }

    func hint() {
        guard isPlaying, !hinted else { return }
        hinted = true
        DispatchQueue.main.async { GameHint.show() }
    }

    func received(_ name: String) {
        #if APPSTORE
        Self.locked = name == "com.apple.screenIsLocked"
        #endif
        if name == "com.apple.screenIsLocked" {
            leave()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.update() }
        }
    }

    private func moveFence() {
        guard let game else { return }
        let frame = rules.contains(.cursor) ? Self.screen(of: game.processIdentifier) ?? fence?.frame : nil
        guard fence == nil || fence?.frame != frame else { return }
        fence?.stop()
        fence = CursorFence(frame: frame, blocksAll: swipes.blocksAll, except: swipes.except, corners: swipes.corners)
    }

    private func refreshCommandKeys() {
        ToolRegistry.shared.tools.forEach { ($0 as? CommandKeysTool)?.refresh() }
    }

    private func startTap() {
        let types: [CGEventType] = [.keyDown, .keyUp, .flagsChanged, .leftMouseDown, .leftMouseUp, .leftMouseDragged]
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
        GameRules.rule(id: app.bundleIdentifier, name: app.localizedName, path: app.executableURL?.path ?? "")
    }

    static func processFiles(_ text: String) -> [URL] {
        GameRules.processIDs(text) { pid in
            guard let app = NSRunningApplication(processIdentifier: pid), !app.isTerminated else { return [] }
            return [app.localizedName, app.executableURL?.lastPathComponent].compactMap { $0 }
        }.compactMap { NSRunningApplication(processIdentifier: $0)?.executableURL }
    }

    static func key(_ url: URL) -> String? {
        if let app = NSWorkspace.shared.runningApplications.first(where: { $0.bundleURL?.path == url.path || $0.executableURL?.path == url.path }) {
            return key(app)
        }
        if url.pathExtension == "app", let bundle = Bundle(url: url) {
            return GameRules.rule(id: bundle.bundleIdentifier, name: FileManager.default.displayName(atPath: url.path), path: bundle.executableURL?.path ?? "")
        }
        let file = (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
        return file && FileManager.default.isExecutableFile(atPath: url.path) ? GameRules.rule(id: nil, name: url.lastPathComponent, path: url.path) : nil
    }

    private func isGame(_ app: NSRunningApplication) -> Bool {
        GameRules.isGame(id: app.bundleIdentifier, name: app.localizedName, path: app.executableURL?.path ?? "", in: games)
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

    #if APPSTORE
    private static var locked = false
    #endif

    static var screenLocked: Bool {
        let session = CGSessionCopyCurrentDictionary() as? [String: Any]
        #if APPSTORE
        return locked || session?[kCGSessionOnConsoleKey] as? Bool == false
        #else
        return session?["CGSSessionScreenIsLocked"] as? Bool == true || session?[kCGSessionOnConsoleKey] as? Bool == false
        #endif
    }

    private static var savedRules: Set<GameRule> {
        Set(GameRule.allCases.filter { UserDefaults.standard.object(forKey: $0.key) as? Bool ?? true })
    }

    private static var savedCorner: FrameRateCorner {
        FrameRateCorner(rawValue: UserDefaults.standard.string(forKey: frameRateCornerKey) ?? "") ?? .standard
    }

    static func window(of pid: pid_t) -> (id: CGWindowID, frame: CGRect)? {
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        let windows = list.compactMap { info -> (id: CGWindowID, frame: CGRect)? in
            guard info[kCGWindowOwnerPID as String] as? pid_t == pid,
                  info[kCGWindowLayer as String] as? Int == 0,
                  let id = info[kCGWindowNumber as String] as? CGWindowID,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary,
                  let frame = CGRect(dictionaryRepresentation: bounds)
            else { return nil }
            return (id, frame)
        }
        return windows.max(by: { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height })
    }

    // The display that shows the largest part of the window, so a window half off the screen keeps its display.
    static func display(of window: CGRect) -> CGDirectDisplayID? {
        var displays = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetDisplaysWithRect(window, 16, &displays, &count)
        return displays.prefix(Int(count)).max { a, b in
            let x = CGDisplayBounds(a).intersection(window), y = CGDisplayBounds(b).intersection(window)
            return x.width * x.height < y.width * y.height
        }
    }

    private static func screen(of pid: pid_t) -> CGRect? {
        guard let window = window(of: pid)?.frame, let display = display(of: window) else { return nil }
        return CGDisplayBounds(display)
    }
}

extension GameRules {
    #if APPSTORE
    // The App Store copy can't switch hot corners off, so the fence keeps the pointer this far (x + y) from every corner pixel.
    static let cornerGap: CGFloat = 16
    #else
    static let cornerGap: CGFloat = 0
    #endif

    static func fenceCorners(_ point: CGPoint, in frame: CGRect, corners: Set<Int> = []) -> CGPoint? {
        var fenced = fence(point, in: frame, corners: corners) ?? point
        for corner in 0..<4 where !corners.contains(corner) {
            let sx: CGFloat = corner % 2 == 0 ? 1 : -1, sy: CGFloat = corner < 2 ? 1 : -1
            let gap = (fenced.x - (sx > 0 ? frame.minX : frame.maxX - 1)) * sx + (fenced.y - (sy > 0 ? frame.minY : frame.maxY - 1)) * sy
            guard gap < cornerGap else { continue }
            fenced.x += (cornerGap - gap) / 2 * sx
            fenced.y += (cornerGap - gap) / 2 * sy
        }
        return fenced == point ? nil : fenced
    }
}

#if APPSTORE
// Dock preferences are out of reach in the sandbox; GameRules.fenceCorners keeps hot corners quiet instead.
enum DockEdges {
    static var journal: [String: Any] { [:] }
    static func calm(corners: Set<Int>, hidesDock: Bool) {}
    static func restoreSoon() {}
    static func restore() {}
}
#else
enum DockEdges {
    private static let key = "game-mode-dock", dock = "com.apple.dock" as CFString
    private static let corners = ["wvous-tl-corner", "wvous-tr-corner", "wvous-bl-corner", "wvous-br-corner"], delay = "autohide-delay"
    private static var pending: DispatchWorkItem?

    static var journal: [String: Any] { UserDefaults.standard.dictionary(forKey: key) ?? [:] }

    static func calm(corners wanted: Set<Int>, hidesDock: Bool) {
        pending?.cancel()
        pending = nil
        CFPreferencesAppSynchronize(dock)
        let saved = journal
        func current(_ name: String) -> Int { ((saved[name] ?? CFPreferencesCopyAppValue(name as CFString, dock) as Any?) as? NSNumber)?.intValue ?? 0 }
        let active = wanted.sorted().map { corners[$0] }.filter { current($0) > 1 }
        let hides = hidesDock && CFPreferencesGetAppBooleanValue("autohide" as CFString, dock, nil)
        let targets = active + (hides ? [delay] : [])
        if !saved.isEmpty {
            guard Set(saved.keys) != Set(targets) else { return }
            let wrote = reset()
            if targets.isEmpty {
                if wrote { relaunch() }
                return
            }
        }
        guard !targets.isEmpty else { return }
        var original: [String: Any] = [:]
        for name in targets { original[name] = CFPreferencesCopyAppValue(name as CFString, dock) ?? "" }
        UserDefaults.standard.set(original, forKey: key)
        for name in active { CFPreferencesSetAppValue(name as CFString, 0 as CFNumber, dock) }
        if hides { CFPreferencesSetAppValue(delay as CFString, 1000.0 as CFNumber, dock) }
        relaunch()
    }

    static func restoreSoon() {
        guard UserDefaults.standard.dictionary(forKey: key) != nil, pending == nil else { return }
        let work = DispatchWorkItem { restore() }
        pending = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: work)
    }

    static func restore() {
        pending?.cancel()
        pending = nil
        guard !journal.isEmpty, reset() else { return }
        relaunch()
    }

    static func restorable(_ saved: [String: Any], current: (String) -> Any?) -> [String: Any] {
        saved.filter { name, _ in (current(name) as? NSNumber)?.doubleValue == (name == delay ? 1000.0 : 0.0) }
    }

    private static func reset() -> Bool {
        CFPreferencesAppSynchronize(dock)
        let saved = journal
        UserDefaults.standard.removeObject(forKey: key)
        let ours = restorable(saved) { CFPreferencesCopyAppValue($0 as CFString, dock) }
        for (name, original) in ours {
            let value = original as? String == "" ? nil : original as CFPropertyList
            CFPreferencesSetAppValue(name as CFString, value, dock)
        }
        return !ours.isEmpty
    }

    private static func relaunch() {
        CFPreferencesAppSynchronize(dock)
        _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/killall"), arguments: ["Dock"])
    }
}
#endif

private final class CursorFence {
    let frame: CGRect?
    let blocksAll: Bool
    let except: Set<Int64>
    let corners: Set<Int>
    fileprivate var holding: Bool?
    fileprivate private(set) var tap: CFMachPort?
    private var loop: CFRunLoop?

    init(frame: CGRect?, blocksAll: Bool, except: Set<Int64>, corners: Set<Int>) {
        self.frame = frame
        self.blocksAll = blocksAll
        self.except = except
        self.corners = corners
        let moves: [CGEventType] = frame == nil ? [] : [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        let mask = moves.reduce(CGEventMask(blocksAll || !except.isEmpty ? 1 << 30 : 0)) { $0 | (1 << $1.rawValue) }
        guard mask != 0, AXIsProcessTrusted() else { return }
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

private enum GameHint {
    private static var panel: NSPanel?

    static func show() {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }) ?? NSScreen.main else { return }
        let view = NSHostingView(rootView: Text("To leave the game, press \(CommandKeysTool.quit.text)")
            .font(.title3.weight(.medium))
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 22)
            .padding(12))
        let size = view.fittingSize
        let panel = panel ?? NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = view
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: screen.visibleFrame.maxY - size.height, width: size.width, height: size.height), display: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        self.panel = panel
        let fade = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.3
        panel.alphaValue = fade == 0 ? 1 : 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { $0.duration = fade; panel.animator().alphaValue = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NSAnimationContext.runAnimationGroup { $0.duration = fade; panel.animator().alphaValue = 0 } completionHandler: { panel.orderOut(nil) }
        }
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
        guard tool.isPlaying else { break }
        if type == .keyDown, event.getIntegerValueField(.keyboardEventAutorepeat) == 0 {
            let combo = GameRules.combo(key: Int64(key), flags: flags.rawValue)
            if let binding = tool.languageBindings[combo], !event.isPikapik, !binding.automatic || tool.inputIntent.allows(Int64(key), flags: flags, at: event.timestamp) {
                event.markPikapik()
                let pid = tool.game?.processIdentifier
                DispatchQueue.main.async {
                    guard tool.game?.processIdentifier == pid, NSWorkspace.shared.frontmostApplication?.processIdentifier == pid, tool.languageBindings[combo] != nil else { return }
                    InputSwitchTool.selectInGame(binding.direction)
                }
            }
        }
        tool.inputIntent.pressed(Int64(key), down: type == .keyDown)
        let blocked = GameRules.blocksAppShortcut(key: key, flags: flags, rules: tool.rules, allowed: tool.allowedAppShortcuts)
        if type == .keyDown, blocked || tool.combos.contains(GameRules.combo(key: Int64(key), flags: flags.rawValue)) { tool.hint() }
        if blocked { return nil }
        #if APPSTORE
        if SymbolicHotKeys.swallows(key: key, flags: flags.rawValue) { return nil }
        #endif
    case .flagsChanged:
        if tool.isPlaying { tool.inputIntent.changed(event.flags, at: event.timestamp) }
    case .leftMouseDown, .leftMouseUp, .leftMouseDragged:
        event.flags = GameRules.clickFlags(type, event.flags, playing: tool.isPlaying, blocksControl: tool.rules.contains(.controlClick))
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
        if let frame = fence.frame, let point = GameRules.fenceCorners(event.location, in: frame, corners: fence.corners) {
            event.location = point
            CGEventSource(stateID: .combinedSessionState)?.localEventsSuppressionInterval = 0
            CGWarpMouseCursorPosition(point)
        }
    default:
        if type.rawValue == 30, event.getIntegerValueField(CGEventField(rawValue: 110)!) == 23 {
            let gate = GameRules.dropsSwipe(
                phase: event.getIntegerValueField(CGEventField(rawValue: 132)!),
                motion: event.getIntegerValueField(CGEventField(rawValue: 123)!),
                blocksAll: fence.blocksAll, except: fence.except, holding: fence.holding
            )
            fence.holding = gate.holding
            if gate.drops { return nil }
        }
    }
    return Unmanaged.passUnretained(event)
}

struct GameModePage: View {
    @Bindable private var tool = GameModeTool.shared
    @State private var advanced = false
    @State private var safeguards = false

    var body: some View {
        Form {
            SettingsHeader(
                tab: .games,
                text: tool.game.map { String(localized: "Now playing: \($0.title)") } ?? String(localized: "Play without interruptions")
            )
            Section {
                GameModeArt(on: tool.isEnabled)
                tool.settingsView
            }
            Section {
                Group {
                    GameList(tool: tool)
                        .onAppear { tool.refreshSuggestions() }
                    ForEach(tool.suggestions, id: \.self) { key in
                        LabeledContent {
                            HStack {
                                Button("Not a Game") { tool.dismiss(key) }
                                Button("Add") { tool.confirm(key) }
                            }
                            .fixedSize()
                        } label: {
                            AppLabel(id: key, subtitle: Text("Looks like a game"))
                        }
                    }
                }
                .appDropZone("games", accepting: { GameModeTool.key($0) != nil }, textFiles: GameModeTool.processFiles) { tool.add($0) }
            } footer: {
                Text("You can also drag a game here from Finder")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            FrameRateSettings(tool: tool)
            Section {
                DisclosureGroup(isExpanded: $advanced) {
                    EmptyView()
                } label: {
                    GameDisclosureLabel(title: String(localized: "More game settings"), detail: String(localized: "Fine-tune protection and explore your Mac’s shortcuts."), symbol: "slider.horizontal.3")
                }
                .disclosureGroupStyle(GameDisclosureStyle(contentSpacing: 0))
            }
            if advanced {
                SystemShortcutList(tool: tool)
                Section {
                    DisclosureGroup(isExpanded: $safeguards) {
                        Text("To leave a game, press \(CommandKeysTool.quit.text); to close its window, \(CommandKeysTool.close.text). ⌥⌘Esc always works.").font(.subheadline).foregroundStyle(.secondary)
                    } label: {
                        GameDisclosureLabel(title: String(localized: "Game safeguards"), detail: String(localized: "Closing the game, the pointer and display."), symbol: "shield", count: GameRule.allCases.count)
                    }
                    .disclosureGroupStyle(GameDisclosureStyle())
                    .settingAnchor(String(localized: "Game safeguards"))
                }
                if safeguards {
                    rules(Text("Closing the game"), [
                        Rule(.commandQ, String(localized: "The game doesn’t close"), ["⌘Q"]),
                        Rule(.commandW, String(localized: "The game window doesn’t close"), ["⌘W"]),
                    ], footer: Text("To leave a game, press \(CommandKeysTool.quit.text); to close its window, \(CommandKeysTool.close.text). ⌥⌘Esc always works."))
                    rules(Text("Apps"), [
                        Rule(.appSwitcher, String(localized: "Apps and windows don’t switch"), ["⌘Tab", key(27, "⌘`")]),
                        Rule(.hide, String(localized: "The game doesn’t hide"), ["⌘H", key(233, "⌘M")]),
                        Rule(.spotlight, String(localized: "Search doesn’t pop up"), [key(64, "⌘" + String(localized: "Space"))], subtitle: Text("Spotlight")),
                        Rule(.siri, String(localized: "Siri and voice typing don’t start"), [key(186, "🎤")]),
                        Rule(.launchpad, String(localized: "The app grid doesn’t open"), [key(173, "F4")], subtitle: Text("Launchpad")),
                    ])
                    rules(Text("Desktops"), [
                        Rule(.missionControl, String(localized: "The view of all windows doesn’t open"), [key(32, "⌃↑")], subtitle: Text("Mission Control")),
                        Rule(.appWindows, String(localized: "The view of the game’s windows doesn’t open"), [key(33, "⌃↓")], subtitle: Text("App Exposé")),
                        Rule(.showDesktop, String(localized: "The game doesn’t slide off the screen"), [key(36, "F11")], subtitle: Text("Show Desktop")),
                        Rule(.desktops, String(localized: "Desktops don’t switch"), [key(79, "⌃←"), key(81, "⌃→")]),
                        Rule(.desktopNumbers, String(localized: "Desktops don’t switch by number"), [key(118, "⌃1"), "…"]),
                    ])
                    rules(Text("Keyboard"), [
                        Rule(.emoji, String(localized: "Emoji don’t open"), [key(50, "⌃⌘" + String(localized: "Space"))]),
                        Rule(.lookUp, String(localized: "The dictionary doesn’t pop up"), [key(70, "⌃⌘D")], subtitle: Text("Look Up")),
                        Rule(.focusKeys, String(localized: "The keyboard stays in the game"), [key(60, "⌃" + String(localized: "Space")), key(12, "⌃F1"), "…"]),
                        Rule(.globe, String(localized: "🌐 shortcuts are paused"), ["🌐"]),
                    ])
                    rules(Text("Mouse and screen"), [
                        Rule(.controlClick, String(localized: "⌃-click works as a plain click"), ["⌃"]),
                        Rule(.swipes, String(localized: "Gestures don’t leave the game")),
                        Rule(
                            .cursor, String(localized: "The pointer stays in the game"),
                            subtitle: Text("The Dock, menu bar and hot corners don’t pop up, and the pointer doesn’t slip onto another screen")
                        ),
                        Rule(.display, String(localized: "The screen stays on"), subtitle: Text("The display doesn’t dim or sleep while you play")),
                    ])
                }
            }
            RestoreDefaultsSection(
                message: String(localized: "These will turn off and go back to their default options: \(tool.title)"),
                isDefault: tool.isDefault,
                reset: tool.reset
            )
        }
        .formStyle(.grouped)
        .coordinateSpace(.named(SystemShortcutList.viewport))
        .settingsPage()
        .environment(\.inSettings, true)
        .onChange(of: SettingsWindow.model.highlight, initial: true) {
            let simple = [tool.title, String(localized: "Your games"), String(localized: "Show FPS"), String(localized: "Corner for FPS")]
            if let title = SettingsWindow.model.highlight, !simple.contains(title) {
                advanced = true
                if title == String(localized: "Game safeguards") || SettingsWindow.model.highlightedShortcut == nil && !GameShortcutGroup.allCases.contains(where: { $0.title == title }) && title != String(localized: "System keyboard shortcuts") { safeguards = true }
            }
        }
    }

    private func key(_ id: Int32, _ fallback: String) -> String {
        SystemShortcuts.shared.text(id) ?? fallback
    }

    private func rules(_ header: Text, _ rows: [Rule], footer: Text? = nil) -> some View {
        #if APPSTORE
        let rows = rows.filter { $0.rule.hotKeys.isEmpty || [.appSwitcher, .hide].contains($0.rule) || $0.rule.hotKeys.contains { SymbolicHotKeys.value($0) != nil } }
        #endif
        return Section {
            ForEach(rows, id: \.rule) { row in
                VStack(spacing: 10) {
                    IllustrationRow { GameRuleArt(rule: row.rule, keys: row.keys, on: tool.rules.contains(row.rule)) }
                        .opacity(tool.isEnabled ? 1 : 0.5)
                    Toggle(isOn: Binding { tool.rules.contains(row.rule) } set: { if $0 { tool.rules.insert(row.rule) } else { tool.rules.remove(row.rule) } }) {
                        HStack(spacing: 12) {
                            RowLabel(Text(row.title), row.rule.detail.map { Text(verbatim: $0) })
                            Spacer(minLength: 0)
                            if !row.keys.isEmpty { KeyCaps(keys: row.keys, system: row.rule.hotKeys.isEmpty ? nil : SystemShortcuts.place(row.rule.hotKeys)) }
                        }
                    }
                }
                .settingAnchor(row.title)
            }
            .disabled(!tool.isEnabled)
        } header: {
            header
        } footer: {
            if let footer {
                footer
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct Rule {
    let rule: GameRule
    let title: String
    let keys: [String]
    let subtitle: Text?

    init(_ rule: GameRule, _ title: String, _ keys: [String] = [], subtitle: Text? = nil) {
        self.rule = rule
        self.title = title
        self.keys = keys
        self.subtitle = subtitle
    }
}

private struct GameModeSettings: View {
    @Bindable var tool: GameModeTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("While you play, your Mac doesn’t pull you out of the game"),
            hint: tool.game.map { Text("Now playing: \($0.title)") } ?? Text("Your Mac doesn’t pull you out of a game"),
            help: Text("To leave a game, press \(CommandKeysTool.quit.text); to close its window, \(CommandKeysTool.close.text). ⌥⌘Esc always works."),
            isOn: $tool.isEnabled
        )
    }
}

struct GameModeArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.8, 0.9, 1.2, 0.8, 1.6, 1.7]
    private static let screen = CGSize(width: 196, height: 108)
    private static let bar = CGRect(x: 39, y: 23, width: 118, height: 22)

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 0 : tick % Self.durations.count
            let search = step == 1 || !on && step == 2
            let edge = step == 4
            let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
            ArtTimeline { time in
                Stage {
                    ZStack {
                        GameScene(time: time ?? GameStory.start)
                        ArtDock(icon: 14)
                            .offset(y: !on && edge ? 40 : 72)
                        Capsule()
                            .fill(.white.opacity(0.85))
                            .frame(width: 44, height: 2)
                            .blur(radius: 1.5)
                            .offset(x: 30, y: Self.screen.height / 2 - 1)
                            .opacity(on && edge ? 1 : 0)
                        ZStack {
                            GameScene(time: time ?? GameStory.start).glassBackdrop(Self.bar)
                            ArtSpotlight(width: Self.bar.width, height: Self.bar.height)
                                .position(x: Self.bar.midX, y: Self.bar.midY)
                        }
                        .opacity(search ? (on ? 0.6 : 1) : 0)
                        .scaleEffect(search ? 1 : 0.9)
                        .blur(radius: on && !search ? 4 : 0)
                    }
                    .frame(width: Self.screen.width, height: Self.screen.height)
                    .clipShape(shape)
                    .overlay(shape.hairline(Color.primary.opacity(0.14)))
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    .position(x: 150, y: 64)
                    ArtCursor()
                        .cursor(at: (3...4).contains(step) ? CGPoint(x: 180, y: 115) : CGPoint(x: 176, y: 74))
                }
                .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
            }
        }
    }
}
