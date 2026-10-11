import SwiftUI

struct FanSettings: View {
    private let control = FanControl.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .fans, text: String(localized: "See how fast your fans spin and choose their speed"))
            if control.hasFans {
                ForEach(control.fans, id: \.id) { fan in
                    FanCard(fan: fan, title: control.fans.count > 1 ? Text("Fan \(fan.id + 1)") : nil)
                }
                Section {
                    LabeledContent {
                        if control.ready {
                            Button("Remove") { control.uninstall() }
                        } else {
                            Button("Allow control") { control.install() }
                                .buttonStyle(.borderedProminent)
                        }
                    } label: {
                        RowLabel(Text("Fan control"), control.ready ? Text("Allowed") : Text("Needs your administrator password once"))
                    }
                    .disabled(control.busy)
                    .settingAnchor(String(localized: "Fan control"))
                    if let error = control.error {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            } else {
                Section {
                    FanScene(rpm: 0, maximum: 1, manual: false)
                    RowLabel(Text("This Mac has no fans"), Text("It cools itself quietly, so there is nothing to set"))
                        .padding(.vertical, 4)
                }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .onAppear { control.watch() }
        .onDisappear { control.unwatch() }
    }
}

private struct FanCard: View {
    let fan: SMCFan
    let title: Text?
    private let control = FanControl.shared
    @State private var draft: Double

    init(fan: SMCFan, title: Text?) {
        self.fan = fan
        self.title = title
        _draft = State(initialValue: FanControl.shared.savedRPM(fan))
    }

    private var manual: Bool { control.wanted[fan.id] != nil }

    var body: some View {
        Section {
            VStack(spacing: 14) {
                FanScene(rpm: fan.current, maximum: fan.maximum, manual: fan.manual)
                    .settingAnchor(String(localized: "Fan speed"))
                VStack(spacing: 0) {
                    Text(Int(fan.current.rounded()), format: .number.grouping(.never))
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text("rpm")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                if control.ready {
                    Picker("Fan speed", selection: Binding(get: { manual }, set: { choose(manual: $0) })) {
                        Text("Auto").tag(false)
                        Text("Manual").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    if manual {
                        Slider(value: $draft, in: fan.minimum...fan.maximum, step: 50) {
                            Text("Fan speed")
                        } minimumValueLabel: {
                            Text(Int(fan.minimum), format: .number.grouping(.never))
                        } maximumValueLabel: {
                            Text(Int(fan.maximum), format: .number.grouping(.never))
                        } onEditingChanged: { editing in
                            if !editing { control.setManual(fan, rpm: draft) }
                        }
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        Text("Slower fans can make your Mac hotter")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .animation(.snappy, value: manual)
        } header: {
            title
        }
    }

    private func choose(manual on: Bool) {
        if on {
            draft = control.savedRPM(fan)
            control.setManual(fan, rpm: draft)
        } else {
            control.setAuto(fan.id)
        }
    }
}

struct FanRow: View {
    private let control = FanControl.shared
    @State private var hovering = false
    @State private var watching = false

    private func watch(_ on: Bool) {
        guard on != watching else { return }
        watching = on
        if on { control.watch() } else { control.unwatch() }
    }

    var body: some View {
        Button { SettingsWindow.show(.fans) } label: {
            HStack(spacing: 10) {
                Image(systemName: "fan")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(control.wanted.isEmpty ? Color.secondary : Color.white)
                    .frame(width: 28, height: 28)
                    .background(control.wanted.isEmpty ? Color.secondary.opacity(0.15) : Color.accentColor, in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Fans")
                        .font(.body)
                        .lineLimit(1)
                    control.summary
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

struct FanScene: View {
    let rpm: Double
    let maximum: Double
    let manual: Bool
    @State private var spin = Spin()
    @Environment(\.colorScheme) private var scheme

    private final class Spin {
        var angle = 0.0
        var last: Double?

        func advance(to time: Double, speed: Double) -> Double {
            if let last { angle = (angle + (time - last) * speed).truncatingRemainder(dividingBy: 360) }
            last = time
            return angle
        }
    }

    var body: some View {
        let speed = min(rpm * 0.09, 700)
        IllustrationRow {
            ArtTimeline { time in
                let angle = time.map { spin.advance(to: $0, speed: speed) } ?? 0
                fan(angle)
            }
        }
    }

    private func fan(_ angle: Double) -> some View {
        let tint = manual ? Color.accentColor : Color.primary
        return ZStack {
            Circle()
                .fill(Art.metal(scheme))
                .opacity(0.5)
                .frame(width: 104, height: 104)
                .overlay(Circle().hairline(Color.primary.opacity(0.15)))
            ForEach(0..<7, id: \.self) { index in
                FanBlade()
                    .fill(tint.opacity(manual ? 0.85 : 0.55))
                    .rotationEffect(.degrees(angle + Double(index) * 360 / 7))
            }
            .frame(width: 92, height: 92)
            Circle()
                .fill(Art.metal(scheme))
                .frame(width: 26, height: 26)
                .overlay(Circle().hairline(Color.primary.opacity(0.25)))
        }
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}

private struct FanBlade: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        func point(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: c.x + x * r, y: c.y + y * r) }
        var path = Path()
        path.move(to: point(0, -0.14))
        path.addQuadCurve(to: point(0.46, -0.96), control: point(0.74, -0.42))
        path.addQuadCurve(to: point(-0.1, -0.14), control: point(0.02, -0.72))
        path.closeSubpath()
        return path
    }
}
