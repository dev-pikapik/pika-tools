import Foundation

final class AppRemover {
    enum Outcome: Equatable {
        case done(String?)
        case cancelled
        case denied
        case failed
    }

    struct Running {
        var name: String
        var isRunning: () -> Bool
        var terminate: () -> Void
        var forceTerminate: () -> Void
    }

    struct Hooks {
        var running: (AppIdentity) -> [Running]
        var confirmQuit: ([String]) async -> Bool
        var confirmForceQuit: ([String]) async -> Bool
        var launchctl: ([String]) -> Int32
        var admin: (String, String) async -> Outcome
        var finder: (URL) async -> Outcome
        var forget: (String) -> Void
    }

    struct Move: Codable, Equatable {
        var original: String
        var trash: String
        var needsAdmin: Bool
        var device: Int32
        var inode: UInt64
    }

    struct Job: Codable, Equatable {
        var label: String
        var domain: String
        var plist: String
    }

    struct Record: Codable, Equatable, Identifiable {
        var id: String
        var appName: String
        var date: Date
        var bytes: Int64
        var moves: [Move]
        var jobs: [Job]
    }

    enum Step: Equatable {
        case openAutomation
        case openAppManagement
        case showInFinder

        var title: String {
            switch self {
            case .openAutomation: String(localized: "Open Automation settings")
            case .openAppManagement: String(localized: "Open App Management settings")
            case .showInFinder: String(localized: "Show in Finder")
            }
        }
    }

    struct Survivor: Equatable {
        enum Why: Equatable {
            case changed
            case protected
            case cancelled
            case blocked
            case automation
            case failed

            var step: Step? {
                switch self {
                case .automation: .openAutomation
                case .blocked: .openAppManagement
                case .changed, .failed: .showInFinder
                case .protected, .cancelled: nil
                }
            }
        }

        var url: URL
        var why: Why
        var step: Step?

        var message: String {
            switch why {
            case .changed: String(localized: "It changed while pikapik was working, so it was left alone.")
            case .protected: String(localized: "It is in a protected place, so pikapik left it alone.")
            case .cancelled: String(localized: "It stays because no password was entered.")
            case .blocked: String(localized: "macOS did not let pikapik move it. Turn on pikapik under App Management, then try again.")
            case .automation: String(localized: "pikapik asks Finder to move apps to the Trash when macOS doesn’t let it do that itself.") + " " + String(localized: "Turn on Finder for pikapik under Automation, then try again.")
            case .failed: String(localized: "It could not be moved. Drag it to the Trash in Finder.")
            }
        }
    }

    struct Report {
        var removed = 0
        var bytes: Int64 = 0
        var survivors: [Survivor] = []
        var stillOpen: [String] = []
        var cancelled = false
        var record: Record?
    }

    struct Stay: Equatable {
        enum Why: Equatable {
            case missing
            case occupied
            case failed
            case cancelled
        }

        var url: URL
        var why: Why

        var message: String {
            switch why {
            case .missing: String(localized: "It is no longer in the Trash.")
            case .occupied: String(localized: "Something else is already in its place.")
            case .failed: String(localized: "It could not be put back. Drag it out of the Trash in Finder.")
            case .cancelled: String(localized: "It stays in the Trash because no password was entered.")
            }
        }
    }

    struct Restoration {
        var restored = 0
        var stayed: [Stay] = []
        var cancelled = false
    }

    private enum Inspection {
        case gone
        case changed
        case same
    }

    private enum Attempt {
        case moved(Move?)
        case needsAdmin
        case failed(Survivor.Why)
    }

    private struct Work {
        var report = Report()
        var why: [String: Survivor.Why] = [:]
        var moves: [Move] = []
        var jobs: [Job] = []

        mutating func record(_ move: Move?, bytes: Int64) {
            if let move { moves.append(move) }
            report.removed += 1
            report.bytes += bytes
        }
    }

    let footprint: AppFootprint
    let hooks: Hooks
    let store: URL
    let trash: URL
    let quitSeconds: Double
    private let bases: [(path: String, real: String)]
    private let files = FileManager.default
    private static let recordsLock = NSLock()

