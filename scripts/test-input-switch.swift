import CoreGraphics

@main
enum TestInputSwitch {
    static func run(_ steps: [CGEventFlags?]) -> InputSwitchGesture.Direction? {
        var gesture = InputSwitchGesture()
        var result: InputSwitchGesture.Direction?
        for step in steps {
            if let flags = step {
                result = gesture.flagsChanged(flags)
            } else {
                gesture.interrupt()
            }
        }
        return result
    }

    static func main() {
        let option = CGEventFlags.maskAlternate
        let shift = CGEventFlags.maskShift
        let both: CGEventFlags = [option, shift]

        precondition(run([option, both, shift, []]) == .next)
        precondition(run([shift, both, option, []]) == .previous)
        precondition(run([option, both, nil, []]) == nil)
        precondition(run([option, [option, .maskCommand], [option, .maskCommand, shift], []]) == nil)
        precondition(run([option, []]) == nil)
        precondition(run([nil, option, both, []]) == .next)
        precondition(run([option, both, [], shift, both, []]) == .previous)
        print("input-switch: ok")
    }
}
