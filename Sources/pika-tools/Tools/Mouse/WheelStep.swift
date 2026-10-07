import CoreGraphics

struct WheelStep {
    enum Mode: String {
        case lines, pixels
    }

    static let range = 1...10
    static let defaultLines = 3
    static let pointsPerLine: Int64 = 10
    static let pixelRange = 1...200
    static let pixelStep = 20
    static let defaultPixels = 40

    var mode = Mode.lines
    let lines: Int
    var pixels = defaultPixels

    static let axes: [(CGEventField, CGEventField, CGEventField)] = [
        (.scrollWheelEventDeltaAxis1, .scrollWheelEventFixedPtDeltaAxis1, .scrollWheelEventPointDeltaAxis1),
        (.scrollWheelEventDeltaAxis2, .scrollWheelEventFixedPtDeltaAxis2, .scrollWheelEventPointDeltaAxis2),
    ]

    func rewrite(_ event: CGEvent) -> Bool {
        guard event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0 else { return false }
        var changed = false
        for (delta, fixed, point) in Self.axes {
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

struct ScrollDirection {
    var natural = false
    var systemNatural = true

    func flips(continuous: Int64, phase: Int64, momentum: Int64) -> Bool {
        natural != systemNatural && continuous == 0 && phase == 0 && momentum == 0
    }

    func rewrite(_ event: CGEvent) {
        guard flips(
            continuous: event.getIntegerValueField(.scrollWheelEventIsContinuous),
            phase: event.getIntegerValueField(.scrollWheelEventScrollPhase),
            momentum: event.getIntegerValueField(.scrollWheelEventMomentumPhase)
        ) else { return }
        for (delta, fixed, point) in WheelStep.axes {
            let values = (event.getIntegerValueField(delta), event.getDoubleValueField(fixed), event.getIntegerValueField(point))
            event.setIntegerValueField(delta, value: -values.0)
            event.setDoubleValueField(fixed, value: -values.1)
            event.setIntegerValueField(point, value: -values.2)
        }
    }
}
