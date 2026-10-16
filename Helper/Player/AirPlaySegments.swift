import AVFoundation
import AudioToolbox
import CoreMedia
import UniformTypeIdentifiers

struct AirPlayBuilt {
    var initData: Data
    var media: Data
}

struct AirPlayCache {
    let limit: Int
    private var items: [String: AirPlayBuilt] = [:]
    private var order: [String] = []
    private(set) var bytes = 0

    init(limit: Int) {
        self.limit = limit
    }

    mutating func value(_ key: String) -> AirPlayBuilt? {
        guard let hit = items[key] else { return nil }
        order.removeAll { $0 == key }
        order.append(key)
        return hit
    }

    mutating func store(_ key: String, _ built: AirPlayBuilt) {
        if let old = items.removeValue(forKey: key) {
            bytes -= old.initData.count + old.media.count
            order.removeAll { $0 == key }
        }
        items[key] = built
        order.append(key)
        bytes += built.initData.count + built.media.count
        while bytes > limit, order.count > 1 {
            let oldest = order.removeFirst()
            if let dropped = items.removeValue(forKey: oldest) { bytes -= dropped.initData.count + dropped.media.count }
        }
    }

    mutating func removeAll() {
        items = [:]
        order = []
        bytes = 0
    }
}

enum AirPlayBuildError: Error {
    case writer(String)
}

private final class SegmentSink: NSObject, AVAssetWriterDelegate {
    var initData = Data()
    var media = Data()

    func assetWriter(_ writer: AVAssetWriter, didOutputSegmentData data: Data, segmentType: AVAssetSegmentType, segmentReport: AVAssetSegmentReport?) {
        if segmentType == .initialization { initData = data } else { media.append(data) }
    }
}

enum AirPlaySegmentWriter {
    static func build(_ type: AVFoundation.AVMediaType, format: CMFormatDescription?, settings: [String: Any]?, start: CMTime, number: Int, next: @escaping () -> CMSampleBuffer?) throws -> AirPlayBuilt {
        let writer = AVAssetWriter(contentType: UTType(AVFileType.mp4.rawValue)!)
        let sink = SegmentSink()
        writer.delegate = sink
        writer.outputFileTypeProfile = .mpeg4AppleHLS
        writer.preferredOutputSegmentInterval = .indefinite
        writer.initialSegmentStartTime = start
        let input = AVAssetWriterInput(mediaType: type, outputSettings: settings, sourceFormatHint: format)
        input.expectsMediaDataInRealTime = false
        guard writer.canAdd(input) else { throw AirPlayBuildError.writer("input refused") }
        writer.add(input)
        guard writer.startWriting() else { throw AirPlayBuildError.writer(writer.error?.localizedDescription ?? "start") }
        writer.startSession(atSourceTime: start)
        let queue = DispatchQueue(label: "pikapik.airplay.writer")
        let done = DispatchSemaphore(value: 0)
        input.requestMediaDataWhenReady(on: queue) {
            while input.isReadyForMoreMediaData {
                guard let sample = next() else {
                    input.markAsFinished()
                    done.signal()
                    return
                }
                if !input.append(sample) {
                    input.markAsFinished()
                    done.signal()
                    return
                }
            }
        }
        done.wait()
        let finished = DispatchSemaphore(value: 0)
        writer.finishWriting { finished.signal() }
        finished.wait()
        guard writer.status == .completed else { throw AirPlayBuildError.writer(writer.error?.localizedDescription ?? "status \(writer.status.rawValue)") }
        return AirPlayBuilt(initData: sink.initData, media: renumber(sink.media, first: number * 256 + 1))
    }

    static func renumber(_ data: Data, first: Int) -> Data {
        var data = data
        var offset = 0
        var number = first
        while offset + 8 <= data.count {
            var size = Int(data[offset]) << 24 | Int(data[offset + 1]) << 16 | Int(data[offset + 2]) << 8 | Int(data[offset + 3])
            let name = String(decoding: data[offset + 4..<offset + 8], as: UTF8.self)
            var header = 8
            if size == 1, offset + 16 <= data.count {
                size = (0..<8).reduce(0) { $0 << 8 | Int(data[offset + 8 + $1]) }
                header = 16
            } else if size == 0 {
                size = data.count - offset
            }
            guard size >= header, offset + size <= data.count else { break }
            if name == "moof", size >= header + 16, String(decoding: data[offset + header + 4..<offset + header + 8], as: UTF8.self) == "mfhd" {
                let at = offset + header + 12
                for i in 0..<4 { data[at + i] = UInt8(truncatingIfNeeded: number >> (24 - 8 * i)) }
                number += 1
            }
            offset += size
        }
        return data
    }
}

