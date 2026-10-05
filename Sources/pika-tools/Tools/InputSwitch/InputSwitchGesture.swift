import CoreGraphics

struct InputSwitchGesture {
    enum Direction: Equatable {
        case next, previous
    }

    private var direction: Direction?
    private var bothHeld = false
    private var cancelled = false

    mutating func flagsChanged(_ flags: CGEventFlags) -> Direction? {
        let option = flags.contains(.maskAlternate)
        let shift = flags.contains(.maskShift)

        guard option || shift else {
            defer { self = InputSwitchGesture() }
            return bothHeld && !cancelled ? direction : nil
        }

        if !flags.intersection([.maskCommand, .maskControl, .maskSecondaryFn]).isEmpty {
            cancelled = true
        }
        if direction == nil {
            if option && shift {
                cancelled = true
            }
            direction = option ? .next : .previous
        }
        if option && shift {
            bothHeld = true
        }
        return nil
    }

    mutating func interrupt() {
        if direction != nil {
            cancelled = true
        }
    }
}
