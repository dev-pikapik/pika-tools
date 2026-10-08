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

    @ObservationIgnored fileprivate var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var combos: Set<UInt64> = []
    @ObservationIgnored private var hinted = false
    @ObservationIgnored private var fence: CursorFence?
    @ObservationIgnored private var fenceTimer: Timer?
    @ObservationIgnored private var assertion: IOPMAssertionID?
    @ObservationIgnored private let trace = HotKeyTrace()

    private init() {
        let defaults = UserDefaults.standard
        GameRules.migrateControl(defaults)
        GameRules.migrateGroups(defaults)
        isEnabled = defaults.bool(forKey: "game-mode")
        rules = Self.savedRules
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
        isEnabled = defaults.bool(forKey: id)
    }

    var isDefault: Bool {
        !isEnabled && rules.count == GameRule.allCases.count && games.isEmpty && notGames.isEmpty
    }

    func reset() {
        isEnabled = false
        rules = Set(GameRule.allCases)
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

    func add(_ url: URL) {
        Self.key(url).map(confirm)
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
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && Self.looksLikeGame($0.bundleIdentifier, $0.bundleURL ?? $0.executableURL) }
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
        trace.disable(GameRules.hotKeys(rules, appSwitcher: tap != nil))
        combos = Set(
            (HotKeyTrace.ids(trace.defaults) ?? []).compactMap(SymbolicHotKeys.value)
                .filter { !GameRules.isGameInput($0.modifiers) }.map { GameRules.combo(key: Int64($0.key), flags: $0.modifiers) }
        )
        hinted = false
        if rules.contains(.cursor) || rules.contains(.swipes) { moveFence() }
        if rules.contains(.cursor) {
            fenceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in GameModeTool.shared.moveFence() }
        }
        if rules.contains(.display) {
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
        combos = []
        if let assertion { IOPMAssertionRelease(assertion) }
        assertion = nil
        trace.restore()
        guard game != nil else { return }
        game = nil
        refreshCommandKeys()
    }

    func hint() {
        guard isPlaying, !hinted else { return }
        hinted = true
        DispatchQueue.main.async { GameHint.show() }
    }

    fileprivate func received(_ name: String) {
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
        fence = CursorFence(frame: frame, dropsSwipes: rules.contains(.swipes))
    }

    private func refreshCommandKeys() {
        ToolRegistry.shared.tools.forEach { ($0 as? CommandKeysTool)?.refresh() }
    }

    private func startTap() {
        let types: [CGEventType] = [.keyDown, .keyUp, .leftMouseDown, .leftMouseUp, .leftMouseDragged]
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

    private static var screenLocked: Bool {
        let session = CGSessionCopyCurrentDictionary() as? [String: Any]
        return session?["CGSSessionScreenIsLocked"] as? Bool == true || session?[kCGSessionOnConsoleKey] as? Bool == false
    }

    private static var savedRules: Set<GameRule> {
        Set(GameRule.allCases.filter { UserDefaults.standard.object(forKey: $0.key) as? Bool ?? true })
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
        let blocked = flags.contains(.maskCommand) && !flags.contains(.maskControl)
            && (key == kVK_Tab && tool.rules.contains(.appSwitcher) || [kVK_ANSI_H, kVK_ANSI_M].contains(key) && tool.rules.contains(.hide))
        if type == .keyDown, blocked || tool.combos.contains(GameRules.combo(key: Int64(key), flags: flags.rawValue)) { tool.hint() }
        if blocked { return nil }
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

struct GameModePage: View {
    @Bindable private var tool = GameModeTool.shared

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
                .gameList()
            } footer: {
                Text("You can also drag a game here from Finder")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            rules(Text("Closing the game"), [
                Rule(.commandQ, String(localized: "The game doesn’t close"), ["⌘Q"]),
                Rule(.commandW, String(localized: "The game window doesn’t close"), ["⌘W"]),
            ], footer: Text("To leave a game, press \(CommandKeysTool.quit.text); to close its window, \(CommandKeysTool.close.text). ⌥⌘Esc always works."))
            rules(Text("Apps"), [
                Rule(.appSwitcher, String(localized: "Apps and windows don’t switch"), ["⌘Tab", key(27, "⌘`")]),
                Rule(.hide, String(localized: "The game doesn’t hide"), ["⌘H", key(233, "⌘M")]),
                Rule(.spotlight, String(localized: "Search doesn’t pop up"), [key(64, "⌘" + String(localized: "Space"))], system: Text("Spotlight")),
                Rule(.siri, String(localized: "Siri and voice typing don’t start"), [key(186, "🎤")]),
                Rule(.launchpad, String(localized: "The app grid doesn’t open"), [key(173, "F4")], system: Text("Launchpad")),
            ])
            rules(Text("Desktops"), [
                Rule(.missionControl, String(localized: "The view of all windows doesn’t open"), [key(32, "⌃↑")], system: Text("Mission Control")),
                Rule(.appWindows, String(localized: "The view of the game’s windows doesn’t open"), [key(33, "⌃↓")], system: Text("App Exposé")),
                Rule(.showDesktop, String(localized: "The game doesn’t slide off the screen"), [key(36, "F11")], system: Text("Show Desktop")),
                Rule(.desktops, String(localized: "Desktops don’t switch"), [key(79, "⌃←"), key(81, "⌃→")]),
                Rule(.desktopNumbers, String(localized: "Desktops don’t switch by number"), [key(118, "⌃1"), "…"]),
                Rule(.swipes, String(localized: "Swipes don’t switch desktops")),
            ])
            rules(Text("Keyboard"), [
                Rule(.emoji, String(localized: "Emoji don’t open"), [key(50, "⌃⌘" + String(localized: "Space"))]),
                Rule(.lookUp, String(localized: "The dictionary doesn’t pop up"), [key(70, "⌃⌘D")], system: Text("Look Up")),
                Rule(.focusKeys, String(localized: "The keyboard stays in the game"), [key(12, "⌃F1"), "…", key(57, "⌃F8")]),
                Rule(.globe, String(localized: "🌐 shortcuts are paused"), ["🌐"]),
            ])
            rules(Text("Mouse and screen"), [
                Rule(.controlClick, String(localized: "⌃-click works as a plain click"), ["⌃"]),
                Rule(
                    .cursor, String(localized: "The pointer stays in the game"),
                    subtitle: Text("The Dock, menu bar and hot corners don’t pop up, and the pointer doesn’t slip onto another screen")
                ),
                Rule(.display, String(localized: "The screen stays on"), subtitle: Text("The display doesn’t dim or sleep while you play")),
            ])
            RestoreDefaultsSection(
                message: String(localized: "These will turn off and go back to their default options: \(tool.title)"),
                isDefault: tool.isDefault,
                reset: tool.reset
            )
        }
        .formStyle(.grouped)
        .gameDrop()
        .settingsPage()
        .environment(\.inSettings, true)
    }

    private func key(_ id: Int32, _ fallback: String) -> String {
        SystemShortcuts.shared.text(id) ?? fallback
    }

    private func rules(_ header: Text, _ rows: [Rule], footer: Text? = nil) -> some View {
        Section {
            ForEach(rows, id: \.rule) { row in
                VStack(spacing: 10) {
                    IllustrationRow { GameRuleArt(rule: row.rule) }
                        .opacity(tool.isEnabled ? 1 : 0.5)
                    Toggle(isOn: Binding { tool.rules.contains(row.rule) } set: { if $0 { tool.rules.insert(row.rule) } else { tool.rules.remove(row.rule) } }) {
                        HStack(spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                RowLabel(Text(row.title), row.subtitle)
                                row.system?.foregroundStyle(.secondary)
                            }
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
    let system: Text?

    init(_ rule: GameRule, _ title: String, _ keys: [String] = [], subtitle: Text? = nil, system: Text? = nil) {
        self.rule = rule
        self.title = title
        self.keys = keys
        self.subtitle = subtitle
        self.system = system
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
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.6, 0.8, 1.1, 1.3, 1.2]
    private static let screen = CGSize(width: 196, height: 108)
    private static let bar = CGRect(x: 39, y: 23, width: 118, height: 22)

    var body: some View {
        let step = reduceMotion ? 0 : tick % Self.durations.count
        let search = step == 1 || !on && step == 2
        let edge = step == 3
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            Stage {
                ZStack {
                    GameScene(hop: step % 2 == 1)
                    ArtDock(icon: 14)
                        .offset(y: !on && edge ? 40 : 72)
                    Capsule()
                        .fill(.white.opacity(0.85))
                        .frame(width: 44, height: 2)
                        .blur(radius: 1.5)
                        .offset(x: 30, y: Self.screen.height / 2 - 1)
                        .opacity(on && edge ? 1 : 0)
                    ZStack {
                        GameScene(hop: step % 2 == 1).glassBackdrop(Self.bar)
                        ArtSpotlight(width: Self.bar.width, height: Self.bar.height)
                            .position(x: Self.bar.midX, y: Self.bar.midY)
                    }
                    .opacity(search ? (on ? 0.6 : 1) : 0)
                    .scaleEffect(search ? 1 : 0.9)
                    .blur(radius: on && !search ? 4 : 0)
                }
                .frame(width: Self.screen.width, height: Self.screen.height)
                .clipShape(shape)
                .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                .position(x: 150, y: 64)
                ArtCursor()
                    .cursor(at: edge ? CGPoint(x: 180, y: 115) : CGPoint(x: 176, y: 74))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
        .loop($tick, Self.durations)
    }
}

struct GameScene: View {
    let hop: Bool

    private static let stars: [CGPoint] = [
        CGPoint(x: -70, y: -36), CGPoint(x: -38, y: -28), CGPoint(x: -84, y: -12), CGPoint(x: 8, y: -40), CGPoint(x: 62, y: -32), CGPoint(x: 84, y: -14),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.17, blue: 0.45), Color(red: 0.62, green: 0.33, blue: 0.56), Color(red: 0.98, green: 0.62, blue: 0.45)],
                startPoint: .top,
                endPoint: .bottom
            )
            ForEach(Self.stars, id: \.x) { Circle().fill(.white.opacity(0.7)).frame(width: 2, height: 2).offset(x: $0.x, y: $0.y) }
            Circle()
                .fill(LinearGradient(colors: [Color(red: 1, green: 0.9, blue: 0.6), Color(red: 1, green: 0.62, blue: 0.4)], startPoint: .top, endPoint: .bottom))
                .frame(width: 34, height: 34)
                .offset(x: 36, y: 10)
            Ellipse().fill(Color(red: 0.36, green: 0.22, blue: 0.48)).frame(width: 190, height: 70).offset(x: -60, y: 50)
            Ellipse().fill(Color(red: 0.22, green: 0.13, blue: 0.33)).frame(width: 240, height: 70).offset(x: 50, y: 60)
            Image(systemName: "figure.run")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .offset(x: -40, y: hop ? 13 : 17)
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in Image(systemName: "heart.fill") }
            }
            .font(.system(size: 7))
            .foregroundStyle(Art.red)
            .offset(x: -74, y: -44)
        }
    }
}
