import SwiftUI

struct MenuView: View {
    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var keepAwake = KeepAwake.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach([SettingsTab.keyboard, .mouse, .windows], id: \.self) { tab in
                let tools = registry.tools.filter { $0.tab == tab }
                if !tools.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                            if index > 0 {
                                Divider().padding(.horizontal, 10)
                            }
                            tool.settingsView
                        }
                    }
                    .glassCard()
                }
            }

            ToggleRow(
                icon: "cup.and.saucer",
                title: String(localized: "Keep Awake"),
                subtitle: keepAwake.statusText,
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
    }
}
