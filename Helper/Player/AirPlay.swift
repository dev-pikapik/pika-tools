import AVFoundation
import AVKit
import AppKit

final class AirPlaySession {
    private let source: AirPlaySource
    private let queue = DispatchQueue(label: "pikapik.airplay.session")
    private var server: AirPlayServer?
    private var cache = AirPlayCache(limit: 128 << 20)
    private var pending: [String: [(AirPlayBuilt?) -> Void]] = [:]
    private var closed = false
    private var asked = false
    private(set) var url: URL

    var hasBeenAsked: Bool { queue.sync { asked } }

    init?(source: AirPlaySource) {
        guard let token = AirPlayNetwork.token(), let host = AirPlayNetwork.primary() else { return nil }
        self.source = source
        url = URL(fileURLWithPath: "/")
        let server = AirPlayServer(host: host, token: token, subnets: AirPlayNetwork.subnets()) { [weak self] route, reply in
            guard let self else { return reply(.notFound) }
            self.queue.async { self.handle(route, reply) }
        }
        guard server.start(), let link = URL(string: "http://\(AirPlayNetwork.text(host)):\(server.port)/\(token)/master.m3u8") else { return nil }
        url = link
        self.server = server
    }

    func close() {
        server?.stop()
        server = nil
        queue.sync {
            closed = true
            cache.removeAll()
        }
    }

    private func handle(_ route: AirPlayRoute, _ reply: @escaping (AirPlayResponse) -> Void) {
        guard !closed else { return reply(.notFound) }
        switch route {
        case .master:
            asked = true
            reply(playlist(source.master()))
        case let .playlist(kind, id):
            reply(source.playlist(kind: kind, id: id).map(playlist) ?? .notFound)
        case let .initSegment(kind, id):
            fetch(kind, id, 0) { built in
                reply(built.map { AirPlayResponse(type: kind == "a" ? "audio/mp4" : "video/mp4", body: $0.initData) } ?? .failed)
            }
        case let .segment(kind, id, index):
            fetch(kind, id, index) { built in
                reply(built.map { AirPlayResponse(type: kind == "a" ? "audio/mp4" : kind == "s" ? "text/vtt" : "video/mp4", body: $0.media) } ?? .failed)
            }
        }
    }

    private func playlist(_ text: String) -> AirPlayResponse {
        AirPlayResponse(type: "application/vnd.apple.mpegurl", body: Data(text.utf8))
    }

    private func fetch(_ kind: Character, _ id: String, _ index: Int, _ done: @escaping (AirPlayBuilt?) -> Void) {
        let key = "\(kind)/\(id)/\(index)"
        if let hit = cache.value(key) { return done(hit) }
        if pending[key] != nil {
            pending[key]?.append(done)
            return
        }
        pending[key] = [done]
        source.build(kind: kind, id: id, index: index) { [weak self] result in
            guard let self else { return done(nil) }
            self.queue.async {
                let built = try? result.get()
                if let built, !self.closed { self.cache.store(key, built) }
                for waiter in self.pending.removeValue(forKey: key) ?? [] { waiter(self.closed ? nil : built) }
            }
        }
    }
}

final class AirPlayLink: NSObject, AVRoutePickerViewDelegate {
    enum Event {
        case entered
        case left(CMTime, resume: Bool)
        case ended
        case playing(Bool)
        case problem(String)
    }

    let picker = AVRoutePickerView()
    var onEvent: (Event) -> Void = { _ in }
    var position: () -> CMTime = { .zero }
    private(set) var isActive = false
    private let player = AVPlayer()
    private var file: URL?
    private var source: AirPlaySource?
    private var session: AirPlaySession?
    private var opening = false
    private var observations: [NSKeyValueObservation] = []
    private var observers: [NSObjectProtocol] = []
    private var watchdog: DispatchWorkItem?
    private var seeks = 0
    private var wanted: Float = 0
    private var sleepObserver: NSObjectProtocol?

