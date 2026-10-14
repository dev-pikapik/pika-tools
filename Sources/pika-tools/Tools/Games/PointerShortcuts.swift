import AppKit

struct PointerTrigger: Equatable {
    enum Kind: Equatable { case button, swipe, mission, pinch, edge, corner }

    var kind: Kind
    var detail: String?
    var trackpad = false
    var mouse = false
    var fingers = 0
    var corner: Int?
    var symbol = "computermouse"
    var modifiers = ""
    var motions: Set<Int64> = []
    var controller: GameRule?

    var settings: URL {
        let pane = kind == .button || kind == .corner ? "Desktop" : trackpad ? "Trackpad" : "Mouse"
        return URL(string: "x-apple.systempreferences:com.apple.\(pane)-Settings.extension")!
    }
}

enum PointerShortcuts {
    typealias Read = (_ domain: String, _ key: String) -> Any?
    typealias Names = (_ table: String, _ key: String) -> String?

    static let first: Int32 = 100_000
    static let dock = "com.apple.dock"
    static let trackpads = ["com.apple.AppleMultitouchTrackpad", "com.apple.driver.AppleBluetoothMultitouch.trackpad"]
    static let mice = ["com.apple.AppleMultitouchMouse", "com.apple.driver.AppleBluetoothMultitouch.mouse"]
    static let sides = ["tl", "tr", "bl", "br"]
    static let cornerNames = ["Top Left Hot Corner", "Top Right Hot Corner", "Bottom Left Hot Corner", "Bottom Right Hot Corner"]
    static let actions: [Int: (name: String, symbol: String)] = [
        2: ("Mission Control", "rectangle.3.group"), 3: ("Application Windows", "macwindow.on.rectangle"), 4: ("Desktop", "desktopcomputer"),
        5: ("Start Screen Saver", "sparkles"), 6: ("Disable Screen Saver", "display"), 10: ("Put Display to Sleep", "moon.zzz.fill"),
        11: ("Apps", "square.grid.3x3.fill"), 12: ("Notification Center", "bell.fill"), 13: ("Lock Screen", "lock.fill"), 14: ("Quick Note", "note.text"),
    ]

    static func isSynthetic(_ id: Int32) -> Bool { id >= first }

    static func buttons(_ configured: [String: Any]) -> Set<Int32> {
        #if APPSTORE
        // Game Mode's tap never sees otherMouseDown, so this build can't pause mouse button shortcuts; listing them would show pauses that do nothing
        return []
        #else
        Set(configured.compactMap { key, item in
            let value = (item as? [String: Any])?["value"] as? [String: Any]
            return value?["type"] as? String == "button" ? Int32(key) : nil
        })
        #endif
    }

    static func buttonRows(_ ids: Set<Int32>, metadata: [Int32: SystemShortcutCatalog.Metadata], active: (Int32) -> Bool, names: Names) -> [SystemGameShortcut] {
        let label = names("desk", "Mouse Shortcut")
        return ids.sorted().compactMap { id in
            guard active(id) else { return nil }
            let known = metadata[id]
            guard let name = SystemShortcutCatalog.nonempty(known?.name) ?? label else { return nil }
            return SystemGameShortcut(
                id: id, name: name, section: known?.section ?? "pointer", sectionName: known?.sectionName ?? name, rawName: known?.rawName ?? name,
                key: .max, character: 0, modifiers: 0, enabled: true,
                pointer: PointerTrigger(kind: .button, detail: known == nil ? nil : label, controller: SystemGameShortcut.controller(id))
            )
        }
    }

    static func paused(_ entries: [SystemGameShortcut], rules: Set<GameRule>, values: [String]) -> (blocksAll: Bool, except: Set<Int64>, corners: Set<Int>) {
        let overrides = SystemGameShortcut.overrides(values)
        let blocksAll = rules.contains(.swipes)
        let pointers = entries.filter { $0.pointer != nil }
        let isPaused = { (row: SystemGameShortcut) in row.mode(rules: rules, overrides: overrides) != .system }
        let listed = Set(pointers.compactMap { $0.pointer?.corner })
        let others = rules.contains(.cursor) ? Set(sides.indices).subtracting(listed) : []
        return (
            blocksAll,
            Set(pointers.filter { isPaused($0) != blocksAll }.flatMap { $0.pointer?.motions ?? [] }),
            Set(pointers.filter(isPaused).compactMap { $0.pointer?.corner }).union(others)
        )
    }

    static func glyphs(_ flags: Int) -> String {
        [(0x40000, "⌃"), (0x80000, "⌥"), (0x20000, "⇧"), (0x100000, "⌘")].filter { flags & $0.0 != 0 }.map(\.1).joined()
    }

