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

    static func main() {
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
    }
}
