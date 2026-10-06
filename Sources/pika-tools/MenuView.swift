import SwiftUI

struct MenuView: View {
    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var keepAwake = KeepAwake.shared
    @AppStorage("quick-hidden") private var hiddenList = ""
    @State private var customizing = false
    @State private var contentHeight: CGFloat = 0

    // Room left for the rows: the screen the panel is on, minus footer, padding and menu bar gap.
    private var maxRowsHeight: CGFloat {
        ((NSApp.keyWindow?.screen ?? NSScreen.main)?.visibleFrame.height ?? 700) - 140
    }

    private var hidden: Set<String> { Set(hiddenList.split(separator: ",").map(String.init)) }

    private func isShown(_ id: String) -> Bool { customizing || !hidden.contains(id) }

    private func binding(_ id: String) -> Binding<Bool> {
        Binding(
            get: { !hidden.contains(id) },
            set: { shown in
                var ids = hidden
                if shown { ids.remove(id) } else { ids.insert(id) }
                hiddenList = ids.sorted().joined(separator: ",")
            }
        )
    }

    @ViewBuilder
    private func customizeRow(icon: String, title: String, id: String) -> some View {
        Toggle(isOn: binding(id)) {
            Label(title, systemImage: icon)
        }
        .toggleStyle(.checkbox)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([SettingsTab.keyboard, .mouse, .windows], id: \.self) { tab in
                        let tools = registry.tools.filter { $0.tab == tab && isShown($0.id) }
                        if !tools.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                                    if index > 0 {
                                        Divider().padding(.horizontal, 10)
                                    }
                                    if customizing {
                                        customizeRow(icon: tool.icon, title: tool.title, id: tool.id)
                                    } else {
                                        tool.settingsView
                                    }
                                }
                            }
                            .glassCard()
                        }
                    }

                    if isShown("keep-awake") {
                        if customizing {
                            customizeRow(icon: "cup.and.saucer", title: String(localized: "Keep Awake"), id: "keep-awake")
                                .glassCard()
                        } else {
                            ToggleRow(
                                icon: "cup.and.saucer",
                                title: String(localized: "Keep Awake"),
                                subtitle: keepAwake.statusText,
                                isOn: $keepAwake.isOn
                            )
                            .glassCard()
                        }
                    }

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
                }
                .background(GeometryReader { geo in
                    Color.clear.onChange(of: geo.size.height, initial: true) { contentHeight = geo.size.height }
                })
            }
            // A ScrollView has no natural height in an auto-sized window, so give it the measured one.
            .frame(height: min(contentHeight, maxRowsHeight))

            HStack {
                Button("Settings…") { SettingsWindow.show() }
                    .keyboardShortcut(",")
                Button(customizing ? "Done" : "Customize…") { customizing.toggle() }
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
