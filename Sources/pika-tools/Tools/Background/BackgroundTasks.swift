import AppKit
import ServiceManagement

struct LaunchState {
    var pids: [String: Int] = [:]
    var disabled: [String: Bool] = [:]

    init() {}

    init(_ text: String) {
        var block = ""
        for line in text.split(separator: "\n") {
            switch line {
            case "\tservices = {": block = "services"
            case "\tdisabled services = {": block = "disabled"
            case "\t}": block = ""
            default:
                if block == "services" {
                    let parts = line.split(separator: "\t")
                    guard parts.count >= 2, let pid = parts[parts.count - 2].split(separator: " ").first.flatMap({ Int($0) }) else { continue }
                    pids[parts[parts.count - 1].trimmingCharacters(in: .whitespaces)] = pid
                } else if block == "disabled" {
                    let item = line.trimmingCharacters(in: .whitespaces)
                    guard item.hasPrefix("\""), let end = item.range(of: "\" => ") else { continue }
                    let value = item[end.upperBound...]
                    disabled[String(item[item.index(after: item.startIndex)..<end.lowerBound])] = value == "disabled" || value == "true"
                }
            }
        }
    }
}

struct Launchd {
    var uid = getuid()
    var gui = LaunchState()
    var user = LaunchState()
    var system = LaunchState()

    static func read() -> Launchd {
        var launchd = Launchd()
        let state = { (domain: String) in LaunchState(AppRoots.run("/bin/launchctl", ["print", domain]) ?? "") }
        launchd.gui = state("gui/\(launchd.uid)")
        launchd.user = state("user/\(launchd.uid)")
        launchd.system = state("system")
        return launchd
    }

    func isLoaded(_ label: String, daemon: Bool) -> Bool {
        daemon ? system.pids[label] != nil : gui.pids[label] != nil || user.pids[label] != nil
    }

    func isRunning(_ label: String, daemon: Bool) -> Bool {
        daemon ? (system.pids[label] ?? 0) > 0 : (gui.pids[label] ?? 0) > 0 || (user.pids[label] ?? 0) > 0
    }
}

struct BackgroundTask: Identifiable, Equatable {
    enum Kind { case login, background, leftover }
    enum Timing { case keepsRunning, schedule, atLogin, atStartup, onDemand }
    enum Scope { case mine, allUsers, wholeMac }
    enum State { case on, off, offInSettings }

    var file: URL
    var label: String
    var title: String
    var icon: URL
    var developer = ""
    var timing: Timing?
    var scope = Scope.mine
    var kind = Kind.background
    var running = false
    var state = State.on
    var domain = ""
    var isOwn = false

    var id: String { file.path }
}

enum BackgroundTasks {
    private static let interpreters: Set<String> = ["sh", "bash", "zsh", "dash", "ksh", "csh", "tcsh", "env", "perl", "ruby", "osascript", "open", "node"]
    private static let brewFolders = ["/opt/homebrew/", "/usr/local/Cellar/", "/usr/local/opt/", "/usr/local/Homebrew/"]

    static func isOwn(_ id: String) -> Bool {
        let id = id.lowercased()
        return id.hasPrefix("com.pesotchi.pika-tools") || id.hasPrefix("com.pikapik.tools")
    }

    static func program(_ info: [String: Any], in app: URL? = nil) -> String? {
        if let app, let bundled = info["BundleProgram"] as? String { return app.appendingPathComponent(bundled).path }
        let arguments = info["ProgramArguments"] as? [String] ?? []
        guard let tool = info["Program"] as? String ?? arguments.first else { return nil }
        let name = (tool as NSString).lastPathComponent
        guard interpreters.contains(name) || name.hasPrefix("python") else { return tool }
        var previous = ""
        for argument in arguments.dropFirst() {
            if argument.hasPrefix("/"), previous != "-c" { return argument }
            previous = argument
        }
        return tool
    }

    static func enclosingApp(_ path: String) -> URL? {
        let parts = (path as NSString).pathComponents
        guard let end = parts.firstIndex(where: { $0.lowercased().hasSuffix(".app") }) else { return nil }
        return URL(fileURLWithPath: NSString.path(withComponents: Array(parts[...end])))
    }

    static func title(label: String, owner: AppIdentity?, target: String) -> String {
        if let owner { return owner.displayName }
        if let app = enclosingApp(target) { return app.deletingPathExtension().lastPathComponent }
        for prefix in ["homebrew.mxcl.", "sh.brew."] where label.hasPrefix(prefix) { return String(label.dropFirst(prefix.count)) }
        return AppNames.orphanTitle(label)
    }

