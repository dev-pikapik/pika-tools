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
            guard let packet = try find() else { throw MediaError.noSamples }
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
            guard let found = try demuxer.locate(stream, target) else { throw MediaError.noSamples }
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
                guard end.dts > packet.dts else { throw MediaError.noSamples }
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
        try demuxer.sampleBuffer(packets, stream)
    }
}
