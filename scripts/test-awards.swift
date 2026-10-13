import Foundation
import Observation

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, keepAwake, fans, speedTest, keyboard, mouse, windows, dock, finder, animations, games, pet, permissions, about

    var id: Self { self }
    var isAvailable: Bool { true }
}

final class Tally {
    var count = 0
}

@main
enum TestAwards {
    static let name = "pikapik-test-awards"
    static let keys = ["pet-counts", "pet-awards", "pet-seen", "pet-fresh", "pet-outfit"]
    static let calendar = Calendar.current

    static func moment(hour: Int, minute: Int = 30, weekday: Int) -> Date {
        calendar.nextDate(after: Date(timeIntervalSince1970: 1_767_225_600), matching: DateComponents(hour: hour, minute: minute, weekday: weekday), matchingPolicy: .nextTime)!
    }

    static func earned(_ p: PetProgress) -> Set<PetAward> {
        Set(PetAward.all.filter(p.earned))
    }

    static func satisfy(_ p: PetProgress, _ award: PetAward) {
        switch award {
        case .explorer: PetAward.pages.forEach { p.mark("page:\($0.rawValue)") }
        case .stylist: PetItem.allCases.prefix(award.goal).forEach { p.mark("item:\($0.rawValue)") }
        case .weekend:
            p.mark("weekday:1")
            p.mark("weekday:7")
        default: p.add(award.counter, award.goal)
        }
    }

