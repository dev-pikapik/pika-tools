import AppKit
import SwiftUI

@available(macOS 14.2, *)
@Observable
final class AppVolumeTool: Tool {
    static let shared = AppVolumeTool()

    let id = "app-volume"
    let icon = "speaker.wave.2"
    var title: String { String(localized: "App Volume") }
    var tab: SettingsTab { .sound }
    var needs: [Permission] { [.systemAudio] }
    var isActive: Bool { isEnabled && Permissions.shared.systemAudio }
    var isDefault: Bool { !isEnabled && memory.keys.isEmpty }
    private(set) var memory: AppVolumeMemory
    private(set) var remembered: [AppVolumeOwner] = []
    var levels: [String: Double] { memory.levels }
    var muted: Set<String> { memory.muted }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        memory = AppVolumeMemory()
        remembered = Self.owners(memory)
    }

    var settingsView: AnyView {
        AnyView(AppVolumeSettings(tool: self))
    }

    func level(_ key: String) -> Double { memory.level(key) }

    func setLevel(_ level: Double, for owner: AppVolumeOwner) {
        memory.setLevel(level, for: owner)
        commit()
    }

    func toggleMute(_ owner: AppVolumeOwner) {
        memory.toggleMute(owner)
        commit()
    }

    func forget(_ key: String) {
        memory.forget(key)
        commit()
    }

    func toggle(_ key: String) {
        if memory.keys.contains(key) {
            forget(key)
        } else if let url = Self.url(for: key) {
            add(url)
        }
    }

    func add(_ url: URL) {
        guard AppShelf.isApp(url) else { return }
        memory.remember(AppVolumeOwner(key: Bundle(url: url)?.bundleIdentifier ?? url.path, name: Self.name(of: url), bundlePath: url.path))
        commit()
    }

    func setEnabled(_ on: Bool) {
        if on, !isEnabled {
            let defaults = UserDefaults.standard
            let hidden = (defaults.string(forKey: "quick-hidden") ?? MenuView.defaultHidden).split(separator: ",")
            defaults.set(hidden.filter { $0 != id }.joined(separator: ","), forKey: "quick-hidden")
        }
        isEnabled = on
        if on { Permissions.shared.checkSystemAudio() }
    }

    func refresh() {
        AppVolumeEngine.shared.configure(active: isActive && MainCopy.canAct, levels: levels, muted: muted)
    }

    func reset() {
        memory.keys.forEach { memory.forget($0) }
        commit()
        isEnabled = false
    }

    func load() {
        memory = AppVolumeMemory()
        remembered = Self.owners(memory)
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    private func commit() {
        memory.save()
        if memory.keys != Set(remembered.map(\.key)) { remembered = Self.owners(memory) }
        refresh()
    }

    private static func owners(_ memory: AppVolumeMemory) -> [AppVolumeOwner] {
        memory.keys.map { key in
            let url = url(for: key)
            return AppVolumeOwner(key: key, name: memory.names[key] ?? url.map(name) ?? key, bundlePath: url?.path)
        }
    }

    private static func url(for key: String) -> URL? {
        if key.hasPrefix("/") { return FileManager.default.fileExists(atPath: key) ? URL(fileURLWithPath: key) : nil }
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: key)
    }

    private static func name(of url: URL) -> String {
        let name = FileManager.default.displayName(atPath: url.path)
        return name.hasSuffix(".app") ? String(name.dropLast(4)) : name
    }
}

@MainActor @Observable
final class AppVolumeModel {
    static let shared = AppVolumeModel()

    private(set) var rows: [AppVolumeRow] = []

    func show(_ rows: [AppVolumeRow]) {
        if rows != self.rows { self.rows = rows }
    }
}

@available(macOS 14.2, *)
private struct AppVolumeSettings: View {
    let tool: AppVolumeTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { AppVolumeArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Works with any app that plays sound"),
            help: Text("Lower or mute any app without touching the others."),
            isOn: Binding(get: { tool.isEnabled }, set: { tool.setEnabled($0) })
        )
        if tool.isActive { AppVolumeList(tool: tool) }
    }
}

@available(macOS 14.2, *)
private struct AppVolumeList: View {
    let tool: AppVolumeTool
    @Environment(\.inSettings) private var inSettings
    @State private var adding = false

