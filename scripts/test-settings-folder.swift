import Foundation

@main
enum TestSettingsFolder {
    static let manager = FileManager.default

    static func save(_ folder: URL, _ modified: Double) {
        try! manager.createDirectory(at: folder, withIntermediateDirectories: true)
        try! SettingsFile(settings: ["pet": true], modified: Date(timeIntervalSince1970: modified), device: folder.lastPathComponent)
            .data().write(to: folder.appendingPathComponent(SettingsFile.name))
    }

    static func stamp(_ folder: URL) -> Double? {
        (try? Data(contentsOf: folder.appendingPathComponent(SettingsFile.name))).flatMap(SettingsFile.init(data:))?.modified.timeIntervalSince1970
    }

    static func move(_ root: URL, old: Double, new: Double?, extra: Bool = false) -> (old: URL, new: URL) {
        let from = root.appendingPathComponent("pika-tools"), to = root.appendingPathComponent("pikapik")
        save(from, old)
        if let new { save(to, new) }
        if extra { try! Data("notes".utf8).write(to: from.appendingPathComponent("notes.txt")) }
        SettingsFile.moveFolder(from: from, to: to)
        return (from, to)
    }

    static func main() {
        let root = manager.temporaryDirectory.appendingPathComponent("test-settings-folder-\(UUID().uuidString)")
        defer { try? manager.removeItem(at: root) }

        var folders = move(root.appendingPathComponent("only-old"), old: 100, new: nil)
        precondition(!manager.fileExists(atPath: folders.old.path) && stamp(folders.new) == 100)

        folders = move(root.appendingPathComponent("old-newer"), old: 200, new: 100)
        precondition(!manager.fileExists(atPath: folders.old.path) && stamp(folders.new) == 200)

        folders = move(root.appendingPathComponent("new-newer"), old: 100, new: 200)
        precondition(!manager.fileExists(atPath: folders.old.path) && stamp(folders.new) == 200)

        folders = move(root.appendingPathComponent("other-files"), old: 300, new: 200, extra: true)
        precondition(stamp(folders.new) == 300 && manager.fileExists(atPath: folders.old.appendingPathComponent("notes.txt").path))

        let unread = root.appendingPathComponent("new-unreadable/pikapik").appendingPathComponent(SettingsFile.name)
        try! manager.createDirectory(at: unread.deletingLastPathComponent(), withIntermediateDirectories: true)
        try! Data("{".utf8).write(to: unread)
        folders = move(root.appendingPathComponent("new-unreadable"), old: 300, new: nil)
        precondition(stamp(folders.old) == 300 && (try? Data(contentsOf: unread)) == Data("{".utf8))

        print("settings folder: ok")
    }
}
