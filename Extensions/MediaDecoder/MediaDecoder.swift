import CoreMedia
import CoreVideo
import MediaExtension

@objc(PikaMediaDecoderFactory)
final class MediaDecoderFactory: NSObject, MEVideoDecoderExtension {
    func makeVideoDecoder(codecType: CMVideoCodecType, videoFormatDescription: CMVideoFormatDescription, videoDecoderSpecifications: [String: Any],
                          pixelBufferManager: MEVideoDecoderPixelBufferManager) throws -> any MEVideoDecoder {
        try MediaDecoder(codecType, videoFormatDescription, pixelBufferManager)
    }
}

final class MediaDecoder: NSObject, MEVideoDecoder {
    typealias Completion = @Sendable (CVImageBuffer?, MEDecodeFrameStatus, (any Error)?) -> Void
    private struct Pending {
        let serial: Int64
        let output: Bool
        let completion: Completion
    }

    static let idleDrain = 0.15
    private let queue = DispatchQueue(label: "pikapik.mediadecoder")
    private let manager: MEVideoDecoderPixelBufferManager
    private let presentationOrder: Bool
    private var context: UnsafeMutablePointer<AVCodecContext>?
    private var packet = av_packet_alloc()
    private var frame = av_frame_alloc()
    private var pending: [Pending] = []
    private var serial: Int64 = 0
    private var sinceSync: [Data] = []
    private var drained = false
    private var drain: DispatchWorkItem?
    private var layout: (OSType, Int32, Int32)?

    init(_ codecType: CMVideoCodecType, _ description: CMVideoFormatDescription, _ manager: MEVideoDecoderPixelBufferManager) throws {
        self.manager = manager
        av_log_set_level(AV_LOG_QUIET)
        let (opened, order) = try openVideoCodec(codecType, description, lowDelay: true)
        context = opened
        presentationOrder = order
        super.init()
    }

    deinit {
        drain?.cancel()
        for item in pending { item.completion(nil, .frameDropped, nil) }
        avcodec_free_context(&context)
        av_packet_free(&packet)
        av_frame_free(&frame)
    }

    var isReadyForMoreMediaData: Bool { true }

    func decodeFrame(from sampleBuffer: CMSampleBuffer, options: MEDecodeFrameOptions, completionHandler: @escaping Completion) {
        queue.sync {
            drain?.cancel()
            drain = nil
            guard let data = Self.bytes(sampleBuffer) else { return completionHandler(nil, [], MediaError.invalidParameter) }
            let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[CFString: Any]]
            let sync = attachments?.first?[kCMSampleAttachmentKey_NotSync] as? Bool != true
            if sync { sinceSync = [] }
            if drained, !sync {
                for old in sinceSync { send(old, serial: -1) }
            }
            drained = false
            serial += 1
            pending.append(Pending(serial: serial, output: !options.doNotOutputFrame, completion: completionHandler))
            send(data, serial: serial)
            let delay = Int(context?.pointee.has_b_frames ?? 0)
            if delay > 0 { sinceSync.append(data) }
            finish(pending.count - delay)
            if !pending.isEmpty {
                let item = DispatchWorkItem { [weak self] in self?.flush() }
                drain = item
                queue.asyncAfter(deadline: .now() + Self.idleDrain, execute: item)
            }
        }
    }

    private func flush() {
        guard let context, !pending.isEmpty else { return }
        avcodec_send_packet(context, nil)
        receive()
        finish(pending.count)
        avcodec_flush_buffers(context)
        drained = true
    }

    private func finish(_ count: Int) {
        guard count > 0 else { return }
        for item in pending.prefix(count) { item.completion(nil, .frameDropped, nil) }
        pending.removeFirst(min(count, pending.count))
    }

    private func send(_ data: Data, serial: Int64) {
        guard let context, let packet, av_new_packet(packet, Int32(data.count)) >= 0 else { return }
        data.withUnsafeBytes { packet.pointee.data.update(from: $0.bindMemory(to: UInt8.self).baseAddress!, count: data.count) }
        packet.pointee.pts = serial
        packet.pointee.dts = serial
        var result = avcodec_send_packet(context, packet)
        if result == PikaErrorAgain {
            receive()
            result = avcodec_send_packet(context, packet)
        }
        av_packet_unref(packet)
        receive()
    }

    private func receive() {
        guard let context, let frame else { return }
        while avcodec_receive_frame(context, frame) >= 0 {
            defer { av_frame_unref(frame) }
            let serial = frame.pointee.pts
            guard serial != -1, let index = presentationOrder ? (pending.isEmpty ? nil : 0) : pending.firstIndex(where: { $0.serial == serial }) else { continue }
            let item = pending.remove(at: index)
            guard item.output else {
                item.completion(nil, [], nil)
                continue
            }
            do {
                item.completion(try image(frame), [], nil)
            } catch {
                item.completion(nil, [], error)
            }
        }
    }

    private static func bytes(_ sampleBuffer: CMSampleBuffer) -> Data? {
        guard let block = CMSampleBufferGetDataBuffer(sampleBuffer) else { return nil }
        let length = CMBlockBufferGetDataLength(block)
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: length, destination: $0.baseAddress!) }
        return status == noErr ? data : nil
    }

    private func image(_ frame: UnsafeMutablePointer<AVFrame>) throws -> CVPixelBuffer {
        try makePixelBuffer(frame) { type, width, height in
            if layout.map({ $0 != (type, width, height) }) ?? true {
                manager.pixelBufferAttributes = [
                    kCVPixelBufferPixelFormatTypeKey as String: type,
                    kCVPixelBufferWidthKey as String: width,
                    kCVPixelBufferHeightKey as String: height,
                    kCVPixelBufferIOSurfacePropertiesKey as String: [String: String](),
                ]
                layout = (type, width, height)
            }
            return try manager.makePixelBuffer()
        }
    }
}
