import AppKit
import CoreServices

actor UninstallerEngine {
    struct Listing {
        let app: AppIdentity
        let stamp: Date
        let lastUsed: Date?
    }

    enum Dropped {
        case app(AppIdentity)
        case refused(String)
    }

    private struct Parts {
        let footprint: AppFootprint
        let remover: AppRemover
    }

    private var parts: Parts?

    private func ready() -> Parts {
        if let parts { return parts }
        let footprint = AppFootprint()
        let remover = AppRemover.live(
            footprint: footprint,
            confirmQuit: { _ in await UninstallerModel.shared.ask(force: false) },
            confirmForceQuit: { _ in await UninstallerModel.shared.ask(force: true) }
        )
        let built = Parts(footprint: footprint, remover: remover)
        parts = built
        return built
    }

    func reload() -> [Listing] {
        parts = nil
        return ready().footprint.installed.map { Listing(app: $0, stamp: Self.stamp($0.url), lastUsed: Self.lastUsed($0.url)) }
    }

    func identify(_ url: URL) -> Dropped? {
        guard let app = AppIdentity.read(at: url) else { return nil }
        let path = app.url.path
        let protected = path.hasPrefix("/System/") || app.bundleID.hasPrefix("com.pesotchi.pika-tools") || ready().footprint.system.contains { $0.url.path == path }
        return protected ? .refused(app.displayName) : .app(app)
    }

    func scan(_ app: AppIdentity) -> [Leftover] {
        ready().footprint.scan(app)
    }

    func remove(_ app: AppIdentity, items: [Leftover]) async -> AppRemover.Report {
        await ready().remover.remove(app, items: items)
    }

    func restore(_ record: AppRemover.Record) async -> AppRemover.Restoration {
        await ready().remover.restore(record)
    }

    static func measure(_ found: [Leftover]) -> Int64? {
        var total: Int64 = 0
        for item in found where item.preselected && item.packageID == nil {
            if Task.isCancelled { return nil }
            total += AppFootprint.allocatedSize(of: item.url)
        }
        return total
    }

    private static func stamp(_ url: URL) -> Date {
        [url, url.appendingPathComponent("Contents/Info.plist")]
            .compactMap { try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate }
            .max() ?? .distantPast
    }

    private static func lastUsed(_ url: URL) -> Date? {
        guard let item = MDItemCreateWithURL(nil, url as CFURL) else { return nil }
        return MDItemCopyAttribute(item, kMDItemLastUsedDate) as? Date
    }
}

@MainActor @Observable
final class AppEntry: Identifiable {
    nonisolated let id: String
    let app: AppIdentity
    let stamp: Date
    var size: Int64?
    var lastUsed: Date?
    var measured: Date?

    init(app: AppIdentity, stamp: Date, lastUsed: Date?) {
        id = app.id
        self.app = app
        self.stamp = stamp
        self.lastUsed = lastUsed
    }

    var isStale: Bool {
        measured.map { Date().timeIntervalSince($0) > 600 } ?? true
    }
}

@MainActor
final class Question {
    let force: Bool
    let name: String
    private var continuation: CheckedContinuation<Bool, Never>?

    init(force: Bool, name: String, continuation: CheckedContinuation<Bool, Never>) {
        self.force = force
        self.name = name
        self.continuation = continuation
    }

    func answer(_ value: Bool) {
        continuation?.resume(returning: value)
        continuation = nil
    }
}

@MainActor @Observable
final class UninstallSession: Identifiable {
    enum Phase {
        case scanning
        case choosing
        case removing
        case restoring
        case removed(AppRemover.Report)
        case restored(AppRemover.Restoration)
    }

    nonisolated let id: String
    let app: AppIdentity
    var plan = RemovalPlan([])
    var phase = Phase.scanning
    var question: Question?
    var notice: String?
    @ObservationIgnored var work: Task<Void, Never>?

    init(app: AppIdentity) {
        id = app.id
        self.app = app
    }

    var isBusy: Bool {
        switch phase {
        case .removing, .restoring: true
        default: false
        }
    }

    func apply(_ sizes: [String: Int64]) {
        plan.setSizes(sizes)
    }

    func answer(_ value: Bool) {
        question?.answer(value)
        question = nil
    }
}

@MainActor @Observable
final class UninstallerModel {
    static let shared = UninstallerModel()

    var shown: [AppEntry] = []
    var query = ""
    var sort = AppSort.name
    var running: Set<String> = []
    var plays = 0
    var notice: String?
    var session: UninstallSession?
    private(set) var loaded = false

    @ObservationIgnored private let engine = UninstallerEngine()
    @ObservationIgnored private var entries: [AppEntry] = []
    @ObservationIgnored private var known: [String: AppEntry] = [:]
    @ObservationIgnored private var icons: [String: NSImage] = [:]
    @ObservationIgnored private var urgent: [AppEntry] = []
    @ObservationIgnored private var pending: [AppEntry] = []
    @ObservationIgnored private var fill: Task<Void, Never>?
    @ObservationIgnored private var resorting: Task<Void, Never>?
    @ObservationIgnored private var hushing: Task<Void, Never>?

    private init() {}

    func appear() {
        refreshRunning()
        reload()
    }

    func disappear() {
        fill?.cancel()
    }

    func reload() {
        let previous = fill
        previous?.cancel()
        fill = Task {
            await previous?.value
            let listing = await engine.reload()
            guard !Task.isCancelled else { return }
            merge(listing)
            await measure()
        }
    }

