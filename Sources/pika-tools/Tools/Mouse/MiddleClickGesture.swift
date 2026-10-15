import CoreGraphics
import Foundation

/// Tells a quick tap with a set number of fingers from a swipe, a pinch, a rest or a press,
/// frame by frame from the fingers the trackpad reports.
struct MiddleClickGesture {
    struct Touch {
        let id: Int
        let position: CGPoint
    }

    static let longest: TimeInterval = 0.35
    static let farthest: CGFloat = 0.04

    private(set) var count = 0
    private var start: TimeInterval?
    private var origins: [Int: CGPoint] = [:]
    private var most = 0
    private var spoiled = false

    /// One frame of fingers on the trackpad, resting thumbs and lifted fingers left out.
    /// True when the frame ends a tap with exactly `fingers` fingers.
    mutating func update(_ touches: [Touch], at time: TimeInterval, fingers: Int) -> Bool {
        count = touches.count
        guard !touches.isEmpty else {
            defer { reset() }
            guard let start else { return false }
            return !spoiled && most == fingers && time - start <= Self.longest
        }
        if start == nil { start = time }
        most = max(most, touches.count)
        for touch in touches {
            let origin = origins[touch.id] ?? touch.position
            origins[touch.id] = origin
            if hypot(touch.position.x - origin.x, touch.position.y - origin.y) > Self.farthest { spoiled = true }
        }
        return false
    }

    /// A real click with the fingers on the trackpad is a click, not a tap.
    mutating func press() {
        if start != nil { spoiled = true }
    }

    mutating func reset() {
        count = 0
        start = nil
        origins = [:]
        most = 0
        spoiled = false
    }
}
