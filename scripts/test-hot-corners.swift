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
    }
}
