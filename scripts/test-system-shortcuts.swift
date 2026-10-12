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

        let names: PointerShortcuts.Names = { table, key in "\(table):\(key)" }
        func sample(_ values: [String: Any]) -> PointerShortcuts.Read { { _, key in values[key] } }
        let defaults = PointerShortcuts.rows(read: sample([:]), names: names)
        precondition(defaults.map(\.id) == [100_001, 100_002, 100_003, 100_004])
        precondition(defaults.allSatisfy { $0.pointer?.controller == .swipes && $0.controller == .swipes && $0.group == .pointer && $0.listed && !$0.assigned })
        precondition(defaults.compactMap { $0.pointer?.motions } == [[1], [2], [3], [9]])
        precondition(defaults[0].name == "trk:GNAME_DASHBOARD" && defaults[0].pointer?.fingers == 4 && defaults[0].pointer?.mouse == true)
        precondition(defaults[0].detail == "trk:GNAME_DASHBOARD_H4FINGER · mou:GNAME_2FHORIZONTALSWIPE_LABEL")
        precondition(defaults[1].name == "trk:GNAME_MISSIONCONTROL" && defaults[1].pointer?.mouse == false)
        precondition(defaults[0].pointer?.settings.absoluteString.contains("Trackpad") == true)
        let off: [String: Any] = [
            "TrackpadFourFingerHorizSwipeGesture": 0, "TrackpadThreeFingerHorizSwipeGesture": 0, "MouseTwoFingerHorizSwipeGesture": 0,
            "TrackpadFourFingerVertSwipeGesture": 0, "TrackpadThreeFingerVertSwipeGesture": 0, "MouseTwoFingerDoubleTapGesture": 0,
            "TrackpadFourFingerPinchGesture": 0, "TrackpadFiveFingerPinchGesture": 0, "TrackpadTwoFingerFromRightEdgeSwipeGesture": 0,
        ]
        precondition(PointerShortcuts.rows(read: sample(off), names: names).isEmpty)
        precondition(PointerShortcuts.rows(read: sample([:]), names: { _, _ in nil }).isEmpty)
        var three = off
        three["TrackpadThreeFingerHorizSwipeGesture"] = 2
        three["TrackpadThreeFingerVertSwipeGesture"] = 2
        three["MouseTwoFingerDoubleTapGesture"] = 3
        three["showAppExposeGestureEnabled"] = true
        let threeRows = PointerShortcuts.rows(read: sample(three), names: names)
        precondition(threeRows.map(\.id) == [100_001, 100_002])
        precondition(threeRows[0].pointer?.fingers == 3 && threeRows[0].pointer?.mouse == false && threeRows[0].detail == "trk:GNAME_DASHBOARD_H3FINGER")
        precondition(threeRows[1].name == "trk:GNAME_MISSIONCONTROL · trk:GNAME_APPEXPOSE" && threeRows[1].pointer?.motions == [2, 6])
        precondition(threeRows[1].detail == "trk:GNAME_MISSIONCONTROL_V3FINGER · trk:GNAME_APPEXPOSE_V3FINGER · mou:GNAME_MISSIONCONTROL_LABEL")
        var tapOnly = off
        tapOnly["MouseTwoFingerDoubleTapGesture"] = 3
        let tapRows = PointerShortcuts.rows(read: sample(tapOnly), names: names)
        precondition(tapRows.count == 1 && tapRows[0].pointer?.motions == [6] && tapRows[0].pointer?.trackpad == false && tapRows[0].pointer?.settings.absoluteString.contains("Mouse") == true)
        var corners = off
        corners["wvous-tr-corner"] = 2
        corners["wvous-tr-modifier"] = 0x120000
        corners["wvous-br-corner"] = 13
        corners["wvous-tl-corner"] = 1
        corners["wvous-bl-corner"] = 99
        let cornerRows = PointerShortcuts.rows(read: sample(corners), names: names)
        precondition(cornerRows.map(\.id) == [100_011, 100_013] && cornerRows.allSatisfy { $0.pointer?.controller == .cursor })
        precondition(cornerRows[0].name == "desk:Mission Control" && cornerRows[0].detail == "desk:Top Right Hot Corner" && cornerRows[0].pointer?.corner == 1)
        precondition(cornerRows[0].pointer?.modifiers == "⇧⌘" && cornerRows[1].pointer?.modifiers == "" && cornerRows[1].name == "desk:Lock Screen")
        precondition(cornerRows[0].pointer?.settings.absoluteString.contains("Desktop") == true)
        corners["wvous-tr-corner"] = 0
        precondition(PointerShortcuts.rows(read: sample(corners), names: names).map(\.id) == [100_013])
        precondition(PointerShortcuts.rows(read: sample(corners), names: names, journal: ["wvous-tr-corner": 2]).map(\.id) == [100_011, 100_013])
        precondition(PointerShortcuts.rows(read: sample(corners), names: names, journal: ["wvous-tr-corner": ""]).map(\.id) == [100_013])
        precondition(PointerShortcuts.glyphs(0x1C0000) == "⌃⌥⌘" && PointerShortcuts.glyphs(0) == "")

        let pointerRows = defaults + cornerRows
        let calmed = PointerShortcuts.paused(pointerRows, rules: all, values: [])
        precondition(calmed.blocksAll && calmed.except.isEmpty && calmed.corners == [0, 1, 2, 3])
        let noCursor = PointerShortcuts.paused(pointerRows, rules: all.subtracting([.cursor]), values: [])
        precondition(noCursor.blocksAll && noCursor.except.isEmpty && noCursor.corners.isEmpty)
        precondition(PointerShortcuts.paused(pointerRows, rules: all.subtracting([.cursor]), values: ["100011:pause"]).corners == [1])
        precondition(PointerShortcuts.paused(pointerRows, rules: all, values: ["100011:system", "100002:system"]).corners == [0, 2, 3])
        precondition(PointerShortcuts.paused(pointerRows, rules: all, values: ["100002:system"]).except == [2])
        precondition(PointerShortcuts.paused(pointerRows, rules: all, values: ["100002:system", "100004:system", "100001:pause"]).except == [2, 9])
        precondition(PointerShortcuts.paused([], rules: all, values: []).blocksAll && PointerShortcuts.paused([], rules: all, values: []).except.isEmpty)
        precondition(PointerShortcuts.paused([], rules: all, values: []).corners == [0, 1, 2, 3])
        let rulesOff = PointerShortcuts.paused(pointerRows, rules: all.subtracting([.swipes]), values: [])
        precondition(!rulesOff.blocksAll && rulesOff.except.isEmpty)
        precondition(PointerShortcuts.paused(pointerRows, rules: all.subtracting([.swipes]), values: ["100001:pause", "100003:background"]).except == [1, 3])
        precondition(PointerShortcuts.paused(pointerRows, rules: all.subtracting([.swipes]), values: ["100001:system"]).except.isEmpty)

        var holding: Bool?
        func gate(_ phase: Int64, _ motion: Int64, _ except: Set<Int64> = [], all blocksAll: Bool = false) -> Bool {
            let result = GameRules.dropsSwipe(phase: phase, motion: motion, blocksAll: blocksAll, except: except, holding: holding)
            holding = result.holding
            return result.drops
        }
        precondition([1, 2, 2, 4].map { gate($0, 1, [1]) } == [true, true, true, true] && holding == nil)
        precondition([1, 2, 2, 8].map { gate($0, 2, [1]) } == [false, false, false, false] && holding == nil)
        precondition(gate(2, 1, [1]) && holding == true)
        precondition(gate(2, 1, []) && gate(4, 1, []) && holding == nil)
        precondition(!gate(2, 1, []))
        precondition(!gate(1, 1, []) && !gate(4, 1, []) && gate(4, 9, [9]) && holding == nil)
        holding = true
        precondition(!gate(1, 1, []) && holding == false)
        precondition(!gate(2, 1, [1]) && !gate(8, 1, [1]) && holding == nil)
        precondition([1, 2, 2, 4].map { gate($0, 7, all: true) } == [true, true, true, true] && holding == nil)
        precondition([1, 2, 2, 8].map { gate($0, 2, [2], all: true) } == [false, false, false, false] && holding == nil)
        precondition(gate(1, 1, [2], all: true) && holding == true && gate(4, 1, [2], all: true) && holding == nil)
        precondition(gate(2, 3, all: true) && gate(8, 3, all: true) && holding == nil)
        precondition(!gate(2, 2, [2], all: true) && holding == false && !gate(4, 2, [2], all: true) && holding == nil)
        precondition([1, 2, 4].map { gate($0, 7) } == [false, false, false] && holding == nil)

        let buttonRecords: [String: Any] = [
            "32": ["enabled": true, "value": ["type": "button", "parameters": [1, 2, 3]]],
            "33": ["enabled": true, "value": ["type": "standard", "parameters": [65535, 126, 8650752]]],
            "500": ["enabled": false, "value": ["type": "button"]],
            "x": ["enabled": true, "value": ["type": "button"]],
            "34": ["enabled": true],
        ]
        precondition(PointerShortcuts.buttons(buttonRecords) == [32, 500])
        let metadata: [Int32: SystemShortcutCatalog.Metadata] = [32: .init(name: "Mission Control", rawName: "Mission Control", section: "expose", sectionName: "Mission Control")]
        let buttonRows = PointerShortcuts.buttonRows([32, 500], metadata: metadata, active: { _ in true }, names: names)
        precondition(buttonRows.map(\.id) == [32, 500] && buttonRows.allSatisfy { $0.group == .pointer && !$0.assigned && $0.pointer?.kind == .button })
        precondition(buttonRows[0].name == "Mission Control" && buttonRows[0].detail == "desk:Mouse Shortcut" && buttonRows[0].controller == SystemGameShortcut.controller(32))
        precondition(buttonRows[1].name == "desk:Mouse Shortcut" && buttonRows[1].detail == nil && buttonRows[1].controller == nil)
        precondition(PointerShortcuts.buttonRows([32, 500], metadata: metadata, active: { $0 == 32 }, names: names).map(\.id) == [32])
        precondition(PointerShortcuts.buttonRows([500], metadata: metadata, active: { _ in true }, names: { _, _ in nil }).isEmpty)
        precondition(buttonRows[1].mode(rules: all, overrides: [:]) == .pause && buttonRows[1].mode(rules: all, overrides: [500: .system]) == .system)

        let everything = [input] + pointerRows + buttonRows
        let picked = SystemShortcutCatalog.selected(everything, rules: all, values: ["100001:pause", "100011:pause"], appSwitcher: true)
        precondition(picked.contains(32) && picked.contains(500) && picked.contains(60) && picked.allSatisfy { !PointerShortcuts.isSynthetic($0) })
        precondition(!SystemShortcutCatalog.selected(everything, rules: all, values: ["500:system"], appSwitcher: true).contains(500))
        let suite = UserDefaults(suiteName: "pika-tools-test-pointer")!
        var switched: [Int32] = []
        HotKeyTrace(defaults: suite, isEnabled: { _ in true }, setEnabled: { id, on in if !on { switched.append(id) } }).disable(picked)
        suite.removePersistentDomain(forName: "pika-tools-test-pointer")
        precondition(switched.contains(32) && switched.allSatisfy { !PointerShortcuts.isSynthetic($0) })
        precondition(everything.allSatisfy { SettingsItem.shortcut($0).matches($0.name) })
        print("mouse buttons, gestures and hot corners: ok")

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
        let live = catalog.filter { PointerShortcuts.isSynthetic($0.id) }
        precondition(live.allSatisfy { $0.pointer != nil && $0.listed && $0.group == .pointer } && catalog.filter { $0.pointer != nil && !PointerShortcuts.isSynthetic($0.id) }.allSatisfy { $0.pointer?.kind == .button })
        precondition(SystemShortcutCatalog.selected(catalog, rules: all, values: [], appSwitcher: true).allSatisfy { !PointerShortcuts.isSynthetic($0) })
        print("live pointer rows:", live.map(\.name).joined(separator: ", "))
        print("live macOS catalogue:", records.count, "published records,", shown.count, "named actions,", catalog.count - shown.count, "hidden")
    }
}
