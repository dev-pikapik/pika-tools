import Foundation

final class World {
    let base: URL
    private let fm = FileManager.default
    private var locked: [String] = []
    private var frozen: [String] = []

    init() {
        base = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pika-uninstaller-\(UUID().uuidString)")
        for name in ["root", "home", "cache", "temp"] { folder(name) }
    }

    func at(_ path: String) -> URL { base.appendingPathComponent(path) }

    func rel(_ url: URL) -> String { String(url.path.dropFirst(base.path.count + 1)) }

    private func parent(_ path: String) -> String { (path as NSString).deletingLastPathComponent }

    func folder(_ path: String) {
        try! fm.createDirectory(at: at(path), withIntermediateDirectories: true)
    }

    func file(_ path: String, _ text: String = "x") {
        folder(parent(path))
        try! text.write(to: at(path), atomically: false, encoding: .utf8)
    }

    func node(_ path: String) {
        if [".plist", ".ips", ".binarycookies"].contains(where: path.hasSuffix) { file(path) } else { file(path + "/data") }
    }

    func plist(_ path: String, _ object: [String: Any]) {
        folder(parent(path))
        try! PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0).write(to: at(path))
    }

    func json(_ path: String, _ object: Any) {
        folder(parent(path))
        try! JSONSerialization.data(withJSONObject: object).write(to: at(path))
    }

    func link(_ path: String, to target: String) {
        folder(parent(path))
        try! fm.createSymbolicLink(atPath: at(path).path, withDestinationPath: target)
    }

    func big(_ path: String) {
        folder(parent(path))
        try! Data(repeating: 0x61, count: 1_000_000).write(to: at(path))
    }

    func age(_ path: String, days: Double, from now: Date, deep: Bool = true) {
        let start = at(path).path
        var paths = [start]
        let isDirectory = (try? fm.attributesOfItem(atPath: start)[.type] as? FileAttributeType) == .typeDirectory
        if deep, isDirectory, let walker = fm.enumerator(atPath: start) {
            paths += walker.compactMap { ($0 as? String).map { start + "/" + $0 } }
        }
        let seconds = time_t(now.timeIntervalSince1970 - days * 86_400)
        for item in paths.reversed() {
            var stamps = [timespec(tv_sec: seconds, tv_nsec: 0), timespec(tv_sec: seconds, tv_nsec: 0)]
            precondition(utimensat(AT_FDCWD, item, &stamps, AT_SYMLINK_NOFOLLOW) == 0, "utimensat \(item)")
        }
    }

    func lock(_ path: String, mode: mode_t) {
        locked.append(path)
        precondition(chmod(at(path).path, mode) == 0, "chmod \(path)")
    }

    func freeze(_ path: String) {
        frozen.append(path)
        precondition(chflags(at(path).path, UInt32(UF_IMMUTABLE)) == 0, "chflags \(path)")
    }

    func unlockAll() {
        for path in frozen { chflags(at(path).path, 0) }
        for path in locked { chmod(at(path).path, 0o755) }
        frozen = []
        locked = []
    }

    func destroy() {
        unlockAll()
        try? fm.removeItem(at: base)
    }

    @discardableResult
    func app(_ name: String, id: String, in dir: String = "root/Applications", executable: String? = nil, nested: [String] = [], labels: [String] = [],
             team: String = "", groups: [String] = [], org: String = "", extra: [String: Any] = [:]) -> AppIdentity {
        let bundle = "\(dir)/\(name).app"
        let program = executable ?? name
        var info: [String: Any] = ["CFBundleIdentifier": id, "CFBundleName": name, "CFBundleExecutable": program, "CFBundleShortVersionString": "1.0"]
        if !labels.isEmpty { info["SMPrivilegedExecutables"] = Dictionary(uniqueKeysWithValues: labels.map { ($0, "anchor apple") }) }
        info.merge(extra) { _, new in new }
        plist(bundle + "/Contents/Info.plist", info)
        file(bundle + "/Contents/MacOS/" + program)
        for nestedID in nested {
            plist("\(bundle)/Contents/Library/LoginItems/\(nestedID).app/Contents/Info.plist", ["CFBundleIdentifier": nestedID])
        }
        var identity = AppIdentity.read(at: at(bundle), signed: false)!
        identity.teamID = team
        identity.groups = groups
        identity.organization = org
        return identity
    }

    func plain(_ name: String, id: String, names: [String]? = nil, in dir: String = "root/Applications") -> AppIdentity {
        folder("\(dir)/\(name).app/Contents")
        return AppIdentity(url: at("\(dir)/\(name).app"), bundleID: id, names: names ?? [name])
    }

    func roots(pkgutil: @escaping ([String]) -> String? = { _ in nil }, known: [String] = []) -> AppRoots {
        let ids = Set(known.map { $0.lowercased() })
        return AppRoots(home: at("home"), root: at("root"), userCache: at("cache"), userTemp: at("temp"), caskrooms: [at("root/opt/homebrew/Caskroom")],
                        pkgutil: pkgutil, isKnownApp: { ids.contains($0.lowercased()) })
    }

    func footprint(_ installed: [AppIdentity], system: [AppIdentity] = [], pkgutil: @escaping ([String]) -> String? = { _ in nil }, known: [String] = []) -> AppFootprint {
        AppFootprint(roots: roots(pkgutil: pkgutil, known: known), installed: installed, system: system)
    }

    func scan(_ footprint: AppFootprint, _ app: AppIdentity) -> [String: Leftover] {
        Dictionary(footprint.scan(app).map { (rel($0.url), $0) }, uniquingKeysWith: { first, _ in first })
    }
}

final class FakePkgutil {
    var calls: [[String]] = []
    let table: [[String]: String]

    init(_ table: [[String]: String]) { self.table = table }

    func run(_ arguments: [String]) -> String? {
        calls.append(arguments)
        return table[arguments]
    }
}

func expect(_ found: [String: Leftover], _ expected: [String: Bool], _ label: String) {
    var problems: [String] = []
    for (path, selected) in expected {
        guard let item = found[path] else {
            problems.append("missing \(path)")
            continue
        }
        if item.preselected != selected { problems.append("\(path) preselected=\(item.preselected)") }
    }
    problems += found.keys.filter { expected[$0] == nil }.map { "unexpected \($0)" }
    precondition(problems.isEmpty, "\(label): " + problems.sorted().joined(separator: "; "))
}

func check(_ found: [String: Leftover], _ path: String, _ reason: LeftoverReason, _ kind: LeftoverKind) {
    guard let item = found[path] else { preconditionFailure("missing \(path)") }
    precondition(item.reason == reason, "\(path) reason \(item.reason)")
    precondition(item.kind == kind, "\(path) kind \(item.kind)")
}

func isHelper(_ reason: LeftoverReason) -> Bool {
    if case .helper = reason { return true }
    return false
}

func names(_ apps: [AppIdentity]) -> [String] { apps.map(\.displayName) }

@main
enum UninstallerTests {
    static func main() {
        words()
        slack()
        vendors()
        ownership()
        links()
        jobs()
        receipts()
        casks()
        inventory()
        trash()
        orphans()
        search()
        print("uninstaller: ok")
    }

