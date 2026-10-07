import SwiftUI

struct MenuView: View {
    static let defaultHidden = "command-keys,compress,convert,dock-hide,finder-cut,finder-delete,finder-open,home-end,key-repeat,new-file,quit-on-close,side-buttons,wheel-direction,wheel-lines,window-zoom"

    let registry: ToolRegistry
    private let permissions = Permissions.shared
    @Bindable private var keepAwake = KeepAwake.shared
    @AppStorage("quick-hidden") private var hiddenList = MenuView.defaultHidden
    @State private var customizing = false
    @State private var contentHeight: CGFloat = 0

    // Room left for the rows: the screen the panel is on, minus footer, padding and menu bar gap.
    private var maxRowsHeight: CGFloat {
        ((NSApp.keyWindow?.screen ?? NSScreen.main)?.visibleFrame.height ?? 700) - 140
    }

    private var hidden: Set<String> { Set(hiddenList.split(separator: ",").map(String.init)) }

    private func isShown(_ id: String) -> Bool { customizing || !hidden.contains(id) }

    private var visibleTabs: [SettingsTab] {
        [.keyboard, .mouse, .windows, .dock, .finder].filter { tab in registry.tools.contains { $0.tab == tab && isShown($0.id) } }
    }

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
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon).frame(width: 20)
            }
        }
        .toggleStyle(.checkbox)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 9)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if customizing {
                Text("Choose what this menu shows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !visibleTabs.isEmpty || isShown("keep-awake") {
                        VStack(spacing: 0) {
                            if isShown("keep-awake") {
                                if customizing {
                                    customizeRow(icon: "cup.and.saucer", title: String(localized: "Keep Awake"), id: "keep-awake")
                                } else {
                                    ToggleRow(
                                        icon: "cup.and.saucer",
                                        title: String(localized: "Keep Awake"),
                                        subtitle: keepAwake.statusText,
                                        hint: keepAwake.statusText,
                                        isOn: $keepAwake.isOn
                                    )
                                }
                            }

                            ForEach(Array(visibleTabs.enumerated()), id: \.element) { index, tab in
                                if index > 0 || isShown("keep-awake") { groupDivider }
                                ForEach(registry.tools.filter { $0.tab == tab && isShown($0.id) }, id: \.id) { tool in
                                    if customizing {
                                        customizeRow(icon: tool.icon, title: tool.title, id: tool.id)
                                    } else {
                                        tool.settingsView
                                    }
                                }
                            }
                        }
                        .padding(6)
                        .glassCard()
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
            .scrollClipDisabled(contentHeight <= maxRowsHeight)
            .scrollBounceBehavior(.basedOnSize)

            HStack(spacing: 8) {
                if customizing {
                    Spacer(minLength: 8)
                    Button("Done") { customizing = false }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button { SettingsWindow.show() } label: { Label("Settings…", systemImage: "gearshape") }
                        .keyboardShortcut(",")
                        .help("Settings…")
                    Button { customizing = true } label: { Label("Customize…", systemImage: "pencil") }
                        .help("Customize…")
                    Spacer(minLength: 8)
                    Button { KeepAwake.shared.set(.off); NSApp.terminate(nil) } label: { Label("Quit", systemImage: "power") }
                        .keyboardShortcut("q")
                        .help("Quit")
                }
            }
            .labelStyle(.iconOnly)
            .buttonBorderShape(customizing ? .automatic : .circle)
            .fixedSize(horizontal: false, vertical: true)
            .glassButtons()

            updateFooter
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(width: 330)
        .onAppear { permissions.refresh() }
    }

    private var groupDivider: some View {
        Divider().padding(.horizontal, 8).padding(.vertical, 4)
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
