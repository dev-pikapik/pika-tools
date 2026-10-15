import AVFoundation
import CoreMedia
import MediaExtension

@objc(PikaMediaReaderFactory)
final class MediaReaderFactory: NSObject, MEFormatReaderExtension {
    func formatReader(with primaryByteSource: MEByteSource, options: MEFormatReaderInstantiationOptions?) throws -> any MEFormatReader {
        try MediaReader(primaryByteSource)
    }
}

final class MediaReader: NSObject, MEFormatReader {
    let demuxer: Demuxer

    init(_ source: MEByteSource) throws {
        demuxer = try Demuxer(name: source.fileName, size: source.fileLength) { buffer, size, offset in
            PikaReadByteSource(source, buffer, size, offset)
        }
    }

    init(_ demuxer: Demuxer) {
        self.demuxer = demuxer
    }

    func loadFileInfo(completionHandler: @escaping @Sendable (MEFileInfo?, (any Error)?) -> Void) {
        let info = MEFileInfo()
        if demuxer.duration.isValid {
            info.duration = demuxer.duration
        } else if let stream = demuxer.tracks.first, let last = try? demuxer.last(stream) {
            info.duration = stream.time(last.pts + last.duration)
        }
        completionHandler(info, nil)
    }

    func loadMetadata(completionHandler: @escaping @Sendable ([AVMetadataItem]?, (any Error)?) -> Void) {
        completionHandler([], nil)
    }

    func loadTrackReaders(completionHandler: @escaping @Sendable ([any METrackReader]?, (any Error)?) -> Void) {
        completionHandler(demuxer.tracks.map { TrackReader(demuxer, $0) }, nil)
    }
}

final class TrackReader: NSObject, METrackReader {
    let demuxer: Demuxer
    let stream: Track

    init(_ demuxer: Demuxer, _ stream: Track) {
        self.demuxer = demuxer
        self.stream = stream
    }

    func loadTrackInfo(completionHandler: @escaping @Sendable (METrackInfo?, (any Error)?) -> Void) {
        let info = METrackInfo(__mediaType: stream.format.mediaType, trackID: CMPersistentTrackID(stream.index + 1), formatDescriptions: [stream.format.description])
        info.isEnabled = stream.enabled
        info.naturalTimescale = stream.timeBase.den
        if stream.format.mediaType == kCMMediaType_Video {
            info.naturalSize = stream.size
            info.nominalFrameRate = stream.frameRate
            info.requiresFrameReordering = stream.reorders
        }
        completionHandler(info, nil)
    }

    func generateSampleCursor(atPresentationTimeStamp presentationTimeStamp: CMTime, completionHandler: @escaping @Sendable ((any MESampleCursor)?, (any Error)?) -> Void) {
        cursor(completionHandler) { try demuxer.locate(stream, stream.ticks(presentationTimeStamp)) }
    }

    func generateSampleCursorAtFirstSampleInDecodeOrder(completionHandler: @escaping @Sendable ((any MESampleCursor)?, (any Error)?) -> Void) {
        cursor(completionHandler) { demuxer.first(stream) }
    }

    func generateSampleCursorAtLastSampleInDecodeOrder(completionHandler: @escaping @Sendable ((any MESampleCursor)?, (any Error)?) -> Void) {
        cursor(completionHandler) { try demuxer.last(stream) }
    }

    private func cursor(_ completionHandler: @Sendable ((any MESampleCursor)?, (any Error)?) -> Void, _ find: () throws -> Packet?) {
        do {
            guard let packet = try find() else { throw MEError(.noSamples) }
            completionHandler(SampleCursor(demuxer, stream, packet), nil)
        } catch {
            completionHandler(nil, error)
        }
    }
}

final class SampleCursor: NSObject, MESampleCursor {
    let demuxer: Demuxer
    let stream: Track
    private(set) var packet: Packet

    init(_ demuxer: Demuxer, _ stream: Track, _ packet: Packet) {
        self.demuxer = demuxer
        self.stream = stream
        self.packet = packet
    }

    func copy(with zone: NSZone? = nil) -> Any {
        SampleCursor(demuxer, stream, packet)
    }

    var presentationTimeStamp: CMTime { stream.time(packet.pts) }
    var decodeTimeStamp: CMTime { stream.time(packet.dts) }
    var currentSampleDuration: CMTime { stream.time(packet.duration) }
    var currentSampleFormatDescription: CMFormatDescription? { stream.format.description }
    var syncInfo: AVSampleCursorSyncInfo {
        AVSampleCursorSyncInfo(sampleIsFullSync: ObjCBool(packet.sync && !packet.open), sampleIsPartialSync: ObjCBool(packet.sync && packet.open), sampleIsDroppable: false)
    }

    func samplesWithEarlierDTSsMayHaveLaterPTSs(than cursor: any MESampleCursor) -> Bool { stream.reorders }
    func samplesWithLaterDTSsMayHaveEarlierPTSs(than cursor: any MESampleCursor) -> Bool { stream.reorders }

    func stepInDecodeOrder(by stepCount: Int64, completionHandler: @escaping @Sendable (Int64, (any Error)?) -> Void) {
        do {
            completionHandler(try step(stepCount) { try $0 > 0 ? demuxer.next($1, stream) : demuxer.previous($1, stream) }, nil)
        } catch {
            completionHandler(0, error)
        }
    }