    static func words() {
        precondition(AppNames.orphanID("com.gone.app.plist") == "com.gone.app")
        precondition(AppNames.orphanID("ABCDE12345.com.gone.app") == "com.gone.app")
        precondition(AppNames.orphanID("group.com.gone.app") == "com.gone.app")
        precondition(AppNames.orphanID("com.gone.app.E1B2C3D4-0000-4000-8000-0000000000BB.plist") == "com.gone.app")
        precondition(AppNames.orphanID("com.gone.app.savedState") == "com.gone.app")
        precondition(AppNames.orphanID("Dropbox") == nil && AppNames.orphanID("loginwindow.plist") == nil)
        precondition(AppNames.orphanID("jetbrains.rd.243.plist") == nil && AppNames.orphanID("main.kts.compiled.cache") == nil)
        precondition(AppNames.orphanID("su.nagornyi.Yandex-Music-For-Safari") == "su.nagornyi.Yandex-Music-For-Safari" && AppNames.orphanID("com.gone") == nil)
        precondition(AppNames.processName("Slack_E1B2C3D4-0000-4000-8000-0000000000CC.plist") == "Slack")
        precondition(AppNames.processName("Slack-2024-01-01-000000.ips") == "Slack")
        precondition(AppNames.processName("frame-2024-01-01-155339.000.ips") == "frame")
        precondition(AppNames.processName("m1b.bin-2024-01-01-233002.ips") == "m1b.bin")
        precondition(AppNames.processName("Slack_2024-01-01-000000_Mac.diag") == "Slack")
        precondition(AppNames.processName("claude-ios-sim") == nil && AppNames.processName("Slack.plist") == nil)
        precondition(AppNames.processName("-2024-01-01-000000.ips") == nil && AppNames.processName("Slack_E1B2C3D4.plist") == nil)
        precondition(AppNames.orphanTitle("com.gone.app") == "Gone")
        precondition(AppNames.orphanTitle("com.big-corp.photo-editor.helper") == "Photo Editor")
        precondition(AppNames.dottedPrefixes("a.b.c") == ["a.b.c", "a.b", "a"])
        precondition(AppNames.idForms("ABCDE12345.group.com.x.y") == ["abcde12345.group.com.x.y", "group.com.x.y", "com.x.y"])
        for junk in ["", "go", "ab", "helper", "support", "icloud", "mobilesync", "addressbook", "dock"] {
            precondition(!AppNames.usable(AppNames.squash(junk)), junk)
        }
        precondition(AppNames.squash("-") == "" && AppNames.squash(" _ ") == "")
        for fine in ["微信", "网易云音乐", "ひらがな", "슬랙", "Notion Calendar"] {
            precondition(!AppNames.squash(fine).isEmpty && AppNames.usable(AppNames.squash(fine)), fine)
        }
        precondition(AppNames.vendors(bundleID: "com.apple.Notes", organization: "Apple Inc") == [])
        precondition(AppNames.vendors(bundleID: "com.google.Chrome", organization: "Google LLC") == ["google"])
        precondition(AppNames.vendors(bundleID: "com.github.thing", organization: "GitHub, Inc.") == [])
        precondition(AppNames.vendors(bundleID: "io.x.app", organization: "The Foo Company") == ["Foo"])
        precondition(AppInventory.isInTrash(URL(fileURLWithPath: "/Users/a/.Trash/A.app")) && AppInventory.isInTrash(URL(fileURLWithPath: "/Volumes/V/.Trashes/501/A.app")))
        precondition(!AppInventory.isInTrash(URL(fileURLWithPath: "/Applications/A.app")))
        let live = AppRoots.live
        precondition(live.home == FileManager.default.homeDirectoryForCurrentUser && live.userCache != nil && live.userTemp != nil)
    }

    static func slack() {
        let w = World()
        defer { w.destroy() }
        let slack = w.app("Slack", id: "com.tinyspeck.slackmacgap", nested: ["com.tinyspeck.slackmacgap.helper", "org.sparkle-project.Sparkle.Autoupdate", "com.github.Electron.helper"],
                          team: "BQR82RBBHL", groups: ["BQR82RBBHL.com.tinyspeck.slackmacgap"], org: "Slack Technologies")
        let dropbox = w.app("Dropbox", id: "com.getdropbox.dropbox")
        precondition(slack.nestedIDs == ["com.tinyspeck.slackmacgap.helper"], "\(slack.nestedIDs)")
        let lib = "home/Library"
        let id = "com.tinyspeck.slackmacgap"
        let uuid = "E1B2C3D4-0000-4000-8000-000000000001"
        let byHost = "\(lib)/Preferences/ByHost/\(id).E1B2C3D4-0000-4000-8000-0000000000AA.plist"
        let agent = "\(lib)/LaunchAgents/\(id).agent.plist"
        let expected: [String: Bool] = [
            "root/Applications/Slack.app": true,
            "\(lib)/Application Support/Slack": true,
            "\(lib)/Application Support/\(id)": true,
            "\(lib)/Application Support/Slack Beta": false,
            "\(lib)/Application Support/CrashReporter/Slack_E1B2C3D4-0000-4000-8000-0000000000CC.plist": true,
            "\(lib)/Caches/\(id)": true,
            "\(lib)/Caches/\(id).ShipIt": true,
            "\(lib)/Preferences/\(id).plist": true,
            byHost: true,
            "\(lib)/Containers/\(id)": true,
            "\(lib)/Containers/\(uuid)": true,
            "\(lib)/Group Containers/BQR82RBBHL.\(id)": true,
            "\(lib)/Group Containers/BQR82RBBHL.shared.extras": false,
            "\(lib)/Group Containers/group.\(id).shared": true,
            "\(lib)/Application Scripts/\(id)": true,
            "\(lib)/Saved Application State/\(id).savedState": true,
            "\(lib)/HTTPStorages/\(id)": true,
            "\(lib)/WebKit/\(id)": true,
            "\(lib)/Cookies/\(id).binarycookies": true,
            "\(lib)/Logs/Slack": true,
            "\(lib)/Logs/DiagnosticReports/Slack-2024-01-01-000000.ips": true,
            "root/Library/Logs/DiagnosticReports/Slack_2024-01-01-000000_Mac.diag": true,
            agent: true,
            "cache/\(id)": true,
            "temp/\(id)": true,
            "root/Library/Application Support/Slack": true,
            "root/Library/Caches/\(id)": true,
            "root/Library/Preferences/\(id).plist": true,
            "root/usr/local/bin/slack": true,
        ]
        for path in expected.keys where !path.hasSuffix(".app") && !path.hasPrefix("root/usr") { w.node(path) }
        w.plist("\(lib)/Containers/\(uuid)/.com.apple.containermanagerd.metadata.plist", ["MCMMetadataIdentifier": "\(id).helper"])
        w.plist(agent, ["Label": "\(id).agent", "ProgramArguments": ["/usr/bin/true"]])
        w.file("root/Applications/Slack.app/Contents/Resources/bin/slack")
        w.link("root/usr/local/bin/slack", to: w.at("root/Applications/Slack.app/Contents/Resources/bin/slack").path)
        let decoys = [
            "\(lib)/Application Support/Slackware", "\(lib)/Application Support/Dropbox", "\(lib)/Preferences/\(id)x.plist",
            "\(lib)/Preferences/org.sparkle-project.Sparkle.plist", "\(lib)/Preferences/com.github.Electron.plist",
            "\(lib)/Preferences/com.apple.finder.plist", "\(lib)/Preferences/com.getdropbox.dropbox.plist", "\(lib)/Group Containers/ZZZZZZZZZZ.slack",
            "\(lib)/Containers/E1B2C3D4-0000-4000-8000-000000000002", "\(lib)/Containers/E1B2C3D4-0000-4000-8000-000000000003",
            "\(lib)/Application Support/CrashReporter/Slack-helper_E1B2C3D4-0000-4000-8000-0000000000CD.plist",
            "\(lib)/Application Support/CrashReporter/Slackware_E1B2C3D4-0000-4000-8000-0000000000CE.plist",
            "\(lib)/Logs/DiagnosticReports/Slack-ios-sim-2024-01-01-000000.ips", "\(lib)/Logs/DiagnosticReports/Slackware-2024-01-01-000000.ips",
            "\(lib)/Logs/DiagnosticReports/Slack.txt",
        ]
        decoys.forEach(w.node)
        w.plist("\(lib)/Containers/E1B2C3D4-0000-4000-8000-000000000002/.com.apple.containermanagerd.metadata.plist", ["MCMMetadataIdentifier": "com.other.thing"])
        w.link("root/usr/local/bin/other", to: "/usr/bin/true")
        w.file("root/usr/local/bin/plain")

        let footprint = w.footprint([slack, dropbox])
        let found = w.scan(footprint, slack)
        expect(found, expected, "Slack")
        check(found, "root/Applications/Slack.app", .bundle, .app)
        check(found, "\(lib)/Application Support/Slack", .byName, .appData)
        check(found, "\(lib)/Application Support/Slack Beta", .related, .appData)
        check(found, "\(lib)/Application Support/\(id)", .byID(id), .appData)
        check(found, "\(lib)/Application Support/CrashReporter/Slack_E1B2C3D4-0000-4000-8000-0000000000CC.plist", .byName, .logs)
        check(found, "\(lib)/Caches/\(id).ShipIt", .byID(id), .caches)
        check(found, byHost, .byID(id), .preferences)
        check(found, "\(lib)/Containers/\(uuid)", .byID("\(id).helper"), .containers)
        check(found, "\(lib)/Group Containers/BQR82RBBHL.\(id)", .appGroup("BQR82RBBHL.\(id)"), .containers)
        check(found, "\(lib)/Group Containers/BQR82RBBHL.shared.extras", .related, .containers)
        check(found, "\(lib)/Cookies/\(id).binarycookies", .byID(id), .caches)
        check(found, "\(lib)/Logs/DiagnosticReports/Slack-2024-01-01-000000.ips", .byName, .logs)
        check(found, agent, .launchJob("\(id).agent"), .background)
        check(found, "root/usr/local/bin/slack", .cliLink, .install)
        precondition(found["root/usr/local/bin/slack"]?.isLink == true && found[agent]?.jobLabel == "\(id).agent")
        precondition(found.values.allSatisfy { !$0.needsAdmin && $0.sharedWith.isEmpty })
        let ordered = footprint.scan(slack)
        precondition(ordered.first?.reason == .bundle && ordered.map(\.kind) == ordered.map(\.kind).sorted())
        let attributes = try! FileManager.default.attributesOfItem(atPath: w.at("root/Applications/Slack.app").path)
        precondition(found["root/Applications/Slack.app"]?.inode == (attributes[.systemFileNumber] as! NSNumber).uint64Value)
        precondition(Int(found["root/Applications/Slack.app"]?.device ?? -1) == (attributes[.systemNumber] as! NSNumber).intValue)
        expect(w.scan(footprint, dropbox), [
            "root/Applications/Dropbox.app": true,
            "\(lib)/Application Support/Dropbox": true,
            "\(lib)/Preferences/com.getdropbox.dropbox.plist": true,
        ], "Dropbox")
    }

