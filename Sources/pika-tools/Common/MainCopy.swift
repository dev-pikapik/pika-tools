import AppKit
import Observation

@Observable
final class MainCopy {
    enum Role { case waiting, main, passive, retired }

    static let shared = MainCopy(
        me: .own(),
        running: { NSWorkspace.shared.runningApplications.compactMap { RunningCopy($0) } },
        later: { DispatchQueue.main.asyncAfter(deadline: .now() + patience, execute: $0) },
        post: { DistributedNotificationCenter.default().postNotificationName($0, object: $1, userInfo: nil, deliverImmediately: true) }
    )
    static var canAct: Bool { shared.role == .main }

    static var journal: UserDefaults {
        let own = Bundle.main.bundleIdentifier ?? ""
        let domain = MainCopyChoice.journal(own)
        CFPreferencesAppSynchronize(domain as CFString)
        return domain == own ? .standard : UserDefaults(suiteName: domain) ?? .standard
    }

    private static let claim = Notification.Name("org.pikapik.main-copy.claim")
    private static let released = Notification.Name("org.pikapik.main-copy.released")
    private static let patience = 3.0

    private(set) var role = Role.waiting
    private(set) var leader: RunningCopy?
    @ObservationIgnored private var activate = {}
    @ObservationIgnored private var deactivate: (Bool) -> Void = { _ in }
    @ObservationIgnored private var awaited: Set<Int32> = []
    @ObservationIgnored private var timeout: DispatchWorkItem?
    @ObservationIgnored private var deferred = DeferredActions()
    @ObservationIgnored private var watching: NSKeyValueObservation?
    @ObservationIgnored let me: RunningCopy
    @ObservationIgnored private let running: () -> [RunningCopy]
    @ObservationIgnored private let later: (DispatchWorkItem) -> Void
    @ObservationIgnored private let send: (Notification.Name, String) -> Void

    init(me: RunningCopy, running: @escaping () -> [RunningCopy], later: @escaping (DispatchWorkItem) -> Void, post: @escaping (Notification.Name, String) -> Void) {
        (self.me, self.running, self.later, send) = (me, running, later, post)
    }

    var leaderCaption: (title: String, path: String?) {
        guard let leader, let app = NSRunningApplication(processIdentifier: leader.pid), let url = app.bundleURL else { return ("", nil) }
        let version = Bundle(url: url)?.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        switch leader.bundleID {
        case MainCopyChoice.appStoreID: return (String(localized: "Mac App Store version \(version)"), nil)
        case MainCopyChoice.websiteID: return (String(localized: "Website version \(version)"), nil)
        default: return (version, url.path)
        }
    }

    func begin(activate: @escaping () -> Void, deactivate: @escaping (Bool) -> Void) {
        watching = NSWorkspace.shared.observe(\.runningApplications) { [self] _, _ in evaluate() }
        let distributed = DistributedNotificationCenter.default()
        distributed.addObserver(forName: Self.claim, object: nil, queue: .main) { [self] note in
            if let pid = Self.sender(note) { claimed(by: pid) }
        }
        distributed.addObserver(forName: Self.released, object: nil, queue: .main) { [self] note in
            if let pid = Self.sender(note) { released(by: pid) }
        }
        start(activate: activate, deactivate: deactivate)
    }

    func start(activate: @escaping () -> Void, deactivate: @escaping (Bool) -> Void) {
        self.activate = activate
        self.deactivate = deactivate
        let others = peers()
        if MainCopyChoice.leader(me, among: others) != me { return release() }
        awaited = Set(others.map(\.pid))
        guard !awaited.isEmpty else { return become() }
        post(Self.claim)
        let work = DispatchWorkItem { [self] in become() }
        timeout = work
        later(work)
    }

    func claimed(by pid: Int32) {
        guard let claimant = peers().first(where: { $0.pid == pid }), MainCopyChoice.leader(me, among: [claimant]) == claimant else { return }
        role == .main || role == .waiting ? release() : post(Self.released)
    }

    func released(by pid: Int32) {
        awaited.remove(pid)
        proceedIfAlone()
    }

    func retire() {
        guard role == .main else { return }
        role = .retired
        deactivate(true)
    }

    func whenMain(_ action: @escaping () -> Void) {
        if role == .waiting { deferred.add(action) }
    }

    func makeMain(failed: @escaping () -> Void) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = ["--settings"]
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, error in
            if error != nil { DispatchQueue.main.async(execute: failed) }
        }
    }

    func evaluate() {
        guard role != .retired else { return }
        let peers = peers()
        let leader = MainCopyChoice.leader(me, among: peers)
        if leader != me {
            self.leader = leader
            release()
            if leader.bundleID == me.bundleID { Background.quit() }
        } else if role == .passive {
            become()
        } else if role == .waiting {
            awaited.formIntersection(peers.map(\.pid))
            proceedIfAlone()
        }
    }

    private func proceedIfAlone() {
        if role == .waiting, awaited.isEmpty { become() }
    }

    private func become() {
        timeout?.cancel()
        awaited = []
        leader = nil
        guard role != .main, MainCopyChoice.becomesMain(me, among: peers(), quitting: Background.shared.quitting) else { return }
        role = .main
        activate()
        deferred.run()
    }

    private func release() {
        guard role == .main || role == .waiting else { return }
        timeout?.cancel()
        awaited = []
        deferred.drop()
        let wasMain = role == .main
        role = .passive
        leader = leader ?? MainCopyChoice.leader(me, among: peers())
        if wasMain { deactivate(false) }
        post(Self.released)
    }

    func peers() -> [RunningCopy] {
        MainCopyChoice.peers(of: me, in: running())
    }

    private func post(_ name: Notification.Name) {
        send(name, String(me.pid))
    }

    private static func sender(_ note: Notification) -> Int32? {
        (note.object as? String).flatMap { Int32($0) }
    }
}
