import Carbon
import CoreGraphics
import Foundation

enum GameRules {
    static let launchers: Set<String> = [
        "com.valvesoftware.steam", "com.epicgames.EpicGamesLauncher", "net.battle.app", "com.blizzard.bna",
        "com.gog.galaxy", "com.apple.games", "com.codeweavers.CrossOver", "com.isaacmarovitz.Whisky",
        "com.heroicgameslauncher.hgl", "org.prismlauncher.PrismLauncher", "com.mojang.minecraftlauncher", "io.itch.mac",
    ]

    static let minecraftLaunchers = ["com.mojang.minecraftlauncher", "com.overwolf.curseforge"]

    static let neverBlocked: Set<Int32> = {
        var ids: [Int32] = [0, 6, 58, 59, 73, 156, 160, 161, 162, 177, 181, 182, 184, 185, 189, 260, 261, 262]
        for range in [15...26, 28...31, 53...56, 100...107, 150...155, 165...172, 192...195] as [ClosedRange<Int32>] { ids += range }
        return Set(ids)
    }()
    static let retiredKeys = ["game-mode-search", "game-mode-switching", "game-mode-quit", "game-mode-control", "game-mode-layout"]

    static func hotKeys(_ rules: Set<GameRule>, appSwitcher: Bool, input: [Int32] = []) -> [Int32] {
        let keys = GameRule.allCases.filter(rules.contains).flatMap(\.hotKeys) + (appSwitcher && rules.contains(.appSwitcher) ? [1, 2] : [])
        return keys + (rules.contains(.focusKeys) ? input.filter { !keys.contains($0) } : [])
    }

    static func isGameInput(_ modifiers: UInt64) -> Bool {
        modifiers & 0x100000 == 0 || modifiers & 0x40000 != 0
    }

    static func blocksAppShortcut(key: Int, flags: CGEventFlags, rules: Set<GameRule>, allowed: Set<UInt64> = []) -> Bool {
        !allowed.contains(combo(key: Int64(key), flags: flags.rawValue)) && !isGameInput(flags.rawValue)
            && (key == kVK_Tab && rules.contains(.appSwitcher) || [kVK_ANSI_H, kVK_ANSI_M].contains(key) && rules.contains(.hide))
    }

    static func clickFlags(_ type: CGEventType, _ flags: CGEventFlags, playing: Bool, blocksControl: Bool) -> CGEventFlags {
        guard playing, blocksControl, [.leftMouseDown, .leftMouseUp, .leftMouseDragged].contains(type) else { return flags }
        return flags.subtracting(.maskControl)
    }

    static func isGame(id: String?, name: String?, path: String, in games: [String]) -> Bool {
        if let id, minecraftLaunchers.contains(id) { return false }
        if !path.isEmpty, games.contains(path) { return true }
        if games.contains(rule(id: id, name: name, path: path)) { return true }
        return games.contains(where: minecraftLaunchers.contains) && (minecraft(path) != nil || name?.hasPrefix("Minecraft") == true)
    }

    static func isRuntime(_ id: String?) -> Bool {
        guard let id = id?.lowercased() else { return true }
        return ["java", "python"].contains(where: id.contains)
    }

    static func rule(id: String?, name: String?, path: String) -> String {
        guard isRuntime(id), !path.isEmpty else { return id ?? name ?? "" }
        return minecraft(path) ?? path
    }

    static func minecraft(_ path: String) -> String? {
        guard let game = path.range(of: "/minecraft/", options: .caseInsensitive),
              let runtime = path.range(of: "/runtime/", options: .caseInsensitive, range: game.lowerBound..<path.endIndex)
        else { return nil }
        return String(path[..<runtime.upperBound])
    }

    static func upgraded(_ games: [String], id: String?, name: String?, path: String) -> [String] {
        let rule = rule(id: id, name: name, path: path)
        guard let old = id ?? name, old != rule, let index = games.firstIndex(of: old) else { return games }
        var games = games
        games.remove(at: index)
        if !games.contains(rule) { games.insert(rule, at: index) }
        return games
    }

    static func dockFiles(_ tiles: [Any]?) -> [URL] {
        (tiles ?? [])
            .compactMap { ((($0 as? [String: Any])?["tile-data"] as? [String: Any])?["file-data"] as? [String: Any])?["_CFURLString"] as? String }
            .compactMap { $0.hasPrefix("/") ? URL(fileURLWithPath: $0) : URL(string: $0) }
            .filter(\.isFileURL)
    }

    static func shelf(_ keys: [String]) -> [String] {
        var seen = Set<String>()
        return keys.filter { !$0.isEmpty && !$0.hasPrefix("com.pesotchi.pika-tools") && $0 != "com.apple.finder" && seen.insert($0).inserted }
    }