    init(footprint: AppFootprint, hooks: Hooks, store: URL, trash: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash"), quitSeconds: Double = 5) {
        self.footprint = footprint
        self.hooks = hooks
        self.store = store
        self.trash = trash
        self.quitSeconds = quitSeconds
        let roots = footprint.roots
        let known = [roots.root, roots.home, roots.atRoot("var"), roots.userCache, roots.userTemp].compactMap { $0 } + roots.caskrooms
        bases = known.map { (path: $0.path, real: Self.realPath($0.path) ?? $0.path) }.sorted { $0.path.count > $1.path.count }
    }

    static func realPath(_ path: String) -> String? {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        return realpath(path, &buffer) == nil ? nil : String(cString: buffer)
    }

    static func quoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    static func guardedMove(_ source: String, to destination: String, device: Int32, inode: UInt64) -> String {
        "[ ! -e \(quoted(destination)) ] && [ \"$(/usr/bin/stat -f '%d:%i' \(quoted(source)))\" = '\(device):\(inode)' ] && /bin/mv -n \(quoted(source)) \(quoted(destination))"
    }

    func remove(_ app: AppIdentity, items: [Leftover]) async -> Report {
        var work = Work()
        let attempted = items.filter { !AppInventory.isInTrash($0.url) }
        var plan: [Leftover] = []
        for item in attempted.sorted(by: { $0.url.pathComponents.count < $1.url.pathComponents.count }) {
            if footprint.isProtected(item.url, for: app, names: names(item), allowLink: item.reason == .cliLink) {
                work.why[item.id] = .protected
            } else {
                plan.append(item)
            }
        }
        let running = hooks.running(app)
        if !running.isEmpty, !(await hooks.confirmQuit(running.map(\.name))) {
            work.report.cancelled = true
            return work.report
        }
        let booted = bootOut(plan)
        if let open = await quit(running) {
            booted.forEach(restart)
            work.report.stillOpen = open
            return work.report
        }
        work.jobs = booted
        var queue: [Leftover] = []
        for item in plan {
            if item.packageID != nil {
                queue.append(item)
                continue
            }
            switch inspect(item) {
            case .gone: continue
            case .changed:
                work.why[item.id] = .changed
                continue
            case .same: break
            }
            let size = item.size ?? AppFootprint.allocatedSize(of: item.url)
            switch await move(item) {
            case .moved(let entry): work.record(entry, bytes: size)
            case .needsAdmin: queue.append(item)
            case .failed(let why):
                work.why[item.id] = why
                if why == .cancelled { work.report.cancelled = true }
            }
        }
        if !queue.isEmpty { await runAdmin(queue, app, &work) }
        booted.filter { exists($0.plist) }.forEach(restart)
        if work.report.removed > 0, AppInventory.isInTrash(app.url) || !exists(app.url.path) { app.ids.forEach(hooks.forget) }
        work.report.survivors = attempted.filter(isPresent).map { item in
            let why = work.why[item.id] ?? .failed
            return Survivor(url: item.url, why: why, step: item.packageID == nil ? why.step : nil)
        }
        if !work.moves.isEmpty {
            let record = Record(id: UUID().uuidString, appName: app.displayName, date: Date(), bytes: work.report.bytes, moves: work.moves, jobs: work.jobs.filter { !exists($0.plist) })
            Self.recordsLock.withLock { write([record] + prune()) }
            work.report.record = record
        }
        return work.report
    }

    func records() -> [Record] {
        Self.recordsLock.withLock { prune() }
    }

    private func prune() -> [Record] {
        let stored = (try? JSONDecoder().decode([Record].self, from: Data(contentsOf: recordsFile))) ?? []
        let kept = stored.compactMap { record -> Record? in
            var record = record
            record.moves.removeAll { !isSame($0.trash, device: $0.device, inode: $0.inode) }
            return record.moves.isEmpty ? nil : record
        }
        if kept != stored { write(kept) }
        return kept
    }

