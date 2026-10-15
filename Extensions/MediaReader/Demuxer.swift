import CoreMedia
import Foundation

struct PacketKey: Hashable {
    let position: Int64
    let pts: Int64
    let size: Int32
}

final class Packet {
    var pts: Int64
    let dts: Int64
    let duration: Int64
    let sync: Bool
    let samples: Int64
    var open = false
    var guessed = false
    var data: Data?
    var stamp = 0
    unowned var run: Run
    var index: Int

    init(pts: Int64, dts: Int64, duration: Int64, sync: Bool, samples: Int64, run: Run) {
        self.pts = pts
        self.dts = dts
        self.duration = duration
        self.sync = sync
        self.samples = samples
        self.run = run
        index = run.packets.count
        run.packets.append(self)
    }
}

struct MediaTags {
    var title: String?
    var artist: String?
    var album: String?
    var cover: Data?
}

final class Run {
    var packets: [Packet] = []
    var atStart = false
    var atEnd = false
}

final class Track {
    let index: Int32
    let timeBase: AVRational
    let format: TrackFormat
    let size: CGSize
    let frameRate: Float
    let reorders: Bool
    var enabled = false
    fileprivate let offset: Int64
    fileprivate let defaultDuration: Int64
    fileprivate let delay: Int64
    fileprivate let decodeOrderTimes: Bool
    fileprivate let sampleRate: Int64
    fileprivate let bytesPerFrame: Int
    fileprivate var runs: [Run] = []
    fileprivate var known: [PacketKey: Packet] = [:]
    fileprivate var head: Packet?
    fileprivate var fresh = true
    fileprivate var order: (pts: Int64, poc: Int32)?
    fileprivate var guess: Packet?
    private var pocStep: Int32 = 2
    fileprivate var parser: UnsafeMutablePointer<AVCodecParserContext>?
    private var parserContext: UnsafeMutablePointer<AVCodecContext>?

    fileprivate init(_ stream: UnsafeMutablePointer<AVStream>, format: TrackFormat, start: Int64, decodeOrderTimes: Bool) {
        let par = stream.pointee.codecpar.pointee
        index = stream.pointee.index
        timeBase = stream.pointee.time_base
        self.format = format
        self.decodeOrderTimes = decodeOrderTimes
        offset = start == PikaNoTimestamp ? 0 : av_rescale_q(start, AVRational(num: 1, den: AV_TIME_BASE), timeBase)
        let plausible = { (rate: AVRational) -> Bool in rate.num > 0 && rate.den > 0 && Int64(rate.num) <= 480 * Int64(rate.den) }
        let rate = plausible(stream.pointee.avg_frame_rate) ? stream.pointee.avg_frame_rate : plausible(stream.pointee.r_frame_rate) ? stream.pointee.r_frame_rate : AVRational(num: 0, den: 1)
        frameRate = rate.num > 0 && rate.den > 0 ? Float(rate.num) / Float(rate.den) : 0
        sampleRate = Int64(par.sample_rate)
        let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(format.description)?.pointee
        bytesPerFrame = asbd?.mFormatID == kAudioFormatLinearPCM ? Int(asbd?.mBytesPerFrame ?? 0) : 0
        if par.codec_type == AVMEDIA_TYPE_VIDEO {
            defaultDuration = rate.num > 0 && rate.den > 0 ? max(1, av_rescale_q(1, AVRational(num: rate.den, den: rate.num), timeBase)) : 1
            let aspect = stream.pointee.sample_aspect_ratio.num > 0 ? stream.pointee.sample_aspect_ratio : par.sample_aspect_ratio
            let scale = aspect.num > 0 && aspect.den > 0 ? Double(aspect.num) / Double(aspect.den) : 1
            size = CGSize(width: (Double(par.width) * scale).rounded(), height: Double(par.height))
        } else {
            defaultDuration = par.frame_size > 0 && par.sample_rate > 0 ? max(1, av_rescale_q(Int64(par.frame_size), AVRational(num: 1, den: par.sample_rate), timeBase)) : 1
            size = .zero
        }
        delay = Int64(par.video_delay) * defaultDuration
        parser = decodeOrderTimes && par.codec_id == AV_CODEC_ID_H264 ? av_parser_init(Int32(AV_CODEC_ID_H264.rawValue)) : nil
        if let parser {
            parser.pointee.flags |= PARSER_FLAG_COMPLETE_FRAMES
            parserContext = avcodec_alloc_context3(nil)
            avcodec_parameters_to_context(parserContext, stream.pointee.codecpar)
        }
        reorders = !decodeOrderTimes && par.video_delay > 0 || parser != nil
    }

