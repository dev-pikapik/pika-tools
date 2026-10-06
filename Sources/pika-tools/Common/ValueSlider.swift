import AppKit
import SwiftUI

struct ValueSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let ticks: Int
    var digits = 0

    var body: some View {
        let clamped = Binding<Double>(
            get: { value },
            set: { value = min(max(($0 / step).rounded() * step, range.lowerBound), range.upperBound) }
        )
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(spacing: 2) {
                TickSlider(title: title, value: clamped, range: range, ticks: ticks)
                HStack {
                    Text("Slow")
                    Spacer()
                    Text("Fast")
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
    @Environment(\.isEnabled) private var isEnabled

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(value: value, minValue: range.lowerBound, maxValue: range.upperBound,
                              target: context.coordinator, action: #selector(Coordinator.changed(_:)))
        slider.numberOfTickMarks = ticks
        slider.tickMarkPosition = .below
        slider.isContinuous = true
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
