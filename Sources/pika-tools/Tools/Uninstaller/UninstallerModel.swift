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
        let protected = app.bundleID.hasPrefix("com.pesotchi.pika-tools") || ready().footprint.isSystem(app)
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

    func records() -> [AppRemover.Record] {
        ready().remover.records()
    }

    func trashed() -> [AppIdentity] {
        ready().footprint.trashed()
    }

    func orphans() -> [OrphanGroup] {
        ready().footprint.orphans()
    }

    func offer(_ url: URL, dismissed: Set<String>) -> AppIdentity? {
        parts = nil
        let parts = ready()
        guard !parts.remover.records().contains(where: { $0.moves.contains { $0.trash == url.path } }),
              let app = parts.footprint.trashed().first(where: { $0.url.path == url.path }),
              !dismissed.contains(app.dismissalKey),
              parts.footprint.scan(app).contains(where: { $0.kind != .app })
        else { return nil }
        return app
    }

    static func measure(_ found: [Leftover], everything: Bool = false) -> Int64? {
        var total: Int64 = 0
        for item in found where (everything || item.preselected) && item.packageID == nil && !AppInventory.isInTrash(item.url) {
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

struct Remnant: Identifiable {
    let app: AppIdentity
    let items: [Leftover]
    var changed: Date?
    var size: Int64?

    var id: String { app.id }
}

struct Removal: Identifiable {
    enum State {
        case idle
        case working
        case done(AppRemover.Restoration)
    }

    let record: AppRemover.Record
    var state = State.idle

    var id: String { record.id }
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
    let leftoversOnly: Bool
    var plan = RemovalPlan([])
    var phase = Phase.scanning
    var question: Question?
    var notice: String?
    @ObservationIgnored var work: Task<Void, Never>?

    init(app: AppIdentity, leftoversOnly: Bool = false) {
        id = app.id
        self.app = app
        self.leftoversOnly = leftoversOnly
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
    var notice: String?
    var trashed: [Remnant] = []
    var orphans: [Remnant] = []
    var removed: [Removal] = []
    var session: UninstallSession? {
        didSet {
            if session == nil, let ended = oldValue { settle(ended) }
        }
    }
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
    @ObservationIgnored private var candidates: [URL] = []
    @ObservationIgnored private var dismissed: Set<String> = []
    @ObservationIgnored private var draining = false

    private init() {}

    func appear() {
        refreshRunning()
        removed.removeAll { if case .done = $0.state { true } else { false } }
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
            await gather()
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

    func icon(of app: AppIdentity) -> NSImage {
        icons[app.url.path] ?? (FileManager.default.fileExists(atPath: app.url.path) ? icon(at: app.url) : NSWorkspace.shared.icon(for: .applicationBundle))
    }

    func open(_ app: AppIdentity, notice: String? = nil) {
        guard let opened = start(app, leftoversOnly: false) else { return }
        opened.notice = notice
        opened.work = Task {
            let found = await engine.scan(app)
            guard !Task.isCancelled else { return }
            opened.plan = RemovalPlan(found)
            opened.phase = .choosing
            await size(opened)
        }
    }

    func open(leftovers group: Remnant) {
        guard let opened = start(group.app, leftoversOnly: true) else { return }
        opened.notice = String(localized: "Looks like the app is gone. Pick what to remove.")
        opened.work = Task {
            opened.plan = RemovalPlan(group.items)
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

    func putBack(_ record: AppRemover.Record) {
        guard let index = removed.firstIndex(where: { $0.id == record.id }), case .idle = removed[index].state else { return }
        removed[index].state = .working
        Task {
            await pause()
            let result = await engine.restore(record)
            if let index = removed.firstIndex(where: { $0.id == record.id }) { removed[index].state = .done(result) }
            reload()
        }
    }

    func offer(_ urls: [URL]) {
        candidates += urls.filter { !candidates.contains($0) }
        drain()
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

    private func start(_ app: AppIdentity, leftoversOnly: Bool) -> UninstallSession? {
        guard session == nil else { return nil }
        guard Permissions.shared.fileAccess else {
            Permissions.shared.ask([.fullDisk])
            return nil
        }
        let opened = UninstallSession(app: app, leftoversOnly: leftoversOnly)
        session = opened
        return opened
    }

    private func settle(_ ended: UninstallSession) {
        if AppInventory.isInTrash(ended.app.url) { dismissed.insert(ended.app.dismissalKey) }
        drain()
    }

    private func drain() {
        guard !draining, session == nil, !candidates.isEmpty, Permissions.shared.fileAccess else { return }
        draining = true
        Task {
            defer { draining = false }
            while session == nil, !candidates.isEmpty {
                let url = candidates.removeFirst()
                guard let app = await engine.offer(url, dismissed: dismissed) else { continue }
                guard session == nil else {
                    candidates.insert(url, at: 0)
                    break
                }
                SettingsWindow.show(.uninstaller)
                open(app, notice: String(localized: "You moved this app to the Trash, but its files are still on your Mac."))
            }
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

    private func gather() async {
        guard Permissions.shared.fileAccess else {
            trashed = []
            orphans = []
            removed = []
            return
        }
        updateRemoved(await engine.records())
        var apps: [Remnant] = []
        for app in await engine.trashed() {
            let items = await engine.scan(app).filter { $0.kind != .app }
            if !items.isEmpty { apps.append(Remnant(app: app, items: items)) }
        }
        let groups = await engine.orphans().map { Remnant(app: AppIdentity(leftovers: $0), items: $0.items, changed: $0.newest) }
        guard !Task.isCancelled else { return }
        trashed = Self.carrying(apps, over: trashed)
        orphans = Self.carrying(groups, over: orphans)
        for item in trashed where item.size == nil {
            guard !Task.isCancelled, let size = await total(of: item.items) else { return }
            if let index = trashed.firstIndex(where: { $0.id == item.id }) { trashed[index].size = size }
        }
        for item in orphans where item.size == nil {
            guard !Task.isCancelled, let size = await total(of: item.items, everything: true) else { return }
            if let index = orphans.firstIndex(where: { $0.id == item.id }) { orphans[index].size = size }
        }
    }

    private func updateRemoved(_ fresh: [AppRemover.Record]) {
        let busy = removed.filter { if case .idle = $0.state { false } else { true } }
        let known = Set(busy.map(\.id))
        removed = (busy + fresh.filter { !known.contains($0.id) }.map { Removal(record: $0) }).sorted { $0.record.date > $1.record.date }
    }

    private static func carrying(_ fresh: [Remnant], over old: [Remnant]) -> [Remnant] {
        let before = Dictionary(old.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return fresh.map { item in
            var item = item
            if let earlier = before[item.id], earlier.items == item.items { item.size = earlier.size }
            return item
        }
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

    private func total(of found: [Leftover], everything: Bool = false) async -> Int64? {
        let job = Task.detached(priority: .utility) { UninstallerEngine.measure(found, everything: everything) }
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
