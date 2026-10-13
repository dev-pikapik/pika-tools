import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PortHint {
    let port: UInt16
    let service: String
    let pane: URL
}

struct PortLook {
    let name: String
    let file: String?
    let icon: NSImage
    let isApp: Bool
    let window: NSRunningApplication?
}

struct PortAddress {
    let text: String
    let link: URL?
}

#if !APPSTORE
struct PortQuestion {
    let program: PortProgram
    let name: String
    let detail: String
    let force: Bool
    let isApp: Bool
}
#endif

@MainActor @Observable final class PortsModel {
    static let shared = PortsModel()
    static let activityMonitor = URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app")
    private static let sharing = URL(string: "x-apple.systempreferences:com.apple.Sharing-Settings.extension")!
    private static let airPlay = URL(string: "x-apple.systempreferences:com.apple.AirDrop-Handoff-Settings.extension")!
    private static let notWeb: Set<UInt16> = [22, 1433, 3306, 5432, 5672, 6379, 9042, 11211, 27017]

    private(set) var programs: [PortProgram] = []
    private(set) var addresses: [String] = []
    private(set) var loaded = false
    private(set) var freeing: Set<pid_t> = []
    var query = ""
    var expanded: Set<pid_t> = []
    #if APPSTORE
    private(set) var copied: pid_t?
    #else
    var question: PortQuestion?
    #endif
    @ObservationIgnored private var looks: [String: PortLook] = [:]
    @ObservationIgnored private var watching: Task<Void, Never>?

