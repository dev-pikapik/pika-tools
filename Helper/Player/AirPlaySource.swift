import AVFoundation
import AudioToolbox
import CoreMedia
import VideoToolbox

final class AirPlayPCMReader {
    private let demuxer: Demuxer
    private let track: Track
    private let decoder: AirPlayAudioDecoder
    private let rate: Double
    private let channels: Int
    private var next: Packet?
    private var buffer: [Float] = []
    private var start = 0
    private var primed = false
    private var started = false

    init(demuxer: Demuxer, track: Track, decoder: AirPlayAudioDecoder, rate: Double, channels: Int) {
        self.demuxer = demuxer
        self.track = track
        self.decoder = decoder
        self.rate = rate
        self.channels = channels
    }

    func samples(from frame: Int, count: Int) -> [Float] {
        if !primed { prime(frame) }
        let end = frame + count
        while start + buffer.count / channels < end, let packet = next { append(packet) }
        var out = [Float](repeating: 0, count: count * channels)
        let from = max(frame, start), to = min(end, start + buffer.count / channels)
        if to > from {
            out.replaceSubrange((from - frame) * channels..<(to - frame) * channels, with: buffer[(from - start) * channels..<(to - start) * channels])
        }
        let drop = min(max(0, end - start), buffer.count / channels)
        buffer.removeFirst(drop * channels)
        start += drop
        return out
    }

    private func prime(_ frame: Int) {
        primed = true
        decoder.reset()
        let base = track.timeBase
        let ticks = Int64((max(0, Double(frame) / rate - 0.25) * Double(base.den) / Double(base.num)).rounded())
        next = (try? demuxer.locate(track, ticks)) ?? nil
    }

    private func append(_ packet: Packet) {
        next = (try? demuxer.next(packet, track)) ?? nil
        demuxer.forget(before: packet, track)
        guard let data = try? demuxer.data(packet, track) else { return }
        let pcm = decoder.decode(data)
        if !started {
            start = Int((track.time(packet.pts).seconds * rate).rounded())
            started = true
        }
        buffer += pcm
    }
}

final class AirPlaySource {
    struct Audio {
        let id: String
        let info: AirPlayStreamInfo
        let track: Track
        let plan: AirPlayAudioPlan
        let codecs: String
        let rate: Double
        let channels: Int
    }

    struct Text {
        let id: String
        let info: AirPlayStreamInfo
        let format: AirPlayTextFormat
    }

    let duration: Double
    private let fd: Int32
    private let container: AirPlayContainer
    private let videoDemuxer: Demuxer
    private let audioDemuxer: Demuxer?
    private let video: Track
    private let segments: [AirPlaySegment]
    private let variants: [AirPlayVariant]
    private let range: String
    private let audio: [Audio]
    private let text: [Text]
    private let textPackets: [Int32: [AirPlayRawPacket]]
    private let pictures: AirPlayPictures?
    private let videoQueue = DispatchQueue(label: "pikapik.airplay.video")
    private let audioQueue = DispatchQueue(label: "pikapik.airplay.audio")
    private var frameDecoder: FrameDecoder?
    private let cuesLock = NSLock()
    private var cues: [String: [AirPlayCue]] = [:]

    static func open(_ url: URL) throws -> AirPlaySource {
        let fd = Darwin.open(url.path, O_RDONLY)
        guard fd >= 0 else { throw MediaError.invalidParameter }
        do {
            return try make(fd, name: url.lastPathComponent)
        } catch {
            close(fd)
            throw error
        }
    }