    deinit {
        av_parser_close(parser)
        avcodec_free_context(&parserContext)
    }

    func time(_ ticks: Int64) -> CMTime {
        CMTime(value: ticks * Int64(timeBase.num), timescale: timeBase.den)
    }

    func ticks(_ time: CMTime) -> Int64 {
        let scaled = CMTimeConvertScale(time, timescale: timeBase.den, method: .roundTowardNegativeInfinity).value
        return scaled >= 0 ? scaled / Int64(timeBase.num) : -((-scaled + Int64(timeBase.num) - 1) / Int64(timeBase.num))
    }

    fileprivate func pictureOrder(_ packet: AVPacket) -> Int32? {
        guard let parser else { return nil }
        var data: UnsafeMutablePointer<UInt8>?
        var size: Int32 = 0
        av_parser_parse2(parser, parserContext, &data, &size, packet.data, packet.size, PikaNoTimestamp, PikaNoTimestamp, packet.pos)
        return size > 0 ? parser.pointee.output_picture_number : nil
    }

    fileprivate func present(_ added: Packet, _ poc: Int32, _ packet: AVPacket) {
        let refresh = packet.flags & AV_PKT_FLAG_KEY != 0 && (Self.instantRefresh(packet) || order.map { poc <= $0.poc } ?? false)
        if var order, !refresh {
            if let guess, guess.index >= 0, poc < order.poc {
                for earlier in guess.run.packets[guess.index...] where earlier !== added { earlier.pts += defaultDuration }
                order.pts += defaultDuration
            } else if poc > order.poc {
                guess?.guessed = false
                guess = nil
            }
            self.order = order
        } else {
            order = (added.dts, poc)
            added.guessed = !refresh
            guess = refresh ? nil : added
        }
        guard let order else { return }
        if poc % 2 != 0, pocStep == 2 {
            pocStep = 1
            for earlier in runs.flatMap(\.packets) where earlier.pts > order.pts { earlier.pts = order.pts + (earlier.pts - order.pts) * 2 }
        }
        added.pts = order.pts + Int64((poc - order.poc) / pocStep) * defaultDuration
    }

    private static func instantRefresh(_ packet: AVPacket) -> Bool {
        guard let data = packet.data, packet.size > 1 else { return false }
        var zeros = 0
        for i in 0..<Int(packet.size) - 1 {
            if zeros >= 2, data[i] == 1, (1...5).contains(data[i + 1] & 0x1F) { return data[i + 1] & 0x1F == 5 }
            zeros = data[i] == 0 ? zeros + 1 : 0
        }
        return false
    }

    fileprivate func payload(_ packet: AVPacket) -> Data {
        if let decoder = format.audioDecoder { return decoder.decode(packet.data, packet.size) }
        let data = packet.data.map { Data(bytes: $0, count: Int(packet.size)) } ?? Data()
        return format.convert?(data) ?? data
    }

    fileprivate func duration(_ packet: AVPacket, _ data: Data) -> Int64 {
        if bytesPerFrame > 0, sampleRate > 0 {
            return max(1, av_rescale_q(Int64(data.count / bytesPerFrame), AVRational(num: 1, den: Int32(sampleRate)), timeBase))
        }
        return packet.duration > 0 ? packet.duration : defaultDuration
    }
}

private final class ByteReader {
    let read: (UnsafeMutablePointer<UInt8>, Int32, Int64) -> Int32
    let size: Int64
    var position: Int64 = 0

    init(size: Int64, read: @escaping (UnsafeMutablePointer<UInt8>, Int32, Int64) -> Int32) {
        self.size = size
        self.read = read
    }
}

