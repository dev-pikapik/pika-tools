import AppKit
import SwiftUI

struct SystemShortcutList: View {
    @Bindable var tool: GameModeTool
    @State private var entries: [SystemGameShortcut] = []
    @State private var search = ""
    @State private var expanded: Set<GameShortcutGroup> = []
    @State private var collapsedResults: Set<GameShortcutGroup> = []
    @State private var listeners: [KeyboardListener] = []

    private var isSearching: Bool { !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private func isOpen(_ group: GameShortcutGroup) -> Bool { isSearching ? !collapsedResults.contains(group) : expanded.contains(group) }

    private func open(_ group: GameShortcutGroup, _ value: Bool) {
        if isSearching {
            if value { collapsedResults.remove(group) } else { collapsedResults.insert(group) }
        } else {
            if value { expanded.insert(group) } else { expanded.remove(group) }
        }
    }

    private var filtered: [SystemGameShortcut] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? entries : entries.filter {
            [$0.displayName, $0.rawName, $0.group.title, $0.description.text, $0.sectionName, $0.text ?? "", String($0.id)]
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        Section {
            Text("Current macOS shortcuts. Automatic protects the game.")
                .font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary).accessibilityHidden(true)
                TextField("Search system shortcuts", text: $search)
                    .textFieldStyle(.roundedBorder).labelsHidden()
                Button("Refresh") { refresh() }
            }
            ForEach(GameShortcutGroup.allCases) { group in
                let rows = filtered.filter { $0.group == group }
                if !rows.isEmpty {
                    DisclosureGroup(isExpanded: Binding(get: { isOpen(group) }, set: { open(group, $0) })) {
                        if isOpen(group) {
                            ForEach(rows) { row in
                                SystemShortcutRow(entry: row, tool: tool).padding(.vertical, 14)
                                if row.id != rows.last?.id { Divider() }
                            }
                        }
                    } label: {
                        GameDisclosureLabel(title: group.title, detail: group.detail, symbol: group.symbol, count: rows.count)
                    }
                    .disclosureGroupStyle(GameDisclosureStyle())
                    .settingAnchor(group.title)
                }
            }
            if filtered.isEmpty, isSearching {
                Text("No Results").foregroundStyle(.secondary).padding(.vertical, 12)
            }
            if !listeners.isEmpty, !isSearching {
                DisclosureGroup {
                    ForEach(listeners) { listener in
                        LabeledContent {
                            (listener.changesKeys ? Text("Can change keys") : Text("Only listens")).foregroundStyle(.secondary)
                        } label: { Text(verbatim: listener.name) }
                    }
                    Text("These apps don’t publish their shortcuts in the macOS catalogue.")
                        .font(.footnote).foregroundStyle(.secondary)
                } label: {
                    GameDisclosureLabel(title: String(localized: "Other apps watching keys"), detail: String(localized: "Apps that can observe or change keyboard input."), symbol: "app.connected.to.app.below.fill", count: listeners.count)
                }
                .disclosureGroupStyle(GameDisclosureStyle())
            }
        } header: {
            HStack {
                Text("System keyboard shortcuts")
                Spacer(minLength: 0)
                Text(verbatim: String(entries.count)).foregroundStyle(.secondary)
            }
        } footer: {
            Text("Some macOS actions have no published name. Other apps may have their own shortcuts.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .settingAnchor(String(localized: "System keyboard shortcuts"))
        .onAppear(perform: refresh)
        .onChange(of: search) { collapsedResults = [] }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in refresh() }
        .onChange(of: SettingsWindow.model.highlight, initial: true) {
            if let group = GameShortcutGroup.allCases.first(where: { $0.title == SettingsWindow.model.highlight }) { expanded.insert(group) }
        }
    }

    private func refresh() {
        entries = SystemShortcutCatalog.load()
        listeners = KeyboardListener.load()
    }
}

struct SystemShortcutRow: View {
    let entry: SystemGameShortcut
    @Bindable var tool: GameModeTool

    private var choices: [Int32: GameShortcutMode] { SystemGameShortcut.overrides(tool.systemShortcuts) }
    private var mode: GameShortcutMode { entry.mode(rules: tool.rules, overrides: choices) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 18) {
                    preview
                    explanation.frame(minWidth: 220, maxWidth: .infinity, alignment: .leading)
                }
                VStack(alignment: .leading, spacing: 12) {
                    explanation
                    preview.frame(maxWidth: .infinity)
                }
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    shortcut
                    Spacer(minLength: 12)
                    behaviour
                }
                VStack(alignment: .leading, spacing: 10) {
                    shortcut
                    behaviour
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .settingAnchor(entry.displayName)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(verbatim: entry.displayName).fontWeight(.medium)
            Text(verbatim: entry.description.text).font(.subheadline).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if entry.assigned, !entry.emergency {
                Text(verbatim: entry.behaviour(mode)).font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var preview: some View {
        SystemShortcutArt(entry: entry, on: mode != .system, background: mode == .background)
            .hostedApart().frame(width: 170, height: 108)
            .opacity(tool.isEnabled && entry.assigned && entry.enabled ? 1 : 0.5).accessibilityHidden(true)
    }

    @ViewBuilder private var shortcut: some View {
        if let text = entry.text {
            KeyCaps(keys: [text], system: SystemShortcuts.place([entry.id]))
        } else {
            ShortcutAssignmentLink(place: SystemShortcuts.place([entry.id]))
        }
    }

    @ViewBuilder private var behaviour: some View {
        if entry.emergency {
            Label("Always available", systemImage: "lock.open").font(.subheadline).foregroundStyle(.secondary)
        } else {
            HStack(spacing: 8) {
                Text("While playing").font(.subheadline).foregroundStyle(.secondary)
                Picker("While playing", selection: Binding(get: { choices[entry.id] ?? .automatic }, set: { tool.setSystemShortcut(entry.id, mode: $0) })) {
                    ForEach(GameShortcutMode.allCases.filter { $0 != .background || entry.supportsBackground }, id: \.self) { choice in
                        Text(choice.title).tag(choice)
                    }
                }
                .labelsHidden().fixedSize().disabled(!tool.isEnabled)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

private struct ShortcutAssignmentLink: View {
    let place: SystemShortcuts.Place
    @State private var showsHint = false

    var body: some View {
        Button("No key assigned") { SystemShortcuts.open(place) { showsHint = true } }
            .buttonStyle(.link).help(Text("Change in System Settings"))
            .popover(isPresented: $showsHint) {
                Text(place.hint ?? String(localized: "Change in System Settings"))
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: 320).padding(12)
            }
    }
}
