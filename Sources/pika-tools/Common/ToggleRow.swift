import SwiftUI

struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? Color.white : Color.secondary)
                .frame(width: 28, height: 28)
                .background(isOn ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body.weight(.medium))
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
        .animation(.snappy, value: isOn)
    }
}
