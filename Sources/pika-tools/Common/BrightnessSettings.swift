import SwiftUI

struct BrightnessSettings: View {
    private let model = Brightness.shared
    private let keys = BrightnessKeysTool.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .brightness, text: String(localized: "Change the brightness of monitors macOS can’t adjust on its own."))
            if model.monitors.isEmpty {
                Section {
                    Text("No monitor needs pikapik right now. macOS adjusts the built-in screen and Apple displays itself, with the brightness keys and in Control Center. Connect another monitor and it will appear here.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .settingAnchor(String(localized: "Brightness"))
                }
            } else {
                let firstControlled = model.monitors.first { $0.hasControl }?.id
                ForEach(model.monitors) { monitor in
                    MonitorSection(
                        monitor: monitor,
                        anchor: monitor.id == model.monitors.first?.id ? String(localized: "Brightness") : "brightness-\(monitor.id)",
                        toggleAnchor: monitor.id == firstControlled ? String(localized: "Dim the picture instead") : "dim-picture-\(monitor.id)"
                    )
                }
            }
            Section { keys.settingsView.needs(keys.needs) }
        }
        .formStyle(.grouped)
        .settingsPage()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PermissionBar(permissions: keys.needs)
        }
        .environment(\.inSettings, true)
        .whileShown { if $0 { model.watch() } else { model.unwatch() } }
    }
}

private struct MonitorSection: View {
    let monitor: Brightness.Monitor
    let anchor: String
    let toggleAnchor: String

    private var mode: String {
        #if APPSTORE
        String(localized: "Dims the picture.")
        #else
        if !monitor.hasControl {
            String(localized: "Dims the picture. This monitor doesn’t let the Mac change its brightness.")
        } else if monitor.dimsPicture {
            String(localized: "Dims the picture.")
        } else {
            String(localized: "Changes the monitor’s own brightness.")
        }
        #endif
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                BrightnessSlider(monitor: monitor, showsPercent: true)
                    .settingAnchor(anchor)
                Text(mode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if !monitor.usesPicture && !monitor.reports {
                    Text("The monitor doesn’t report its brightness, so the slider stays where you left it.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 4)
            #if !APPSTORE
            if monitor.hasControl {
                Toggle(isOn: Binding(get: { monitor.dimsPicture }, set: { Brightness.shared.setDimsPicture($0, for: monitor.id) })) {
                    RowLabel(Text("Dim the picture instead"), Text("Turn on if the monitor doesn’t respond to the slider."))
                }
                .settingAnchor(toggleAnchor)
            }
            #endif
        } header: {
            Text(monitor.name)
        }
    }
}

struct BrightnessSlider: View {
    let monitor: Brightness.Monitor
    var showsPercent = false

    var body: some View {
        let percent = monitor.level.formatted(.percent.precision(.fractionLength(0)))
        HStack(spacing: 8) {
            Image(systemName: "sun.min")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Slider(value: Binding(get: { monitor.level }, set: { Brightness.shared.set($0, for: monitor.id) }), in: 0...1) {
                Text("Brightness of \(monitor.name)")
            }
            .labelsHidden()
            .accessibilityValue(Text(percent))
            Image(systemName: "sun.max")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            if showsPercent {
                Text(percent)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 40, alignment: .trailing)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct BrightnessRow: View {
    private let model = Brightness.shared
    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { SettingsWindow.show(.brightness) } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.secondary.opacity(0.15), in: Circle())
                        .accessibilityHidden(true)
                    Text("Brightness")
                        .font(.body)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if hovering {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.fill.quaternary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            ForEach(model.monitors) { monitor in
                VStack(alignment: .leading, spacing: 0) {
                    if model.monitors.count > 1 {
                        Text(monitor.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    BrightnessSlider(monitor: monitor)
                }
                .padding(.leading, 46)
                .padding(.trailing, 8)
                .padding(.bottom, 6)
            }
        }
        .whileShown(in: StatusMenu.isPanel) { if $0 { model.watch() } else { model.unwatch() } }
    }
}