private let readBytes: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutablePointer<UInt8>?, Int32) -> Int32 = { opaque, buffer, size in
    guard let opaque, let buffer else { return PikaErrorEOF }
    let reader = Unmanaged<ByteReader>.fromOpaque(opaque).takeUnretainedValue()
    guard reader.position < reader.size else { return PikaErrorEOF }
    let count = reader.read(buffer, Int32(min(Int64(size), reader.size - reader.position)), reader.position)
    if count > 0 { reader.position += Int64(count) }
    return count
}

private let seekBytes: @convention(c) (UnsafeMutableRawPointer?, Int64, Int32) -> Int64 = { opaque, offset, whence in
    guard let opaque else { return -1 }
    let reader = Unmanaged<ByteReader>.fromOpaque(opaque).takeUnretainedValue()
    switch whence & ~AVSEEK_FORCE {
    case AVSEEK_SIZE: return reader.size
    case SEEK_SET: reader.position = offset
    case SEEK_CUR: reader.position += offset
    case SEEK_END: reader.position = reader.size + offset
    default: return -1
    }
    return reader.position
}

struct Chapter {
    let start: Double
    let title: String
}

final class Demuxer {
    let streams: [Track]
    let duration: CMTime
    private let memoryLimit: Int
    private let lock = NSRecursiveLock()
    private let reader: ByteReader
    private var context: UnsafeMutablePointer<AVFormatContext>?
    private var packet = av_packet_alloc()
    private var byIndex: [Int32: Track] = [:]
    private var held: [(Packet, Int)] = []
    private var heldStart = 0
    private var heldBytes = 0
    private var stamp = 0

    init(name: String, size: Int64, memoryLimit: Int = 96 << 20, read: @escaping (UnsafeMutablePointer<UInt8>, Int32, Int64) -> Int32) throws {
        reader = ByteReader(size: size, read: read)
        self.memoryLimit = memoryLimit
        av_log_set_level(AV_LOG_QUIET)
        let bufferSize: Int32 = 1 << 16
        guard let buffer = av_malloc(Int(bufferSize)),
              let io = avio_alloc_context(buffer.assumingMemoryBound(to: UInt8.self), bufferSize, 0, Unmanaged.passUnretained(reader).toOpaque(), readBytes, nil, seekBytes) else {
            throw MediaError.allocationFailure
        }
        var context = avformat_alloc_context()
        context?.pointee.pb = io
        guard avformat_open_input(&context, name, nil, nil) == 0, let context else {
            Self.free(io)
            throw MediaError.unsupportedFeature
        }
        guard avformat_find_stream_info(context, nil) >= 0 else {
            var failed: UnsafeMutablePointer<AVFormatContext>? = context
            avformat_close_input(&failed)
            Self.free(io)
            throw MediaError.parsingFailure
        }
        self.context = context
        let container = String(cString: context.pointee.iformat.pointee.name)
        var candidates: [Track] = []
        for i in 0..<Int(context.pointee.nb_streams) {
            guard let stream = context.pointee.streams[i] else { continue }
            stream.pointee.discard = AVDISCARD_ALL
            let par = stream.pointee.codecpar.pointee
            let decodeOrderTimes = container == "avi" || container == "asf" || container.hasPrefix("matroska") && par.codec_type == AVMEDIA_TYPE_VIDEO && par.codec_tag != 0
            guard stream.pointee.disposition & AV_DISPOSITION_ATTACHED_PIC == 0, let format = makeTrackFormat(stream, decodeOrderTimes: decodeOrderTimes) else { continue }
            stream.pointee.discard = AVDISCARD_DEFAULT
            candidates.append(Track(stream, format: format, start: context.pointee.start_time, decodeOrderTimes: decodeOrderTimes))
        }
        for stream in candidates { byIndex[stream.index] = stream }
        streams = candidates
        duration = context.pointee.duration > 0 ? CMTime(value: context.pointee.duration, timescale: CMTimeScale(AV_TIME_BASE)) : .invalid
        var count = 0
        while count < 4000, candidates.contains(where: { ($0.runs.first?.packets.count ?? 0) < 8 }), try readPacket() != nil { count += 1 }
        for stream in candidates where stream.runs.isEmpty {
            context.pointee.streams[Int(stream.index)]?.pointee.discard = AVDISCARD_ALL
            byIndex[stream.index] = nil
        }
        let found = candidates.filter { !$0.runs.isEmpty }
        for type in [kCMMediaType_Video, kCMMediaType_Audio] {
            let ofType = found.filter { $0.format.mediaType == type }
            let preferred = ofType.first { context.pointee.streams[Int($0.index)]!.pointee.disposition & AV_DISPOSITION_DEFAULT != 0 } ?? ofType.first
            preferred?.enabled = true
        }
        guard !found.isEmpty else { throw MediaError.unsupportedFeature }
    }

