import AppKit

@main
struct TestMainCopy {
    static let start = Date(timeIntervalSince1970: 1_000)

    static func copy(_ pid: Int32, _ id: String, at seconds: Double) -> RunningCopy {
        RunningCopy(pid: pid, bundleID: id, launched: start.addingTimeInterval(seconds))
    }

    static func leader(_ me: RunningCopy, _ running: [RunningCopy]) -> Int32 {
        MainCopyChoice.leader(me, among: MainCopyChoice.peers(of: me, in: running)).pid
    }

    static let crashKey = "test-main-copy-crash", systemKey = "test-main-copy-system"

    static func main() {
        if CommandLine.arguments.dropFirst().first == "crash" {
            OriginalValue.save(OriginalValue.change(nil, current: false, to: true), crashKey)
            UserDefaults.standard.set(true, forKey: systemKey)
            _exit(0)
        }

        let website = MainCopyChoice.websiteID, store = MainCopyChoice.appStoreID
        precondition(MainCopyChoice.family(website) == MainCopyChoice.family(store))
        precondition(MainCopyChoice.family("com.pikapik.e2e.tools.a") == MainCopyChoice.family("com.pikapik.e2e.tools.b"))
        precondition(MainCopyChoice.family("com.pikapik.e2e.tools.a") != MainCopyChoice.family(website))
        precondition(MainCopyChoice.family("com.pesotchi.pika-tools.dev") != MainCopyChoice.family(website))
        precondition(MainCopyChoice.family("com.apple.finder") != MainCopyChoice.family(website))
        print("the website and App Store copies are one family, test and dev copies are not: ok")

        let a = copy(10, website, at: 0), b = copy(20, store, at: 60), c = copy(30, "com.apple.finder", at: 90)
        precondition(MainCopyChoice.peers(of: a, in: [a, b, c]) == [b])
        precondition(leader(a, [a]) == 10)
        precondition(leader(a, [a, b, c]) == 20 && leader(b, [a, b, c]) == 20)
        print("the copy that started last leads, other apps are ignored: ok")

        precondition(leader(a, [a]) == 10)
        let d = copy(40, website, at: 120), e = copy(50, store, at: 120)
        precondition(leader(d, [a, d, e]) == 50 && leader(e, [a, d, e]) == 50)
        print("copies that started at the same moment agree on one leader: ok")

        precondition(leader(a, [a, b, d]) == 40)
        precondition(leader(a, [a, b]) == 20)
        precondition(leader(a, [a]) == 10)
        print("when the leader quits the copy that started before it takes over: ok")

        let first = OriginalValue.change(nil, current: false, to: true)
        precondition(first == OriginalValue.Entry(before: false, ours: true))
        precondition(OriginalValue.change(first, current: true, to: false) == nil)
        precondition(OriginalValue.change(OriginalValue.Entry(before: true, ours: false), current: false, to: true) == nil)
        print("the first change remembers the original and changing back forgets it: ok")

        precondition(OriginalValue.putBack(first, current: true) == false)
        precondition(OriginalValue.putBack(first, current: false) == nil)
        precondition(OriginalValue.putBack(nil, current: true) == nil)
        precondition(OriginalValue.putBack(OriginalValue.Entry(before: true, ours: false), current: true) == nil)
        print("the original goes back only while the switch still holds our value: ok")

        let key = "test-main-copy-original"
        defer { UserDefaults.standard.removeObject(forKey: key) }
        OriginalValue.save(first, key)
        precondition(OriginalValue.load(key) == first)
        OriginalValue.save(nil, key)
        precondition(OriginalValue.load(key) == nil)
        print("the remembered original survives a restart and can be cleared: ok")

        var system = false
        var entry = OriginalValue.set(key, current: system, to: true) { value in
            precondition(OriginalValue.load(key) == first)
            system = value
        }
        precondition(system && entry == first && OriginalValue.load(key) == first)
        entry = OriginalValue.set(key, current: system, to: false) { value in
            precondition(OriginalValue.load(key) == first)
            system = value
        }
        precondition(!system && entry == nil && OriginalValue.load(key) == nil)
        print("the original is saved before the switch is written and forgotten only after it is back: ok")

        let wanted = "test-main-copy-wanted"
        defer { UserDefaults.standard.removeObject(forKey: wanted) }
        OriginalValue.set(key, intent: wanted, current: system, to: true) { value in
            precondition(OriginalValue.load(wanted) == first && OriginalValue.load(key) == first)
            system = value
        }
        precondition(system && OriginalValue.load(wanted) == first && OriginalValue.load(key) == first)
        OriginalValue.set(key, intent: wanted, current: system, to: false) { value in
            precondition(OriginalValue.load(wanted) == nil && OriginalValue.load(key) == first)
            system = value
        }
        precondition(!system && OriginalValue.load(wanted) == nil && OriginalValue.load(key) == nil)
        print("the wish to keep the switch on is written before the switch and forgotten before it is turned off: ok")

        let on = OriginalValue.Entry(before: false, ours: true)
        precondition(OriginalValue.resume(on, journal: nil, current: false) == .write(true))
        precondition(OriginalValue.resume(on, journal: nil, current: true) == .forget)
        precondition(OriginalValue.resume(on, journal: on, current: true) == .keep)
        precondition(OriginalValue.resume(on, journal: on, current: false) == .forget)
        precondition(OriginalValue.resume(nil, journal: on, current: true) == .write(false))
        precondition(OriginalValue.resume(nil, journal: on, current: false) == .forget)
        precondition(OriginalValue.resume(nil, journal: nil, current: false) == .keep)
        precondition(OriginalValue.resume(nil, journal: nil, current: true) == .keep)
        print("the main copy turns the switch on again only while it still has your old value: ok")

        var mac = true
        var remembered: OriginalValue.Entry? = on
        if case .forget = OriginalValue.resume(remembered, journal: nil, current: mac) { remembered = nil }
        mac = false
        precondition(OriginalValue.resume(remembered, journal: nil, current: mac) == .keep)
        print("a switch you changed while this copy was not the main one stays yours: ok")

        let mouse = ["linear": 0, "acceleration": 45056, "resolution": 26214400]
        let pikapik = ["linear": [1], "acceleration": [-65536], "resolution": [6553600]]
        let device = ["linear": 1, "acceleration": 4294901760, "resolution": 6553599]
        precondition(OriginalValue.putBack(mouse, ours: pikapik, current: device) == mouse)
        precondition(!OriginalValue.isBack(mouse, ours: pikapik, current: device))
        precondition(OriginalValue.isBack(mouse, ours: pikapik, current: mouse))
        print("the mouse gets its speed back even when it reports pikapik's number a little differently: ok")

        let yours = ["linear": 0, "acceleration": 65536, "resolution": 26214400]
        precondition(OriginalValue.putBack(mouse, ours: pikapik, current: yours).isEmpty)
        precondition(OriginalValue.isBack(mouse, ours: pikapik, current: yours))
        precondition(OriginalValue.putBack(["linear": 0], ours: ["linear": [1]], current: ["linear": 1]) == ["linear": 0])
        precondition(OriginalValue.isBack(["linear": 1], ours: ["linear": [1]], current: ["linear": 1]))
        print("a speed you set yourself stays and a mouse still at pikapik's speed keeps its journal: ok")

        let speeds = ["acceleration": 45056]
        let changing = ["acceleration": [65536, 98304]]
        precondition(OriginalValue.putBack(speeds, ours: changing, current: ["acceleration": 65536]) == speeds)
        precondition(OriginalValue.putBack(speeds, ours: changing, current: ["acceleration": 98304]) == speeds)
        print("a crash while the speed changes still finds pikapik's speed: ok")

        let defaults = UserDefaults.standard
        defer { defaults.removeObject(forKey: crashKey); defaults.removeObject(forKey: systemKey) }
        let crashed = Process()
        crashed.executableURL = Bundle.main.executableURL
        crashed.arguments = ["crash"]
        try! crashed.run()
        crashed.waitUntilExit()
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        let current = defaults.bool(forKey: systemKey), saved = OriginalValue.load(crashKey)
        precondition(current && saved == first)
        precondition(OriginalValue.change(saved, current: current, to: true) == first)
        let real = OriginalValue.putBack(saved, current: current)
        precondition(real == false)
        defaults.set(real, forKey: systemKey)
        OriginalValue.save(nil, crashKey)
        precondition(!defaults.bool(forKey: systemKey) && OriginalValue.load(crashKey) == nil)
        print("after a crash the next launch keeps the real original and puts it back: ok")

        processStart()
        mapping()
        handover()
        deferredActions()
        quittingStaysPassive()
    }

