import SwiftUI

#if APPSTORE
private let appStore = true
#else
private let appStore = false
#endif

enum PetCounter: String {
    case visits, steps, lifts, flights, jumps, leaps, climbs, tumbles, catches, kicks, plays, phrases
    case pages, github, tried, dawn, night, weekend, days, awards
}

enum PetAward: String, CaseIterable, Identifiable {
    case hello, stroll, traveller, marathon
    case lift, flyer, cosmonaut, jumper, hurdler, climber, tumbler, rescuer, striker, playmaker
    case chatter, explorer, github, stylist
    case lark, owl, weekend, week, month, hundred
    case collector

    enum Kind { case walk, play, friend, time, legend }

    static var all: [PetAward] { allCases.filter { $0 != .github || !appStore } }

    static var pages: [SettingsTab] { SettingsTab.allCases.filter { !appStore || ($0 != .fans && $0 != .animations) } }

    var id: Self { self }

    var kind: Kind {
        switch self {
        case .stroll, .traveller, .marathon: .walk
        case .lift, .flyer, .cosmonaut, .jumper, .hurdler, .climber, .tumbler, .rescuer, .striker, .playmaker: .play
        case .hello, .chatter, .explorer, .github, .stylist: .friend
        case .lark, .owl, .weekend, .week, .month, .hundred: .time
        case .collector: .legend
        }
    }

    var counter: PetCounter {
        switch self {
        case .hello: .visits
        case .stroll, .traveller, .marathon: .steps
        case .lift: .lifts
        case .flyer, .cosmonaut: .flights
        case .jumper: .jumps
        case .hurdler: .leaps
        case .climber: .climbs
        case .tumbler: .tumbles
        case .rescuer: .catches
        case .striker: .kicks
        case .playmaker: .plays
        case .chatter: .phrases
        case .explorer: .pages
        case .github: .github
        case .stylist: .tried
        case .lark: .dawn
        case .owl: .night
        case .weekend: .weekend
        case .week, .month, .hundred: .days
        case .collector: .awards
        }
    }

    var goal: Int {
        switch self {
        case .hello, .github, .lark, .owl: 1
        case .stroll: 10_000
        case .traveller: 100_000
        case .marathon: 1_000_000
        case .lift, .flyer, .climber, .stylist: 10
        case .cosmonaut, .jumper, .striker: 100
        case .hurdler, .tumbler, .playmaker, .chatter: 25
        case .rescuer: 5
        case .weekend: 2
        case .week: 7
        case .month: 30
        case .hundred: 100
        case .explorer: Self.pages.count
        case .collector: Self.all.count - 1
        }
    }

    var items: [PetItem] {
        switch self {
        case .hello: [.party]
        case .stroll: [.beanie, .scarf]
        case .traveller: [.cowboy, .bandana]
        case .marathon: [.skates]
        case .lift: [.bunny]
        case .flyer: [.cape]
        case .cosmonaut: [.helmet, .suit]
        case .jumper: [.propeller]
        case .hurdler: [.boots]
        case .climber: [.pirate]
        case .tumbler: [.viking]
        case .rescuer: [.mask, .hero]
        case .striker: [.stripes]
        case .playmaker: [.balloon]
        case .chatter: [.hearts]
        case .explorer: appStore ? [.detective, .labcoat] : [.detective]
        case .github: [.labcoat]
        case .stylist: [.round, .tutu]
        case .lark: [.flowers, .wings]
        case .owl: [.wizard]
        case .weekend: [.overalls]
        case .week: [.hoodie]
        case .month: [.tophat, .tux]
        case .hundred: [.crown]
        case .collector: [.angel]
        }
    }

    var symbol: String {
        switch self {
        case .hello: "hand.wave.fill"
        case .stroll: "pawprint.fill"
        case .traveller: "map.fill"
        case .marathon: "flag.checkered"
        case .lift: "arrow.up"
        case .flyer: "paperplane.fill"
        case .cosmonaut: "moon.stars.fill"
        case .jumper: "hare.fill"
        case .hurdler: "cursorarrow.rays"
        case .climber: "mountain.2.fill"
        case .tumbler: "tornado"
        case .rescuer: "heart.fill"
        case .striker: "soccerball"
        case .playmaker: "hand.point.up.left.fill"
        case .chatter: "bubble.left.fill"
        case .explorer: "binoculars.fill"
        case .github: "chevron.left.forwardslash.chevron.right"
        case .stylist: "tshirt.fill"
        case .lark: "sunrise.fill"
        case .owl: "moon.zzz.fill"
        case .weekend: "sun.max.fill"
        case .week, .month, .hundred: "calendar"
        case .collector: "trophy.fill"
        }
    }