final class AirPlayAudioEncoder {
    enum Kind {
        case aac, alac
    }

    private final class Feed {
        var samples: [Float] = []
        var offset = 0
        var channels = 0
        var scratch = [Float]()
    }

    let kind: Kind
    let channels: Int
    let sampleRate: Double
    let frames: Int
    let format: CMAudioFormatDescription
    private var converter: AudioConverterRef?
    private let feed = Feed()
    private let bytes: Int
    private static let ended: OSStatus = 1

    static func layout(_ channels: Int) -> AudioChannelLayoutTag {
        switch channels {
        case 1: kAudioChannelLayoutTag_Mono
        case 2: kAudioChannelLayoutTag_Stereo
        case 3: kAudioChannelLayoutTag_MPEG_3_0_A
        case 4: kAudioChannelLayoutTag_MPEG_4_0_A
        case 5: kAudioChannelLayoutTag_MPEG_5_0_A
        default: kAudioChannelLayoutTag_MPEG_5_1_A
        }
    }

    init?(_ kind: Kind, sampleRate: Double, channels: Int, bits: Int = 16) {
        guard channels >= 1, channels <= 6, sampleRate >= 8000, kind == .alac || sampleRate <= 48000 else { return nil }
        self.kind = kind
        self.channels = channels
        self.sampleRate = sampleRate
        frames = kind == .aac ? 1024 : 4096
        bytes = 4 * channels
        var input = AudioStreamBasicDescription(mSampleRate: sampleRate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagsNativeFloatPacked, mBytesPerPacket: UInt32(4 * channels),
                                                mFramesPerPacket: 1, mBytesPerFrame: UInt32(4 * channels), mChannelsPerFrame: UInt32(channels), mBitsPerChannel: 32, mReserved: 0)
        var output = AudioStreamBasicDescription(mSampleRate: sampleRate, mFormatID: kind == .aac ? kAudioFormatMPEG4AAC : kAudioFormatAppleLossless,
                                                 mFormatFlags: kind == .aac ? UInt32(MPEG4ObjectID.AAC_LC.rawValue) : bits > 16 ? 4 : 1, mBytesPerPacket: 0,
                                                 mFramesPerPacket: UInt32(frames), mBytesPerFrame: 0, mChannelsPerFrame: UInt32(channels), mBitsPerChannel: 0, mReserved: 0)
        var made: AudioConverterRef?
        guard AudioConverterNew(&input, &output, &made) == noErr, let made else { return nil }
        converter = made
        var tag = Self.layout(channels)
        var layout = AudioChannelLayout(mChannelLayoutTag: tag, mChannelBitmap: [], mNumberChannelDescriptions: 0, mChannelDescriptions: AudioChannelDescription())
        let size = UInt32(MemoryLayout<AudioChannelLayout>.size)
        AudioConverterSetProperty(made, kAudioConverterInputChannelLayout, size, &layout)
        AudioConverterSetProperty(made, kAudioConverterOutputChannelLayout, size, &layout)
        if kind == .aac {
            var rate = UInt32(channels == 1 ? 96000 : channels == 2 ? 160_000 : channels * 64000)
            AudioConverterSetProperty(made, kAudioConverterEncodeBitRate, 4, &rate)
        }
        var cookieSize: UInt32 = 0
        AudioConverterGetPropertyInfo(made, kAudioConverterCompressionMagicCookie, &cookieSize, nil)
        var cookie = [UInt8](repeating: 0, count: Int(cookieSize))
        if cookieSize > 0 { AudioConverterGetProperty(made, kAudioConverterCompressionMagicCookie, &cookieSize, &cookie) }
        var description: CMAudioFormatDescription?
        tag = Self.layout(channels)
        let status = withUnsafePointer(to: &layout) { layout in
            CMAudioFormatDescriptionCreate(allocator: nil, asbd: &output, layoutSize: MemoryLayout<AudioChannelLayout>.size, layout: layout, magicCookieSize: cookie.count,
                                           magicCookie: cookie.isEmpty ? nil : cookie, extensions: nil, formatDescriptionOut: &description)
        }
        guard status == noErr, let description else {
            AudioConverterDispose(made)
            return nil
        }
        format = description
        feed.channels = channels
    }

    deinit {
        if let converter { AudioConverterDispose(converter) }
    }