    func watch() {
        guard watching == nil else { return }
        watching = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func unwatch() {
        watching?.cancel()
        watching = nil
    }

    func refresh() async {
        let (programs, addresses) = await Task.detached(priority: .utility) {
            let listeners = PortScanner.listeners()
            var owners: [pid_t: PortOwner] = [:]
            for pid in Set(listeners.map(\.pid)) { owners[pid] = PortScanner.owner(pid) }
            return (PortScanner.programs(listeners, owners: owners), PortScanner.networkAddresses())
        }.value
        if programs != self.programs {
            self.programs = programs
            let keys = Set(programs.map(Self.key))
            looks = looks.filter { keys.contains($0.key) }
        }
        if addresses != self.addresses { self.addresses = addresses }
        if !loaded { loaded = true }
    }

    var shown: [PortProgram] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return programs }
        if let digits = Self.digits(text) { return programs.filter { $0.ports.contains { String($0).hasPrefix(digits) } } }
        return programs.filter { program in
            ([look(program).name, program.owner.name, program.owner.folder ?? "", program.owner.command.joined(separator: " ")] + hints(program).map(\.service))
                .contains { $0.localizedStandardContains(text) }
        }
    }

    var freePort: UInt16? {
        guard let digits = Self.digits(query.trimmingCharacters(in: .whitespacesAndNewlines)), let port = UInt16(digits),
              port > 0, port < PortScanner.ephemeral, !programs.contains(where: { $0.ports.contains(port) }) else { return nil }
        return port
    }

    func isOurs(_ program: PortProgram) -> Bool { program.owner.isMine && !program.owner.isApple }

    func look(_ program: PortProgram) -> PortLook {
        let key = Self.key(program)
        if let look = looks[key] { return look }
        let owner = program.owner
        let chain = [owner.pid] + Self.ancestors(of: owner.pid)
        let apps = NSWorkspace.shared.runningApplications
        let app = Self.app(for: owner, chain: chain, apps: apps)
        let file = app?.bundleURL?.path ?? Self.bundle(owner.path)
        let name = app?.localizedName ?? file.map { FileManager.default.displayName(atPath: $0).replacingOccurrences(of: ".app", with: "", options: [.anchored, .backwards]) } ?? owner.name
        let icon = file.map { NSWorkspace.shared.icon(forFile: $0) } ?? NSWorkspace.shared.icon(for: .unixExecutable)
        let window = ([app].compactMap { $0 } + chain.compactMap { pid in apps.first { $0.processIdentifier == pid } }).first { $0.activationPolicy == .regular }
        let look = PortLook(name: name, file: file, icon: icon, isApp: app != nil, window: window)
        looks[key] = look
        return look
    }

    func byline(_ program: PortProgram) -> String {
        let owner = program.owner
        if owner.isApple {
            let services = hints(program).map(\.service).reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } }
            return services.isEmpty ? String(localized: "Part of macOS") : services.joined(separator: " · ")
        }
        if owner.isMine { return owner.folder.flatMap { $0 == "/" ? nil : Self.tilde($0) } ?? "" }
        return owner.uid == 0 ? String(localized: "System service") : String(localized: "Started by another user")
    }

    func hints(_ program: PortProgram) -> [PortHint] {
        guard program.owner.isApple else { return [] }
        let airPlay = program.owner.path?.hasSuffix("/ControlCenter") == true
        let remote = programs.contains { $0.ports.contains(3283) }
        return program.ports.compactMap { port -> PortHint? in
            switch port {
            case 5000, 7000: airPlay ? PortHint(port: port, service: String(localized: "AirPlay Receiver"), pane: Self.airPlay) : nil
            case 22: PortHint(port: port, service: String(localized: "Remote Login"), pane: Self.sharing)
            case 139, 445: PortHint(port: port, service: String(localized: "File Sharing"), pane: Self.sharing)
            case 3283: PortHint(port: port, service: String(localized: "Remote Management"), pane: Self.sharing)
            case 5900: PortHint(port: port, service: remote ? String(localized: "Remote Management") : String(localized: "Screen Sharing"), pane: Self.sharing)
            default: nil
            }
        }
    }

    func addresses(_ program: PortProgram) -> [PortAddress] {
        var seen = Set<String>()
        var result: [PortAddress] = []
        for listener in program.listeners {
            let hosts = listener.hosts.sorted().flatMap { host -> [String] in
                if host == "*" { return ["localhost"] + addresses }
                if PortScanner.isLoopback(host) { return ["localhost"] }
                return [host.contains(":") ? "[\(host)]" : host]
            }
            for host in hosts {
                let text = "\(host):\(listener.port)"
                guard seen.insert(text).inserted else { continue }
                let web = isOurs(program) && listener.tcp && !Self.notWeb.contains(listener.port) && !text.contains("%")
                result.append(PortAddress(text: text, link: web ? URL(string: "http://\(text)") : nil))
            }
        }
        return result
    }

    func reveal(_ program: PortProgram) {
        guard let path = look(program).file ?? program.owner.path else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    #if APPSTORE
    func copyCommand(_ program: PortProgram) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("kill \(program.owner.pid)", forType: .string)
        copied = program.id
        Task {
            try? await Task.sleep(for: .seconds(1))
            if copied == program.id { copied = nil }
        }
    }
    #else
    func free(_ program: PortProgram) {
        question = ask(program, force: false)
    }

    func confirm(_ question: PortQuestion) {
        self.question = nil
        if question.force { forceQuit(question.program) } else { Task { await quit(question.program) } }
    }

    private func quit(_ program: PortProgram) async {
        guard verified(program) else { return await refresh() }
        freeing.insert(program.id)
        if let app = runningApp(program.owner) { app.terminate() } else { kill(program.owner.pid, SIGTERM) }
        var held = true
        for _ in 0..<50 {
            held = holding(program)
            if !held { break }
            try? await Task.sleep(for: .milliseconds(100))
        }
        freeing.remove(program.id)
        if held, question == nil {
            question = ask(program, force: true)
        }
        await refresh()
    }

    private func forceQuit(_ program: PortProgram) {
        if verified(program) {
            runningApp(program.owner)?.forceTerminate()
            kill(program.owner.pid, SIGKILL)
            for pid in program.helpers where Self.holds(pid, program.ports) { kill(pid, SIGKILL) }
        }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await refresh()
        }
    }

    private func verified(_ program: PortProgram) -> Bool {
        let old = program.owner
        guard let now = PortScanner.owner(old.pid) else { return false }
        return Self.isSafe(now) && now.started == old.started && now.path == old.path && now.uid == old.uid
    }

    private func holding(_ program: PortProgram) -> Bool {
        ([program.owner.pid] + program.helpers).contains { !PortScanner.ports(of: $0).isDisjoint(with: program.ports) }
    }

    private func ask(_ program: PortProgram, force: Bool) -> PortQuestion {
        let list = program.ports.map(String.init).formatted(.list(type: .and))
        let ports = program.ports.count == 1 ? String(localized: "Port \(list)") : String(localized: "Ports \(list)")
        let detail = [ports, byline(program)].filter { !$0.isEmpty }.joined(separator: " · ")
        return PortQuestion(program: program, name: look(program).name, detail: detail, force: force, isApp: runningApp(program.owner) != nil)
    }

    private func runningApp(_ owner: PortOwner) -> NSRunningApplication? {
        Self.app(for: owner, chain: [owner.pid] + Self.ancestors(of: owner.pid), apps: NSWorkspace.shared.runningApplications)
    }

    private static func holds(_ pid: pid_t, _ ports: [UInt16]) -> Bool {
        guard let owner = PortScanner.owner(pid), isSafe(owner) else { return false }
        return !PortScanner.ports(of: pid).isDisjoint(with: ports)
    }

    private static func isSafe(_ owner: PortOwner) -> Bool {
        owner.pid > 1 && owner.pid != getpid() && owner.isMine && !owner.isApple && !(owner.path ?? "").hasPrefix(Bundle.main.bundlePath + "/")
    }
    #endif

    static func tilde(_ path: String) -> String {
        let home = FolderAccess.home.path
        if path == home { return "~" }
        return path.hasPrefix(home + "/") ? "~" + path.dropFirst(home.count) : path
    }

    private static func key(_ program: PortProgram) -> String { "\(program.owner.pid)-\(program.owner.started)" }

    private static func digits(_ text: String) -> String? {
        let tail = text.split(separator: ":", omittingEmptySubsequences: false).last ?? ""
        let port = tail.split(separator: "/", omittingEmptySubsequences: false).first ?? ""
        return !port.isEmpty && port.allSatisfy({ $0.isASCII && $0.isNumber }) ? String(port) : nil
    }

    private static func bundle(_ path: String?) -> String? {
        guard let path, let range = path.range(of: ".app/Contents/MacOS/", options: .backwards) else { return nil }
        return String(path[..<range.lowerBound]) + ".app"
    }

    private static func ancestors(of pid: pid_t) -> [pid_t] {
        var chain: [pid_t] = []
        var pid = pid
        while chain.count < 8, let parent = PortScanner.owner(pid)?.parent, parent > 1, !chain.contains(parent) {
            chain.append(parent)
            pid = parent
        }
        return chain
    }

    private static func app(for owner: PortOwner, chain: [pid_t], apps: [NSRunningApplication]) -> NSRunningApplication? {
        let apps = apps.filter { $0.activationPolicy != .prohibited }
        if let app = apps.first(where: { $0.processIdentifier == owner.pid }) { return app }
        if let bundle = bundle(owner.path), let app = apps.first(where: { $0.bundleURL?.path == bundle }) { return app }
        guard let path = owner.path else { return nil }
        for pid in chain.dropFirst() {
            if let app = apps.first(where: { $0.processIdentifier == pid }), let bundle = app.bundleURL?.path, path.hasPrefix(bundle + "/") { return app }
        }
        return nil
    }
}
