import SwiftUI

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            Toggle(isOn: $isOn) {
                Text(title)
                Text(subtitle)
            }
        } else {
            row
        }
    }

    private var row: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? Color.white : Color.secondary)
                .frame(width: 28, height: 28)
                .background(isOn ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(10)
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
        .accessibilityRepresentation {
            Toggle(title, isOn: $isOn).accessibilityHint(subtitle)
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
