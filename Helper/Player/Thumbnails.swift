import AppKit
import AVFoundation
import VideoToolbox

private final class ThumbnailReader {
    private let file: Int32
    private let demuxer: Demuxer
    private let track: Track
    private let software: FrameDecoder?
    private var session: VTDecompressionSession?
    private let size: CGSize

    init(_ url: URL, _ size: CGSize) throws {
        self.size = size
        file = open(url.path, O_RDONLY)
        guard file >= 0 else { throw MediaError.invalidParameter }
        let fd = file
        do {
            demuxer = try Demuxer(name: url.lastPathComponent, size: lseek(fd, 0, SEEK_END), memoryLimit: 16 << 20) { buffer, count, offset in
                let read = pread(fd, buffer, Int(count), offset)
                return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
            }
            guard let track = demuxer.streams.first(where: { $0.enabled && $0.format.mediaType == kCMMediaType_Video }) else { throw MediaError.unsupportedFeature }
            self.track = track
            let codec = CMFormatDescriptionGetMediaSubType(track.format.description)
            software = PikaCodec.video.contains { PikaCodec.fourCC($0.1) == codec } ? try FrameDecoder(track.format.description) : nil
            if software == nil {
                guard VTDecompressionSessionCreate(allocator: nil, formatDescription: track.format.description, decoderSpecification: nil, imageBufferAttributes: nil, outputCallback: nil, decompressionSessionOut: &session) == noErr else { throw MediaError.unsupportedFeature }
            }
        } catch {
            close(fd)
            throw error
        }
        demuxer.discard(except: [track])
    }

    deinit {
        if let session { VTDecompressionSessionInvalidate(session) }
        close(file)
    }

    func image(at seconds: Double) -> CGImage? {
        autoreleasepool {
            guard var packet = (try? demuxer.locate(track, track.ticks(CMTime(seconds: seconds, preferredTimescale: 90000)))) ?? nil else { return nil }
            while !packet.sync, let previous = (try? demuxer.previous(packet, track)) ?? nil { packet = previous }
            defer { demuxer.forget(before: packet, track) }
            guard packet.sync, let buffer = decode(packet) else { return nil }
            var full: CGImage?
            VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &full)
            return full.flatMap(shrink)
        }
    }

    private func decode(_ packet: Packet) -> CVPixelBuffer? {
        if let software {
            guard let data = try? demuxer.data(packet, track) else { return nil }
            let samples = software.decode(data, pts: packet.pts, duration: packet.duration, track) + software.decode(nil, pts: 0, duration: 0, track)
            return samples.first.flatMap(CMSampleBufferGetImageBuffer)
        }
        guard let session, let sample = try? demuxer.sampleBuffer([packet], track) else { return nil }
        var result: CVPixelBuffer?
        let status = VTDecompressionSessionDecodeFrame(session, sampleBuffer: sample, flags: [], infoFlagsOut: nil) { status, _, buffer, _, _ in
            if status == noErr { result = buffer }
        }
        VTDecompressionSessionWaitForAsynchronousFrames(session)
        return status == noErr ? result : nil
    }

    private func shrink(_ image: CGImage) -> CGImage? {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
}

final class Thumbnails {
    private let url: URL
    private let duration: Double
    private let size: CGSize
    private let cache = NSCache<NSNumber, CGImage>()
    private let queue = DispatchQueue(label: "pikapik.thumbnails", qos: .utility)
    private let lock = NSLock()
    private var reader: ThumbnailReader?
    private var wanted: Int?
    private var cursor = 0
    private var running = false
    private var closed = false
    private var failed = false
    private var skipped = Set<Int>()
    var onReady: ((Int) -> Void)?

    init(url: URL, size: CGSize, duration: Double) {
        self.url = url
        self.size = PlayerThumbnail.size(for: size)
        self.duration = duration
        cache.countLimit = PlayerThumbnail.buckets
    }

    func close() {
        lock.withLock { closed = true }
        cache.removeAllObjects()
        onReady = nil
    }

    func image(for bucket: Int) -> CGImage? {
        let nearest = PlayerThumbnail.nearest(to: bucket) { cache.object(forKey: $0 as NSNumber) != nil }
        lock.withLock {
            guard !closed, !failed else { return }
            if nearest != bucket, !skipped.contains(bucket) { wanted = bucket }
            guard !running, wanted != nil || cursor < PlayerThumbnail.buckets else { return }
            running = true
            queue.async { [self] in work() }
        }
        return nearest.flatMap { cache.object(forKey: $0 as NSNumber) }
    }

    private func work() {
        while let bucket = take() {
            guard cache.object(forKey: bucket as NSNumber) == nil else { continue }
            if let image = reader?.image(at: PlayerThumbnail.time(of: bucket, duration: duration)) {
                cache.setObject(image, forKey: bucket as NSNumber)
                DispatchQueue.main.async { [weak self] in self?.onReady?(bucket) }
            } else {
                lock.withLock { _ = skipped.insert(bucket) }
            }
        }
    }

    private var stopped: Bool { lock.withLock { closed || failed } }

    private func take() -> Int? {
        if reader == nil, !stopped {
            do { reader = try ThumbnailReader(url, size) } catch { lock.withLock { failed = true } }
        }
        return lock.withLock {
            if let bucket = wanted, !closed, !failed {
                wanted = nil
                return bucket
            }
            while cursor < PlayerThumbnail.buckets, !closed, !failed {
                defer { cursor += 1 }
                if !skipped.contains(cursor) { return cursor }
            }
            running = false
            if closed || failed { reader = nil }
            return nil
        }
    }
}

final class ThumbnailPreview: NSView {
    private let picture = NSImageView()
    private let label = NSTextField(labelWithString: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        layer?.cornerRadius = 8
        picture.wantsLayer = true
        picture.layer?.cornerRadius = 4
        picture.layer?.masksToBounds = true
        picture.imageScaling = .scaleAxesIndependently
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        [picture, label].forEach { $0.setAccessibilityElement(false) }
        let stack = NSStackView(views: [label, picture])
        stack.orientation = .vertical
        stack.spacing = 4
        stack.edgeInsets = NSEdgeInsets(top: 5, left: 6, bottom: 6, right: 6)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func show(time: String, image: CGImage?) {
        label.stringValue = time
        picture.isHidden = image == nil
        guard let image else { return }
        picture.image = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
