import AppKit
import SwiftUI

struct UninstallerPage: View {
    @Bindable private var model = UninstallerModel.shared
    private let permissions = Permissions.shared
    private let watch = TrashWatchTool.shared
    @State private var sheetHeight: CGFloat = 540
    static let viewport = "uninstaller-list"

    var body: some View {
        Form {
            SettingsHeader(tab: .uninstaller, text: String(localized: "Remove an app and its files. You can put it all back."))
            Section {
                UninstallerArt(replay: model.plays)
                    .appDropZone("uninstaller") { model.open(dropped: $0) }
            }
            TrashedSection()
            RemovedSection()
            Section {
                Group {
                    searchRow
                    if let notice = model.notice {
                        Text(notice)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(model.shown) { entry in
                        InstalledRow(entry: entry, running: model.running.contains(entry.id)) { model.open(entry.app) }
                    }
                    if model.loaded, model.shown.isEmpty, !model.query.isEmpty {
                        Text("No apps found")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .needs([.fullDisk])
            }
            LeftoversSection()
            Section { watch.settingsView.needs(watch.needs) }
        }
        .formStyle(.grouped)
        .coordinateSpace(.named(Self.viewport))
        .onGeometryChange(for: CGFloat.self) { $0.size.height - $0.safeAreaInsets.top } action: { sheetHeight = min(540, max(360, $0 - 24)) }
        .settingsPage()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PermissionBar(permissions: [.fullDisk])
        }
        .environment(\.inSettings, true)
        .sheet(item: $model.session) { UninstallerSheet(session: $0, height: sheetHeight) }
        .onAppear {
            permissions.refresh()
            model.appear()
        }
        .onDisappear { model.disappear() }
        .onChange(of: permissions.fileAccess) { model.reload() }
        .onChange(of: model.query) { model.reshuffle() }
        .onChange(of: model.sort) { model.reshuffle() }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)) { _ in model.refreshRunning() }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)) { _ in model.refreshRunning() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in permissions.refresh() }
    }

    private var searchRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(text: $model.query, prompt: Text("Search apps")) { Text("Search apps") }
                .textFieldStyle(.plain)
                .labelsHidden()
            Picker(selection: $model.sort) {
                ForEach(AppSort.allCases, id: \.self) { Text($0.title).tag($0) }
            } label: {
                Text("Sort by")
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .fixedSize()
        }
        .settingAnchor(String(localized: "Remove an app"))
    }
}

private struct InstalledRow: View {
    let entry: AppEntry
    let running: Bool
    let open: () -> Void
    @State private var near = false
    private let model = UninstallerModel.shared

    var body: some View {
        Group {
            if near {
                Button(action: open) { label }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([entry.app.url]) }
                    }
            } else {
                Color.clear
            }
        }
        .frame(height: 40)
        .onGeometryChange(for: Bool.self) { proxy in
            guard let viewport = proxy.bounds(of: .named(UninstallerPage.viewport)) else { return false }
            return viewport.insetBy(dx: 0, dy: -viewport.height / 2).intersects(CGRect(origin: .zero, size: proxy.size))
        } action: { visible in
            if visible { model.want(entry) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { if near != visible { near = visible } }
        }
    }

    private var label: some View {
        AppRowLabel(icon: model.icon(at: entry.app.url), name: entry.app.displayName, running: running, byline: entry.app.byline) {
            SizeColumn(size: entry.size, caption: entry.lastUsed.map { UninstallerText.used(min($0, Date())) } ?? "")
            RowChevron()
        }
    }
}