    static func vendors() {
        let w = World()
        defer { w.destroy() }
        let chrome = w.app("Google Chrome", id: "com.google.Chrome", team: "EQHXZ8M8AV", org: "Google LLC")
        let drive = w.app("Google Drive", id: "com.google.drivefs", team: "EQHXZ8M8AV", org: "Google LLC")
        let gadget = w.app("Gadget", id: "com.acme.gadget")
        let toolbox = w.app("Acme Toolbox", id: "com.acme.toolbox")
        let word = w.app("Word", id: "com.msoft.Word", team: "UBF8T346G9", groups: ["UBF8T346G9.shared"], org: "Msoft Corporation")
        let excel = w.app("Excel", id: "com.msoft.Excel", team: "UBF8T346G9", groups: ["UBF8T346G9.shared"], org: "Msoft Corporation")
        let twin = w.app("Twin", id: "com.twin.app")
        let twinHome = w.app("Twin", id: "com.twin.app", in: "home/Applications")
        let lib = "home/Library"
        for path in [
            "Application Support/Google/Chrome", "Application Support/Google/Drive", "Application Support/Google/Other", "Caches/Google/Chrome", "Caches/Google/Drive",
            "Application Support/Acme/Gadget", "Caches/Acme",
            "Group Containers/UBF8T346G9.shared", "Group Containers/UBF8T346G9.other",
            "Application Support/Msoft/Word", "Application Support/Msoft/Excel", "Application Support/Msoft/Common",
            "Containers/com.twin.app", "Application Support/Twin",
        ] { w.node("\(lib)/\(path)") }
        w.file("\(lib)/Application Support/Acme/Settings.json")

        let google = w.footprint([chrome, drive])
        expect(w.scan(google, chrome), [
            "root/Applications/Google Chrome.app": true,
            "\(lib)/Application Support/Google/Chrome": true,
            "\(lib)/Caches/Google/Chrome": true,
        ], "Chrome")
        check(w.scan(google, chrome), "\(lib)/Caches/Google/Chrome", .vendor, .caches)
        expect(w.scan(google, drive), [
            "root/Applications/Google Drive.app": true,
            "\(lib)/Application Support/Google/Drive": true,
            "\(lib)/Caches/Google/Drive": true,
        ], "Drive")

        let alone = w.scan(w.footprint([gadget]), gadget)
        expect(alone, [
            "root/Applications/Gadget.app": true,
            "\(lib)/Application Support/Acme": true,
            "\(lib)/Caches/Acme": true,
        ], "Gadget alone")
        check(alone, "\(lib)/Application Support/Acme", .vendor, .appData)
        expect(w.scan(w.footprint([gadget, toolbox]), gadget), [
            "root/Applications/Gadget.app": true,
            "\(lib)/Application Support/Acme/Gadget": true,
        ], "Gadget with sibling")

        let suite = w.footprint([word, excel])
        let wordFound = w.scan(suite, word)
        expect(wordFound, [
            "root/Applications/Word.app": true,
            "\(lib)/Group Containers/UBF8T346G9.shared": false,
            "\(lib)/Group Containers/UBF8T346G9.other": false,
            "\(lib)/Application Support/Msoft/Word": true,
        ], "Word")
        precondition(wordFound["\(lib)/Group Containers/UBF8T346G9.shared"]?.sharedWith == ["Excel"])
        precondition(wordFound["\(lib)/Group Containers/UBF8T346G9.other"]?.sharedWith == ["Excel"])
        check(wordFound, "\(lib)/Group Containers/UBF8T346G9.shared", .appGroup("UBF8T346G9.shared"), .containers)
        let excelFound = w.scan(suite, excel)
        expect(excelFound, [
            "root/Applications/Excel.app": true,
            "\(lib)/Group Containers/UBF8T346G9.shared": false,
            "\(lib)/Group Containers/UBF8T346G9.other": false,
            "\(lib)/Application Support/Msoft/Excel": true,
        ], "Excel")
        precondition(excelFound["\(lib)/Group Containers/UBF8T346G9.shared"]?.sharedWith == ["Word"])

        let twins = w.footprint([twin, twinHome])
        let twinFound = w.scan(twins, twin)
        expect(twinFound, [
            "root/Applications/Twin.app": true,
            "\(lib)/Containers/com.twin.app": false,
            "\(lib)/Application Support/Twin": false,
        ], "Twin")
        precondition(twinFound["\(lib)/Containers/com.twin.app"]?.sharedWith == ["Twin"])
        precondition(w.scan(twins, twinHome)["\(lib)/Containers/com.twin.app"]?.preselected == false)
    }