    override init() {
        super.init()
        player.allowsExternalPlayback = true
        picker.player = player
        picker.delegate = self
        picker.isRoutePickerButtonBordered = false
        picker.setRoutePickerButtonColor(.labelColor, for: .normal)
        picker.setRoutePickerButtonColor(.secondaryLabelColor, for: .normalHighlighted)
        picker.setRoutePickerButtonColor(.controlAccentColor, for: .active)
        picker.setRoutePickerButtonColor(.controlAccentColor, for: .activeHighlighted)
        sleepObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            self?.leave(resume: false)
        }
    }

    deinit {
        if let sleepObserver { NSWorkspace.shared.notificationCenter.removeObserver(sleepObserver) }
    }

    func open(_ url: URL) {
        close()
        file = url
    }

    func close() {
        teardown()
        source = nil
        file = nil
    }

    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        prepare()
    }

    func command(time: CMTime?, rate: Float) {
        guard isActive else { return }
        wanted = rate
        guard let time else { return apply() }
        seeks += 1
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            DispatchQueue.main.async {
                self?.seeks -= 1
                self?.apply()
            }
        }
    }

    func follow(_ clock: AVSampleBufferRenderSynchronizer) {
        guard isActive, seeks == 0, player.currentItem?.status == .readyToPlay else { return }
        let time = player.currentTime()
        guard time.isValid, abs(clock.currentTime().seconds - time.seconds) > 0.5 else { return }
        clock.setRate(clock.rate, time: time)
    }

    private func apply() {
        if wanted > 0 { player.rate = wanted } else { player.pause() }
    }

    private func prepare() {
        guard let file, session == nil, !opening else { return }
        if let source { return begin(source) }
        opening = true
        DispatchQueue.global(qos: .userInitiated).async {
            let opened = try? AirPlaySource.open(file)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.opening = false
                guard self.file == file, let opened else { return }
                self.source = opened
                self.begin(opened)
            }
        }
    }

    private func begin(_ source: AirPlaySource) {
        guard session == nil, let made = AirPlaySession(source: source) else { return }
        session = made
        let item = AVPlayerItem(url: made.url)
        observations = [
            player.observe(\.isExternalPlaybackActive, options: [.initial, .new]) { [weak self] player, _ in
                let active = player.isExternalPlaybackActive
                DispatchQueue.main.async { self?.routeChanged(active) }
            },
            player.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] _, change in
                guard let old = change.oldValue, let new = change.newValue else { return }
                DispatchQueue.main.async { self?.statusChanged(old, new) }
            },
            item.observe(\.status, options: [.new]) { [weak self] item, _ in
                guard item.status == .failed else { return }
                DispatchQueue.main.async { self?.stopped() }
            },
        ]
        observers = [
            NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: item, queue: .main) { [weak self] _ in self?.onEvent(.ended) },
            NotificationCenter.default.addObserver(forName: AVPlayerItem.failedToPlayToEndTimeNotification, object: item, queue: .main) { [weak self] _ in self?.stopped() },
        ]
        player.replaceCurrentItem(with: item)
        item.seek(to: position(), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: nil)
        let work = DispatchWorkItem { [weak self] in
            if self?.isActive == false { self?.teardown() }
        }
        watchdog = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: work)
    }

    private func routeChanged(_ active: Bool) {
        guard session != nil else { return }
        if active, !isActive {
            isActive = true
            watchdog?.cancel()
            onEvent(.entered)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                if let self, self.isActive, self.session?.hasBeenAsked == false { self.stopped() }
            }
        } else if !active, isActive {
            leave(resume: true)
        }
    }

    private func statusChanged(_ old: AVPlayer.TimeControlStatus, _ new: AVPlayer.TimeControlStatus) {
        guard isActive, seeks == 0 else { return }
        if old == .playing, new == .paused {
            onEvent(.playing(false))
        } else if old == .paused, new != .paused {
            onEvent(.playing(true))
        }
    }

    private func stopped() {
        guard isActive, let session else { return teardown() }
        let asked = session.hasBeenAsked
        leave(resume: true)
        DispatchQueue.global().async {
            let blocked = asked ? nil : Self.firewallBlocksAll()
            DispatchQueue.main.async { [weak self] in self?.onEvent(.problem(AirPlayAdvice.text(blockAll: blocked, asked: asked))) }
        }
    }

    private func leave(resume: Bool) {
        guard session != nil else { return }
        let time = player.currentTime()
        let was = isActive
        teardown()
        if was { onEvent(.left(time.isValid ? time : position(), resume: resume)) }
    }

    private func teardown() {
        watchdog?.cancel()
        watchdog = nil
        observations = []
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        observers = []
        player.pause()
        player.replaceCurrentItem(with: nil)
        session?.close()
        session = nil
        isActive = false
        seeks = 0
        wanted = 0
    }

    private static func firewallBlocksAll() -> Bool? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/libexec/ApplicationFirewall/socketfilterfw")
        process.arguments = ["--getblockall"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        let done = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in done.signal() }
        guard (try? process.run()) != nil else { return nil }
        if done.wait(timeout: .now() + 3) == .timedOut {
            process.terminate()
            return nil
        }
        return AirPlayFirewall.blockAll(String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self))
    }
}
