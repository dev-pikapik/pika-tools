import SwiftUI

struct BatterySettings: View {
    private let battery = Battery.shared
    private static let batterySettings = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension")!
    private static let service = URL(string: "https://support.apple.com/mac/repair")!

    var body: some View {
        Form {
            SettingsHeader(tab: .battery, text: String(localized: "See how your battery is doing and how to make it last"))
            if let state = battery.state {
                Section {
                    VStack(spacing: 14) {
                        BatteryScene(charge: state.charge, phase: state.phase)
                        VStack(spacing: 2) {
                            Text(Double(state.charge) / 100, format: .percent)
                                .font(.system(size: 44, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                            Self.status(state)
                                .font(.headline)
                            if let note = Self.note(state) {
                                note
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .accessibilityElement(children: .combine)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .animation(.snappy, value: state)
                }
                health(state)
                power(state)
                tips
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .animation(.snappy, value: battery.health)
        .onAppear { battery.watch() }
        .onDisappear { battery.unwatch() }
    }

    private func health(_ state: BatteryState) -> some View {
        Section {
            if let normal = battery.health?.normal {
                LabeledContent {
                    if normal {
                        Text("Normal")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Service Recommended")
                            .foregroundStyle(.orange)
                        Link("Get Service…", destination: Self.service)
                    }
                } label: {
                    Label { RowLabel(Text("Condition")) } icon: { Image(systemName: "heart") }
                }
            }
            if let capacity = battery.health?.capacity {
                LabeledContent {
                    Text(Double(capacity) / 100, format: .percent)
                        .foregroundStyle(.secondary)
                } label: {
                    Label {
                        RowLabel(Text("Maximum Capacity"), Text("Compared with when it was new"))
                    } icon: { Image(systemName: "battery.100percent") }
                }
            }
            if let cycles = state.cycles {
                LabeledContent {
                    Text(cycles, format: .number)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                } label: {
                    Label {
                        RowLabel(Text("Cycle Count"), Text("Designed for \(Battery.ratedCycles.formatted()) cycles"))
                    } icon: { Image(systemName: "arrow.triangle.2.circlepath") }
                }
            }
        } header: {
            Text("Battery Health")
                .settingAnchor(String(localized: "Battery Health"))
        }
    }

    @ViewBuilder
    private func power(_ state: BatteryState) -> some View {
        let adapter = state.adapter != nil || state.adapterWatts != nil
        if adapter || state.watts != nil {
            Section {
                if adapter {
                    LabeledContent {
                        if let watts = state.adapterWatts {
                            Text(Self.watts(Double(watts), digits: 0))
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        Label {
                            RowLabel(Text("Power Adapter"), state.adapter.map { Text(verbatim: $0) })
                        } icon: { Image(systemName: "powerplug") }
                    }
                }
                if let watts = state.watts {
                    LabeledContent {
                        Text(Self.watts(watts, digits: 1))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                    } label: {
                        if state.phase == .charging {
                            Label {
                                RowLabel(Text("Charging Power"), Text("Going into the battery right now"))
                            } icon: { Image(systemName: "bolt") }
                        } else {
                            Label {
                                RowLabel(Text("Power Use"), Text("What your Mac uses right now"))
                            } icon: { Image(systemName: "gauge.with.dots.needle.50percent") }
                        }
                    }
                }
            } header: {
                Text("Power")
                    .settingAnchor(String(localized: "Power Adapter"))
            }
        }
    }

    private var tips: some View {
        Section {
            LabeledContent {
                Button("Battery Settings…") { NSWorkspace.shared.open(Self.batterySettings) }
            } label: {
                Label { Self.limit } icon: { Image(systemName: "battery.75percent") }
            }
            Label {
                RowLabel(Text("Keep It Cool"), Text("Use your Mac where it’s between \(Self.celsius(10)) and \(Self.celsius(35))"))
            } icon: { Image(systemName: "thermometer.medium") }
            Label {
                RowLabel(Text("Storing Your Mac"), Text("Charge it to about \(0.5.formatted(.percent)) and shut it down"))
            } icon: { Image(systemName: "archivebox") }
        } header: {
            Text("Keep It Healthy")
                .settingAnchor(String(localized: "Keep It Healthy"))
        }
    }

    #if arch(arm64)
    private static let appleSilicon = true
    #else
    private static let appleSilicon = false
    #endif

    private static var limit: RowLabel {
        if #available(macOS 26.4, *), appleSilicon {
            return RowLabel(Text("Charge Limit"), Text("Choose where charging stops, from \(0.8.formatted(.percent)) to \(1.0.formatted(.percent))"))
        }
        return RowLabel(Text("Optimized Battery Charging"), Text("Your Mac learns your routine and waits at \(0.8.formatted(.percent)) until you need it"))
    }

    private static func status(_ state: BatteryState) -> Text {
        switch state.phase {
        case .charging: state.minutes.map { Text("\(duration($0)) until fully charged") } ?? Text("Charging")
        case .full: Text("Fully Charged")
        case .onHold: Text("Charging on Hold")
        case .draining: Text("Not Charging")
        case .onBattery: state.minutes.map { Text("\(duration($0)) left") } ?? Text("Running on battery")
        }
    }

    private static func note(_ state: BatteryState) -> Text? {
        switch state.phase {
        case .onHold: Text("Your Mac paused charging to protect the battery")
        case .draining: Text("The power adapter can’t keep up, so the battery is helping")
        case .charging, .full, .onBattery: nil
        }
    }

    private static func duration(_ minutes: Int) -> String {
        Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    private static func watts(_ value: Double, digits: Int) -> String {
        Measurement(value: value, unit: UnitPower.watts)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(digits))))
    }

    private static func celsius(_ value: Double) -> String {
        Measurement(value: value, unit: UnitTemperature.celsius).formatted(.measurement(width: .abbreviated, usage: .weather))
    }
}

struct BatteryScene: View {
    let charge: Int
    let phase: BatteryState.Phase
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        IllustrationRow {
            if phase == .charging {
                ArtTimeline { time in battery(pulse: time.map { 1 + 0.06 * sin($0 * .pi) } ?? 1) }
            } else {
                battery(pulse: 1)
            }
        }
    }

    private var tint: Color {
        switch phase {
        case .charging, .full, .onHold: Art.green
        case .draining: Art.yellow
        case .onBattery: charge <= 20 ? Art.red : Color.primary.opacity(0.75)
        }
    }

    private var glyph: String? {
        switch phase {
        case .charging, .full: "bolt.fill"
        case .onHold: "pause.fill"
        case .draining: "bolt.slash.fill"
        case .onBattery: nil
        }
    }

    private func battery(pulse: Double) -> some View {
        let shell = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return HStack(spacing: 3) {
            ZStack(alignment: .leading) {
                shell
                    .fill(Art.metal(scheme))
                    .opacity(0.5)
                    .overlay(shell.hairline(Color.primary.opacity(0.15)))
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.gradient)
                    .frame(width: 140 * Double(charge) / 100)
                    .padding(6)
                if let glyph {
                    Image(systemName: glyph)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 1.5)
                        .scaleEffect(pulse)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: 152, height: 72)
            UnevenRoundedRectangle(bottomTrailingRadius: 4, topTrailingRadius: 4, style: .continuous)
                .fill(Color.primary.opacity(0.25))
                .frame(width: 7, height: 26)
        }
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}