    var title: String {
        switch self {
        case .hello: String(localized: "First Hello")
        case .stroll: String(localized: "Little Walk")
        case .traveller: String(localized: "Traveler")
        case .marathon: String(localized: "Marathon")
        case .lift: String(localized: "Up We Go")
        case .flyer: String(localized: "Frequent Flyer")
        case .cosmonaut: String(localized: "Cosmonaut")
        case .jumper: String(localized: "Bouncy")
        case .hurdler: String(localized: "Hurdler")
        case .climber: String(localized: "Climber")
        case .tumbler: String(localized: "Tumbler")
        case .rescuer: String(localized: "Safe Hands")
        case .striker: String(localized: "Striker")
        case .playmaker: String(localized: "Playmate")
        case .chatter: String(localized: "Chatterbox")
        case .explorer: String(localized: "Explorer")
        case .github: String(localized: "Open Source")
        case .stylist: String(localized: "Stylist")
        case .lark: String(localized: "Early Bird")
        case .owl: String(localized: "Night Owl")
        case .weekend: String(localized: "Weekend Buddy")
        case .week: String(localized: "One Week")
        case .month: String(localized: "One Month")
        case .hundred: String(localized: "Hundred Days")
        case .collector: String(localized: "Collector")
        }
    }

    var hint: String {
        switch self {
        case .hello: String(localized: "Open your pet’s wardrobe.")
        case .stroll: String(localized: "Your pet walks 10,000 steps.")
        case .traveller: String(localized: "Your pet walks 100,000 steps.")
        case .marathon: String(localized: "Your pet walks a million steps.")
        case .lift: String(localized: "Pick up your pet 10 times.")
        case .flyer: String(localized: "Throw your pet high 10 times.")
        case .cosmonaut: String(localized: "Throw your pet high 100 times.")
        case .jumper: String(localized: "Your pet jumps 100 times.")
        case .hurdler: String(localized: "Your pet jumps over the pointer 25 times.")
        case .climber: String(localized: "Your pet climbs onto a window 10 times.")
        case .tumbler: String(localized: "Your pet tumbles 25 times.")
        case .rescuer: String(localized: "Catch your pet in midair 5 times.")
        case .striker: String(localized: "Your pet kicks the ball 100 times.")
        case .playmaker: String(localized: "Push or throw the ball 25 times.")
        case .chatter: String(localized: "Your pet talks to you 25 times.")
        case .explorer: String(localized: "Open every page in Settings.")
        case .github: String(localized: "Visit pikapik on GitHub.")
        case .stylist: String(localized: "Try on 10 different things.")
        case .lark: String(localized: "Keep your pet company between 5 and 7 in the morning.")
        case .owl: String(localized: "Keep your pet company after midnight.")
        case .weekend: String(localized: "Spend a Saturday and a Sunday together.")
        case .week: String(localized: "Spend 7 days together.")
        case .month: String(localized: "Spend 30 days together.")
        case .hundred: String(localized: "Spend 100 days together.")
        case .collector: String(localized: "Earn every other award.")
        }
    }
}

private enum PetKey {
    static let counts = "pet-counts", awards = "pet-awards", seen = "pet-seen", fresh = "pet-fresh", outfit = "pet-outfit"
    static let all = [counts, awards, seen, fresh, outfit]
}

@Observable
final class PetProgress {
    static let shared = PetProgress()
    static let step: CGFloat = 13.44

    private let store: UserDefaults
    private(set) var counts: [String: Int] { didSet { store.set(counts, forKey: PetKey.counts) } }
    private(set) var earnedAt: [String: Date] { didSet { store.set(earnedAt, forKey: PetKey.awards) } }
    private(set) var seen: Set<String> { didSet { store.set(seen.sorted(), forKey: PetKey.seen) } }
    private(set) var fresh: [String] { didSet { store.set(fresh, forKey: PetKey.fresh) } }
    private(set) var outfit: [PetSlot: PetItem] { didSet { store.set(outfit.values.map(\.rawValue).sorted(), forKey: PetKey.outfit) } }
    private(set) var news: [PetAward] = []
    @ObservationIgnored private var pending = 0.0
    @ObservationIgnored private var lastWalked: CGFloat = 0