    private static func make(_ fd: Int32, name: String) throws -> AirPlaySource {
        let size = lseek(fd, 0, SEEK_END)
        let read: (UnsafeMutablePointer<UInt8>, Int32, Int64) -> Int32 = { buffer, count, offset in
            let read = pread(fd, buffer, Int(count), offset)
            return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
        }
        let container = try AirPlayContainer(fd: fd)
        let videoDemuxer = try Demuxer(name: name, size: size, memoryLimit: 48 << 20, read: read)
        guard let video = videoDemuxer.tracks.first(where: { $0.format.mediaType == kCMMediaType_Video && $0.enabled }),
              let stream = container.streams.first(where: { $0.index == video.index && $0.kind == .video }) else { throw MediaError.unsupportedFeature }
        videoDemuxer.discard(except: [video])
        let textStreams = container.streams.filter { $0.kind == .text }
        let pictureStreams = container.streams.filter { $0.kind == .picture }
        guard let scan = container.scan(video: stream.index, keep: (textStreams + pictureStreams).map(\.index)) else { throw MediaError.parsingFailure }
        let scale = Double(scan.base.num) / Double(scan.base.den)
        let duration = container.duration > 0 ? container.duration : Double(scan.end) * scale
        let all = (scan.keys + scan.open).sorted()
        let keys = scan.keys.count >= max(1, Int(duration / 20)) ? scan.keys : all
        let segments = AirPlayPlan.segments(keyframes: keys.map { Double($0) * scale }, duration: duration)
        guard !keys.isEmpty, !segments.isEmpty else { throw MediaError.noSamples }

        let codec: AirPlayVideoCodec = stream.codec == AV_CODEC_ID_H264 && stream.depth <= 8 ? .h264 : stream.codec == AV_CODEC_ID_HEVC ? .hevc : .other
        let range = stream.transfer == AVCOL_TRC_SMPTE2084 ? "PQ" : stream.transfer == AVCOL_TRC_ARIB_STD_B67 ? "HLG" : "SDR"
        let decoder = codec == .other ? try FrameDecoder(video.format.description) : nil
        let burned = range == "SDR" && stream.depth <= 8 ? pictureStreams.first { $0.isForced } ?? pictureStreams.first { $0.isDefault } : nil
        let pictures = burned.flatMap { picture in
            container.parameters(picture.index).flatMap { parameters in
                scan.packets[picture.index].map { AirPlayPictures(parameters: parameters, packets: $0, fallback: CGSize(width: stream.width, height: stream.height)) }
            }
        }
        let info = AirPlayVideoInfo(codec: codec, width: stream.width, height: stream.height, frameRate: Double(video.frameRate),
                                    bitrate: min(80_000_000, max(1_000_000, Int(Double(size) * 8 / max(duration, 1)))), range: range, tenBit: stream.depth > 8,
                                    codecString: codecString(video.format.description, codec, stream), burnsSubtitles: pictures != nil)

        var audioDemuxer: Demuxer?
        var audio: [Audio] = []
        if container.streams.contains(where: { $0.kind == .audio }), let opened = try? Demuxer(name: name, size: size, memoryLimit: 48 << 20, read: read) {
            let tracks = opened.tracks.filter { $0.format.mediaType == kCMMediaType_Audio }
            opened.discard(except: tracks)
            audioDemuxer = tracks.isEmpty ? nil : opened
            audio = tracks.compactMap { track in container.streams.first { $0.index == track.index && $0.kind == .audio }.flatMap { audioEntry(track, $0) } }
        }
        return AirPlaySource(fd: fd, container: container, videoDemuxer: videoDemuxer, audioDemuxer: audioDemuxer, video: video, segments: segments,
                             variants: AirPlayCodecs.variants(for: info), range: range, audio: audio,
                             text: textStreams.map { Text(id: String($0.index), info: $0, format: textFormat($0.codec)) },
                             textPackets: scan.packets, pictures: pictures, duration: duration, frameDecoder: decoder)
    }

    private init(fd: Int32, container: AirPlayContainer, videoDemuxer: Demuxer, audioDemuxer: Demuxer?, video: Track, segments: [AirPlaySegment], variants: [AirPlayVariant],
                 range: String, audio: [Audio], text: [Text], textPackets: [Int32: [AirPlayRawPacket]], pictures: AirPlayPictures?, duration: Double, frameDecoder: FrameDecoder?) {
        self.fd = fd
        self.container = container
        self.videoDemuxer = videoDemuxer
        self.audioDemuxer = audioDemuxer
        self.video = video
        self.segments = segments
        self.variants = variants
        self.range = range
        self.audio = audio
        self.text = text
        self.textPackets = textPackets
        self.pictures = pictures
        self.duration = duration
        self.frameDecoder = frameDecoder
    }

    deinit {
        close(fd)
    }

    private static func textFormat(_ codec: AVCodecID) -> AirPlayTextFormat {
        switch codec {
        case AV_CODEC_ID_ASS, AV_CODEC_ID_SSA: .ass
        case AV_CODEC_ID_MOV_TEXT: .movText
        default: .plain
        }
    }