    func stepInPresentationOrder(by stepCount: Int64, completionHandler: @escaping @Sendable (Int64, (any Error)?) -> Void) {
        do {
            completionHandler(try step(stepCount) { try stream.reorders ? neighbour($1, forward: $0 > 0) : $0 > 0 ? demuxer.next($1, stream) : demuxer.previous($1, stream) }, nil)
        } catch {
            completionHandler(0, error)
        }
    }

    func stepByDecodeTime(_ deltaDecodeTime: CMTime, completionHandler: @escaping @Sendable (CMTime, Bool, (any Error)?) -> Void) {
        do {
            let target = packet.dts + stream.ticks(deltaDecodeTime)
            var pinned = false
            if abs(target - packet.dts) > stream.ticks(CMTime(value: 5, timescale: 1)), let found = try demuxer.locate(stream, target) { packet = found }
            while packet.dts > target {
                guard let previous = try demuxer.previous(packet, stream) else { pinned = true; break }
                packet = previous
            }
            while let next = try demuxer.next(packet, stream), next.dts <= target { packet = next }
            if target >= packet.dts + packet.duration, try demuxer.next(packet, stream) == nil { pinned = true }
            completionHandler(decodeTimeStamp, pinned, nil)
        } catch {
            completionHandler(decodeTimeStamp, false, error)
        }
    }

    func stepByPresentationTime(_ deltaPresentationTime: CMTime, completionHandler: @escaping @Sendable (CMTime, Bool, (any Error)?) -> Void) {
        do {
            let target = packet.pts + stream.ticks(deltaPresentationTime)
            guard let found = try demuxer.locate(stream, target) else { throw MEError(.noSamples) }
            packet = found
            let pinned = try target < packet.pts || (target >= packet.pts + packet.duration && demuxer.next(packet, stream) == nil)
            completionHandler(presentationTimeStamp, pinned, nil)
        } catch {
            completionHandler(presentationTimeStamp, false, error)
        }
    }

    func loadSampleBufferContainingSamples(to endSampleCursor: (any MESampleCursor)?, completionHandler: @escaping @Sendable (CMSampleBuffer?, (any Error)?) -> Void) {
        do {
            var packets = [packet]
            if let end = (endSampleCursor as? SampleCursor)?.packet, end !== packet {
                guard end.dts > packet.dts else { throw MEError(.noSamples) }
                while packets.count < 4096, let last = packets.last, last !== end, let next = try demuxer.next(last, stream) { packets.append(next) }
            }
            completionHandler(try makeSampleBuffer(packets), nil)
        } catch {
            completionHandler(nil, error)
        }
    }

    private func step(_ count: Int64, _ move: (Int64, Packet) throws -> Packet?) throws -> Int64 {
        var done: Int64 = 0
        while done < abs(count), let moved = try move(count, packet) {
            done += count > 0 ? packet.samples : moved.samples
            packet = moved
        }
        return count < 0 ? -done : done
    }

    private func neighbour(_ packet: Packet, forward: Bool) throws -> Packet? {
        var window: [Packet] = []
        var before = packet, after = packet
        for _ in 0..<16 {
            if let previous = try demuxer.previous(before, stream) { window.append(previous); before = previous }
            if let next = try demuxer.next(after, stream) { window.append(next); after = next }
        }
        return forward
            ? window.filter { $0.pts > packet.pts }.min { $0.pts < $1.pts }
            : window.filter { $0.pts < packet.pts }.max { $0.pts < $1.pts }
    }

    func makeSampleBuffer(_ packets: [Packet]) throws -> CMSampleBuffer {
        let parts = try packets.map { try demuxer.data($0, stream) }
        let total = parts.reduce(0) { $0 + $1.count }
        var block: CMBlockBuffer?
        guard total > 0, CMBlockBufferCreateWithMemoryBlock(allocator: nil, memoryBlock: nil, blockLength: total, blockAllocator: nil, customBlockSource: nil,
                                                            offsetToData: 0, dataLength: total, flags: kCMBlockBufferAssureMemoryNowFlag, blockBufferOut: &block) == noErr,
              let block else { throw MEError(.allocationFailure) }
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
            guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(description)?.pointee else { throw MEError(.internalFailure) }
            if asbd.mFormatID == kAudioFormatLinearPCM {
                status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(allocator: nil, dataBuffer: block, formatDescription: description,
                                                                              sampleCount: total / Int(asbd.mBytesPerFrame), presentationTimeStamp: presentationTimeStamp, packetDescriptions: nil, sampleBufferOut: &buffer)
            } else {
                var start: Int64 = 0
                var descriptions: [AudioStreamPacketDescription] = []
                for (packet, part) in zip(packets, parts) {
                    let frames = asbd.mFramesPerPacket == 0 ? UInt32(max(0, av_rescale_q(packet.duration, stream.timeBase, AVRational(num: 1, den: Int32(asbd.mSampleRate))))) : 0
                    descriptions.append(AudioStreamPacketDescription(mStartOffset: start, mVariableFramesInPacket: frames, mDataByteSize: UInt32(part.count)))
                    start += Int64(part.count)
                }
                status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(allocator: nil, dataBuffer: block, formatDescription: description,
                                                                              sampleCount: packets.count, presentationTimeStamp: presentationTimeStamp, packetDescriptions: &descriptions, sampleBufferOut: &buffer)
            }
        }
        guard status == noErr, let buffer else { throw MEError(.internalFailure) }
        return buffer
    }
}
