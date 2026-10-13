import Foundation

private let base = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pika-background-\(UUID().uuidString)")

private func at(_ path: String) -> URL { base.appendingPathComponent(path) }

private func file(_ path: String) {
    try! FileManager.default.createDirectory(at: at(path).deletingLastPathComponent(), withIntermediateDirectories: true)
    try! Data("x".utf8).write(to: at(path))
}

private func plist(_ path: String, _ object: [String: Any]) {
    try! FileManager.default.createDirectory(at: at(path).deletingLastPathComponent(), withIntermediateDirectories: true)
    try! PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0).write(to: at(path))
}

@main
enum BackgroundTests {
    static func main() {
        defer { try? FileManager.default.removeItem(at: base) }
        parser()
        programs()
        names()
        timings()
        domains()
        collected()
        print("background: ok")
    }

    static func parser() {
        let state = LaunchState("""
            gui/501 = {
            \tservices = {
            \t\t   37691   (pe) \tcom.example.pe
            \t\t    1066      - \tcom.example.running
            \t\t       0      0 \tcom.example.idle
            \t}
            \tdisabled services = {
            \t\t"com.example.off" => disabled
            \t\t"com.example.on" => enabled
            \t\t"com.example.old" => true
            \t\t"com.example.back" => false
            \t}
            }
            """)
        precondition(state.pids == ["com.example.pe": 37691, "com.example.running": 1066, "com.example.idle": 0], "\(state.pids)")
        precondition(state.disabled == ["com.example.off": true, "com.example.on": false, "com.example.old": true, "com.example.back": false], "\(state.disabled)")
        var launchd = Launchd()
        launchd.user = state
        precondition(launchd.isRunning("com.example.pe", daemon: false) && !launchd.isRunning("com.example.idle", daemon: false))
        precondition(launchd.isLoaded("com.example.idle", daemon: false) && !launchd.isLoaded("com.example.idle", daemon: true))
    }

    static func programs() {
        let cases: [([String: Any], String?)] = [
            (["Program": "/usr/local/bin/tool", "ProgramArguments": ["tool", "--flag"]], "/usr/local/bin/tool"),
            (["ProgramArguments": ["/usr/local/bin/tool", "/Users/me/file"]], "/usr/local/bin/tool"),
            (["ProgramArguments": ["/bin/bash", "-l", "/Users/me/run.sh"]], "/Users/me/run.sh"),
            (["ProgramArguments": ["/bin/sh", "-c", "/opt/thing --flag"]], "/bin/sh"),
            (["ProgramArguments": ["/usr/bin/env", "python3", "/Users/me/job.py"]], "/Users/me/job.py"),
            (["ProgramArguments": ["/usr/bin/python3.12", "/Users/me/job.py"]], "/Users/me/job.py"),
            (["BundleProgram": "Contents/MacOS/agent"], nil),
            ([:], nil),
        ]
        for (info, expected) in cases {
            precondition(BackgroundTasks.program(info) == expected, "\(info): \(BackgroundTasks.program(info) ?? "nil")")
        }
        let app = URL(fileURLWithPath: "/Applications/Foo.app")
        precondition(BackgroundTasks.program(["BundleProgram": "Contents/MacOS/agent", "Program": "/bin/sh"], in: app) == "/Applications/Foo.app/Contents/MacOS/agent")
    }

    static func names() {
        let slack = AppIdentity(url: URL(fileURLWithPath: "/Applications/Slack.app"), bundleID: "com.tinyspeck.slackmacgap", names: ["Slack"], organization: "Slack Technologies")
        precondition(BackgroundTasks.title(label: "com.tinyspeck.slackmacgap.helper", owner: slack, target: "/x") == "Slack")
        precondition(BackgroundTasks.title(label: "com.foo.helper", owner: nil, target: "/Applications/Foo Bar.app/Contents/MacOS/helper") == "Foo Bar")
        precondition(BackgroundTasks.title(label: "homebrew.mxcl.redis", owner: nil, target: "/opt/homebrew/opt/redis/bin/redis-server") == "redis")
        precondition(BackgroundTasks.title(label: "sh.brew.autoupdate", owner: nil, target: "/bin/sh") == "autoupdate")
        precondition(BackgroundTasks.developer(owner: slack, label: "x", target: "/x") == "Slack Technologies")
        precondition(BackgroundTasks.developer(owner: nil, label: "homebrew.mxcl.pika-missing", target: "/opt/homebrew/opt/pika-missing/bin/x") == "Homebrew")
        precondition(BackgroundTasks.developer(owner: nil, label: "org.example.x", target: "/usr/local/Cellar/pika-missing/1.0/bin/x") == "Homebrew")
        precondition(BackgroundTasks.developer(owner: nil, label: "org.example.x", target: "relative") == "")
        precondition(BackgroundTasks.isOwn("com.pesotchi.pika-tools.fans") && BackgroundTasks.isOwn("COM.PIKAPIK.TOOLS.helper") && !BackgroundTasks.isOwn("com.pesotchi.other"))
    }

