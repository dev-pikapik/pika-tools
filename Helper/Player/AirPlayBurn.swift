import CoreGraphics
import CoreMedia
import Foundation
import VideoToolbox

final class AirPlayPictures {
    struct Image {
        let image: CGImage
        let frame: CGRect
    }

    struct Event {
        var start: Double
        var end: Double
        var images: [Image]
    }

    static let lookback = 30.0
    let canvas: CGSize
    private let parameters: UnsafeMutablePointer<AVCodecParameters>
    private let packets: [AirPlayRawPacket]

    init(parameters: UnsafeMutablePointer<AVCodecParameters>, packets: [AirPlayRawPacket], fallback: CGSize) {
        self.parameters = parameters
        self.packets = packets
        let size = CGSize(width: Int(parameters.pointee.width), height: Int(parameters.pointee.height))
        canvas = size.width > 0 && size.height > 0 ? size : fallback
    }

    func events(from lower: Double, to upper: Double) -> [Event] {
        guard let codec = avcodec_find_decoder(parameters.pointee.codec_id), let context = avcodec_alloc_context3(codec) else { return [] }
        var opened: UnsafeMutablePointer<AVCodecContext>? = context
        defer { avcodec_free_context(&opened) }
        var allocated = av_packet_alloc()
        defer { av_packet_free(&allocated) }
        guard avcodec_parameters_to_context(context, parameters) >= 0, avcodec_open2(context, codec, nil) >= 0, let packet = allocated else { return [] }
        var events: [Event] = []
        for raw in packets where raw.time >= lower - Self.lookback && raw.time < upper {
            guard av_new_packet(packet, Int32(raw.data.count)) >= 0 else { break }
            raw.data.withUnsafeBytes { packet.pointee.data.update(from: $0.bindMemory(to: UInt8.self).baseAddress!, count: raw.data.count) }
            var subtitle = AVSubtitle()
            var got: Int32 = 0
            let status = avcodec_decode_subtitle2(context, &subtitle, &got, packet)
            av_packet_unref(packet)
            guard status >= 0, got != 0 else { continue }
            defer { avsubtitle_free(&subtitle) }
            let start = raw.time + Double(subtitle.start_display_time) / 1000
            if var last = events.popLast() {
                last.end = min(last.end, start)
                events.append(last)
            }
            let end = subtitle.end_display_time > 0 && subtitle.end_display_time < 600_000 ? raw.time + Double(subtitle.end_display_time) / 1000 : start + 10
            let images = (0..<Int(subtitle.num_rects)).compactMap { subtitle.rects[$0].flatMap { Self.image($0.pointee) } }
            if !images.isEmpty { events.append(Event(start: start, end: end, images: images)) }
        }
        return events.filter { $0.end > lower && $0.start < upper && $0.end > $0.start }
    }

    private static func image(_ rect: AVSubtitleRect) -> Image? {
        let (width, height) = (Int(rect.w), Int(rect.h))
        guard rect.type == SUBTITLE_BITMAP, width > 0, height > 0, let indices = rect.data.0, let table = rect.data.1 else { return nil }
        let palette = UnsafeRawPointer(table).bindMemory(to: UInt32.self, capacity: 256)
        let colors = min(Int(rect.nb_colors), 256)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let index = Int(indices[y * Int(rect.linesize.0) + x])
                guard index < colors else { continue }
                let color = palette[index]
                let alpha = Int(color >> 24)
                let offset = (y * width + x) * 4
                pixels[offset] = UInt8(Int(color & 255) * alpha / 255)
                pixels[offset + 1] = UInt8(Int(color >> 8 & 255) * alpha / 255)
                pixels[offset + 2] = UInt8(Int(color >> 16 & 255) * alpha / 255)
                pixels[offset + 3] = UInt8(alpha)
            }
        }
        let made = pixels.withUnsafeMutableBytes { raw in
            CGContext(data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)?.makeImage()
        }
        return made.map { Image(image: $0, frame: CGRect(x: Int(rect.x), y: Int(rect.y), width: width, height: height)) }
    }
}

final class AirPlayBurner {
    private let canvas: CGSize
    private let events: [AirPlayPictures.Event]
    private var transfer: VTPixelTransferSession?
    private var pool: CVPixelBufferPool?
    private var layout: (Int, Int)?

    init(pictures: AirPlayPictures, from lower: Double, to upper: Double) {
        canvas = pictures.canvas
        events = pictures.events(from: lower, to: upper)
        VTPixelTransferSessionCreate(allocator: nil, pixelTransferSessionOut: &transfer)
    }

