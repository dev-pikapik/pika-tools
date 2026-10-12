import Foundation

@main
enum TestRename {
    static func main() {
        let old = URL(fileURLWithPath: "/Applications/pika-tools.app")
        let new = URL(fileURLWithPath: "/Applications/pikapik.app")

        let root = FileManager.default.temporaryDirectory.appendingPathComponent("test-rename-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let ownID = "com.pesotchi.pika-tools"
        func plist(_ id: String?) -> Data {
            let info: [String: String] = id.map { ["CFBundleIdentifier": $0] } ?? [:]
            return try! PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        }
        func applications(newName info: Data?) -> URL {
            let dir = root.appendingPathComponent(UUID().uuidString)
            let contents = dir.appendingPathComponent("pikapik.app/Contents")
            try! FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
            if let info { try! info.write(to: contents.appendingPathComponent("Info.plist")) }
            return dir
        }
        func oldApp(in dir: URL) -> URL { dir.appendingPathComponent("pika-tools.app") }
        func destination(in dir: URL, brewManaged: Bool = false, id: String? = ownID) -> URL {
            Updater.destination(of: oldApp(in: dir), brewManaged: brewManaged, ownID: id)
        }
        let free = root.appendingPathComponent("free")
        let mine = applications(newName: plist(ownID))
        let store = applications(newName: plist("com.pikapik.tools"))
        let noInfo = applications(newName: nil)
        let unreadable = applications(newName: Data("not a plist".utf8))
        let noID = applications(newName: plist(nil))
        precondition(destination(in: free).path == free.path + "/pikapik.app")
        precondition(destination(in: mine).path == mine.path + "/pikapik.app")
        for dir in [store, noInfo, unreadable, noID] { precondition(destination(in: dir) == oldApp(in: dir), dir.path) }
        precondition(destination(in: noID, id: nil) == oldApp(in: noID))
        for dir in [free, mine, store] { precondition(destination(in: dir, brewManaged: true) == oldApp(in: dir), dir.path) }
        for dir in [free, mine, store] {
            for name in ["pikapik.app", "My Tools.app"] {
                let app = dir.appendingPathComponent(name)
                precondition(Updater.destination(of: app, brewManaged: false, ownID: ownID) == app, app.path)
            }
        }

        precondition(!Updater.isBrewManaged(prefixes: [root.path]))
        for token in ["pika-tools", "pikapik"] {
            let cask = root.appendingPathComponent("Caskroom/\(token)")
            try! FileManager.default.createDirectory(at: cask, withIntermediateDirectories: true)
            precondition(Updater.isBrewManaged(prefixes: ["/nonexistent", root.path]), token)
            try! FileManager.default.removeItem(at: cask)
        }
        precondition(!Updater.isBrewManaged(prefixes: [root.path]))

        precondition(!Updater.isNewPlace(new.path, last: nil, launchedBefore: false))
        precondition(Updater.isNewPlace(new.path, last: nil, launchedBefore: true))
        precondition(Updater.isNewPlace(new.path, last: old.path, launchedBefore: true))
        precondition(!Updater.isNewPlace(new.path, last: new.path, launchedBefore: true))

        let line = "+    com.pesotchi.pika-tools.new-file(1.27.1)\tD9AD182A\t2026-10-09 00:11:22 +0000\t"
        let appex = "/Applications/pikapik.app/Contents/PlugIns/NewFile.appex"
        precondition(Updater.isRegistered(appex, in: line + appex))
        precondition(!Updater.isRegistered(appex, in: line + "/Applications/pika-tools.app/Contents/PlugIns/NewFile.appex"))
        precondition(!Updater.isRegistered(appex, in: line + "/Users/me" + appex))
        precondition(!Updater.isRegistered(appex, in: "  (no matches)"))
        precondition(!Updater.isRegistered(appex, in: ""))
        for name in ["archive.tar.gz", "archive.tar.bz2", "archive.tar.xz"] {
            let taken = root.appendingPathComponent(name)
            try! Data().write(to: taken)
            let twin = FileManager.default.uniqueURL(for: name, in: root).lastPathComponent
            precondition(twin == name.replacingOccurrences(of: "archive", with: "archive 2"), twin)
        }
        precondition(FileManager.default.uniqueURL(for: "notes.txt", in: root).lastPathComponent == "notes.txt")
        try! FileManager.default.createSymbolicLink(atPath: root.path + "/Foo", withDestinationPath: "nowhere")
        precondition(FileManager.default.uniqueURL(for: "Foo", in: root, directory: true).lastPathComponent == "Foo 2")
        try! FileManager.default.createSymbolicLink(atPath: root.path + "/Bar.zip.002", withDestinationPath: "nowhere")
        precondition(FileManager.default.uniqueURL(for: "Bar.zip", in: root, parts: 3).lastPathComponent == "Bar 2.zip")
        print("rename: ok")
    }
}