    deinit {
        let io = context?.pointee.pb
        avformat_close_input(&context)
        if let io { Self.free(io) }
        av_packet_free(&packet)
    }

    private static func free(_ io: UnsafeMutablePointer<AVIOContext>) {
        var io: UnsafeMutablePointer<AVIOContext>? = io
        av_freep(&io!.pointee.buffer)
        avio_context_free(&io)
    }

    var tracks: [Track] {
        streams.filter { byIndex[$0.index] != nil }
    }

    func chapters() -> [Chapter] {
        lock.withLock {
            guard let context else { return [] }
            let offset = context.pointee.start_time == PikaNoTimestamp ? 0 : Double(context.pointee.start_time) / Double(AV_TIME_BASE)
            var found: [Chapter] = []
            for index in 0..<Int(context.pointee.nb_chapters) {
                guard let chapter = context.pointee.chapters[index]?.pointee, chapter.time_base.den > 0 else { continue }
                let start = Double(chapter.start) * Double(chapter.time_base.num) / Double(chapter.time_base.den) - offset
                guard start.isFinite else { continue }
                let title = av_dict_get(chapter.metadata, "title", nil, 0).map { String(cString: $0.pointee.value) } ?? ""
                found.append(Chapter(start: max(0, start), title: title))
            }
            return found.sorted { $0.start < $1.start }
        }
    }

    func tags() -> MediaTags {
        lock.withLock {
            guard let context else { return MediaTags() }
            let streams = (0..<Int(context.pointee.nb_streams)).compactMap { context.pointee.streams[$0] }
            let dictionaries = [context.pointee.metadata] + streams.map { $0.pointee.metadata }
            func tag(_ keys: String...) -> String? {
                for key in keys {
                    for dictionary in dictionaries {
                        guard let value = av_dict_get(dictionary, key, nil, 0)?.pointee.value else { continue }
                        let text = String(cString: value).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !text.isEmpty { return text }
                    }
                }
                return nil
            }
            let picture = streams.first { $0.pointee.disposition & AV_DISPOSITION_ATTACHED_PIC != 0 && $0.pointee.attached_pic.size > 0 }?.pointee.attached_pic
            return MediaTags(title: tag("title"), artist: tag("artist", "album_artist", "author", "performer"), album: tag("album"),
                             cover: picture.flatMap { picture in picture.data.map { Data(bytes: $0, count: Int(picture.size)) } })
        }
    }

    func discard(except used: [Track]) {
        lock.withLock {
            for stream in tracks where !used.contains(where: { $0 === stream }) {
                context?.pointee.streams[Int(stream.index)]?.pointee.discard = AVDISCARD_ALL
                byIndex[stream.index] = nil
            }
        }
    }

    func forget(before packet: Packet, _ stream: Track) {
        lock.withLock {
            let run = packet.run
            guard packet.index >= 4096 || stream.runs.count > 1 else { return }
            for old in stream.runs.filter({ $0 !== run }).flatMap(\.packets) + run.packets[..<packet.index] {
                if let data = old.data { heldBytes -= data.count }
                old.data = nil
                old.index = -1
            }
            if packet.index > 0 {
                run.packets.removeFirst(packet.index)
                for (index, kept) in run.packets.enumerated() { kept.index = index }
                run.atStart = false
            }
            stream.runs = [run]
            stream.known = stream.known.filter { $0.value.index >= 0 }
            if let head = stream.head, head.index < 0 { stream.head = nil }
        }
    }

