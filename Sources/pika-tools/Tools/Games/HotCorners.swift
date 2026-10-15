import Foundation

#if !APPSTORE
enum HotCorners {
    private static let journalKey = "hot-corners-before", dock = "com.apple.dock" as CFString

    static func key(_ side: String) -> String { "wvous-\(side)-corner" }

    static var before: [String: Int] { UserDefaults.standard.dictionary(forKey: journalKey) as? [String: Int] ?? [:] }

    static func choose(_ action: Int, current: Int, saved: [String: Int], side: String) -> (saved: [String: Int], write: Int?) {
        guard action != current else { return (saved, nil) }
        var saved = saved
        if saved[side] == nil { saved[side] = current }
        return (saved, action)
    }

    static func putBack(current: Int, saved: [String: Int], side: String) -> (saved: [String: Int], write: Int?) {
        var saved = saved
        guard let original = saved.removeValue(forKey: side) else { return (saved, nil) }
        return (saved, original == current ? nil : original)
    }

    static func choose(_ action: Int, side: String) { apply(side) { choose(action, current: $0, saved: before, side: side) } }

    static func putBack(side: String) { apply(side) { putBack(current: $0, saved: before, side: side) } }

    static func putBackAll() {
        CFPreferencesAppSynchronize(dock)
        var saved = before, wrote = false
        for side in saved.keys {
            let name = key(side) as CFString
            let plan = putBack(current: (CFPreferencesCopyAppValue(name, dock) as? NSNumber)?.intValue ?? 0, saved: saved, side: side)
            saved = plan.saved
            guard let value = plan.write else { continue }
            CFPreferencesSetAppValue(name, value as CFNumber, dock)
            wrote = true
        }
        UserDefaults.standard.set(saved.isEmpty ? nil : saved, forKey: journalKey)
        guard wrote else { return }
        CFPreferencesAppSynchronize(dock)
        _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/killall"), arguments: ["Dock"])
    }

    private static func apply(_ side: String, _ plan: (Int) -> (saved: [String: Int], write: Int?)) {
        CFPreferencesAppSynchronize(dock)
        let name = key(side) as CFString
        let current = (CFPreferencesCopyAppValue(name, dock) as? NSNumber)?.intValue ?? 0
        let result = plan(current)
        UserDefaults.standard.set(result.saved.isEmpty ? nil : result.saved, forKey: journalKey)
        guard let value = result.write else { return }
        CFPreferencesSetAppValue(name, value as CFNumber, dock)
        CFPreferencesAppSynchronize(dock)
        _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/killall"), arguments: ["Dock"])
    }
}
#endif
