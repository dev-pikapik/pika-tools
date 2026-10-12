import Foundation

final class TrashWatcher {
    private let folder: URL
    private let found: ([URL]) -> Void
    private var source: DispatchSourceFileSystemObject?
    private var pending: DispatchWorkItem?
    private var seen: Set<String> = []

    init?(folder: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash"), found: @escaping ([URL]) -> Void) {
        self.folder = folder
        self.found = found
        let descriptor = open(folder.path, O_EVTONLY)
        guard descriptor >= 0 else { return nil }
        guard let known = apps() else {
            close(descriptor)
            return nil
        }
        seen = known
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: [.write, .rename, .delete], queue: .main)
        source.setEventHandler { [weak self] in
            self?.pending?.cancel()
            let work = DispatchWorkItem { self?.check() }
            self?.pending = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
        }
        source.setCancelHandler { close(descriptor) }
        source.resume()
        self.source = source
    }

    func stop() {
        pending?.cancel()
        pending = nil
        source?.cancel()
        source = nil
    }

    private func apps() -> Set<String>? {
        (try? FileManager.default.contentsOfDirectory(atPath: folder.path)).map { Set($0.filter { $0.hasSuffix(".app") }) }
    }

    private func check() {
        guard let now = apps() else { return }
        let fresh = now.subtracting(seen)
        seen = now
        if !fresh.isEmpty { found(fresh.sorted().map { folder.appendingPathComponent($0) }) }
    }
}
