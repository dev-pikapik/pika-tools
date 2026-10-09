import AppKit
import SwiftUI

final class CompressTool: Tool {
    let id = "compress"
    let icon = "arrow.down.right.and.arrow.up.left"
    var title: String { String(localized: "Smaller Copy in Finder") }
    let tab = SettingsTab.finder
    private let finder = FinderExtension(bundle: "Compress", key: "compress")

    var isActive: Bool { finder.isActive }

    var isEnabled: Bool {
        get { finder.isEnabled }
        set { finder.isEnabled = newValue }
    }

    var settingsView: AnyView {
        AnyView(FinderExtensionSettings(
            tool: self,
            finder: finder,
            subtitle: Text("Right-click a file › Make a Smaller Copy"),
            hint: Text("Right-click a photo, video or song"),
            help: Text("Right-click a file in Finder and choose Make a Smaller Copy. Works with photos, GIFs, PDFs, videos and uncompressed sound like WAV or AIFF, which becomes M4A. The original stays as it is. If the file can’t get any smaller, no copy is made.")
        ) { AnyView(CompressArt(on: $0)) })
    }

    func refresh() { finder.refresh() }
    func load() { finder.load() }
}

struct CompressArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.3, 1.15, 0.15, 0.5, 0.75, 0.25, 0.15, 0.35, 2.0]
    private static let click = CGPoint(x: 112, y: 58)
    private static let sizes = [4_800_000, 1_200_000].map { ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file) }

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 8 : tick % Self.durations.count
            let menu = (3...6).contains(step)
            let picked = (2...7).contains(step)
            let copied = on && step == 8
            let row = CGPoint(x: Self.click.x + 18, y: Self.click.y + 26)
            Stage {
                ArtWindow(size: CGSize(width: 220, height: 100)) {
                    ZStack {
                        ArtPhotoFile(width: 40, label: Self.sizes[0], selected: picked, color: picked ? .primary : .secondary)
                            .position(x: 72, y: 42)
                        ArtPhotoFile(width: 28, label: Self.sizes[1], color: .accentColor)
                            .opacity(copied ? 1 : 0)
                            .scaleEffect(copied ? 1 : 0.6)
                            .position(x: 148, y: 42)
                    }
                }
                .position(x: 150, y: 64)
                if menu {
                    ArtMenu(width: 140) {
                        ArtMenuRow(width: 34)
                        if on { ArtMenuRow(title: Text("Make a Smaller Copy"), active: step >= 5) } else { ArtMenuRow(width: 64) }
                        ArtMenuRow(width: 48)
                    }
                    .position(x: Self.click.x + 70, y: Self.click.y + 26)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if (2...3).contains(step) { ArtRipple().position(Self.click) }
                if (6...7).contains(step) { ArtRipple().position(row) }
                ArtCursor(pressed: step == 2 || step == 6)
                    .cursor(at: step == 0 ? CGPoint(x: 236, y: 98) : step < 4 ? Self.click : row)
                    .opacity(step == 8 ? 0 : 1)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }
}

struct ArtPhotoFile: View {
    let width: CGFloat
    let label: String
    var selected = false
    var color: Color = .secondary

    var body: some View {
        VStack(spacing: 3) {
            ArtPhoto(width: width)
            Text(verbatim: label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(color)
                .lineLimit(1)
                .fixedSize()
        }
        .padding(4)
        .background(Color.accentColor.opacity(selected ? 0.2 : 0), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        .frame(height: 56, alignment: .bottom)
    }
}

struct ArtPhoto: View {
    let width: CGFloat

    var body: some View {
        ArtLandscape(size: CGSize(width: width, height: width * 0.75))
            .clipShape(RoundedRectangle(cornerRadius: 1.5, style: .continuous))
            .padding(width * 0.06)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 2.5, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 1.5, y: 0.5)
    }
}

enum Compress {
    static func handle(_ url: URL) {
        guard url.host == "compress" || url.host == "convert",
              ToolRegistry.shared.tools.contains(where: { $0.id == url.host && $0.isActive })
        else { return }
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let target = url.host == "convert" ? query.first(where: { $0.name == "to" })?.value : nil
        guard url.host == "compress" || target != nil else { return }
        let jobs = query
            .compactMap { $0.name == "path" ? $0.value : nil }
            .filter { $0.hasPrefix("/") }
            .map { URL(fileURLWithPath: $0) }
            .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
            .filter { file in
                guard let target else { return Compressor.canCompress(file) }
                return ConvertFormats.targets(for: file).contains(target) && ConvertFormats.format(of: file) != target
            }
            .map { CompressJob(file: $0, target: target) }
        guard !jobs.isEmpty else { return }
        Task { @MainActor in CompressQueue.shared.add(jobs) }
    }
}

private struct CompressJob: Equatable, Sendable {
    let file: URL
    let target: String?

