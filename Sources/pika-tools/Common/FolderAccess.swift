import AppKit

enum FolderAccess {
    #if APPSTORE
    private static let key = "folder-access"
    private static var open: [URL] = []

    static func ensure(_ folders: [URL]) -> Bool {
        folders.allSatisfy { folder in
            let folder = folder.resolvingSymlinksInPath()
            return open.contains { covers($0.path, folder.path) && FileManager.default.isWritableFile(atPath: folder.path) }
                || restore(folder) || ask(folder)
        }
    }

    private static func covers(_ root: String, _ path: String) -> Bool {
        path == root || path.hasPrefix(root.hasSuffix("/") ? root : root + "/")
    }

    private static func restore(_ folder: URL) -> Bool {
        var saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Data] ?? [:]
        defer { UserDefaults.standard.set(saved, forKey: key) }
        for (path, data) in saved where covers(path, folder.path) {
            var stale = false
            guard let root = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale),
                  root.startAccessingSecurityScopedResource()
            else {
                saved[path] = nil
                continue
            }
            guard covers(root.resolvingSymlinksInPath().path, folder.path), FileManager.default.isWritableFile(atPath: folder.path) else {
                root.stopAccessingSecurityScopedResource()
                saved[path] = nil
                continue
            }
            if stale, let fresh = try? root.bookmarkData(options: .withSecurityScope) { saved[path] = fresh }
            open.append(root.resolvingSymlinksInPath())
            return true
        }
        return false
    }

    private static func ask(_ folder: URL) -> Bool {
        let home = URL(fileURLWithPath: String(cString: getpwuid(getuid())?.pointee.pw_dir ?? strdup("/")), isDirectory: true).resolvingSymlinksInPath()
        let inHome = covers(home.path, folder.path)
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = inHome ? home : folder
        panel.message = inHome
            ? String(localized: "Choose your home folder once so pikapik can save files next to yours.")
            : String(localized: "Choose this folder so pikapik can save files next to yours.")
        panel.prompt = String(localized: "Allow Access")
        NSApp.bringForward()
        while panel.runModal() == .OK {
            guard let url = panel.url, covers(url.resolvingSymlinksInPath().path, folder.path),
                  let data = try? url.bookmarkData(options: .withSecurityScope), url.startAccessingSecurityScopedResource()
            else { continue }
            var saved = UserDefaults.standard.dictionary(forKey: key) as? [String: Data] ?? [:]
            saved[url.resolvingSymlinksInPath().path] = data
            UserDefaults.standard.set(saved, forKey: key)
            open.append(url.resolvingSymlinksInPath())
            return true
        }
        return false
    }
    #else
    static func ensure(_ folders: [URL]) -> Bool { true }
    #endif
}