    static func rows(read: Read, names: Names, journal: [String: Any] = [:]) -> [SystemGameShortcut] {
        var result: [SystemGameShortcut] = []
        func number(_ domain: String, _ key: String) -> Int? { (read(domain, key) as? NSNumber)?.intValue }
        func on(_ domains: [String], _ key: String, _ values: [Int], default fallback: Int) -> Bool {
            domains.contains { values.contains(number($0, key) ?? fallback) }
        }
        func flag(_ key: String, _ fallback: Bool) -> Bool { (read(dock, key) as? NSNumber)?.boolValue ?? fallback }
        func label(_ parts: [String?]) -> String? {
            let text = parts.compactMap(SystemShortcutCatalog.nonempty)
            return text.isEmpty ? nil : text.joined(separator: " · ")
        }
        func add(_ slot: Int32, _ name: String?, _ trigger: PointerTrigger) {
            guard let name = SystemShortcutCatalog.nonempty(name) else { return }
            result.append(SystemGameShortcut(id: first + slot, name: name, section: "pointer", sectionName: name, rawName: name, key: .max, character: 0, modifiers: 0, enabled: true, pointer: trigger))
        }

        let four = on(trackpads, "TrackpadFourFingerHorizSwipeGesture", [2], default: 2)
        let pad = four || on(trackpads, "TrackpadThreeFingerHorizSwipeGesture", [2], default: 0)
        let swipe = on(mice, "MouseTwoFingerHorizSwipeGesture", [2, 3], default: 2)
        if pad || swipe {
            add(1, names("trk", "GNAME_DASHBOARD"), PointerTrigger(
                kind: .swipe,
                detail: label([pad ? names("trk", four ? "GNAME_DASHBOARD_H4FINGER" : "GNAME_DASHBOARD_H3FINGER") : nil, swipe ? names("mou", "GNAME_2FHORIZONTALSWIPE_LABEL") : nil]),
                trackpad: pad, mouse: swipe, fingers: four ? 4 : 3, motions: [1], controller: .swipes
            ))
        }

        let up4 = on(trackpads, "TrackpadFourFingerVertSwipeGesture", [2], default: 2)
        let vertical = up4 || on(trackpads, "TrackpadThreeFingerVertSwipeGesture", [2], default: 0)
        let control = flag("showMissionControlGestureEnabled", true), windows = flag("showAppExposeGestureEnabled", false)
        let tap = on(mice, "MouseTwoFingerDoubleTapGesture", [3], default: 0)
        let pads = vertical && (control || windows)
        if pads || tap {
            let suffix = up4 ? "V4FINGER" : "V3FINGER"
            add(2, label([pads && control || tap ? names("trk", "GNAME_MISSIONCONTROL") : nil, pads && windows ? names("trk", "GNAME_APPEXPOSE") : nil]), PointerTrigger(
                kind: .mission,
                detail: label([
                    pads && control ? names("trk", "GNAME_MISSIONCONTROL_" + suffix) : nil,
                    pads && windows ? names("trk", "GNAME_APPEXPOSE_" + suffix) : nil,
                    tap ? names("mou", "GNAME_MISSIONCONTROL_LABEL") : nil,
                ]),
                trackpad: pads, mouse: tap, fingers: up4 ? 4 : 3, motions: Set((pads ? [2] : []) + (tap ? [6] : [])), controller: .swipes
            ))
        }

        let pinch4 = on(trackpads, "TrackpadFourFingerPinchGesture", [2], default: 2)
        let apps = flag("showLaunchpadGestureEnabled", true), desktop = flag("showDesktopGestureEnabled", true)
        if (pinch4 || on(trackpads, "TrackpadFiveFingerPinchGesture", [2], default: 2)) && (apps || desktop) {
            add(3, names("trk", "5FPINCHOPENCLOSE"), PointerTrigger(
                kind: .pinch,
                detail: pinch4 ? label([apps ? names("trk", "GNAME_LAUNCHPAD_LABEL") : nil, desktop ? names("trk", "GNAME_SHOWDESKTOP_LABEL") : nil]) : nil,
                trackpad: true, fingers: pinch4 ? 4 : 5, motions: [3], controller: .swipes
            ))
        }

        if on(trackpads, "TrackpadTwoFingerFromRightEdgeSwipeGesture", [3], default: 3) {
            add(4, names("trk", "GNAME_NOTIFICATION_CENTER"), PointerTrigger(
                kind: .edge, detail: names("trk", "GNAME_NOTIFICATION_CENTER_LABEL"), trackpad: true, fingers: 2, motions: [9], controller: .swipes
            ))
        }

        #if !APPSTORE
        for (index, side) in sides.enumerated() {
            let key = "wvous-\(side)-corner"
            guard let code = ((journal[key] ?? read(dock, key)) as? NSNumber)?.intValue, let action = actions[code] else { continue }
            add(10 + Int32(index), names("desk", action.name), PointerTrigger(
                kind: .corner, detail: names("desk", cornerNames[index]), corner: index, symbol: action.symbol,
                modifiers: glyphs(number(dock, "wvous-\(side)-modifier") ?? 0), controller: .cursor
            ))
        }
        #endif
        return result
    }

    static func load() -> [SystemGameShortcut] {
        (trackpads + mice + [dock]).forEach { CFPreferencesAppSynchronize($0 as CFString) }
        return rows(
            read: { CFPreferencesCopyAppValue($1 as CFString, $0 as CFString) },
            names: appleNames,
            journal: DockEdges.journal
        )
    }

    static func appleNames(_ table: String, _ key: String) -> String? {
        if tables[table] == nil {
            let bundles = ["desk": "DesktopSettings", "trk": "TrackpadExtension", "mou": "MouseExtension"]
            tables[table] = bundles[table].flatMap { Bundle(path: "/System/Library/ExtensionKit/Extensions/\($0).appex") }
                .map { SystemShortcutCatalog.strings($0, "Localizable") } ?? [:]
        }
        return SystemShortcutCatalog.nonempty(tables[table]?[key])
    }

    private static var tables: [String: [String: String]] = [:]
}
