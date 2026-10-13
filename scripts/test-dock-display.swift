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
        precondition(plan(false, nil, owned: true, before: true) == (true, nil, false))
        precondition(plan(false, true, owned: true, before: nil) == (nil, nil, false))
        print("off: the key is left alone unless pikapik set it, and the Dock restarts only on a real change: ok")
    }
}