    static func main() {
        let defaults = UserDefaults(suiteName: name)!
        func fresh() -> PetProgress {
            defaults.removePersistentDomain(forName: name)
            return PetProgress(store: defaults)
        }
        var p = fresh()
        precondition(keys.allSatisfy { defaults.object(forKey: $0) == nil }, "creating the progress wrote something")
        precondition(p.outfit.isEmpty && p.news.isEmpty && !p.hasNews && p.freshAwards == 0 && earned(p).isEmpty)
        print("a new pet starts with nothing and nothing is written: ok")

        let derived: Set<PetAward> = [.explorer, .stylist, .weekend, .collector]
        for award in PetAward.all where !derived.contains(award) {
            p = fresh()
            p.add(award.counter, award.goal - 1)
            precondition(!p.earned(award), "\(award) earned one short of \(award.goal)")
            precondition(p.progress(award).current == award.goal - 1 && p.progress(award).goal == award.goal)
            p.add(award.counter)
            let expected = Set(PetAward.all.filter { $0.counter == award.counter && $0.goal <= award.goal })
            precondition(earned(p) == expected, "\(award): earned \(earned(p)), expected \(expected)")
            p.add(award.counter, award.goal)
            precondition(p.progress(award).current == award.goal, "progress went past the goal")
        }
        print("each counter earns exactly its awards at their goals: ok")

        p = fresh()
        for (i, tab) in PetAward.pages.enumerated() {
            precondition(!p.earned(.explorer) && p.count(.pages) == i, "explorer after \(i) pages")
            p.mark("page:\(tab.rawValue)")
            p.mark("page:\(tab.rawValue)")
        }
        precondition(earned(p) == [.explorer])
        p = fresh()
        for tab in SettingsTab.allCases where !PetAward.pages.contains(tab) { p.mark("page:\(tab.rawValue)") }
        p.mark("page:nowhere")
        precondition(p.count(.pages) == 0 && !p.earned(.explorer), "pages outside the list counted")

        p = fresh()
        for item in PetItem.allCases.prefix(9) {
            p.mark("item:\(item.rawValue)")
            p.mark("item:\(item.rawValue)")
        }
        precondition(p.count(.tried) == 9 && !p.earned(.stylist))
        p.mark("item:\(PetItem.allCases[9].rawValue)")
        precondition(earned(p) == [.stylist])

        p = fresh()
        p.mark("weekday:7")
        p.mark("weekday:7")
        precondition(!p.earned(.weekend) && p.count(.weekend) == 1)
        p.mark("weekday:1")
        precondition(earned(p) == [.weekend])
        print("pages, tried items and weekend days count each once: ok")

        p = fresh()
        for award in PetAward.all where award != .chatter && award != .collector { satisfy(p, award) }
        precondition(!p.earned(.collector) && p.count(.awards) == PetAward.all.count - 2)
        satisfy(p, .chatter)
        precondition(p.earned(.collector) && Array(p.news.suffix(2)) == [.chatter, .collector], "collector did not follow the last award")
        p = fresh()
        PetAward.all.filter { $0 != .collector }.forEach { satisfy(p, $0) }
        precondition(earned(p) == Set(PetAward.all) && p.news.last == .collector)
        precondition(p.news.count == PetAward.all.count && Set(p.news).count == p.news.count, "an award was announced twice")
        let last = p.earnedAt[PetAward.collector.rawValue]!
        precondition(p.earnedAt.values.allSatisfy { $0 <= last }, "collector was not the last")
        precondition(p.progress(.collector).current == PetAward.all.count - 1 && p.progress(.collector).goal == PetAward.all.count - 1)
        precondition(PetItem.allCases.allSatisfy(p.unlocked), "some item can never be unlocked: \(PetItem.allCases.filter { !p.unlocked($0) })")
        for look in PetLook.all {
            precondition(Set(look.items.map(\.slot)).count == look.items.count, "\(look.id) has two items for one slot")
            p.wear(look)
            precondition(Set(p.outfit.values) == Set(look.items), "\(look.id) was not put on")
        }
        print("the collector comes last, nothing is announced twice, every item can be unlocked: ok")

        p = fresh()
        precondition(PetItem.allCases.filter(\.free).allSatisfy(p.unlocked) && PetItem.allCases.filter { !$0.free }.allSatisfy { !p.unlocked($0) })
        p.wear(.crown)
        precondition(p.outfit.isEmpty && p.count(.tried) == 0, "wore a locked item")
        p.add(.visits)
        precondition(p.unlocked(.party) && !p.unlocked(.crown))
        p.wear(.party)
        precondition(p.outfit == [.head: .party])
        p.wear(.cap)
        precondition(p.outfit == [.head: .cap], "a second hat did not replace the first")
        p.wear(.tee)
        precondition(p.outfit == [.head: .cap, .body: .tee])
        p.wear(.cap)
        precondition(p.outfit == [.body: .tee], "wearing a worn item did not take it off")
        precondition(p.count(.tried) == 3)
        precondition(defaults.stringArray(forKey: "pet-outfit") == ["tee"])

        let wizard = PetLook.all.first { $0.id == "wizard" }!
        p = fresh()
        p.wear(.tee)
        p.wear(wizard)
        precondition(p.outfit == [.body: .tee], "wore a look with locked items")
        p.add(.night)
        p.wear(wizard)
        precondition(p.outfit == [.body: .tee], "wore a look with one locked item")
        p.add(.flights, 10)
        p.wear(wizard)
        precondition(p.outfit == [.head: .wizard, .back: .cape], "a look did not replace the outfit")
        precondition(p.count(.tried) == 3)
        print("only unlocked items and looks can be worn, a hat replaces a hat: ok")

        defaults.removePersistentDomain(forName: name)
        defaults.set(["crown", "cap", "nonsense", "tee", "party"], forKey: "pet-outfit")
        precondition(PetProgress(store: defaults).outfit == [.head: .cap, .body: .tee], "locked or unknown items came back")
        defaults.set(["hello": Date()], forKey: "pet-awards")
        precondition(PetProgress(store: defaults).outfit == [.head: .party, .body: .tee], "an unlocked item was dropped")
        print("a saved outfit keeps only what is unlocked: ok")

        p = fresh()
        p.add(.visits)
        p.add(.steps, 5)
        p.mark("page:pet")
        p.wear(.tee)
        p.wear(.party)
        let again = PetProgress(store: defaults)
        precondition(again.counts == p.counts && Set(again.earnedAt.keys) == Set(p.earnedAt.keys) && again.seen == p.seen)
        precondition(again.fresh == p.fresh && again.outfit == p.outfit && again.news.isEmpty)
        precondition(defaults.stringArray(forKey: "pet-outfit") == ["party", "tee"] && defaults.stringArray(forKey: "pet-fresh") == ["hello", "party"])
        precondition(defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("pet-") }.allSatisfy(keys.contains), "stray keys")
        print("everything survives a restart under the five pet keys: ok")