    static func developer(owner: AppIdentity?, label: String, target: String) -> String {
        if let organization = owner?.organization, !organization.isEmpty { return organization }
        if target.hasPrefix("/"), let organization = AppIdentity.signature(of: URL(fileURLWithPath: target))?.organization, !organization.isEmpty { return organization }
        if label.hasPrefix("homebrew.") || label.hasPrefix("sh.brew.") || brewFolders.contains(where: target.hasPrefix) { return "Homebrew" }
        return ""
    }

    static func timing(_ info: [String: Any], daemon: Bool) -> BackgroundTask.Timing {
        if info["KeepAlive"] as? Bool == true || !(info["KeepAlive"] as? [String: Any] ?? [:]).isEmpty { return .keepsRunning }
        if info["StartInterval"] != nil || info["StartCalendarInterval"] != nil { return .schedule }
        if info["RunAtLoad"] as? Bool == true { return daemon ? .atStartup : .atLogin }
        return .onDemand
    }

    static func agentDomain(_ label: String, _ info: [String: Any], _ launchd: Launchd) -> String {
        let gui = "gui/\(launchd.uid)", user = "user/\(launchd.uid)"
        if launchd.gui.pids[label] != nil { return gui }
        if launchd.user.pids[label] != nil { return user }
        if launchd.gui.disabled[label] == true { return gui }
        if launchd.user.disabled[label] == true { return user }
        let types = info["LimitLoadToSessionType"] as? [String] ?? (info["LimitLoadToSessionType"] as? String).map { [$0] } ?? []
        return types == ["Background"] ? user : gui
    }

    static func isMissing(_ path: String) -> Bool {
        guard path.hasPrefix("/") else { return false }
        if AppInventory.isInTrash(URL(fileURLWithPath: path)) { return true }
        var info = stat()
        return stat(path, &info) != 0 && errno == ENOENT
    }