    deinit {
        if let transfer { VTPixelTransferSessionInvalidate(transfer) }
    }

    func apply(_ sample: CMSampleBuffer) -> CMSampleBuffer? {
        guard let source = CMSampleBufferGetImageBuffer(sample), let transfer else { return nil }
        let (width, height) = (CVPixelBufferGetWidth(source), CVPixelBufferGetHeight(source))
        if layout.map({ $0 != (width, height) }) ?? true {
            let attributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: width,
                                             kCVPixelBufferHeightKey as String: height, kCVPixelBufferIOSurfacePropertiesKey as String: [String: String]()]
            pool = nil
            CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary, &pool)
            layout = (width, height)
        }
        var target: CVPixelBuffer?
        guard let pool, CVPixelBufferPoolCreatePixelBuffer(nil, pool, &target) == kCVReturnSuccess, let target,
              VTPixelTransferSessionTransferImage(transfer, from: source, to: target) == noErr else { return nil }
        let time = CMSampleBufferGetPresentationTimeStamp(sample).seconds
        let active = events.filter { $0.start <= time && time < $0.end }
        if !active.isEmpty {
            CVPixelBufferLockBaseAddress(target, [])
            defer { CVPixelBufferUnlockBaseAddress(target, []) }
            if let context = CGContext(data: CVPixelBufferGetBaseAddress(target), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(target),
                                       space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) {
                let (sx, sy) = (CGFloat(width) / canvas.width, CGFloat(height) / canvas.height)
                for image in active.flatMap(\.images) {
                    let frame = image.frame
                    context.draw(image.image, in: CGRect(x: frame.minX * sx, y: CGFloat(height) - frame.maxY * sy, width: frame.width * sx, height: frame.height * sy))
                }
            }
        }
        var format: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: target, formatDescriptionOut: &format)
        var timing = CMSampleTimingInfo()
        CMSampleBufferGetSampleTimingInfo(sample, at: 0, timingInfoOut: &timing)
        var made: CMSampleBuffer?
        guard let format, CMSampleBufferCreateReadyWithImageBuffer(allocator: nil, imageBuffer: target, formatDescription: format, sampleTiming: &timing, sampleBufferOut: &made) == noErr else { return nil }
        return made
    }
}

final class AirPlayHardwareDecoder {
    private static let reorderDepth = 16
    private var session: VTDecompressionSession?
    private let lock = NSLock()
    private var frames: [CMSampleBuffer] = []

    init?(_ description: CMVideoFormatDescription) {
        let attributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
        guard VTDecompressionSessionCreate(allocator: nil, formatDescription: description, decoderSpecification: nil, imageBufferAttributes: attributes as CFDictionary,
                                           outputCallback: nil, decompressionSessionOut: &session) == noErr else { return nil }
    }

    deinit {
        if let session { VTDecompressionSessionInvalidate(session) }
    }

    func decode(_ sample: CMSampleBuffer) -> [CMSampleBuffer] {
        guard let session else { return [] }
        VTDecompressionSessionDecodeFrame(session, sampleBuffer: sample, flags: [._EnableTemporalProcessing], infoFlagsOut: nil) { [weak self] status, _, image, time, duration in
            guard status == noErr, let image, let self else { return }
            var format: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: image, formatDescriptionOut: &format)
            var timing = CMSampleTimingInfo(duration: duration, presentationTimeStamp: time, decodeTimeStamp: .invalid)
            var made: CMSampleBuffer?
            guard let format, CMSampleBufferCreateReadyWithImageBuffer(allocator: nil, imageBuffer: image, formatDescription: format, sampleTiming: &timing, sampleBufferOut: &made) == noErr, let made else { return }
            self.lock.withLock { self.frames.append(made) }
        }
        VTDecompressionSessionWaitForAsynchronousFrames(session)
        return take(keeping: Self.reorderDepth)
    }

    func finish() -> [CMSampleBuffer] {
        guard let session else { return [] }
        VTDecompressionSessionFinishDelayedFrames(session)
        VTDecompressionSessionWaitForAsynchronousFrames(session)
        return take(keeping: 0)
    }

    private func take(keeping depth: Int) -> [CMSampleBuffer] {
        lock.withLock {
            frames.sort { CMSampleBufferGetPresentationTimeStamp($0) < CMSampleBufferGetPresentationTimeStamp($1) }
            let ready = Array(frames.prefix(max(0, frames.count - depth)))
            frames.removeFirst(ready.count)
            return ready
        }
    }
}