    var message: String {
        let name = file.lastPathComponent
        guard let target else { return String(localized: "Making “\(name)” smaller…") }
        return String(localized: "Converting “\(name)” to \(target.uppercased())…")
    }

    var failure: String {
        target == nil ? String(localized: "Couldn’t make a smaller copy") : String(localized: "Couldn’t convert")
    }
}

@MainActor
private final class CompressQueue {
    static let shared = CompressQueue()

    private let progress = CompressProgress()
    private var waiting: [CompressJob] = []
    private var job: Task<Void, Never>?
    private var work: Task<URL?, Error>?
    private var panel: NSPanel?
    private var made: [URL] = []
    private var compact: [String] = []
    private var failed: [String] = []
    private var failure = ""

    func add(_ jobs: [CompressJob]) {
        waiting += jobs.filter { !waiting.contains($0) }
        guard job == nil else { return }
        job = Task { await run() }
    }

    private func run() async {
        let reveal = Task {
            try await Task.sleep(for: .seconds(1))
            showPanel()
        }
        while !waiting.isEmpty {
            let job = waiting.removeFirst()
            progress.message = job.message
            progress.fraction = nil
            let progress = progress
            let work = Task.detached(priority: .userInitiated) {
                try await Self.perform(job) { value in
                    Task { @MainActor in progress.fraction = value }
                }
            }
            self.work = work
            do {
                if let copy = try await work.value {
                    made.append(copy)
                } else {
                    compact.append(job.file.lastPathComponent)
                }
            } catch is CancellationError {
                waiting.removeAll()
            } catch {
                if failed.isEmpty { failure = job.failure }
                failed.append("\(job.file.lastPathComponent): \(error.localizedDescription)")
            }
        }
        reveal.cancel()
        panel?.close()
        panel = nil
        work = nil
        job = nil
        finish()
    }

    private func cancel() {
        waiting.removeAll()
        work?.cancel()
    }

    private func finish() {
        if !made.isEmpty { NSWorkspace.shared.activateFileViewerSelecting(made) }
        defer { (made, compact, failed) = ([], [], []) }
        guard !failed.isEmpty || !compact.isEmpty else { return }
        let alert = NSAlert()
        if failed.isEmpty {
            alert.messageText = String(localized: "Already compact")
            alert.informativeText = ([String(localized: "A smaller copy wouldn’t save space, so none was made:")] + compact).joined(separator: "\n")
        } else {
            alert.alertStyle = .warning
            alert.messageText = failure
            var lines = failed
            if !compact.isEmpty { lines += ["", String(localized: "Already compact, no copy needed:")] + compact }
            alert.informativeText = lines.joined(separator: "\n")
        }
        RunLoop.main.perform {
            MainActor.assumeIsolated {
                NSApp.activate()
                alert.runModal()
            }
        }
    }

    private func showPanel() {
        let panel = NSPanel(contentRect: .zero, styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = NSHostingView(rootView: CompressProgressView(progress: progress) { [weak self] in self?.cancel() })
        panel.setContentSize(panel.contentView?.fittingSize ?? .zero)
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.center()
        panel.orderFrontRegardless()
        self.panel = panel
    }

    nonisolated private static func perform(_ job: CompressJob, progress: @escaping @Sendable (Double) -> Void) async throws -> URL? {
        let manager = FileManager.default
        let file = job.file
        let folder = file.deletingLastPathComponent()
        let base = file.deletingPathExtension().lastPathComponent
        let temporary = try manager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: folder, create: true)
        defer { try? manager.removeItem(at: temporary) }
        let name: String
        let output: URL
        if let target = job.target {
            name = base + "." + Converter.fileExtension(for: target)
            output = temporary.appending(path: name)
            try await Converter.convert(file, to: target, output: output, progress: progress)
            try Task.checkCancellation()
        } else {
            name = String(localized: "\(base) (smaller)") + "." + Compressor.fileExtension(for: file)
            output = temporary.appending(path: name)
            try await Compressor.compress(file, to: output, progress: progress)
            try Task.checkCancellation()
            let before = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            let after = try output.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? before
            guard Double(after) <= Double(before) * 0.95 else { return nil }
        }
        let copy = NewFile.uniqueURL(for: name, in: folder)
        try manager.moveItem(at: output, to: copy)
        return copy
    }
}

@MainActor
@Observable
private final class CompressProgress {
    var message = ""
    var fraction: Double?
}

private struct CompressProgressView: View {
    let progress: CompressProgress
    let cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(progress.message)
                .lineLimit(1)
                .truncationMode(.middle)
            if let fraction = progress.fraction {
                ProgressView(value: fraction)
            } else {
                ProgressView()
                    .progressViewStyle(.linear)
            }
            HStack {
                Spacer()
                Button("Cancel", action: cancel)
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
