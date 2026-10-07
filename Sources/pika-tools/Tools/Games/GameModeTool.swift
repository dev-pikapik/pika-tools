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
    @ObservationIgnored fileprivate var combos: Set<UInt64> = []
    @ObservationIgnored private var hinted = false
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
        guard isEnabled, let app, games.contains(Self.key(app)), !Self.screenLocked else { return leave() }
        guard app.processIdentifier != game?.processIdentifier else { return }
        leave()
        enter(app)
    }

    private func enter(_ app: NSRunningApplication) {
        game = app
        trace.disable(GameRules.hotKeys(search: blocksSearch, switching: blocksSwitching, layout: keepsLayout, appSwitcher: tap != nil))
        combos = Set(
            (HotKeyTrace.ids(trace.defaults) ?? []).filter { !GameRules.layoutKeys.contains($0) }
                .compactMap(SymbolicHotKeys.value).map { GameRules.combo(key: Int64($0.key), flags: $0.modifiers) }
        )
        hinted = false
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

    func keys(_ ids: Int32...) -> [String] {
        let off = HotKeyTrace.ids(trace.defaults) ?? []
        return ids.filter { off.contains($0) || SymbolicHotKeys.isEnabled($0) }.compactMap(SymbolicHotKeys.shortcut)
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

private enum GameHint {
    private static var panel: NSPanel?

    static func show() {
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }) ?? NSScreen.main else { return }
        let view = NSHostingView(rootView: Text("To leave the game, press ⇧⌘Q")
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
        let blocked = tool.blocksSwitching && flags.contains(.maskCommand) && !flags.contains(.maskControl)
            && [kVK_Tab, kVK_ANSI_H, kVK_ANSI_M].contains(key)
        if type == .keyDown, blocked || tool.combos.contains(GameRules.combo(key: Int64(key), flags: flags.rawValue)) { tool.hint() }
        if blocked { return nil }
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
                text: tool.game.map { String(localized: "Now playing: \($0.localizedName ?? "")") } ?? String(localized: "Play without interruptions")
            )
            Section {
                GameModeArt(on: tool.isEnabled)
                tool.settingsView
            }
            Section {
                AppExclusions(
                    title: String(localized: "Your games"),
                    apps: $tool.games,
                    isEnabled: true,
                    empty: Text("Add a game, and Game Mode turns on by itself while you play it"),
                    addMenu: "Add a Game…"
                )
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
            Section {
                Group {
                    ToggleRow(
                        icon: "magnifyingglass",
                        title: String(localized: "Search and Siri"),
                        subtitle: caption("Spotlight", named(String(localized: "Emoji"), tool.keys(50)), "Siri", "🌐"),
                        keys: [tool.keys(64).first ?? "⌘" + String(localized: "Space")],
                        column: Self.column,
                        isOn: $tool.blocksSearch
                    )
                    ToggleRow(
                        icon: "rectangle.on.rectangle",
                        title: String(localized: "Other apps and desktops"),
                        subtitle: caption(
                            "⌘H", "⌘M", named(String(localized: "Mission Control"), tool.keys(32)),
                            named(String(localized: "Desktops"), tool.keys(79, 81)), String(localized: "Swipes")
                        ),
                        keys: ["⌘Tab"],
                        column: Self.column,
                        isOn: $tool.blocksSwitching
                    )
                    ToggleRow(
                        icon: "xmark.app",
                        title: String(localized: "The game doesn’t close by accident"),
                        subtitle: Text("⌘Q and ⌘W don’t work in the game. To quit, press ⇧⌘Q"),
                        keys: Self.column,
                        isOn: $tool.blocksQuit
                    )
                    ToggleRow(
                        icon: "globe",
                        title: String(localized: "The keyboard language doesn’t change"),
                        subtitle: Text("If it switches by accident, it comes back right away"),
                        keys: [tool.keys(60).first ?? "⌃" + String(localized: "Space")],
                        column: Self.column,
                        isOn: $tool.keepsLayout
                    )
                }
                .disabled(!tool.isEnabled)
            } header: {
                Text("While you play")
            } footer: {
                Text("To leave a game, press ⇧⌘Q; to close its window, ⇧⌘W. ⌥⌘Esc always works.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section {
                Group {
                    ToggleRow(
                        icon: "cursorarrow.rays",
                        title: String(localized: "The pointer stays in the game"),
                        subtitle: Text("The Dock, menu bar and hot corners don’t pop up, and the pointer doesn’t slip onto another screen"),
                        isOn: $tool.fencesCursor
                    )
                    ToggleRow(
                        icon: "sun.max",
                        title: String(localized: "The screen stays on"),
                        subtitle: Text("The display doesn’t dim or sleep while you play"),
                        isOn: $tool.keepsDisplayOn
                    )
                }
                .disabled(!tool.isEnabled)
            }
            RestoreDefaultsSection(
                message: String(localized: "These will turn off and go back to their default options: \(tool.title)"),
                isDefault: tool.isDefault,
                reset: tool.reset
            )
        }
        .formStyle(.grouped)
        .settingsPage()
        .environment(\.inSettings, true)
    }

    private static let column = ["⌘Q", "⌘W"]

    private func caption(_ parts: String?...) -> Text {
        Text(verbatim: parts.compactMap { $0 }.joined(separator: " · "))
    }

    private func named(_ name: String, _ keys: [String]) -> String? {
        keys.isEmpty ? nil : ([name] + keys).joined(separator: "\u{00A0}")
    }
}

private struct GameModeSettings: View {
    @Bindable var tool: GameModeTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("While you play, your Mac doesn’t pull you out of the game"),
            hint: tool.game.map { Text("Now playing: \($0.localizedName ?? "")") } ?? Text("Your Mac doesn’t pull you out of a game"),
            help: Text("To leave a game, press ⇧⌘Q; to close its window, ⇧⌘W. ⌥⌘Esc always works."),
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

    var body: some View {
        let step = reduceMotion ? 0 : tick % Self.durations.count
        let search = step == 1 || !on && step == 2
        let edge = step == 3
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            Stage {
                ZStack {
                    GameScene(hop: step % 2 == 1)
                    ArtDock()
                        .scaleEffect(0.62)
                        .offset(y: !on && edge ? 40 : 72)
                    Capsule()
                        .fill(.white.opacity(0.85))
                        .frame(width: 44, height: 2)
                        .blur(radius: 1.5)
                        .offset(x: 30, y: Self.screen.height / 2 - 1)
                        .opacity(on && edge ? 1 : 0)
                    spotlight
                        .opacity(search ? (on ? 0.6 : 1) : 0)
                        .scaleEffect(search ? 1 : 0.9)
                        .blur(radius: on && !search ? 4 : 0)
                        .offset(y: -20)
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

    private var spotlight: some View {
        HStack(spacing: 5) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 46, height: 4)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(width: 118, height: 22)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.94), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
}

private struct GameScene: View {
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