    static func ownership() {
        let w = World()
        defer { w.destroy() }
        let lib = "home/Library"

        let foo = w.app("Foo", id: "com.foo.app")
        let pro = w.app("Foo Pro", id: "com.foo.app.pro")
        for path in ["Preferences/com.foo.app.plist", "Preferences/com.foo.app.pro.plist", "Application Support/Foo", "Application Support/Foo Pro", "Caches/com.foo.app.helper"] {
            w.node("\(lib)/\(path)")
        }
        let family = w.footprint([foo, pro])
        expect(w.scan(family, foo), [
            "root/Applications/Foo.app": true,
            "\(lib)/Preferences/com.foo.app.plist": true,
            "\(lib)/Application Support/Foo": true,
            "\(lib)/Caches/com.foo.app.helper": true,
        ], "Foo")
        expect(w.scan(family, pro), [
            "root/Applications/Foo Pro.app": true,
            "\(lib)/Preferences/com.foo.app.pro.plist": true,
            "\(lib)/Application Support/Foo Pro": true,
        ], "Foo Pro")

        let nest = w.app("Nest", id: "com.nest.main", nested: ["com.nest.helper", "com.nestlabs.thermo", "org.sparkle-project.Sparkle.Updater", "com.github.Electron.helper", "com.apple.inner"])
        precondition(nest.nestedIDs == ["com.apple.inner", "com.nest.helper", "com.nestlabs.thermo"], "\(nest.nestedIDs)")
        precondition(nest.strongIDs == ["com.nest.main", "com.nest.helper"] && nest.looseIDs == ["com.apple.inner", "com.nestlabs.thermo"], "\(nest.strongIDs) \(nest.looseIDs)")
        for path in [
            "com.nest.main.plist", "com.nest.helper.plist", "com.nestlabs.thermo.plist", "com.apple.inner.plist",
            "org.sparkle-project.Sparkle.Updater.plist", "com.github.Electron.helper.plist",
        ] { w.node("\(lib)/Preferences/\(path)") }
        expect(w.scan(w.footprint([nest]), nest), [
            "root/Applications/Nest.app": true,
            "\(lib)/Preferences/com.nest.main.plist": true,
            "\(lib)/Preferences/com.nest.helper.plist": true,
            "\(lib)/Preferences/com.nestlabs.thermo.plist": false,
        ], "Nest")

        let junkNames = ["Go", "Helper", "Dock", "iCloud", "MobileSync", "AddressBook", "Support"]
        let junk = AppIdentity(url: w.at("root/Applications/Go.app"), bundleID: "com.junk.thing", names: junkNames)
        w.folder("root/Applications/Go.app/Contents")
        for name in junkNames { w.node("\(lib)/Application Support/\(name)") }
        w.node("\(lib)/Preferences/com.junk.thing.plist")
        expect(w.scan(w.footprint([junk]), junk), [
            "root/Applications/Go.app": true,
            "\(lib)/Preferences/com.junk.thing.plist": true,
        ], "Junk names")

        let notes = w.plain("Notes", id: "com.third.notes")
        let music = w.plain("Music", id: "com.third.music")
        let appleNotes = w.plain("Notes", id: "com.apple.Notes", in: "root/System/Applications")
        let appleMusic = w.plain("Music", id: "com.apple.Music", in: "root/System/Applications")
        for path in ["Application Support/Notes", "Caches/Music", "Containers/com.apple.Notes", "Preferences/com.third.notes.plist", "Preferences/com.apple.Music.plist"] {
            w.node("\(lib)/\(path)")
        }
        expect(w.scan(w.footprint([notes, music], system: [appleNotes, appleMusic]), notes), [
            "root/Applications/Notes.app": true,
            "\(lib)/Preferences/com.third.notes.plist": true,
        ], "Notes next to Apple Notes")
        expect(w.scan(w.footprint([notes, music]), notes), [
            "root/Applications/Notes.app": true,
            "\(lib)/Application Support/Notes": true,
            "\(lib)/Preferences/com.third.notes.plist": true,
        ], "Notes without Apple apps")

        let pages = w.app("Pages", id: "com.apple.iWork.Pages")
        for path in ["Containers/com.apple.iWork.Pages", "Preferences/com.apple.iWork.Pages.plist", "Preferences/com.apple.finder.plist", "Containers/com.apple.Safari", "Application Support/Pages"] {
            w.node("\(lib)/\(path)")
        }
        expect(w.scan(w.footprint([pages]), pages), [
            "root/Applications/Pages.app": true,
            "\(lib)/Containers/com.apple.iWork.Pages": true,
            "\(lib)/Preferences/com.apple.iWork.Pages.plist": true,
            "\(lib)/Application Support/Pages": true,
        ], "Pages")

        let wechat = w.app("微信", id: "com.tencent.xinWeChat")
        let dash = AppIdentity(url: w.at("root/Applications/-.app"), bundleID: "com.dash.app", names: ["-", "_", " - "])
        w.folder("root/Applications/-.app/Contents")
        for name in ["微信", "-", "_"] { w.node("\(lib)/Application Support/\(name)") }
        let scripts = w.footprint([wechat, dash])
        expect(w.scan(scripts, wechat), ["root/Applications/微信.app": true, "\(lib)/Application Support/微信": true], "CJK name")
        expect(w.scan(scripts, dash), ["root/Applications/-.app": true], "Dash name")

        let legacy = w.app("Legacy", id: "")
        w.node("\(lib)/Application Support/Legacy")
        expect(w.scan(w.footprint([legacy]), legacy), ["root/Applications/Legacy.app": true, "\(lib)/Application Support/Legacy": false], "No bundle id")
    }

    static func links() {
        let w = World()
        defer { w.destroy() }
        let slinky = w.app("Slinky", id: "com.slink.app")
        w.big("outside/payload/big.bin")
        w.link("home/Library/Application Support/com.slink.app", to: w.at("outside/payload").path)
        w.big("outside/hard/a.bin")
        try! FileManager.default.linkItem(at: w.at("outside/hard/a.bin"), to: w.at("outside/hard/b.bin"))
        let found = w.scan(w.footprint([slinky]), slinky)
        expect(found, ["root/Applications/Slinky.app": true, "home/Library/Application Support/com.slink.app": true], "Slinky")
        precondition(found["home/Library/Application Support/com.slink.app"]?.isLink == true)
        let linkSize = AppFootprint.allocatedSize(of: w.at("home/Library/Application Support/com.slink.app"))
        let targetSize = AppFootprint.allocatedSize(of: w.at("outside/payload"))
        let hardSize = AppFootprint.allocatedSize(of: w.at("outside/hard"))
        precondition(linkSize < 100_000 && targetSize >= 1_000_000, "link \(linkSize) target \(targetSize)")
        precondition(hardSize >= 1_000_000 && hardSize < 1_500_000, "hard \(hardSize)")
        precondition(AppFootprint.allocatedSize(of: w.at("outside/missing")) == 0)
    }

