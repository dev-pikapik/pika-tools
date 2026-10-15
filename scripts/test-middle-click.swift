import CoreGraphics
import Foundation

@main
enum TestMiddleClick {
    typealias Touch = MiddleClickGesture.Touch

    static func fingers(_ count: Int, shift: CGFloat = 0) -> [Touch] {
        (0..<count).map { Touch(id: $0, position: CGPoint(x: 0.3 + CGFloat($0) * 0.15 + shift, y: 0.5)) }
    }

    /// Feeds frames 10 ms apart, then the empty frame that ends the touch, and says whether it was a tap.
    static func tap(_ frames: [[Touch]], fingers expected: Int = 3, gesture: inout MiddleClickGesture, press: Int? = nil, end: TimeInterval? = nil) -> Bool {
        var time: TimeInterval = 100
        for (index, frame) in frames.enumerated() {
            if index == press { gesture.press() }
            precondition(!gesture.update(frame, at: time, fingers: expected))
            time += 0.01
        }
        return gesture.update([], at: end.map { 100 + $0 } ?? time, fingers: expected)
    }

    static func tap(_ frames: [[Touch]], fingers expected: Int = 3, press: Int? = nil, end: TimeInterval? = nil) -> Bool {
        var gesture = MiddleClickGesture()
        return tap(frames, fingers: expected, gesture: &gesture, press: press, end: end)
    }

    static func main() {
        let three = Array(repeating: fingers(3), count: 8)
        precondition(tap(three))
        precondition(!tap(Array(repeating: fingers(2), count: 8)))
        precondition(!tap(Array(repeating: fingers(4), count: 8)))
        precondition(tap(Array(repeating: fingers(4), count: 8), fingers: 4))
        precondition(!tap(three, fingers: 4))

        precondition(tap(three, end: 0.34))
        precondition(!tap(three, end: 0.4))

        precondition(tap(three + [fingers(3, shift: 0.03)]))
        precondition(!tap(three + [fingers(3, shift: 0.05)]))

        precondition(!tap(three, press: 2))

        let staggered = [fingers(1), fingers(2), fingers(3), fingers(3), Array(fingers(3).prefix(1))]
        precondition(tap(staggered))
        precondition(!tap(staggered + [fingers(4)]))

        var gesture = MiddleClickGesture()
        gesture.press()
        precondition(tap(three, gesture: &gesture))
        precondition(!tap(three, gesture: &gesture, press: 1))
        precondition(tap(three, gesture: &gesture))
        precondition(!tap(three, gesture: &gesture, end: 2))
        precondition(tap(three, gesture: &gesture))

        precondition(!gesture.update(fingers(3), at: 0, fingers: 3))
        precondition(gesture.count == 3)
        precondition(!gesture.update(fingers(1), at: 0.01, fingers: 3))
        precondition(gesture.count == 1)
        precondition(gesture.update([], at: 0.02, fingers: 3))
        precondition(gesture.count == 0)

        var idle = MiddleClickGesture()
        precondition(!idle.update([], at: 0, fingers: 3))
        print("test-middle-click: all passed")
    }
}
