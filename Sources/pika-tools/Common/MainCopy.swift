import AppKit
import SwiftUI

@Observable
final class MainCopy {
    enum Role { case waiting, main, passive, retired }

    static let shared = MainCopy()
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
    @ObservationIgnored let me = RunningCopy(pid: getpid(), bundleID: Bundle.main.bundleIdentifier ?? "", launched: MainCopyChoice.started(getpid()) ?? .distantPast)

    private init() {}

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
        self.activate = activate
        self.deactivate = deactivate
        watching = NSWorkspace.shared.observe(\.runningApplications) { [self] _, _ in evaluate() }
        let distributed = DistributedNotificationCenter.default()
        distributed.addObserver(forName: Self.claim, object: nil, queue: .main) { [self] note in
            guard let pid = Self.sender(note), let claimant = peers().first(where: { $0.pid == pid }),
                  MainCopyChoice.leader(me, among: [claimant]) == claimant else { return }
            role == .main || role == .waiting ? release() : post(Self.released)
        }
        distributed.addObserver(forName: Self.released, object: nil, queue: .main) { [self] note in
            guard let pid = Self.sender(note) else { return }
            awaited.remove(pid)
            proceedIfAlone()
        }
        let others = peers()
        if MainCopyChoice.leader(me, among: others) != me { return release() }
        awaited = Set(others.map(\.pid))
        guard !awaited.isEmpty else { return become() }
        post(Self.claim)
        let work = DispatchWorkItem { [self] in become() }
        timeout = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.patience, execute: work)
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

    private func evaluate() {
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
        guard role != .main else { return }
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
        MainCopyChoice.peers(of: me, in: NSWorkspace.shared.runningApplications.compactMap(Self.copy))
    }

    private func post(_ name: Notification.Name) {
        DistributedNotificationCenter.default().postNotificationName(name, object: String(me.pid), userInfo: nil, deliverImmediately: true)
    }

    private static func sender(_ note: Notification) -> Int32? {
        (note.object as? String).flatMap { Int32($0) }
    }

    private static func copy(_ app: NSRunningApplication) -> RunningCopy? {
        guard !app.isTerminated, let id = app.bundleIdentifier, let launched = MainCopyChoice.started(app.processIdentifier) else { return nil }
        return RunningCopy(pid: app.processIdentifier, bundleID: id, launched: launched)
    }
}

struct PassiveCopyView: View {
    private let copy = MainCopy.shared
    @State private var starting = false

    var body: some View {
        let caption = copy.leaderCaption
        ContentUnavailableView {
            Label("Another copy of pikapik is in charge", systemImage: "rectangle.on.rectangle")
        } description: {
            Text("This copy changes nothing on your Mac and takes over when the other copy quits.")
            Text(verbatim: caption.title)
            if let path = caption.path {
                Text(verbatim: path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        } actions: {
            Button("Make This Copy the Main One") {
                starting = true
                copy.makeMain { starting = false }
            }
            .buttonStyle(.borderedProminent)
            .disabled(starting)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Text(verbatim: "pikapik"))
        .onAppear { SettingsWindow.window?.title = "pikapik" }
    }
}
