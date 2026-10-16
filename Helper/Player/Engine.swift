import AVFoundation
import CoreMedia
import VideoToolbox

final class FrameDecoder {
    private var context: UnsafeMutablePointer<AVCodecContext>?
    private let presentationOrder: Bool
    private var packet = av_packet_alloc()
    private var frame = av_frame_alloc()
    private var times: [(Int64, Int64)] = []
    private var pool: CVPixelBufferPool?
    private var layout: (OSType, Int32, Int32)?
    private var format: CMVideoFormatDescription?

    init(_ description: CMVideoFormatDescription) throws {
        (context, presentationOrder) = try openVideoCodec(CMFormatDescriptionGetMediaSubType(description), description, lowDelay: false)
    }

    deinit {
        avcodec_free_context(&context)
        av_packet_free(&packet)
        av_frame_free(&frame)
    }

    func flush() {
        avcodec_flush_buffers(context)
        times = []
    }

    func decode(_ data: Data?, pts: Int64, duration: Int64, _ track: Track) -> [CMSampleBuffer] {
        guard let context, let packet else { return [] }
        var output: [CMSampleBuffer] = []
        guard let data else {
            avcodec_send_packet(context, nil)
            receive(track, into: &output)
            flush()
            return output
        }
        guard !data.isEmpty, av_new_packet(packet, Int32(data.count)) >= 0 else { return [] }
        defer { av_packet_unref(packet) }
        data.withUnsafeBytes { packet.pointee.data.update(from: $0.bindMemory(to: UInt8.self).baseAddress!, count: data.count) }
        packet.pointee.pts = pts
        packet.pointee.duration = duration
        if presentationOrder { times.append((pts, duration)) }
        if avcodec_send_packet(context, packet) == PikaErrorAgain {
            receive(track, into: &output)
            avcodec_send_packet(context, packet)
        }
        receive(track, into: &output)
        return output
    }

    private func receive(_ track: Track, into output: inout [CMSampleBuffer]) {
        guard let context, let frame else { return }
        while avcodec_receive_frame(context, frame) >= 0 {
            defer { av_frame_unref(frame) }
            var (pts, duration) = (frame.pointee.best_effort_timestamp, frame.pointee.duration)
            if presentationOrder {
                guard !times.isEmpty else { continue }
                (pts, duration) = times.removeFirst()
            }
            guard pts != PikaNoTimestamp, let image = try? makePixelBuffer(frame, makeImage), let sample = sample(image, track.time(pts), track.time(max(duration, 0))) else { continue }
            output.append(sample)
        }
    }

    private func makeImage(_ type: OSType, _ width: Int32, _ height: Int32) throws -> CVPixelBuffer {
        if layout.map({ $0 != (type, width, height) }) ?? true {
            let attributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: type,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferIOSurfacePropertiesKey as String: [String: String](),
                kCVPixelBufferMetalCompatibilityKey as String: true,
            ]
            pool = nil
            CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary, &pool)
            layout = (type, width, height)
        }
        var image: CVPixelBuffer?
        guard let pool, CVPixelBufferPoolCreatePixelBuffer(nil, pool, &image) == kCVReturnSuccess, let image else { throw MediaError.allocationFailure }
        return image
    }

    private func sample(_ image: CVPixelBuffer, _ time: CMTime, _ duration: CMTime) -> CMSampleBuffer? {
        if format.map({ !CMVideoFormatDescriptionMatchesImageBuffer($0, imageBuffer: image) }) ?? true {
            format = nil
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: image, formatDescriptionOut: &format)
        }
        guard let format else { return nil }
        var timing = CMSampleTimingInfo(duration: duration, presentationTimeStamp: time, decodeTimeStamp: .invalid)
        var sample: CMSampleBuffer?
        CMSampleBufferCreateReadyWithImageBuffer(allocator: nil, imageBuffer: image, formatDescription: format, sampleTiming: &timing, sampleBufferOut: &sample)
        return sample
    }
}

final class Engine {
    private final class Feed {
        let track: Track
        let renderer: any AVQueuedSampleBufferRendering
        let decoder: FrameDecoder?
        var next: Packet?
        var hide = Int64.min
        var done = false

        init(_ track: Track, _ renderer: any AVQueuedSampleBufferRendering, _ decoder: FrameDecoder?) {
            self.track = track
            self.renderer = renderer
            self.decoder = decoder
        }
    }

    let synchronizer = AVSampleBufferRenderSynchronizer()
    let layer = AVSampleBufferDisplayLayer()
    let size: CGSize
    let duration: CMTime
    let audioTracks: [Track]
    let chapters: [Chapter]
    private let audio = AVSampleBufferAudioRenderer()
    private let demuxer: Demuxer
    private let file: Int32
    private let queue = DispatchQueue(label: "pikapik.player")
    private let lock = NSLock()
    private var chosenAudio: Track?
    private var feedList: [Feed] = []
    private var feeds: [Feed] {
        get { lock.withLock { feedList } }
        set { lock.withLock { feedList = newValue } }
    }
    private var wanted: (CMTime, Float)?
    private var requested: CMTime?
    private var steps = 0
    private var end = CMTime.zero
    private(set) var finished: CMTime?

