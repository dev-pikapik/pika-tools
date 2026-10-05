import SwiftUI

struct MenuView: View {
    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var loginItem = LoginItem.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            VStack(spacing: 0) {
                ForEach(registry.tools, id: \.id) { tool in
                    tool.settingsView
                }
            }
            .glassCard()

            ToggleRow(
                icon: "power",
                title: "Открывать при входе",
                subtitle: loginItem.needsApproval
                    ? "Разреши в Настройках › Основные › Объекты входа"
                    : "Запустится сам, когда включишь Mac",
                isOn: $loginItem.isOn
            )
            .glassCard()

            if !permissions.accessibility {
                Label("Нет доступа — перехваты пока не работают", systemImage: "exclamationmark.triangle.fill")
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
                    Label("Проверить доступы", systemImage: "lock.shield")
                }
                Spacer()
                Button("Выйти") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .glassButtons()

            updateFooter
        }
        .padding(14)
        .frame(width: 310)
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
                Label("Обновить до \(version)", systemImage: "arrow.down.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }

        HStack(spacing: 6) {
            Text("Версия \(updater.current)")
            Text("·")
            switch updater.state {
            case .checking: Text("проверяю…")
            case .installing: Text("ставлю обновление…")
            case .upToDate: Text("свежая")
            case .available: Text("есть новая")
            case .failed(let message): Text(message).lineLimit(1).help(message)
            case .idle: EmptyView()
            }
            Spacer()
            Button("Проверить") { Task { await updater.check() } }
                .buttonStyle(.link)
                .disabled(updater.state == .checking || updater.state == .installing)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: registry.status.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(registry.status == .active ? Color.white : registry.status.color)
                .frame(width: 34, height: 34)
                .background(registry.status == .active ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                .contentTransition(.symbolEffect(.replace))

            VStack(alignment: .leading, spacing: 1) {
                Text("pika-tools").font(.headline)
                Text(registry.status.title)
                    .font(.subheadline)
                    .foregroundStyle(registry.status.color)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
        .animation(.snappy, value: registry.status)
    }
}
