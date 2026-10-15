import Carbon.HIToolbox
import CoreGraphics

@main
struct TestKeyUpFlags {
    static func main() {
        let keys: [(Int, CGEventFlags)] = [(kVK_ANSI_X, .maskCommand), (kVK_F19, [.maskControl, .maskAlternate, .maskShift, .maskCommand]), (kVK_Home, [])]
        for (key, flags) in keys {
            guard let down = CGEvent.pikapikKey(key, down: true, flags: flags) else { preconditionFailure("no key-down event") }
            precondition(down.type == .keyDown && down.getIntegerValueField(.keyboardEventKeycode) == Int64(key))
            precondition(down.flags.intersection(flags) == flags && down.isPikapik)

            let before = CGEventSource.flagsState(.hidSystemState)
            guard let up = CGEvent.pikapikKey(key, down: false, flags: flags) else { preconditionFailure("no key-up event") }
            let after = CGEventSource.flagsState(.hidSystemState)
            precondition(up.type == .keyUp && up.getIntegerValueField(.keyboardEventKeycode) == Int64(key) && up.isPikapik)
            precondition(up.flags == before || up.flags == after)
            if !before.contains(.maskCommand) && !after.contains(.maskCommand) { precondition(!up.flags.contains(.maskCommand)) }
        }
        print("a key-down carries the flags it was given and a key-up carries the flags the user really holds: ok")
    }
}
