import AppKit

enum FolderAccess {
    private static let key = "folderBookmarks"
    private static let limit = 100
    private static var started = Set<String>()

    static func isFolder(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }

    static func files(in folder: URL) -> [URL]? {
        if let files = read(folder) { return files }
        restore(folder)
        return read(folder)
    }

    static func remember(_ folder: URL) {
        guard let data = try? folder.bookmarkData(options: .withSecurityScope) else { return }
        prune()
        var saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Data] ?? [:]
        saved[folder.standardizedFileURL.path] = data
        while saved.count > limit, let extra = saved.keys.first(where: { $0 != folder.standardizedFileURL.path }) { saved[extra] = nil }
        UserDefaults.standard.set(saved, forKey: key)
    }

    /// Drops the saved folders that are gone or no longer open, so deleted folders leave no dead entries behind.
    static func prune() {
        let saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Data] ?? [:]
        let kept = saved.filter { path, data in
            if offline(path) { return true }
            var stale = false
            guard let url = try? URL(resolvingBookmarkData: data, options: [.withSecurityScope, .withoutUI, .withoutMounting], relativeTo: nil, bookmarkDataIsStale: &stale) else { return false }
            let opened = url.startAccessingSecurityScopedResource()
            defer { if opened { url.stopAccessingSecurityScopedResource() } }
            return isFolder(url) && !url.path.contains("/.Trash")
        }
        if kept.count != saved.count { UserDefaults.standard.set(kept, forKey: key) }
    }

    static func ask(_ folder: URL, in window: NSWindow, message: String = String(localized: "To play the next file, allow access to this folder."), _ done: @escaping (Bool) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.directoryURL = folder
        panel.prompt = String(localized: "Allow")
        panel.message = message
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let chosen = panel.url, PlaylistFolders.covers(chosen, folder) else { return done(false) }
            remember(chosen)
            done(true)
        }
    }

    /// A disk that is not plugged in right now keeps its entries: they work again when it comes back.
    private static func offline(_ path: String) -> Bool {
        let parts = path.split(separator: "/")
        return parts.count > 1 && parts[0] == "Volumes" && !FileManager.default.fileExists(atPath: "/Volumes/" + parts[1])
    }

    private static func read(_ folder: URL) -> [URL]? {
        try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }

    private static func restore(_ folder: URL) {
        let saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Data] ?? [:]
        for (path, data) in saved where PlaylistFolders.covers(URL(fileURLWithPath: path), folder) {
            var stale = false
            guard let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale) else { continue }
            if started.insert(path).inserted { _ = url.startAccessingSecurityScopedResource() }
            if stale { remember(url) }
            return
        }
    }
}