    static func collect(_ footprint: AppFootprint, launchd: Launchd, own: URL, loginItems: [URL], running: [(id: String?, url: URL?)],
                        status: (URL) -> Int = { SMAppService.statusForLegacyPlist(at: $0).rawValue }) -> [BackgroundTask] {
        let fm = FileManager.default
        let home = footprint.roots.home.appendingPathComponent("Library/LaunchAgents").path + "/"
        let shared = footprint.roots.atRoot("Library/LaunchAgents").path + "/"
        let runningIDs = Set(running.compactMap(\.id))
        let runningPaths = Set(running.compactMap { $0.url?.standardizedFileURL.path })
        var labels = Set<String>(), paths = Set<String>()
        var tasks: [BackgroundTask] = []

        func plist(_ url: URL) -> [String: Any] { NSDictionary(contentsOf: url) as? [String: Any] ?? [:] }
        func existing(_ url: URL?) -> URL? { url.flatMap { fm.fileExists(atPath: $0.path) ? $0 : nil } }

        func add(_ file: URL, label: String, info: [String: Any], target: String, daemon: Bool, owner: AppIdentity?) {
            let mine = isOwn(label)
            let domain = daemon ? "system" : agentDomain(label, info, launchd)
            let map = daemon ? launchd.system : domain.hasPrefix("user/") ? launchd.user : launchd.gui
            var task = BackgroundTask(file: file, label: label, title: mine ? "pikapik" : title(label: label, owner: owner, target: target), icon: own)
            if !mine {
                task.icon = owner?.url ?? existing(enclosingApp(target)) ?? existing(URL(fileURLWithPath: target)) ?? file
                task.developer = developer(owner: owner, label: label, target: target)
            }
            task.isOwn = mine
            task.timing = timing(info, daemon: daemon)
            task.scope = daemon ? .wholeMac : file.path.hasPrefix(shared) ? .allUsers : .mine
            task.kind = isMissing(target) ? .leftover : .background
            task.running = launchd.isRunning(label, daemon: daemon)
            if status(file) == 2 {
                task.state = .offInSettings
            } else if let off = map.disabled[label] {
                task.state = off ? .off : .on
            } else if info["Disabled"] as? Bool == true {
                task.state = .off
            }
            if !daemon, !mine, file.path.hasPrefix(home) { task.domain = domain }
            labels.insert(label.lowercased())
            paths.insert(file.standardizedFileURL.path)
            tasks.append(task)
        }

        for job in footprint.launchTasks() {
            let info = plist(job.url)
            guard let target = program(info) else { continue }
            add(job.url, label: job.label, info: info, target: target, daemon: job.isDaemon, owner: job.owner)
        }

        for app in footprint.installed {
            for (folder, daemon) in [("Contents/Library/LaunchAgents", false), ("Contents/Library/LaunchDaemons", true)] {
                let dir = app.url.appendingPathComponent(folder)
                for name in ((try? fm.contentsOfDirectory(atPath: dir.path)) ?? []).sorted() where name.hasSuffix(".plist") {
                    let file = dir.appendingPathComponent(name)
                    let info = plist(file)
                    let label = info["Label"] as? String ?? String(name.dropLast(6))
                    guard !labels.contains(label.lowercased()), !AppNames.isApple([label.lowercased()]),
                          launchd.isLoaded(label, daemon: daemon) || [1, 2].contains(status(file)),
                          let target = program(info, in: app.url) else { continue }
                    add(file, label: label, info: info, target: target, daemon: daemon, owner: app)
                }
            }
            let helpers = app.url.appendingPathComponent("Contents/Library/LoginItems")
            for name in ((try? fm.contentsOfDirectory(atPath: helpers.path)) ?? []).sorted() where name.hasSuffix(".app") {
                let helper = helpers.appendingPathComponent(name)
                guard let id = plist(helper.appendingPathComponent("Contents/Info.plist"))["CFBundleIdentifier"] as? String,
                      !labels.contains(id.lowercased()), !paths.contains(helper.standardizedFileURL.path),
                      launchd.gui.pids[id] != nil || runningIDs.contains(id) || launchd.gui.disabled[id] == false else { continue }
                var task = BackgroundTask(file: helper, label: id, title: isOwn(id) ? "pikapik" : app.displayName, icon: app.url)
                task.developer = app.organization
                task.timing = .atLogin
                task.running = (launchd.gui.pids[id] ?? 0) > 0 || runningIDs.contains(id)
                task.isOwn = isOwn(id)
                labels.insert(id.lowercased())
                paths.insert(helper.standardizedFileURL.path)
                tasks.append(task)
            }
        }

        for url in loginItems {
            let path = url.standardizedFileURL.path
            guard paths.insert(path).inserted else { continue }
            let id = plist(url.appendingPathComponent("Contents/Info.plist"))["CFBundleIdentifier"] as? String ?? ""
            let mine = isOwn(id)
            let name = url.pathExtension.lowercased() == "app" ? url.deletingPathExtension().lastPathComponent : url.lastPathComponent
            var task = BackgroundTask(file: url, label: id, title: mine ? "pikapik" : name, icon: mine ? own : url)
            if !mine {
                task.developer = footprint.installed.first { $0.url.standardizedFileURL.path == path }?.organization
                    ?? AppIdentity.signature(of: url)?.organization ?? ""
            }
            task.isOwn = mine
            task.kind = AppInventory.isInTrash(url) ? .leftover : .login
            task.running = runningPaths.contains(path)
            tasks.append(task)
        }

        return tasks.sorted {
            let order = $0.title.localizedStandardCompare($1.title)
            return order == .orderedSame ? $0.label < $1.label : order == .orderedAscending
        }
    }

    static func loginItems() -> [URL] {
        (SessionLoginItems() as LoginItemsList).urls()
    }

    #if !APPSTORE
    static func turnOff(_ task: BackgroundTask) -> Bool {
        guard !task.domain.isEmpty, AppRoots.run("/bin/launchctl", ["disable", "\(task.domain)/\(task.label)"]) != nil else { return false }
        _ = AppRoots.run("/bin/launchctl", ["bootout", "\(task.domain)/\(task.label)"])
        return true
    }

    static func turnOn(_ task: BackgroundTask) -> Bool {
        guard !task.domain.isEmpty, AppRoots.run("/bin/launchctl", ["enable", "\(task.domain)/\(task.label)"]) != nil else { return false }
        _ = AppRoots.run("/bin/launchctl", ["bootstrap", task.domain, task.file.path])
        return true
    }
    #endif

    static func openLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

private protocol LoginItemsList {
    func urls() -> [URL]
}

private struct SessionLoginItems: LoginItemsList {
    @available(macOS, deprecated: 10.11)
    func urls() -> [URL] {
        guard let list = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeUnretainedValue(), nil)?.takeRetainedValue() else { return [] }
        var seed: UInt32 = 0
        let items = LSSharedFileListCopySnapshot(list, &seed)?.takeRetainedValue() as? [LSSharedFileListItem] ?? []
        let flags = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
        return items.compactMap { LSSharedFileListItemCopyResolvedURL($0, flags, nil)?.takeRetainedValue() as URL? }
    }
}