        let monday = moment(hour: 12, weekday: 2)
        p = fresh()
        p.tick(now: monday)
        p.tick(now: monday.addingTimeInterval(600))
        precondition(p.count(.days) == 1, "one day counted \(p.count(.days)) times")
        for day in 1...6 {
            let next = calendar.date(byAdding: .day, value: day, to: monday)!
            p.tick(now: next)
            p.tick(now: next.addingTimeInterval(60))
            precondition(p.count(.days) == day + 1)
        }
        precondition(p.earned(.week) && !p.earned(.month))
        for (hour, minute, night, dawn) in [(0, 0, 1, 0), (3, 59, 1, 0), (4, 0, 0, 0), (4, 59, 0, 0), (5, 0, 0, 1), (6, 59, 0, 1), (7, 0, 0, 0), (12, 0, 0, 0), (23, 59, 0, 0)] {
            p = fresh()
            p.tick(now: moment(hour: hour, minute: minute, weekday: 3))
            precondition(p.count(.night) == night && p.count(.dawn) == dawn, "night \(p.count(.night)) dawn \(p.count(.dawn)) at \(hour):\(minute)")
            precondition(p.earned(.owl) == (night == 1) && p.earned(.lark) == (dawn == 1))
        }
        p = fresh()
        p.tick(now: moment(hour: 1, weekday: 3))
        p.tick(now: moment(hour: 2, weekday: 3))
        precondition(p.count(.night) == 1, "a night counted more than once")
        p = fresh()
        p.tick(now: monday)
        precondition(p.count(.weekend) == 0)
        p.tick(now: moment(hour: 12, weekday: 7))
        precondition(p.seen.contains("weekday:7") && !p.earned(.weekend))
        p.tick(now: moment(hour: 12, weekday: 1))
        precondition(p.seen.contains("weekday:1") && p.earned(.weekend))
        print("days, nights, early mornings and weekends: ok")

        let step = PetProgress.step
        p = fresh()
        p.walk(step * 10.25)
        precondition(p.count(.steps) == 0, "steps counted before 100 or a tick")
        p.tick(now: monday)
        precondition(p.count(.steps) == 10)
        p.walk(step * 20.5)
        p.tick(now: monday)
        precondition(p.count(.steps) == 20, "a fraction of a step was lost or counted twice: \(p.count(.steps))")
        p = fresh()
        p.walk(step * 99.5)
        precondition(p.count(.steps) == 0)
        p.walk(step * 100.5)
        precondition(p.count(.steps) == 100, "100 steps did not flush: \(p.count(.steps))")
        p.walk(step * 3.25)
        p.tick(now: monday)
        precondition(p.count(.steps) == 103, "a restarted walk was not counted from zero: \(p.count(.steps))")
        p = fresh()
        p.walk(step * 10_000.5)
        precondition(p.earned(.stroll) && p.count(.steps) == 10_000)
        precondition((defaults.dictionary(forKey: "pet-counts") as? [String: Int])?["steps"] == 10_000)
        print("walked distance becomes steps and survives a restart of the walk: ok")

        p = fresh()
        p.add(.visits)
        p.add(.visits)
        precondition(p.news == [.hello] && p.hasNews && p.earned(.hello))
        precondition(p.popNews() == .hello && p.popNews() == nil && !p.hasNews)
        p.add(.lifts, 10)
        precondition(p.news == [.lift] && p.fresh == ["hello", "party", "lift", "bunny"] && p.freshAwards == 2)
        p.hush()
        precondition(p.news.isEmpty && !p.hasNews && p.freshAwards == 2, "hush dropped the badge")
        p.clearFresh(["hello", "party", "lift"])
        precondition(p.fresh == ["bunny"] && p.freshAwards == 0)
        precondition(PetProgress(store: defaults).news.isEmpty)
        print("news is queued once, hush keeps the badges: ok")

        p = fresh()
        p.add(.visits)
        p.add(.steps, 3)
        p.mark("page:pet")
        p.wear(.party)
        p.walk(step * 5.5)
        p.erase()
        precondition(keys.allSatisfy { defaults.object(forKey: $0) == nil }, "erase left a key behind")
        precondition(p.counts.isEmpty && p.earnedAt.isEmpty && p.seen.isEmpty && p.fresh.isEmpty && p.outfit.isEmpty && p.news.isEmpty)
        precondition(PetAward.all.allSatisfy { !p.earned($0) } && !p.unlocked(.party))
        p.add(.visits)
        precondition(p.news == [.hello], "an erased pet could not earn again")
        print("erase forgets everything: ok")

        let writes = Tally()
        let token = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: defaults, queue: nil) { _ in writes.count += 1 }
        p = fresh()
        writes.count = 0
        p.mark("page:pet")
        let first = writes.count
        p.mark("page:pet")
        precondition(first > 0 && writes.count == first, "marking a page twice wrote twice")
        p.tick(now: monday)
        let ticked = writes.count
        p.tick(now: monday.addingTimeInterval(60))
        p.walk(step * 0.5)
        precondition(writes.count == ticked, "a repeated tick or a few steps wrote")
        NotificationCenter.default.removeObserver(token)

        p = fresh()
        let seen = Tally()
        withObservationTracking { _ = p.freshAwards } onChange: { seen.count += 1 }
        p.add(.visits)
        precondition(seen.count == 1, "the badge would not hear about a new award")
        print("repeats do not write, changes can be observed: ok")

        defaults.removePersistentDomain(forName: name)
        let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        try? FileManager.default.removeItem(at: library.appending(path: "Preferences/\(name).plist"))
    }
}