    static func jobs() {
        let w = World()
        defer { w.destroy() }
        let jobby = w.app("Jobby", id: "com.jobby.app", labels: ["com.jobby.helper", "com.jobby.helper2"])
        let lib = "home/Library"
        let tools = w.at("root/Library/PrivilegedHelperTools").path
        w.plist("\(lib)/LaunchAgents/org.x.sync.plist", ["Label": "org.x.sync", "AssociatedBundleIdentifiers": ["com.jobby.app"], "ProgramArguments": ["/usr/bin/true"]])
        w.plist("\(lib)/LaunchAgents/com.jobby.app.updater.plist", ["Label": "com.jobby.app.updater"])
        w.plist("\(lib)/LaunchAgents/org.y.thing.plist", ["Label": "org.y.thing", "ProgramArguments": [w.at("root/Applications/Jobby.app/Contents/MacOS/Jobby").path, "--agent"]])
        w.file("\(lib)/Application Support/Jobby/bin/cleaner")
        w.file("\(lib)/Application Support/Elsewhere/bin/cleaner")
        w.plist("\(lib)/LaunchAgents/org.q.cleaner.plist", ["Label": "org.q.cleaner", "Program": w.at("\(lib)/Application Support/Jobby/bin/cleaner").path])
        w.plist("\(lib)/LaunchAgents/org.r.cleaner.plist", ["Label": "org.r.cleaner", "Program": w.at("\(lib)/Application Support/Elsewhere/bin/cleaner").path])
        w.file("\(lib)/LaunchAgents/com.jobby.app.broken.plist", "not a property list")
        w.plist("root/Library/LaunchAgents/org.z.other.plist", ["Label": "org.z.other", "ProgramArguments": ["/usr/bin/true"]])
        w.plist("root/Library/LaunchDaemons/com.jobby.helper.plist", ["Label": "com.jobby.helper", "Program": "\(tools)/com.jobby.helper"])
        w.file("root/Library/PrivilegedHelperTools/com.jobby.helper")
        w.plist("root/Library/LaunchDaemons/org.v.daemon.plist", ["Label": "org.v.daemon", "ProgramArguments": ["\(tools)/com.jobby.helper2"]])
        w.file("root/Library/PrivilegedHelperTools/com.jobby.helper2")
        w.plist("root/Library/LaunchDaemons/org.w.daemon.plist", ["Label": "org.w.daemon", "ProgramArguments": ["\(tools)/org.w.tool"]])
        w.file("root/Library/PrivilegedHelperTools/org.w.tool")

        let footprint = w.footprint([jobby])
        let root = getuid() == 0
        if !root {
            w.lock("root/Library/LaunchDaemons", mode: 0o555)
            w.lock("root/Library/PrivilegedHelperTools", mode: 0o555)
        }
        let found = w.scan(footprint, jobby)
        w.unlockAll()
        expect(found, [
            "root/Applications/Jobby.app": true,
            "\(lib)/LaunchAgents/org.x.sync.plist": true,
            "\(lib)/LaunchAgents/com.jobby.app.updater.plist": true,
            "\(lib)/LaunchAgents/org.y.thing.plist": true,
            "\(lib)/LaunchAgents/org.q.cleaner.plist": true,
            "\(lib)/Application Support/Jobby": true,
            "\(lib)/LaunchAgents/com.jobby.app.broken.plist": true,
            "root/Library/LaunchDaemons/com.jobby.helper.plist": true,
            "root/Library/PrivilegedHelperTools/com.jobby.helper": true,
            "root/Library/LaunchDaemons/org.v.daemon.plist": true,
            "root/Library/PrivilegedHelperTools/com.jobby.helper2": true,
        ], "Jobby")
        check(found, "\(lib)/LaunchAgents/org.x.sync.plist", .launchJob("org.x.sync"), .background)
        check(found, "\(lib)/LaunchAgents/com.jobby.app.updater.plist", .launchJob("com.jobby.app.updater"), .background)
        check(found, "\(lib)/LaunchAgents/org.y.thing.plist", .launchJob("org.y.thing"), .background)
        check(found, "\(lib)/LaunchAgents/org.q.cleaner.plist", .launchJob("org.q.cleaner"), .background)
        check(found, "\(lib)/LaunchAgents/com.jobby.app.broken.plist", .launchJob("com.jobby.app.broken"), .background)
        check(found, "root/Library/LaunchDaemons/com.jobby.helper.plist", .helper("com.jobby.helper"), .background)
        precondition(isHelper(found["root/Library/PrivilegedHelperTools/com.jobby.helper"]?.reason ?? .byName))
        precondition(isHelper(found["root/Library/PrivilegedHelperTools/com.jobby.helper2"]?.reason ?? .byName))
        precondition(isHelper(found["root/Library/LaunchDaemons/org.v.daemon.plist"]?.reason ?? .byName))
        precondition(found["root/Library/LaunchDaemons/com.jobby.helper.plist"]?.isDaemon == true && found["root/Library/LaunchDaemons/org.v.daemon.plist"]?.isDaemon == true)
        precondition(found["\(lib)/LaunchAgents/org.x.sync.plist"]?.isDaemon == false && found["\(lib)/LaunchAgents/org.x.sync.plist"]?.jobLabel == "org.x.sync")
        for path in found.keys where path.hasPrefix("root/Library/") {
            precondition(found[path]?.needsAdmin == !root, "\(path) needsAdmin")
        }
        for path in found.keys where !path.hasPrefix("root/Library/") { precondition(found[path]?.needsAdmin == false, "\(path) needsAdmin") }

        w.freeze("root/Library/PrivilegedHelperTools")
        let frozen = w.scan(footprint, jobby)
        w.unlockAll()
        precondition(frozen["root/Library/PrivilegedHelperTools/com.jobby.helper"]?.needsAdmin == false, "a folder the system protects is not an admin matter")
    }

