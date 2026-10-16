import Foundation
import Network
import Security

enum AirPlayRoute: Equatable {
    case master
    case playlist(kind: Character, id: String)
    case initSegment(kind: Character, id: String)
    case segment(kind: Character, id: String, index: Int)
}

struct AirPlayResponse {
    var status = 200
    var type = "application/octet-stream"
    var body = Data()

    static let notFound = AirPlayResponse(status: 404, type: "text/plain", body: Data("Not found".utf8))
    static let failed = AirPlayResponse(status: 500, type: "text/plain", body: Data("Could not prepare".utf8))
}

enum AirPlayRouter {
    private static let characters = Set("abcdefghijklmnopqrstuvwxyz0123456789./".utf8)

    static func parse(_ target: String, token: String) -> AirPlayRoute? {
        guard target.utf8.count <= 96, target.utf8.allSatisfy(characters.contains) else { return nil }
        let parts = target.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 3, parts[0].isEmpty, same(parts[1], token) else { return nil }
        let rest = Array(parts.dropFirst(2))
        if rest == ["master.m3u8"] { return .master }
        guard let kind = rest.first.flatMap({ $0.count == 1 ? $0.first : nil }), "vas".contains(kind), rest.count >= 2, rest.count <= 3 else { return nil }
        if rest.count == 2 {
            guard rest[1].hasSuffix(".m3u8"), let id = identifier(String(rest[1].dropLast(5))) else { return nil }
            return .playlist(kind: kind, id: id)
        }
        guard let id = identifier(rest[1]) else { return nil }
        if rest[2] == "init.mp4" { return kind == "s" ? nil : .initSegment(kind: kind, id: id) }
        let suffix = kind == "s" ? ".vtt" : ".m4s"
        guard rest[2].hasSuffix(suffix), let index = number(String(rest[2].dropLast(suffix.count))) else { return nil }
        return .segment(kind: kind, id: id, index: index)
    }

    private static func identifier(_ text: String) -> String? {
        text.count >= 1 && text.count <= 8 && !text.contains(".") ? text : nil
    }

    private static func number(_ text: String) -> Int? {
        text.count >= 1 && text.count <= 6 && text.utf8.allSatisfy { $0 >= 48 && $0 <= 57 } ? Int(text) : nil
    }

    static func same(_ a: String, _ b: String) -> Bool {
        let (x, y) = (Array(a.utf8), Array(b.utf8))
        var difference = x.count ^ y.count
        for i in 0..<max(x.count, y.count) { difference |= Int(i < x.count ? x[i] : 0) ^ Int(i < y.count ? y[i] : 0) }
        return difference == 0
    }
}

struct AirPlaySubnet: Equatable {
    let network: UInt32
    let mask: UInt32

    func contains(_ address: UInt32) -> Bool { address & mask == network }
}

enum AirPlayNetwork {
    static func token() -> String? {
        var bytes = [UInt8](repeating: 0, count: 16)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else { return nil }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func interfaces() -> [(name: String, address: UInt32, mask: UInt32)] {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return [] }
        defer { freeifaddrs(list) }
        var found: [(String, UInt32, UInt32)] = []
        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let entry = cursor?.pointee {
            defer { cursor = entry.ifa_next }
            let flags = Int32(entry.ifa_flags)
            guard flags & IFF_UP != 0, flags & IFF_RUNNING != 0, let address = entry.ifa_addr, let netmask = entry.ifa_netmask, address.pointee.sa_family == sa_family_t(AF_INET) else { continue }
            let ip = address.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { UInt32(bigEndian: $0.pointee.sin_addr.s_addr) }
            let mask = netmask.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { UInt32(bigEndian: $0.pointee.sin_addr.s_addr) }
            found.append((String(cString: entry.ifa_name), ip, mask))
        }
        return found
    }

    static func subnets() -> [AirPlaySubnet] {
        interfaces().map { AirPlaySubnet(network: $0.address & $0.mask, mask: $0.mask) }
            + [AirPlaySubnet(network: 0xA9FE_0000, mask: 0xFFFF_0000)]
    }

    static func primary() -> UInt32? {
        let usable = interfaces().filter { $0.address >> 24 != 127 && $0.address >> 16 != 0xA9FE }
        let wired = usable.filter { $0.name.hasPrefix("en") }
        return (wired.first { $0.name == "en0" } ?? wired.first ?? usable.first { !$0.name.hasPrefix("utun") && !$0.name.hasPrefix("awdl") && !$0.name.hasPrefix("llw") })?.address
    }

    static func text(_ address: UInt32) -> String {
        "\(address >> 24).\(address >> 16 & 255).\(address >> 8 & 255).\(address & 255)"
    }
}

final class AirPlayServer {
    typealias Handler = (AirPlayRoute, @escaping (AirPlayResponse) -> Void) -> Void

    static let limit = 16
    private let host: UInt32
    private let token: String
    private let subnets: [AirPlaySubnet]
    private let handler: Handler
    private let queue = DispatchQueue(label: "pikapik.airplay.server")
    private var listener: NWListener?
    private var connections: [ObjectIdentifier: NWConnection] = [:]
    private var closed = false
    private(set) var port: UInt16 = 0

    init(host: UInt32, token: String, subnets: [AirPlaySubnet], handler: @escaping Handler) {
        self.host = host
        self.token = token
        self.subnets = subnets
        self.handler = handler
    }

