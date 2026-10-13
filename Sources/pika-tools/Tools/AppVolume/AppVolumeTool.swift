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
    var isDefault: Bool { !isEnabled && levels.isEmpty && muted.isEmpty }
    private(set) var levels: [String: Double]
    private(set) var muted: Set<String>

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        levels = Self.storedLevels()
        muted = Self.storedMuted()
    }

    var settingsView: AnyView {
        AnyView(AppVolumeSettings(tool: self))
    }

    func level(_ key: String) -> Double { levels[key] ?? 1 }

    func setLevel(_ level: Double, for key: String) {
        levels[key] = AppVolumeMath.level(slider: level)
        persist()
        refresh()
    }

    func toggleMute(_ key: String) {
        if muted.contains(key) { muted.remove(key) } else { muted.insert(key) }
        persist()
        refresh()
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
        AppVolumeEngine.shared.configure(active: isActive, levels: levels, muted: muted)
    }

    func reset() {
        levels = [:]
        muted = []
        persist()
        isEnabled = false
    }

    func load() {
        levels = Self.storedLevels()
        muted = Self.storedMuted()
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    private func persist() {
        UserDefaults.standard.set(levels, forKey: "app-volume-levels")
        UserDefaults.standard.set(muted.sorted(), forKey: "app-volume-muted")
    }

    private static func storedLevels() -> [String: Double] {
        (UserDefaults.standard.dictionary(forKey: "app-volume-levels") ?? [:])
            .compactMapValues { ($0 as? NSNumber).map { min(max($0.doubleValue, 0), 1) } }
            .filter { $0.value < 1 }
    }

    private static func storedMuted() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: "app-volume-muted") ?? [])
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

    var body: some View {
        let rows = AppVolumeModel.shared.rows
        VStack(spacing: inSettings ? 8 : 2) {
            if rows.isEmpty {
                Text("No apps are playing sound")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
                    .transition(.opacity)
            }
            ForEach(rows, id: \.owner.key) { row in
                AppVolumeRowView(tool: tool, row: row)
                    .transition(.opacity)
            }
        }
        .padding(.leading, inSettings ? 0 : 46)
        .padding(.trailing, inSettings ? 0 : 8)
        .animation(.snappy, value: rows)
    }
}

@available(macOS 14.2, *)
private struct AppVolumeRowView: View {
    let tool: AppVolumeTool
    let row: AppVolumeRow

    var body: some View {
        let key = row.owner.key
        let muted = tool.muted.contains(key)
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                AppVolumeIcon(path: row.owner.bundlePath)
                Text(verbatim: row.owner.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(row.playing ? 1 : 0.55)
            Slider(value: Binding(get: { tool.level(key) }, set: { tool.setLevel($0, for: key) }), in: 0...1)
                .controlSize(.small)
                .frame(width: 96)
                .disabled(muted)
                .accessibilityLabel(Text("Volume of \(row.owner.name)"))
            Button { tool.toggleMute(key) } label: {
                Image(systemName: muted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .foregroundStyle(muted ? Color.accentColor : Color.secondary)
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(muted ? Text("Unmute") : Text("Mute"))
            .accessibilityLabel(muted ? Text("Unmute") : Text("Mute"))
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
