import AppKit
import SwiftUI

@MainActor
@Observable
final class ArchiveRow: Identifiable {
    let title: String
    let icon: NSImage
    let job = Archive.Job()
    var fraction: Double? = 0

    init(title: String, icon: NSImage) {
        self.title = title
        self.icon = icon
    }
}

@MainActor
@Observable
final class ArchiveBoard {
    var rows: [ArchiveRow] = []
}

@MainActor
final class ArchiveQueue {
    static let shared = ArchiveQueue()

    private enum Work {
        case extract(URL)
        case create(ArchiveCreateRequest)
    }

    private let board = ArchiveBoard()
    private let password = ArchivePasswordPrompt()
    private var waiting: [(work: Work, row: ArchiveRow)] = []
    private var running = false
    private var panel: NSPanel?
    private var results: [URL] = []

    func extract(_ urls: [URL]) {
        for url in urls {
            add(.extract(url), ArchiveRow(title: String(localized: "Extracting “\(url.lastPathComponent)”…"), icon: NSWorkspace.shared.icon(forFile: url.path)))
        }
    }

    func create(_ items: [URL]) {
        Task {
            guard let request = await ArchiveCreatePrompt.ask(for: items) else { return }
            let name = request.name + "." + request.format.fileExtension
            add(.create(request), ArchiveRow(title: String(localized: "Creating “\(name)”…"), icon: NSWorkspace.shared.icon(for: request.format.type)))
        }
    }

    private func add(_ work: Work, _ row: ArchiveRow) {
        board.rows.append(row)
        waiting.append((work, row))
        guard !running else { return }
        running = true
        Task { await drain() }
    }

    private func stop(_ row: ArchiveRow) {
        row.job.cancel()
        guard waiting.contains(where: { $0.row === row }) else { return }
        waiting.removeAll { $0.row === row }
        board.rows.removeAll { $0 === row }
    }

    private func drain() async {
        while !waiting.isEmpty {
            let (work, row) = waiting.removeFirst()
            switch work {
            case .extract(let url): await extract(url, row: row)
            case .create(let request): await create(request, row: row)
            }
            board.rows.removeAll { $0 === row }
        }
        running = false
        panel?.close()
        panel = nil
        let made = results
        results = []
        if !made.isEmpty { NSWorkspace.shared.activateFileViewerSelecting(made) }
    }

    private func extract(_ url: URL, row: ArchiveRow) async {
        let name = url.lastPathComponent
        var secret: String?
        var partial = false
        var huge = false
        while true {
            let (typed, allowPartial, allowHuge) = (secret, partial, huge)
            do {
                let result = try await run(row) { job, progress in
                    try Archive.extract(url, password: typed, allowPartial: allowPartial, allowHuge: allowHuge, job: job, progress: progress)
                }
                password.close()
                results.append(result)
                return
            } catch ArchiveError.needsPassword, ArchiveError.wrongPassword {
                guard let answer = await password.ask(for: url, wrong: typed != nil) else { return }
                secret = answer
            } catch ArchiveError.truncated {
                password.close()
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = String(localized: "“\(name)” didn’t finish downloading")
                alert.informativeText = String(localized: "Only part of the file is here.")
                alert.addButton(withTitle: String(localized: "Extract What’s There"))
                alert.addButton(withTitle: String(localized: "Cancel"))
                guard await ask(alert) == .alertFirstButtonReturn else { return }
                partial = true
            } catch ArchiveError.huge(let expanded, _) {
                password.close()
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = String(localized: "“\(name)” expands to \(Self.size(expanded))")
                alert.informativeText = String(localized: "It could fill up your disk.")
                alert.addButton(withTitle: String(localized: "Extract Anyway"))
                alert.addButton(withTitle: String(localized: "Cancel"))
                guard await ask(alert) == .alertFirstButtonReturn else { return }
                huge = true
            } catch {
                password.close()
                await report(error, name: name, creating: false)
                return
            }
        }
    }

