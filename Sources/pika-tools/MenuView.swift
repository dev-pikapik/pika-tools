import SwiftUI

struct MenuView: View {
    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var loginItem = LoginItem.shared

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
                icon: "power",
                title: String(localized: "Open at Login"),
                subtitle: loginItem.needsApproval
                    ? String(localized: "Allow it in System Settings › General › Login Items")
                    : String(localized: "Starts on its own when you log in"),
                isOn: $loginItem.isOn
            )
            .glassCard()

            if !permissions.accessibility {
                Label("No access yet, so the tools can’t work", systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 4)
            }

            HStack {
                Button {
                    permissions.refresh()
                    registry.refresh()
                    PermissionsWindow.show()
                } label: {
                    Label("Check Permissions", systemImage: "lock.shield")
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
                    .fixedSize(horizontal: true, vertical: false)
            }
            .glassButtons()

            updateFooter
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(width: 330)
        .onAppear {
            permissions.refresh()
            loginItem.refresh()
        }
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
            Text("·")
            Group {
                switch updater.state {
                case .checking: Text("checking…")
                case .installing: Text("installing update…")
                case .upToDate: Text("up to date")
                case .available: Text("update available")
                case .failed(let message): Text(message).help(message)
                case .idle: EmptyView()
                }
            }
            .lineLimit(1)
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