    static func timings() {
        let cases: [([String: Any], Bool, BackgroundTask.Timing)] = [
            (["KeepAlive": true, "StartInterval": 60], false, .keepsRunning),
            (["KeepAlive": ["SuccessfulExit": false]], true, .keepsRunning),
            (["KeepAlive": false, "StartCalendarInterval": ["Hour": 3]], false, .schedule),
            (["KeepAlive": [String: Any](), "RunAtLoad": true], false, .atLogin),
            (["RunAtLoad": true], true, .atStartup),
            (["RunAtLoad": false], false, .onDemand),
        ]
        for (info, daemon, expected) in cases {
            precondition(BackgroundTasks.timing(info, daemon: daemon) == expected, "\(info)")
        }
    }

    static func domains() {
        var launchd = Launchd()
        launchd.gui.pids["a.gui"] = 0
        launchd.user.pids["a.user"] = 5
        launchd.user.disabled["a.off"] = true
        let gui = "gui/\(launchd.uid)", user = "user/\(launchd.uid)"
        precondition(BackgroundTasks.agentDomain("a.gui", ["LimitLoadToSessionType": "Background"], launchd) == gui)
        precondition(BackgroundTasks.agentDomain("a.user", [:], launchd) == user)
        precondition(BackgroundTasks.agentDomain("a.off", [:], launchd) == user)
        precondition(BackgroundTasks.agentDomain("a.new", ["LimitLoadToSessionType": "Background"], launchd) == user)
        precondition(BackgroundTasks.agentDomain("a.new", ["LimitLoadToSessionType": ["Background"]], launchd) == user)
        precondition(BackgroundTasks.agentDomain("a.new", ["LimitLoadToSessionType": ["Aqua", "Background"]], launchd) == gui)
        precondition(BackgroundTasks.agentDomain("a.new", [:], launchd) == gui)
        file("home/.Trash/Old.app/Contents/MacOS/old")
        precondition(BackgroundTasks.isMissing(at("gone").path) && BackgroundTasks.isMissing(at("home/.Trash/Old.app/Contents/MacOS/old").path))
        precondition(!BackgroundTasks.isMissing("/bin/sh") && !BackgroundTasks.isMissing("relative"))
    }

