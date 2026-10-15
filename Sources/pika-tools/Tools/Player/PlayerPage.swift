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
            Section {
                Toggle(isOn: Binding(get: { Self.videos.isOn }, set: { Self.videos.set($0) })) {
                    RowLabel(Text("Open videos in pikapik"), videosSubtitle)
                }
                .settingAnchor(String(localized: "Open videos in pikapik"))
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in Self.videos.refresh() }
            }
            Section("Formats") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 8)], spacing: 8) {
                    ForEach(PlayerFormats.all, id: \.name) { format in
                        Text(verbatim: format.name)
                            .font(.callout.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(.quaternary, in: Capsule())
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

    private var videosSubtitle: Text {
        let names = Self.videos.returnsTo
        return names.isEmpty ? Text("All the formats below") : Text("Turning off returns them to \(names.formatted(.list(type: .and)))")
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