    static func receipts() {
        let w = World()
        defer { w.destroy() }
        let packed = w.app("Packed", id: "com.packed.app")
        let one = w.app("Suite One", id: "com.suite.one")
        let two = w.app("Suite Two", id: "com.suite.two")
        let appley = w.app("Appley", id: "com.appley.app")
        let fallback = w.app("Fallback Tool", id: "com.fallback.tool")
        let loner = w.app("Fallback Loner", id: "com.loner.app")
        w.node("root/Library/Application Support/FallbackData")
        w.file("root/Library/Application Support/Packed/data/deep.bin")
        w.node("root/Library/Application Support/PackedExtra")
        w.node("root/Library/Application Support/Suite")
        w.file("root/Library/LaunchDaemons/com.packed.daemon.plist")
        w.file("root/Library/PrivilegedHelperTools/com.packed.helper")
        w.file("root/Library/Preferences/com.apple.finder.plist")
        w.file("root/usr/local/bin/packed")
        w.file("root/private/etc/packed.conf")
        let files = [
            "Applications/Packed.app", "Applications/Packed.app/Contents", "Library/Application Support/Packed", "Library/Application Support/Packed/data/deep.bin",
            "Library/LaunchDaemons/com.packed.daemon.plist", "Library/PrivilegedHelperTools/com.packed.helper", "Library/Preferences/com.apple.finder.plist",
            "usr/local/bin/packed", "private/etc/packed.conf",
        ].joined(separator: "\n")
        let fake = FakePkgutil([
            ["--file-info", packed.url.path]: "volume: /\npath: \(packed.url.path)\n\npkgid: com.packed.pkg\npkg-version: 1.0\n\npkgid: com.packed.extra\n\npkgid: com.packed.usb\n\npkgid: com.apple.pkg.Foo\n",
            ["--pkg-info", "com.packed.pkg"]: "package-id: com.packed.pkg\nversion: 1.0\nvolume: /\nlocation: \ninstall-time: 1\n",
            ["--files", "com.packed.pkg"]: files,
            ["--pkg-info", "com.packed.extra"]: "package-id: com.packed.extra\nvolume: /\nlocation: Library\n",
            ["--files", "com.packed.extra"]: "Application Support/PackedExtra\n",
            ["--pkg-info", "com.packed.usb"]: "package-id: com.packed.usb\nvolume: /Volumes/USB\nlocation: \n",
            ["--files", "com.packed.usb"]: "Library/Application Support/PackedUsb\n",
            ["--file-info", one.url.path]: "pkgid: com.suite.pkg\n",
            ["--file-info", two.url.path]: "pkgid: com.suite.pkg\n",
            ["--pkg-info", "com.suite.pkg"]: "volume: /\nlocation: \n",
            ["--files", "com.suite.pkg"]: "Applications/Suite One.app\nApplications/Suite Two.app\nLibrary/Application Support/Suite\n",
            ["--file-info", appley.url.path]: "pkgid: com.apple.pkg.Appley\n",
            ["--pkgs"]: "com.apple.pkg.Base\ncom.fallback.pkg.tool\ncom.fallback.other\ncom.unrelated.pkg\n",
            ["--pkg-info", "com.fallback.pkg.tool"]: "volume: /\nlocation: \n",
            ["--files", "com.fallback.pkg.tool"]: "Applications/Fallback Tool.app\nLibrary/Application Support/FallbackData\n",
            ["--pkg-info", "com.fallback.other"]: "volume: /\nlocation: Applications\n",
            ["--files", "com.fallback.other"]: "Other.app\n",
        ])
        let footprint = w.footprint([packed, one, two, appley, fallback, loner], pkgutil: fake.run)
        _ = footprint.orphans()
        precondition(fake.calls.isEmpty, "pkgutil is asked only when an app is scanned")

        let found = w.scan(footprint, packed)
        expect(found, [
            "root/Applications/Packed.app": true,
            "root/Library/Application Support/Packed": true,
            "root/Library/Application Support/PackedExtra": true,
            "root/Library/LaunchDaemons/com.packed.daemon.plist": true,
            "root/Library/PrivilegedHelperTools/com.packed.helper": true,
            "root/var/db/receipts/com.packed.pkg.plist": true,
            "root/var/db/receipts/com.packed.extra.plist": true,
        ], "Packed")
        check(found, "root/Library/Application Support/Packed", .receipt("com.packed.pkg"), .appData)
        check(found, "root/Library/Application Support/PackedExtra", .receipt("com.packed.extra"), .appData)
        check(found, "root/var/db/receipts/com.packed.pkg.plist", .receipt("com.packed.pkg"), .install)
        precondition(found["root/var/db/receipts/com.packed.pkg.plist"]?.packageID == "com.packed.pkg" && found["root/var/db/receipts/com.packed.pkg.plist"]?.needsAdmin == true)
        precondition(fake.calls.count == 6 && fake.calls.filter { $0[0] == "--files" }.count == 2, "\(fake.calls)")
        precondition(!fake.calls.contains { $0.contains("com.apple.pkg.Foo") } && !fake.calls.contains { $0 == ["--files", "com.packed.usb"] })

        let shared = w.scan(footprint, one)
        expect(shared, [
            "root/Applications/Suite One.app": true,
            "root/Library/Application Support/Suite": false,
            "root/var/db/receipts/com.suite.pkg.plist": false,
        ], "Suite One")
        precondition(shared["root/Library/Application Support/Suite"]?.sharedWith == ["Suite Two"])
        precondition(shared["root/var/db/receipts/com.suite.pkg.plist"]?.sharedWith == ["Suite Two"])
        precondition(fake.calls.count == 9)

        expect(w.scan(footprint, appley), ["root/Applications/Appley.app": true], "Appley")
        precondition(fake.calls.count == 10)

        let rescued = w.scan(footprint, fallback)
        expect(rescued, [
            "root/Applications/Fallback Tool.app": true,
            "root/Library/Application Support/FallbackData": true,
            "root/var/db/receipts/com.fallback.pkg.tool.plist": true,
        ], "Fallback Tool")
        check(rescued, "root/Library/Application Support/FallbackData", .receipt("com.fallback.pkg.tool"), .appData)
        precondition(fake.calls.count == 16 && fake.calls.filter { $0 == ["--pkgs"] }.count == 1, "\(fake.calls)")
        precondition(!fake.calls.contains { $0.contains("com.unrelated.pkg") || $0.contains("com.apple.pkg.Base") })

        expect(w.scan(footprint, loner), ["root/Applications/Fallback Loner.app": true], "Fallback Loner")
        precondition(fake.calls.count == 17 && fake.calls.filter { $0 == ["--pkgs"] }.count == 1)
    }

    static func casks() {
        let w = World()
        defer { w.destroy() }
        let lib = "home/Library"
        let caskroom = "root/opt/homebrew/Caskroom"
        let brewed = w.app("Brewed", id: "org.brewed.app")
        let two = w.app("Brewed Two", id: "org.brewed2.app")
        let quitter = w.app("Quitter", id: "org.quitter.app")
        let staged = w.app("Staged", id: "org.staged.app")
        let slack = w.app("Slack", id: "com.tinyspeck.slackmacgap")
        for path in [
            "\(lib)/Application Support/BrewedSupportFiles", "\(lib)/Application Support/Brewed", "\(lib)/Preferences/org.brewed.a.plist",
            "\(lib)/Preferences/org.brewed.b.plist", "\(lib)/Preferences/other.brewed.c.plist", "root/Library/Application Support/BrewedGlobal",
            "home/Documents/Brewed", "home/Documents/Brewed2", "\(lib)/Mobile Documents/iCloud~org~brewed", "home/.brewed",
            "\(lib)/Preferences/com.apple.finder.plist", "\(lib)/Application Support/Slack", "\(lib)/Caches/zapped-cache",
        ] { w.node(path) }
        w.file("\(lib)/Keychains/brewed.keychain-db")
        let zap = [
            "~/Library/Application Support/BrewedSupportFiles", "~/Library/Application Support/Brewed", "~/Library/Preferences/org.brewed.*.plist",
            "/Library/Application Support/BrewedGlobal", "~/Documents/Brewed", "~/Documents/Brew*", "~/Library/Mobile Documents/iCloud~org~brewed",
            "~/Library/Application Support/../Mobile Documents/iCloud~org~brewed", "~/Library/../Documents/Brewed", "~/.brewed",
            "~/Library/Keychains/brewed.keychain-db", "~/Library/Preferences/com.apple.finder.plist", "~/Library/Application Support/Slack",
            "~/Library/Application Support", "~/Library/Caches/brewed-missing", "/usr/local/brewed", "/etc/brewed",
        ]
        w.json("\(caskroom)/brewed/.metadata/INSTALL_RECEIPT.json", ["uninstall_artifacts": [["app": ["Brewed.app"]], ["zap": [["trash": zap]]]]])
        w.link("\(caskroom)/brewed/1.0/Brewed.app", to: w.at("root/Applications/Brewed.app").path)
        w.json("\(caskroom)/brewed2/.metadata/2.0/20240101000000.000/Casks/brewed2.json",
               ["artifacts": [["app": [["target": "Brewed Two.app"]]], ["uninstall": [["quit": ["org.brewed2.app"]]]], ["zap": [["trash": "~/Library/Caches/zapped-cache"]]]]])
        w.json("\(caskroom)/quitter/.metadata/INSTALL_RECEIPT.json", ["uninstall_artifacts": [["app": ["Quitter Original.app"]], ["uninstall": [["quit": "org.quitter.app"]]]]])
        w.link("\(caskroom)/staged/1.0/Staged.app", to: w.at("root/Applications/Staged.app").path)
        w.json("\(caskroom)/other/.metadata/INSTALL_RECEIPT.json", ["uninstall_artifacts": [["app": ["Nothing.app"]]]])

        let footprint = w.footprint([brewed, two, quitter, staged, slack])
        let found = w.scan(footprint, brewed)
        expect(found, [
            "root/Applications/Brewed.app": true,
            "\(caskroom)/brewed": true,
            "\(lib)/Application Support/BrewedSupportFiles": true,
            "\(lib)/Application Support/Brewed": true,
            "\(lib)/Preferences/org.brewed.a.plist": true,
            "\(lib)/Preferences/org.brewed.b.plist": true,
            "root/Library/Application Support/BrewedGlobal": true,
        ], "Brewed")
        check(found, "\(caskroom)/brewed", .homebrew("brewed"), .install)
        check(found, "\(lib)/Application Support/BrewedSupportFiles", .homebrew("brewed"), .appData)
        check(found, "\(lib)/Preferences/org.brewed.a.plist", .homebrew("brewed"), .preferences)
        expect(w.scan(footprint, two), ["root/Applications/Brewed Two.app": true, "\(caskroom)/brewed2": true, "\(lib)/Caches/zapped-cache": true], "Brewed Two")
        expect(w.scan(footprint, quitter), ["root/Applications/Quitter.app": true, "\(caskroom)/quitter": true], "Quitter")
        expect(w.scan(footprint, staged), ["root/Applications/Staged.app": true, "\(caskroom)/staged": true], "Staged")
        let slackFound = w.scan(footprint, slack)
        expect(slackFound, ["root/Applications/Slack.app": true, "\(lib)/Application Support/Slack": true], "Slack beside casks")
    }

