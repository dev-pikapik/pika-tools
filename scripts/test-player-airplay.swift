import AVFoundation
import Foundation

private func check(_ condition: Bool, _ message: String) {
    precondition(condition, message)
}

private func be(_ data: Data, _ at: Int, _ count: Int) -> Int {
    (0..<count).reduce(0) { $0 << 8 | Int(data[at + $1]) }
}

private struct Box {
    let name: String
    let payload: Range<Int>
}

private func boxes(_ data: Data, in range: Range<Int>) -> [Box] {
    var found: [Box] = []
    var at = range.lowerBound
    while at + 8 <= range.upperBound {
        let size = be(data, at, 4)
        guard size >= 8, at + size <= range.upperBound else { break }
        found.append(Box(name: String(decoding: data[at + 4..<at + 8], as: UTF8.self), payload: at + 8..<at + size))
        at += size
    }
    return found
}

private func find(_ data: Data, _ path: [String], in range: Range<Int>? = nil) -> Range<Int>? {
    let range = range ?? 0..<data.count
    guard let name = path.first, let box = boxes(data, in: range).first(where: { $0.name == name }) else { return nil }
    return path.count == 1 ? box.payload : find(data, Array(path.dropFirst()), in: box.payload)
}

private func timescale(_ initData: Data) -> Int {
    find(initData, ["moov", "trak", "mdia", "mdhd"]).map { be(initData, $0.lowerBound + (be(initData, $0.lowerBound, 1) == 1 ? 20 : 12), 4) } ?? 1
}

private func merged(_ list: [Fragment], segment: Int) -> Fragment {
    check(!list.isEmpty && list[0].number == segment * 256 + 1, "segment \(segment) has its own sequence number")
    for (before, after) in zip(list, list.dropFirst()) {
        check(after.number == before.number + 1 && before.start + before.total == after.start, "the fragments inside segment \(segment) follow each other")
    }
    return Fragment(number: list[0].number, start: list[0].start, durations: list.flatMap(\.durations), firstIsSync: list[0].firstIsSync)
}

private struct Fragment {
    var number: Int
    var start: Int
    var durations: [Int]
    var firstIsSync: Bool
    var total: Int { durations.reduce(0, +) }
}

private func fragments(_ data: Data) -> [Fragment] {
    var result: [Fragment] = []
    for moof in boxes(data, in: 0..<data.count) where moof.name == "moof" {
        guard let mfhd = find(data, ["mfhd"], in: moof.payload), let traf = find(data, ["traf"], in: moof.payload),
              let tfhd = find(data, ["tfhd"], in: traf), let tfdt = find(data, ["tfdt"], in: traf) else { continue }
        let tfhdFlags = be(data, tfhd.lowerBound, 4) & 0xFFFFFF
        var at = tfhd.lowerBound + 8
        if tfhdFlags & 1 != 0 { at += 8 }
        if tfhdFlags & 2 != 0 { at += 4 }
        let defaultDuration = tfhdFlags & 8 != 0 ? be(data, at, 4) : 0
        var durations: [Int] = []
        var firstFlags: Int?
        for run in boxes(data, in: traf) where run.name == "trun" {
            let flags = be(data, run.payload.lowerBound, 4) & 0xFFFFFF
            let count = be(data, run.payload.lowerBound + 4, 4)
            var cursor = run.payload.lowerBound + 8
            if flags & 1 != 0 { cursor += 4 }
            if flags & 4 != 0 {
                if firstFlags == nil { firstFlags = be(data, cursor, 4) }
                cursor += 4
            }
            for _ in 0..<count {
                if flags & 0x100 != 0 {
                    durations.append(be(data, cursor, 4))
                    cursor += 4
                } else {
                    durations.append(defaultDuration)
                }
                if flags & 0x200 != 0 { cursor += 4 }
                if flags & 0x400 != 0 {
                    if firstFlags == nil { firstFlags = be(data, cursor, 4) }
                    cursor += 4
                }
                if flags & 0x800 != 0 { cursor += 4 }
            }
        }
        result.append(Fragment(number: be(data, mfhd.lowerBound + 4, 4), start: be(data, tfdt.lowerBound + 4, be(data, tfdt.lowerBound, 1) == 1 ? 8 : 4), durations: durations, firstIsSync: (firstFlags ?? 0) & 0x10000 == 0))
    }
    return result
}

