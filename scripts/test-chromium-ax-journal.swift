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
        defer { UserDefaults.standard.removeObject(forKey: key); UserDefaults.standard.removeObject(forKey: crashKey) }
        let saved = [entry(100), entry(200, "com.tinyspeck.slackmacgap", "AXEnhancedUserInterface")]
        precondition(Switched.load(key).isEmpty)
        Switched.save(saved, key)
        precondition(Switched.load(key) == saved)
        precondition(Switched.load(key)[1].attribute == "AXEnhancedUserInterface" && Switched.load(key)[1].before == false)
        Switched.save([], key)
        precondition(Switched.load(key).isEmpty && UserDefaults.standard.object(forKey: key) == nil)
        print("the remembered apps survive a restart and can be cleared: ok")

        let running: [pid_t: String] = [100: "com.google.Chrome", 200: "com.tinyspeck.slackmacgap", 300: "com.microsoft.VSCode", 400: "com.apple.Safari"]
        var on: Set<String> = ["100.AXManualAccessibility", "200.AXEnhancedUserInterface", "300.AXManualAccessibility", "400.AXManualAccessibility"]
        func back(_ entries: [Switched]) -> [pid_t] {
            Switched.putBack(entries, bundleID: { running[$0] }, isOn: { on.contains("\($0).\($1)") }).map(\.pid)
        }
        precondition(back([entry(100), entry(200, "com.tinyspeck.slackmacgap", "AXEnhancedUserInterface"), entry(300, "com.microsoft.VSCode")]) == [100, 200, 300])
        print("an app that still runs and still holds our value is put back: ok")

        precondition(back([entry(999)]).isEmpty)
        precondition(back([entry(100), entry(999), entry(300, "com.microsoft.VSCode")]) == [100, 300])
        print("an app that has quit is dropped: ok")

        precondition(back([entry(400, "com.google.Chrome")]).isEmpty)
        precondition(back([entry(100, "com.google.Chrome.beta")]).isEmpty)
        print("a different app on the same process number is left alone: ok")

        on.remove("100.AXManualAccessibility")
        precondition(back([entry(100), entry(300, "com.microsoft.VSCode")]) == [300])
        precondition(back([entry(100, "com.google.Chrome", "AXEnhancedUserInterface")]).isEmpty)
        print("a switch that is already off is left as the user has it: ok")

        let crashed = Process()
        crashed.executableURL = Bundle.main.executableURL
        crashed.arguments = ["crash"]
        try! crashed.run()
        crashed.waitUntilExit()
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        precondition(Switched.load(crashKey) == saved)
        print("after a crash the next launch finds what was switched on: ok")
    }
}
