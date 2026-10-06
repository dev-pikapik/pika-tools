import CoreGraphics

@main
enum TestInputSwitch {
    static func run(_ steps: [CGEventFlags?]) -> [InputSwitchGesture.Direction] {
        var gesture = InputSwitchGesture()
        var results: [InputSwitchGesture.Direction] = []
        for step in steps {
            if let flags = step {
                if let direction = gesture.flagsChanged(flags) { results.append(direction) }
            } else {
                gesture.interrupt()
            }
        }
        return results
    }

    static func main() {
        let option = CGEventFlags.maskAlternate
        let shift = CGEventFlags.maskShift
        let both: CGEventFlags = [option, shift]

        precondition(run([option, both, shift, []]) == [.next])
        precondition(run([shift, both, option, []]) == [.previous])
        precondition(run([option, both, []]) == [.next])
        precondition(run([option, both, option, both, option, both, option, []]) == [.next, .next, .next])
        precondition(run([shift, both, shift, both, shift, []]) == [.previous, .previous])
        precondition(run([option, both, shift, both, shift, []]) == [.next, .previous])
        precondition(run([option, both, nil, []]) == [])
        precondition(run([option, [option, .maskCommand], [option, .maskCommand, shift], []]) == [])
        precondition(run([option, []]) == [])
        precondition(run([both, option, []]) == [])
        precondition(run([nil, option, both, []]) == [.next])
        precondition(run([option, both, [], shift, both, []]) == [.next, .previous])
        print("input-switch: ok")
    }
}