private final class Calls: @unchecked Sendable {
    private let lock = NSLock()
    private var routes: [AirPlayRoute] = []
    var count: Int { lock.withLock { routes.count } }
    func add(_ route: AirPlayRoute) { lock.withLock { routes.append(route) } }
}

private func request(_ port: UInt16, _ raw: String) -> (status: Int?, text: String) {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    defer { close(fd) }
    var timeout = timeval(tv_sec: 3, tv_usec: 0)
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
    var address = sockaddr_in()
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = port.bigEndian
    address.sin_addr.s_addr = UInt32(0x7F00_0001).bigEndian
    let connected = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
    guard connected == 0 else { return (nil, "refused") }
    _ = raw.withCString { send(fd, $0, strlen($0), 0) }
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 65536)
    while true {
        let read = recv(fd, &buffer, buffer.count, 0)
        if read <= 0 { break }
        data.append(buffer, count: read)
    }
    let text = String(decoding: data, as: UTF8.self)
    let status = text.hasPrefix("HTTP/1.1 ") ? Int(text.dropFirst(9).prefix(3)) : nil
    return (status, text)
}

private func get(_ port: UInt16, _ target: String, method: String = "GET", extra: String = "") -> (status: Int?, text: String) {
    request(port, "\(method) \(target) HTTP/1.1\r\nHost: x\r\nConnection: close\r\n\(extra)\r\n")
}

@main
enum TestPlayerAirplay {
    static func main() async throws {
        setvbuf(stdout, nil, _IOLBF, 0)
        planning()
        playlists()
        texts()
        router()
        server()
        cache()
        try await audioSegments()
        try await videoSegments()
        print("all AirPlay checks passed")
    }

    static func planning() {
        let regular = AirPlayPlan.segments(keyframes: Array(stride(from: 0.0, to: 100, by: 2)), duration: 100)
        check(regular.first?.start == 0 && regular.last.map({ abs($0.end - 100) < 1e-9 }) == true, "the pieces cover the whole film")
        check(zip(regular, regular.dropFirst()).allSatisfy { abs($0.end - $1.start) < 1e-9 }, "the pieces follow each other with no gap and no overlap")
        check(regular.dropLast().allSatisfy { $0.duration >= 5.75 && $0.duration <= 8 }, "pieces are about six seconds: \(regular.map(\.duration))")
        let tail = AirPlayPlan.segments(keyframes: [0, 6, 12], duration: 12.4)
        check(tail.count == 2 && abs(tail[1].duration - 6.4) < 1e-9, "a tail under a second joins the piece before it: \(tail)")
        let sparse = AirPlayPlan.segments(keyframes: [0, 30, 60], duration: 80)
        check(sparse.map(\.start) == [0, 30, 60], "a piece never starts between two key frames: \(sparse)")
        check(AirPlayPlan.fixed(duration: 20).map(\.start) == [0, 6, 12, 18] && AirPlayPlan.fixed(duration: 18.5).map(\.start) == [0, 6, 12], "a film without a key frame list is cut every six seconds, a short tail is joined")
        check(AirPlayPlan.segments(keyframes: [], duration: 20).count == 1, "no key frames means one piece")
        check(AirPlayPlan.segments(keyframes: [0], duration: 0).isEmpty, "an empty film has no pieces")
        check(AirPlayPlan.index(of: 6, in: regular) == 1 && AirPlayPlan.index(of: 5.999, in: regular) == 0 && AirPlayPlan.index(of: 99.9, in: regular) == regular.count - 1, "a time finds its piece, boundaries are exact")
        check(AirPlayPlan.index(of: -1, in: regular) == nil, "before the start finds nothing")
        print("pieces: ok")
    }

    static func info(_ codec: AirPlayVideoCodec, range: String = "SDR", tenBit: Bool = false, burns: Bool = false) -> AirPlayVideoInfo {
        AirPlayVideoInfo(codec: codec, width: 1920, height: 1080, frameRate: 24, bitrate: 8_000_000, range: range, tenBit: tenBit, codecString: codec == .h264 ? "avc1.640028" : "hvc1.2.4.L150.B0", burnsSubtitles: burns)
    }

