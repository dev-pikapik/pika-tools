import AppKit
import SwiftUI

final class CompressTool: Tool {
    let id = "compress"
    let icon = "arrow.down.right.and.arrow.up.left"
    var title: String { String(localized: "Smaller Copy and Convert in Finder") }
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
            subtitle: Text("Right-click a photo, video or song"),
            hint: Text("Right-click a photo, video or song"),
            help: Text("Right-click a file in Finder. Make a Smaller Copy shrinks photos, PDFs and videos. Convert To saves pictures, videos and music in another format, like JPEG or MP4. The original stays as it is.")
        ))
    }

    func refresh() { finder.refresh() }
    func load() { finder.load() }
}

enum Compress {
    static func handle(_ url: URL) {
        guard url.host == "compress" || url.host == "convert",
              ToolRegistry.shared.tools.contains(where: { $0 is CompressTool && $0.isActive })
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
                return Converter.targets(for: file).contains(target) && Converter.format(of: file) != target
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
        NSApp.activate()
        alert.runModal()
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
            name = String(localized: "\(base) (smaller)") + "." + file.pathExtension
            output = temporary.appending(path: file.lastPathComponent)
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
