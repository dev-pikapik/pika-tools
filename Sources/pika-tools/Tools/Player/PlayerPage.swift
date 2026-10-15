import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PlayerPage: View {
    static let helper = Bundle.main.bundleURL.appending(path: "Contents/Helpers/pikapik Player.app")
    private static let license = Bundle.main.url(forResource: "FFmpeg License", withExtension: "txt")
    private static let source = URL(string: "https://github.com/dev-pikapik/pika-tools/releases/latest")!
    private static let videos = DefaultApps(types: PlayerFormats.types, target: helper, previousKey: "player-video-previous-apps")

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
            Section("Formats") {
                VStack(spacing: 6) {
                    Button(action: { Self.videos.set(!Self.videos.isOn) }) {
                        (Self.videos.isOn ? Text("Restore Previous Apps") : Text("Open All in pikapik")).frame(minWidth: 140)
                    }
                    .controlSize(.large)
                    .settingAnchor(String(localized: "Open All in pikapik"))
                    (Self.videos.isOn ? Text("macOS will ask about each format. Click “Use” each time.") : Text("macOS will ask about each format. Click “Use pikapik Player”."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .disabled(Self.videos.busy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in Self.videos.refresh() }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
                    ForEach(PlayerFormats.all, id: \.name) { format in
                        let types = PlayerFormats.types(of: format.extensions)
                        let isOn = Self.videos.isOn(types)
                        Button(action: { Self.videos.set(!isOn, for: types) }) {
                            HStack(spacing: 5) {
                                Text(verbatim: format.name)
                                    .font(.callout.weight(.medium))
                                if let app = Self.videos.app(of: types) {
                                    Image(nsImage: NSWorkspace.shared.icon(forFile: app.path)).resizable().frame(width: 16, height: 16)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .background(isOn ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.quaternary), in: Capsule())
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(Self.videos.busy)
                        .help(format.extensions.map { "." + $0 }.joined(separator: " "))
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                if let license = Self.license {
                    row(String(localized: "FFmpeg and dav1d Licenses"), symbol: "doc.text.fill", color: .green) { NSWorkspace.shared.open(license) }
                }
                row(String(localized: "Source Code"), symbol: "chevron.left.forwardslash.chevron.right", color: .gray) { NSWorkspace.shared.open(Self.source) }
            }
        }
        .formStyle(.grouped)
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
