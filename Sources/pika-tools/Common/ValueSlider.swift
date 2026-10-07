import AppKit
import SwiftUI

struct ValueSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let ticks: Int
    var digits = 0
    var mark: Double?

    var body: some View {
        let clamped = Binding<Double>(
            get: { value },
            set: { value = min(max(($0 / step).rounded() * step, range.lowerBound), range.upperBound) }
        )
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(spacing: 2) {
                TickSlider(title: title, value: clamped, range: range, ticks: ticks, mark: mark)
                HStack {
                    Text("Slower")
                    Spacer()
                    Text("Faster")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            }
            .frame(maxWidth: 220)
            TextField(title, value: clamped, format: .number.precision(.fractionLength(digits)))
                .labelsHidden()
                .multilineTextAlignment(.trailing)
                .frame(width: 44)
            Stepper(title, value: clamped, in: range, step: step)
                .labelsHidden()
        }
    }
}

private struct TickSlider: NSViewRepresentable {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let ticks: Int
    let mark: Double?
    @Environment(\.isEnabled) private var isEnabled

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSSlider {
        let slider = MarkedSlider(value: value, minValue: range.lowerBound, maxValue: range.upperBound,
                              target: context.coordinator, action: #selector(Coordinator.changed(_:)))
        slider.numberOfTickMarks = ticks
        slider.tickMarkPosition = .below
        slider.isContinuous = true
        slider.mark = mark
        slider.setAccessibilityLabel(title)
        return slider
    }

    func updateNSView(_ slider: NSSlider, context: Context) {
        context.coordinator.value = $value
        slider.doubleValue = value
        slider.isEnabled = isEnabled
    }

    final class Coordinator: NSObject {
        var value: Binding<Double>?

        @objc func changed(_ slider: NSSlider) {
            value?.wrappedValue = slider.doubleValue
        }
    }
}

private final class MarkedSlider: NSSlider {
    var mark: Double?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let mark, let cell = cell as? NSSliderCell, numberOfTickMarks > 1 else { return }
        let first = cell.rectOfTickMark(at: 0)
        let last = cell.rectOfTickMark(at: numberOfTickMarks - 1)
        let x = first.midX + (last.midX - first.midX) * (mark - minValue) / (maxValue - minValue)
        let y = isFlipped ? first.maxY + 4 : first.minY - 4
        NSColor.controlAccentColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: x - 2, y: y - 2, width: 4, height: 4)).fill()
    }
}