    static func processStart() {
        let now = Date()
        precondition(MainCopyChoice.started(getpid()).map { $0 < now } == true, "this process started before now")
        let child = Process()
        child.executableURL = URL(fileURLWithPath: "/bin/sleep")
        child.arguments = ["2"]
        let launched = Date()
        try! child.run()
        let first = MainCopyChoice.started(child.processIdentifier)
        precondition(first.map { abs($0.timeIntervalSince(launched)) < 1 } == true, "a child's start is the moment it was launched: \(String(describing: first)) vs \(launched)")
        precondition(MainCopyChoice.started(child.processIdentifier) == first, "reading a process's start twice gives the same date")
        let me = RunningCopy(pid: getpid(), bundleID: MainCopyChoice.websiteID)!, peer = RunningCopy(pid: child.processIdentifier, bundleID: MainCopyChoice.websiteID)!
        precondition(me.launched == MainCopyChoice.started(getpid()), "a copy's own date is its process's start")
        precondition(peer.launched == MainCopyChoice.started(child.processIdentifier), "a peer's date is its own process's start, not ours: \(peer.launched) vs \(String(describing: MainCopyChoice.started(child.processIdentifier)))")
        precondition(peer.launched > me.launched, "the later process is the later copy")
        child.terminate()
        child.waitUntilExit()
        precondition(MainCopyChoice.started(Int32.max) == nil && RunningCopy(pid: Int32.max, bundleID: MainCopyChoice.websiteID) == nil, "a process that does not exist has no start and is no copy")
        print("a process's start comes from the kernel: this one is in the past, a child's is its launch moment and never changes, a missing one has none: ok")
    }

    static func mapping() {
        let sentinel = Date(timeIntervalSince1970: 42)
        var asked: [Int32] = []
        let own = RunningCopy.own(started: { asked.append($0); return sentinel })
        precondition(own.pid == getpid() && own.launched == sentinel && asked == [getpid()], "a copy's own date comes from the start lookup of its own pid: \(own) \(asked)")
        precondition(RunningCopy.own().launched == MainCopyChoice.started(getpid()), "a copy's own date is the kernel start of this process")
        let unknown = RunningCopy.own(started: { _ in nil }), peer = copy(5, MainCopyChoice.websiteID, at: 5)
        precondition(unknown.launched == .distantPast && MainCopyChoice.leader(unknown, among: [peer]) == peer, "a copy that does not know its start counts as the oldest, so any other copy leads: \(unknown)")
        precondition(RunningCopy(NSRunningApplication.current) == nil, "a process LaunchServices does not know is no copy")
        let child = Process()
        child.executableURL = URL(fileURLWithPath: "/bin/sleep")
        child.arguments = ["5"]
        try! child.run()
        defer { child.terminate(); child.waitUntilExit() }
        let pid = child.processIdentifier, start = MainCopyChoice.started(child.processIdentifier)
        precondition(pid != getpid() && start != nil && start != MainCopyChoice.started(getpid()), "the child is another process with its own start")
        let app = StubApp(pid: pid, terminated: false, id: MainCopyChoice.websiteID)
        precondition(RunningCopy(app) == RunningCopy(pid: pid, bundleID: MainCopyChoice.websiteID, launched: start ?? .distantPast), "an app maps to a copy with its own pid, bundle id and kernel start: \(String(describing: RunningCopy(app)))")
        var lookedUp: [Int32] = []
        precondition(RunningCopy(app, started: { lookedUp.append($0); return sentinel })?.launched == sentinel && lookedUp == [pid], "the start lookup gets the app's pid and its answer is the date: \(lookedUp)")
        precondition(RunningCopy(app, started: { _ in nil }) == nil, "an app with no start time is no copy")
        precondition(RunningCopy(StubApp(pid: pid, terminated: true, id: MainCopyChoice.websiteID), started: { _ in sentinel }) == nil, "an app that has quit is no copy")
        precondition(RunningCopy(StubApp(pid: pid, terminated: false, id: nil), started: { _ in sentinel }) == nil, "an app with no bundle id is no copy")
        print("a running app maps to a copy with the kernel start of its own pid, our own copy to this process's start, and an unknown start counts as the oldest: ok")
    }

