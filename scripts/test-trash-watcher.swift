import Foundation

@main
struct TestTrashWatcher {
    static let fm = FileManager.default

    static func make(_ folder: URL, _ names: [String]) {
        for name in names {
            let url = folder.appendingPathComponent(name)
            if name.hasSuffix(".app") {
                try! fm.createDirectory(at: url, withIntermediateDirectories: true)
            } else {
                try! Data("x".utf8).write(to: url)
            }
        }
    }

    static func wait(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    static func main() {
        let folder = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pika-trash-watcher-\(UUID().uuidString)")
        try! fm.createDirectory(at: folder, withIntermediateDirectories: true)
        make(folder, ["Old.app", "Older.app", "notes.txt"])

        var offered: [[String]] = []
        guard let watcher = TrashWatcher(folder: folder, found: { offered.append($0.map(\.lastPathComponent)) }) else { preconditionFailure("watcher did not start") }
        wait(1.5)
        precondition(offered.isEmpty, "apps already in the Trash when the watcher starts must not be offered: \(offered)")

        make(folder, ["Fresh.app", "more.txt"])
        wait(1.5)
        precondition(offered == [["Fresh.app"]], "\(offered)")

        make(folder, ["Second.app", "Third.app"])
        wait(1.5)
        precondition(offered == [["Fresh.app"], ["Second.app", "Third.app"]], "\(offered)")

        try! fm.moveItem(at: folder.appendingPathComponent("Fresh.app"), to: folder.appendingPathComponent("Renamed.txt"))
        wait(1.5)
        precondition(offered.count == 2, "\(offered)")

        watcher.stop()
        make(folder, ["Late.app"])
        wait(1.5)
        precondition(offered.count == 2, "a stopped watcher must stay quiet: \(offered)")

        precondition(TrashWatcher(folder: folder.appendingPathComponent("missing"), found: { _ in }) == nil)
        precondition(TrashWatcher(folder: folder.appendingPathComponent("notes.txt"), found: { _ in }) == nil)
        print("trash watcher: baseline at start, new apps only, stop, unreadable folder: ok")
    }
}