    private static func codecString(_ description: CMFormatDescription, _ codec: AirPlayVideoCodec, _ stream: AirPlayStreamInfo) -> String {
        let atoms = CMFormatDescriptionGetExtension(description, extensionKey: kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms) as? [String: Data]
        switch codec {
        case .h264:
            if let text = atoms?["avcC"].flatMap(AirPlayCodecs.avc1) { return text }
            var set: UnsafePointer<UInt8>?
            var size = 0
            if CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description, parameterSetIndex: 0, parameterSetPointerOut: &set, parameterSetSizeOut: &size, parameterSetCountOut: nil,
                                                                   nalUnitHeaderLengthOut: nil) == noErr, let set, size >= 4 {
                return "avc1." + (1...3).map { String(format: "%02x", set[$0]) }.joined()
            }
            return AirPlayCodecs.h264String(width: stream.width, height: stream.height)
        case .hevc:
            return atoms?["hvcC"].flatMap(AirPlayCodecs.hvc1) ?? AirPlayCodecs.hevcString(width: stream.width, height: stream.height, tenBit: stream.depth > 8)
        case .other:
            return ""
        }
    }

    private static func audioEntry(_ track: Track, _ info: AirPlayStreamInfo) -> Audio? {
        let codec: AirPlayAudioCodec
        switch info.codec {
        case AV_CODEC_ID_AAC: codec = .aac
        case AV_CODEC_ID_AC3: codec = .ac3
        case AV_CODEC_ID_EAC3: codec = .eac3
        case AV_CODEC_ID_ALAC: codec = .alac
        case AV_CODEC_ID_FLAC: codec = .flac
        case AV_CODEC_ID_OPUS: codec = .opus
        case AV_CODEC_ID_VORBIS: codec = .vorbis
        case AV_CODEC_ID_DTS: codec = .dts
        case AV_CODEC_ID_MP3: codec = .mp3
        default: codec = .other
        }
        guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(track.format.description)?.pointee, asbd.mChannelsPerFrame > 0 else { return nil }
        let plan = AirPlayCodecs.audio(codec)
        let (rate, channels) = (asbd.mSampleRate, Int(asbd.mChannelsPerFrame))
        if plan != .asIs {
            guard AirPlayAudioEncoder(plan == .alac ? .alac : .aac, sampleRate: rate, channels: channels, bits: info.bits) != nil, AirPlayAudioDecoder(track.format.description) != nil else { return nil }
        }
        let codecs: String
        switch plan {
        case .asIs: codecs = codec == .ac3 ? "ac-3" : codec == .eac3 ? "ec-3" : codec == .alac ? "alac" : "mp4a.40.2"
        case .alac: codecs = "alac"
        case .aac: codecs = "mp4a.40.2"
        }
        return Audio(id: String(info.index), info: info, track: track, plan: plan, codecs: codecs, rate: rate, channels: channels)
    }

    private static func label(_ info: AirPlayStreamInfo, _ number: Int) -> String {
        if let title = info.title { return title }
        if let code = info.language, let name = Locale.current.localizedString(forLanguageCode: alpha2(code)) { return name }
        return String(localized: "Track \(number)")
    }

    private static func alpha2(_ code: String) -> String {
        Locale.LanguageCode(code).identifier(.alpha2) ?? code
    }

    func master() -> String {
        let audioTracks = audio.enumerated().map { number, entry in
            AirPlayAudioTrack(id: entry.id, language: entry.info.language.map(Self.alpha2), name: Self.label(entry.info, number + 1), codecs: entry.codecs, channels: entry.channels,
                              isDefault: entry.info.isDefault || (number == 0 && !audio.contains { $0.info.isDefault }), plan: entry.plan)
        }
        let textTracks = text.enumerated().map { number, entry in
            AirPlayTextTrack(id: entry.id, language: entry.info.language.map(Self.alpha2), name: Self.label(entry.info, number + 1), forced: entry.info.isForced, isDefault: false)
        }
        return AirPlayPlaylists.master(variants: variants, audio: audioTracks, text: textTracks)
    }

    func playlist(kind: Character, id: String) -> String? {
        switch kind {
        case "v": variants.contains { $0.id == id } ? AirPlayPlaylists.media(id: id, segments: segments) : nil
        case "a": audio.contains { $0.id == id } ? AirPlayPlaylists.media(id: id, segments: segments) : nil
        case "s": text.contains { $0.id == id } ? AirPlayPlaylists.media(id: id, segments: [AirPlaySegment(start: 0, duration: duration)], suffix: "vtt", map: false) : nil
        default: nil
        }
    }

    func build(kind: Character, id: String, index: Int, _ done: @escaping (Result<AirPlayBuilt, Error>) -> Void) {
        switch kind {
        case "v":
            guard let variant = variants.first(where: { $0.id == id }), index < segments.count else { return done(.failure(MediaError.invalidParameter)) }
            videoQueue.async { done(Result { try self.buildVideo(variant, index) }) }
        case "a":
            guard let entry = audio.first(where: { $0.id == id }), index < segments.count else { return done(.failure(MediaError.invalidParameter)) }
            audioQueue.async { done(Result { try self.buildAudio(entry, index) }) }
        case "s":
            guard let entry = text.first(where: { $0.id == id }), index == 0 else { return done(.failure(MediaError.invalidParameter)) }
            done(.success(AirPlayBuilt(initData: Data(), media: AirPlayWebVTT.file(cues(entry)))))
        default:
            done(.failure(MediaError.invalidParameter))
        }
    }

    private func cues(_ entry: Text) -> [AirPlayCue] {
        cuesLock.withLock {
            if let known = cues[entry.id] { return known }
            let parsed = AirPlayCues.parse(entry.format, textPackets[entry.info.index] ?? [])
            cues[entry.id] = parsed
            return parsed
        }
    }

    private func ticks(_ seconds: Double, _ base: AVRational) -> Int64 {
        Int64((seconds * Double(base.den) / Double(base.num)).rounded())
    }

    private func packets(_ demuxer: Demuxer, _ track: Track, from first: Packet, before end: Int64, keysOnly: Bool) -> () -> Packet? {
        var pending: Packet? = first
        let limit = end == .max ? end : end + 2 * Int64(track.timeBase.den) / Int64(track.timeBase.num)
        return {
            guard let packet = pending else { return nil }
            pending = (try? demuxer.next(packet, track)) ?? nil
            demuxer.forget(before: packet, track)
            if let following = pending, keysOnly ? following.sync && following.pts >= end || following.dts > limit : following.pts >= end { pending = nil }
            return packet
        }
    }

    private func buildVideo(_ variant: AirPlayVariant, _ index: Int) throws -> AirPlayBuilt {
        let segment = segments[index]
        let begin = ticks(segment.start, video.timeBase)
        let end = index + 1 < segments.count ? ticks(segments[index + 1].start, video.timeBase) : .max
        guard var first = try videoDemuxer.locate(video, begin) else { throw MediaError.noSamples }
        while !first.sync, let previous = try videoDemuxer.previous(first, video) { first = previous }
        let next = packets(videoDemuxer, video, from: first, before: end, keysOnly: true)
        let start = video.time(min(first.dts, first.pts))
        var failed = false
        if !variant.transcode {
            let built = try AirPlaySegmentWriter.build(.video, format: video.format.description, settings: nil, start: start, number: index) { [self] in
                guard let packet = next() else { return nil }
                guard let sample = try? videoDemuxer.sampleBuffer([packet], video) else {
                    failed = true
                    return nil
                }
                return sample
            }
            if failed { throw MediaError.internalFailure }
            return built
        }
        let burner = pictures.map { AirPlayBurner(pictures: $0, from: segment.start, to: segment.end) }
        let hardware = frameDecoder == nil ? AirPlayHardwareDecoder(video.format.description) : nil
        guard frameDecoder != nil || hardware != nil else { throw MediaError.unsupportedFeature }
        frameDecoder?.flush()
        var ready: [CMSampleBuffer] = []
        var drained = false
        let from = video.time(first.pts)
        let built = try AirPlaySegmentWriter.build(.video, format: nil, settings: settings(variant), start: from, number: index) { [self] in
            while true {
                if !ready.isEmpty {
                    let frame = ready.removeFirst()
                    guard CMSampleBufferGetPresentationTimeStamp(frame) >= from else { continue }
                    guard let burner else { return frame }
                    guard let burned = burner.apply(frame) else {
                        failed = true
                        return nil
                    }
                    return burned
                }
                if drained { return nil }
                if let packet = next() {
                    guard let data = try? videoDemuxer.data(packet, video) else {
                        failed = true
                        return nil
                    }
                    if let hardware {
                        guard let sample = try? videoDemuxer.sampleBuffer([packet], video) else {
                            failed = true
                            return nil
                        }
                        ready = hardware.decode(sample)
                    } else {
                        ready = frameDecoder?.decode(data, pts: packet.pts, duration: packet.duration, video) ?? []
                    }
                } else {
                    ready = hardware?.finish() ?? frameDecoder?.decode(nil, pts: 0, duration: 0, video) ?? []
                    drained = true
                }
            }
        }
        if failed { throw MediaError.internalFailure }
        return built
    }

    private func settings(_ variant: AirPlayVariant) -> [String: Any] {
        let description = video.format.description
        func property(_ key: CFString) -> String? { CMFormatDescriptionGetExtension(description, extensionKey: key) as? String }
        let hdr = range != "SDR"
        let colour = [
            AVVideoColorPrimariesKey: property(kCMFormatDescriptionExtension_ColorPrimaries) ?? (hdr ? AVVideoColorPrimaries_ITU_R_2020 : AVVideoColorPrimaries_ITU_R_709_2),
            AVVideoTransferFunctionKey: property(kCMFormatDescriptionExtension_TransferFunction)
                ?? (range == "PQ" ? AVVideoTransferFunction_SMPTE_ST_2084_PQ : range == "HLG" ? AVVideoTransferFunction_ITU_R_2100_HLG : AVVideoTransferFunction_ITU_R_709_2),
            AVVideoYCbCrMatrixKey: property(kCMFormatDescriptionExtension_YCbCrMatrix) ?? (hdr ? AVVideoYCbCrMatrix_ITU_R_2020 : AVVideoYCbCrMatrix_ITU_R_709_2),
        ]
        let level = variant.codec == .hevc ? (variant.tenBit ? kVTProfileLevel_HEVC_Main10_AutoLevel : kVTProfileLevel_HEVC_Main_AutoLevel) : AVVideoProfileLevelH264HighAutoLevel as CFString
        return [
            AVVideoCodecKey: variant.codec == .hevc ? AVVideoCodecType.hevc : AVVideoCodecType.h264,
            AVVideoWidthKey: variant.width & ~1,
            AVVideoHeightKey: variant.height & ~1,
            AVVideoColorPropertiesKey: colour,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: variant.bitrate,
                AVVideoProfileLevelKey: level as String,
                AVVideoAllowFrameReorderingKey: false,
                AVVideoMaxKeyFrameIntervalDurationKey: 2.0,
            ] as [String: Any],
        ]
    }

    private func buildAudio(_ entry: Audio, _ index: Int) throws -> AirPlayBuilt {
        guard let demuxer = audioDemuxer else { throw MediaError.noSamples }
        let segment = segments[index]
        let last = index + 1 == segments.count
        let track = entry.track
        if entry.plan == .asIs {
            let begin = ticks(segment.start, track.timeBase)
            let end = last ? .max : ticks(segment.end, track.timeBase)
            guard var first = try demuxer.locate(track, begin) else { throw MediaError.noSamples }
            while first.pts < begin, let following = try demuxer.next(first, track) { first = following }
            let next = packets(demuxer, track, from: first, before: end, keysOnly: false)
            var failed = false
            let built = try AirPlaySegmentWriter.build(.audio, format: track.format.description, settings: nil, start: track.time(first.pts), number: index) {
                guard let packet = next() else { return nil }
                guard let sample = try? demuxer.sampleBuffer([packet], track) else {
                    failed = true
                    return nil
                }
                return sample
            }
            if failed { throw MediaError.internalFailure }
            return built
        }
        guard let encoder = AirPlayAudioEncoder(entry.plan == .alac ? .alac : .aac, sampleRate: entry.rate, channels: entry.channels, bits: entry.info.bits),
              let decoder = AirPlayAudioDecoder(track.format.description) else { throw MediaError.unsupportedFeature }
        let reader = AirPlayPCMReader(demuxer: demuxer, track: track, decoder: decoder, rate: entry.rate, channels: entry.channels)
        let lead = AirPlayAudioGrid.lead
        let range = AirPlayAudioGrid.range(of: segment, rate: entry.rate, frames: encoder.frames, lead: lead, last: last, total: duration)
        let packets = AirPlayAudioGrid.encode(range, with: encoder, lead: lead, warmup: AirPlayAudioGrid.warmup, pcm: reader.samples)
        let start = AirPlayAudioGrid.time(ofPacket: range.lowerBound, rate: entry.rate, frames: encoder.frames, lead: lead)
        guard let sample = encoder.sample(packets, start: start) else { throw MediaError.noSamples }
        var pending: CMSampleBuffer? = sample
        return try AirPlaySegmentWriter.build(.audio, format: encoder.format, settings: nil, start: start, number: index) {
            defer { pending = nil }
            return pending
        }
    }
}
