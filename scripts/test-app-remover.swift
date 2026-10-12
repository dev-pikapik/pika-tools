import Foundation

final class Stubs {
    let folder: URL
    let log: URL

    init(in base: URL) {
        folder = base.appendingPathComponent("stubs")
        log = folder.appendingPathComponent("calls")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        for tool in ["launchctl", "pkgutil"] {
            let script = "#!/bin/sh\nprintf '\(tool)' >> '\(log.path)'\nprintf '\\t%s' \"$@\" >> '\(log.path)'\nprintf '\\n' >> '\(log.path)'\n"
            let path = folder.appendingPathComponent(tool)
            try! script.write(to: path, atomically: false, encoding: .utf8)
            precondition(chmod(path.path, 0o755) == 0, "chmod \(tool)")
        }
    }

    var calls: [[String]] {
        let text = (try? String(contentsOf: log, encoding: .utf8)) ?? ""
        return text.split(separator: "\n").map { $0.split(separator: "\t", omittingEmptySubsequences: false).map(String.init) }
    }
}

final class World {
    private static let session = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pika-app-remover-\(UUID().uuidString)")

    let base: URL
    let top: URL
    let stubs: Stubs
    private let fm = FileManager.default
    private var locked: [String] = []

    init() {
        base = World.session.appendingPathComponent(UUID().uuidString)
        top = base.appendingPathComponent("alias")
        stubs = Stubs(in: base)
        try! fm.createDirectory(at: base.appendingPathComponent("real"), withIntermediateDirectories: true)
        try! fm.createSymbolicLink(atPath: top.path, withDestinationPath: "real")
        for name in ["root", "home", "cache", "temp", "trash", "store", "aside"] { folder(name) }
    }

    static func present(_ path: String) -> Bool {
        var info = stat()
        return lstat(path, &info) == 0
    }

    func at(_ path: String) -> URL { top.appendingPathComponent(path) }

    func rel(_ path: String) -> String {
        path.hasPrefix(top.path + "/") ? String(path.dropFirst(top.path.count + 1)) : path
    }

    func unique(_ stem: String) -> String { "pika-uninstall-test-\(stem)-\(UUID().uuidString.prefix(8))" }

    func folder(_ path: String) {
        try! fm.createDirectory(at: at(path), withIntermediateDirectories: true)
    }

    func file(_ path: String, _ text: String = "x") {
        folder((path as NSString).deletingLastPathComponent)
        try! text.write(to: at(path), atomically: false, encoding: .utf8)
    }

    func link(_ path: String, to target: String) {
        folder((path as NSString).deletingLastPathComponent)
        try! fm.createSymbolicLink(atPath: at(path).path, withDestinationPath: target)
    }

    @discardableResult
    func shelve(_ absolute: String) -> String {
        let destination = at("aside").appendingPathComponent("\(UUID().uuidString)-\((absolute as NSString).lastPathComponent)").path
        try! fm.moveItem(atPath: absolute, toPath: destination)
        return destination
    }

    func lock(_ path: String, mode: mode_t) {
        locked.append(path)
        precondition(chmod(at(path).path, mode) == 0, "chmod \(path)")
    }

    func unlockAll() {
        for path in locked { chmod(at(path).path, 0o755) }
        locked = []
    }

    func text(_ path: String) -> String? { try? String(contentsOf: at(path), encoding: .utf8) }

    func exists(_ path: String) -> Bool { World.present(at(path).path) }

    func same(_ path: String, _ item: Leftover) -> Bool {
        var info = stat()
        return lstat(path, &info) == 0 && info.st_dev == item.device && info.st_ino == item.inode
    }

    func stored() -> [AppRemover.Record] {
        try! JSONDecoder().decode([AppRemover.Record].self, from: Data(contentsOf: at("store/records.json")))
    }

    func why(_ report: AppRemover.Report) -> [String: AppRemover.Survivor.Why] {
        Dictionary(uniqueKeysWithValues: report.survivors.map { (rel($0.url.path), $0.why) })
    }

    func app(_ name: String, id: String, in dir: String = "root/Applications") -> AppIdentity {
        file("\(dir)/\(name).app/Contents/MacOS/\(name)")
        return AppIdentity(url: at("\(dir)/\(name).app"), bundleID: id, names: [name])
    }

    func item(_ path: String, kind: LeftoverKind = .appData, reason: LeftoverReason = .byName, admin: Bool = false, label: String? = nil,
              daemon: Bool = false, package: String? = nil, size: Int64? = nil) -> Leftover {
        var info = stat()
        let found = lstat(at(path).path, &info) == 0
        return Leftover(url: at(path), kind: kind, reason: reason, preselected: true, needsAdmin: admin, device: found ? info.st_dev : 0,
                        inode: found ? info.st_ino : 0, jobLabel: label, isDaemon: daemon, packageID: package, size: size)
    }

    func roots(pkgutil: @escaping ([String]) -> String?) -> AppRoots {
        AppRoots(home: at("home"), root: at("root"), userCache: at("cache"), userTemp: at("temp"), caskrooms: [at("root/opt/homebrew/Caskroom")],
                 pkgutil: pkgutil, isKnownApp: { _ in false })
    }
}

final class FakePackages {
    var installed: Set<String> = []
    var stubs: Stubs?

    func run(_ arguments: [String]) -> String? {
        guard arguments.count == 2, arguments[0] == "--pkg-info", installed.contains(arguments[1]) else { return nil }
        let forgotten = stubs?.calls.contains { $0 == ["pkgutil", "--forget", arguments[1]] } ?? false
        return forgotten ? nil : "package-id: \(arguments[1])\n"
    }
}

final class FakeLaunchctl {
    var calls: [[String]] = []
    var loaded: Set<String> = []

