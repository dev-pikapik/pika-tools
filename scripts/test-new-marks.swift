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
        for name in ["fresh", "update", "direct", "seen", "expiry", "next", "old", "down", "website", "store", "gear"] {
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
        let older = marks("old")
        older.begin(version: "1.50.0", fresh: false)
        precondition(tabs(older) == ["keepAwake", "keyboard"], "an older version shows only what it has: \(tabs(older))")
        print("next update: ok")

        let clock2 = Clock()
        let one = marks("down", clock: clock2)
        one.begin(version: "1.50.0", fresh: false)
        one.open("keyboard")
        one.leave("keyboard")
        clock2.date += 5 * day
        let back = marks("down", clock: clock2)
        back.begin(version: "1.49.1", fresh: false)
        precondition(tabs(back).isEmpty && !back.isNew(row: "display-off"), "a downgrade shows nothing")
        let again2 = marks("down", clock: clock2)
        again2.begin(version: "1.50.0", fresh: false)
        precondition(tabs(again2) == ["keepAwake"] && !again2.isNew(row: "home-end") && again2.isNew(row: "display-off"), "what was seen does not come back: \(tabs(again2))")
        clock2.date += 17 * day
        precondition(tabs(again2).isEmpty, "the 21 days run from the first update, not from the downgrade")
        print("downgrade: ok")

        let site = marks("website", appStore: false), shop = marks("store", appStore: true)
        site.begin(version: "1.50.0", fresh: false)
        shop.begin(version: "1.50.0", fresh: false)
        site.open("keyboard")
        site.leave("keyboard")
        precondition(shop.isNew(tab: "keyboard") && shop.isNew(row: "home-end"), "two copies keep their own marks")
        let both1 = marks("seen"), both2 = marks("seen")
        both1.begin(version: "1.50.0", fresh: false)
        both2.begin(version: "1.50.0", fresh: false)
        both1.open("keepAwake")
        both2.open("keyboard")
        let third = marks("seen")
        third.begin(version: "1.50.0", fresh: false)
        precondition(tabs(third).isEmpty, "two running instances of one copy do not undo each other: \(tabs(third))")
        print("two copies: ok")

        let gear = marks("gear")
        gear.begin(version: "1.50.0", fresh: false)
        precondition(!gear.settingsOpened, "the gear dot shows until Settings is opened")
        gear.open("general")
        precondition(gear.settingsOpened && tabs(gear) == ["keepAwake", "keyboard"], "opening Settings clears the gear, not the tab dots")
        let gearLater = marks("gear")
        gearLater.begin(version: "1.50.0", fresh: false)
        precondition(gearLater.settingsOpened, "and it stays cleared")
        gearLater.begin(version: "1.51.0", fresh: false)
        precondition(!gearLater.settingsOpened, "the next update brings it back")
        print("gear: ok")

        let table = NewMarks.items
        precondition(!table.isEmpty && table.allSatisfy { !Version.parts($0.version).isEmpty })
        let source = try! String(contentsOfFile: "Sources/pika-tools/Common/SettingsWindow.swift", encoding: .utf8)
        let declaration = source.components(separatedBy: "\n").first { $0.hasPrefix("    case general") }!
        let names = declaration.replacingOccurrences(of: "case ", with: "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for item in table { precondition(names.contains(item.tab), "\(item.tab) is not a Settings tab") }
        print("table: ok")
    }
}
