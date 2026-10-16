import Foundation

struct AirPlaySegment: Equatable {
    let start: Double
    let duration: Double
    var end: Double { start + duration }
}

enum AirPlayVideoCodec: Equatable {
    case h264, hevc, other
}

enum AirPlayAudioCodec: Equatable {
    case aac, ac3, eac3, alac, flac, opus, vorbis, dts, mp3, other
}

enum AirPlayAudioPlan: Equatable {
    case asIs, alac, aac
}

struct AirPlayVideoInfo: Equatable {
    var codec: AirPlayVideoCodec
    var width: Int
    var height: Int
    var frameRate: Double
    var bitrate: Int
    var range: String
    var tenBit: Bool
    var codecString: String
    var burnsSubtitles = false
}

struct AirPlayVariant: Equatable {
    let id: String
    let codec: AirPlayVideoCodec
    let transcode: Bool
    let codecs: String
    let width: Int
    let height: Int
    let bitrate: Int
    let frameRate: Double
    let range: String
    let tenBit: Bool
}

struct AirPlayAudioTrack: Equatable {
    let id: String
    let language: String?
    let name: String
    let codecs: String
    let channels: Int
    let isDefault: Bool
    let plan: AirPlayAudioPlan
}

struct AirPlayTextTrack: Equatable {
    let id: String
    let language: String?
    let name: String
    let forced: Bool
    let isDefault: Bool
}

enum AirPlayPlan {
    static let target = 6.0
    static let shortest = 1.0

    static func segments(keyframes: [Double], duration: Double) -> [AirPlaySegment] {
        guard duration > 0 else { return [] }
        let first = keyframes.first.map { min($0, duration) } ?? 0
        var starts = [first]
        for time in keyframes where time >= starts[starts.count - 1] + target - 0.25 && time < duration - shortest {
            starts.append(time)
        }
        return pieces(starts, duration: duration)
    }

    static func fixed(duration: Double) -> [AirPlaySegment] {
        guard duration > 0 else { return [] }
        var starts = [0.0]
        while starts[starts.count - 1] + target < duration - shortest { starts.append(starts[starts.count - 1] + target) }
        return pieces(starts, duration: duration)
    }

    private static func pieces(_ starts: [Double], duration: Double) -> [AirPlaySegment] {
        starts.enumerated().map { index, start in
            AirPlaySegment(start: start, duration: (index + 1 < starts.count ? starts[index + 1] : duration) - start)
        }
    }

    static func index(of time: Double, in segments: [AirPlaySegment]) -> Int? {
        guard let first = segments.first, time >= first.start else { return nil }
        return segments.lastIndex { $0.start <= time }
    }
}

enum AirPlayCodecs {
    static func audio(_ codec: AirPlayAudioCodec) -> AirPlayAudioPlan {
        switch codec {
        case .aac, .ac3, .eac3, .alac: .asIs
        case .flac: .alac
        case .opus, .vorbis, .dts, .mp3, .other: .aac
        }
    }

    static func bitrate(_ codec: AirPlayVideoCodec, width: Int, height: Int, frameRate: Double) -> Int {
        let rate = frameRate > 0 ? min(frameRate, 120) : 30
        let perPixel = codec == .hevc ? 0.07 : 0.1
        return min(40_000_000, max(1_500_000, Int(Double(width * height) * rate * perPixel)))
    }

    static func variants(for video: AirPlayVideoInfo) -> [AirPlayVariant] {
        func make(_ codec: AirPlayVideoCodec, transcode: Bool) -> AirPlayVariant {
            let encoded = codec == .hevc ? hevcString(width: video.width, height: video.height, tenBit: video.tenBit) : h264String(width: video.width, height: video.height)
            let copied = !transcode
            return AirPlayVariant(id: codec == .hevc ? "hevc" : "h264", codec: codec, transcode: transcode, codecs: copied ? video.codecString : encoded,
                                  width: video.width, height: video.height,
                                  bitrate: copied ? video.bitrate : bitrate(codec, width: video.width, height: video.height, frameRate: video.frameRate),
                                  frameRate: video.frameRate, range: video.range, tenBit: video.tenBit)
        }
        switch video.codec {
        case .h264: return [make(.h264, transcode: video.burnsSubtitles)]
        case .hevc: return [make(.hevc, transcode: video.burnsSubtitles)]
        case .other: return video.range == "SDR" && !video.tenBit ? [make(.hevc, transcode: true), make(.h264, transcode: true)] : [make(.hevc, transcode: true)]
        }
    }

