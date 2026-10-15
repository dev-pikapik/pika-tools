import CoreGraphics

@main
struct TestDockDisplay {
    static func plan(_ on: Bool, _ current: Bool?, owned: Bool = false, before: Bool? = nil) -> (Bool?, Bool?, Bool) {
        let result = DockDisplaySwitch.plan(on: on, current: current, owned: owned, before: before)
        return (result.value, result.before, result.restart)
    }

    static func main() {
        precondition(plan(true, nil) == (false, nil, true))
        precondition(plan(true, true) == (false, true, true))
        precondition(plan(true, false) == (false, false, false))
        print("turning on remembers the old value and restarts the Dock only when it changes: ok")

        precondition(plan(false, false, owned: true, before: nil) == (nil, nil, true))
        precondition(plan(false, false, owned: true, before: true) == (true, nil, true))
        precondition(plan(false, false, owned: true, before: false) == (false, nil, false))
        print("turning off puts back exactly what was there: ok")

        precondition(plan(true, false, owned: true, before: nil) == (false, nil, false))
        precondition(plan(true, nil, owned: true, before: nil) == (false, nil, true))
        precondition(plan(true, true, owned: true, before: false) == (false, false, true))
        print("on: a key someone removed or changed is written again: ok")

        precondition(plan(false, nil) == (nil, nil, false))
        precondition(plan(false, false) == (false, nil, false))
        precondition(plan(false, true) == (true, nil, false))
        precondition(plan(false, nil, owned: true, before: true) == (nil, nil, false))
        precondition(plan(false, true, owned: true, before: nil) == (true, nil, false))
        precondition(plan(false, true, owned: true, before: false) == (true, nil, false))
        print("off: the key is left alone unless pikapik set it, and the Dock restarts only on a real change: ok")

        let crashed = DockDisplaySwitch.plan(on: true, current: true, owned: false, before: nil)
        let again = DockDisplaySwitch.plan(on: true, current: crashed.value, owned: true, before: crashed.before)
        precondition(again.value == false && again.before == true && !again.restart)
        let off = DockDisplaySwitch.plan(on: false, current: crashed.value, owned: true, before: again.before)
        precondition(off.value == true && off.restart)
        print("after a crash the next launch keeps the real value as the original and puts it back: ok")

        let side = ["a": CGPoint(x: 0, y: 0), "b": CGPoint(x: 1920, y: -120), "c": CGPoint(x: -1440, y: 60)]
        let moved = MainDisplay.moved(side, to: "b")
        precondition(moved == ["a": CGPoint(x: -1920, y: 120), "b": .zero, "c": CGPoint(x: -3360, y: 180)])
        precondition(MainDisplay.moved(side, to: "a") == nil && MainDisplay.moved(side, to: "z") == nil)
        print("making a display the main one shifts every display by the same amount, so the arrangement keeps its shape: ok")

        precondition(MainDisplay.remembered(side, now: moved!) == side)
        precondition(MainDisplay.remembered([:], now: side) == side)
        precondition(MainDisplay.remembered(side, now: ["a": .zero, "d": CGPoint(x: 5, y: 5)]) == ["a": .zero, "d": CGPoint(x: 5, y: 5)])
        print("the first arrangement is the one remembered, unless the set of displays has changed: ok")

        precondition(MainDisplay.restored(side, now: moved!) == side)
        precondition(MainDisplay.restored(side, now: side) == nil)
        precondition(MainDisplay.restored(side, now: ["a": .zero, "b": .zero]) == nil)
        print("restoring writes the old arrangement only for the same displays and only when it differs: ok")
    }
}
