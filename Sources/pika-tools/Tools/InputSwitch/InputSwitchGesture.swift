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
            return nil
        }
        guard bothHeld else { return nil }
        bothHeld = false
        let result = cancelled ? nil : direction
        direction = option ? .next : .previous
        return result
    }

    mutating func interrupt() {
        if direction != nil {
            cancelled = true
        }
    }
}
