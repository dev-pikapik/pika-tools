import CoreGraphics

struct WheelStep {
    enum Mode: String {
        case lines, pixels
    }

    static let range = 1...10
    static let defaultLines = 3
    static let pointsPerLine: Int64 = 10
    static let pixelRange = 1...200
    static let defaultPixels = 40

    var mode = Mode.lines
    let lines: Int
    var pixels = defaultPixels

    func rewrite(_ event: CGEvent) -> Bool {
        guard event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0 else { return false }
        let axes: [(CGEventField, CGEventField, CGEventField)] = [
            (.scrollWheelEventDeltaAxis1, .scrollWheelEventFixedPtDeltaAxis1, .scrollWheelEventPointDeltaAxis1),
            (.scrollWheelEventDeltaAxis2, .scrollWheelEventFixedPtDeltaAxis2, .scrollWheelEventPointDeltaAxis2),
        ]
        var changed = false
        for (delta, fixed, point) in axes {
            let sign = sign(event.getIntegerValueField(delta), event.getDoubleValueField(fixed))
            guard sign != 0 else { continue }
            switch mode {
            case .lines:
                let value = sign * Int64(min(max(lines, Self.range.lowerBound), Self.range.upperBound))
                event.setIntegerValueField(delta, value: value)
                event.setDoubleValueField(fixed, value: Double(value))
                event.setIntegerValueField(point, value: value * Self.pointsPerLine)
            case .pixels:
                let value = Double(sign * Int64(min(max(pixels, Self.pixelRange.lowerBound), Self.pixelRange.upperBound)))
                event.setDoubleValueField(fixed, value: value)
                event.setDoubleValueField(point, value: value)
            }
            changed = true
        }
        if changed && mode == .pixels {
            event.setIntegerValueField(.scrollWheelEventIsContinuous, value: 1)
        }
        return changed
    }

    private func sign(_ delta: Int64, _ fixed: Double) -> Int64 {
        delta != 0 ? delta.signum() : (fixed > 0 ? 1 : fixed < 0 ? -1 : 0)
    }
}
