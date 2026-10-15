import Foundation

struct RunningCopy: Equatable {
    let pid: Int32
    let bundleID: String
    let launched: Date
}

enum MainCopyChoice {
    static let websiteID = "com.pesotchi.pika-tools"
    static let appStoreID = "com.pikapik.tools"

    static func family(_ bundleID: String) -> String {
        if [websiteID, appStoreID].contains(bundleID) { return "pikapik" }
        guard bundleID.hasPrefix("com.pikapik.e2e.") else { return bundleID }
        return bundleID.split(separator: ".").dropLast().joined(separator: ".")
    }

    static func peers(of me: RunningCopy, in running: [RunningCopy]) -> [RunningCopy] {
        running.filter { $0.pid != me.pid && family($0.bundleID) == family(me.bundleID) }
    }

    static func leader(_ me: RunningCopy, among peers: [RunningCopy]) -> RunningCopy {
        (peers + [me]).max { ($0.launched, $0.pid) < ($1.launched, $1.pid) } ?? me
    }

    static func takesOver(_ peers: [RunningCopy]) -> Bool {
        peers.max { ($0.launched, $0.pid) < ($1.launched, $1.pid) }.map { $0.bundleID != appStoreID } ?? false
    }

    static func journal(_ bundleID: String) -> String {
        family(bundleID) == "pikapik" ? websiteID : family(bundleID)
    }
}

enum OriginalValue {
    struct Entry: Equatable {
        let before: Bool
        let ours: Bool
    }

    static func change(_ entry: Entry?, current: Bool, to new: Bool) -> Entry? {
        let before = entry?.before ?? current
        return new == before ? nil : Entry(before: before, ours: new)
    }

    static func putBack(_ entry: Entry?, current: Bool) -> Bool? {
        guard let entry, entry.ours == current else { return nil }
        return entry.before
    }

    enum Resume: Equatable {
        case keep
        case write(Bool)
        case forget
    }

    static func resume(_ wanted: Entry?, journal: Entry?, current: Bool) -> Resume {
        if let journal {
            guard current == journal.ours else { return .forget }
            return wanted == nil ? .write(journal.before) : .keep
        }
        guard let wanted else { return .keep }
        return current == wanted.before ? .write(wanted.ours) : .forget
    }

    @discardableResult
    static func set(_ key: String, intent: String? = nil, journal: UserDefaults = .standard, current: Bool, to new: Bool, write: (Bool) -> Void) -> Entry? {
        let entry = change(load(key, journal: journal), current: current, to: new)
        if let intent { save(entry, intent) }
        if entry != nil { save(entry, key, journal: journal) }
        write(new)
        if entry == nil { save(nil, key, journal: journal) }
        return entry
    }

    static func same(_ value: Int?, _ other: Int?) -> Bool {
        guard let value, let other else { return value == other }
        let a = Int(Int32(truncatingIfNeeded: value)), b = Int(Int32(truncatingIfNeeded: other))
        return abs(a - b) <= abs(b) / 100
    }

    static func putBack(_ before: [String: Int], ours: [String: [Int]], current: [String: Int]) -> [String: Int] {
        before.filter { key, value in !same(current[key], value) && (ours[key] ?? []).contains { same(current[key], $0) } }
    }

    static func isBack(_ before: [String: Int], ours: [String: [Int]], current: [String: Int]) -> Bool {
        putBack(before, ours: ours, current: current).isEmpty
    }

    static func load(_ key: String, journal: UserDefaults = .standard) -> Entry? {
        guard let saved = journal.array(forKey: key) as? [Bool], saved.count == 2 else { return nil }
        return Entry(before: saved[0], ours: saved[1])
    }

    static func save(_ entry: Entry?, _ key: String, journal: UserDefaults = .standard) {
        journal.set(entry.map { [$0.before, $0.ours] }, forKey: key)
    }
}