    static func playlists() {
        let h264 = AirPlayCodecs.variants(for: info(.h264))
        check(h264.count == 1 && !h264[0].transcode && h264[0].codecs == "avc1.640028", "H.264 goes through unchanged")
        let hevc = AirPlayCodecs.variants(for: info(.hevc, range: "PQ", tenBit: true))
        check(hevc.count == 1 && !hevc[0].transcode && hevc[0].range == "PQ" && hevc[0].tenBit, "HDR HEVC goes through unchanged and stays HDR")
        let vp9 = AirPlayCodecs.variants(for: info(.other))
        check(vp9.map(\.codec) == [.hevc, .h264] && vp9.allSatisfy(\.transcode), "VP9 and AV1 become HEVC, with H.264 as the fallback: \(vp9.map(\.id))")
        check(AirPlayCodecs.variants(for: info(.other, range: "PQ", tenBit: true)).map(\.codec) == [.hevc], "HDR is never squeezed into H.264")
        check(AirPlayCodecs.variants(for: info(.h264, burns: true)).allSatisfy(\.transcode), "burnt-in subtitles need a new encode")
        check(AirPlayCodecs.audio(.aac) == .asIs && AirPlayCodecs.audio(.ac3) == .asIs && AirPlayCodecs.audio(.eac3) == .asIs && AirPlayCodecs.audio(.alac) == .asIs, "AAC, AC-3, E-AC-3 and ALAC go as they are")
        check(AirPlayCodecs.audio(.flac) == .alac, "FLAC becomes ALAC")
        check([AirPlayAudioCodec.opus, .vorbis, .dts, .mp3].allSatisfy { AirPlayCodecs.audio($0) == .aac }, "Opus, Vorbis, DTS and MP3 become AAC")

        let master = AirPlayPlaylists.master(variants: vp9, audio: [
            AirPlayAudioTrack(id: "1", language: "en", name: "English", codecs: "mp4a.40.2", channels: 2, isDefault: true, plan: .asIs),
            AirPlayAudioTrack(id: "2", language: "ru", name: "Русский", codecs: "ac-3", channels: 6, isDefault: false, plan: .asIs),
        ], text: [AirPlayTextTrack(id: "3", language: "de", name: "Deutsch", forced: false, isDefault: false)])
        let lines = master.components(separatedBy: "\n")
        check(lines.first == "#EXTM3U" && master.hasSuffix("\n"), "the master list is a playlist")
        check(lines.filter { $0.hasPrefix("#EXT-X-MEDIA:TYPE=AUDIO") }.count == 2 && master.contains("LANGUAGE=\"ru\"") && master.contains("DEFAULT=YES"), "every sound track is listed with its language")
        check(master.contains("TYPE=SUBTITLES") && master.contains("URI=\"s/3.m3u8\"") && master.contains("SUBTITLES=\"sub\""), "text subtitles are a separate track")
        check(lines.filter { $0.hasPrefix("#EXT-X-STREAM-INF") }.count == 2 && lines.contains("v/hevc.m3u8") && lines.contains("v/h264.m3u8"), "both picture variants are offered")
        check(lines.filter { $0.hasPrefix("#EXT-X-STREAM-INF") }.allSatisfy { $0.contains("ac-3") && $0.contains("mp4a.40.2") && $0.contains("wvtt") && $0.contains("AUDIO=\"aud\"") }, "the codec list names every sound and subtitle format")

        let segments = AirPlayPlan.segments(keyframes: Array(stride(from: 0.0, to: 30, by: 2)), duration: 30)
        let media = AirPlayPlaylists.media(id: "h264", segments: segments).components(separatedBy: "\n")
        let lengths = media.filter { $0.hasPrefix("#EXTINF:") }.compactMap { Double($0.dropFirst(8).dropLast()) }
        check(lengths.count == segments.count && abs(lengths.reduce(0, +) - 30) < 0.001, "the durations add up to the film: \(lengths)")
        check(media.contains("#EXT-X-ENDLIST") && media.contains("#EXT-X-MAP:URI=\"h264/init.mp4\"") && media.contains("h264/0.m4s") && media.contains("#EXT-X-PLAYLIST-TYPE:VOD"), "the list is complete and ends")
        let target = media.first { $0.hasPrefix("#EXT-X-TARGETDURATION:") }.flatMap { Int($0.dropFirst(22)) } ?? 0
        check(Double(target) >= (lengths.max() ?? 0), "the target duration is not shorter than the longest piece")
        let text = AirPlayPlaylists.media(id: "3", segments: [AirPlaySegment(start: 0, duration: 30)], suffix: "vtt", map: false)
        check(!text.contains("EXT-X-MAP") && text.contains("3/0.vtt"), "a subtitle list has no init part")
        print("variants and lists: ok")
    }