    func run(_ arguments: [String]) -> Int32 {
        calls.append(arguments)
        switch arguments.first {
        case "print": return loaded.contains(arguments[1]) ? 0 : 113
        case "bootout": return loaded.remove(arguments[1]) != nil ? 0 : 3
        case "bootstrap":
            loaded.insert(arguments[1] + "/" + ((arguments[2] as NSString).lastPathComponent as NSString).deletingPathExtension)
            return 0
        default: return 1
        }
    }
}

final class FakeAdmin {
    var scripts: [String] = []
    var prompts: [String] = []
    var answer = AppRemover.Outcome.done(nil)
    var before: () -> Void = {}
    private let stubs: Stubs

    init(stubs: Stubs) { self.stubs = stubs }

    func run(_ script: String, _ prompt: String) async -> AppRemover.Outcome {
        scripts.append(script)
        prompts.append(prompt)
        before()
        guard case .done = answer else { return answer }
        let tamed = script
            .replacingOccurrences(of: "/bin/launchctl", with: stubs.folder.path + "/launchctl")
            .replacingOccurrences(of: "/usr/sbin/pkgutil", with: stubs.folder.path + "/pkgutil")
        for tool in ["launchctl", "pkgutil"] {
            precondition(tamed.components(separatedBy: tool).count == tamed.components(separatedBy: stubs.folder.path + "/" + tool).count, "\(tool) outside the stub: \(tamed)")
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", tamed]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try! process.run()
        process.waitUntilExit()
        precondition(process.terminationStatus == 0, "script exit \(process.terminationStatus)")
        return answer
    }
}

final class FakeFinder {
    var urls: [URL] = []
    var answer = AppRemover.Outcome.done(nil)
    var reportsPath = true
    var rename: String?
    var before: () -> Void = {}
    private let trash: URL

    init(trash: URL) { self.trash = trash }

    func run(_ url: URL) async -> AppRemover.Outcome {
        urls.append(url)
        before()
        guard case .done = answer else { return answer }
        let destination = trash.appendingPathComponent(rename ?? url.lastPathComponent)
        try! FileManager.default.moveItem(at: url, to: destination)
        return .done(reportsPath ? destination.path : nil)
    }
}

final class FakeApp {
    let name: String
    var alive = true
    var quits = true
    var forceQuits = true
    var terminated = 0
    var forced = 0

    init(name: String) { self.name = name }

    var running: AppRemover.Running {
        AppRemover.Running(
            name: name,
            isRunning: { self.alive },
            terminate: {
                self.terminated += 1
                if self.quits { self.alive = false }
            },
            forceTerminate: {
                self.forced += 1
                if self.forceQuits { self.alive = false }
            })
    }
}

final class Rig {
    static var real: Set<String> = []

    let w = World()
    let admin: FakeAdmin
    let finder: FakeFinder
    let launchctl = FakeLaunchctl()
    let packages = FakePackages()
    var apps: [FakeApp] = []
    var quit = true
    var force = true
    var quitAsked: [[String]] = []
    var forceAsked: [[String]] = []
    var forgotten: [String] = []
    var remover: AppRemover!

    init(quitSeconds: Double = 5) {
        admin = FakeAdmin(stubs: w.stubs)
        finder = FakeFinder(trash: w.at("trash"))
        packages.stubs = w.stubs
        let hooks = AppRemover.Hooks(
            running: { _ in self.apps.map(\.running) },
            confirmQuit: { names in
                self.quitAsked.append(names)
                return self.quit
            },
            confirmForceQuit: { names in
                self.forceAsked.append(names)
                return self.force
            },
            launchctl: launchctl.run,
            admin: admin.run,
            finder: finder.run,
            forget: { self.forgotten.append($0) })
        let footprint = AppFootprint(roots: w.roots(pkgutil: packages.run), installed: [])
        remover = AppRemover(footprint: footprint, hooks: hooks, store: w.at("store"), trash: w.at("trash"), quitSeconds: quitSeconds)
    }

    var stubs: Stubs { w.stubs }

    func gui(_ label: String) -> String { "gui/\(getuid())/\(label)" }

    func remove(_ app: AppIdentity, _ items: [Leftover]) async -> AppRemover.Report {
        let report = await remover.remove(app, items: items)
        for move in report.record?.moves ?? [] where !move.trash.hasPrefix(w.top.path + "/") { Rig.real.insert(move.trash) }
        return report
    }
}

@main
enum AppRemoverTests {
    static func main() async {
        await roundTrip()
        await restoring()
        await changed()
        await never()
        await adminBatch()
        await adminGuard()
        await adminRestore()
        await adminOccupied()
        await cancelled()
        await survivors()
        await finderMoves()
        await receipts()
        await quitting()
        await jobs()
        await forgetting()
        await keeping()
        await racing()
        messages()
        let left = Rig.real.filter(World.present)
        precondition(left.isEmpty, "left in the Trash: \(left)")
        print("app remover: ok")
    }

