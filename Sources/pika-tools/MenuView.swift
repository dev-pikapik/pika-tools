import SwiftUI

struct MenuView: View {
    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var keepAwake = KeepAwake.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            VStack(spacing: 0) {
                ForEach(Array(registry.tools.enumerated()), id: \.element.id) { index, tool in
                    if index > 0 {
                        Divider().padding(.horizontal, 10)
                    }
                    tool.settingsView
                }
            }
            .glassCard()

            ToggleRow(
                icon: "cup.and.saucer",
                title: String(localized: "Keep Awake"),
                subtitle: keepAwake.status,
                isOn: $keepAwake.isOn
            )
            .glassCard()

            if !permissions.allGranted {
                Button {
                    SettingsWindow.show(.permissions)
                } label: {
                    Label("Permissions needed", systemImage: "exclamationmark.triangle.fill")
                        .font(.callout)
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 4)
            }

            HStack {
                Button("Settings…") { SettingsWindow.show() }
                    .keyboardShortcut(",")
                Spacer(minLength: 8)
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .fixedSize(horizontal: false, vertical: true)
            .glassButtons()

            updateFooter
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(width: 310)
        .onAppear { permissions.refresh() }
    }

    @ViewBuilder
    private var updateFooter: some View {
        let updater = Updater.shared
        if case .available(let version) = updater.state {
            Button {
                Task { await updater.install() }
            } label: {
                Label("Update to \(version)", systemImage: "arrow.down.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }

        HStack(spacing: 6) {
            Text("Version \(updater.current)")
            if let status = updater.state.title {
                Text("·")
                Text(status)
                    .lineLimit(1)
                    .help(status)
            }
            Spacer(minLength: 8)
            Button("Check") { Task { await updater.check() } }
                .buttonStyle(.link)
                .fixedSize(horizontal: true, vertical: false)
                .disabled(updater.state == .checking || updater.state == .installing)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: registry.status.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(registry.status == .active ? Color.white : registry.status.color)
                .frame(width: 34, height: 34)
                .background(registry.status == .active ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                .contentTransition(.symbolEffect(.replace))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text("pika-tools").font(.headline)
                Text(registry.status.title)
                    .font(.subheadline)
                    .foregroundStyle(registry.status.color)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .animation(.snappy, value: registry.status)
    }
}