    static func texts() {
        func packet(_ time: Double, _ text: String) -> AirPlayRawPacket { AirPlayRawPacket(time: time, duration: 2, data: Data(text.utf8)) }
        let plain = AirPlayCues.parse(.plain, [packet(5, "Second <b>line</b>"), packet(1, "First")])
        check(plain.map(\.start) == [1, 5] && plain.map(\.text) == ["First", "Second <b>line</b>"].map(AirPlayWebVTT.plain), "cues come out in time order: \(plain)")
        let ass = AirPlayCues.parse(.ass, [packet(1, "0,0,Default,,0,0,0,,Hello, {\\i1}world{\\i0}\\Nnext")])
        check(ass.first?.text == "Hello, world\nnext", "ASS styling is dropped and the comma stays: \(ass)")
        let bytes = Array("Hi".utf8)
        let mov = AirPlayCues.parse(.movText, [AirPlayRawPacket(time: 3, duration: 1, data: Data([0, UInt8(bytes.count)] + bytes + [1, 2, 3]))])
        check(mov.first?.text == "Hi", "mov_text keeps only its text")
        check(AirPlayCues.parse(.plain, [AirPlayRawPacket(time: 0, duration: 0, data: Data("x".utf8)), packet(0, "  ")]).isEmpty, "empty cues are dropped")
        check(AirPlayWebVTT.time(3723.5) == "01:02:03.500", "VTT time: \(AirPlayWebVTT.time(3723.5))")
        let file = String(decoding: AirPlayWebVTT.file([AirPlayCue(start: 1, end: 2.5, text: "a --> b & <c>\n\nd")]), as: UTF8.self)
        check(file.hasPrefix("WEBVTT\n") && file.contains("00:00:01.000 --> 00:00:02.500\na --&gt; b &amp; &lt;c>\nd\n"), "VTT escapes markers and drops blank lines: \(file)")

        check(AirPlayFirewall.blockAll("Block all DISABLED!") == false && AirPlayFirewall.blockAll("Block all ENABLED!") == true && AirPlayFirewall.blockAll("nothing") == nil, "the firewall answer is understood")
        let blocked = AirPlayAdvice.text(blockAll: true, asked: false)
        check(blocked.contains("Block all incoming connections") && blocked.contains("System Settings"), "with the firewall closed the text says what to switch off and where")
        let silent = AirPlayAdvice.text(blockAll: false, asked: false)
        check(silent != blocked && AirPlayAdvice.text(blockAll: nil, asked: false) == silent && !silent.contains("Block all"), "otherwise it asks to check the network")
        let stopped = AirPlayAdvice.text(blockAll: true, asked: true)
        check(stopped != blocked && stopped != silent && !AirPlayAdvice.title.isEmpty, "a device that was reached and then stopped gets its own text")
        print("subtitles and advice: ok")
    }

