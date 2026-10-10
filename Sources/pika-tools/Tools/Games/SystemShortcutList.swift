import AppKit
import SwiftUI

struct SystemShortcutList: View {
    @Bindable var tool: GameModeTool
    @State private var entries: [SystemGameShortcut] = []
    @State private var search = ""
    @State private var expanded: Set<String> = []
    @State private var listeners: [KeyboardListener] = []

    private var isSearching: Bool { !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private var filtered: [SystemGameShortcut] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? entries : entries.filter {
            [$0.name, $0.rawName, $0.sectionName, $0.text ?? "", String($0.id)].contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        Section {
            Text("Current macOS shortcuts. Automatic protects the game.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                TextField("Search system shortcuts", text: $search)
                Button("Refresh") { refresh() }
            }
            ForEach(Array(Dictionary(grouping: filtered, by: \.section).keys.sorted()), id: \.self) { section in
                let rows = filtered.filter { $0.section == section }
                DisclosureGroup(isExpanded: Binding(get: { isSearching || expanded.contains(section) }, set: { if $0 { expanded.insert(section) } else { expanded.remove(section) } })) {
                    if isSearching || expanded.contains(section) {
                        ForEach(rows) { row in
                            let choices = SystemGameShortcut.overrides(tool.systemShortcuts)
                            let mode = row.mode(rules: tool.rules, overrides: choices)
                            VStack(spacing: 10) {
                                IllustrationRow { SystemShortcutArt(entry: row, on: mode != .system, background: mode == .background) }
                                    .opacity(tool.isEnabled ? 1 : 0.5)
                                LabeledContent {
                                    HStack(spacing: 12) {
                                        KeyCaps(keys: [row.text ?? ""], system: SystemShortcuts.place([row.id]))
                                        Picker("While playing", selection: Binding(get: { choices[row.id] ?? .automatic }, set: { tool.setSystemShortcut(row.id, mode: $0) })) {
                                            ForEach(GameShortcutMode.allCases.filter { $0 != .background || row.supportsBackground }, id: \.self) { choice in
                                                Text(choice.title).tag(choice)
                                            }
                                        }
                                        .labelsHidden()
                                        .fixedSize()
                                        .disabled(!tool.isEnabled || row.emergency)
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        RowLabel(Text(verbatim: row.name), row.emergency ? Text("Always available") : !row.assigned ? Text("No key assigned") : !row.enabled ? Text("Off in macOS") : mode == .background ? Text("Run without interrupting") : nil)
                                    }
                                }
                            }
                            .settingAnchor(row.name)
                        }
                    }
                } label: {
                    HStack {
                        Text(verbatim: rows.first?.sectionName ?? section)
                        Spacer(minLength: 0)
                        Text(verbatim: String(rows.count)).foregroundStyle(.secondary)
                    }
                }
            }
            if !listeners.isEmpty {
                DisclosureGroup("Other apps watching keys") {
                    ForEach(listeners) { listener in
                        LabeledContent {
                            (listener.changesKeys ? Text("Can change keys") : Text("Only listens")).foregroundStyle(.secondary)
                        } label: {
                            Text(verbatim: listener.name)
                        }
                    }
                    Text("These apps don’t publish their shortcuts in the macOS catalogue.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack {
                Text("System keyboard shortcuts")
                Spacer(minLength: 0)
                Text(verbatim: String(entries.count)).foregroundStyle(.secondary)
            }
        } footer: {
            Text("Some macOS actions have no published name. Other apps may have their own shortcuts.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .settingAnchor(String(localized: "System keyboard shortcuts"))
        .onAppear(perform: refresh)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in refresh() }
    }

    private func refresh() {
        entries = SystemShortcutCatalog.load()
        listeners = KeyboardListener.load()
    }
}