    var volume: Float {
        get { audio.volume }
        set { audio.volume = newValue }
    }

    var muted: Bool {
        get { audio.isMuted }
        set { audio.isMuted = newValue }
    }

    var output: String? { audio.audioOutputDeviceUniqueID }

    func route(to uid: String) {
        audio.audioOutputDeviceUniqueID = uid
    }

    var hasAudio: Bool { feeds.contains { $0.renderer === audio } }

    var audioTrack: Track? { lock.withLock { chosenAudio } ?? feeds.first { $0.renderer === audio }?.track }

    var hasVideo: Bool { !size.equalTo(.zero) }

    var position: CMTime { lock.withLock { requested } ?? synchronizer.currentTime() }

    var failed: Bool {
        layer.sampleBufferRenderer.status == .failed && !hasAudio || audio.status == .failed && !feeds.contains { $0.renderer !== audio }
    }

    init(_ url: URL) throws {
        file = open(url.path, O_RDONLY)
        guard file >= 0 else { throw MediaError.invalidParameter }
        let fd = file
        do {
            demuxer = try Demuxer(name: url.lastPathComponent, size: lseek(fd, 0, SEEK_END), memoryLimit: 32 << 20) { buffer, count, offset in
                let read = pread(fd, buffer, Int(count), offset)
                return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
            }
        } catch {
            close(fd)
            throw error
        }
        let demuxer = demuxer
        var feeds: [Feed] = []
        var size = CGSize.zero
        for track in demuxer.streams where track.enabled {
            guard track.format.mediaType == kCMMediaType_Video else {
                if Self.decodable(track.format.description) { feeds.append(Feed(track, audio, nil)) }
                continue
            }
            let codec = CMFormatDescriptionGetMediaSubType(track.format.description)
            var decoder: FrameDecoder?
            if PikaCodec.video.contains(where: { PikaCodec.fourCC($0.1) == codec }) {
                guard let opened = try? FrameDecoder(track.format.description) else { continue }
                decoder = opened
            }
            feeds.append(Feed(track, layer.sampleBufferRenderer, decoder))
            size = track.size
        }
        feedList = feeds
        self.size = size
        audioTracks = demuxer.tracks.filter { $0.format.mediaType == kCMMediaType_Audio && Self.decodable($0.format.description) }
        demuxer.discard(except: feeds.map(\.track))
        duration = demuxer.duration.isValid ? demuxer.duration : feeds.compactMap { feed in
            ((try? demuxer.last(feed.track)) ?? nil).map { feed.track.time($0.pts + $0.duration) }
        }.max() ?? .zero
        chapters = demuxer.chapters()
        guard !feeds.isEmpty else {
            close(fd)
            throw MediaError.unsupportedFeature
        }
        layer.videoGravity = .resizeAspect
        audio.audioTimePitchAlgorithm = .spectral
        if !size.equalTo(.zero) { synchronizer.addRenderer(layer.sampleBufferRenderer) }
        if hasAudio { synchronizer.addRenderer(audio) }
    }

    private static func decodable(_ format: CMFormatDescription) -> Bool {
        guard var input = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee else { return false }
        guard input.mFormatID != kAudioFormatLinearPCM else { return true }
        var output = AudioStreamBasicDescription(mSampleRate: input.mSampleRate, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagsNativeFloatPacked,
                                                 mBytesPerPacket: 4 * input.mChannelsPerFrame, mFramesPerPacket: 1, mBytesPerFrame: 4 * input.mChannelsPerFrame,
                                                 mChannelsPerFrame: input.mChannelsPerFrame, mBitsPerChannel: 32, mReserved: 0)
        var converter: AudioConverterRef?
        guard AudioConverterNew(&input, &output, &converter) == noErr, let converter else { return false }
        defer { AudioConverterDispose(converter) }
        var size = 0
        guard let cookie = CMAudioFormatDescriptionGetMagicCookie(format, sizeOut: &size), size > 0 else { return true }
        return AudioConverterSetProperty(converter, kAudioConverterDecompressionMagicCookie, UInt32(size), cookie) == noErr
    }

    deinit {
        for feed in feeds { feed.renderer.stopRequestingMediaData() }
        close(file)
    }

    func stop() {
        lock.withLock { (wanted, requested) = (nil, nil) }
        synchronizer.rate = 0
        queue.sync {
            for feed in feeds {
                feed.renderer.stopRequestingMediaData()
                feed.renderer.flush()
            }
        }
    }

    func seek(to time: CMTime, rate: Float) {
        lock.withLock { (wanted, requested) = ((time, rate), time) }
        finished = nil
        queue.async { [weak self] in self?.restart() }
    }