    static func router() {
        let token = String(repeating: "ab", count: 16)
        check(AirPlayRouter.parse("/\(token)/master.m3u8", token: token) == .master, "master")
        check(AirPlayRouter.parse("/\(token)/v/h264.m3u8", token: token) == .playlist(kind: "v", id: "h264"), "variant list")
        check(AirPlayRouter.parse("/\(token)/a/2/init.mp4", token: token) == .initSegment(kind: "a", id: "2"), "init part")
        check(AirPlayRouter.parse("/\(token)/v/hevc/12.m4s", token: token) == .segment(kind: "v", id: "hevc", index: 12), "segment")
        check(AirPlayRouter.parse("/\(token)/s/3/0.vtt", token: token) == .segment(kind: "s", id: "3", index: 0), "subtitle file")
        let refused = [
            "/\(String(repeating: "cd", count: 16))/master.m3u8", "/master.m3u8", "/\(token.dropLast())/master.m3u8", "/\(token)/../master.m3u8", "/\(token)/v/../../etc/passwd",
            "/\(token)/%2e%2e/master.m3u8", "/\(token)/v/%2e%2e%2fh264.m3u8", "/\(token)/v/h264%2finit.mp4", "/\(token)//master.m3u8", "/\(token)/master.m3u8?x=1", "/\(token)/master.m3u8#x",
            "/\(token)/V/h264.m3u8", "/\(token)/v/H264.m3u8", "/\(token)/x/h264.m3u8", "/\(token)/v/123456789/init.mp4", "/\(token)/v/h264/9999999.m4s", "/\(token)/v/h264/-1.m4s", "/\(token)/v/h264/1.mp4",
            "/\(token)/s/3/init.mp4", "/\(token)/v/h264/init.mp4/x", "/\(token)\\master.m3u8", "http://127.0.0.1/\(token)/master.m3u8", "/\(token)/master.m3u8\u{0}", "/\(token)/ключ.m3u8", "/\(token)/v/h264.m3u8" + String(repeating: "a", count: 100),
            "", "/", "/\(token)", "/\(token)/", "\(token)/master.m3u8",
        ]
        for target in refused { check(AirPlayRouter.parse(target, token: token) == nil, "refused: \(target)") }
        check(AirPlayRouter.same(token, token) && !AirPlayRouter.same(token, String(repeating: "ab", count: 15) + "ac") && !AirPlayRouter.same(token, ""), "tokens are compared whole")
        let tokens = Set((0..<50).compactMap { _ in AirPlayNetwork.token() })
        check(tokens.count == 50 && tokens.allSatisfy { $0.count == 32 && $0.allSatisfy(\.isHexDigit) }, "every showing gets a new 128-bit token")
        check(AirPlayNetwork.subnets().contains { $0.contains(0xA9FE_0001) }, "link-local addresses are allowed")
        print("addresses: ok")
    }

    static func server() {
        let token = AirPlayNetwork.token() ?? ""
        let calls = Calls()
        let body = Data((0..<1000).map { UInt8($0 % 251) })
        let handler: AirPlayServer.Handler = { route, reply in
            calls.add(route)
            switch route {
            case .master: reply(AirPlayResponse(type: "application/vnd.apple.mpegurl", body: Data("#EXTM3U\n".utf8)))
            case .segment: reply(AirPlayResponse(type: "video/mp4", body: body))
            default: reply(.notFound)
            }
        }
        let loopback = AirPlaySubnet(network: 0x7F00_0000, mask: 0xFF00_0000)
        let server = AirPlayServer(host: 0x7F00_0001, token: token, subnets: [loopback], handler: handler)
        check(server.start() && server.port > 0, "the server starts on a free port")
        let port = server.port

        let master = get(port, "/\(token)/master.m3u8")
        check(master.status == 200 && master.text.contains("Content-Type: application/vnd.apple.mpegurl") && master.text.hasSuffix("#EXTM3U\n"), "the master list is served")
        let head = get(port, "/\(token)/v/h264/0.m4s", method: "HEAD")
        check(head.status == 200 && head.text.contains("Content-Length: 1000") && head.text.hasSuffix("\r\n\r\n"), "HEAD returns no body")
        let part = get(port, "/\(token)/v/h264/0.m4s", extra: "Range: bytes=10-19\r\n")
        check(part.status == 206 && part.text.contains("Content-Range: bytes 10-19/1000") && part.text.hasSuffix(String(decoding: body[10..<20], as: UTF8.self)), "a range gets exactly its bytes")
        check(get(port, "/\(token)/v/h264/0.m4s", extra: "Range: bytes=5000-\r\n").status == 416, "a range past the end is refused")
        let accepted = calls.count

        let attempts = [
            "/\(String(repeating: "0", count: 32))/master.m3u8", "/master.m3u8", "/\(token)/../master.m3u8", "/\(token)/%2e%2e/master.m3u8", "/\(token)/v/%2e%2e%2fh264.m3u8", "/etc/passwd",
            "/\(token)/v/h264/9999999.m4s", "/\(token)/master.m3u8?a=b", "http://127.0.0.1:\(port)/\(token)/master.m3u8",
        ]
        for target in attempts { check(get(port, target).status == 404, "refused with 404: \(target)") }
        check(request(port, "POST /\(token)/master.m3u8 HTTP/1.1\r\nHost: x\r\nContent-Length: 0\r\n\r\n").status == 400, "only GET and HEAD are answered")
        check(request(port, "garbage\r\n\r\n").status == 400, "nonsense is refused")
        check(calls.count == accepted, "refused requests never reach the film")

        let foreign = AirPlayServer(host: 0x7F00_0001, token: token, subnets: [AirPlaySubnet(network: 0x0A63_0000, mask: 0xFFFF_0000)], handler: handler)
        check(foreign.start(), "a second server starts")
        let before = calls.count
        check(get(foreign.port, "/\(token)/master.m3u8").status == nil && calls.count == before, "an address outside the allowed networks gets no answer")
        foreign.stop()

        server.stop()
        check(get(port, "/\(token)/master.m3u8").status == nil && calls.count == before, "after closing nothing is answered and the port is free")
        let again = AirPlayServer(host: 0x7F00_0001, token: token, subnets: [loopback], handler: handler)
        check(again.start(), "a new server can start right after")
        again.stop()
        print("server: ok")
    }