    private func create(_ request: ArchiveCreateRequest, row: ArchiveRow) async {
        do {
            let made = try await run(row) { job, progress in
                try Archive.create(items: request.items, name: request.name, format: request.format, password: request.password, splitBytes: request.split, job: job, progress: progress)
            }
            results += made
        } catch {
            await report(error, name: request.name + "." + request.format.fileExtension, creating: true)
        }
    }

    private func run<T: Sendable>(_ row: ArchiveRow, _ body: @escaping @Sendable (Archive.Job, @escaping @Sendable (Double) -> Void) throws -> T) async throws -> T {
        row.fraction = nil
        let reveal = Task {
            try await Task.sleep(for: .milliseconds(500))
            showPanel()
        }
        defer { reveal.cancel() }
        let job = row.job
        return try await Task.detached(priority: .userInitiated) {
            try body(job) { value in
                Task { @MainActor in row.fraction = max(row.fraction ?? 0, value) }
            }
        }.value
    }

    private func report(_ error: Error, name: String, creating: Bool) async {
        let alert = NSAlert()
        alert.alertStyle = .warning
        switch error as? ArchiveError {
        case .cancelled:
            return
        case .missingPart(let part):
            alert.messageText = String(localized: "Part “\(part)” is missing")
            alert.informativeText = String(localized: "Put all parts in one folder and try again.")
        case .noSpace(let needed, let free):
            alert.messageText = String(localized: "Not enough space")
            alert.informativeText = needed > 0
                ? String(localized: "It needs \(Self.size(needed)), but only \(Self.size(free)) is free.")
                : String(localized: "Free up some space and try again.")
        case .damaged(let extracted, let total, let result):
            results.append(result)
            alert.messageText = String(localized: "“\(name)” is partly damaged")
            alert.informativeText = String(localized: "Files extracted: \(extracted) of \(total)")
        case .unsupported:
            alert.messageText = String(localized: "“\(name)” can’t be opened")
        default:
            NSLog("pikapik archive: %@ failed: %@", name, String(describing: error))
            if creating {
                alert.messageText = String(localized: "Couldn’t create “\(name)”")
                alert.informativeText = String(localized: "Something went wrong. Please try again.")
            } else {
                alert.messageText = String(localized: "Couldn’t extract “\(name)”")
                alert.informativeText = String(localized: "The file may be damaged.")
            }
        }
        _ = await ask(alert)
    }

    private func ask(_ alert: NSAlert) async -> NSApplication.ModalResponse {
        await withCheckedContinuation { continuation in
            RunLoop.main.perform {
                MainActor.assumeIsolated {
                    NSApp.bringForward()
                    continuation.resume(returning: alert.runModal())
                }
            }
        }
    }

    private func showPanel() {
        password.dismissWhileChecking()
        guard panel == nil else { return }
        let controller = NSHostingController(rootView: ArchiveBoardView(board: board) { [weak self] row in self?.stop(row) })
        controller.sizingOptions = [.preferredContentSize]
        let panel = ArchivePanel(controller, activating: false)
        panel.orderFrontRegardless()
        self.panel = panel
    }

    private static func size(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

struct ArchiveBoardView: View {
    let board: ArchiveBoard
    let stop: (ArchiveRow) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(board.rows.prefix(4)) { row in
                ArchiveRowView(row: row) { stop(row) }
            }
            if board.rows.count > 4 {
                Text(verbatim: "+\(board.rows.count - 4)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .archiveChrome(width: 348)
    }
}

private struct ArchiveRowView: View {
    let row: ArchiveRow
    let stop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: row.icon)
                .resizable()
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(row.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let fraction = row.fraction {
                    ProgressView(value: fraction)
                } else {
                    ProgressView()
                        .progressViewStyle(.linear)
                }
            }
            Button(action: stop) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help(Text("Stop"))
            .accessibilityLabel(Text("Stop"))
        }
    }
}
