import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PlayerPage: View {
    static let helper = Bundle.main.bundleURL.appending(path: "Contents/Helpers/pikapik Player.app")
    private static let license = Bundle.main.url(forResource: "FFmpeg License", withExtension: "txt")
    private static let source = URL(string: "https://github.com/dev-pikapik/pika-tools/releases/latest")!
    private static let videos = DefaultApps(types: PlayerFormats.types, target: helper, previousKey: "player-video-previous-apps")
    private static let pictures = DefaultApps(types: ImageFormats.types, target: helper, previousKey: "player-image-previous-apps", fallback: ImageFormats.previewApp)

    var body: some View {
        Form {
            SettingsHeader(tab: .player, text: String(localized: "MKV, AVI, WMV and other videos in their own window"))
            Section {
                Button(action: open) { Text("Open Video…").frame(minWidth: 140) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .settingAnchor(String(localized: "Open Video…"))
            }
            Section("Formats") { formats(Self.videos, PlayerFormats.all, anchor: String(localized: "Open All in pikapik")) }
            Section("Pictures") { formats(Self.pictures, ImageFormats.all, anchor: String(localized: "Pictures")) }
            Section {
                if let license = Self.license {
                    row(String(localized: "FFmpeg and dav1d Licenses"), symbol: "doc.text.fill", color: .green) { NSWorkspace.shared.open(license) }
                }
                row(String(localized: "Source Code"), symbol: "chevron.left.forwardslash.chevron.right", color: .gray) { NSWorkspace.shared.open(Self.source) }
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private func formats(_ apps: DefaultApps, _ list: [(name: String, extensions: [String])], anchor: String) -> some View {
        VStack(spacing: 6) {
            Button(action: { if MainCopy.canAct { apps.set(!apps.isOn) } }) {
                (apps.isOn ? Text("Restore Previous Apps") : Text("Open All in pikapik")).frame(minWidth: 140)
            }
            .controlSize(.large)
            .settingAnchor(anchor)
            (apps.isOn ? Text("macOS will ask about each format. Click “Use” each time.") : Text("macOS will ask about each format. Click “Use pikapik Player”."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .disabled(apps.busy)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in apps.refresh() }
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ForEach(list, id: \.name) { format in
                let types = PlayerFormats.types(of: format.extensions)
                let isOn = apps.isOn(types)
                Button(action: { if MainCopy.canAct { apps.set(!isOn, for: types) } }) {
                    HStack(spacing: 5) {
                        Text(verbatim: format.name)
                            .font(.callout.weight(.medium))
                        if let app = apps.app(of: types) {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: app.path)).resizable().frame(width: 16, height: 16)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(isOn ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.quaternary), in: Capsule())
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(apps.busy)
                .help(format.extensions.map { "." + $0 }.joined(separator: " "))
            }
        }
        .padding(.vertical, 4)
    }

    private func row(_ title: String, symbol: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.secondary)
            } label: {
                HStack(spacing: 10) {
                    SectionIcon(symbol: symbol, color: color, size: SettingsTab.iconSize)
                    Text(verbatim: title)
                        .foregroundStyle(.primary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingAnchor(title)
    }

    private func open() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = PlayerFormats.extensions.compactMap { UTType(filenameExtension: $0) }
        guard panel.runModal() == .OK else { return }
        NSWorkspace.shared.open(panel.urls, withApplicationAt: Self.helper, configuration: NSWorkspace.OpenConfiguration())
    }
}