    func first(_ stream: Track) -> Packet? {
        lock.withLock { stream.runs.first { $0.atStart }?.packets.first }
    }

    func firstInPresentationOrder(_ stream: Track) -> Packet? {
        lock.withLock { stream.runs.first { $0.atStart }?.packets.prefix(32).min { $0.pts < $1.pts } }
    }

    func last(_ stream: Track) throws -> Packet? {
        try lock.withLock {
            for back: Int64 in [10, 60, 600, -1] {
                if let run = stream.runs.first(where: { $0.atEnd }) { return run.packets.last }
                guard let context else { break }
                let start = context.pointee.start_time == PikaNoTimestamp ? 0 : context.pointee.start_time
                let end = context.pointee.duration > 0 ? start + context.pointee.duration : start
                try seek(to: back < 0 ? start : end - back * Int64(AV_TIME_BASE))
                while try readPacket() != nil {}
            }
            return stream.runs.first { $0.atEnd }?.packets.last
        }
    }

    func next(_ packet: Packet, _ stream: Track) throws -> Packet? {
        try lock.withLock {
            if packet.index + 1 < packet.run.packets.count { return packet.run.packets[packet.index + 1] }
            if packet.run.atEnd { return nil }
            try reach(packet, stream)
            try read(stream) { _ in true }
            return packet.index + 1 < packet.run.packets.count ? packet.run.packets[packet.index + 1] : nil
        }
    }

    func previous(_ packet: Packet, _ stream: Track) throws -> Packet? {
        try lock.withLock {
            var back = Int64(AV_TIME_BASE)
            for _ in 0..<6 {
                if packet.index > 0 { return packet.run.packets[packet.index - 1] }
                if packet.run.atStart { return nil }
                try seek(to: microseconds(min(packet.pts, packet.dts), stream) - back)
                try read(stream) { $0 === packet || $0.dts > packet.dts }
                back *= 8
            }
            if packet.index > 0 { return packet.run.packets[packet.index - 1] }
            packet.run.atStart = true
            return nil
        }
    }

    func locate(_ stream: Track, _ time: Int64) throws -> Packet? {
        try lock.withLock {
            var start: Packet?
            if let run = stream.runs.first(where: { $0.packets[0].dts <= time && ($0.atEnd || $0.packets[$0.packets.count - 1].dts > time) }) {
                var low = 0, high = run.packets.count
                while low < high {
                    let middle = (low + high) / 2
                    if run.packets[middle].dts > time { high = middle } else { low = middle + 1 }
                }
                start = run.packets[low - 1]
            } else {
                try seek(to: microseconds(time, stream))
                try read(stream) { $0.dts > time }
                guard let head = stream.head else { return try last(stream) }
                start = head.dts > time ? try previous(head, stream) : head
            }
            var best: Packet?
            var ahead = start
            for _ in 0..<16 {
                guard let packet = ahead, let following = try next(packet, stream) else { break }
                if following.pts <= time, following.pts > best?.pts ?? .min { best = following }
                ahead = following
            }
            var after = 0, scanned = 0
            while let packet = start, after < 16, scanned < 4096 {
                scanned += 1
                if packet.pts <= time, packet.pts > best?.pts ?? .min { best = packet }
                if best != nil { after += 1 }
                start = try previous(packet, stream)
            }
            return best ?? firstInPresentationOrder(stream)
        }
    }

    func data(_ packet: Packet, _ stream: Track) throws -> Data {
        try lock.withLock {
            if let data = packet.data { return data }
            stream.head = nil
            try reach(packet, stream)
            guard let data = packet.data else { throw MediaError.parsingFailure }
            return data
        }
    }