    static func roundTrip() async {
        let rig = Rig()
        let w = rig.w
        let name = w.unique("app")
        let app = w.app(name, id: "com.example.\(name)")
        let data = "home/Library/Application Support/\(w.unique("data"))"
        w.file(data + "/note.txt")
        let prefs = "home/Library/Preferences/\(w.unique("prefs")).plist"
        w.file(prefs)
        let label = w.unique("agent")
        let agent = "home/Library/LaunchAgents/\(label).plist"
        w.file(agent)
        let ghost = "home/Library/Caches/\(w.unique("ghost"))"
        let old = "home/.Trash/\(w.unique("old"))"
        w.file(old)
        rig.launchctl.loaded = [rig.gui(label)]
        let moved = [
            w.item("root/Applications/\(name).app", kind: .app, reason: .bundle),
            w.item(data),
            w.item(prefs, kind: .preferences),
            w.item(agent, kind: .background, label: label),
        ]
        let items = moved + [w.item(data + "/note.txt"), w.item(ghost), w.item(old)]
        let bytes = moved.map { AppFootprint.allocatedSize(of: $0.url) }.reduce(0, +)
        let report = await rig.remove(app, items)
        precondition(report.removed == 4 && report.bytes == bytes && bytes > 0, "\(report)")
        precondition(report.survivors.isEmpty && !report.cancelled && report.stillOpen.isEmpty, "\(report)")
        guard let record = report.record else { preconditionFailure("no record: \(report)") }
        precondition(record.appName == name && record.bytes == bytes, "\(record)")
        precondition(Set(record.moves.map { w.rel($0.original) }) == Set(moved.map { w.rel($0.url.path) }), "\(record.moves)")
        for move in record.moves {
            guard let original = moved.first(where: { $0.url.path == move.original }) else { preconditionFailure("unknown \(move.original)") }
            precondition(!move.needsAdmin && move.device == original.device && move.inode == original.inode, "\(move)")
            precondition(AppInventory.isInTrash(URL(fileURLWithPath: move.trash)) && w.same(move.trash, original), "\(move)")
            precondition(!World.present(move.original), "\(move.original) is still there")
        }
        precondition(w.exists(old) && !w.exists(ghost))
        precondition(rig.launchctl.calls == [["print", rig.gui(label)], ["bootout", rig.gui(label)]], "\(rig.launchctl.calls)")
        precondition(record.jobs == [AppRemover.Job(label: label, domain: "gui/\(getuid())", plist: w.at(agent).path)], "\(record.jobs)")
        precondition(rig.admin.scripts.isEmpty && rig.finder.urls.isEmpty && rig.quitAsked.isEmpty)
        precondition(rig.forgotten == app.ids && !app.ids.isEmpty, "\(rig.forgotten)")
        precondition(rig.remover.records() == [record] && w.stored() == [record])

        let back = await rig.remover.restore(record)
        precondition(back.restored == 4 && back.stayed.isEmpty && !back.cancelled, "\(back)")
        for original in moved { precondition(w.same(original.url.path, original), "\(original.url.path) did not come back") }
        precondition(w.exists(data + "/note.txt"))
        precondition(rig.launchctl.calls.last == ["bootstrap", "gui/\(getuid())", w.at(agent).path], "\(rig.launchctl.calls)")
        precondition(rig.launchctl.loaded.contains(rig.gui(label)))
        precondition(rig.remover.records().isEmpty && w.stored().isEmpty)
    }

    static func restoring() async {
        let rig = Rig()
        let w = rig.w
        defer { w.unlockAll() }
        let app = w.app(w.unique("app"), id: "com.example.restoring")
        let folder = "home/Library/Application Support/\(w.unique("folder"))"
        w.folder(folder)
        func trashed() async -> (path: String, item: Leftover, record: AppRemover.Record) {
            let path = "\(folder)/\(w.unique("note")).txt"
            w.file(path)
            let item = w.item(path)
            let report = await rig.remove(app, [item])
            guard report.removed == 1, let record = report.record else { preconditionFailure("\(report)") }
            return (path, item, record)
        }

        let first = await trashed()
        w.lock(folder, mode: 0o555)
        var back = await rig.remover.restore(first.record)
        precondition(back.restored == 0 && back.stayed.map { w.rel($0.url.path) } == [first.path] && back.stayed.map(\.why) == [.failed], "\(back)")
        precondition(w.same(first.record.moves[0].trash, first.item) && rig.remover.records() == [first.record])
        w.unlockAll()
        back = await rig.remover.restore(first.record)
        precondition(back.restored == 1 && back.stayed.isEmpty && w.same(w.at(first.path).path, first.item), "\(back)")
        precondition(rig.remover.records().isEmpty)

        let second = await trashed()
        w.shelve(second.record.moves[0].trash)
        precondition(rig.remover.records().isEmpty && w.stored().isEmpty)
        back = await rig.remover.restore(second.record)
        precondition(back.restored == 0 && back.stayed.map(\.why) == [.missing] && !w.exists(second.path), "\(back)")

        let third = await trashed()
        w.file(third.path, "new")
        back = await rig.remover.restore(third.record)
        precondition(back.restored == 0 && back.stayed.map(\.why) == [.occupied] && w.text(third.path) == "new", "\(back)")
        precondition(w.same(third.record.moves[0].trash, third.item))
        w.shelve(third.record.moves[0].trash)
    }

    static func changed() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.changed")
        let swapped = "home/Library/Preferences/\(w.unique("swapped")).plist"
        w.file(swapped, "original")
        let swappedItem = w.item(swapped, kind: .preferences)
        w.shelve(w.at(swapped).path)
        w.file(swapped, "stranger")
        let label = w.unique("agent")
        let agent = "home/Library/LaunchAgents/\(label).plist"
        w.file(agent, "original")
        let agentItem = w.item(agent, kind: .background, label: label)
        w.shelve(w.at(agent).path)
        w.file(agent, "stranger")
        rig.launchctl.loaded = [rig.gui(label)]
        let parent = "home/Library/Application Support/\(w.unique("parent"))"
        w.file(parent + "/data", "inside")
        let insideItem = w.item(parent + "/data")
        w.link(parent, to: w.shelve(w.at(parent).path))
        precondition(w.same(w.at(parent + "/data").path, insideItem), "the link must keep the identity")

        let report = await rig.remove(app, [swappedItem, agentItem, insideItem])
        precondition(report.removed == 0 && report.record == nil && !report.cancelled, "\(report)")
        precondition(w.why(report) == [swapped: .changed, agent: .changed, parent + "/data": .changed], "\(w.why(report))")
        precondition(report.survivors.allSatisfy { $0.step == .showInFinder })
        precondition(w.text(swapped) == "stranger" && w.text(agent) == "stranger" && w.text(parent + "/data") == "inside")
        precondition(rig.launchctl.calls.isEmpty && rig.admin.scripts.isEmpty && rig.finder.urls.isEmpty)
    }

