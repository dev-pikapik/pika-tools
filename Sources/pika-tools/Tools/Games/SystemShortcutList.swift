import AppKit
import SwiftUI

struct SystemShortcutList: View {
    @Bindable var tool: GameModeTool
    @State private var expanded: Set<GameShortcutGroup> = []
    @State private var listeners: [KeyboardListener] = []
    private var entries: [SystemGameShortcut] { SettingsWindow.model.systemShortcuts }

    var body: some View {
        Section {
            ForEach(GameShortcutGroup.allCases) { group in
                let rows = entries.filter { $0.group == group }
                if !rows.isEmpty {
                    DisclosureGroup(isExpanded: Binding(get: { expanded.contains(group) }, set: { if $0 { expanded.insert(group) } else { expanded.remove(group) } })) {
                        if expanded.contains(group) {
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
            if !listeners.isEmpty {
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
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in refresh() }
        .onChange(of: SettingsWindow.model.highlight, initial: true) {
            if let group = SettingsWindow.model.highlightedShortcut?.group ?? GameShortcutGroup.allCases.first(where: { $0.title == SettingsWindow.model.highlight }) { expanded.insert(group) }
        }
    }

    private func refresh() {
        listeners = KeyboardListener.load()
    }
}

struct SystemShortcutRow: View {
    let entry: SystemGameShortcut
    @Bindable var tool: GameModeTool

    private var choices: [Int32: GameShortcutMode] { SystemGameShortcut.overrides(tool.systemShortcuts) }
    private var mode: GameShortcutMode { entry.mode(rules: tool.rules, overrides: choices) }
    private var choice: GameShortcutMode { choices[entry.id] ?? .automatic }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            IllustrationRow { SystemShortcutArt(entry: entry, on: mode != .system, background: mode == .background) }
                .opacity(tool.isEnabled ? 1 : 0.5)
            BesideOrBelow {
                explanation
                shortcut
                behaviour
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .settingAnchor(entry.anchor)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(verbatim: entry.displayName)
            if let detail = entry.detail {
                Text(verbatim: detail).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if entry.assigned, !entry.enabled, !entry.emergency {
                Text("Off in macOS").font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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
            GameShortcutPicker(entry: entry, rules: tool.rules, selection: Binding(get: { choice }, set: { tool.setSystemShortcut(entry.id, mode: $0) }))
                .disabled(!tool.isEnabled)
        }
    }
}

private struct BesideOrBelow: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let frames = place(subviews, width: proposal.width)
        return CGSize(width: frames.map(\.maxX).max() ?? 0, height: frames.map(\.maxY).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, place(subviews, width: bounds.width)) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    private func place(_ subviews: Subviews, width: CGFloat?) -> [CGRect] {
        let shortcut = subviews[1].sizeThatFits(.unspecified)
        let behaviour = subviews[2].sizeThatFits(.unspecified)
        let controls = shortcut.width + 12 + behaviour.width
        let beside = max(180, subviews[0].sizeThatFits(.unspecified).width) + 12 + controls
        let width = width ?? beside
        let row = max(shortcut.height, behaviour.height)
        if beside <= width {
            let column = width - 12 - controls
            let text = subviews[0].sizeThatFits(ProposedViewSize(width: column, height: nil))
            let height = max(text.height, row)
            return [
                CGRect(x: 0, y: (height - text.height) / 2, width: column, height: text.height),
                CGRect(x: width - controls, y: (height - shortcut.height) / 2, width: shortcut.width, height: shortcut.height),
                CGRect(x: width - behaviour.width, y: (height - behaviour.height) / 2, width: behaviour.width, height: behaviour.height),
            ]
        }
        let text = subviews[0].sizeThatFits(ProposedViewSize(width: width, height: nil))
        let top = text.height + 10
        if controls <= width {
            return [
                CGRect(x: 0, y: 0, width: width, height: text.height),
                CGRect(x: width - controls, y: top + (row - shortcut.height) / 2, width: shortcut.width, height: shortcut.height),
                CGRect(x: width - behaviour.width, y: top + (row - behaviour.height) / 2, width: behaviour.width, height: behaviour.height),
            ]
        }
        return [
            CGRect(x: 0, y: 0, width: width, height: text.height),
            CGRect(x: width - shortcut.width, y: top, width: shortcut.width, height: shortcut.height),
            CGRect(x: width - behaviour.width, y: top + shortcut.height + 8, width: behaviour.width, height: behaviour.height),
        ]
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