    func start() -> Bool {
        let parameters = NWParameters.tcp
        guard let address = IPv4Address(Data([UInt8(host >> 24), UInt8(host >> 16 & 255), UInt8(host >> 8 & 255), UInt8(host & 255)])) else { return false }
        parameters.requiredLocalEndpoint = .hostPort(host: .ipv4(address), port: .any)
        guard let listener = try? NWListener(using: parameters) else { return false }
        let ready = DispatchSemaphore(value: 0)
        var started = false
        listener.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.port = listener.port?.rawValue ?? 0
                started = self?.port != 0
                ready.signal()
            case .failed, .cancelled:
                ready.signal()
            default: break
            }
        }
        listener.newConnectionHandler = { [weak self] connection in self?.accept(connection) }
        self.listener = listener
        listener.start(queue: queue)
        guard ready.wait(timeout: .now() + 5) == .success, started else {
            stop()
            return false
        }
        return true
    }

    func stop() {
        let done = DispatchSemaphore(value: 0)
        queue.async {
            self.closed = true
            self.listener?.cancel()
            self.listener = nil
            for connection in self.connections.values { connection.cancel() }
            self.connections = [:]
            done.signal()
        }
        _ = done.wait(timeout: .now() + 2)
    }

    private func accept(_ connection: NWConnection) {
        guard !closed, connections.count < Self.limit, case .hostPort(let remote, _) = connection.endpoint, case .ipv4(let address) = remote, address.rawValue.count == 4 else {
            connection.cancel()
            return
        }
        let value = address.rawValue.reduce(UInt32(0)) { $0 << 8 | UInt32($1) }
        guard subnets.contains(where: { $0.contains(value) }) else {
            connection.cancel()
            return
        }
        let id = ObjectIdentifier(connection)
        connections[id] = connection
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed, .cancelled: self?.queue.async { self?.connections[id] = nil }
            default: break
            }
        }
        connection.start(queue: queue)
        receive(connection, Data())
    }

    private func receive(_ connection: NWConnection, _ buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, complete, error in
            guard let self, !self.closed else { return connection.cancel() }
            var buffer = buffer
            if let data { buffer.append(data) }
            if let end = buffer.range(of: Data("\r\n\r\n".utf8)) {
                self.serve(connection, head: String(decoding: buffer[..<end.lowerBound], as: UTF8.self))
            } else if error != nil || complete || buffer.count > 8192 {
                connection.cancel()
            } else {
                self.receive(connection, buffer)
            }
        }
    }

    private func serve(_ connection: NWConnection, head: String) {
        let lines = head.components(separatedBy: "\r\n")
        let words = lines[0].components(separatedBy: " ")
        guard words.count == 3, ["GET", "HEAD"].contains(words[0]), ["HTTP/1.1", "HTTP/1.0"].contains(words[2]) else {
            return send(connection, AirPlayResponse(status: 400, type: "text/plain", body: Data("Bad request".utf8)), head: false, range: nil, keep: false)
        }
        var range: String?
        var keep = words[2] == "HTTP/1.1"
        for line in lines.dropFirst() {
            let pair = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard pair.count == 2 else { continue }
            switch pair[0].lowercased() {
            case "range": range = pair[1]
            case "connection": keep = pair[1].lowercased() == "keep-alive" || (keep && pair[1].lowercased() != "close")
            default: break
            }
        }
        let headOnly = words[0] == "HEAD"
        guard let route = AirPlayRouter.parse(words[1], token: token) else {
            return send(connection, .notFound, head: headOnly, range: nil, keep: false)
        }
        handler(route) { [weak self] response in
            self?.queue.async { self?.send(connection, response, head: headOnly, range: range, keep: keep) }
        }
    }

    static func slice(_ range: String?, of size: Int) -> (ClosedRange<Int>?, valid: Bool) {
        guard let range else { return (nil, true) }
        guard range.hasPrefix("bytes="), !range.contains(","), size > 0 else { return (nil, false) }
        let parts = range.dropFirst(6).split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 2 else { return (nil, false) }
        switch (Int(parts[0]), Int(parts[1])) {
        case let (first?, last?) where first <= last && first < size: return (first...min(last, size - 1), true)
        case let (first?, nil) where parts[1].isEmpty && first < size: return (first...(size - 1), true)
        case let (nil, count?) where parts[0].isEmpty && count > 0: return (max(0, size - count)...(size - 1), true)
        default: return (nil, false)
        }
    }

    private func send(_ connection: NWConnection, _ response: AirPlayResponse, head: Bool, range: String?, keep: Bool) {
        guard !closed else { return connection.cancel() }
        var status = response.status
        var body = response.body
        var headers = ["Content-Type: \(response.type)", "Accept-Ranges: bytes", "Cache-Control: no-store", "Connection: \(keep ? "keep-alive" : "close")"]
        if status == 200 {
            let (slice, valid) = Self.slice(range, of: body.count)
            if !valid {
                status = 416
                headers.append("Content-Range: bytes */\(body.count)")
                body = Data()
            } else if let slice {
                headers.append("Content-Range: bytes \(slice.lowerBound)-\(slice.upperBound)/\(body.count)")
                body = body.subdata(in: slice.lowerBound..<(slice.upperBound + 1))
                status = 206
            }
        }
        headers.append("Content-Length: \(body.count)")
        let reason = [200: "OK", 206: "Partial Content", 400: "Bad Request", 404: "Not Found", 416: "Range Not Satisfiable", 500: "Internal Server Error"][status] ?? "OK"
        let top = Data(("HTTP/1.1 \(status) \(reason)\r\n" + headers.joined(separator: "\r\n") + "\r\n\r\n").utf8)
        let finish: (NWError?) -> Void = { [weak self] error in
            if error != nil || !keep { connection.cancel() } else { self?.receive(connection, Data()) }
        }
        if head || body.isEmpty {
            connection.send(content: top, completion: .contentProcessed(finish))
        } else {
            connection.send(content: top, completion: .contentProcessed { error in
                if error != nil { return connection.cancel() }
                connection.send(content: body, completion: .contentProcessed(finish))
            })
        }
    }
}