    static func collected() {
        let app = "root/Applications/Foo.app/Contents/"
        plist(app + "Info.plist", ["CFBundleIdentifier": "com.foo.app", "CFBundleExecutable": "Foo"])
        file(app + "MacOS/Foo")
        file(app + "MacOS/foo-sync")
        plist(app + "Library/LaunchAgents/com.foo.agent.plist", ["Label": "com.foo.agent", "BundleProgram": "Contents/MacOS/Foo"])
        plist(app + "Library/LaunchAgents/com.foo.unused.plist", ["Label": "com.foo.unused", "BundleProgram": "Contents/MacOS/Foo"])
        plist(app + "Library/LaunchDaemons/com.foo.daemon.plist", ["Label": "com.foo.daemon", "BundleProgram": "Contents/MacOS/Foo", "KeepAlive": true])
        plist(app + "Library/LoginItems/Foo Launcher.app/Contents/Info.plist", ["CFBundleIdentifier": "com.foo.launcher"])
        plist(app + "Library/LoginItems/Foo Idle.app/Contents/Info.plist", ["CFBundleIdentifier": "com.foo.idle"])
        plist("root/Applications/pikapik.app/Contents/Info.plist", ["CFBundleIdentifier": "com.pesotchi.pika-tools"])
        file("root/usr/local/libexec/vendord")
        let vendord = at("root/usr/local/libexec/vendord").path
        plist("home/Library/LaunchAgents/com.foo.sync.plist", ["Label": "com.foo.sync", "ProgramArguments": [at(app + "MacOS/foo-sync").path], "RunAtLoad": true])
        plist("home/Library/LaunchAgents/com.gone.updater.plist", ["Label": "com.gone.updater", "ProgramArguments": [at("root/Applications/Gone.app/Contents/MacOS/updater").path], "StartInterval": 3600])
        plist("home/Library/LaunchAgents/com.needs.approval.plist", ["Label": "com.needs.approval", "Program": vendord])
        plist("home/Library/LaunchAgents/com.pesotchi.pika-tools.test.plist", ["Label": "com.pesotchi.pika-tools.test", "Program": vendord])
        plist("home/Library/LaunchAgents/com.apple.pika-test.plist", ["Label": "com.apple.pika-test", "Program": vendord])
        plist("home/Library/LaunchAgents/broken.plist", ["Label": "broken"])
        plist("root/Library/LaunchDaemons/com.vendor.daemon.plist", ["Label": "com.vendor.daemon", "Program": vendord, "KeepAlive": ["SuccessfulExit": false]])
        plist("root/Library/LaunchAgents/com.vendor.shared.plist", ["Label": "com.vendor.shared", "Program": vendord, "Disabled": true])

        let roots = AppRoots(home: at("home"), root: at("root"), userCache: nil, userTemp: nil, caskrooms: [], pkgutil: { _ in nil }, isKnownApp: { _ in false })
        let foo = AppIdentity(url: at("root/Applications/Foo.app"), bundleID: "com.foo.app", names: ["Foo"], organization: "Foo Inc.")
        let own = at("root/Applications/pikapik.app")
        let launcher = at(app + "Library/LoginItems/Foo Launcher.app")
        var launchd = Launchd()
        launchd.gui.pids = ["com.foo.agent": 0, "com.foo.sync": 42]
        launchd.gui.disabled = ["com.gone.updater": true, "com.foo.sync": false]
        launchd.system.pids = ["com.vendor.daemon": 77]
        let tasks = BackgroundTasks.collect(AppFootprint(roots: roots, installed: [foo], system: []), launchd: launchd, own: own,
                                            loginItems: [foo.url, own, launcher, at("home/.Trash/Old.app")],
                                            running: [(id: "com.foo.launcher", url: nil), (id: "com.foo.app", url: foo.url)],
                                            status: { ["com.needs.approval.plist": 2, "com.foo.daemon.plist": 1][$0.lastPathComponent] ?? 0 })
        let found = Dictionary(tasks.map { ($0.label.isEmpty ? $0.file.lastPathComponent : $0.label, $0) }, uniquingKeysWith: { first, _ in first })
        let expected: Set = ["com.foo.agent", "com.foo.daemon", "com.foo.launcher", "com.foo.sync", "com.gone.updater", "com.needs.approval",
                             "com.pesotchi.pika-tools.test", "com.vendor.daemon", "com.vendor.shared", "com.foo.app", "com.pesotchi.pika-tools", "Old.app"]
        precondition(Set(found.keys) == expected && tasks.count == expected.count, "\(tasks.map(\.label).sorted())")
        let titles = tasks.map(\.title)
        precondition(titles == titles.sorted { $0.localizedStandardCompare($1) != .orderedDescending }, "\(titles)")
        let gui = "gui/\(launchd.uid)"

        func check(_ label: String, _ test: (BackgroundTask) -> Bool) {
            precondition(test(found[label]!), "\(label): \(found[label]!)")
        }
        check("com.foo.agent") { $0.title == "Foo" && $0.developer == "Foo Inc." && $0.kind == .background && !$0.running && $0.state == .on && $0.domain.isEmpty && $0.timing == .onDemand && $0.icon == foo.url }
        check("com.foo.daemon") { $0.scope == .wholeMac && $0.timing == .keepsRunning && !$0.running && $0.domain.isEmpty }
        check("com.foo.launcher") { $0.file == launcher && $0.title == "Foo" && $0.running && $0.timing == .atLogin && $0.kind == .background }
        check("com.foo.sync") { $0.title == "Foo" && $0.developer == "Foo Inc." && $0.running && $0.state == .on && $0.domain == gui && $0.scope == .mine && $0.timing == .atLogin }
        check("com.gone.updater") { $0.kind == .leftover && $0.title == "Gone" && $0.state == .off && $0.domain == gui && $0.timing == .schedule && $0.icon == $0.file }
        check("com.needs.approval") { $0.state == .offInSettings && $0.domain == gui && $0.kind == .background }
        check("com.pesotchi.pika-tools.test") { $0.isOwn && $0.title == "pikapik" && $0.domain.isEmpty && $0.icon == own }
        check("com.vendor.daemon") { $0.scope == .wholeMac && $0.running && $0.timing == .keepsRunning && $0.domain.isEmpty && $0.state == .on }
        check("com.vendor.shared") { $0.scope == .allUsers && $0.state == .off && $0.domain.isEmpty }
        check("com.foo.app") { $0.kind == .login && $0.title == "Foo" && $0.developer == "Foo Inc." && $0.running && $0.timing == nil }
        check("com.pesotchi.pika-tools") { $0.kind == .login && $0.isOwn && $0.title == "pikapik" && $0.icon == own }
        check("Old.app") { $0.kind == .leftover && $0.title == "Old" }
    }
}