    init(store: UserDefaults = .standard) {
        let earned = store.dictionary(forKey: PetKey.awards) as? [String: Date] ?? [:]
        self.store = store
        counts = store.dictionary(forKey: PetKey.counts) as? [String: Int] ?? [:]
        earnedAt = earned
        seen = Set(store.stringArray(forKey: PetKey.seen) ?? [])
        fresh = store.stringArray(forKey: PetKey.fresh) ?? []
        outfit = Dictionary(
            (store.stringArray(forKey: PetKey.outfit) ?? []).compactMap(PetItem.init(rawValue:)).filter { Self.unlocks($0, earned) }.map { ($0.slot, $0) },
            uniquingKeysWith: { $1 }
        )
    }

    var hasNews: Bool { !news.isEmpty }

    var freshAwards: Int { fresh.filter { PetAward(rawValue: $0) != nil }.count }

    func count(_ counter: PetCounter) -> Int {
        switch counter {
        case .pages: PetAward.pages.filter { seen.contains("page:\($0.rawValue)") }.count
        case .tried: seen.filter { $0.hasPrefix("item:") }.count
        case .weekend: seen.filter { $0.hasPrefix("weekday:") }.count
        case .awards: PetAward.all.filter { $0 != .collector && earned($0) }.count
        default: counts[counter.rawValue] ?? 0
        }
    }

    func earned(_ award: PetAward) -> Bool { earnedAt[award.rawValue] != nil }

    func progress(_ award: PetAward) -> (current: Int, goal: Int) { (min(count(award.counter), award.goal), award.goal) }

    func unlocked(_ item: PetItem) -> Bool { Self.unlocks(item, earnedAt) }

    private static func unlocks(_ item: PetItem, _ earned: [String: Date]) -> Bool {
        item.free || PetAward.all.contains { earned[$0.rawValue] != nil && $0.items.contains(item) }
    }

    func add(_ counter: PetCounter, _ n: Int = 1) {
        counts[counter.rawValue, default: 0] += n
        check()
    }

    func mark(_ key: String) {
        guard !seen.contains(key) else { return }
        seen.insert(key)
        check()
    }

    func check() {
        while let award = PetAward.all.first(where: { !earned($0) && count($0.counter) >= $0.goal }) {
            earnedAt[award.rawValue] = Date()
            let ids = ([award.rawValue] + award.items.map(\.rawValue)).filter { !fresh.contains($0) }
            fresh += ids
            news.append(award)
        }
    }

    func clearFresh(_ ids: [String]) {
        guard fresh.contains(where: ids.contains) else { return }
        fresh.removeAll(where: ids.contains)
    }

    func wear(_ item: PetItem) {
        guard unlocked(item) else { return }
        outfit[item.slot] = outfit[item.slot] == item ? nil : item
        mark("item:\(item.rawValue)")
    }

    func wear(_ look: PetLook) {
        guard look.items.allSatisfy(unlocked) else { return }
        outfit = Dictionary(look.items.map { ($0.slot, $0) }, uniquingKeysWith: { $1 })
        look.items.forEach { mark("item:\($0.rawValue)") }
    }

    func tick(now: Date) {
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .era, for: now) ?? 0
        if day != counts["today"] {
            counts["today"] = day
            add(.days)
        }
        switch calendar.component(.hour, from: now) {
        case 0..<4 where count(.night) == 0: add(.night)
        case 5..<7 where count(.dawn) == 0: add(.dawn)
        default: break
        }
        let weekday = calendar.component(.weekday, from: now)
        if weekday == 1 || weekday == 7 { mark("weekday:\(weekday)") }
        flush()
    }

    func walk(_ walked: CGFloat) {
        if walked < lastWalked { lastWalked = 0 }
        pending += Double((walked - lastWalked) / Self.step)
        lastWalked = walked
        if pending >= 100 { flush() }
    }

    private func flush() {
        let steps = Int(pending)
        guard steps > 0 else { return }
        pending -= Double(steps)
        add(.steps, steps)
    }

    @discardableResult
    func popNews() -> PetAward? { news.isEmpty ? nil : news.removeFirst() }

    func hush() { news = [] }

    func erase() {
        counts = [:]
        earnedAt = [:]
        seen = []
        fresh = []
        outfit = [:]
        news = []
        pending = 0
        PetKey.all.forEach(store.removeObject(forKey:))
    }
}
