import AppKit
import Carbon

@main
struct TestSystemShortcuts {
    static func entry(_ id: Int32, key: UInt16 = 49, modifiers: UInt64 = 0x40000) -> SystemGameShortcut {
        SystemGameShortcut(id: id, name: "Example", section: "input_sources", sectionName: "Input Sources", rawName: "Example", key: key, character: 32, modifiers: modifiers, enabled: true)
    }

    static func main() {
        let all = Set(GameRule.allCases)
        let input = entry(60)
        let screenshot = entry(15, key: 20, modifiers: 0x120000)
        let emergency = entry(0, key: 53, modifiers: 0x180000)
        precondition(input.mode(rules: all, overrides: [:]) == .background)
        precondition(input.mode(rules: all, overrides: [60: .pause]) == .pause)
        precondition(input.mode(rules: all, overrides: [60: .system]) == .system)
        precondition(input.mode(rules: all.subtracting([.focusKeys]), overrides: [:]) == .system)
        precondition(screenshot.mode(rules: all, overrides: [:]) == .pause)
        precondition(screenshot.mode(rules: all, overrides: [15: .background]) == .pause)
        precondition(emergency.mode(rules: all, overrides: [0: .pause]) == .system)
        let parsed = SystemGameShortcut.overrides(["60:pause", "61:background", "15:system", "bad", "-1:pause", "60:unknown"])
        precondition(parsed == [60: .pause, 61: .background, 15: .system])
        let selected = SystemShortcutCatalog.selected([input, screenshot, emergency], rules: all, values: ["15:system"], appSwitcher: true)
        precondition(selected.contains(60) && !selected.contains(15) && !selected.contains(0))
        let changed = entry(60, key: 40, modifiers: 0x120000)
        let bindings = SystemShortcutCatalog.languageBindings([changed], rules: all, values: [], disabled: [60])
        let newKey = GameRules.combo(key: 40, flags: 0x120000)
        precondition(bindings[newKey]?.direction == .previous && bindings[newKey]?.automatic == true)
        precondition(bindings[GameRules.combo(key: 49, flags: 0x40000)] == nil)
        precondition(SystemShortcutCatalog.languageBindings([input], rules: all, values: [], disabled: []).isEmpty)
        let duplicate = SystemShortcutCatalog.languageBindings([entry(61), input], rules: all, values: ["60:background"], disabled: [60, 61])
        precondition(duplicate.count == 1 && duplicate.values.first?.automatic == false)
        precondition(!GameRules.blocksAppShortcut(key: kVK_Tab, flags: .maskCommand, rules: all, allowed: [GameRules.combo(key: Int64(kVK_Tab), flags: CGEventFlags.maskCommand.rawValue)]))
        let discovered = SystemShortcutCatalog.discover(count: 3, known: [90_000]) { [60, 4000, 90_000].contains($0) }
        precondition(discovered == [60, 4000, 90_000])
        print("catalogue policies and remapped keys: ok")

        var intent = GameInputIntent()
        intent.changed(.maskControl, at: 1_000_000_000)
        precondition(intent.allows(49, flags: .maskControl, at: 1_100_000_000))
        intent.pressed(13, down: true)
        precondition(!intent.allows(49, flags: .maskControl, at: 1_150_000_000))
        intent.pressed(13, down: false)
        precondition(!intent.allows(49, flags: .maskControl, at: 1_700_000_000))
        intent.changed([], at: 1_800_000_000)
        intent.changed(.maskControl, at: 2_000_000_000)
        precondition(intent.allows(49, flags: .maskControl, at: 2_100_000_000))
        precondition(!GameInputIntent(held: [13]).allows(49, flags: .maskControl, at: 2_100_000_000))
        print("held game keys and deliberate shortcuts: ok")

        var native: Unmanaged<CFArray>?
        precondition(CopySymbolicHotKeys(&native) == noErr)
        let records = native!.takeRetainedValue() as! [[String: Any]]
        let catalog = SystemShortcutCatalog.load()
        precondition(catalog.count >= records.count)
        precondition(Set(catalog.map(\.id)).count == catalog.count)
        precondition(catalog.allSatisfy { !$0.name.isEmpty && !$0.sectionName.isEmpty })
        precondition(catalog.filter { $0.section == "screenshots" }.count >= 5)
        precondition(catalog.filter { $0.id == 60 || $0.id == 61 }.count == 2)
        print("live macOS catalogue:", records.count, "published records,", catalog.count, "actions found")
    }
}
