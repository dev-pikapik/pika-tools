import Foundation

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

        handover()
    }

    static let original: [AnimationSetting: Double] = [.minimize: 2]
    static let wantsA: [AnimationSetting: Double] = [.bounce: 1, .dockDelay: 0]
    static let wantsB: [AnimationSetting: Double] = [.bounce: 1, .dockDelay: 0.3, .minimize: 1]

    static func handover() {
        let website = MainCopyChoice.websiteID, store = MainCopyChoice.appStoreID
        defer { UserDefaults.standard.removeObject(forKey: DockRestart.key) }
        precondition(!MainCopyChoice.takesOver([], quitting: false))
        precondition(!MainCopyChoice.takesOver([copy(1, store, at: 5)], quitting: false))
        precondition(MainCopyChoice.takesOver([copy(1, website, at: 5)], quitting: false))
        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 1), copy(2, store, at: 5)], quitting: false))
        precondition(MainCopyChoice.takesOver([copy(1, website, at: 9), copy(2, store, at: 5)], quitting: false))
        precondition(MainCopyChoice.journal(website) == website && MainCopyChoice.journal(store) == website)
        precondition(MainCopyChoice.journal("com.pikapik.e2e.tools.a") == "com.pikapik.e2e.tools")
        precondition(MainCopyChoice.journal("com.pikapik.e2e.tools.a") == MainCopyChoice.journal("com.pikapik.e2e.tools.b"))
        precondition(MainCopyChoice.journal("com.apple.finder") == "com.apple.finder")
        print("the copy that comes next continues the animations unless it is the App Store one: ok")

        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 5)], quitting: true))
        precondition(!MainCopyChoice.takesOver([copy(1, website, at: 9), copy(2, store, at: 5)], quitting: true))
        print("a copy that is quitting, as when the Mac shuts down, never counts on the next one: ok")

        precondition(!AnimationSetting.restartsDock([(.dockDelay, 0.3)], autohide: false))
        precondition(AnimationSetting.restartsDock([(.dockDelay, 0.3)], autohide: true))
        precondition(AnimationSetting.restartsDock([(.minimize, nil)], autohide: false))
        precondition(!AnimationSetting.restartsDock([(.windowOpen, 0)], autohide: true))
        print("the Dock restarts only for changes it shows: ok")

        for exit in Exit.allCases {
            let mac = Mac(system: original)
            let a = mac.party("A", "com.pikapik.e2e.tools.a", 10, wantsA), b = mac.party("B", "com.pikapik.e2e.tools.b", 20, wantsB)
            var clock = 0.0
            mac.apply(a, seen: mac.system)
            mac.elapse()
            var leader = a, passive = b
            for lap in 1...3 {
                for _ in 0..<2 {
                    clock += 60
                    mac.kills = []
                    swap(&leader, &passive)
                    leader.launched = clock
                    mac.handOver(from: passive, to: leader)
                    mac.elapse()
                    precondition(mac.system == original.merging(leader.wants) { $1 }, "lap \(lap): the system holds \(leader.name)'s wishes and the originals")
                    precondition(mac.kills == [Kill(by: leader.name, flagSet: true, wait: false)], "lap \(lap): the Dock restarts once, by \(leader.name), while the flag is still set: \(mac.kills)")
                    precondition(!mac.flag, "lap \(lap): the flag is gone after the restart")
                }
            }
            precondition(leader === a && passive === b)
            switch exit {
            case .mainFirst:
                mac.kills = []
                precondition(MainCopyChoice.takesOver(MainCopyChoice.peers(of: a.running, in: [a.running, b.running]), quitting: false))
                mac.handOver(from: a, to: b)
                mac.elapse()
                precondition(mac.system == original.merging(wantsB) { $1 })
                mac.leave(b, among: [])
            case .passiveFirst:
                mac.leave(a, among: [])
            }
            precondition(mac.system == original, "after \(exit) the system is as before pikapik")
            precondition(mac.own.isEmpty && mac.ours.isEmpty, "after \(exit) the journal is empty")
            precondition(!mac.flag && mac.queue.isEmpty, "after \(exit) no Dock restart is left")
        }
        print("three laps between two copies, then both quit in either order: one Dock restart per handover, originals back: ok")

        let mac = Mac(system: original)
        let a = mac.party("A", "com.pikapik.e2e.tools.a", 10, wantsA)
        mac.apply(a, seen: mac.system)
        mac.elapse()
        mac.kills = []
        mac.leave(a, among: [copy(30, MainCopyChoice.appStoreID, at: 500)])
        precondition(mac.system == original && mac.kills == [Kill(by: "A", flagSet: false, wait: true)])
        print("an App Store copy does not continue the animations, so the leaving copy puts them back: ok")

        let shutdown = Mac(system: original)
        let c = shutdown.party("A", "com.pikapik.e2e.tools.a", 10, wantsA)
        shutdown.apply(c, seen: shutdown.system)
        shutdown.elapse()
        shutdown.kills = []
        shutdown.leave(c, among: [copy(30, MainCopyChoice.websiteID, at: 500)], quitting: true)
        precondition(shutdown.system == original && shutdown.kills.count == 1 && shutdown.own.isEmpty && shutdown.ours.isEmpty)
        print("when the Mac shuts down with two copies open, each one puts the animations back: ok")

        for wants in [wantsA, wantsB] {
            let mac = Mac(system: original)
            let a = mac.party("A", "com.pikapik.e2e.tools.a", 10, wantsA), b = mac.party("B", "com.pikapik.e2e.tools.b", 20, wants)
            mac.apply(a, seen: mac.system)
            precondition(mac.queue.count == 1 && mac.kills.isEmpty && mac.flag, "A's restart waits and the flag is set")
            b.launched = 60
            mac.handOver(from: a, to: b)
            precondition(mac.kills.isEmpty && mac.flag, "the handover restarts nothing and keeps the flag")
            mac.elapse()
            precondition(mac.kills == [Kill(by: "B", flagSet: true, wait: false)], "the waiting restart is done once, by B: \(mac.kills)")
            precondition(!mac.flag)
        }
        print("a Dock restart that is still waiting goes to the next copy, which restarts the Dock once: ok")

        let same = Mac(system: original)
        let first = same.party("A", "com.pikapik.e2e.tools.a", 10, wantsA), second = same.party("B", "com.pikapik.e2e.tools.b", 20, wantsA)
        same.apply(first, seen: same.system)
        same.elapse()
        same.kills = []
        second.launched = 60
        same.handOver(from: first, to: second)
        same.elapse()
        precondition(same.kills.isEmpty && !same.flag && same.system == original.merging(wantsA) { $1 })
        print("two copies that want the same values restart the Dock zero times at the handover: ok")

        for wants in [wantsA, wantsB] {
            let mac = Mac(system: original)
            let a = mac.party("A", "com.pikapik.e2e.tools.a", 10, wantsA), b = mac.party("B", "com.pikapik.e2e.tools.b", 20, wants)
            mac.apply(a, seen: mac.system)
            precondition(mac.flag && mac.queue.count == 1)
            mac.queue = []
            mac.apply(b, seen: mac.system)
            mac.elapse()
            precondition(mac.kills == [Kill(by: "B", flagSet: true, wait: false)], "after the crash the new main copy restarts the Dock once: \(mac.kills)")
            precondition(!mac.flag && mac.queue.isEmpty)
        }
        print("if pikapik stops while the Dock restart waits, the next main copy still does it: ok")
    }

    enum Exit: CaseIterable { case mainFirst, passiveFirst }

    struct Kill: Equatable {
        let by: String, flagSet: Bool, wait: Bool
    }

    final class Party {
        let name: String, bundleID: String, pid: Int32, wants: [AnimationSetting: Double], dock: DockRestart
        var launched = 0.0

        init(_ name: String, _ bundleID: String, _ pid: Int32, _ wants: [AnimationSetting: Double], dock: DockRestart) {
            (self.name, self.bundleID, self.pid, self.wants, self.dock) = (name, bundleID, pid, wants, dock)
        }

        var running: RunningCopy { TestMainCopy.copy(pid, bundleID, at: launched) }
    }

    final class Mac {
        var system: [AnimationSetting: Double]
        var own: [AnimationSetting: Double] = [:]
        var ours: [AnimationSetting: Double] = [:]
        var queue: [DispatchWorkItem] = []
        var kills: [Kill] = []

        init(system: [AnimationSetting: Double]) {
            self.system = system
            UserDefaults.standard.removeObject(forKey: DockRestart.key)
        }

        var flag: Bool { UserDefaults.standard.bool(forKey: DockRestart.key) }

        func party(_ name: String, _ bundleID: String, _ pid: Int32, _ wants: [AnimationSetting: Double]) -> Party {
            Party(name, bundleID, pid, wants, dock: DockRestart(
                journal: { .standard },
                later: { self.queue.append($0) },
                kill: { wait in self.kills.append(Kill(by: name, flagSet: self.flag, wait: wait)) }
            ))
        }

        func elapse() {
            let due = queue
            queue = []
            due.forEach { $0.perform() }
        }

        func apply(_ party: Party, seen: [AnimationSetting: Double]) {
            let (before, wasOurs) = (own, ours)
            let originals = AnimationSetting.originals(own, owned: ours, new: party.wants, system: seen)
            let applied = AnimationSetting.set(party.wants, own: own, ours: ours, system: seen, remember: { self.own = $0; self.ours = $1 }) { setting, value in
                precondition(self.ours == wasOurs.merging(party.wants) { $1 } && self.own == before.merging(originals) { $1 }, "\(party.name): the journal holds the old and the new values and the originals before \(setting) is written")
                self.system[setting] = value
            }
            precondition(own == applied.own && ours == applied.ours, "\(party.name): the journal ends with the new values")
            party.dock.restart(for: applied.changes, autohide: false)
        }

        func putBack(_ party: Party) {
            let (before, wasOurs) = (own, ours)
            let changes = AnimationSetting.putBack(own: own, ours: ours, system: system, remember: { self.own = $0; self.ours = $1 }) { setting, value in
                precondition(self.own == before && self.ours == wasOurs, "\(party.name): the journal is kept until \(setting) is back")
                self.system[setting] = value
            }
            if changes.contains(where: { $0.0.apply == .dock }) { party.dock.now() }
        }

        func leave(_ party: Party, among others: [RunningCopy], quitting: Bool = false) {
            party.dock.leave(takesOver: MainCopyChoice.takesOver(others, quitting: quitting)) { putBack(party) }
        }

        func handOver(from outgoing: Party, to incoming: Party) {
            let seen = system
            leave(outgoing, among: MainCopyChoice.peers(of: outgoing.running, in: [outgoing.running, incoming.running]))
            apply(incoming, seen: seen)
        }
    }
}
