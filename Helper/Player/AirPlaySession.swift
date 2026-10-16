import Foundation

protocol AirPlayContent: AnyObject {
    func master() -> String
    func playlist(kind: Character, id: String) -> String?
    func build(kind: Character, id: String, index: Int, _ done: @escaping (Result<AirPlayBuilt, Error>) -> Void)
}

final class AirPlaySession {
    private let open: () -> AirPlayContent?
    private let local: Set<UInt32>
    private let queue = DispatchQueue(label: "pikapik.airplay.session")
    private var server: AirPlayServer?
    private var content: AirPlayContent?
    private var opening = false
    private var waiting: [(AirPlayContent?) -> Void] = []
    private var cache = AirPlayCache(limit: 128 << 20)
    private var pending: [String: [(AirPlayBuilt?) -> Void]] = [:]
    private var closed = false
    private var asked = false
    private(set) var url: URL

    var hasBeenAsked: Bool { queue.sync { asked } }
    var cachedBytes: Int { queue.sync { cache.bytes } }

    init?(host: UInt32? = AirPlayNetwork.primary(), subnets: [AirPlaySubnet] = AirPlayNetwork.subnets(), local: [UInt32] = AirPlayNetwork.addresses(),
          limits: AirPlayServer.Limits = AirPlayServer.Limits(), open: @escaping () -> AirPlayContent?) {
        guard let token = AirPlayNetwork.token(), let host else { return nil }
        self.open = open
        self.local = Set(local)
        url = URL(fileURLWithPath: "/")
        let server = AirPlayServer(host: host, token: token, subnets: subnets, limits: limits) { [weak self] route, client, reply in
            guard let self else { return reply(.notFound) }
            self.queue.async { self.handle(route, client, reply) }
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
            content = nil
            pending = [:]
            let list = waiting
            waiting = []
            for body in list { body(nil) }
        }
    }

    private func withContent(_ body: @escaping (AirPlayContent?) -> Void) {
        if let content { return body(content) }
        waiting.append(body)
        guard !opening else { return }
        opening = true
        DispatchQueue.global(qos: .userInitiated).async {
            let opened = self.open()
            self.queue.async {
                self.opening = false
                if !self.closed { self.content = opened }
                let list = self.waiting
                self.waiting = []
                for body in list { body(self.closed ? nil : opened) }
            }
        }
    }

    private func handle(_ route: AirPlayRoute, _ client: UInt32, _ reply: @escaping (AirPlayResponse) -> Void) {
        guard !closed else { return reply(.notFound) }
        if case .master = route, !local.contains(client) { asked = true }
        withContent { content in
            guard let content else { return reply(.failed) }
            switch route {
            case .master:
                reply(self.playlist(content.master()))
            case let .playlist(kind, id):
                reply(content.playlist(kind: kind, id: id).map(self.playlist) ?? .notFound)
            case let .initSegment(kind, id):
                self.fetch(content, kind, id, 0) { built in
                    reply(built.map { AirPlayResponse(type: kind == "a" ? "audio/mp4" : "video/mp4", body: $0.initData) } ?? .failed)
                }
            case let .segment(kind, id, index):
                self.fetch(content, kind, id, index) { built in
                    reply(built.map { AirPlayResponse(type: kind == "a" ? "audio/mp4" : kind == "s" ? "text/vtt" : "video/mp4", body: $0.media) } ?? .failed)
                }
            }
        }
    }

    private func playlist(_ text: String) -> AirPlayResponse {
        AirPlayResponse(type: "application/vnd.apple.mpegurl", body: Data(text.utf8))
    }

    private func fetch(_ content: AirPlayContent, _ kind: Character, _ id: String, _ index: Int, _ done: @escaping (AirPlayBuilt?) -> Void) {
        let key = "\(kind)/\(id)/\(index)"
        if let hit = cache.value(key) { return done(hit) }
        if pending[key] != nil {
            pending[key]?.append(done)
            return
        }
        pending[key] = [done]
        content.build(kind: kind, id: id, index: index) { [weak self] result in
            guard let self else { return done(nil) }
            self.queue.async {
                let built = try? result.get()
                if let built, !self.closed { self.cache.store(key, built) }
                for waiter in self.pending.removeValue(forKey: key) ?? [] { waiter(self.closed ? nil : built) }
            }
        }
    }
}