    func restore(_ record: Record) async -> Restoration {
        var result = Restoration()
        var back: Set<String> = []
        var rooted: [Move] = []
        for move in record.moves {
            let original = URL(fileURLWithPath: move.original)
            if !isSame(move.trash, device: move.device, inode: move.inode) {
                result.stayed.append(Stay(url: original, why: .missing))
            } else if exists(move.original) {
                result.stayed.append(Stay(url: original, why: .occupied))
            } else if move.needsAdmin {
                rooted.append(move)
            } else if (try? files.moveItem(atPath: move.trash, toPath: move.original)) != nil {
                back.insert(move.original)
            } else {
                result.stayed.append(Stay(url: original, why: .failed))
            }
        }
        if !rooted.isEmpty {
            let steps = rooted.map { move in
                let step = Self.guardedMove(move.trash, to: move.original, device: move.device, inode: move.inode)
                let daemon = record.jobs.contains { $0.domain == "system" && $0.plist == move.original }
                return daemon ? step + " && /bin/launchctl bootstrap system \(Self.quoted(move.original))" : step
            }
            let outcome = await hooks.admin((steps + ["exit 0"]).joined(separator: "; "), String(localized: "pikapik wants to put back what it removed."))
            result.cancelled = outcome == .cancelled
            for move in rooted {
                if isSame(move.original, device: move.device, inode: move.inode) {
                    back.insert(move.original)
                } else {
                    let why: Stay.Why = result.cancelled ? .cancelled : exists(move.original) ? .occupied : .failed
                    result.stayed.append(Stay(url: URL(fileURLWithPath: move.original), why: why))
                }
            }
        }
        record.jobs.filter { $0.domain != "system" && back.contains($0.plist) }.forEach(restart)
        result.restored = back.count
        _ = records()
        return result
    }

    private var recordsFile: URL { store.appendingPathComponent("records.json") }

    private func write(_ list: [Record]) {
        try? files.createDirectory(at: store, withIntermediateDirectories: true)
        try? JSONEncoder().encode(Array(list.prefix(10))).write(to: recordsFile, options: .atomic)
    }

    private func names(_ item: Leftover) -> [String] {
        [item.url.lastPathComponent] + [item.jobLabel, item.packageID].compactMap { $0 }
    }

    private func exists(_ path: String) -> Bool {
        var info = stat()
        return lstat(path, &info) == 0
    }

    private func isPresent(_ item: Leftover) -> Bool {
        if let id = item.packageID { return footprint.roots.pkgutil(["--pkg-info", id]) != nil }
        return exists(item.url.path)
    }

    private func isSame(_ path: String, device: Int32, inode: UInt64) -> Bool {
        var info = stat()
        return lstat(path, &info) == 0 && info.st_dev == device && info.st_ino == inode
    }

    private func inspect(_ item: Leftover) -> Inspection {
        var info = stat()
        guard lstat(item.url.path, &info) == 0 else { return .gone }
        guard info.st_dev == item.device, info.st_ino == item.inode, hasCanonicalParent(item.url) else { return .changed }
        return .same
    }

    private func hasCanonicalParent(_ url: URL) -> Bool {
        let parent = url.deletingLastPathComponent().path
        guard let real = Self.realPath(parent) else { return false }
        guard let base = bases.first(where: { $0.path == parent || parent.hasPrefix($0.path == "/" ? "/" : $0.path + "/") }) else { return real == parent }
        return real == base.real + parent.dropFirst(base.path.count)
    }

    private func bootOut(_ plan: [Leftover]) -> [Job] {
        let domain = "gui/\(getuid())"
        return plan.compactMap { item in
            guard let label = item.jobLabel, !item.isDaemon, inspect(item) == .same,
                  hooks.launchctl(["print", "\(domain)/\(label)"]) == 0,
                  hooks.launchctl(["bootout", "\(domain)/\(label)"]) == 0
            else { return nil }
            return Job(label: label, domain: domain, plist: item.url.path)
        }
    }

    private func restart(_ job: Job) {
        _ = hooks.launchctl(["bootstrap", job.domain, job.plist])
    }

    private func quit(_ running: [Running]) async -> [String]? {
        guard !running.isEmpty else { return nil }
        running.forEach { $0.terminate() }
        if await waitUntilQuit(running) { return nil }
        let open = running.filter { $0.isRunning() }
        guard await hooks.confirmForceQuit(open.map(\.name)) else { return open.map(\.name) }
        open.forEach { $0.forceTerminate() }
        if await waitUntilQuit(running) { return nil }
        return running.filter { $0.isRunning() }.map(\.name)
    }

