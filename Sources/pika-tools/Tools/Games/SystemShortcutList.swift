import AppKit
import SwiftUI

struct SystemShortcutList: View {
    @Bindable var tool: GameModeTool
    @State private var expanded: Set<GameShortcutGroup> = []
    @State private var listeners: [KeyboardListener] = []
    static let viewport = "system-shortcuts-viewport"
    private var entries: [SystemGameShortcut] { SettingsWindow.model.systemShortcuts }

    var body: some View {
        Section {
            ForEach(GameShortcutGroup.allCases) { group in
                let rows = entries.filter { $0.group == group }
                if !rows.isEmpty {
                    DisclosureGroup(isExpanded: Binding(get: { expanded.contains(group) }, set: { if $0 { expanded.insert(group) } else { expanded.remove(group) } })) {
                        if expanded.contains(group) {
                            ForEach(rows) { row in
                                WindowedShortcutRow(entry: row, tool: tool)
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
            Text("Other apps may have their own shortcuts.")
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
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(verbatim: entry.name)
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
        if let pointer = entry.pointer {
            if pointer.modifiers.isEmpty {
                #if APPSTORE
                Button("Change in System Settings") { NSWorkspace.shared.open(pointer.settings) }.buttonStyle(.link)
                #else
                if let corner = pointer.corner {
                    HotCornerMenu(side: PointerShortcuts.sides[corner], current: pointer.action ?? 0)
                } else {
                    Button("Change in System Settings") { NSWorkspace.shared.open(pointer.settings) }.buttonStyle(.link)
                }
                #endif
            } else {
                KeyCaps(keys: [pointer.modifiers], system: SystemShortcuts.Place(url: pointer.settings, hint: nil))
            }
        } else if let text = entry.text {
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

struct WindowedShortcutRow: View {
    let entry: SystemGameShortcut
    @Bindable var tool: GameModeTool
    @State private var near = false
    @State private var width: CGFloat = 0

    private struct Slot: Equatable {
        let near: Bool
        let width: CGFloat
    }

    var body: some View {
        Group {
            if near {
                SystemShortcutRow(entry: entry, tool: tool)
                    .onGeometryChange(for: CGSize.self) { $0.size } action: { RowHeights.record(entry, $0) }
            } else {
                Color.clear.frame(height: RowHeights.estimate(entry)).accessibilityElement().accessibilityLabel(Text(verbatim: entry.name))
            }
        }
        .settingAnchor(entry.anchor)
        .padding(.vertical, 14)
        .onGeometryChange(for: Slot.self) { proxy in
            let width = proxy.size.width.rounded()
            guard let viewport = proxy.bounds(of: .named(SystemShortcutList.viewport)) else { return Slot(near: false, width: width) }
            return Slot(near: viewport.insetBy(dx: 0, dy: -viewport.height / 2).intersects(CGRect(origin: .zero, size: proxy.size)), width: width)
        } action: { slot in
            RowHeights.sync(slot.width)
            if slot.width != width { width = slot.width }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { if near != slot.near { near = slot.near } }
        }
    }
}

private enum RowHeights {
    private static var width: CGFloat = 0
    private static var typical: CGFloat = 207
    private static var byID: [Int32: CGFloat] = [:]
    private static var byShape: [String: CGFloat] = [:]

    static func estimate(_ entry: SystemGameShortcut) -> CGFloat {
        byID[entry.id] ?? byShape[shape(entry)] ?? typical
    }

    static func record(_ entry: SystemGameShortcut, _ size: CGSize) {
        sync(size.width.rounded())
        byID[entry.id] = size.height
        byShape[shape(entry)] = size.height
        typical += (size.height - typical) / 4
    }

    static func sync(_ width: CGFloat) {
        guard width != self.width else { return }
        self.width = width
        byID = [:]
        byShape = [:]
    }

    private static func shape(_ entry: SystemGameShortcut) -> String {
        "\(entry.detail ?? "")|\(entry.text?.count ?? 0)|\(entry.emergency)|\(entry.assigned && !entry.enabled)|\(entry.pointer != nil)"
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
                if let guide = place.guide {
                    guide.frame(width: 340).padding(12)
                } else {
                    Text(place.hint ?? String(localized: "Change in System Settings"))
                        .fixedSize(horizontal: false, vertical: true).frame(maxWidth: 320).padding(12)
                }
            }
    }
}

#if !APPSTORE
private struct HotCornerMenu: View {
    let side: String
    let current: Int

    private var original: Int? { HotCorners.before[side].flatMap { $0 == current ? nil : $0 } }

    private func name(_ code: Int) -> String {
        guard let action = PointerShortcuts.actions[code] else { return "" }
        return PointerShortcuts.appleNames("desk", action.name) ?? action.name
    }

    var body: some View {
        Menu("Change…") {
            ForEach(PointerShortcuts.actions.keys.sorted(), id: \.self) { code in
                Toggle(name(code), isOn: Binding(get: { code == current }, set: { _ in change { HotCorners.choose(code, side: side) } }))
            }
            if let original {
                Divider()
                Button("Put Back") { change { HotCorners.putBack(side: side) } }
                    .help(name(original))
            }
        }
        .fixedSize()
        .disabled(!DockEdges.journal.isEmpty)
    }

    private func change(_ action: () -> Void) {
        action()
        SettingsWindow.model.refreshShortcuts()
    }
}
#endif