    static func never() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.never")
        let tools = "root/usr/local/bin"
        let tool = "\(tools)/\(w.unique("tool"))"
        w.link(tool, to: "/nonexistent-pika-target")
        let paths = [
            "home/Documents/\(w.unique("doc")).txt",
            "home/Desktop/\(w.unique("desk")).txt",
            "home/Downloads/\(w.unique("down")).txt",
            "home/Library/Mobile Documents/\(w.unique("cloud"))",
            "home/Library/Keychains/\(w.unique("keys")).keychain-db",
            "home/Library/Preferences/com.apple.finder.plist",
            "root/System/Library/\(w.unique("sys"))",
            "root/usr/lib/\(w.unique("usr"))",
        ]
        paths.forEach { w.file($0) }
        w.folder("home/Library/Application Support")
        let places = ["home/Library/Application Support", "home", "root"]
        let items = paths.map { w.item($0, admin: $0.hasPrefix("root/")) } + places.map { w.item($0) } + [w.item(tool, kind: .install, reason: .byName, admin: true)]
        let report = await rig.remove(app, items)
        precondition(report.removed == 0 && report.record == nil && !report.cancelled, "\(report)")
        precondition(w.why(report) == Dictionary(uniqueKeysWithValues: (paths + places + [tool]).map { ($0, .protected) }), "\(w.why(report))")
        precondition(report.survivors.allSatisfy { $0.step == nil })
        precondition((paths + places + [tool]).allSatisfy(w.exists))
        precondition(rig.admin.scripts.isEmpty && rig.finder.urls.isEmpty && rig.launchctl.calls.isEmpty && rig.forgotten.isEmpty)

