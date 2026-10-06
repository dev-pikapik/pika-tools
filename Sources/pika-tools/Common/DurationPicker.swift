import SwiftUI

struct DurationPicker: View {
    @Binding var seconds: Int
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var focused: Bool
    @State private var current: Int
    @State private var zeroed = false
    @State private var typed = ""
    @State private var selected = Part.hours
    @State private var hovered: Part?

    init(seconds: Binding<Int>) {
        _seconds = seconds
        _current = State(initialValue: seconds.wrappedValue)
    }

    private enum Part: CaseIterable {
        case days, hours, minutes, seconds

        var unit: Int {
            switch self {
            case .days: 86400
            case .hours: 3600
            case .minutes: 60
            case .seconds: 1
            }
        }

        var limit: Int {
            switch self {
            case .days: KeepAwake.maxDuration / 86400
            case .hours: 23
            case .minutes, .seconds: 59
            }
        }

        var title: String {
            switch self {
            case .days: String(localized: "Days")
            case .hours: String(localized: "Hours")
            case .minutes: String(localized: "Minutes")
            case .seconds: String(localized: "Seconds")
            }
        }

        func value(in total: Int) -> Int {
            let count = total / unit
            return self == .days ? count : count % (self == .hours ? 24 : 60)
        }

        func replacing(in total: Int, with value: Int) -> Int {
            min(total + (min(max(value, 0), limit) - self.value(in: total)) * unit, KeepAwake.maxDuration)
        }
    }

    private static let presets = [15 * 60, 30 * 60, 3600, 2 * 3600, 8 * 3600]

    private var shown: Int { zeroed ? 0 : current }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ForEach(Part.allCases, id: \.self) { part in
                    if part != .days {
                        Text(verbatim: ":")
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .baselineOffset(3)
                            .padding(.horizontal, 3)
                            .accessibilityHidden(true)
                    }
                    segment(part)
                }
            }
            .focusable()
            .focused($focused)
            .focusEffectDisabled()
            .onKeyPress(phases: [.down, .repeat]) { press($0) }
            .opacity(isEnabled ? 1 : 0.4)
            HStack(spacing: 6) {
                ForEach(Self.presets, id: \.self, content: preset)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Duration"))
        .onChange(of: focused) {
            typed = ""
            if !focused { zeroed = false }
        }
        .onChange(of: seconds) { _, new in
            current = new
            zeroed = false
        }
    }

    private func segment(_ part: Part) -> some View {
        let value = part.value(in: shown)
        let isSelected = focused && selected == part
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        return VStack(spacing: 1) {
            Text(verbatim: String(format: "%02d", value))
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(zeroed ? Color.red : isSelected ? Color.accentColor : .primary)
                .contentTransition(.numericText(value: Double(value)))
            Text(part.title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 56)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.16) : hovered == part ? Color.primary.opacity(0.06) : .clear, in: shape)
        .contentShape(shape)
        .animation(.snappy(duration: 0.2), value: value)
        .animation(.snappy(duration: 0.2), value: isSelected)
        .onHover { hovered = $0 ? part : nil }
        .onTapGesture { select(part) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(part.title)
        .accessibilityValue(value.formatted())
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: step(part, 1)
            case .decrement: step(part, -1)
            @unknown default: break
            }
        }
    }

    private func preset(_ value: Int) -> some View {
        let selected = shown == value
        return Button {
            commit(value)
        } label: {
            Text(Duration.seconds(value).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated)))
                .font(.subheadline)
                .foregroundStyle(selected ? Color.white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(selected ? Color.accentColor : Color.primary.opacity(0.08), in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: selected)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func commit(_ total: Int) {
        zeroed = total == 0
        guard total > 0, total != current else { return }
        current = total
        seconds = total
    }

    private func select(_ part: Part) {
        typed = ""
        selected = part
    }

    private func step(_ part: Part, _ delta: Int) {
        typed = ""
        commit(part.replacing(in: shown, with: part.value(in: shown) + delta))
    }

    private func move(_ delta: Int) -> Bool {
        guard let index = Part.allCases.firstIndex(of: selected), Part.allCases.indices.contains(index + delta) else { return false }
        typed = ""
        selected = Part.allCases[index + delta]
        return true
    }

    private func type(_ digit: Int) {
        var text = typed + String(digit)
        if Int(text)! > selected.limit { text = String(digit) }
        typed = text
        let value = Int(text)!
        commit(selected.replacing(in: shown, with: value))
        if text.count == String(selected.limit).count || value * 10 > selected.limit {
            typed = ""
            _ = move(1)
        }
    }

    private func press(_ press: KeyPress) -> KeyPress.Result {
        guard press.modifiers.isDisjoint(with: [.command, .control, .option]) else { return .ignored }
        switch press.key {
        case .upArrow: step(selected, 1)
        case .downArrow: step(selected, -1)
        case .leftArrow: _ = move(-1)
        case .rightArrow: _ = move(1)
        case .tab: return move(press.modifiers.contains(.shift) ? -1 : 1) ? .handled : .ignored
        case .delete, .deleteForward, KeyEquivalent("\u{7F}"):
            typed = ""
            commit(selected.replacing(in: shown, with: 0))
        case .return, .escape: focused = false
        default:
            guard press.characters.count == 1, let digit = Int(press.characters) else { return .ignored }
            type(digit)
        }
        return .handled
    }
}