    static func h264String(width: Int, height: Int) -> String {
        let level = width * height > 2_100_000 ? 0x33 : width * height > 1_000_000 ? 0x28 : 0x1f
        return "avc1.6400" + String(format: "%02x", level)
    }

    static func hevcString(width: Int, height: Int, tenBit: Bool) -> String {
        let level = width * height > 8_900_000 ? 153 : width * height > 2_100_000 ? 150 : 120
        return "hvc1.\(tenBit ? 2 : 1).\(tenBit ? 4 : 6).L\(level).B0"
    }

    static func avc1(_ avcC: Data) -> String? {
        let bytes = [UInt8](avcC)
        guard bytes.count >= 4, bytes[0] == 1 else { return nil }
        return "avc1." + bytes[1...3].map { String(format: "%02x", $0) }.joined()
    }

    static func hvc1(_ hvcC: Data) -> String? {
        let bytes = [UInt8](hvcC)
        guard bytes.count >= 13, bytes[0] == 1 else { return nil }
        let space = ["", "A", "B", "C"][Int(bytes[1] >> 6)]
        let profile = Int(bytes[1] & 0x1f)
        var compatibility = UInt32(bytes[2]) << 24 | UInt32(bytes[3]) << 16 | UInt32(bytes[4]) << 8 | UInt32(bytes[5])
        var reversed: UInt32 = 0
        for _ in 0..<32 {
            reversed = reversed << 1 | compatibility & 1
            compatibility >>= 1
        }
        var constraints = Array(bytes[6...11])
        while constraints.count > 1, constraints.last == 0 { constraints.removeLast() }
        return "hvc1.\(space)\(profile).\(String(reversed, radix: 16)).\(bytes[1] & 0x20 != 0 ? "H" : "L")\(bytes[12])." + constraints.map { String($0, radix: 16, uppercase: true) }.joined(separator: ".")
    }
}