        let link = await rig.remove(app, [w.item(tool, kind: .install, reason: .cliLink, admin: true)])
        precondition(link.removed == 1 && link.survivors.isEmpty && !w.exists(tool), "\(link)")
        precondition(rig.admin.scripts.count == 1 && rig.admin.scripts[0].contains("/bin/mv -n '\(w.at(tool).path)'"), "\(rig.admin.scripts)")
    }

    static func adminBatch() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.batch")
        let oddName = "it's $HOME \"q\" `x` \(w.unique("odd"))"
        let odd = "root/Library/Application Support/\(oddName)"
        w.file(odd + "/inner.txt")
        let twin = w.unique("twin")
        let twins = ["root/Library/Caches/\(twin)", "root/Library/Logs/\(twin)"]
        twins.forEach { w.file($0 + "/x") }
        let label = w.unique("helper")
        let daemon = "root/Library/LaunchDaemons/\(label).plist"
        w.file(daemon)
        rig.launchctl.loaded = ["system/\(label)"]
        let package = "com.example.pika-test.pkg-1"
        rig.packages.installed = [package]
        let receipt = w.item("root/var/db/receipts/\(package).plist", kind: .install, reason: .receipt(package), admin: true, package: package)
        let moved = [w.item(odd, admin: true)] + twins.map { w.item($0, admin: true) } + [w.item(daemon, kind: .background, admin: true, label: label, daemon: true)]
        let bytes = moved.map { AppFootprint.allocatedSize(of: $0.url) }.reduce(0, +)
        let report = await rig.remove(app, moved + [receipt])

        let trash = w.at("trash").path
        func q(_ text: String) -> String { "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'" }
        func step(_ item: Leftover, to name: String) -> String {
            "[ ! -e \(q(trash + "/" + name)) ] && [ \"$(/usr/bin/stat -f '%d:%i' \(q(item.url.path)))\" = '\(item.device):\(item.inode)' ] && /bin/mv -n \(q(item.url.path)) \(q(trash + "/" + name))"
        }
        let script = rig.admin.scripts.first ?? ""
        precondition(rig.admin.scripts.count == 1 && rig.admin.prompts == ["pikapik wants to remove what “\(app.displayName)” left behind."], "\(rig.admin.prompts)")
        precondition(script.contains(step(moved[0], to: oddName)), script)
        precondition(script.contains("it'\\''s $HOME \"q\" `x` "), script)
        precondition(script.contains(step(moved[3], to: label + ".plist") + " && /bin/launchctl bootout 'system/\(label)'; "), script)
        precondition(script.hasSuffix("; /usr/sbin/pkgutil --forget '\(package)'; exit 0"), script)
        precondition(script.components(separatedBy: "/bin/mv -n").count == 5 && !script.contains("receipts"), script)

        precondition(report.removed == 5 && report.bytes == bytes && report.survivors.isEmpty && !report.cancelled, "\(report)")
        guard let record = report.record else { preconditionFailure("no record: \(report)") }
        precondition(record.moves.count == 4 && record.moves.allSatisfy(\.needsAdmin), "\(record)")
        precondition(record.jobs == [AppRemover.Job(label: label, domain: "system", plist: w.at(daemon).path)], "\(record.jobs)")
        precondition(rig.stubs.calls == [["launchctl", "bootout", "system/\(label)"], ["pkgutil", "--forget", package]], "\(rig.stubs.calls)")
        precondition(rig.launchctl.calls == [["print", "system/\(label)"]], "\(rig.launchctl.calls)")
        precondition(w.exists("trash/\(oddName)/inner.txt") && w.exists("trash/\(label).plist"))
        let twinsInTrash = (try? FileManager.default.contentsOfDirectory(atPath: trash))?.filter { $0.hasPrefix(twin) } ?? []
        precondition(twinsInTrash.count == 2 && twinsInTrash.allSatisfy { w.exists("trash/\($0)/x") }, "\(twinsInTrash)")
        precondition(moved.allSatisfy { !World.present($0.url.path) })

        let back = await rig.remover.restore(record)
        let undo = rig.admin.scripts.last ?? ""
        precondition(back.restored == 4 && back.stayed.isEmpty && !back.cancelled, "\(back)")
        precondition(rig.admin.scripts.count == 2 && rig.admin.prompts[1] == "pikapik wants to put back what it removed.", "\(rig.admin.prompts)")
        precondition(undo.hasSuffix("; exit 0") && undo.components(separatedBy: "/bin/mv -n").count == 5, undo)
        precondition(undo.contains(" && /bin/launchctl bootstrap system \(q(w.at(daemon).path))"), undo)
        precondition(moved.allSatisfy { w.same($0.url.path, $0) })
        precondition(rig.stubs.calls.last == ["launchctl", "bootstrap", "system", w.at(daemon).path], "\(rig.stubs.calls)")
        precondition(rig.remover.records().isEmpty)
    }

    static func adminGuard() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.guard")
        let path = "root/Library/Application Support/\(w.unique("guard"))"
        w.file(path + "/data", "original")
        let item = w.item(path, admin: true)
        rig.admin.before = {
            w.shelve(w.at(path).path)
            w.file(path + "/data", "stranger")
        }
        let report = await rig.remove(app, [item])
        precondition(report.removed == 0 && report.record == nil && !report.cancelled, "\(report)")
        precondition(w.why(report) == [path: .failed] && report.survivors[0].step == .showInFinder, "\(w.why(report))")
        precondition(w.text(path + "/data") == "stranger" && rig.admin.scripts.count == 1)
        precondition(((try? FileManager.default.contentsOfDirectory(atPath: w.at("trash").path)) ?? ["?"]).isEmpty)
    }

    static func adminRestore() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.again")
        let path = "root/Library/Application Support/\(w.unique("again"))"
        w.file(path + "/data", "original")
        let item = w.item(path, admin: true)
        let report = await rig.remove(app, [item])
        guard let record = report.record, let move = record.moves.first else { preconditionFailure("\(report)") }

        rig.admin.answer = .cancelled
        var back = await rig.remover.restore(record)
        precondition(back.cancelled && back.restored == 0 && back.stayed.map(\.why) == [.cancelled], "\(back)")
        precondition(w.same(move.trash, item) && rig.remover.records() == [record])

        rig.admin.answer = .failed
        back = await rig.remover.restore(record)
        precondition(!back.cancelled && back.restored == 0 && back.stayed.map(\.why) == [.failed], "\(back)")

        rig.admin.answer = .done(nil)
        rig.admin.before = {
            w.shelve(move.trash)
            try! "stranger".write(toFile: move.trash, atomically: false, encoding: .utf8)
        }
        back = await rig.remover.restore(record)
        precondition(back.restored == 0 && back.stayed.map(\.why) == [.failed], "\(back)")
        precondition(!w.exists(path) && (try? String(contentsOfFile: move.trash, encoding: .utf8)) == "stranger")
        precondition(rig.remover.records().isEmpty)
    }

    static func adminOccupied() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.occupied")
        let path = "root/Library/Application Support/\(w.unique("occupied"))"
        w.file(path + "/data", "original")
        let item = w.item(path, admin: true)
        let report = await rig.remove(app, [item])
        guard let record = report.record, let move = record.moves.first else { preconditionFailure("\(report)") }

        rig.admin.before = { w.file(path + "/data", "reinstalled") }
        let back = await rig.remover.restore(record)
        precondition(back.restored == 0 && !back.cancelled && back.stayed.map(\.why) == [.occupied], "\(back)")
        precondition(rig.admin.scripts.count == 2 && rig.admin.scripts[1].contains("[ ! -e '\(w.at(path).path)' ] && "), "\(rig.admin.scripts)")
        precondition(w.text(path + "/data") == "reinstalled" && !w.exists(path + "/" + (move.trash as NSString).lastPathComponent), "nested in the new copy")
        precondition(w.same(move.trash, item) && rig.remover.records() == [record])
    }

    static func racing() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.racing")
        let remover = rig.remover!
        func pick(_ count: Int) -> [Leftover] {
            (0..<count).map { _ in
                let path = "home/Library/Application Support/\(w.unique("race"))"
                w.file(path)
                return w.item(path)
            }
        }
        let warm = await remover.remove(app, items: pick(1))
        guard let first = warm.record else { preconditionFailure("\(warm)") }
        _ = await remover.restore(first)
        for round in 1...3 {
            let made: [AppRemover.Record] = await withTaskGroup(of: AppRemover.Record?.self) { group in
                for item in pick(8) { group.addTask { await remover.remove(app, items: [item]).record } }
                var records: [AppRemover.Record] = []
                for await record in group { if let record { records.append(record) } }
                return records
            }
            let kept = Set(remover.records().map(\.id))
            let lost = made.filter { !kept.contains($0.id) }.count
            for record in made { _ = await remover.restore(record) }
            precondition(made.count == 8 && lost == 0, "round \(round): \(lost) of \(made.count) records lost")
        }
        precondition(remover.records().isEmpty)
    }

    static func cancelled() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.cancelled")
        let note = "home/Library/Application Support/\(w.unique("note"))"
        w.file(note + "/x")
        let data = "root/Library/Application Support/\(w.unique("data"))"
        w.file(data + "/x")
        let daemonLabel = w.unique("daemon")
        let daemon = "root/Library/LaunchDaemons/\(daemonLabel).plist"
        w.file(daemon)
        let agentLabel = w.unique("agent")
        let agent = "home/Library/LaunchAgents/\(agentLabel).plist"
        w.file(agent)
        let package = "com.example.pika-test.pkg-2"
        let receipt = "root/var/db/receipts/\(package).plist"
        rig.packages.installed = [package]
        rig.launchctl.loaded = [rig.gui(agentLabel), "system/\(daemonLabel)"]
        let items = [
            w.item(note),
            w.item(data, admin: true),
            w.item(daemon, kind: .background, admin: true, label: daemonLabel, daemon: true),
            w.item(agent, kind: .background, admin: true, label: agentLabel),
            w.item(receipt, kind: .install, reason: .receipt(package), admin: true, package: package),
        ]

        rig.admin.answer = .cancelled
        let report = await rig.remove(app, items)
        precondition(report.cancelled && report.removed == 1 && report.stillOpen.isEmpty, "\(report)")
        precondition(w.why(report) == [data: .cancelled, daemon: .cancelled, agent: .cancelled, receipt: .cancelled], "\(w.why(report))")
        precondition(report.survivors.allSatisfy { $0.step == nil })
        precondition(report.record?.moves.count == 1 && report.record?.jobs.isEmpty == true, "\(report)")
        precondition(rig.admin.scripts.count == 1 && rig.stubs.calls.isEmpty)
        let expected = [["print", rig.gui(agentLabel)], ["bootout", rig.gui(agentLabel)], ["print", "system/\(daemonLabel)"], ["bootstrap", "gui/\(getuid())", w.at(agent).path]]
        precondition(rig.launchctl.calls == expected, "\(rig.launchctl.calls)")
        precondition(rig.launchctl.loaded == [rig.gui(agentLabel), "system/\(daemonLabel)"])
        precondition(rig.forgotten.isEmpty && [data, daemon, agent].allSatisfy(w.exists))

        rig.admin.answer = .failed
        let again = await rig.remove(app, Array(items.dropFirst()))
        precondition(!again.cancelled && again.removed == 0 && again.record == nil, "\(again)")
        precondition(w.why(again) == [data: .failed, daemon: .failed, agent: .failed, receipt: .failed], "\(w.why(again))")
        precondition(again.survivors.filter { $0.step == .showInFinder }.count == 3 && again.survivors.filter { $0.step == nil }.count == 1)
        precondition(rig.stubs.calls.isEmpty)

        guard let record = report.record else { preconditionFailure("\(report)") }
        let back = await rig.remover.restore(record)
        precondition(back.restored == 1 && back.stayed.isEmpty && w.same(w.at(note).path, items[0]), "\(back)")
    }

    static func survivors() async {
        let rig = Rig()
        let w = rig.w
        defer { w.unlockAll() }
        let locked = "home/Library/Application Support/\(w.unique("locked"))"
        w.file(locked + "/data")
        let blocked = w.item(locked + "/data")
        let one = w.unique("one")
        let two = w.unique("two")
        let first = w.app(one, id: "com.example.survivors.one")
        let second = w.app(two, id: "com.example.survivors.two")
        let firstItem = w.item("root/Applications/\(one).app", kind: .app, reason: .bundle)
        let secondItem = w.item("root/Applications/\(two).app", kind: .app, reason: .bundle)
        w.lock(locked, mode: 0o555)
        w.lock("root/Applications", mode: 0o555)
        let bundle = "root/Applications/\(one).app"

        rig.finder.answer = .denied
        var report = await rig.remove(first, [blocked, firstItem])
        precondition(report.removed == 0 && report.record == nil && !report.cancelled, "\(report)")
        precondition(w.why(report) == [locked + "/data": .blocked, bundle: .automation], "\(w.why(report))")
        precondition(Set(report.survivors.map(\.step)) == [.openAppManagement, .openAutomation], "\(report.survivors)")
        precondition(rig.finder.urls.map(\.path) == [w.at(bundle).path] && rig.admin.scripts.isEmpty)
        precondition(w.exists(locked + "/data") && w.exists(bundle) && rig.forgotten.isEmpty)

        rig.finder.answer = .cancelled
        report = await rig.remove(first, [blocked, firstItem])
        precondition(report.cancelled && report.removed == 0, "\(report)")
        precondition(w.why(report) == [locked + "/data": .blocked, bundle: .cancelled], "\(w.why(report))")

        rig.finder.answer = .failed
        report = await rig.remove(first, [blocked, firstItem])
        precondition(!report.cancelled && w.why(report) == [locked + "/data": .blocked, bundle: .failed], "\(w.why(report))")
        precondition(report.survivors.first { $0.why == .failed }?.step == .showInFinder)
        precondition(rig.finder.urls.count == 3)

        rig.finder.answer = .done(nil)
        rig.finder.before = { w.unlockAll() }
        report = await rig.remove(second, [secondItem])
        precondition(report.removed == 1 && report.survivors.isEmpty, "\(report)")
        guard let move = report.record?.moves.first else { preconditionFailure("\(report)") }
        precondition(!move.needsAdmin && move.trash == w.at("trash/\(two).app").path && w.same(move.trash, secondItem), "\(move)")
        precondition(rig.finder.urls.count == 4 && rig.admin.scripts.isEmpty && rig.forgotten == second.ids, "\(rig.forgotten)")
    }

    static func finderMoves() async {
        let rig = Rig()
        let w = rig.w
        func install(_ stem: String) -> (app: AppIdentity, item: Leftover) {
            let name = w.unique(stem)
            return (w.app(name, id: "com.example.\(stem)"), w.item("root/Applications/\(name).app", kind: .app, reason: .bundle, admin: true))
        }

        let (first, firstItem) = install("finder-a")
        var report = await rig.remove(first, [firstItem])
        guard let firstRecord = report.record, firstRecord.moves.count == 1 else { preconditionFailure("\(report)") }
        precondition(rig.finder.urls.map(\.path) == [firstItem.url.path] && rig.admin.scripts.isEmpty, "\(rig.finder.urls)")
        precondition(report.removed == 1 && report.survivors.isEmpty && !report.cancelled, "\(report)")
        let firstMove = firstRecord.moves[0]
        precondition(firstMove.trash == w.at("trash/\(firstItem.url.lastPathComponent)").path && firstMove.needsAdmin, "\(firstMove)")
        precondition(w.same(firstMove.trash, firstItem) && !World.present(firstItem.url.path))

        let (second, secondItem) = install("finder-b")
        rig.finder.reportsPath = false
        rig.finder.rename = "\(secondItem.url.deletingPathExtension().lastPathComponent) 2.app"
        report = await rig.remove(second, [secondItem])
        guard let secondMove = report.record?.moves.first else { preconditionFailure("\(report)") }
        precondition(secondMove.trash == w.at("trash/\(rig.finder.rename ?? "")").path && w.same(secondMove.trash, secondItem), "\(secondMove)")

        let back = await rig.remover.restore(firstRecord)
        precondition(back.restored == 1 && back.stayed.isEmpty && w.same(firstItem.url.path, firstItem), "\(back)")
        precondition(rig.admin.scripts.count == 1 && rig.admin.scripts[0].contains("/bin/mv -n '\(firstMove.trash)' '\(firstItem.url.path)'"), "\(rig.admin.scripts)")
    }

    static func receipts() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.receipts")
        let good = "com.example.pika-test.good-1"
        let bad = ["x; true", "$(true)", "-f", "a b", "x'y"]
        rig.packages.installed = Set([good] + bad)
        func receipt(_ id: String) -> Leftover {
            w.item("root/var/db/receipts/\(id).plist", kind: .install, reason: .receipt(id), admin: true, package: id)
        }

        let report = await rig.remove(app, [receipt(good)])
        precondition(report.removed == 1 && report.record == nil && report.survivors.isEmpty, "\(report)")
        precondition(rig.admin.scripts == ["/usr/sbin/pkgutil --forget '\(good)'; exit 0"], "\(rig.admin.scripts)")
        precondition(rig.stubs.calls == [["pkgutil", "--forget", good]] && !w.exists("root/var"), "\(rig.stubs.calls)")

        let refused = await rig.remove(app, bad.map(receipt))
        precondition(refused.removed == 0 && refused.record == nil && !refused.cancelled, "\(refused)")
        precondition(refused.survivors.count == bad.count && refused.survivors.allSatisfy { $0.why == .failed && $0.step == nil }, "\(refused.survivors)")
        precondition(rig.admin.scripts.count == 1 && rig.stubs.calls.count == 1)
    }

    static func quitting() async {
        func attempt(_ configure: (Rig, FakeApp) -> Void) async -> (rig: Rig, app: FakeApp, report: AppRemover.Report, data: String, agent: String) {
            let rig = Rig(quitSeconds: 0.25)
            let w = rig.w
            let fake = FakeApp(name: "Pika Test")
            rig.apps = [fake]
            configure(rig, fake)
            let app = w.app(w.unique("app"), id: "com.example.quitting")
            let label = w.unique("agent")
            let data = "root/Library/Application Support/\(w.unique("data"))"
            let agent = "home/Library/LaunchAgents/\(label).plist"
            w.file(data + "/x")
            w.file(agent)
            rig.launchctl.loaded = [rig.gui(label)]
            let report = await rig.remove(app, [w.item(data, admin: true), w.item(agent, kind: .background, admin: true, label: label)])
            return (rig, fake, report, data, agent)
        }

        var run = await attempt { rig, _ in rig.quit = false }
        precondition(run.report.cancelled && run.report.removed == 0 && run.report.stillOpen.isEmpty, "\(run.report)")
        precondition(run.rig.quitAsked == [["Pika Test"]] && run.app.terminated == 0 && run.rig.forceAsked.isEmpty)
        precondition(run.rig.launchctl.calls.isEmpty && run.rig.admin.scripts.isEmpty && run.rig.w.exists(run.data))

        run = await attempt { _, _ in }
        precondition(run.report.removed == 2 && run.report.stillOpen.isEmpty && !run.report.cancelled, "\(run.report)")
        precondition(run.rig.quitAsked == [["Pika Test"]] && run.app.terminated == 1 && run.app.forced == 0 && run.rig.forceAsked.isEmpty)
        precondition(run.report.record?.jobs.count == 1 && !run.rig.w.exists(run.data))

        run = await attempt { rig, app in
            app.quits = false
            rig.force = false
        }
        let label = (run.agent as NSString).lastPathComponent.replacingOccurrences(of: ".plist", with: "")
        precondition(run.report.stillOpen == ["Pika Test"] && run.report.removed == 0 && run.report.record == nil, "\(run.report)")
        precondition(run.rig.forceAsked == [["Pika Test"]] && run.app.terminated == 1 && run.app.forced == 0)
        precondition(run.rig.launchctl.calls == [["print", run.rig.gui(label)], ["bootout", run.rig.gui(label)], ["bootstrap", "gui/\(getuid())", run.rig.w.at(run.agent).path]], "\(run.rig.launchctl.calls)")
        precondition(run.rig.launchctl.loaded.contains(run.rig.gui(label)) && run.rig.admin.scripts.isEmpty && run.rig.w.exists(run.data))

        run = await attempt { _, app in app.quits = false }
        precondition(run.report.removed == 2 && run.report.stillOpen.isEmpty, "\(run.report)")
        precondition(run.rig.forceAsked == [["Pika Test"]] && run.app.forced == 1 && !run.rig.w.exists(run.data))

        run = await attempt { _, app in
            app.quits = false
            app.forceQuits = false
        }
        precondition(run.report.stillOpen == ["Pika Test"] && run.report.removed == 0, "\(run.report)")
        precondition(run.app.forced == 1 && run.rig.forceAsked.count == 1 && run.rig.launchctl.calls.last?.first == "bootstrap" && run.rig.w.exists(run.data))
    }

    static func jobs() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.jobs")
        func pair() -> (agent: Leftover, daemon: Leftover, agentLabel: String, daemonLabel: String) {
            let agentLabel = w.unique("agent")
            let daemonLabel = w.unique("daemon")
            w.file("home/Library/LaunchAgents/\(agentLabel).plist")
            w.file("root/Library/LaunchDaemons/\(daemonLabel).plist")
            return (w.item("home/Library/LaunchAgents/\(agentLabel).plist", kind: .background, admin: true, label: agentLabel),
                    w.item("root/Library/LaunchDaemons/\(daemonLabel).plist", kind: .background, admin: true, label: daemonLabel, daemon: true), agentLabel, daemonLabel)
        }

        let idle = pair()
        var report = await rig.remove(app, [idle.agent, idle.daemon])
        precondition(rig.launchctl.calls == [["print", rig.gui(idle.agentLabel)], ["print", "system/\(idle.daemonLabel)"]], "\(rig.launchctl.calls)")
        precondition(report.removed == 2 && report.record?.jobs.isEmpty == true && !rig.admin.scripts[0].contains("bootout"), "\(report)")

        let busy = pair()
        rig.launchctl.loaded = [rig.gui(busy.agentLabel), "system/\(busy.daemonLabel)"]
        report = await rig.remove(app, [busy.agent, busy.daemon])
        let jobs = [
            AppRemover.Job(label: busy.agentLabel, domain: "gui/\(getuid())", plist: busy.agent.url.path),
            AppRemover.Job(label: busy.daemonLabel, domain: "system", plist: busy.daemon.url.path),
        ]
        precondition(report.removed == 2 && report.record?.jobs == jobs, "\(report)")
        precondition(rig.stubs.calls == [["launchctl", "bootout", "system/\(busy.daemonLabel)"]], "\(rig.stubs.calls)")

        guard let record = report.record else { preconditionFailure("\(report)") }
        let back = await rig.remover.restore(record)
        precondition(back.restored == 2 && back.stayed.isEmpty, "\(back)")
        precondition(rig.launchctl.calls.last == ["bootstrap", "gui/\(getuid())", busy.agent.url.path], "\(rig.launchctl.calls)")
        precondition(rig.stubs.calls.last == ["launchctl", "bootstrap", "system", busy.daemon.url.path], "\(rig.stubs.calls)")
    }

    static func forgetting() async {
        let trashed = Rig()
        let t = trashed.w
        let gone = t.unique("gone")
        let goneApp = t.app(gone, id: "com.example.gone", in: "home/.Trash")
        let leftover = "root/Library/Application Support/\(t.unique("left"))"
        t.file(leftover + "/x")
        var report = await trashed.remove(goneApp, [t.item("home/.Trash/\(gone).app", kind: .app, reason: .bundle), t.item(leftover, admin: true)])
        precondition(report.removed == 1 && report.survivors.isEmpty && !goneApp.ids.isEmpty && trashed.forgotten == goneApp.ids, "\(report) \(trashed.forgotten)")
        precondition(t.exists("home/.Trash/\(gone).app") && trashed.finder.urls.isEmpty && trashed.admin.scripts.count == 1)

        let kept = Rig()
        let k = kept.w
        let keptApp = k.app(k.unique("kept"), id: "com.example.kept")
        let other = "root/Library/Application Support/\(k.unique("left"))"
        k.file(other + "/x")
        report = await kept.remove(keptApp, [k.item(other, admin: true)])
        precondition(report.removed == 1 && kept.forgotten.isEmpty, "\(report)")

        let stuck = Rig()
        let s = stuck.w
        stuck.finder.answer = .denied
        let name = s.unique("stuck")
        let stuckApp = s.app(name, id: "com.example.stuck")
        let side = "root/Library/Application Support/\(s.unique("left"))"
        s.file(side + "/x")
        report = await stuck.remove(stuckApp, [s.item("root/Applications/\(name).app", kind: .app, reason: .bundle, admin: true), s.item(side, admin: true)])
        precondition(report.removed == 1 && s.why(report) == ["root/Applications/\(name).app": .automation] && stuck.forgotten.isEmpty, "\(report)")
    }

    static func keeping() async {
        let rig = Rig()
        let w = rig.w
        let app = w.app(w.unique("app"), id: "com.example.keeping")
        var ids: [String] = []
        for _ in 0..<12 {
            let path = "root/Library/Application Support/\(w.unique("many"))"
            w.file(path + "/x")
            let report = await rig.remove(app, [w.item(path, admin: true)])
            guard let record = report.record else { preconditionFailure("\(report)") }
            ids.append(record.id)
            let kept = rig.remover.records().map(\.id)
            precondition(kept == Array(ids.suffix(10).reversed()), "\(kept)")
        }
        precondition(w.stored().map(\.id) == Array(ids.suffix(10).reversed()))
    }

    static func messages() {
        let url = URL(fileURLWithPath: "/nonexistent-pika-target")
        let whys: [AppRemover.Survivor.Why] = [.changed, .protected, .cancelled, .blocked, .automation, .failed]
        let texts = whys.map { AppRemover.Survivor(url: url, why: $0, step: $0.step).message }
        precondition(Set(texts).count == whys.count && !texts.contains(""), "\(texts)")
        precondition(texts[3].contains("App Management") && texts[4].contains("Automation") && texts[4].contains("Finder"), "\(texts)")
        let steps: [AppRemover.Step?] = [.showInFinder, nil, nil, .openAppManagement, .openAutomation, .showInFinder]
        precondition(whys.map(\.step) == steps)
        let stays: [AppRemover.Stay.Why] = [.missing, .occupied, .failed, .cancelled]
        let reasons = stays.map { AppRemover.Stay(url: url, why: $0).message }
        precondition(Set(reasons).count == stays.count && !reasons.contains(""), "\(reasons)")
        precondition([AppRemover.Step.openAutomation, .openAppManagement, .showInFinder].map(\.title) == ["Open Automation settings", "Open App Management settings", "Show in Finder"])
    }
}
