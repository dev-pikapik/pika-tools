import Carbon
import CoreGraphics
import Foundation

@main
enum TestGameMode {
    static func main() {
        precondition(GameRules.looksLikeGame(id: "com.apple.Chess", category: "public.app-category.board-games", supportsGameMode: false, path: "/System/Applications/Chess.app"))
        precondition(GameRules.looksLikeGame(id: "a.b", category: "public.app-category.games", supportsGameMode: false, path: "/Applications/A.app"))
        precondition(GameRules.looksLikeGame(id: "a.b", category: nil, supportsGameMode: true, path: "/Applications/A.app"))
        precondition(GameRules.looksLikeGame(id: "a.b", category: nil, supportsGameMode: false, path: "/Users/me/Library/Application Support/Steam/steamapps/common/Game/Game.app"))
        precondition(GameRules.looksLikeGame(id: nil, category: nil, supportsGameMode: false, path: "/Applications/CrossOver.app/Contents/SharedSupport/CrossOver/lib/wine/x86_64-unix/wine-preloader"))
        precondition(GameRules.looksLikeGame(id: nil, category: nil, supportsGameMode: false, path: "/Users/me/Library/Application Support/com.isaacmarovitz.Whisky/Libraries/Wine/bin/wine64-preloader"))
        precondition(!GameRules.looksLikeGame(id: "com.apple.games", category: "public.app-category.games", supportsGameMode: false, path: "/System/Applications/Games.app"))
        precondition(!GameRules.looksLikeGame(id: "com.valvesoftware.steam", category: nil, supportsGameMode: true, path: "/Applications/Steam.app"))
        precondition(!GameRules.looksLikeGame(id: "com.apple.Safari", category: "public.app-category.productivity", supportsGameMode: false, path: "/Applications/Safari.app"))
        print("detection: ok")

        let all = GameRules.searchKeys + GameRules.switchingKeys + GameRules.appSwitcherKeys + GameRules.layoutKeys
        precondition(Set(all).count == all.count)
        precondition(GameRules.neverBlocked.isDisjoint(with: all))
        precondition(GameRules.hotKeys(search: false, switching: false, layout: false, appSwitcher: true).isEmpty)
        precondition(GameRules.hotKeys(search: true, switching: false, layout: false, appSwitcher: true) == GameRules.searchKeys)
        precondition(GameRules.hotKeys(search: false, switching: true, layout: false, appSwitcher: true).contains(1))
        precondition(!GameRules.hotKeys(search: false, switching: true, layout: false, appSwitcher: false).contains(1))
        precondition(!GameRules.hotKeys(search: true, switching: true, layout: true, appSwitcher: false).contains(2))
        precondition(GameRules.hotKeys(search: false, switching: false, layout: true, appSwitcher: true) == [60, 61, 156])
        precondition(GameRules.searchKeys.contains(64) && GameRules.switchingKeys.contains(37) && GameRules.switchingKeys.contains(233))
        print("groups: ok")

        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("test-game-mode-\(UUID().uuidString)")
        let suite = folder.path
        var table: [Int32: Bool] = [1: true, 2: true, 64: true, 65: false, 37: true]
        func trace() -> HotKeyTrace {
            HotKeyTrace(
                defaults: UserDefaults(suiteName: suite)!,
                isEnabled: { table[$0] ?? false },
                setEnabled: { table[$0] = $1 }
            )
        }
        trace().disable([1, 2, 64, 65])
        precondition(table == [1: false, 2: false, 64: false, 65: false, 37: true])
        precondition(Set(UserDefaults(suiteName: suite)!.array(forKey: HotKeyTrace.key) as! [Int]) == [1, 2, 64])
        trace().disable([37])
        precondition(Set(UserDefaults(suiteName: suite)!.array(forKey: HotKeyTrace.key) as! [Int]) == [1, 2, 64, 37])
        trace().restore()
        precondition(table == [1: true, 2: true, 64: true, 65: false, 37: true])
        precondition(UserDefaults(suiteName: suite)!.object(forKey: HotKeyTrace.key) == nil)
        trace().restore()
        precondition(table[65] == false)
        trace().disable([64])
        table[64] = true
        trace().restore()
        precondition(table[64] == true)
        UserDefaults(suiteName: suite)!.set("64", forKey: HotKeyTrace.key)
        trace().restore()
        precondition(UserDefaults(suiteName: suite)!.object(forKey: HotKeyTrace.key) == nil)
        UserDefaults(suiteName: suite)!.set([Int.max, 64], forKey: HotKeyTrace.key)
        table[64] = false
        trace().restore()
        precondition(table[64] == true && UserDefaults(suiteName: suite)!.object(forKey: HotKeyTrace.key) == nil)
        UserDefaults(suiteName: suite)!.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(atPath: suite + ".plist")
        print("trace: ok")

        let q = Int64(kVK_ANSI_Q), w = Int64(kVK_ANSI_W)
        for quit in [false, true] {
            for close in [false, true] {
                for blocks in [false, true] {
                    let game = GameRules.commandKeys(quit: quit, close: close, playing: true, blocksQuit: blocks)
                    precondition(game.keys.isSuperset(of: [q, w]))
                    precondition(game.blocked == Set((quit || blocks ? [q] : []) + (close || blocks ? [w] : [])))
                    let idle = GameRules.commandKeys(quit: quit, close: close, playing: false, blocksQuit: blocks)
                    precondition(idle.keys == idle.blocked && idle.blocked == Set((quit ? [q] : []) + (close ? [w] : [])))
                }
            }
        }
        precondition(GameRules.commandKeys(quit: false, close: false, playing: true, blocksQuit: false).blocked.isEmpty)
        print("quit keys: ok")

        precondition(GameRules.combo(key: 49, flags: 0x80000 | 0x10000 | 0x100) == GameRules.combo(key: 49, flags: 0x80000))
        precondition(GameRules.combo(key: 123, flags: 0xA40000) == GameRules.combo(key: 123, flags: 0x840000))
        precondition(GameRules.combo(key: 49, flags: 0x100000) != GameRules.combo(key: 49, flags: 0x80000))
        precondition(GameRules.combo(key: 49, flags: 0x100000) != GameRules.combo(key: 48, flags: 0x100000))
        print("hint keys: ok")

        precondition(GameRules.layoutToRestore(locked: "com.apple.keylayout.Russian", current: "com.apple.keylayout.ABC") == "com.apple.keylayout.Russian")
        precondition(GameRules.layoutToRestore(locked: "com.apple.keylayout.ABC", current: "com.apple.keylayout.ABC") == nil)
        precondition(GameRules.layoutToRestore(locked: nil, current: "com.apple.keylayout.ABC") == nil)
        print("layout: ok")

        precondition(GameRules.shortcut(character: 32, key: 49, modifiers: 0x80000) == "⌥Space")
        precondition(GameRules.shortcut(character: 32, key: 49, modifiers: 0x140000) == "⌃⌘Space")
        precondition(GameRules.shortcut(character: 65535, key: 48, modifiers: 0x100000) == "⌘Tab")
        precondition(GameRules.shortcut(character: 65535, key: 123, modifiers: 0x840000) == "⌃←")
        precondition(GameRules.shortcut(character: 65535, key: 124, modifiers: 0x860000) == "⌃⇧→")
        precondition(GameRules.shortcut(character: 100, key: 2, modifiers: 0x140000) == "⌃⌘D")
        precondition(GameRules.shortcut(character: 104, key: 4, modifiers: 0x800000) == "🌐H")
        precondition(GameRules.shortcut(character: 65535, key: 65535, modifiers: 0) == nil)
        print("shortcuts: ok")

        let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let second = CGRect(x: 1440, y: -200, width: 1920, height: 1080)
        precondition(GameRules.fence(CGPoint(x: 700, y: 400), in: screen) == nil)
        precondition(GameRules.fence(CGPoint(x: 1, y: 1), in: screen) == nil)
        precondition(GameRules.fence(CGPoint(x: 0, y: 400), in: screen) == CGPoint(x: 1, y: 400))
        precondition(GameRules.fence(CGPoint(x: 700, y: 899.5), in: screen) == CGPoint(x: 700, y: 898))
        precondition(GameRules.fence(CGPoint(x: 1439, y: 0), in: screen) == CGPoint(x: 1438, y: 1))
        precondition(GameRules.fence(CGPoint(x: 2000, y: 100), in: screen) == CGPoint(x: 1438, y: 100))
        precondition(GameRules.fence(CGPoint(x: 1440, y: -200), in: second) == CGPoint(x: 1441, y: -199))
        precondition(GameRules.fence(CGPoint(x: 1000, y: 500), in: second) == CGPoint(x: 1441, y: 500))
        print("cursor fence: ok")
    }
}
