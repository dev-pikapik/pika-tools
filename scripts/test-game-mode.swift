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
        UserDefaults(suiteName: suite)!.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(atPath: suite + ".plist")
        print("trace: ok")

        var press = DoublePress()
        precondition(!press.press(at: 10))
        precondition(press.press(at: 10.3))
        precondition(!press.press(at: 10.5))
        precondition(!press.press(at: 11))
        precondition(press.press(at: 11.35))
        precondition(!press.press(at: 20))
        precondition(!press.press(at: 20.41))
        print("double ⌘Tab: ok")

        precondition(GameRules.layoutToRestore(locked: "com.apple.keylayout.Russian", current: "com.apple.keylayout.ABC") == "com.apple.keylayout.Russian")
        precondition(GameRules.layoutToRestore(locked: "com.apple.keylayout.ABC", current: "com.apple.keylayout.ABC") == nil)
        precondition(GameRules.layoutToRestore(locked: nil, current: "com.apple.keylayout.ABC") == nil)
        print("layout: ok")

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
