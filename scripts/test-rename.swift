import Foundation

@main
enum TestRename {
    static func main() {
        let old = URL(fileURLWithPath: "/Applications/pika-tools.app")
        let new = URL(fileURLWithPath: "/Applications/pikapik.app")
        let own = URL(fileURLWithPath: "/Users/me/Apps/My Tools.app")
        precondition(Updater.destination(of: old, brewManaged: false) == new)
        precondition(Updater.destination(of: old, brewManaged: true) == old)
        precondition(Updater.destination(of: new, brewManaged: false) == new)
        precondition(Updater.destination(of: own, brewManaged: false) == own)
        precondition(Updater.destination(of: URL(fileURLWithPath: "/Users/me/pika-tools.app"), brewManaged: false).path == "/Users/me/pikapik.app")

        let root = FileManager.default.temporaryDirectory.appendingPathComponent("test-rename-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        precondition(!Updater.isBrewManaged(prefixes: [root.path]))
        for token in ["pika-tools", "pikapik"] {
            let cask = root.appendingPathComponent("Caskroom/\(token)")
            try! FileManager.default.createDirectory(at: cask, withIntermediateDirectories: true)
            precondition(Updater.isBrewManaged(prefixes: ["/nonexistent", root.path]), token)
            try! FileManager.default.removeItem(at: cask)
        }
        precondition(!Updater.isBrewManaged(prefixes: [root.path]))
        print("rename: ok")
    }
}
