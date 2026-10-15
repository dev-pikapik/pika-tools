import Foundation

@main
struct TestChromiumAXJournal {
    typealias Switched = TextFocus.Switched

    static let crashKey = "test-chromium-ax-crash"

    static func entry(_ pid: pid_t, _ id: String = "com.google.Chrome", _ attribute: String = "AXManualAccessibility") -> Switched {
        Switched(bundleID: id, pid: pid, attribute: attribute, before: false)
    }

    static func main() {
        if CommandLine.arguments.dropFirst().first == "crash" {
            Switched.save([entry(100), entry(200, "com.tinyspeck.slackmacgap", "AXEnhancedUserInterface")], crashKey)
            _exit(0)
        }

        let key = "test-chromium-ax-journal"
        defer { [key, crashKey, TextFocus.journalKey].forEach(UserDefaults.standard.removeObject) }
        let saved = [entry(100), entry(200, "com.tinyspeck.slackmacgap", "AXEnhancedUserInterface")]
        precondition(Switched.load(key).isEmpty)
        Switched.save(saved, key)
        precondition(Switched.load(key) == saved)
        precondition(Switched.load(key)[1].attribute == "AXEnhancedUserInterface" && Switched.load(key)[1].before == false)
        Switched.save([], key)
        precondition(Switched.load(key).isEmpty && UserDefaults.standard.object(forKey: key) == nil)
        print("the remembered apps survive a restart and can be cleared: ok")

        let running: [pid_t: String] = [100: "com.google.Chrome", 200: "com.tinyspeck.slackmacgap", 300: "com.microsoft.VSCode", 400: "com.apple.Safari"]
        func back(_ entries: [Switched]) -> [pid_t] {
            Switched.putBack(entries, bundleID: { running[$0] }).map(\.pid)
        }
        precondition(back([entry(100), entry(200, "com.tinyspeck.slackmacgap", "AXEnhancedUserInterface"), entry(300, "com.microsoft.VSCode")]) == [100, 200, 300])
        print("an app that still runs is put back, even though Chromium answers off while the switch is on: ok")

        precondition(back([entry(999)]).isEmpty)
        precondition(back([entry(100), entry(999), entry(300, "com.microsoft.VSCode")]) == [100, 300])
        print("an app that has quit is dropped: ok")

        precondition(back([entry(400, "com.google.Chrome")]).isEmpty)
        precondition(back([entry(100, "com.google.Chrome.beta")]).isEmpty)
        print("a different app on the same process number is left alone: ok")

        let crashed = Process()
        crashed.executableURL = Bundle.main.executableURL
        crashed.arguments = ["crash"]
        try! crashed.run()
        crashed.waitUntilExit()
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        precondition(Switched.load(crashKey) == saved)
        print("after a crash the next launch finds what was switched on: ok")

        var writes: [String] = []
        TextFocus.write = { _, on, pid in
            if !on { Thread.sleep(forTimeInterval: 0.3) }
            writes.append("\(pid) \(on) \(Switched.load(TextFocus.journalKey).map(\.pid))")
            return .success
        }
        let gone = crashed.processIdentifier
        Switched.save([entry(100)], TextFocus.journalKey)
        TextFocus.putBackAfterCrash(bundleID: { $0 == 100 ? "com.google.Chrome" : nil })
        let owner = NSObject()
        TextFocus.watch(owner, front: nil)
        precondition(TextFocus.enable("AXManualAccessibility", gone, "com.google.Chrome") == .success)
        precondition(writes == ["100 false [100]", "\(gone) true [\(gone)]"], "\(writes)")
        print("the journal holds an app before its switch changes, and putting back finishes before a new switch: ok")

        TextFocus.unwatch(owner)
        precondition(Switched.load(TextFocus.journalKey).isEmpty && writes.count == 2)
        print("switching off clears the journal: ok")
    }
}
