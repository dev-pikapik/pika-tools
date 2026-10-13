import SwiftUI

struct TemperatureSettings: View {
    private let model = Temperatures.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .temperatures, text: String(localized: "See how warm your Mac is inside"))
            Section {
                VStack(spacing: 14) {
                    ThermalScene(level: model.level)
                        .settingAnchor(String(localized: "Temperature"))
                    VStack(spacing: 4) {
                        Text(model.verdict)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text(model.advice)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .multilineTextAlignment(.center)
                    .accessibilityElement(children: .combine)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            #if !APPSTORE
            if !model.readings.isEmpty {
                Section {
                    ForEach(ThermalPart.allCases.filter { model.readings[$0] != nil }) { part in
                        PartRow(part: part, celsius: model.readings[part] ?? 0)
                    }
                } footer: {
                    Text("Bars and colors follow the normal range for each part")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            #endif
        }
        .formStyle(.grouped)
        .settingsPage()
        .onAppear { model.watch() }
        .onDisappear { model.unwatch() }
    }
}

#if !APPSTORE
private func degrees(_ celsius: Double) -> String {
    Measurement(value: celsius, unit: UnitTemperature.celsius)
        .formatted(.measurement(width: .narrow, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0))))
}

private struct PartRow: View {
    let part: ThermalPart
    let celsius: Double

    var body: some View {
        let level = part.level(celsius, in: UnitTemperature(forLocale: .autoupdatingCurrent, usage: .weather))
        LabeledContent {
            HStack(spacing: 10) {
                Gauge(value: part.fraction(celsius)) {}
                    .gaugeStyle(.linearCapacity)
                    .tint(ThermalScene.tint(level))
                    .frame(width: 80)
                Text(degrees(celsius))
                    .monospacedDigit()
                    .frame(minWidth: 40, alignment: .trailing)
            }
        } label: {
            Label { Text(part.title) } icon: { Image(systemName: part.symbol).frame(width: 24) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(part.title)
        .accessibilityValue(Text(verbatim: "\(degrees(celsius)), \(Temperatures.verdict(level))"))
    }
}
#endif

struct ThermalScene: View {
    let level: Int
    @Environment(\.colorScheme) private var scheme

    static func tint(_ level: Int) -> Color {
        [Art.green, Art.yellow, .orange, Art.red][min(max(level, 0), 3)]
    }

    var body: some View {
        IllustrationRow {
            ArtTimeline { time in
                chip(time.map { (sin($0 * (1.2 + Double(level) * 0.6)) + 1) / 2 } ?? 0.5)
            }
        }
    }

    private func chip(_ pulse: Double) -> some View {
        let tint = Self.tint(level)
        let shell = RoundedRectangle(cornerRadius: 12, style: .continuous)
        let die = RoundedRectangle(cornerRadius: 6, style: .continuous)
        return ZStack {
            Circle()
                .fill(RadialGradient(colors: [tint.opacity(0.5), tint.opacity(0)], center: .center, startRadius: 8, endRadius: 64))
                .frame(width: 128, height: 128)
                .scaleEffect(0.8 + 0.2 * pulse)
            ZStack {
                ForEach(0..<4, id: \.self) { side in
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { _ in
                            Capsule()
                                .fill(Art.metal(scheme))
                                .frame(width: 4, height: 12)
                                .overlay(Capsule().hairline(Color.primary.opacity(0.2)))
                        }
                    }
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(side) * 90))
                }
                shell
                    .fill(Art.metal(scheme))
                    .frame(width: 72, height: 72)
                    .overlay(shell.hairline(Color.primary.opacity(0.15)))
                die
                    .fill(tint.gradient)
                    .frame(width: 34, height: 34)
                    .overlay(die.hairline(Color.primary.opacity(0.15)))
            }
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
    }
}

struct TemperatureRow: View {
    private let model = Temperatures.shared
    @State private var hovering = false
    @State private var watching = false

    private func watch(_ on: Bool) {
        guard on != watching else { return }
        watching = on
        if on { model.watch() } else { model.unwatch() }
    }

    private var summary: String {
        #if !APPSTORE
        if let celsius = model.readings[.processor] {
            return String(localized: "\(model.verdict) · Processor \(degrees(celsius))")
        }
        #endif
        return model.verdict
    }

    var body: some View {
        let level = model.level
        Button { SettingsWindow.show(.temperatures) } label: {
            HStack(spacing: 10) {
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(level == 0 ? Color.secondary : level == 1 ? Color.black.opacity(0.75) : Color.white)
                    .frame(width: 28, height: 28)
                    .background(level == 0 ? Color.secondary.opacity(0.15) : ThermalScene.tint(level), in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Temperature")
                        .font(.body)
                        .lineLimit(1)
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if hovering {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.fill.quaternary)
            }
        }
        .onHover { hovering = $0 }
        .onAppear { watch(true) }
        .onDisappear { watch(false) }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification)) { note in
            guard let window = note.object as? NSWindow, NSStringFromClass(type(of: window)).contains("MenuBarExtraWindow") else { return }
            watch(window.occlusionState.contains(.visible))
        }
    }
}
