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

    static func load(_ key: String) -> Entry? {
        guard let saved = UserDefaults.standard.array(forKey: key) as? [Bool], saved.count == 2 else { return nil }
        return Entry(before: saved[0], ours: saved[1])
    }

    static func save(_ entry: Entry?, _ key: String) {
        UserDefaults.standard.set(entry.map { [$0.before, $0.ours] }, forKey: key)
    }
}
