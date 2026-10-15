import Foundation

#if !APPSTORE
enum HotCorners {
    private static let journalKey = "hot-corners-before", oursKey = "hot-corners-ours", dock = "com.apple.dock" as CFString

    static func key(_ side: String) -> String { "wvous-\(side)-corner" }

    static var before: [String: Int] { UserDefaults.standard.dictionary(forKey: journalKey) as? [String: Int] ?? [:] }

    static func choose(_ action: Int, current: Int, saved: [String: Int], side: String) -> (saved: [String: Int], write: Int?) {
        guard action != current else { return (saved, nil) }
        var saved = saved
        if saved[side] == nil { saved[side] = current }
        return (saved, action)
    }

    static var ours: [String: Int] { UserDefaults.standard.dictionary(forKey: oursKey) as? [String: Int] ?? [:] }

    static func putBack(current: Int, saved: [String: Int], ours: Int? = nil, side: String) -> (saved: [String: Int], write: Int?) {
        var saved = saved
        guard let original = saved.removeValue(forKey: side) else { return (saved, nil) }
        guard ours.map({ $0 == current }) ?? true else { return (saved, nil) }
        return (saved, original == current ? nil : original)
    }

    static func choose(_ action: Int, side: String) { apply(side) { choose(action, current: $0, saved: before, side: side) } }

    static func putBack(side: String) { apply(side) { putBack(current: $0, saved: before, side: side) } }

    static func putBackAll() {
        CFPreferencesAppSynchronize(dock)
        var saved = before, wrote = false
        let ours = ours
        for side in saved.keys {
            let name = key(side) as CFString
            let plan = putBack(current: (CFPreferencesCopyAppValue(name, dock) as? NSNumber)?.intValue ?? 0, saved: saved, ours: ours[side], side: side)
            saved = plan.saved
            guard let value = plan.write else { continue }
            CFPreferencesSetAppValue(name, value as CFNumber, dock)
            wrote = true
        }
        if wrote {
            CFPreferencesAppSynchronize(dock)
            _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/killall"), arguments: ["Dock"])
        }
        remember(saved, [:])
    }

    static func kept(_ old: [String: Int], _ new: [String: Int]) -> [String: Int] {
        old.merging(new) { $1 }
    }

    private static func apply(_ side: String, _ plan: (Int) -> (saved: [String: Int], write: Int?)) {
        CFPreferencesAppSynchronize(dock)
        let name = key(side) as CFString
        let current = (CFPreferencesCopyAppValue(name, dock) as? NSNumber)?.intValue ?? 0
        let result = plan(current)
        var written = ours
        written[side] = result.saved[side] == nil ? nil : (result.write ?? written[side])
        remember(kept(before, result.saved), kept(ours, written))
        if let value = result.write {
            CFPreferencesSetAppValue(name, value as CFNumber, dock)
            CFPreferencesAppSynchronize(dock)
            _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/killall"), arguments: ["Dock"])
        }
        remember(result.saved, written)
    }

    private static func remember(_ saved: [String: Int], _ ours: [String: Int]) {
        UserDefaults.standard.set(saved.isEmpty ? nil : saved, forKey: journalKey)
        UserDefaults.standard.set(ours.isEmpty ? nil : ours, forKey: oursKey)
    }
}
#endif