    static func quittingStaysPassive() {
        let website = MainCopyChoice.websiteID, store = MainCopyChoice.appStoreID
        enum Path: String, CaseIterable { case mainLeft = "the main copy leaves", timeout = "the claim times out", released = "the last copy answers", peersGone = "the other copies are gone" }
        for path in Path.allCases {
            for quitting in [true, false] {
                let older = path == .mainLeft
                let me = copy(10, website, at: older ? 10 : 30), other = copy(20, store, at: 20)
                var running = [me, other], timers: [DispatchWorkItem] = [], posted: [Notification.Name] = []
                var activated = 0, deactivated: [Bool] = []
                let main = MainCopy(me: me, running: { running }, later: { timers.append($0) }, post: { name, _ in posted.append(name) })
                Background.shared.quitting = false
                main.start(activate: { activated += 1 }, deactivate: { deactivated.append($0) })
                precondition(main.role == (older ? .passive : .waiting) && activated == 0, "\(path.rawValue): the copy starts \(older ? "passive" : "waiting"): \(main.role)")
                Background.shared.quitting = quitting
                switch path {
                case .mainLeft:
                    running = [me]
                    main.evaluate()
                case .timeout:
                    timers.forEach { $0.perform() }
                case .released:
                    main.released(by: other.pid)
                case .peersGone:
                    running = [me]
                    main.evaluate()
                }
                if quitting {
                    precondition(main.role != .main && activated == 0 && deactivated.isEmpty, "\(path.rawValue) while the copy is quitting: it never becomes main and changes nothing: \(main.role)")
                } else {
                    precondition(main.role == .main && activated == 1, "\(path.rawValue): a copy that is not quitting becomes main: \(main.role)")
                }
            }
        }
        Background.shared.quitting = false
        print("a copy that is quitting never becomes main, whether the main copy leaves, the claim times out, the last copy answers or the others are gone: ok")
    }

    static func deferredActions() {
        var deferred = DeferredActions()
        var log: [String] = []
        deferred.add { log.append("awake on") }
        deferred.add { log.append("awake off") }
        deferred.run()
        precondition(log == ["awake on", "awake off"], "both actions run, in order: \(log)")
        deferred.run()
        precondition(log.count == 2, "a second run does nothing: \(log)")
        deferred.add { log.append("late") }
        deferred.drop()
        deferred.run()
        precondition(log.count == 2, "a dropped action never runs: \(log)")
        print("Keep Awake links that arrive while the copy waits all run in order once it is main, and none after it lets go: ok")
    }

    static let original: [AnimationSetting: Double] = [.minimize: 2]
    static let wantsA: [AnimationSetting: Double] = [.bounce: 0, .dockDelay: 0]
    static let wantsB: [AnimationSetting: Double] = [.bounce: 0, .dockDelay: 0.3, .minimize: 1]
    static let tools = "com.pikapik.e2e.tools"