    static func inventory() {
        let w = World()
        defer { w.destroy() }
        w.app("Alpha", id: "com.alpha.app")
        w.app("Beta", id: "com.beta.app", in: "root/Applications/Suite")
        w.app("Gamma", id: "com.gamma.app", in: "root/Applications/Deep/Deeper")
        w.app("Terminal", id: "com.apple.Terminal", in: "root/Applications/Utilities")
        w.app("Tool", id: "com.tool.app", in: "root/Applications/Utilities")
        w.app("Setty", id: "com.setty.app", in: "root/Applications/Setapp")
        w.app("Pages", id: "com.apple.iWork.Pages")
        w.app("Safari", id: "com.apple.Safari")
        w.app("Install macOS Foo", id: "com.apple.InstallAssistant.Foo")
        w.app("pika-tools", id: "com.pesotchi.pika-tools")
        w.app("Sys", id: "com.apple.Sys", in: "root/System/Applications")
        w.app("Notes", id: "com.apple.Notes", in: "root/System/Applications")
        w.app("Disk Utility", id: "com.apple.DiskUtility", in: "root/System/Applications/Utilities")
        w.app("Finder", id: "com.apple.finder", in: "root/System/Library/CoreServices")
        w.link("root/Applications/LinkedSys.app", to: w.at("root/System/Applications/Sys.app").path)
        w.app("Dupe", id: "com.dupe.app")
        w.link("home/Applications/DupeLink.app", to: w.at("root/Applications/Dupe.app").path)
        w.app("Home", id: "com.home.app", in: "home/Applications")
        w.file("root/Applications/readme.txt")
        let roots = w.roots()
        precondition(names(AppInventory.installed(roots)) == ["Alpha", "Beta", "Dupe", "Home", "Install macOS Foo", "Pages", "Safari", "Setty", "Tool"], "\(names(AppInventory.installed(roots)))")
        precondition(Set(names(AppInventory.system(roots))) == ["Sys", "Notes", "Disk Utility", "Finder", "Pages", "Safari", "Install macOS Foo", "Terminal"], "\(names(AppInventory.system(roots)))")
        precondition(AppFootprint(roots: roots).installed.count == 9)

        let contents = "root/Applications/Big.app/Contents"
        w.app("Big", id: "com.big.app", executable: "BigExe", nested: ["com.big.app.login"], labels: ["com.big.app.other"],
              extra: ["CFBundleDisplayName": "Big App", "CFBundleShortVersionString": "2.5"])
        w.plist(contents + "/XPCServices/Svc.xpc/Contents/Info.plist", ["CFBundleIdentifier": "com.big.app.svc", "CFBundleExecutable": "SvcExe"])
        w.plist(contents + "/PlugIns/Share.appex/Contents/Info.plist", ["CFBundleIdentifier": "com.big.app.share"])
        w.plist(contents + "/PlugIns/Var.appex/Contents/Info.plist", ["CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)"])
        w.plist(contents + "/Frameworks/Big Helper.app/Contents/Info.plist", ["CFBundleIdentifier": "com.big.app.helper"])
        w.plist(contents + "/Frameworks/Sparkle.framework/Versions/B/Updater.app/Contents/Info.plist", ["CFBundleIdentifier": "org.sparkle-project.Sparkle.Updater"])
        w.plist(contents + "/Resources/Hidden.app/Contents/Info.plist", ["CFBundleIdentifier": "com.hidden.app"])
        w.file(contents + "/Library/LaunchServices/com.big.app.privhelper")
        w.file(contents + "/_MASReceipt/receipt")
        let big = AppIdentity.read(at: w.at("root/Applications/Big.app"), signed: false)!
        precondition(big.bundleID == "com.big.app" && big.version == "2.5" && big.isAppStore)
        precondition(big.names == ["Big", "Big App", "BigExe"], "\(big.names)")
        precondition(Set(big.nestedIDs) == ["com.big.app.login", "com.big.app.svc", "com.big.app.share", "com.big.app.helper"] && big.nestedIDs.count == 4, "\(big.nestedIDs)")
        precondition(big.executables == ["BigExe", "SvcExe"], "\(big.executables)")
        precondition(big.helperLabels == ["com.big.app.other", "com.big.app.privhelper"], "\(big.helperLabels)")
        precondition(big.strongIDs.count == 5 && big.looseIDs.isEmpty)
        precondition(AppIdentity.read(at: w.at("root/Applications/readme.txt")) == nil && AppIdentity.read(at: w.at("root/Applications/Missing.app")) == nil)
    }

    static func trash() {
        let w = World()
        defer { w.destroy() }
        w.app("Alpha", id: "com.alpha.app")
        w.app("Same", id: "com.same.app")
        w.app("Old", id: "com.old.app", in: "home/.Trash")
        w.app("Same", id: "com.same.app", in: "home/.Trash")
        w.app("Known", id: "com.known.app", in: "home/.Trash")
        w.node("home/Library/Containers/com.old.app")
        let footprint = AppFootprint(roots: w.roots(known: ["com.known.app"]))
        precondition(names(footprint.installed) == ["Alpha", "Same"], "\(names(footprint.installed))")
        let trashed = footprint.trashed()
        precondition(names(trashed) == ["Old"], "\(names(trashed))")
        let found = w.scan(footprint, trashed[0])
        expect(found, ["home/.Trash/Old.app": true, "home/Library/Containers/com.old.app": true], "Old in the Trash")
        precondition(found["home/.Trash/Old.app"]?.reason == .bundle)
    }