    var body: some View {
        let rows = inSettings ? AppVolumeMath.rows(live: AppVolumeModel.shared.rows, remembered: tool.remembered) : AppVolumeModel.shared.rows
        VStack(spacing: inSettings ? 8 : 2) {
            ForEach(rows, id: \.owner.key) { row in
                AppVolumeRowView(tool: tool, row: row)
                    .transition(.opacity)
            }
            if rows.isEmpty || inSettings {
                HStack {
                    if rows.isEmpty {
                        Text("No apps are playing sound")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 5)
                            .transition(.opacity)
                    }
                    if inSettings {
                        Spacer(minLength: 8)
                        if adding {
                            Button("Done") { adding = false }
                        } else {
                            Button("Add App…", systemImage: "plus") { adding = true }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if inSettings && adding {
                AppShelf(
                    hint: Text("Here’s what’s in your Dock and open now. Click an app to add it, or drag one here from Finder"),
                    added: tool.remembered.map(\.key),
                    suggest: Self.suggestions,
                    toggle: tool.toggle,
                    other: { AppExclusions.choose().forEach(tool.add) }
                )
            }
        }
        .padding(.leading, inSettings ? 0 : 46)
        .padding(.trailing, inSettings ? 0 : 8)
        .animation(.snappy, value: rows)
        .appDropZone(tool.title, isEnabled: inSettings, add: tool.add)
    }

    private static func suggestions() -> [String] {
        var seen = Set<String>()
        return (AppShelf.dock().compactMap { Bundle(url: $0)?.bundleIdentifier } + AppShelf.running.compactMap(\.bundleIdentifier))
            .filter { !BackgroundTasks.isOwn($0) && seen.insert($0).inserted }
    }
}

@available(macOS 14.2, *)
private struct AppVolumeRowView: View {
    let tool: AppVolumeTool
    let row: AppVolumeRow
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        let key = row.owner.key
        let muted = tool.muted.contains(key)
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                AppVolumeIcon(path: row.owner.bundlePath)
                Text(verbatim: row.title)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(row.playing ? 1 : 0.55)
            Slider(value: Binding(get: { tool.level(key) }, set: { tool.setLevel($0, for: row.owner) }), in: 0...1)
                .controlSize(.small)
                .frame(width: inSettings ? 140 : 96)
                .disabled(muted)
                .accessibilityLabel(Text("Volume of \(row.title)"))
            Button { tool.toggleMute(row.owner) } label: {
                Image(systemName: muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundStyle(muted ? Color.accentColor : Color.secondary)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(muted ? Text("Unmute") : Text("Mute"))
            .accessibilityLabel(muted ? Text("Unmute") : Text("Mute"))
            if inSettings {
                let kept = tool.memory.keys.contains(key)
                Button { tool.forget(key) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Forget This App")
                .accessibilityLabel(Text("Forget This App"))
                .opacity(kept ? 1 : 0)
                .disabled(!kept)
                .accessibilityHidden(!kept)
            }
        }
    }
}

private struct AppVolumeIcon: View {
    let path: String?

    var body: some View {
        Group {
            if let path {
                Image(nsImage: NSWorkspace.shared.icon(forFile: path)).resizable()
            } else {
                Image(systemName: "waveform.circle.fill").resizable().foregroundStyle(.secondary)
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}

struct AppVolumeArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.2, 1.2, 1.2, 1.2]
    private static let levels: [[CGFloat]] = [[0.9, 0.55, 0.25], [0.9, 0.3, 0.65], [0.6, 0.3, 0.85], [0.6, 0.75, 0.4]]
    private static let tiles: [(symbol: String, color: Color)] = [
        ("music.note", Art.red), ("play.rectangle.fill", .accentColor), ("phone.fill", Art.green),
    ]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 0 : tick % Self.levels.count
            let shown: [CGFloat] = on ? Self.levels[step] : [1, 1, 1]
            Stage {
                HStack(spacing: 24) {
                    ForEach(0..<3, id: \.self) { index in
                        HStack(spacing: 10) {
                            tile(Self.tiles[index])
                            bar(shown[index], color: on ? Self.tiles[index].color : Color.secondary.opacity(0.5))
                        }
                    }
                }
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.6), value: shown)
        }
    }

    private func tile(_ tile: (symbol: String, color: Color)) -> some View {
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
        return shape
            .fill(LinearGradient(colors: [tile.color, tile.color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            .overlay(shape.hairline(Color.white.opacity(0.25)))
            .overlay {
                Image(systemName: tile.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 40, height: 40)
            .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
            .saturation(on ? 1 : 0.35)
    }

    private func bar(_ level: CGFloat, color: Color) -> some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .frame(width: 8, height: 64)
            .overlay(alignment: .bottom) {
                Capsule().fill(color).frame(width: 8, height: 64 * level)
            }
    }
}
