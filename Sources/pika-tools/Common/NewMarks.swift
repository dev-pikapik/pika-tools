import Foundation
import Observation

/// Something an update added. `tab` is a `SettingsTab` raw value, `row` an optional tool id or section id inside that tab.
struct NewItem {
    enum Build { case both, appStore, direct }

    let version: String
    let tab: String
    var row: String?
    var build = Build.both
}

/// Marks what the last update added: a dot on the tab until it is opened, a "New" tag on the row until the tab is left.
@Observable
final class NewMarks {
    static let shared = NewMarks()

    // To mark something new, add one line here with the version that ships it.
    static let items = [
        NewItem(version: "1.50.0", tab: "keepAwake", row: "display-off", build: .appStore),
        NewItem(version: "1.50.0", tab: "keyboard", row: "home-end", build: .appStore),
        NewItem(version: "1.50.0", tab: "keyboard", row: "layout-fix", build: .appStore),
        NewItem(version: "1.50.0", tab: "finder", row: "archive", build: .appStore),
        NewItem(version: "1.50.0", tab: "finder", row: "desktop-icons", build: .appStore),
        NewItem(version: "1.50.0", tab: "permissions", row: "apps-can-ask", build: .appStore),
    ]

    static let lifetime: TimeInterval = 21 * 24 * 3600
    // A copy that never ran this feature has no stored version: it came from the last release without it.
    static let lastWithout = "1.49.0"

    private static let versionKey = "new-marks-version", fromKey = "new-marks-from"
    private static let sinceKey = "new-marks-since", seenKey = "new-marks-seen"

    private let items: [NewItem]
    private let defaults: UserDefaults
    private let appStore: Bool
    private let now: () -> Date
    private var current = ""
    private var from = ""
    private var since = Date.distantPast
    private var seen = Set<String>()

    init(items: [NewItem] = NewMarks.items, defaults: UserDefaults = .standard, appStore: Bool = NewMarks.isAppStore, now: @escaping () -> Date = Date.init) {
        self.items = items
        self.defaults = defaults
        self.appStore = appStore
        self.now = now
    }

    private static var isAppStore: Bool {
        #if APPSTORE
        true
        #else
        false
        #endif
    }

    /// Call once per launch, before the app records that it has run. A fresh install has nothing to point at.
    /// The stored version is the highest this copy has run, so a downgrade and the update back to it start nothing new.
    func begin(version: String, fresh: Bool) {
        current = version
        let top = defaults.string(forKey: Self.versionKey)
        if top.map({ Version.isNewer(version, than: $0) }) ?? true {
            defaults.set(top ?? (fresh ? version : Self.lastWithout), forKey: Self.fromKey)
            defaults.set(now().timeIntervalSince1970, forKey: Self.sinceKey)
            defaults.removeObject(forKey: Self.seenKey)
            defaults.set(version, forKey: Self.versionKey)
        }
        from = defaults.string(forKey: Self.fromKey) ?? version
        since = Date(timeIntervalSince1970: defaults.double(forKey: Self.sinceKey))
        seen = Set(defaults.stringArray(forKey: Self.seenKey) ?? [])
    }

    private var fresh: [NewItem] {
        guard now() < since.addingTimeInterval(Self.lifetime) else { return [] }
        return items.filter {
            Version.isNewer($0.version, than: from) && !Version.isNewer($0.version, than: current)
                && ($0.build == .both || $0.build == (appStore ? .appStore : .direct))
        }
    }

    /// Tabs whose dot has not been cleared.
    var unseenTabs: Set<String> { Set(fresh.map(\.tab).filter { !seen.contains("tab:\($0)") }) }

    func isNew(tab: String) -> Bool { unseenTabs.contains(tab) }

    func isNew(row: String) -> Bool { fresh.contains { $0.row == row } && !seen.contains("row:\(row)") }

    /// The gear in the menu panel points at Settings; once Settings has been opened it has done its job.
    var settingsOpened: Bool { seen.contains("settings") }

    /// Opening a tab clears its dot.
    func open(_ tab: String) {
        remember("settings")
        remember("tab:\(tab)")
    }

    /// Leaving a tab clears the tags of its rows: they have been on screen.
    func leave(_ tab: String) {
        fresh.filter { $0.tab == tab }.compactMap(\.row).forEach { remember("row:\($0)") }
    }

    /// Merges with what is stored, so a second running copy of the app cannot take back what this one saw.
    private func remember(_ key: String) {
        guard !seen.contains(key) else { return }
        seen.formUnion(defaults.stringArray(forKey: Self.seenKey) ?? [])
        seen.insert(key)
        defaults.set(seen.sorted(), forKey: Self.seenKey)
    }
}
