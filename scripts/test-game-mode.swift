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

        let ids = GameRule.allCases.flatMap(\.hotKeys) + [1, 2]
        let all = Set(GameRule.allCases)
        precondition(Set(ids).count == ids.count)
        precondition(GameRules.neverBlocked.isDisjoint(with: ids) && GameRules.neverBlocked.isSuperset(of: [60, 61, 156]))
        precondition(Set(GameRule.allCases.map(\.key)).count == all.count)
        precondition(GameRules.hotKeys([], appSwitcher: true).isEmpty)
        precondition(GameRules.hotKeys([.commandQ, .commandW, .swipes, .controlClick, .cursor, .display], appSwitcher: true).isEmpty)
        precondition(GameRules.hotKeys([.spotlight], appSwitcher: true) == GameRule.spotlight.hotKeys)
        precondition(GameRules.hotKeys(all, appSwitcher: true).contains(1))
        precondition(!GameRules.hotKeys(all, appSwitcher: false).contains(2))
        precondition(!GameRules.hotKeys(all.subtracting([.appSwitcher]), appSwitcher: true).contains(1))
        precondition(GameRule.spotlight.hotKeys.contains(64) && GameRule.siri.hotKeys == [186] && GameRule.hide.hotKeys.contains(233))
        precondition(GameRule.missionControl.hotKeys.contains(32) && GameRule.appWindows.hotKeys.contains(33) && GameRule.showDesktop.hotKeys.contains(37))
        precondition(Set(GameRule.desktops.hotKeys).isSuperset(of: [79, 81]) && Set(GameRule.desktopNumbers.hotKeys).isSuperset(of: [118, 126]))
        precondition(Set(GameRule.focusKeys.hotKeys).isSuperset(of: [7, 12, 57, 159]) && GameRule.emoji.hotKeys == [50] && GameRule.lookUp.hotKeys == [70])
        precondition(GameRules.isGameInput(0x40000) && GameRules.isGameInput(0x840000))
        precondition(!GameRules.isGameInput(0x140000) && !GameRules.isGameInput(0x100000) && !GameRules.isGameInput(0x80000))
        print("rules: ok")

        let control: CGEventFlags = [.maskControl, .maskCommand, .maskShift]
        for type in [CGEventType.leftMouseDown, .leftMouseUp, .leftMouseDragged] {
            precondition(GameRules.clickFlags(type, control, playing: true, blocksControl: true) == [.maskCommand, .maskShift])
            precondition(GameRules.clickFlags(type, control, playing: false, blocksControl: true) == control)
            precondition(GameRules.clickFlags(type, control, playing: true, blocksControl: false) == control)
        }
        for type in [CGEventType.keyDown, .keyUp, .flagsChanged, .rightMouseDown, .otherMouseDown, .scrollWheel, .mouseMoved] {
            precondition(GameRules.clickFlags(type, control, playing: true, blocksControl: true) == control)
        }
        print("control: ok")

        let java = "/Users/me/Library/Application Support/minecraft/runtime/java-runtime-delta/mac-os-arm64/java-runtime-delta/jre.bundle/Contents/Home/bin/java"
        let curse = "/Users/me/Documents/curseforge/minecraft/Install/runtime/java-runtime-epsilon/mac-os-arm64/java-runtime-epsilon/jre.bundle/Contents/Home/bin/java"
        let mojang = ["com.mojang.minecraftlauncher"], overwolf = ["com.overwolf.curseforge"]
        precondition(GameRules.isGame(id: nil, name: "java", path: java, in: mojang))
        precondition(GameRules.isGame(id: "net.java.openjdk.java", name: "java", path: java, in: mojang))
        precondition(GameRules.isGame(id: "net.java.openjdk.java", name: "java", path: curse, in: overwolf))
        precondition(GameRules.isGame(id: nil, name: "Minecraft 1.21", path: "/usr/bin/java", in: mojang))
        precondition(!GameRules.isGame(id: nil, name: "java", path: java, in: []))
        precondition(!GameRules.isGame(id: nil, name: "java", path: "/usr/bin/java", in: mojang))
        precondition(!GameRules.isGame(id: "com.mojang.minecraftlauncher", name: "Minecraft Launcher", path: "/Applications/Minecraft.app/Contents/MacOS/launcher", in: mojang))
        precondition(!GameRules.isGame(id: "com.overwolf.curseforge", name: "CurseForge", path: "/Applications/CurseForge.app/Contents/MacOS/CurseForge", in: overwolf))
        precondition(GameRules.isGame(id: "com.a.game", name: "Game", path: "/Applications/Game.app/Contents/MacOS/Game", in: ["com.a.game"]))
        precondition(GameRules.isGame(id: nil, name: "Wine Game", path: "/opt/wine", in: ["Wine Game"]))
        precondition(!GameRules.isGame(id: "com.a.game", name: "Game", path: java, in: ["com.b.game"]))
        print("minecraft: ok")

        for (old, migrated) in [(true as Bool?, true as Bool?), (false, nil), (nil, nil)] {
            let suite = "test-game-mode-migrate-\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            if let old { defaults.set(old, forKey: "ctrl-keys") }
            defaults.set(["com.apple.Terminal"], forKey: "ctrl-keys-excluded")
            GameRules.migrateControl(defaults)
            precondition(defaults.object(forKey: "game-mode-control") as? Bool == migrated)
            precondition(defaults.object(forKey: "ctrl-keys") == nil && defaults.object(forKey: "ctrl-keys-excluded") == nil)
            GameRules.migrateControl(defaults)
            precondition(defaults.object(forKey: "game-mode-control") as? Bool == migrated)
            defaults.removePersistentDomain(forName: suite)
        }
        for value in [true, false] {
            let suite = "test-game-mode-groups-\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            GameRules.retiredKeys.forEach { defaults.set(value, forKey: $0) }
            GameRules.migrateGroups(defaults)
            for rule in GameRule.allCases {
                precondition(defaults.object(forKey: rule.key) as? Bool == (rule.group == nil ? nil : value))
            }
            precondition(GameRules.retiredKeys.allSatisfy { defaults.object(forKey: $0) == nil })
            defaults.removePersistentDomain(forName: suite)
        }
        do {
            let suite = "test-game-mode-groups-\(UUID().uuidString)"
            let defaults = UserDefaults(suiteName: suite)!
            defaults.set(false, forKey: "game-mode-quit")
            defaults.set(true, forKey: GameRule.commandQ.key)
            defaults.set(false, forKey: "game-mode-search")
            GameRules.migrateGroups(defaults)
            GameRules.migrateGroups(defaults)
            precondition(defaults.object(forKey: GameRule.commandQ.key) as? Bool == true && defaults.object(forKey: GameRule.commandW.key) as? Bool == false)
            precondition([GameRule.spotlight, .siri, .emoji, .lookUp, .globe].allSatisfy { defaults.object(forKey: $0.key) as? Bool == false })
            precondition(defaults.object(forKey: GameRule.missionControl.key) == nil && defaults.object(forKey: GameRule.hide.key) == nil)
            defaults.removePersistentDomain(forName: suite)
        }
        let file = GameRules.migrated(["game-mode-control": false, "game-mode-layout": true, "game-mode-switching": true, GameRule.hide.key: false, "x": 1])
        precondition(GameRules.retiredKeys.allSatisfy { file[$0] == nil })
        precondition(file[GameRule.desktops.key] as? Bool == false && file[GameRule.controlClick.key] as? Bool == false)
        precondition(file[GameRule.swipes.key] as? Bool == true && file[GameRule.hide.key] as? Bool == false)
        precondition(file[GameRule.spotlight.key] == nil && file["x"] as? Int == 1 && file.count == 12)
        print("migration: ok")

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
        table[60] = false
        table[61] = false
        UserDefaults(suiteName: suite)!.set([60, 61], forKey: HotKeyTrace.key)
        trace().restore()
        precondition(table[60] == true && table[61] == true)
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
                for blocksQuit in [false, true] {
                    for blocksClose in [false, true] {
                        let game = GameRules.commandKeys(quit: quit, close: close, playing: true, blocksQuit: blocksQuit, blocksClose: blocksClose)
                        precondition(game.keys.isSuperset(of: [q, w]))
                        precondition(game.blocked == Set((quit || blocksQuit ? [q] : []) + (close || blocksClose ? [w] : [])))
                        let idle = GameRules.commandKeys(quit: quit, close: close, playing: false, blocksQuit: blocksQuit, blocksClose: blocksClose)
                        precondition(idle.keys == idle.blocked && idle.blocked == Set((quit ? [q] : []) + (close ? [w] : [])))
                    }
                }
            }
        }
        precondition(GameRules.commandKeys(quit: false, close: false, playing: true, blocksQuit: true, blocksClose: false).blocked == [q])
        precondition(GameRules.commandKeys(quit: false, close: false, playing: true, blocksQuit: false, blocksClose: true).blocked == [w])
        print("quit keys: ok")

        precondition(GameRules.combo(key: 49, flags: 0x80000 | 0x10000 | 0x100) == GameRules.combo(key: 49, flags: 0x80000))
        precondition(GameRules.combo(key: 123, flags: 0xA40000) == GameRules.combo(key: 123, flags: 0x840000))
        precondition(GameRules.combo(key: 49, flags: 0x100000) != GameRules.combo(key: 49, flags: 0x80000))
        precondition(GameRules.combo(key: 49, flags: 0x100000) != GameRules.combo(key: 48, flags: 0x100000))
        print("hint keys: ok")

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
