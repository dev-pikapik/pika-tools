import CoreGraphics

struct WheelStep {
    static let range = 1...10
    static let defaultLines = 3
    static let pointsPerLine: Int64 = 10

    let lines: Int

    func rewrite(_ event: CGEvent) -> Bool {
        guard event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0 else { return false }
        let axes: [(CGEventField, CGEventField, CGEventField)] = [
            (.scrollWheelEventDeltaAxis1, .scrollWheelEventFixedPtDeltaAxis1, .scrollWheelEventPointDeltaAxis1),
            (.scrollWheelEventDeltaAxis2, .scrollWheelEventFixedPtDeltaAxis2, .scrollWheelEventPointDeltaAxis2),
        ]
        var changed = false
        for (delta, fixed, point) in axes {
            let value = step(event.getIntegerValueField(delta), event.getDoubleValueField(fixed))
            guard value != 0 else { continue }
            event.setIntegerValueField(delta, value: value)
            event.setDoubleValueField(fixed, value: Double(value))
            event.setIntegerValueField(point, value: value * Self.pointsPerLine)
            changed = true
        }
        return changed
    }

    func step(_ delta: Int64, _ fixed: Double) -> Int64 {
        let sign: Int64 = delta != 0 ? delta.signum() : (fixed > 0 ? 1 : fixed < 0 ? -1 : 0)
        return sign * Int64(min(max(lines, Self.range.lowerBound), Self.range.upperBound))
    }
}
