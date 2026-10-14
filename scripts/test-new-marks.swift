import Foundation

@main
enum TestNewMarks {
    static let day: TimeInterval = 24 * 3600
    static let items = [
        NewItem(version: "1.50.0", tab: "keepAwake", row: "display-off", build: .appStore),
        NewItem(version: "1.50.0", tab: "keyboard", row: "home-end", build: .appStore),
        NewItem(version: "1.50.0", tab: "keyboard", row: "layout-fix"),
        NewItem(version: "1.50.0", tab: "mouse", build: .direct),
        NewItem(version: "1.51.0", tab: "sound", row: "app-volume"),
    ]

    final class Clock {
        var date = Date(timeIntervalSince1970: 1_800_000_000)
    }

    static func store(_ name: String) -> UserDefaults {
        UserDefaults(suiteName: "pika-test-new-marks-\(name)")!
    }

    static func marks(_ name: String, appStore: Bool = true, clock: Clock = Clock()) -> NewMarks {
        NewMarks(items: items, defaults: store(name), appStore: appStore, now: { clock.date })
    }

    static func tabs(_ marks: NewMarks) -> [String] { marks.unseenTabs.sorted() }

    static func main() {
        for name in ["fresh", "update", "direct", "seen", "expiry", "next", "old"] {
            UserDefaults.standard.removePersistentDomain(forName: "pika-test-new-marks-\(name)")
        }

        let fresh = marks("fresh")
        fresh.begin(version: "1.50.0", fresh: true)
        precondition(tabs(fresh).isEmpty && !fresh.isNew(row: "home-end"), "a fresh install shows nothing")
        let again = marks("fresh")
        again.begin(version: "1.50.0", fresh: false)
        precondition(tabs(again).isEmpty, "and still nothing on the second launch")
        print("fresh install: ok")

        let before = marks("update")
        precondition(tabs(before).isEmpty, "nothing before the launch logic ran")
        before.begin(version: "1.50.0", fresh: false)
        precondition(tabs(before) == ["keepAwake", "keyboard"], "App Store 1.50.0 items: \(tabs(before))")
        precondition(before.isNew(tab: "keyboard") && !before.isNew(tab: "sound"))
        precondition(before.isNew(row: "layout-fix") && before.isNew(row: "display-off") && !before.isNew(row: "app-volume"))
        let stored = store("update")
        stored.set("1.49.1", forKey: "new-marks-version")
        stored.removeObject(forKey: "new-marks-from")
        let upgrade = NewMarks(items: items, defaults: stored, appStore: true)
        upgrade.begin(version: "1.50.0", fresh: false)
        precondition(tabs(upgrade) == ["keepAwake", "keyboard"], "1.49.1 to 1.50.0: \(tabs(upgrade))")
        print("update: ok")

        let direct = marks("direct", appStore: false)
        direct.begin(version: "1.50.0", fresh: false)
        precondition(tabs(direct) == ["keyboard", "mouse"], "website 1.50.0 items: \(tabs(direct))")
        precondition(!direct.isNew(row: "home-end") && direct.isNew(row: "layout-fix") && !direct.isNew(row: "display-off"))
        let dev = marks("direct", appStore: true)
        dev.begin(version: "1.49.1", fresh: false)
        precondition(tabs(dev).isEmpty, "the running version is older than the item")
        print("builds: ok")

        let seen = marks("seen")
        seen.begin(version: "1.50.0", fresh: false)
        seen.open("keyboard")
        precondition(tabs(seen) == ["keepAwake"] && seen.isNew(row: "home-end"), "opening clears the dot, not the tag")
        seen.leave("keyboard")
        precondition(!seen.isNew(row: "home-end") && !seen.isNew(row: "layout-fix") && seen.isNew(row: "display-off"))
        let relaunch = marks("seen")
        relaunch.begin(version: "1.50.0", fresh: false)
        precondition(tabs(relaunch) == ["keepAwake"] && !relaunch.isNew(row: "home-end"), "what was seen stays seen")
        print("seen: ok")

        let clock = Clock()
        let expiry = marks("expiry", clock: clock)
        expiry.begin(version: "1.50.0", fresh: false)
        clock.date += 20 * day
        precondition(tabs(expiry) == ["keepAwake", "keyboard"], "still new after 20 days")
        clock.date += 2 * day
        precondition(tabs(expiry).isEmpty && !expiry.isNew(row: "home-end"), "gone after 21 days")
        let late = marks("expiry", clock: clock)
        late.begin(version: "1.50.0", fresh: false)
        precondition(tabs(late).isEmpty, "a relaunch does not restart the 21 days")
        print("expiry: ok")

        let first = marks("next")
        first.begin(version: "1.50.0", fresh: false)
        first.open("keyboard")
        let next = marks("next")
        next.begin(version: "1.51.0", fresh: false)
        precondition(tabs(next) == ["sound"] && next.isNew(row: "app-volume") && !next.isNew(row: "home-end"), "only the newest update shows: \(tabs(next))")
        let skipped = marks("old")
        skipped.begin(version: "1.49.0", fresh: false)
        skipped.begin(version: "1.51.0", fresh: false)
        precondition(tabs(skipped) == ["keepAwake", "keyboard", "sound"], "skipping a version keeps both: \(tabs(skipped))")
        let down = marks("old")
        down.begin(version: "1.50.0", fresh: false)
        precondition(tabs(down).isEmpty, "a downgrade shows nothing")
        print("next update: ok")

        let table = NewMarks.items
        precondition(!table.isEmpty && table.allSatisfy { !Version.parts($0.version).isEmpty })
        let source = try! String(contentsOfFile: "Sources/pika-tools/Common/SettingsWindow.swift", encoding: .utf8)
        let declaration = source.components(separatedBy: "\n").first { $0.hasPrefix("    case general") }!
        let names = declaration.replacingOccurrences(of: "case ", with: "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for item in table { precondition(names.contains(item.tab), "\(item.tab) is not a Settings tab") }
        print("table: ok")
    }
}
