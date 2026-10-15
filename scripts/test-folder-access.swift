import Foundation

@main
enum TestFolderAccess {
    static func main() throws {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("pika-folder-access-\(getpid())")
        defer {
            try? fm.removeItem(at: root)
            UserDefaults.standard.removeObject(forKey: "folderBookmarks")
        }
        func folder(_ name: String) throws -> URL {
            let url = root.appendingPathComponent(name)
            try fm.createDirectory(at: url, withIntermediateDirectories: true)
            return url
        }
        func saved() -> [String: Data] { UserDefaults.standard.dictionary(forKey: "folderBookmarks") as? [String: Data] ?? [:] }
        func key(_ url: URL) -> String { url.standardizedFileURL.path }

        UserDefaults.standard.removeObject(forKey: "folderBookmarks")
        FolderAccess.prune()
        precondition(saved().isEmpty, "nothing saved, nothing to clean")

        let keep = try folder("keep"), gone = try folder("gone"), trashed = try folder("trashed")
        [keep, gone, trashed].forEach(FolderAccess.remember)
        precondition(saved().count == 3, "three folders saved: \(saved().count)")
        FolderAccess.prune()
        precondition(saved().count == 3, "folders that are still there are not touched")
        print("saved folders that still exist stay: ok")

        try fm.removeItem(at: gone)
        var inTrash: NSURL?
        try fm.trashItem(at: trashed, resultingItemURL: &inTrash)
        defer { inTrash.map { try? fm.removeItem(at: $0 as URL) } }
        UserDefaults.standard.set(saved().merging(["/Users/nobody/pika-garbage": Data([1, 2, 3])]) { $1 }, forKey: "folderBookmarks")
        FolderAccess.prune()
        precondition(Set(saved().keys) == [key(keep)], "a deleted folder, one in the Trash and one that does not open are gone, the live one stays: \(saved().keys.sorted())")
        precondition(FolderAccess.files(in: keep) != nil, "the live folder still opens")
        print("a deleted folder, one in the Trash and a broken entry are dropped, the live one stays: ok")

        let later = try folder("later"), fresh = try folder("fresh")
        FolderAccess.remember(later)
        try fm.removeItem(at: later)
        FolderAccess.remember(fresh)
        precondition(Set(saved().keys) == [key(keep), key(fresh)], "saving a new folder also cleans: \(saved().keys.sorted())")
        print("saving a new folder cleans the dead entries too: ok")

        let unplugged = "/Volumes/PikaNoSuchDisk-\(getpid())/photos"
        UserDefaults.standard.set(saved().merging([unplugged: Data([9])]) { $1 }, forKey: "folderBookmarks")
        FolderAccess.prune()
        precondition(saved().keys.contains(unplugged) && saved().count == 3, "a disk that is not plugged in keeps its entry for when it comes back")
        print("an unplugged disk keeps its entry: ok")
    }
}