    func encode(_ pcm: [Float]) -> [Data] {
        guard let converter else { return [] }
        feed.samples.removeFirst(feed.offset)
        feed.offset = 0
        feed.samples.append(contentsOf: pcm)
        var packets: [Data] = []
        let input: AudioConverterComplexInputDataProc = { _, count, data, _, user in
            let feed = Unmanaged<Feed>.fromOpaque(user!).takeUnretainedValue()
            let available = (feed.samples.count - feed.offset) / feed.channels
            let wanted = min(Int(count.pointee), available)
            guard wanted > 0 else {
                count.pointee = 0
                return AirPlayAudioEncoder.ended
            }
            feed.scratch = Array(feed.samples[feed.offset..<feed.offset + wanted * feed.channels])
            feed.offset += wanted * feed.channels
            count.pointee = UInt32(wanted)
            feed.scratch.withUnsafeMutableBytes { raw in
                data.pointee.mNumberBuffers = 1
                data.pointee.mBuffers.mNumberChannels = UInt32(feed.channels)
                data.pointee.mBuffers.mDataByteSize = UInt32(raw.count)
                data.pointee.mBuffers.mData = raw.baseAddress
            }
            return noErr
        }
        var out = [UInt8](repeating: 0, count: 16384)
        while true {
            var count: UInt32 = 1
            var description = AudioStreamPacketDescription()
            var size = UInt32(out.count)
            let status = out.withUnsafeMutableBytes { raw -> OSStatus in
                var list = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: UInt32(channels), mDataByteSize: size, mData: raw.baseAddress))
                let status = AudioConverterFillComplexBuffer(converter, input, Unmanaged.passUnretained(feed).toOpaque(), &count, &list, &description)
                size = list.mBuffers.mDataByteSize
                return status
            }
            if count == 1, size > 0 { packets.append(Data(out[Int(description.mStartOffset)..<Int(description.mStartOffset) + Int(description.mDataByteSize)])) }
            if count == 0 || (status != noErr && status != Self.ended) { break }
        }
        return packets
    }

    func sample(_ packets: [Data], start: CMTime) -> CMSampleBuffer? {
        guard !packets.isEmpty else { return nil }
        let total = packets.reduce(0) { $0 + $1.count }
        var block: CMBlockBuffer?
        guard CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: total, blockAllocator: nil, customBlockSource: nil, offsetToData: 0, dataLength: total,
                                                 flags: kCMBlockBufferAssureMemoryNowFlag, blockBufferOut: &block) == noErr, let block else { return nil }
        var offset = 0
        var descriptions: [AudioStreamPacketDescription] = []
        for packet in packets {
            _ = packet.withUnsafeBytes { CMBlockBufferReplaceDataBytes(with: $0.baseAddress!, blockBuffer: block, offsetIntoDestination: offset, dataLength: packet.count) }
            descriptions.append(AudioStreamPacketDescription(mStartOffset: Int64(offset), mVariableFramesInPacket: 0, mDataByteSize: UInt32(packet.count)))
            offset += packet.count
        }
        var buffer: CMSampleBuffer?
        let status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(allocator: nil, dataBuffer: block, formatDescription: format, sampleCount: packets.count, presentationTimeStamp: start,
                                                                          packetDescriptions: &descriptions, sampleBufferOut: &buffer)
        return status == noErr ? buffer : nil
    }
}

final class AirPlayAudioDecoder {
    private final class Feed {
        let storage = UnsafeMutableRawPointer.allocate(byteCount: 1 << 20, alignment: 16)
        let description = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: 1)
        var size = 0
        var packets: UInt32 = 0
        var bytesPerPacket = 0

