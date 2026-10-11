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
        precondition(SystemShortcutCatalog.nonempty(nil) == nil)
        precondition(SystemShortcutCatalog.nonempty(" \n\t") == nil)
        let unnamed = SystemGameShortcut(id: 10_000, name: " \n", section: "other", sectionName: "", rawName: "", key: .max, character: 0, modifiers: 0, enabled: false)
        precondition(!unnamed.listed && unnamed.group == .other && unnamed.description == .other)
        precondition(input.group == .language && emergency.group == .windows)
        let inputItem = SettingsItem.shortcut(input)
        let nextInputItem = SettingsItem.shortcut(entry(61))
        precondition(inputItem.title == nextInputItem.title && inputItem.id != nextInputItem.id)
        precondition(inputItem.matches("Ctrl+Space") && !inputItem.matches("Command+Space"))
        precondition(inputItem.matches("Switch language"))
        let model = SettingsWindow.Model()
        model.systemShortcuts = [input, entry(61)]
        model.open(nextInputItem)
        precondition(model.selection == .games && model.highlightedShortcut?.id == 61)
        let dock = SystemGameShortcut(id: 52, name: "Toggle Dock hiding", section: "other", sectionName: "", rawName: "Turn Dock Hiding On/Off", key: 2, character: 100, modifiers: 0x180000, enabled: true)
        precondition(dock.detail == nil && input.detail != nil && unnamed.detail != nil)
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
        let shown = catalog.filter(\.listed)
        precondition(!shown.isEmpty && shown.allSatisfy { !$0.sectionName.isEmpty && $0.group != .other && $0.description != .other })
        precondition(catalog.filter { !$0.listed }.allSatisfy { $0.rawName.isEmpty && $0.controller == nil && !$0.emergency })
        precondition(shown.allSatisfy { SettingsItem.shortcut($0).matches($0.name) })
        let byID = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        precondition([(16, 15), (18, 17), (20, 19), (22, 21), (154, 53), (166, 53), (155, 54), (165, 54)].allSatisfy { byID[$0.0] == nil || byID[$0.1]?.listed != true || byID[$0.0]?.name == byID[$0.1]?.name })
        precondition(entry(6, key: 53, modifiers: 0x1A0000).emergency && !entry(58, key: 53, modifiers: 0x80000).emergency && !entry(73, key: 53, modifiers: 0x100000).emergency)
        precondition(catalog.filter { $0.section == "screenshots" }.count >= 5)
        precondition(catalog.filter { $0.id == 60 || $0.id == 61 }.count == 2)
        precondition(shown.allSatisfy { !$0.description.text.isEmpty && !$0.group.title.isEmpty && !$0.group.detail.isEmpty })
        precondition(GameShortcutGroup.allCases.reduce(0) { count, group in count + shown.filter { $0.group == group }.count } == shown.count)
        precondition(Set(catalog.filter { $0.section == "screenshots" }.map(\.group)) == [.screenshots])
        print("live macOS catalogue:", records.count, "published records,", shown.count, "named actions,", catalog.count - shown.count, "hidden")
    }
}