    static func cache() {
        var cache = AirPlayCache(limit: 100)
        func part(_ size: Int) -> AirPlayBuilt { AirPlayBuilt(initData: Data(), media: Data(count: size)) }
        cache.store("a", part(40))
        cache.store("b", part(40))
        check(cache.value("a") != nil, "a is read")
        cache.store("c", part(40))
        check(cache.value("b") == nil && cache.value("a") != nil && cache.value("c") != nil && cache.bytes == 80, "the piece unused longest goes first")
        cache.store("big", part(500))
        check(cache.value("big") != nil && cache.bytes == 500 && cache.value("a") == nil, "one big piece is kept alone")
        cache.removeAll()
        check(cache.bytes == 0 && cache.value("big") == nil, "closing empties the cache")
        print("cache: ok")
    }

    static func temporary(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("pikapik-airplay-\(ProcessInfo.processInfo.processIdentifier)-\(name)")
    }

    static func audioSegments() async throws {
        let rate = 44100.0, total = 20.0
        func wave(_ frame: Int) -> Float {
            let time = Double(frame) / rate
            return Float(0.5 * sin(2 * Double.pi * (200 * time + 45 * time * time)))
        }
        let samples = (0..<Int(total * rate) + 16384).map(wave)
        let segments = AirPlayPlan.segments(keyframes: Array(stride(from: 0.0, to: total, by: 2)), duration: total)
        var init0 = Data()
        var pieces: [Data] = []
        var parts: [Fragment] = []
        for (index, segment) in segments.enumerated() {
            guard let encoder = AirPlayAudioEncoder(.aac, sampleRate: rate, channels: 1) else { fatalError("no AAC encoder") }
            let range = AirPlayAudioGrid.range(of: segment, rate: rate, frames: encoder.frames, lead: AirPlayAudioGrid.lead, last: index + 1 == segments.count, total: total)
            let packets = AirPlayAudioGrid.encode(range, with: encoder, lead: AirPlayAudioGrid.lead, warmup: AirPlayAudioGrid.warmup) { frame, count in (0..<count).map { samples[frame + $0] } }
            let start = AirPlayAudioGrid.time(ofPacket: range.lowerBound, rate: rate, frames: encoder.frames, lead: AirPlayAudioGrid.lead)
            check(packets.count == range.count, "segment \(index) has all its packets")
            var pending = encoder.sample(packets, start: start)
            let built = try AirPlaySegmentWriter.build(.audio, format: encoder.format, settings: nil, start: start, number: index) {
                defer { pending = nil }
                return pending
            }
            if index == 0 { init0 = built.initData }
            pieces.append(built.media)
            parts.append(merged(fragments(built.media), segment: index))
        }
        check(find(init0, ["moov"]) != nil && boxes(init0, in: 0..<init0.count).first?.name == "ftyp", "the init part has ftyp and moov")
        let scale = Double(timescale(init0))
        for (index, part) in parts.enumerated() {
            check(abs(Double(part.start) / scale - segments[index].start) <= 1024 / rate, "segment \(index) starts where the list says: \(Double(part.start) / scale) vs \(segments[index].start)")
            check(abs(Double(part.total) / scale - segments[index].duration) <= 1024 / rate, "segment \(index) lasts as the list says: \(Double(part.total) / scale) vs \(segments[index].duration)")
            if index > 0 { check(parts[index - 1].start + parts[index - 1].total == part.start, "segment \(index) continues exactly where the previous one ended") }
        }

        var lags: [Int] = []
        for (index, piece) in pieces.enumerated() {
            let decoded = try await read(init0, piece, .audio, [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 32, AVLinearPCMIsFloatKey: true, AVLinearPCMIsBigEndianKey: false,
                                                               AVLinearPCMIsNonInterleaved: false, AVNumberOfChannelsKey: 1, AVSampleRateKey: rate], "audio\(index)")
            check(!decoded.isEmpty, "segment \(index) decodes with the shared init part")
            var pcm: [Float] = []
            for sample in decoded {
                guard let block = CMSampleBufferGetDataBuffer(sample) else { continue }
                var length = 0
                var pointer: UnsafeMutablePointer<Int8>?
                CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &pointer)
                pcm += UnsafeBufferPointer(start: UnsafeRawPointer(pointer!).assumingMemoryBound(to: Float.self), count: length / 4)
            }
            check(abs(Double(pcm.count) / rate - segments[index].duration) < 0.2, "segment \(index) decodes to its length: \(Double(pcm.count) / rate) s vs \(segments[index].duration) s")
            let origin = Int((Double(parts[index].start) / scale * rate).rounded())
            let window = Array(stride(from: 8192, to: min(pcm.count - 1, 8192 + 22050), by: 16))
            var best = (lag: 0, error: Float.infinity)
            for lag in -4096...4096 {
                var error: Float = 0
                for j in window { error += abs(pcm[j] - samples[origin + j + lag]) }
                if error < best.error { best = (lag, error) }
            }
            let mean = best.error / Float(window.count)
            check(mean < 0.03, "segment \(index) carries the wave: mean error \(mean)")
            lags.append(best.lag)
        }
        check((lags.max() ?? 0) - (lags.min() ?? 0) <= 1 && abs(lags[0]) <= 2112 + 1024, "every segment sits at the same offset from its time stamp, so the wave has no jump at the joins: \(lags)")
        print("sound pieces decode with one init part and line up in time (offsets \(lags)): ok")
    }

    static func read(_ initData: Data, _ media: Data, _ type: AVFoundation.AVMediaType, _ settings: [String: Any]?, _ name: String) async throws -> [CMSampleBuffer] {
        let file = temporary("\(name).mp4")
        defer { try? FileManager.default.removeItem(at: file) }
        try (initData + media).write(to: file)
        let asset = AVURLAsset(url: file)
        guard let track = try await asset.loadTracks(withMediaType: type).first else { fatalError("\(name) has no track") }
        let reader = try AVAssetReader(asset: asset)
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        check(reader.startReading(), "\(name) opens: \(String(describing: reader.error))")
        var samples: [CMSampleBuffer] = []
        while let sample = output.copyNextSampleBuffer() { if CMSampleBufferGetNumSamples(sample) > 0 { samples.append(sample) } }
        check(reader.status == .completed, "\(name) reads to the end: \(String(describing: reader.error))")
        return samples
    }

    static func film(at source: URL, width: Int, height: Int, fps: Int, seconds: Int) throws -> Bool {
        try? FileManager.default.removeItem(at: source)
        let writer = try AVAssetWriter(url: source, fileType: .mov)
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: width, AVVideoHeightKey: height,
                                                                           AVVideoCompressionPropertiesKey: [AVVideoMaxKeyFrameIntervalKey: 2 * fps, AVVideoAllowFrameReorderingKey: false, AVVideoAverageBitRateKey: 400_000]])
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                                                                                                 kCVPixelBufferWidthKey as String: width, kCVPixelBufferHeightKey as String: height])
        guard writer.canAdd(input) else { print("skipped: this Mac has no H.264 encoder for the picture test"); return false }
        writer.add(input)
        guard writer.startWriting() else { print("skipped: the H.264 writer does not start: \(String(describing: writer.error))"); return false }
        writer.startSession(atSourceTime: .zero)
        for frame in 0..<(fps * seconds) {
            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.002) }
            var buffer: CVPixelBuffer?
            CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32BGRA, nil, &buffer)
            guard let buffer else { fatalError("no pixel buffer") }
            CVPixelBufferLockBaseAddress(buffer, [])
            if let base = CVPixelBufferGetBaseAddress(buffer) { memset(base, Int32(frame * 7 % 256), CVPixelBufferGetBytesPerRow(buffer) * height) }
            CVPixelBufferUnlockBaseAddress(buffer, [])
            adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: CMTimeScale(fps)))
        }
        input.markAsFinished()
        let finished = DispatchSemaphore(value: 0)
        writer.finishWriting { finished.signal() }
        finished.wait()
        guard writer.status == .completed else { print("skipped: the H.264 encoder is not available here: \(String(describing: writer.error))"); return false }
        return true
    }

    static func videoSegments() async throws {
        let (width, height, fps, seconds) = (128, 72, 24, 14)
        let source = temporary("video.mov")
        defer { try? FileManager.default.removeItem(at: source) }
        guard try film(at: source, width: width, height: height, fps: fps, seconds: seconds) else { return }
        let asset = AVURLAsset(url: source)
        guard let track = try await asset.loadTracks(withMediaType: .video).first else { fatalError("no video track") }
        let reader = try AVAssetReader(asset: asset)
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
        reader.add(output)
        reader.startReading()
        var samples: [CMSampleBuffer] = []
        while let sample = output.copyNextSampleBuffer() { if CMSampleBufferGetNumSamples(sample) > 0 { samples.append(sample) } }
        check(samples.count == fps * seconds, "the test film has all its frames: \(samples.count)")
        func isKey(_ sample: CMSampleBuffer) -> Bool {
            let attachments = CMSampleBufferGetSampleAttachmentsArray(sample, createIfNecessary: false) as? [[CFString: Any]]
            return attachments?.first?[kCMSampleAttachmentKey_NotSync] as? Bool != true
        }
        let keyframes = samples.filter(isKey).map { CMSampleBufferGetPresentationTimeStamp($0).seconds }
        check(keyframes.count >= 5, "the test film has key frames: \(keyframes)")
        let segments = AirPlayPlan.segments(keyframes: keyframes, duration: Double(seconds))
        check(segments.count == 3 && segments.allSatisfy { segment in keyframes.contains { abs($0 - segment.start) < 1e-6 } }, "the film is cut in three: \(segments)")
        guard let description = CMSampleBufferGetFormatDescription(samples[0]) else { fatalError("no format") }
        var init0 = Data()
        var pieces: [Data] = []
        var counts: [Int] = []
        var parts: [Fragment] = []
        var used = 0
        for (index, segment) in segments.enumerated() {
            var chosen = samples.filter { CMSampleBufferGetPresentationTimeStamp($0).seconds >= segment.start - 1e-6 && CMSampleBufferGetPresentationTimeStamp($0).seconds < segment.end - 1e-6 }
            check(isKey(chosen[0]), "segment \(index) starts on a key frame")
            used += chosen.count
            let built = try AirPlaySegmentWriter.build(.video, format: description, settings: nil, start: CMSampleBufferGetPresentationTimeStamp(chosen[0]), number: index) {
                chosen.isEmpty ? nil : chosen.removeFirst()
            }
            if index == 0 { init0 = built.initData }
            pieces.append(built.media)
            counts.append(used - counts.reduce(0, +))
            let part = merged(fragments(built.media), segment: index)
            check(part.firstIsSync, "segment \(index) starts on a key frame")
            parts.append(part)
        }
        check(used == samples.count, "no frame is lost or repeated between pieces")
        let scale = Double(timescale(init0))
        for (index, part) in parts.enumerated() {
            check(abs(Double(part.start) / scale - segments[index].start) < 1.0 / 24 + 1e-6, "video segment \(index) starts where the list says: \(Double(part.start) / scale) vs \(segments[index].start)")
            if index > 0 { check(parts[index - 1].start + parts[index - 1].total == part.start, "video segment \(index) continues exactly where the previous one ended") }
        }
        var shown = 0
        for (index, piece) in pieces.enumerated() {
            let frames = try await read(init0, piece, .video, [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA], "video\(index)")
            let times = frames.map { CMSampleBufferGetPresentationTimeStamp($0).seconds }
            check(frames.count == counts[index], "segment \(index) decodes all its frames with the shared init part: \(frames.count) of \(counts[index])")
            let first = Double(parts[index].start) / scale + times[0]
            check(abs(first - segments[index].start) < 1e-3, "jumping to \(segments[index].start) s lands on that very frame: \(first)")
            check(zip(times, times.dropFirst()).allSatisfy { abs($1 - $0 - 1.0 / 24) < 1e-3 } && first + times[times.count - 1] < segments[index].end, "segment \(index) frames come at an even step inside its time")
            shown += frames.count
        }
        check(shown == samples.count, "every frame of the film is shown once")
        print("picture pieces decode with one init part, jumps are exact: ok")
    }
}
