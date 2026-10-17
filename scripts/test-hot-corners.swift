import Foundation

@main
struct TestHotCorners {
    static func main() {
        var plan = HotCorners.choose(11, current: 2, saved: [:], side: "br")
        precondition(plan.write == 11 && plan.saved == ["br": 2])
        plan = HotCorners.choose(4, current: 11, saved: plan.saved, side: "br")
        precondition(plan.write == 4 && plan.saved == ["br": 2])
        precondition(HotCorners.choose(4, current: 4, saved: ["br": 2], side: "br").write == nil)
        precondition(HotCorners.choose(3, current: 2, saved: ["tl": 5], side: "br").saved == ["tl": 5, "br": 2])
        print("a new corner action is written and the first one is remembered once: ok")

        plan = HotCorners.putBack(current: 4, saved: ["br": 2, "tl": 5], side: "br")
        precondition(plan.write == 2 && plan.saved == ["tl": 5])
        plan = HotCorners.putBack(current: 2, saved: ["br": 2], side: "br")
        precondition(plan.write == nil && plan.saved.isEmpty)
        precondition(HotCorners.putBack(current: 4, saved: ["tl": 5], side: "br").write == nil)
        print("put back writes the remembered action, or nothing when it is already there: ok")

        plan = HotCorners.putBack(current: 4, saved: ["br": 2, "tl": 5], ours: 4, side: "br")
        precondition(plan.write == 2 && plan.saved == ["tl": 5])
        plan = HotCorners.putBack(current: 9, saved: ["br": 2, "tl": 5], ours: 4, side: "br")
        precondition(plan.write == nil && plan.saved == ["tl": 5])
        print("a corner changed by hand keeps the user's action and only the journal entry goes: ok")

        let crashed = HotCorners.choose(11, current: 2, saved: [:], side: "br")
        let journal = HotCorners.kept([:], crashed.saved), ours = crashed.write
        precondition(HotCorners.choose(11, current: 11, saved: journal, side: "br").saved == ["br": 2])
        plan = HotCorners.putBack(current: 11, saved: journal, ours: ours, side: "br")
        precondition(plan.write == 2 && plan.saved.isEmpty)
        print("after a crash with our action on the corner the next launch puts the real one back: ok")

        let during = HotCorners.kept(["br": 2, "tl": 5], ["tl": 5])
        precondition(during == ["br": 2, "tl": 5])
        plan = HotCorners.putBack(current: 2, saved: during, ours: 11, side: "br")
        precondition(plan.write == nil && plan.saved == ["tl": 5])
        print("a crash in the middle of putting back keeps the journal until the write is done: ok")

        ["hot-corners-before", "hot-corners-ours"].forEach(UserDefaults.standard.removeObject)
        var written: Int?
        HotCorners.apply("br", HotCorners.choose(11, current: 2, saved: HotCorners.before, side: "br")) { value in
            precondition(HotCorners.before == ["br": 2] && HotCorners.ours == ["br": 11])
            written = value
        }
        precondition(written == 11 && HotCorners.before == ["br": 2] && HotCorners.ours == ["br": 11])
        HotCorners.apply("br", HotCorners.putBack(current: 11, saved: HotCorners.before, side: "br")) { value in
            precondition(HotCorners.before == ["br": 2] && HotCorners.ours == ["br": 11])
            written = value
        }
        precondition(written == 2 && HotCorners.before.isEmpty && HotCorners.ours.isEmpty)
        print("the journal is saved before the corner is written and cleared only after it: ok")

        precondition(DockCorners.same(["wvous-br-corner": 11, "wvous-tl-corner": 0], [1, 4, 10, 11]))
        precondition(!DockCorners.same(["wvous-br-corner": 11], [1, 4, 10, 2]))
        precondition(!DockCorners.same(["wvous-xx-corner": 1], [1, 1, 1, 1]))
        precondition(DockCorners.same([:], []))
        print("the Dock reads back the corners it was told, with 0 and 1 both meaning nothing: ok")
    }
}
