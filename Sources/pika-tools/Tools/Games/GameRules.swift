import Carbon
import CoreGraphics
import Foundation

enum GameRules {
    static let launchers: Set<String> = [
        "com.valvesoftware.steam", "com.epicgames.EpicGamesLauncher", "net.battle.app", "com.blizzard.bna",
        "com.gog.galaxy", "com.apple.games", "com.codeweavers.CrossOver", "com.isaacmarovitz.Whisky",
        "com.heroicgameslauncher.hgl", "org.prismlauncher.PrismLauncher", "com.mojang.minecraftlauncher", "io.itch.mac",
    ]

    static let searchKeys: [Int32] = [50, 64, 65, 70, 164, 186, 187, 190, 196, 197, 210, 211, 212, 213, 263, 264]
    static let switchingKeys: [Int32] = [27, 52, 57, 99, 159, 163, 173, 174, 198, 199, 200, 214, 220, 222, 233, 234]
        + Array(7...13) + Array(32...37) + Array(75...86) + Array(108...149) + Array(237...258)
    static let appSwitcherKeys: [Int32] = [1, 2]
    static let layoutKeys: [Int32] = [60, 61, 156]
    static let neverBlocked: Set<Int32> = Set([0, 6, 58, 59, 73, 160, 161, 162, 177, 181, 182, 184, 185, 189, 260, 261, 262]
        + Array(15...26) + Array(28...31) + Array(53...56) + Array(100...107) + Array(150...155) + Array(165...172) + Array(192...195))

    static func hotKeys(search: Bool, switching: Bool, layout: Bool, appSwitcher: Bool) -> [Int32] {
        (search ? searchKeys : []) + (switching ? switchingKeys + (appSwitcher ? appSwitcherKeys : []) : []) + (layout ? layoutKeys : [])
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

    static func shortcut(character: UInt16, key: UInt16, modifiers: UInt64) -> String? {
        let names: [UInt16: String] = [
            49: String(localized: "Space"), 48: "Tab", 53: "Esc", 36: "↩", 51: "⌫", 117: "⌦", 123: "←", 124: "→", 125: "↓", 126: "↑",
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
            160: "F3", 131: "F4", 176: "🎤", 177: "🔍",
        ]
        let printable = (33..<127).contains(character) ? Unicode.Scalar(character).map { String($0).uppercased() } : nil
        guard let name = names[key] ?? printable else { return nil }
        let flags: [(UInt64, String)] = [(0x40000, "⌃"), (0x80000, "⌥"), (0x20000, "⇧"), (0x100000, "⌘")]
        let fn = names[key] == nil && modifiers & 0x800000 != 0 ? "🌐" : ""
        return fn + flags.filter { modifiers & $0.0 != 0 }.map(\.1).joined() + name
    }

    static func commandKeys(quit: Bool, close: Bool, playing: Bool, blocksQuit: Bool) -> (keys: Set<Int64>, blocked: Set<Int64>) {
        let game = playing && blocksQuit
        let blocked = Set((quit || game ? [Int64(kVK_ANSI_Q)] : []) + (close || game ? [Int64(kVK_ANSI_W)] : []))
        return (playing ? blocked.union([Int64(kVK_ANSI_Q), Int64(kVK_ANSI_W)]) : blocked, blocked)
    }

    static func combo(key: Int64, flags: UInt64) -> UInt64 {
        UInt64(truncatingIfNeeded: key) << 32 | flags & 0x9E0000
    }

    static func layoutToRestore(locked: String?, current: String?) -> String? {
        guard let locked, current != locked else { return nil }
        return locked
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
        defaults.set((saved + off).map(Int.init), forKey: Self.key)
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

    static func shortcut(_ id: Int32) -> String? {
        value(id).flatMap { GameRules.shortcut(character: $0.character, key: $0.key, modifiers: $0.modifiers) }
    }
}