    func sampleBuffer(_ packets: [Packet], _ stream: Track) throws -> CMSampleBuffer {
        let parts = try packets.map { try data($0, stream) }
        let total = parts.reduce(0) { $0 + $1.count }
        var block: CMBlockBuffer?
        guard total > 0, CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: total, blockAllocator: nil, customBlockSource: nil,
                                                            offsetToData: 0, dataLength: total, flags: kCMBlockBufferAssureMemoryNowFlag, blockBufferOut: &block) == noErr,
              let block else { throw MediaError.allocationFailure }
        var offset = 0
        for part in parts {
            _ = part.withUnsafeBytes { CMBlockBufferReplaceDataBytes(with: $0.baseAddress!, blockBuffer: block, offsetIntoDestination: offset, dataLength: part.count) }
            offset += part.count
        }
        let description = stream.format.description
        var buffer: CMSampleBuffer?
        var status: OSStatus
        if stream.format.mediaType == kCMMediaType_Video {
            var timing = packets.map { CMSampleTimingInfo(duration: stream.time($0.duration), presentationTimeStamp: stream.time($0.pts), decodeTimeStamp: stream.time($0.dts)) }
            var sizes = parts.map(\.count)
            status = CMSampleBufferCreateReady(allocator: nil, dataBuffer: block, formatDescription: description, sampleCount: packets.count,
                                               sampleTimingEntryCount: timing.count, sampleTimingArray: &timing, sampleSizeEntryCount: sizes.count, sampleSizeArray: &sizes, sampleBufferOut: &buffer)
            if let buffer, let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: true) as? [NSMutableDictionary] {
                for (packet, attachment) in zip(packets, attachments) where !packet.sync || packet.open {
                    attachment[kCMSampleAttachmentKey_NotSync] = true
                    if packet.sync { attachment[kCMSampleAttachmentKey_PartialSync] = true }
                }
            }
        } else {
            guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(description)?.pointee else { throw MediaError.internalFailure }
            if asbd.mFormatID == kAudioFormatLinearPCM {
                status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(allocator: nil, dataBuffer: block, formatDescription: description,
                                                                              sampleCount: total / Int(asbd.mBytesPerFrame), presentationTimeStamp: stream.time(packets[0].pts), packetDescriptions: nil, sampleBufferOut: &buffer)
            } else {
                var start: Int64 = 0
                var descriptions: [AudioStreamPacketDescription] = []
                for (packet, part) in zip(packets, parts) {
                    let frames = asbd.mFramesPerPacket == 0 ? UInt32(max(0, av_rescale_q(packet.duration, stream.timeBase, AVRational(num: 1, den: Int32(asbd.mSampleRate))))) : 0
                    descriptions.append(AudioStreamPacketDescription(mStartOffset: start, mVariableFramesInPacket: frames, mDataByteSize: UInt32(part.count)))
                    start += Int64(part.count)
                }
                status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(allocator: nil, dataBuffer: block, formatDescription: description,
                                                                              sampleCount: packets.count, presentationTimeStamp: stream.time(packets[0].pts), packetDescriptions: &descriptions, sampleBufferOut: &buffer)
            }
        }
        guard status == noErr, let buffer else { throw MediaError.internalFailure }
        return buffer
    }

    private func microseconds(_ ticks: Int64, _ stream: Track) -> Int64 {
        av_rescale_q(ticks + stream.offset, stream.timeBase, AVRational(num: 1, den: AV_TIME_BASE))
    }

    private func reach(_ packet: Packet, _ stream: Track) throws {
        var back: Int64 = 0
        for _ in 0..<6 {
            if stream.head === packet { return }
            try seek(to: microseconds(min(packet.pts, packet.dts), stream) - back)
            try read(stream) { $0 === packet || $0.dts > packet.dts }
            back = back == 0 ? Int64(AV_TIME_BASE) : back * 8
        }
        if stream.head !== packet { throw MediaError.parsingFailure }
    }

    private func seek(to time: Int64) throws {
        guard let context else { throw MediaError.internalFailure }
        let any = streams.contains { $0.parser != nil } ? 0 : AVSEEK_FLAG_ANY
        guard av_seek_frame(context, -1, time, AVSEEK_FLAG_BACKWARD | any) >= 0 || av_seek_frame(context, -1, time, any) >= 0 else { throw MediaError.parsingFailure }
        context.pointee.pb.pointee.error = 0
        for stream in streams {
            stream.head = nil
            stream.fresh = false
            stream.format.audioDecoder?.flush()
            stream.order = nil
        }
    }

    private func read(_ stream: Track, until done: (Packet) -> Bool) throws {
        for _ in 0..<2_000_000 {
            guard let index = try readPacket() else { return }
            if index == stream.index, let head = stream.head, done(head) { return }
        }
    }

    private func readPacket() throws -> Int32? {
        guard let context, let packet else { throw MediaError.internalFailure }
        for _ in 0..<64 {
            let result = av_read_frame(context, packet)
            if result == PikaErrorEOF {
                for stream in streams {
                    if let head = stream.head, head.index == head.run.packets.count - 1 { head.run.atEnd = true }
                }
                return nil
            }
            if result < 0 {
                if context.pointee.pb.pointee.error < 0 { throw MediaError.parsingFailure }
                continue
            }
            defer { av_packet_unref(packet) }
            route(packet.pointee)
            return packet.pointee.stream_index
        }
        throw MediaError.parsingFailure
    }

    private func route(_ packet: AVPacket) {
        guard let stream = byIndex[packet.stream_index] else { return }
        let key = PacketKey(position: packet.pos, pts: packet.pts, size: packet.size)
        let poc = stream.pictureOrder(packet)
        if let known = stream.known[key] {
            if let poc { (stream.order, stream.guess) = ((known.pts, poc), known.guessed ? known : nil) }
            if known.data == nil { hold(known, stream.payload(packet)) }
            if let head = stream.head, head.run !== known.run, head.index == head.run.packets.count - 1, known.index == 0 {
                merge(known.run, into: head.run, stream)
            }
            stream.head = known
            stream.fresh = false
            return
        }
        let previous = stream.head.flatMap { $0.index == $0.run.packets.count - 1 ? $0 : nil }
        let pts = stream.decodeOrderTimes || packet.pts == PikaNoTimestamp ? nil : packet.pts - stream.offset
        let raw = packet.dts == PikaNoTimestamp ? nil : packet.dts - stream.offset
        guard var dts = raw ?? previous.map({ $0.dts + $0.duration }) ?? pts.map({ $0 - stream.delay }) else { return }
        if let previous, dts <= previous.dts { dts = previous.dts + 1 }
        let data = stream.payload(packet)
        let run: Run
        if let previous {
            run = previous.run
        } else {
            run = Run()
            run.atStart = stream.fresh
            stream.runs.append(run)
        }
        let added = Packet(pts: pts ?? dts, dts: dts, duration: stream.duration(packet, data), sync: packet.flags & AV_PKT_FLAG_KEY != 0,
                           samples: stream.bytesPerFrame > 0 ? Int64(data.count / stream.bytesPerFrame) : 1, run: run)
        if let poc { stream.present(added, poc, packet) }
        if let previous, previous.sync, added.pts < previous.pts, !run.atStart || previous.index > 0 { previous.open = true }
        stream.known[key] = added
        stream.head = added
        stream.fresh = false
        hold(added, data)
    }

    private func merge(_ run: Run, into target: Run, _ stream: Track) {
        for packet in run.packets {
            packet.run = target
            packet.index = target.packets.count
            target.packets.append(packet)
        }
        target.atEnd = run.atEnd
        stream.runs.removeAll { $0 === run }
    }

    private func hold(_ packet: Packet, _ data: Data) {
        packet.data = data
        stamp += 1
        packet.stamp = stamp
        held.append((packet, stamp))
        heldBytes += data.count
        while heldStart < held.count, heldBytes > memoryLimit || held[heldStart].0.data == nil || held[heldStart].0.stamp != held[heldStart].1 {
            let (old, oldStamp) = held[heldStart]
            heldStart += 1
            if old.stamp == oldStamp, let data = old.data {
                old.data = nil
                heldBytes -= data.count
            }
        }
        if heldStart > 4096 {
            held.removeFirst(heldStart)
            heldStart = 0
        }
    }
}