    static func processIDs(_ text: String, names: (Int32) -> [String]) -> [Int32] {
        guard text.utf8.count <= 65_536 else { return [] }
        var seen = Set<Int32>()
        return text.split(whereSeparator: \.isNewline).compactMap { line in
            let fields = line.split(separator: "\t").map { $0.trimmingCharacters(in: .whitespaces) }
            guard fields.count > 1 else { return nil }
            let candidates = Set(fields.compactMap(Int32.init)).filter { pid in
                pid > 0 && names(pid).contains(where: fields.contains)
            }
            guard candidates.count == 1, let pid = candidates.first, seen.insert(pid).inserted else { return nil }
            return pid
        }
    }

    static func migrateControl(_ defaults: UserDefaults) {
        if defaults.object(forKey: "ctrl-keys") as? Bool == true { defaults.set(true, forKey: "game-mode-control") }
        ["ctrl-keys", "ctrl-keys-excluded"].forEach(defaults.removeObject)
    }

    static func migrateGroups(_ defaults: UserDefaults) {
        for rule in GameRule.allCases where defaults.object(forKey: rule.key) == nil {
            if let value = rule.group.flatMap(defaults.object) { defaults.set(value, forKey: rule.key) }
        }
        retiredKeys.forEach(defaults.removeObject)
    }

    static func migrated(_ values: [String: Any]) -> [String: Any] {
        var values = values
        for rule in GameRule.allCases where values[rule.key] == nil {
            values[rule.key] = rule.group.flatMap { values[$0] }
        }
        retiredKeys.forEach { values[$0] = nil }
        return values
    }

    static func looksLikeGame(id: String?, category: String?, supportsGameMode: Bool, path: String) -> Bool {
        if let id, launchers.contains(id) { return false }
        if let category, category == "public.app-category.games" || category.hasPrefix("public.app-category.") && category.hasSuffix("-games") {
            return true
        }
        let path = path.lowercased()
        return supportsGameMode || path.contains("/steamapps/common/")
            || id == nil && ["wine", "crossover", "whisky", "game porting toolkit"].contains(where: path.contains)
    }

    static func fence(_ point: CGPoint, in frame: CGRect) -> CGPoint? {
        let fenced = CGPoint(
            x: min(max(point.x, frame.minX + 1), frame.maxX - 2),
            y: min(max(point.y, frame.minY + 1), frame.maxY - 2)
        )
        return fenced == point ? nil : fenced
    }

    static func commandKeys(quit: Bool, close: Bool, playing: Bool, blocksQuit: Bool, blocksClose: Bool) -> (keys: Set<Int64>, blocked: Set<Int64>) {
        let blocked = Set((quit || playing && blocksQuit ? [Int64(kVK_ANSI_Q)] : []) + (close || playing && blocksClose ? [Int64(kVK_ANSI_W)] : []))
        return (playing ? blocked.union([Int64(kVK_ANSI_Q), Int64(kVK_ANSI_W)]) : blocked, blocked)
    }

    static func combo(key: Int64, flags: UInt64) -> UInt64 {
        UInt64(truncatingIfNeeded: key) << 32 | flags & 0x9E0000
    }
}

enum GameRule: String, CaseIterable {
    case commandQ = "command-q", commandW = "command-w", spotlight, siri, appSwitcher = "app-switcher", hide, launchpad
    case missionControl = "mission-control", appWindows = "app-windows", showDesktop = "show-desktop", desktops
    case desktopNumbers = "desktop-numbers", swipes, emoji, lookUp = "look-up", focusKeys = "focus-keys", globe, controlClick = "control-click"
    case cursor, display

    var key: String { "game-mode-\(rawValue)" }

    var group: String? {
        switch self {
        case .commandQ, .commandW: "game-mode-quit"
        case .spotlight, .siri, .emoji, .lookUp, .globe: "game-mode-search"
        case .appSwitcher, .hide, .launchpad, .showDesktop, .swipes: "game-mode-switching"
        case .missionControl, .appWindows, .desktops, .desktopNumbers, .focusKeys, .controlClick: "game-mode-control"
        case .cursor, .display: nil
        }
    }

    var hotKeys: [Int32] {
        switch self {
        case .spotlight: [64, 65, 187, 263, 264]
        case .siri: [186]
        case .appSwitcher: [27, 220]
        case .hide: [233, 234]
        case .launchpad: [173, 174]
        case .missionControl: [32, 34, 52, 99, 163, 222] + Array(75...78) + Array(108...117)
        case .appWindows: [33, 35, 198]
        case .showDesktop: [36, 37]
        case .desktops: Array(79...86) + [199, 200]
        case .desktopNumbers: Array(118...149)
        case .emoji: [50]
            case .lookUp: [70]
        case .focusKeys: Array(7...13) + [57, 60, 61, 159]
        case .globe: [190, 196, 197] + Array(210...214) + Array(237...258)
        case .commandQ, .commandW, .swipes, .controlClick, .cursor, .display: []
        }
    }
}