    func reshuffle() {
        let byID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let found = AppSearch.filter(entries.map(\.app), query: query)
        let ordered = query.isEmpty || sort != .name ? sort.ordered(found, size: { byID[$0.id]?.size }, used: { byID[$0.id]?.lastUsed }) : found
        shown = ordered.compactMap { byID[$0.id] }
    }

    func want(_ entry: AppEntry) {
        guard entry.isStale, !urgent.contains(where: { $0 === entry }) else { return }
        urgent.append(entry)
    }

    func refreshRunning() {
        running = Set(NSWorkspace.shared.runningApplications.compactMap { $0.bundleURL?.path })
    }

    func icon(at url: URL) -> NSImage {
        if let icon = icons[url.path] { return icon }
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        icons[url.path] = icon
        return icon
    }

    func open(_ app: AppIdentity) {
        guard session == nil else { return }
        guard Permissions.shared.fileAccess else { return Permissions.shared.ask([.fullDisk]) }
        let opened = UninstallSession(app: app)
        session = opened
        opened.work = Task {
            let found = await engine.scan(app)
            guard !Task.isCancelled else { return }
            opened.plan = RemovalPlan(found)
            opened.phase = .choosing
            await size(opened)
        }
    }

    func open(dropped url: URL) {
        guard session == nil else { return }
        guard Permissions.shared.fileAccess else { return Permissions.shared.ask([.fullDisk]) }
        Task {
            switch await engine.identify(url) {
            case .app(let app): open(app)
            case .refused(let name): say(String(localized: "“\(name)” can’t be removed."))
            case nil: break
            }
        }
    }

    func remove(reset: Bool) {
        guard let current = session, case .choosing = current.phase else { return }
        let chosen = current.plan.chosen(reset: reset)
        guard !chosen.isEmpty else { return }
        current.work?.cancel()
        current.notice = nil
        current.phase = .removing
        current.work = Task {
            await pause()
            let report = await engine.remove(current.app, items: chosen)
            finish(current, report)
        }
    }

    func putBack() {
        guard let current = session, case .removed(let report) = current.phase, let record = report.record else { return }
        current.phase = .restoring
        current.work = Task {
            await pause()
            let result = await engine.restore(record)
            current.phase = .restored(result)
            reload()
        }
    }

    func close() {
        session?.work?.cancel()
        session = nil
    }

    func ask(force: Bool) async -> Bool {
        guard let current = session else { return false }
        return await withCheckedContinuation { continuation in
            current.question = Question(force: force, name: current.app.displayName, continuation: continuation)
        }
    }

    private func merge(_ listing: [UninstallerEngine.Listing]) {
        entries = listing.map { item in
            let old = known[item.app.id]
            if let old, old.stamp == item.stamp {
                old.lastUsed = item.lastUsed
                return old
            }
            let entry = AppEntry(app: item.app, stamp: item.stamp, lastUsed: item.lastUsed)
            entry.size = old?.size
            known[entry.id] = entry
            return entry
        }
        loaded = true
        reshuffle()
    }

    private func measure() async {
        guard Permissions.shared.fileAccess else { return }
        pending = entries.filter(\.isStale)
        while !Task.isCancelled, let entry = take() {
            let found = await engine.scan(entry.app)
            guard !Task.isCancelled, let size = await total(of: found) else { return }
            entry.size = size
            entry.measured = Date()
            resortSoon()
        }
    }

    private func take() -> AppEntry? {
        while !urgent.isEmpty || !pending.isEmpty {
            let entry = urgent.isEmpty ? pending.removeFirst() : urgent.removeFirst()
            if entry.isStale { return entry }
        }
        return nil
    }

    private func total(of found: [Leftover]) async -> Int64? {
        let job = Task.detached(priority: .utility) { UninstallerEngine.measure(found) }
        return await withTaskCancellationHandler { await job.value } onCancel: { job.cancel() }
    }

    private func resortSoon() {
        guard sort == .size, resorting == nil else { return }
        resorting = Task {
            try? await Task.sleep(for: .seconds(2))
            resorting = nil
            guard !Task.isCancelled else { return }
            reshuffle()
        }
    }

    private func size(_ opened: UninstallSession) async {
        let urls = opened.plan.items.filter { $0.size == nil }.map(\.url)
        let job = Task.detached(priority: .userInitiated) {
            var batch: [String: Int64] = [:]
            var flushed = Date()
            for url in urls {
                if Task.isCancelled { return }
                batch[url.path] = AppFootprint.allocatedSize(of: url)
                if Date().timeIntervalSince(flushed) > 0.25 {
                    await opened.apply(batch)
                    batch = [:]
                    flushed = Date()
                }
            }
            await opened.apply(batch)
        }
        await withTaskCancellationHandler { await job.value } onCancel: { job.cancel() }
    }

    private func pause() async {
        let task = fill
        task?.cancel()
        await task?.value
    }

    private func finish(_ current: UninstallSession, _ report: AppRemover.Report) {
        if report.removed == 0, report.survivors.isEmpty, !report.stillOpen.isEmpty {
            current.notice = String(localized: "Quit \(ListFormatter.localizedString(byJoining: report.stillOpen)) first, then try again.")
            current.phase = .choosing
        } else if report.removed == 0, report.record == nil, report.cancelled {
            current.phase = .choosing
        } else {
            current.phase = .removed(report)
            if report.record != nil { plays += 1 }
        }
        reload()
    }

    private func say(_ text: String) {
        notice = text
        hushing?.cancel()
        hushing = Task {
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            notice = nil
        }
    }
}