    static func handover() {
        let website = MainCopyChoice.websiteID, store = MainCopyChoice.appStoreID
        defer { ["journal", "local.A", "local.B", "local.C"].forEach { UserDefaults.standard.removePersistentDomain(forName: "test-main-copy.\($0)") } }
        precondition(!MainCopyChoice.takesOver([], poweringOff: false))
        precondition(!MainCopyChoice.takesOver([copy(1, store, at: 5)], poweringOff: false))
        precondition(MainCopyChoice.takesOver([copy(1, website, at: 5)], poweringOff: false))
        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 1), copy(2, store, at: 5)], poweringOff: false))
        precondition(MainCopyChoice.takesOver([copy(1, website, at: 9), copy(2, store, at: 5)], poweringOff: false))
        precondition(MainCopyChoice.journal(website) == website && MainCopyChoice.journal(store) == website)
        precondition(MainCopyChoice.journal("\(tools).a") == tools)
        precondition(MainCopyChoice.journal("\(tools).a") == MainCopyChoice.journal("\(tools).b"))
        precondition(MainCopyChoice.journal("com.apple.finder") == "com.apple.finder")
        print("the copy that comes next continues the animations unless it is the App Store one: ok")

        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 5)], poweringOff: true))
        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 9), copy(2, store, at: 5)], poweringOff: true))
        print("a copy on a Mac that is shutting down never counts on the next one: ok")

        precondition(!AnimationSetting.restartsDock([(.dockDelay, 0.3)], autohide: false))
        precondition(AnimationSetting.restartsDock([(.dockDelay, 0.3)], autohide: true))
        precondition(AnimationSetting.restartsDock([(.minimize, nil)], autohide: false))
        precondition(!AnimationSetting.restartsDock([(.windowOpen, 0)], autohide: true))
        print("the Dock restarts only for changes it shows: ok")

        for exit in Exit.allCases {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA), b = mac.party("B", "\(tools).b", 20, wantsB)
            mac.become(a)
            mac.elapse()
            var leader = a, passive = b
            for lap in 1...3 {
                for _ in 0..<2 {
                    mac.kills = []
                    swap(&leader, &passive)
                    mac.handOver(from: passive, to: leader)
                    mac.elapse()
                    precondition(mac.system == original.merging(leader.wants) { $1 }, "lap \(lap): the system holds \(leader.name)'s wishes and the originals")
                    precondition(mac.kills == [.restart(leader.name)], "lap \(lap): the Dock restarts once, by \(leader.name), while the flag is still set: \(mac.kills)")
                    precondition(!mac.flag, "lap \(lap): the flag is gone after the restart")
                }
            }
            precondition(leader === a && passive === b)
            mac.kills = []
            switch exit {
            case .mainFirst:
                mac.quit(a)
                precondition(mac.kills.isEmpty && mac.flag == false, "the main copy quits and hands over: \(mac.kills)")
                mac.become(b)
                mac.elapse()
                precondition(mac.system == original.merging(wantsB) { $1 })
                precondition(mac.kills == [.restart("B")], "B restarts the Dock once: \(mac.kills)")
                mac.kills = []
                mac.quit(b)
                precondition(mac.kills == [.putBack("B")], "the last copy puts back: \(mac.kills)")
            case .passiveFirst:
                mac.quit(b)
                precondition(mac.kills.isEmpty, "the passive copy quits while the main one runs: \(mac.kills)")
                mac.quit(a)
                precondition(mac.kills == [.putBack("A")], "the last copy puts back: \(mac.kills)")
            }
            precondition(mac.system == original, "after \(exit) the system is as before pikapik")
            precondition(mac.journalEmpty && mac.queue.isEmpty, "after \(exit) the journal and the Dock restart are clear")
        }
        print("three laps between two copies, then both quit in either order: one Dock restart per handover, originals back: ok")

        let stranger = Mac(system: original)
        let lone = stranger.party("A", "\(tools).a", 10, wantsA)
        stranger.become(lone)
        stranger.elapse()
        stranger.kills = []
        stranger.strangers = [copy(30, store, at: 500)]
        stranger.quit(lone)
        precondition(stranger.system == original && stranger.kills == [.putBack("A")] && stranger.journalEmpty)
        print("an App Store copy does not continue the animations, so the leaving copy puts them back: ok")

        let shutdown = Mac(system: original)
        let c = shutdown.party("A", website, 10, wantsA), d = shutdown.party("B", website, 20, wantsB)
        shutdown.become(c)
        shutdown.elapse()
        shutdown.kills = []
        shutdown.poweringOff = true
        shutdown.quit(c)
        precondition(shutdown.system == original && shutdown.kills == [.putBack("A")] && shutdown.journalEmpty, "shutdown: \(shutdown.kills)")
        shutdown.quit(d)
        precondition(shutdown.kills == [.putBack("A")], "the other copy has nothing left to put back: \(shutdown.kills)")
        print("when the Mac shuts down with two copies open, the main copy puts the animations back and the Dock restarts once: ok")

        for wants in [wantsB, wantsA] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wants), b = mac.party("B", "\(tools).b", 20, wantsB)
            mac.become(b)
            mac.elapse()
            mac.kills = []
            mac.quit(b)
            mac.become(a)
            mac.elapse()
            precondition(mac.kills == (wants == wantsB ? [] : [.restart("A")]), "B quits while A runs: \(mac.kills)")
            precondition(mac.system == original.merging(wants) { $1 } && !mac.flag)
            mac.kills = []
            mac.quit(a)
            precondition(mac.system == original && mac.journalEmpty && mac.kills == [.putBack("A")])
        }
        print("one copy quits while the other runs: the other continues, with no Dock restart for the same values and one for others: ok")

        for waiting in [false, true] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA), b = mac.party("B", "\(tools).b", 20, wantsB)
            mac.become(a)
            if !waiting { mac.elapse() }
            mac.kills = []
            mac.quit(a)
            precondition(mac.kills.isEmpty && mac.system == original.merging(wantsA) { $1 }, "A quits and B has not become main yet: \(mac.kills)")
            mac.quit(b)
            precondition(mac.system == original && mac.journalEmpty, "B quits before it became main and puts the originals back")
            precondition(mac.kills == [.putBack("B")], "waiting \(waiting): \(mac.kills)")
        }
        print("both copies quit one after another: the last one puts back what the journal holds: ok")

        for wants in [wantsA, wantsB] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA), b = mac.party("B", "\(tools).b", 20, wants)
            mac.become(a)
            precondition(mac.queue.count == 1 && mac.kills.isEmpty && mac.flag, "A's restart waits and the flag is set")
            mac.handOver(from: a, to: b)
            precondition(mac.kills.isEmpty && mac.flag, "the handover restarts nothing and keeps the flag")
            mac.elapse()
            precondition(mac.kills == [.restart("B")], "the waiting restart is done once, by B: \(mac.kills)")
            precondition(!mac.flag && mac.queue.isEmpty && mac.system == original.merging(wants) { $1 })
        }
        print("a Dock restart that is still waiting goes to the next copy, which restarts the Dock once: ok")

        for wants in [wantsA, wantsB] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA), b = mac.party("B", "\(tools).b", 20, wants)
            mac.become(a)
            precondition(mac.flag && mac.queue.count == 1)
            mac.queue = []
            mac.running.removeAll { $0 === a }
            mac.leader = nil
            mac.become(b)
            mac.elapse()
            precondition(mac.kills == [.restart("B")], "after the crash the new main copy restarts the Dock once: \(mac.kills)")
            precondition(!mac.flag && mac.queue.isEmpty && mac.system == original.merging(wants) { $1 })
        }
        print("if pikapik stops while the Dock restart waits, the next main copy still does it: ok")

        let hiding = Mac(system: original)
        let h = hiding.party("A", "\(tools).a", 10, wantsA), i = hiding.party("B", "\(tools).b", 20, wantsA)
        hiding.become(h)
        hiding.elapse()
        hiding.kills = []
        h.engine.setAutohide(true)
        precondition(hiding.autohide && hiding.flag && hiding.queue.count == 1)
        hiding.elapse()
        precondition(hiding.kills == [.restart("A")] && !hiding.flag, "autohide restarts the Dock once, with the flag set: \(hiding.kills)")
        hiding.kills = []
        hiding.quit(h)
        hiding.become(i)
        hiding.elapse()
        precondition(!hiding.autohide && hiding.kills == [.restart("B")], "the next copy does not want autohide and turns it off: \(hiding.kills)")
        hiding.kills = []
        i.engine.setAutohide(true)
        hiding.elapse()
        hiding.kills = []
        hiding.quit(i)
        precondition(!hiding.autohide && hiding.system == original && hiding.journalEmpty && hiding.kills == [.putBack("B")], "autohide comes back: \(hiding.kills)")
        print("the Dock is set to restart before autohide is written, and autohide comes back with the animations: ok")

        for hidden in [true, false] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA)
            mac.become(a)
            mac.elapse()
            if hidden { a.engine.setAutohide(true) }
            mac.elapse()
            mac.kills = []
            a.engine.set(.dockDelay, 0.3)
            precondition(mac.flag == hidden && mac.queue.count == (hidden ? 1 : 0), "autohide \(hidden): the Dock restart is set only if the Dock shows the change")
            mac.elapse()
            precondition(mac.kills == (hidden ? [.restart("A")] : []) && !mac.flag && mac.system[.dockDelay] == 0.3, "autohide \(hidden): \(mac.kills)")
        }
        print("a speed change restarts the Dock once while autohide is on and not at all while it is off: ok")

        let only = Mac(system: original)
        let j = only.party("A", "\(tools).a", 10, [:])
        only.become(j)
        j.engine.setAutohide(true)
        only.elapse()
        only.kills = []
        only.quit(j)
        precondition(!only.autohide && only.journalEmpty && only.kills == [.putBack("A")], "only autohide comes back: \(only.kills)")
        let alone = Mac(system: original)
        let k = alone.party("A", "\(tools).a", 10, [:])
        alone.become(k)
        k.engine.setAutohide(true)
        alone.elapse()
        alone.kills = []
        alone.leader = nil
        AnimationsEngine.uninstall(k.host)
        precondition(!alone.autohide && alone.journalEmpty && alone.kills == [.putBack("A")], "uninstall where only autohide comes back: \(alone.kills)")
        print("when only autohide comes back, on quit and on uninstall, the Dock restarts once: ok")
        for uninstall in [false, true] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsB)
            mac.become(a)
            a.engine.setAutohide(true)
            mac.elapse()
            var left: [String: Any]?
            mac.whileWaiting = { left = mac.journal.persistentDomain(forName: Mac.journalName) }
            if uninstall {
                mac.leader = nil
                AnimationsEngine.uninstall(a.host)
            } else {
                mac.quit(a)
            }
            mac.running = []
            precondition(mac.system == original && !mac.autohide && left?[DockRestart.key] as? Bool == true, "uninstall \(uninstall): the Dock restart is pending when the values are back and the Dock has not restarted yet")
            mac.journal.setPersistentDomain(left!, forName: Mac.journalName)
            mac.kills = []
            let c = mac.party("C", "\(tools).c", 30, [:])
            mac.become(c)
            mac.elapse()
            precondition(mac.kills == [.restart("C")] && mac.system == original && mac.journalEmpty && mac.leaving.isEmpty, "uninstall \(uninstall): the next copy restarts the Dock once: \(mac.kills)")
        }
        print("pikapik stops after it puts the values back and before the Dock restarts, on quit and on uninstall: the next copy restarts the Dock once: ok")
        for staying in [false, true] {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, [:])
            let b = staying ? mac.party("B", "\(tools).b", 20, [:]) : nil
            mac.become(a)
            mac.elapse()
            mac.kills = []
            a.engine.restartDock()
            mac.quit(a)
            if let b {
                precondition(mac.kills.isEmpty && mac.flag, "the copy that stays restarts the Dock, not the one that leaves: \(mac.kills)")
                mac.become(b)
                mac.elapse()
                precondition(mac.kills == [.restart("B")] && mac.journalEmpty, "the copy that stays restarts the Dock once: \(mac.kills)")
            } else {
                precondition(mac.kills == [.putBack("A")] && mac.journalEmpty && mac.queue.allSatisfy(\.isCancelled), "the last copy restarts the Dock before it quits: \(mac.kills)")
            }
        }
        print("another setting asks for a Dock restart right before the copy quits: the last copy restarts the Dock at once, or the copy that stays does it: ok")

        for order in Together.allCases {
            let mac = Mac(system: original)
            let a = mac.party("A", "\(tools).a", 10, wantsA), b = mac.party("B", "\(tools).b", 20, wantsB)
            mac.become(a)
            mac.elapse()
            mac.kills = []
            switch order {
            case .mainFirst:
                mac.willQuit(a)
                mac.willQuit(b)
                mac.retire(a)
            case .passiveFirst:
                mac.willQuit(b)
                mac.willQuit(a)
                mac.retire(a)
            case .mainRetiresFirst:
                mac.willQuit(a)
                mac.retire(a)
                mac.willQuit(b)
            }
            mac.running = []
            mac.elapse()
            precondition(mac.system == original, "\(order): the originals are back")
            precondition(mac.journalEmpty && mac.queue.isEmpty, "\(order): the journal, the leaving mark and the Dock restart are clear")
            precondition(mac.kills.count == 1 && mac.kills[0].app == "Dock" && mac.kills[0].wait, "\(order): the Dock restarts exactly once: \(mac.kills)")
        }
        print("both copies get the quit at the same moment, in any order: the animations come back and the Dock restarts once: ok")

        let me = copy(10, website, at: 10), main = copy(20, store, at: 20)
        precondition(!MainCopyChoice.becomesMain(me, among: [main], quitting: false), "a passive copy stays passive while the main copy runs")
        precondition(MainCopyChoice.becomesMain(me, among: [], quitting: false), "a passive copy becomes main when the main copy leaves")
        precondition(!MainCopyChoice.becomesMain(me, among: [], quitting: true), "a passive copy that is quitting stays passive when the main copy leaves")

        let race = Mac(system: original)
        let passive = race.party("A", "\(tools).a", 10, wantsA), leaving = race.party("B", "\(tools).b", 20, wantsB)
        race.become(leaving)
        race.elapse()
        race.kills = []
        race.willQuit(leaving)
        race.whileWaiting = {
            race.retire(leaving)
            race.running.removeAll { $0 === leaving }
            if MainCopyChoice.becomesMain(passive.running, among: race.running.filter { $0 !== passive }.map(\.running), quitting: true) { race.become(passive) }
        }
        race.willQuit(passive)
        race.retire(passive)
        race.running = []
        race.elapse()
        precondition(race.system == original && !race.autohide, "quit while waiting for the Dock: the originals are back")
        precondition(race.journalEmpty && race.queue.isEmpty, "quit while waiting for the Dock: the journal and the Dock restart are clear")
        precondition(race.kills.count == 1 && race.kills[0].wait, "quit while waiting for the Dock: the Dock restarts exactly once: \(race.kills)")
        print("a passive copy that is quitting stays passive when the main copy leaves while it waits for the Dock: one Dock restart: ok")

        let window = Mac(system: original)
        let incumbent = window.party("A", "\(tools).a", 10, wantsA)
        window.become(incumbent)
        window.elapse()
        window.kills = []
        window.journal.set(start, forKey: "animations-leaving-20")
        window.strangers = [copy(20, "\(tools).b", at: 20)]
        window.leader = nil
        incumbent.engine.refresh()
        precondition(window.kills.isEmpty && window.system == original.merging(wantsA) { $1 } && !window.journalEmpty, "a mark left by an earlier process with the same pid does not make the new copy leaving: \(window.kills)")
        window.strangers = []
        _ = window.party("B", "\(tools).b", 20, wantsB)
        precondition(window.leaving.isEmpty, "a copy clears the mark left under its pid when it starts: \(window.leaving)")
        print("a mark left by an earlier process with the same pid is ignored before the new copy has started, and cleared once it has: ok")

        for (offset, sameProcess) in [(0.5, true), (-0.5, true), (1.5, false), (-1.5, false)] as [(Double, Bool)] {
            let tolerance = Mac(system: original)
            let held = tolerance.party("A", "\(tools).a", 10, wantsA)
            tolerance.become(held)
            tolerance.elapse()
            tolerance.kills = []
            let peer = copy(20, "\(tools).b", at: 20)
            tolerance.journal.set(peer.launched.addingTimeInterval(offset), forKey: "animations-leaving-20")
            tolerance.strangers = [peer]
            tolerance.leader = nil
            held.engine.refresh()
            tolerance.elapse()
            if sameProcess {
                precondition(tolerance.system == original && tolerance.journalEmpty && tolerance.kills.count == 1 && tolerance.kills[0].wait, "a mark \(offset) s off the peer's launch is that peer leaving: \(tolerance.kills)")
            } else {
                precondition(tolerance.kills.isEmpty && tolerance.system == original.merging(wantsA) { $1 } && !tolerance.journalEmpty, "a mark \(offset) s off the peer's launch is another process: \(tolerance.kills)")
            }
        }
        print("a mark within half a second of a peer's launch is that peer leaving, one 1.5 s off is another process, either way round: ok")

        let trio = Mac(system: original)
        let a3 = trio.party("A", "\(tools).a", 10, wantsA), b3 = trio.party("B", "\(tools).b", 20, wantsB), c3 = trio.party("C", "\(tools).c", 30, wantsB)
        trio.become(a3)
        trio.elapse()
        trio.kills = []
        trio.willQuit(a3)
        trio.willQuit(b3)
        precondition(trio.leaving == ["animations-leaving-10", "animations-leaving-20"] && trio.kills.isEmpty, "B's mark does not erase A's: \(trio.leaving)")
        trio.retire(a3)
        precondition(trio.kills.isEmpty && trio.system == original.merging(wantsA) { $1 }, "A has read the marks before C writes its own and hands over: \(trio.kills)")
        trio.willQuit(c3)
        precondition(trio.system == original && trio.journalEmpty && trio.kills.count == 1 && trio.kills[0].wait, "C's mark lands after A has read, and C still puts everything back once: \(trio.kills)")
        print("a mark written after another copy has read the marks loses nothing, and marks never overwrite each other: ok")

        for wants in [wantsB, [:]] {
            let changed = !wants.isEmpty
            let pair = Mac(system: original)
            let a = pair.party("A", "\(tools).a", 10, wantsA), b = pair.party("B", "\(tools).b", 20, wants)
            pair.become(b)
            if changed { b.engine.setAutohide(true) }
            pair.elapse()
            pair.kills = []
            pair.willQuit(b)
            let stalled = DispatchSemaphore(value: 0), finished = DispatchSemaphore(value: 0)
            let other = {
                Thread {
                    pair.retire(b)
                    stalled.signal()
                    finished.signal()
                }.start()
                stalled.wait()
            }
            pair.whileWriting = other
            pair.contended = stalled
            pair.willQuit(a)
            if pair.whileWriting != nil {
                pair.whileWriting = nil
                other()
            }
            finished.wait()
            pair.running = []
            pair.elapse()
            precondition(pair.system == original && !pair.autohide && pair.journalEmpty && pair.queue.isEmpty, "two copies put back at the same moment, values changed \(changed): the originals are back, the journal and the Dock restart flag are clear")
            precondition(pair.kills == (changed ? [.putBack("A")] : []), "two copies put back at the same moment, values changed \(changed): the Dock restarts \(changed ? "once" : "never"): \(pair.kills)")
        }
        print("two copies put back at the same moment: the second waits for the first, finds nothing left and does not restart the Dock: ok")

        let late = Mac(system: original)
        let first = late.party("A", "\(tools).a", 10, wantsA), quitting = late.party("B", "\(tools).b", 20, wantsA)
        late.become(first)
        late.elapse()
        late.willQuit(quitting)
        late.quit(first)
        let next = late.party("C", "\(tools).c", 30, wantsB)
        late.become(next)
        late.elapse()
        late.kills = []
        precondition(late.leaving == ["animations-leaving-20"], "a copy that puts back keeps the mark of a copy that is still quitting: \(late.leaving)")
        late.quit(next)
        precondition(late.kills == [.putBack("C")] && late.system == original, "the main copy that leaves next does not count on the quitting copy and puts back itself: \(late.kills)")
        late.running.removeAll { $0 === quitting }
        _ = late.party("D", "\(tools).d", 40, [:])
        precondition(late.leaving.isEmpty && late.journalEmpty && late.kills == [.putBack("C")], "after everyone quits the next launch finds an empty journal: \(late.leaving)")
        print("a copy that puts back keeps the marks of copies still quitting, so the next main copy does not count on them: ok")

        enum Gone: CaseIterable { case beforeNotice, beforeRetire, afterRetire }
        for (launched, gone) in [5.0, 500].flatMap({ at in Gone.allCases.map { (at, $0) } }) {
            let pair = Mac(system: original)
            let web = pair.party("A", website, 10, wantsA)
            pair.become(web)
            pair.elapse()
            pair.kills = []
            pair.strangers = [copy(30, store, at: launched)]
            if gone == .beforeNotice { pair.strangers = [] }
            pair.willQuit(web)
            if gone == .beforeRetire { pair.strangers = [] }
            pair.retire(web)
            pair.strangers = []
            pair.running = []
            pair.elapse()
            precondition(pair.system == original && pair.journalEmpty && pair.kills == [.putBack("A")], "the website copy quits with an App Store copy launched at \(launched) that goes \(gone): it puts back once: \(pair.kills)")
        }
        print("the website copy quits together with an App Store copy, older or newer, gone at any moment: it puts the animations back and restarts the Dock once: ok")

        everyOrder()

        let sync = Mac(system: original)
        let e = sync.party("A", "\(tools).a", 10, wantsB)
        sync.become(e)
        e.engine.setAutohide(true)
        sync.kills = []
        sync.leader = nil
        AnimationsEngine.uninstall(e.host)
        precondition(sync.system == original && !sync.autohide && sync.journalEmpty, "uninstall puts everything back")
        precondition(sync.kills == [.putBack("A")], "uninstall restarts the Dock once and clears the flag: \(sync.kills)")
        sync.queue = []
        let later = Mac(system: original)
        let f = later.party("A", "\(tools).a", 10, wantsB)
        later.become(f)
        later.elapse()
        f.engine.setAutohide(true)
        later.elapse()
        later.kills = []
        later.leader = nil
        later.journal.set(start, forKey: "animations-leaving-99")
        AnimationsEngine.uninstall(f.host)
        precondition(later.system == original && !later.autohide && later.journalEmpty && later.kills == [.putBack("A")], "uninstall after a finished restart: \(later.kills)")
        let old = Mac(system: original.merging(wantsA) { $1 })
        old.journal.removeObject(forKey: "animations-ours")
        old.withoutJournal = true
        let g = old.party("A", "\(tools).a", 10, [:])
        wantsA.forEach { g.host.local.set($1, forKey: "animations-\($0.rawValue)") }
        AnimationsEngine.uninstall(g.host)
        precondition(old.system == original && old.kills == [.putBack("A")], "the 1.52.0 keys still work: \(old.kills)")
        let empty = Mac(system: original)
        let h2 = empty.party("A", "\(tools).a", 10, [:])
        AnimationsEngine.uninstall(h2.host)
        precondition(empty.kills.isEmpty && empty.system == original, "an empty journal kills nothing: \(empty.kills)")
        print("uninstall puts the animations and autohide back through the journal, restarts the Dock once and kills nothing when there is nothing to put back: ok")
    }

    enum Step: String { case willQuit = "W", retire = "R", exit = "X", takeOver = "B" }

    static func orders(_ stage: [Int], _ leader: Int?, takeOver: Bool, _ steps: [(Step, Int)] = []) -> [[(Step, Int)]] {
        var next = stage.indices.compactMap { copy -> (Step, Int)? in
            switch stage[copy] {
            case 0: return (.willQuit, copy)
            case 1: return (leader == copy ? .retire : .exit, copy)
            case 2: return (.exit, copy)
            default: return nil
            }
        }
        if takeOver, leader == nil, let newest = stage.indices.last(where: { stage[$0] < 3 }), stage[newest] == 0 { next.append((.takeOver, newest)) }
        guard !next.isEmpty else { return [steps] }
        return next.flatMap { step, copy -> [[(Step, Int)]] in
            var stage = stage, leader = leader
            switch step {
            case .willQuit: stage[copy] = 1
            case .retire: (stage[copy], leader) = (2, nil)
            case .exit: stage[copy] = 3
            case .takeOver: leader = copy
            }
            return orders(stage, leader, takeOver: takeOver, steps + [(step, copy)])
        }
    }

    static func everyOrder() {
        var count = 0
        let cases = [2, 3].flatMap { copies in [false, true].flatMap { takeOver in [false, true].flatMap { same in (0..<copies).map { (copies, takeOver, same, $0) } } } }
        for (copies, takeOver, same, first) in cases {
            for steps in orders([Int](repeating: 0, count: copies), first, takeOver: takeOver) {
                let label = "\(copies) copies, takeover \(takeOver), same wishes \(same), main \(first): " + steps.map { "\($0.0.rawValue)\($0.1)" }.joined(separator: " ")
                let mac = Mac(system: original)
                let parties = (0..<copies).map { mac.party(["A", "B", "C"][$0], "\(tools).\(["a", "b", "c"][$0])", Int32(10 * ($0 + 1)), same || $0 == first ? wantsA : wantsB) }
                parties.forEach { mac.journal.set(start, forKey: "animations-leaving-\($0.pid)") }
                mac.become(parties[first])
                mac.elapse()
                mac.kills = []
                var begun = Set<Int>()
                for (step, copy) in steps {
                    switch step {
                    case .willQuit: mac.willQuit(parties[copy]); begun.insert(copy)
                    case .retire: mac.retire(parties[copy])
                    case .exit: mac.running.removeAll { $0 === parties[copy] }
                    case .takeOver: mac.become(parties[copy])
                    }
                    precondition(begun.count == copies || mac.kills.isEmpty, "\(label): put back while a copy has not been told to quit, after \(step.rawValue)\(copy): \(mac.kills)")
                    let quitting = begun.map { parties[$0] }.filter { party in mac.running.contains { $0 === party } }
                    precondition(quitting.allSatisfy { mac.journal.object(forKey: "animations-leaving-\($0.pid)") as? Date == $0.running.launched }, "\(label): a copy that is still quitting keeps its mark, after \(step.rawValue)\(copy): \(mac.leaving)")
                }
                precondition(mac.system == original && !mac.autohide, "\(label): the originals are back")
                precondition(mac.journalEmpty, "\(label): the journal and the Dock restart flag are clear")
                precondition(mac.kills.count == 1 && mac.kills[0].wait, "\(label): the Dock restarts exactly once: \(mac.kills)")
                _ = mac.party("D", "\(tools).d", 40, [:])
                precondition(mac.leaving.isEmpty, "\(label): the next launch clears the marks: \(mac.leaving)")
                count += 1
            }
        }
        precondition(count == 3542, "orders run: \(count)")
        print("any order of quit notice, retire and exit for 2 or 3 copies, with and without a passive copy taking over, each starting with stale marks: originals back, journal empty, one Dock restart, a quitting copy keeps its mark until it exits, the next launch clears the marks (\(count) orders): ok")
    }

    enum Exit: CaseIterable { case mainFirst, passiveFirst }
    enum Together: CaseIterable { case mainFirst, passiveFirst, mainRetiresFirst }

    struct Kill: Equatable {
        let by: String, app: String, flagSet: Bool, wait: Bool

        static func restart(_ by: String) -> Kill { Kill(by: by, app: "Dock", flagSet: true, wait: false) }
        static func putBack(_ by: String, flagSet: Bool = true) -> Kill { Kill(by: by, app: "Dock", flagSet: flagSet, wait: true) }
    }

    final class Party {
        let name: String, bundleID: String, pid: Int32, wants: [AnimationSetting: Double]
        var host: AnimationsHost!
        var engine: AnimationsEngine!

        init(_ name: String, _ bundleID: String, _ pid: Int32, _ wants: [AnimationSetting: Double]) {
            (self.name, self.bundleID, self.pid, self.wants) = (name, bundleID, pid, wants)
        }

        var running: RunningCopy { TestMainCopy.copy(pid, bundleID, at: Double(pid)) }
    }

    final class Mac {
        static let journalName = "test-main-copy.journal"
        static let autohideKey = "animations-autohide-original"

        let journal = UserDefaults(suiteName: Mac.journalName)!
        var system: [AnimationSetting: Double]
        var autohide = false, poweringOff = false, withoutJournal = false
        var queue: [DispatchWorkItem] = []
        var kills: [Kill] = []
        var running: [Party] = []
        var strangers: [RunningCopy] = []
        var leader: Party?
        var whileWaiting: (() -> Void)?, whileWriting: (() -> Void)?
        var contended: DispatchSemaphore?
        let lock = NSLock()

        init(system: [AnimationSetting: Double]) {
            self.system = system
            journal.removePersistentDomain(forName: Self.journalName)
            journal.set([String: Double](), forKey: "animations-ours")
        }

        var flag: Bool { journal.bool(forKey: DockRestart.key) }
        var own: [String: Double] { journal.dictionary(forKey: "animations-own") as? [String: Double] ?? [:] }
        var ours: [String: Double] { journal.dictionary(forKey: "animations-ours") as? [String: Double] ?? [:] }
        var journalEmpty: Bool { own.isEmpty && ours.isEmpty && OriginalValue.load(Self.autohideKey, journal: journal) == nil && !flag }
        var leaving: [String] { journal.dictionaryRepresentation().keys.filter { $0.hasPrefix("animations-leaving-") }.sorted() }

        func party(_ name: String, _ bundleID: String, _ pid: Int32, _ wants: [AnimationSetting: Double]) -> Party {
            let suite = "test-main-copy.local.\(name)"
            let local = UserDefaults(suiteName: suite)!
            local.removePersistentDomain(forName: suite)
            let party = Party(name, bundleID, pid, wants)
            party.host = AnimationsHost(
                me: party.running,
                canAct: { self.leader === party },
                peers: { MainCopyChoice.peers(of: party.running, in: self.running.map(\.running) + self.strangers) },
                poweringOff: { self.poweringOff },
                journal: { self.journal },
                local: local,
                read: { self.system[$0] },
                write: { self.write($0, $1, by: party) },
                readAutohide: { self.autohide },
                writeAutohide: { self.writeAutohide($0, by: party) },
                later: { self.queue.append($0) },
                kill: {
                    self.kills.append(Kill(by: name, app: $0, flagSet: self.flag, wait: $1))
                    if $1, let waiting = self.whileWaiting {
                        self.whileWaiting = nil
                        waiting()
                    }
                },
                exclusive: { body in
                    precondition(Thread.current.threadDictionary["exclusive"] == nil, "\(name): the put back never waits for its own lock")
                    if !self.lock.try() {
                        self.contended?.signal()
                        self.lock.lock()
                    }
                    Thread.current.threadDictionary["exclusive"] = true
                    body()
                    Thread.current.threadDictionary["exclusive"] = nil
                    self.lock.unlock()
                }
            )
            party.engine = AnimationsEngine(party.host)
            wants.forEach { party.engine.set($0.key, $0.value) }
            running.append(party)
            return party
        }

        func elapse() {
            let due = queue
            queue = []
            due.forEach { $0.perform() }
        }

        func become(_ party: Party) {
            leader = party
            party.engine.refresh()
        }

        func handOver(from outgoing: Party, to incoming: Party) {
            leader = nil
            outgoing.engine.refresh()
            become(incoming)
        }

        func willQuit(_ party: Party) {
            party.engine.willQuit()
        }

        func retire(_ party: Party) {
            guard leader === party else { return }
            leader = nil
            party.engine.refresh()
        }

        func quit(_ party: Party) {
            willQuit(party)
            retire(party)
            running.removeAll { $0 === party }
        }

        private func write(_ setting: AnimationSetting, _ value: Double?, by party: Party) {
            let journaled = ours[setting.rawValue]
            precondition(withoutJournal || journaled != nil && own[setting.rawValue] == TestMainCopy.original[setting], "\(party.name): the journal holds the old and the new values and the original before \(setting) is written")
            if leader === party {
                precondition(value == nil || value == journaled || value == TestMainCopy.original[setting], "\(party.name): the journal holds the value before \(setting) is written")
                precondition(!AnimationSetting.restartsDock([(setting, value)], autohide: autohide) || flag, "\(party.name): the Dock restart is pending before \(setting) is written")
            } else {
                precondition(setting.apply != .dock || flag, "\(party.name): the Dock restart is pending before \(setting) is put back")
            }
            if let writing = whileWriting {
                whileWriting = nil
                writing()
            }
            system[setting] = value
        }

        private func writeAutohide(_ on: Bool, by party: Party) {
            precondition(OriginalValue.load(Self.autohideKey, journal: journal) != nil, "\(party.name): the journal holds the original autohide before it is written")
            precondition(flag, "\(party.name): the Dock restart is pending before autohide is written")
            autohide = on
        }
    }
}

final class Background {
    static let shared = Background()
    var quitting = false

    static func quit() {}
}

final class StubApp: NSRunningApplication, @unchecked Sendable {
    private let process: pid_t, quit: Bool, bundle: String?

    init(pid: pid_t, terminated: Bool, id: String?) {
        (process, quit, bundle) = (pid, terminated, id)
        super.init()
    }

    override var isTerminated: Bool { quit }
    override var processIdentifier: pid_t { process }
    override var bundleIdentifier: String? { bundle }
}