struct HotKeyTrace {
    static let key = "game-mode-hotkeys-off"
    var defaults = UserDefaults.standard
    var isEnabled: (Int32) -> Bool = SymbolicHotKeys.isEnabled
    var setEnabled: (Int32, Bool) -> Void = SymbolicHotKeys.set

    func disable(_ ids: [Int32]) {
        let saved = Self.ids(defaults) ?? []
        let off = ids.filter { !saved.contains($0) && isEnabled($0) }
        guard !off.isEmpty else { return }
        defaults.set((saved + off).map { Int($0) }, forKey: Self.key)
        off.forEach { setEnabled($0, false) }
    }

    func restore() {
        Self.ids(defaults)?.filter { !isEnabled($0) }.forEach { setEnabled($0, true) }
        defaults.removeObject(forKey: Self.key)
    }

    static func ids(_ defaults: UserDefaults) -> [Int32]? {
        (defaults.array(forKey: key) as? [Int])?.compactMap(Int32.init(exactly:))
    }
}

enum SymbolicHotKeys {
    static var gameInputs: [Int32] {
        let configured = CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString, "com.apple.symbolichotkeys" as CFString) as? [String: Any] ?? [:]
        let ids = Set((0..<300).map(Int32.init) + configured.keys.compactMap(Int32.init))
        return ids.sorted().filter { id in
            guard let value = value(id), value.key != UInt16.max else { return false }
            return GameRules.isGameInput(value.modifiers)
        }
    }

    #if APPSTORE
    private static var swallowed: [Int32: UInt64] = [:]

    private static func configured(_ id: Int32) -> (enabled: Bool, character: UInt16, key: UInt16, modifiers: UInt64)? {
        let all = CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString, "com.apple.symbolichotkeys" as CFString) as? [String: Any]
        guard let entry = all?[String(id)] as? [String: Any],
              let parameters = (entry["value"] as? [String: Any])?["parameters"] as? [Int], parameters.count == 3,
              parameters[1] != Int(UInt16.max), parameters[2] & 0x100000 != 0, parameters[2] & 0x800000 == 0
        else { return nil }
        let enabled = (entry["enabled"] as? NSNumber)?.boolValue ?? true
        return (enabled, UInt16(truncatingIfNeeded: parameters[0]), UInt16(truncatingIfNeeded: parameters[1]), UInt64(parameters[2]))
    }

    static var available: Bool { true }

    static func swallows(key: Int, flags: UInt64) -> Bool {
        swallowed.values.contains(GameRules.combo(key: Int64(key), flags: flags))
    }

    static func isEnabled(_ id: Int32) -> Bool {
        configured(id)?.enabled == true && swallowed[id] == nil
    }

    static func set(_ id: Int32, _ on: Bool) {
        if on {
            swallowed[id] = nil
        } else if let value = configured(id) {
            swallowed[id] = GameRules.combo(key: Int64(value.key), flags: value.modifiers)
        }
    }

    static func value(_ id: Int32) -> (character: UInt16, key: UInt16, modifiers: UInt64)? {
        configured(id).map { ($0.character, $0.key, $0.modifiers) }
    }
    #else
    private typealias SetEnabled = @convention(c) (Int32, Bool) -> Int32
    private typealias IsEnabled = @convention(c) (Int32) -> Bool
    private typealias Value = @convention(c) (Int32, UnsafeMutablePointer<UInt16>, UnsafeMutablePointer<UInt16>, UnsafeMutablePointer<UInt64>) -> Int32

    private static let library = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY)
    private static let setter = dlsym(library, "CGSSetSymbolicHotKeyEnabled").map { unsafeBitCast($0, to: SetEnabled.self) }
    private static let getter = dlsym(library, "CGSIsSymbolicHotKeyEnabled").map { unsafeBitCast($0, to: IsEnabled.self) }
    private static let reader = dlsym(library, "CGSGetSymbolicHotKeyValue").map { unsafeBitCast($0, to: Value.self) }

    static var available: Bool { setter != nil && getter != nil }

    static func isEnabled(_ id: Int32) -> Bool {
        getter?(id) ?? false
    }

    static func set(_ id: Int32, _ on: Bool) {
        _ = setter?(id, on)
    }

    static func value(_ id: Int32) -> (character: UInt16, key: UInt16, modifiers: UInt64)? {
        var character: UInt16 = 0
        var key: UInt16 = 0
        var modifiers: UInt64 = 0
        guard reader?(id, &character, &key, &modifiers) == 0 else { return nil }
        return (character, key, modifiers)
    }
    #endif
}
