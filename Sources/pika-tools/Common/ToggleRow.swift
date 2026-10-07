import SwiftUI

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: Text
    var hint: Text?
    var help: Text?
    var keys: [String] = []
    @Binding var isOn: Bool
    @Environment(\.inSettings) private var inSettings
    @State private var hovering = false

    var body: some View {
        if inSettings {
            let toggle = Toggle(isOn: $isOn) {
                KeyLabel(keys: keys, title: Text(title), subtitle: subtitle)
            }
            .settingAnchor(title)
            if let help {
                toggle.help(help)
            } else {
                toggle
            }
        } else {
            row
        }
    }

    private var row: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isOn ? Color.white : Color.secondary)
                    .frame(width: 28, height: 28)
                    .background(isOn ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.body)
                        .lineLimit(2)
                    if let hint {
                        hint
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 0)
                if !keys.isEmpty { KeyCaps(keys: keys) }
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
        .help(help ?? subtitle)
        .accessibilityRepresentation {
            Toggle(title, isOn: $isOn).accessibilityHint(help ?? subtitle)
        }
        .animation(.snappy, value: isOn)
    }
}

private struct InSettingsKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var inSettings: Bool {
        get { self[InSettingsKey.self] }
        set { self[InSettingsKey.self] = newValue }
    }
}