    static func orphans() {
        let w = World()
        defer { w.destroy() }
        let now = Date()
        let lib = "home/Library"
        let live = w.app("Live", id: "com.live.app")
        let vend = w.app("Vend Alpha", id: "com.vend.alpha")
        let smith = w.app("Wordsmith", id: "com.hnc.Wordsmith")
        var old: [String] = []
        func gone(_ path: String) {
            w.node(path)
            old.append(path)
        }
        func agent(_ name: String, label: String, program: String) {
            w.plist("\(lib)/LaunchAgents/\(name).plist", ["Label": label, "ProgramArguments": [program]])
            old.append("\(lib)/LaunchAgents/\(name).plist")
        }
        for path in [
            "Preferences/com.gone.app.plist", "Preferences/ByHost/com.gone.app.E1B2C3D4-0000-4000-8000-0000000000BB.plist", "Caches/com.gone.app", "Caches/com.gone.app.ShipIt",
            "Group Containers/ABCDE12345.com.gone.app", "Saved Application State/com.gone.app.savedState", "Application Support/com.gone.app",
            "Preferences/com.known.app.plist", "Preferences/com.live.app.plist", "Preferences/com.live.app.helper.plist", "Preferences/com.vend.beta.plist",
            "Preferences/com.apple.something.plist", "Group Containers/group.com.apple.something", "Group Containers/systemgroup.com.apple.x",
            "Preferences/com.alive.app.plist", "Application Support/com.prog.app", "Preferences/com.dead.app.plist", "Group Containers/group.com.cloud.shared",
            "Application Support/Dropbox", "Preferences/loginwindow.plist", "Application Support/Some Folder",
            "Preferences/com.wordsmith.old.shipit.plist", "Preferences/net.hnc.other.thing.plist", "Preferences/jetbrains.rd.243.plist", "Caches/main.kts.compiled.cache",
        ] { gone("\(lib)/\(path)") }
        w.file("\(lib)/Application Support/com.prog.app/helper-bin")
        w.file("root/Applications/Elsewhere/alive-bin")
        agent("com.alive.app", label: "com.alive.app", program: w.at("root/Applications/Elsewhere/alive-bin").path)
        agent("org.zzz.agent", label: "org.zzz.agent", program: w.at("\(lib)/Application Support/com.prog.app/helper-bin").path)
        agent("com.dead.app", label: "com.dead.app", program: w.at("root/Applications/Missing/dead-bin").path)
        w.node("\(lib)/Preferences/com.recent.app.plist")
        w.node("\(lib)/Application Support/com.inner.app")
        w.node("\(lib)/Preferences/com.six.days.plist")
        w.node("\(lib)/Preferences/com.eight.days.plist")
        w.file("outside/fresh/new.txt")
        w.link("\(lib)/Application Support/com.linked.app", to: w.at("outside/fresh").path)
        let locked = getuid() != 0
        if locked { gone("\(lib)/Application Support/com.locked.app") }
        for path in old { w.age(path, days: 30, from: now) }
        w.age("\(lib)/Application Support/com.inner.app", days: 30, from: now, deep: false)
        w.age("\(lib)/Preferences/com.six.days.plist", days: 6, from: now)
        w.age("\(lib)/Preferences/com.eight.days.plist", days: 8, from: now)
        w.age("\(lib)/Application Support/com.linked.app", days: 30, from: now, deep: false)
        if locked { w.lock("\(lib)/Application Support/com.locked.app", mode: 0o000) }

        let footprint = w.footprint([live, vend, smith], known: ["com.known.app"])
        let groups = footprint.orphans(now: now)
        w.unlockAll()
        precondition(groups.map(\.id) == ["com.eight.days", "com.dead.app", "com.gone.app", "com.linked.app", "com.cloud.shared"].sorted { lhs, rhs in
            AppNames.orphanTitle(lhs).localizedCaseInsensitiveCompare(AppNames.orphanTitle(rhs)) == .orderedAscending
        }, "\(groups.map(\.id))")
        precondition(groups.map(\.name) == ["Days", "Dead", "Gone", "Linked", "Shared"], "\(groups.map(\.name))")
        precondition(groups.allSatisfy { group in group.items.allSatisfy { !$0.preselected && $0.sharedWith.isEmpty } })
        let gone = groups.first { $0.id == "com.gone.app" }!
        precondition(gone.items.count == 7 && Set(gone.items.map(\.kind)) == [.preferences, .caches, .containers, .appData], "\(gone.items.map { w.rel($0.url) })")
        precondition(abs(gone.newest.timeIntervalSince(now) + 30 * 86_400) < 5)
        precondition(groups.first { $0.id == "com.dead.app" }?.items.count == 2)
        precondition(groups.first { $0.id == "com.linked.app" }?.items.first?.isLink == true)
        precondition(groups.first { $0.id == "com.eight.days" }!.items.map { w.rel($0.url) } == ["\(lib)/Preferences/com.eight.days.plist"])
        let again = footprint.orphans(now: now.addingTimeInterval(8 * 86_400))
        precondition(again.contains { $0.id == "com.six.days" } && again.contains { $0.id == "com.recent.app" } && again.contains { $0.id == "com.inner.app" })
    }

    static func search() {
        let slack = AppIdentity(url: URL(fileURLWithPath: "/Applications/Slack.app"), bundleID: "com.tinyspeck.slackmacgap", names: ["Slack"], organization: "Slack Technologies")
        let code = AppIdentity(url: URL(fileURLWithPath: "/Applications/Visual Studio Code.app"), bundleID: "com.microsoft.VSCode", names: ["Visual Studio Code", "Code"], organization: "Microsoft Corporation")
        let runner = AppIdentity(url: URL(fileURLWithPath: "/Applications/Code Runner.app"), bundleID: "com.coderunner.app", names: ["Code Runner"])
        let notes = AppIdentity(url: URL(fileURLWithPath: "/Applications/Заметки.app"), bundleID: "com.apple.Notes", names: ["Заметки", "Notes"])
        let cafe = AppIdentity(url: URL(fileURLWithPath: "/Applications/Café.app"), bundleID: "com.cafe.app", names: ["Café"])
        let chrome = AppIdentity(url: URL(fileURLWithPath: "/Applications/Google Chrome.app"), bundleID: "com.google.Chrome", names: ["Google Chrome"], organization: "Google LLC")
        let word = AppIdentity(url: URL(fileURLWithPath: "/Applications/Word.app"), bundleID: "com.microsoft.Word", names: ["Word"], organization: "Microsoft Corporation")
        let apps = [slack, code, runner, notes, cafe, chrome, word]
        func find(_ query: String) -> [String] { names(AppSearch.filter(apps, query: query)) }
        precondition(find("slack") == ["Slack"] && find("SLACK") == ["Slack"] && find("sla") == ["Slack"])
        precondition(find("ыдфсл") == ["Slack"], "\(find("ыдфсл"))")
        precondition(find("vsc") == ["Visual Studio Code"], "\(find("vsc"))")
        precondition(find("visual code") == ["Visual Studio Code"])
        precondition(find("code") == ["Visual Studio Code", "Code Runner"], "\(find("code"))")
        precondition(find("cod") == ["Code Runner", "Visual Studio Code"], "\(find("cod"))")
        precondition(find("cafe") == ["Café"] && find("Café") == ["Café"])
        precondition(find("google") == ["Google Chrome"])
        precondition(find("microsoft") == ["Visual Studio Code", "Word"], "\(find("microsoft"))")
        precondition(find("tinyspeck") == ["Slack"], "\(find("tinyspeck"))")
        precondition(find("pfvtnrb") == ["Заметки"], "\(find("pfvtnrb"))")
        precondition(find("zzzz").isEmpty)
        precondition(names(AppSearch.filter(apps, query: "")) == names(apps) && names(AppSearch.filter(apps, query: "   ")) == names(apps))
        precondition(AppSearch.matches(slack, query: "slack") && !AppSearch.matches(slack, query: "chrome"))
        precondition(AppSearch.score(slack, query: "slack") == 100 && AppSearch.score(slack, query: "sla") == 90 && AppSearch.score(slack, query: "ыдфсл") == 95)
    }
}