enum AirPlayPlaylists {
    static func master(variants: [AirPlayVariant], audio: [AirPlayAudioTrack], text: [AirPlayTextTrack]) -> String {
        var lines = ["#EXTM3U", "#EXT-X-VERSION:7", "#EXT-X-INDEPENDENT-SEGMENTS"]
        for track in audio {
            lines.append("#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"aud\",NAME=\"\(quoted(track.name))\"" + language(track.language)
                + ",DEFAULT=\(track.isDefault ? "YES" : "NO"),AUTOSELECT=YES,CHANNELS=\"\(max(track.channels, 1))\",URI=\"a/\(track.id).m3u8\"")
        }
        for track in text {
            lines.append("#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"sub\",NAME=\"\(quoted(track.name))\"" + language(track.language)
                + ",DEFAULT=\(track.isDefault ? "YES" : "NO"),AUTOSELECT=YES,FORCED=\(track.forced ? "YES" : "NO"),URI=\"s/\(track.id).m3u8\"")
        }
        let extra = Array(Set(audio.map(\.codecs))).sorted() + (text.isEmpty ? [] : ["wvtt"])
        for variant in variants {
            var attributes = "BANDWIDTH=\(variant.bitrate + 640_000),AVERAGE-BANDWIDTH=\(variant.bitrate),CODECS=\"" + ([variant.codecs] + extra).joined(separator: ",") + "\""
            attributes += ",RESOLUTION=\(variant.width)x\(variant.height)"
            if variant.frameRate > 0 { attributes += ",FRAME-RATE=" + String(format: "%.3f", variant.frameRate) }
            attributes += ",VIDEO-RANGE=\(variant.range)"
            if !audio.isEmpty { attributes += ",AUDIO=\"aud\"" }
            if !text.isEmpty { attributes += ",SUBTITLES=\"sub\"" }
            lines.append("#EXT-X-STREAM-INF:" + attributes)
            lines.append("v/\(variant.id).m3u8")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    static func media(id: String, segments: [AirPlaySegment], suffix: String = "m4s", map: Bool = true) -> String {
        let longest = segments.map(\.duration).max() ?? AirPlayPlan.target
        var lines = ["#EXTM3U", "#EXT-X-VERSION:7", "#EXT-X-TARGETDURATION:\(Int(longest.rounded(.up)))", "#EXT-X-PLAYLIST-TYPE:VOD", "#EXT-X-MEDIA-SEQUENCE:0", "#EXT-X-INDEPENDENT-SEGMENTS"]
        if map { lines.append("#EXT-X-MAP:URI=\"\(id)/init.mp4\"") }
        for (index, segment) in segments.enumerated() {
            lines.append("#EXTINF:" + String(format: "%.5f", segment.duration) + ",")
            lines.append("\(id)/\(index).\(suffix)")
        }
        lines.append("#EXT-X-ENDLIST")
        return lines.joined(separator: "\n") + "\n"
    }

    private static func language(_ code: String?) -> String {
        guard let code, code.range(of: "^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8})*$", options: .regularExpression) != nil else { return "" }
        return ",LANGUAGE=\"\(code)\""
    }

    private static func quoted(_ text: String) -> String {
        String(text.filter { $0 != "\"" && !$0.isNewline }.prefix(64))
    }
}

struct AirPlayRawPacket {
    let time: Double
    let duration: Double
    let data: Data
}

enum AirPlayTextFormat {
    case plain, ass, movText
}

enum AirPlayCues {
    static func parse(_ format: AirPlayTextFormat, _ packets: [AirPlayRawPacket]) -> [AirPlayCue] {
        packets.compactMap { packet in
            guard packet.duration > 0 else { return nil }
            var raw: String?
            switch format {
            case .plain:
                raw = String(data: packet.data, encoding: .utf8)
            case .ass:
                let parts = String(decoding: packet.data, as: UTF8.self).split(separator: ",", maxSplits: 8, omittingEmptySubsequences: false)
                raw = parts.count == 9 ? String(parts[8]) : nil
            case .movText:
                guard packet.data.count >= 2 else { return nil }
                let bytes = [UInt8](packet.data)
                raw = String(bytes: bytes[2..<min(bytes.count, 2 + Int(bytes[0]) << 8 + Int(bytes[1]))], encoding: .utf8)
            }
            guard let text = raw.map(AirPlayWebVTT.plain), !text.isEmpty else { return nil }
            return AirPlayCue(start: packet.time, end: packet.time + packet.duration, text: text)
        }.sorted { $0.start < $1.start }
    }
}

struct AirPlayCue: Equatable {
    var start: Double
    var end: Double
    var text: String
}

enum AirPlayWebVTT {
    static func time(_ seconds: Double) -> String {
        let milliseconds = Int((max(0, seconds) * 1000).rounded())
        return String(format: "%02d:%02d:%02d.%03d", milliseconds / 3_600_000, milliseconds / 60_000 % 60, milliseconds / 1000 % 60, milliseconds % 1000)
    }

    static func file(_ cues: [AirPlayCue]) -> Data {
        var text = "WEBVTT\nX-TIMESTAMP-MAP=MPEGTS:0,LOCAL:00:00:00.000\n\n"
        for cue in cues where cue.end > cue.start {
            text += time(cue.start) + " --> " + time(cue.end) + "\n" + escaped(cue.text) + "\n\n"
        }
        return Data(text.utf8)
    }

    private static func escaped(_ text: String) -> String {
        var lines = text.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n").components(separatedBy: "\n")
        lines = lines.map { $0.replacingOccurrences(of: "-->", with: "--&gt;") }
        return lines.filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static func plain(_ markup: String) -> String {
        var text = markup.replacingOccurrences(of: "\\N", with: "\n").replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\h", with: " ")
        text = text.replacingOccurrences(of: "\\{[^}]*\\}", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "</?[A-Za-z][^>]*>", with: "", options: .regularExpression)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum AirPlayFirewall {
    static func blockAll(_ output: String) -> Bool? {
        let text = output.lowercased()
        guard text.contains("block all") else { return nil }
        if text.contains("enabled") { return true }
        if text.contains("disabled") { return false }
        return nil
    }
}

enum AirPlayAdvice {
    static var title: String { String(localized: "AirPlay video can’t continue") }

    static func text(blockAll: Bool?, asked: Bool) -> String {
        if asked {
            return String(localized: "The AirPlay device stopped playing this video, so playback continues on this Mac. Check that the device is turned on and on the same network, then pick it again.")
        }
        if blockAll == true {
            return String(localized: "The firewall is set to “Block all incoming connections”, so an AirPlay device can’t get the video from this Mac. Open System Settings, choose Network, then Firewall, then Options, turn off “Block all incoming connections”, and pick the device again. pikapik doesn’t change this setting itself.")
        }
        return String(localized: "The AirPlay device didn’t ask this Mac for the video. Make sure the Mac and the device are on the same network and that no VPN or firewall blocks connections inside it, then pick the device again.")
    }
}
