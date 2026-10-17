import AppKit
import SwiftUI
import UniformTypeIdentifiers

final class ArchiveTool: Tool {
    let id = "archive"
    let icon = "doc.zipper"
    var title: String { String(localized: "Archives in Finder") }
    let tab = SettingsTab.finder
    private let finder = FinderExtension(bundle: "Archive", key: "archive", preview: true)
    static let formats: [(name: String, types: [UTType])] = [("ZIP", [.zip]), ("7Z", [UTType("org.7-zip.7-zip-archive")].compactMap { $0 })]
    private let defaultApp = DefaultApps(
        types: ArchiveTool.formats.flatMap(\.types),
        target: Bundle.main.bundleURL,
        previousKey: "archive-previous-apps",
        fallback: "com.apple.archiveutility"
    )

    var isActive: Bool { finder.isActive }
    var needs: [Permission] { finder.needsSettings ? [.finder] : [] }

    var isEnabled: Bool {
        get { finder.isEnabled }
        set { finder.isEnabled = newValue }
    }

    var settingsView: AnyView {
        AnyView(ArchiveSettings(tool: self, finder: finder, defaultApp: defaultApp))
    }

    func refresh() {
        finder.refresh()
        defaultApp.refresh()
    }

    func load() { finder.load() }
}

private struct ArchiveSettings: View {
    let tool: ArchiveTool
    let finder: FinderExtension
    @Bindable var defaultApp: DefaultApps
    @Environment(\.inSettings) private var inSettings

    private var help: Text {
        #if APPSTORE
        Text("Right-click an archive in Finder and choose Extract. Right-click any other file or folder and choose Create Archive… to make a ZIP, 7Z or TAR. Only ZIP can have a password.")
        #else
        Text("Right-click an archive in Finder and choose Extract. Right-click any other file or folder and choose Create Archive… to make a ZIP, 7Z or TAR. ZIP and 7Z can have a password.")
        #endif
    }

    var body: some View {
        FinderExtensionSettings(
            tool: tool,
            finder: finder,
            subtitle: Text("Right-click › Extract or Create Archive"),
            hint: Text("Right-click a file or folder"),
            help: help
        ) { AnyView(ArchiveArt(on: $0)) }
        #if !APPSTORE
        if inSettings {
            DefaultAppToggle(title: String(localized: "Open archives in pikapik"), formats: ArchiveTool.formats, apps: defaultApp)
        }
        #endif
    }
}

enum ArchiveHandoff {
    static func handle(_ url: URL) {
        guard url.host == "archive",
              ToolRegistry.shared.tools.contains(where: { $0 is ArchiveTool && $0.isActive })
        else { return }
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let files = query
            .compactMap { $0.name == "path" ? $0.value : nil }
            .filter { $0.hasPrefix("/") }
            .map { URL(fileURLWithPath: $0) }
        switch query.first(where: { $0.name == "action" })?.value {
        case "extract": extract(files)
        case "create": create(files)
        default: break
        }
    }

    static func open(_ urls: [URL]) {
        #if APPSTORE
        guard ToolRegistry.shared.tools.contains(where: { $0 is ArchiveTool }) else { return }
        #endif
        queue(urls.filter(\.isFileURL))
    }

    private static func extract(_ files: [URL]) {
        queue(files.filter(Archive.isArchive))
    }

    private static func queue(_ files: [URL]) {
        let archives = Archive.distinct(files.filter(isFile))
        guard !archives.isEmpty, FolderAccess.ensure(archives.map { $0.deletingLastPathComponent() }) else { return }
        Task { @MainActor in ArchiveQueue.shared.extract(archives) }
    }

    private static func create(_ files: [URL]) {
        let items = files.filter { FileManager.default.fileExists(atPath: $0.path) }
        guard !items.isEmpty, FolderAccess.ensure(items.map { $0.deletingLastPathComponent() }) else { return }
        Task { @MainActor in ArchiveQueue.shared.create(items) }
    }

    private static func isFile(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true
    }
}

struct ArchiveArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let pass = [1.2, 1.1, 0.15, 0.5, 0.7, 0.25, 0.15, 0.4, 1.5]
    private static let click = CGPoint(x: 160, y: 62)

    var body: some View {
        IllustrationRow(loop: Self.pass + Self.pass) { tick in
            let step = reduceMotion ? Self.pass.count - 1 : tick % (2 * Self.pass.count)
            let opening = step < Self.pass.count
            let phase = step % Self.pass.count
            let menu = (3...6).contains(phase)
            let picked = (2...7).contains(phase)
            let spread = on && (opening ? phase >= 7 : phase < 7)
            let row = CGPoint(x: Self.click.x + 18, y: Self.click.y + 26)
            Stage {
                ArtWindow(size: CGSize(width: 220, height: 100)) {
                    ZStack {
                        ArtArchive(selected: picked)
                            .opacity(spread ? 0 : 1)
                            .scaleEffect(spread ? 0.6 : 1)
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { _ in ArtFile(selected: picked) }
                        }
                        .opacity(spread ? 1 : 0)
                        .scaleEffect(spread ? 1 : 0.6)
                    }
                    .offset(y: -6)
                }
                .position(x: 150, y: 64)
                if menu {
                    ArtMenu(width: 132) {
                        ArtMenuRow(width: 34)
                        if on {
                            ArtMenuRow(title: opening ? Text("Extract") : Text("Create Archive…"), active: phase >= 5)
                        } else {
                            ArtMenuRow(width: 64)
                        }
                        ArtMenuRow(width: 48)
                    }
                    .position(x: Self.click.x + 66, y: Self.click.y + 26)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if (2...3).contains(phase) { ArtRipple().position(Self.click) }
                if (6...7).contains(phase) { ArtRipple().position(row) }
                ArtCursor(pressed: phase == 2 || phase == 6)
                    .cursor(at: phase == 0 ? CGPoint(x: 240, y: 104) : phase < 4 ? Self.click : row)
                    .opacity(phase == 8 ? 0 : 1)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }
}

private struct ArtArchive: View {
    var selected = false

    var body: some View {
        Image(systemName: "doc.zipper")
            .font(.system(size: 30, weight: .light))
            .foregroundStyle(selected ? Color.accentColor : Color.secondary)
            .padding(8)
            .background(Color.accentColor.opacity(selected ? 0.2 : 0), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