    private func waitUntilQuit(_ running: [Running]) async -> Bool {
        let deadline = Date().addingTimeInterval(quitSeconds)
        while running.contains(where: { $0.isRunning() }) {
            guard Date() < deadline, (try? await Task.sleep(for: .milliseconds(50))) != nil else { return false }
        }
        return true
    }

    private func move(_ item: Leftover) async -> Attempt {
        let isApp = item.kind == .app
        if item.needsAdmin {
            if isApp { return await viaFinder(item) }
            return .needsAdmin
        }
        var trashed: NSURL?
        do {
            try files.trashItem(at: item.url, resultingItemURL: &trashed)
            return .moved(entry(item, trash: (trashed as URL?)?.path, needsAdmin: false))
        } catch {
            if isApp { return await viaFinder(item) }
            return .failed((error as NSError).code == NSFileWriteNoPermissionError ? .blocked : .failed)
        }
    }

    private func viaFinder(_ item: Leftover) async -> Attempt {
        switch await hooks.finder(item.url) {
        case .done(let path): return .moved(entry(item, trash: locate(item, hint: path), needsAdmin: item.needsAdmin))
        case .cancelled: return .failed(.cancelled)
        case .denied: return .failed(.automation)
        case .failed: return .failed(.failed)
        }
    }

    private func locate(_ item: Leftover, hint: String?) -> String? {
        let guesses = [hint.map { URL(fileURLWithPath: $0).path }, trash.appendingPathComponent(item.url.lastPathComponent).path].compactMap { $0 }
        if let found = guesses.first(where: { isSame($0, device: item.device, inode: item.inode) }) { return found }
        let names = (try? files.contentsOfDirectory(atPath: trash.path)) ?? []
        return names.map { trash.appendingPathComponent($0).path }.first { isSame($0, device: item.device, inode: item.inode) }
    }

    private func entry(_ item: Leftover, trash: String?, needsAdmin: Bool) -> Move? {
        trash.map { Move(original: item.url.path, trash: $0, needsAdmin: needsAdmin, device: item.device, inode: item.inode) }
    }

    private func runAdmin(_ queue: [Leftover], _ app: AppIdentity, _ work: inout Work) async {
        var moves: [String] = []
        var forgets: [String] = []
        var movers: [(item: Leftover, destination: String, size: Int64)] = []
        var receipts: [String] = []
        var daemons: [Job] = []
        var taken: Set<String> = []
        for item in queue {
            if let id = item.packageID {
                guard id.range(of: "^[A-Za-z0-9][A-Za-z0-9._+-]*$", options: .regularExpression) != nil else {
                    work.why[item.id] = .failed
                    continue
                }
                forgets.append("/usr/sbin/pkgutil --forget \(Self.quoted(id))")
                receipts.append(id)
                continue
            }
            var destination = trash.appendingPathComponent(item.url.lastPathComponent).path
            if taken.contains(destination) || exists(destination) {
                destination = trash.appendingPathComponent("\(item.url.lastPathComponent) \(UUID().uuidString.prefix(8))").path
            }
            taken.insert(destination)
            var step = Self.guardedMove(item.url.path, to: destination, device: item.device, inode: item.inode)
            if let label = item.jobLabel, item.isDaemon, hooks.launchctl(["print", "system/\(label)"]) == 0 {
                step += " && /bin/launchctl bootout \(Self.quoted("system/\(label)"))"
                daemons.append(Job(label: label, domain: "system", plist: item.url.path))
            }
            moves.append(step)
            movers.append((item, destination, item.size ?? AppFootprint.allocatedSize(of: item.url)))
        }
        guard !(moves + forgets).isEmpty else { return }
        let script = (moves + forgets + ["exit 0"]).joined(separator: "; ")
        switch await hooks.admin(script, String(localized: "pikapik wants to remove what “\(app.displayName)” left behind.")) {
        case .cancelled:
            work.report.cancelled = true
            for item in queue { work.why[item.id] = .cancelled }
        default:
            for mover in movers where !exists(mover.item.url.path) && isSame(mover.destination, device: mover.item.device, inode: mover.item.inode) {
                work.record(entry(mover.item, trash: mover.destination, needsAdmin: true), bytes: mover.size)
            }
            for id in receipts where footprint.roots.pkgutil(["--pkg-info", id]) == nil {
                work.record(nil, bytes: 0)
            }
            work.jobs += daemons
        }
    }
}