    func step(_ direction: Int) {
        lock.withLock { steps += direction }
        finished = nil
        queue.async { [weak self] in self?.restartOnFrame() }
    }

    func selectAudio(_ track: Track) {
        guard audioTracks.contains(where: { $0 === track }) else { return }
        lock.withLock { chosenAudio = track }
        queue.async { [weak self] in self?.switchAudio(to: track) }
    }

    func tags() -> MediaTags { demuxer.tags() }

    func frameImage() -> CGImage? {
        guard #available(macOS 14.4, *), let buffer = layer.sampleBufferRenderer.displayedPixelBuffer() else { return nil }
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &image)
        return image
    }

    private func switchAudio(to track: Track) {
        guard audioTracks.contains(where: { $0 === track }), let old = feeds.first(where: { $0.renderer === audio }), old.track !== track else { return }
        let time = synchronizer.currentTime()
        audio.stopRequestingMediaData()
        audio.flush()
        demuxer.select(track, replacing: old.track)
        let feed = Feed(track, audio, nil)
        feed.next = (try? demuxer.locate(track, track.ticks(time))) ?? nil
        feeds = feeds.map { $0 === old ? feed : $0 }
        pump(feed)
        audio.requestMediaDataWhenReady(on: queue) { [weak self, weak feed] in
            if let self, let feed { self.pump(feed) }
        }
    }

    private func restartOnFrame() {
        let count = lock.withLock { defer { steps = 0 }; return steps }
        guard count != 0, let track = feeds.first(where: { $0.renderer === layer.sampleBufferRenderer })?.track else { return }
        let start = position
        var time = start
        for _ in 0..<abs(count) {
            guard let next = frame(count > 0 ? 1 : -1, from: time, track) else { break }
            time = next
        }
        guard time != start else { return }
        lock.withLock { (wanted, requested) = ((time, 0), time) }
        restart()
    }

    private func frame(_ direction: Int, from time: CMTime, _ track: Track) -> CMTime? {
        guard let current = (try? demuxer.locate(track, track.ticks(time))) ?? nil else { return nil }
        var times: [Int64] = []
        for move in [demuxer.next, demuxer.previous] {
            var neighbour = current
            for _ in 0..<16 {
                guard let following = (try? move(neighbour, track)) ?? nil else { break }
                neighbour = following
                times.append(following.pts)
            }
        }
        let found = direction > 0 ? times.filter { $0 > current.pts }.min() : times.filter { $0 < current.pts }.max()
        return found.map(track.time)
    }

    private func restart() {
        guard let (time, rate) = lock.withLock({ defer { wanted = nil }; return wanted }) else { return }
        synchronizer.rate = 0
        end = .zero
        for feed in feeds {
            feed.renderer.stopRequestingMediaData()
            feed.renderer.flush()
            feed.decoder?.flush()
            var packet = (try? demuxer.locate(feed.track, feed.track.ticks(time))) ?? nil
            feed.hide = packet?.pts ?? .min
            while let current = packet, !current.sync, let previous = (try? demuxer.previous(current, feed.track)) ?? nil { packet = previous }
            feed.next = packet
            feed.done = false
            pump(feed)
        }
        synchronizer.setRate(rate, time: time)
        lock.withLock { if wanted == nil { requested = nil } }
        for feed in feeds {
            feed.renderer.requestMediaDataWhenReady(on: queue) { [weak self, weak feed] in
                if let self, let feed { self.pump(feed) }
            }
        }
    }

    private func pump(_ feed: Feed) {
        while !feed.done, feed.renderer.isReadyForMoreMediaData {
            guard let packet = feed.next else {
                if let decoder = feed.decoder { send(decoder.decode(nil, pts: 0, duration: 0, feed.track), feed) }
                feed.done = true
                feed.renderer.stopRequestingMediaData()
                if feeds.allSatisfy(\.done) {
                    let end = end
                    DispatchQueue.main.async { self.finished = end }
                }
                return
            }
            feed.next = (try? demuxer.next(packet, feed.track)) ?? nil
            demuxer.forget(before: packet, feed.track)
            end = max(end, feed.track.time(packet.pts + packet.duration))
            if let decoder = feed.decoder {
                guard let data = try? demuxer.data(packet, feed.track) else { continue }
                send(decoder.decode(data, pts: packet.pts, duration: packet.duration, feed.track), feed)
            } else if let buffer = try? demuxer.sampleBuffer([packet], feed.track) {
                if packet.pts < feed.hide, feed.renderer !== audio, let attachments = CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: true) as? [NSMutableDictionary] {
                    attachments.first?[kCMSampleAttachmentKey_DoNotDisplay] = true
                }
                feed.renderer.enqueue(buffer)
            }
        }
    }

    private func send(_ samples: [CMSampleBuffer], _ feed: Feed) {
        let hide = feed.track.time(feed.hide)
        for sample in samples where feed.hide == .min || CMSampleBufferGetPresentationTimeStamp(sample) >= hide {
            feed.renderer.enqueue(sample)
        }
    }
}