        deinit {
            storage.deallocate()
            description.deallocate()
        }
    }

    let channels: Int
    let sampleRate: Double
    private var converter: AudioConverterRef?
    private let feed = Feed()
    private static let ended: OSStatus = 1

    init?(_ format: CMAudioFormatDescription) {
        guard var input = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee, input.mChannelsPerFrame > 0, input.mChannelsPerFrame <= 8 else { return nil }
        channels = Int(input.mChannelsPerFrame)
        sampleRate = input.mSampleRate
        feed.bytesPerPacket = Int(input.mBytesPerPacket)
        let plain = input.mFormatID == kAudioFormatLinearPCM && input.mFormatFlags & kAudioFormatFlagIsFloat != 0 && input.mBitsPerChannel == 32 && input.mFormatFlags & kAudioFormatFlagIsBigEndian == 0
        guard !plain else { return }
        var output = AudioStreamBasicDescription(mSampleRate: input.mSampleRate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagsNativeFloatPacked, mBytesPerPacket: UInt32(4 * channels),
                                                 mFramesPerPacket: 1, mBytesPerFrame: UInt32(4 * channels), mChannelsPerFrame: UInt32(channels), mBitsPerChannel: 32, mReserved: 0)
        var made: AudioConverterRef?
        guard AudioConverterNew(&input, &output, &made) == noErr, let made else { return nil }
        var size = 0
        if let cookie = CMAudioFormatDescriptionGetMagicCookie(format, sizeOut: &size), size > 0,
           AudioConverterSetProperty(made, kAudioConverterDecompressionMagicCookie, UInt32(size), cookie) != noErr {
            AudioConverterDispose(made)
            return nil
        }
        converter = made
    }

    deinit {
        if let converter { AudioConverterDispose(converter) }
    }

    func reset() {
        if let converter { AudioConverterReset(converter) }
    }

    func decode(_ data: Data) -> [Float] {
        guard let converter else { return data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) } }
        guard !data.isEmpty, data.count <= 1 << 20 else { return [] }
        data.withUnsafeBytes { feed.storage.copyMemory(from: $0.baseAddress!, byteCount: data.count) }
        feed.size = data.count
        feed.packets = feed.bytesPerPacket > 0 ? UInt32(data.count / feed.bytesPerPacket) : 1
        feed.description.pointee = AudioStreamPacketDescription(mStartOffset: 0, mVariableFramesInPacket: 0, mDataByteSize: UInt32(data.count))
        let input: AudioConverterComplexInputDataProc = { _, count, data, description, user in
            let feed = Unmanaged<Feed>.fromOpaque(user!).takeUnretainedValue()
            guard feed.packets > 0 else {
                count.pointee = 0
                return AirPlayAudioDecoder.ended
            }
            count.pointee = feed.packets
            feed.packets = 0
            data.pointee.mNumberBuffers = 1
            data.pointee.mBuffers.mNumberChannels = 1
            data.pointee.mBuffers.mDataByteSize = UInt32(feed.size)
            data.pointee.mBuffers.mData = feed.storage
            if feed.bytesPerPacket == 0 { description?.pointee = feed.description }
            return noErr
        }
        var out: [Float] = []
        var buffer = [Float](repeating: 0, count: 16384 * channels)
        while true {
            var frames: UInt32 = 16384
            let status = buffer.withUnsafeMutableBytes { raw -> OSStatus in
                var list = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: UInt32(channels), mDataByteSize: UInt32(raw.count), mData: raw.baseAddress))
                return AudioConverterFillComplexBuffer(converter, input, Unmanaged.passUnretained(feed).toOpaque(), &frames, &list, nil)
            }
            if frames > 0 { out.append(contentsOf: buffer[0..<Int(frames) * channels]) }
            if frames == 0 || (status != noErr && status != Self.ended) { break }
        }
        return out
    }
}

enum AirPlayAudioGrid {
    static let lead = 2
    static let warmup = 4

    static func packets(for time: Double, rate: Double, frames: Int) -> Int {
        Int((time * rate / Double(frames)).rounded(.up))
    }

    static func range(of segment: AirPlaySegment, rate: Double, frames: Int, lead: Int, last: Bool, total: Double) -> Range<Int> {
        let first = packets(for: segment.start, rate: rate, frames: frames) + lead
        let end = last ? packets(for: total, rate: rate, frames: frames) + lead : packets(for: segment.end, rate: rate, frames: frames) + lead
        return first..<max(first, end)
    }

    static func time(ofPacket index: Int, rate: Double, frames: Int, lead: Int) -> CMTime {
        CMTime(value: CMTimeValue((index - lead) * frames), timescale: CMTimeScale(rate))
    }

    static func encode(_ range: Range<Int>, with encoder: AirPlayAudioEncoder, lead: Int, warmup: Int, pcm: (Int, Int) -> [Float]) -> [Data] {
        let first = max(0, range.lowerBound - warmup)
        var packets: [Data] = []
        var frame = first * encoder.frames
        let chunk = 4 * encoder.frames
        while first + packets.count < range.upperBound, frame < (range.upperBound + 8) * encoder.frames {
            packets += encoder.encode(pcm(frame, chunk))
            frame += chunk
        }
        let skip = range.lowerBound - first
        return Array(packets.dropFirst(skip).prefix(range.count))
    }
}
