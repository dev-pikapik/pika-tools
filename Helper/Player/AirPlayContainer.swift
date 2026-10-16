import Foundation

struct AirPlayStreamInfo {
    enum Kind {
        case video, audio, text, picture, other
    }

    let index: Int32
    let kind: Kind
    let codec: AVCodecID
    let language: String?
    let title: String?
    let isDefault: Bool
    let isForced: Bool
    let channels: Int
    let bits: Int
    let depth: Int
    let transfer: AVColorTransferCharacteristic
    let profile: Int
    let width: Int
    let height: Int
}

final class AirPlayContainer {
    static let packetLimit = 128 << 20
    let streams: [AirPlayStreamInfo]
    let size: Int64
    private(set) var duration = 0.0
    private let reader: ByteReader
    private var context: UnsafeMutablePointer<AVFormatContext>?
    private var origin: Int64 = 0

    init(fd: Int32) throws {
        size = lseek(fd, 0, SEEK_END)
        reader = ByteReader(size: size) { buffer, count, offset in
            let read = pread(fd, buffer, Int(count), offset)
            return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
        }
        let bufferSize: Int32 = 1 << 20
        guard let buffer = av_malloc(Int(bufferSize)),
              let io = avio_alloc_context(buffer.assumingMemoryBound(to: UInt8.self), bufferSize, 0, Unmanaged.passUnretained(reader).toOpaque(), readBytes, nil, seekBytes) else {
            throw MediaError.allocationFailure
        }
        var opened = avformat_alloc_context()
        opened?.pointee.pb = io
        guard avformat_open_input(&opened, "airplay", nil, nil) == 0, let opened else {
            Demuxer.free(io)
            throw MediaError.unsupportedFeature
        }
        guard avformat_find_stream_info(opened, nil) >= 0 else {
            var failed: UnsafeMutablePointer<AVFormatContext>? = opened
            avformat_close_input(&failed)
            Demuxer.free(io)
            throw MediaError.parsingFailure
        }
        context = opened
        duration = opened.pointee.duration > 0 ? Double(opened.pointee.duration) / Double(AV_TIME_BASE) : 0
        origin = opened.pointee.start_time == PikaNoTimestamp ? 0 : opened.pointee.start_time
        var found: [AirPlayStreamInfo] = []
        for i in 0..<Int(opened.pointee.nb_streams) {
            guard let stream = opened.pointee.streams[i] else { continue }
            let par = stream.pointee.codecpar.pointee
            func tag(_ key: String) -> String? {
                av_dict_get(stream.pointee.metadata, key, nil, 0).map { String(cString: $0.pointee.value).trimmingCharacters(in: .whitespacesAndNewlines) }.flatMap { $0.isEmpty ? nil : $0 }
            }
            let kind: AirPlayStreamInfo.Kind
            switch par.codec_type {
            case AVMEDIA_TYPE_VIDEO: kind = stream.pointee.disposition & AV_DISPOSITION_ATTACHED_PIC == 0 ? .video : .other
            case AVMEDIA_TYPE_AUDIO: kind = .audio
            case AVMEDIA_TYPE_SUBTITLE:
                switch par.codec_id {
                case AV_CODEC_ID_SUBRIP, AV_CODEC_ID_ASS, AV_CODEC_ID_SSA, AV_CODEC_ID_MOV_TEXT, AV_CODEC_ID_WEBVTT, AV_CODEC_ID_TEXT: kind = .text
                case AV_CODEC_ID_HDMV_PGS_SUBTITLE, AV_CODEC_ID_DVD_SUBTITLE, AV_CODEC_ID_DVB_SUBTITLE: kind = .picture
                default: kind = .other
                }
            default: kind = .other
            }
            let depth = av_pix_fmt_desc_get(AVPixelFormat(par.format)).map { Int($0.pointee.comp.0.depth) } ?? 8
            found.append(AirPlayStreamInfo(index: Int32(i), kind: kind, codec: par.codec_id, language: tag("language").flatMap { $0 == "und" ? nil : $0 }, title: tag("title"),
                                           isDefault: stream.pointee.disposition & AV_DISPOSITION_DEFAULT != 0, isForced: stream.pointee.disposition & AV_DISPOSITION_FORCED != 0,
                                           channels: Int(par.ch_layout.nb_channels), bits: Int(par.bits_per_raw_sample), depth: par.bits_per_raw_sample > 8 ? Int(par.bits_per_raw_sample) : depth,
                                           transfer: par.color_trc, profile: Int(par.profile), width: Int(par.width), height: Int(par.height)))
        }
        streams = found
    }

    deinit {
        let io = context?.pointee.pb
        avformat_close_input(&context)
        if let io { Demuxer.free(io) }
    }

    func parameters(_ index: Int32) -> UnsafeMutablePointer<AVCodecParameters>? {
        context?.pointee.streams[Int(index)]?.pointee.codecpar
    }

    func scan(video: Int32, keep: [Int32]) -> AirPlayScan? {
        var allocated = av_packet_alloc()
        defer { av_packet_free(&allocated) }
        guard let context, let packet = allocated, let stream = context.pointee.streams[Int(video)] else { return nil }
        let wanted = keep + [video]
        for i in 0..<Int(context.pointee.nb_streams) {
            context.pointee.streams[i]?.pointee.discard = wanted.contains(Int32(i)) ? AVDISCARD_DEFAULT : AVDISCARD_ALL
        }
        defer { for i in 0..<Int(context.pointee.nb_streams) { context.pointee.streams[i]?.pointee.discard = AVDISCARD_DEFAULT } }
        guard av_seek_frame(context, -1, origin, AVSEEK_FLAG_BACKWARD) >= 0 else { return nil }
        context.pointee.pb.pointee.error = 0
        var result = AirPlayScan(base: stream.pointee.time_base)
        var key: (time: Int64, open: Bool)?
        var total = 0
        func close() {
            if let key { if key.open { result.open.append(key.time) } else { result.keys.append(key.time) } }
        }
        while av_read_frame(context, packet) >= 0 {
            defer { av_packet_unref(packet) }
            let index = packet.pointee.stream_index
            guard let source = context.pointee.streams[Int(index)], wanted.contains(index) else { continue }
            let stamp = packet.pointee.pts == PikaNoTimestamp ? packet.pointee.dts : packet.pointee.pts
            guard stamp != PikaNoTimestamp, source.pointee.time_base.den > 0 else { continue }
            let base = source.pointee.time_base
            let shift = av_rescale_q(origin, AVRational(num: 1, den: AV_TIME_BASE), base)
            if index == video {
                let time = stamp - shift
                if packet.pointee.flags & AV_PKT_FLAG_KEY != 0 {
                    close()
                    key = (time, false)
                } else if let current = key, time < current.time {
                    key?.open = true
                }
                result.end = max(result.end, time + max(packet.pointee.duration, 0))
            } else if let bytes = packet.pointee.data, packet.pointee.size > 0, total < Self.packetLimit {
                let scale = Double(base.num) / Double(base.den)
                result.packets[index, default: []].append(AirPlayRawPacket(time: Double(stamp - shift) * scale, duration: Double(max(packet.pointee.duration, 0)) * scale,
                                                                           data: Data(bytes: bytes, count: Int(packet.pointee.size))))
                total += Int(packet.pointee.size)
            }
        }
        close()
        return result
    }
}

struct AirPlayScan {
    var base: AVRational
    var keys: [Int64] = []
    var open: [Int64] = []
    var end: Int64 = 0
    var packets: [Int32: [AirPlayRawPacket]] = [:]
}
