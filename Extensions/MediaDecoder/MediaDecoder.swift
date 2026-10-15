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
        let atoms = CMFormatDescriptionGetExtension(description, extensionKey: kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms) as? [String: Data]
        guard let atom = atoms?[PikaCodec.atom], atom.count >= 5,
              let id = PikaCodec.video.first(where: { PikaCodec.fourCC($0.1) == codecType })?.0,
              let codec = id == AV_CODEC_ID_AV1 ? avcodec_find_decoder_by_name("libdav1d") : avcodec_find_decoder(id),
              let context = avcodec_alloc_context3(codec) else { throw MEError(.unsupportedFeature) }
        let bytes = [UInt8](atom)
        presentationOrder = bytes[4] != 0
        let dimensions = CMVideoFormatDescriptionGetDimensions(description)
        context.pointee.codec_tag = bytes[0..<4].reduce(0) { $0 << 8 | UInt32($1) }
        context.pointee.width = dimensions.width
        context.pointee.height = dimensions.height
        context.pointee.thread_count = 0
        context.pointee.thread_type = FF_THREAD_SLICE
        if !presentationOrder { context.pointee.flags |= AV_CODEC_FLAG_LOW_DELAY }
        let extradata = bytes[5...]
        if !extradata.isEmpty, let buffer = av_mallocz(extradata.count + Int(AV_INPUT_BUFFER_PADDING_SIZE))?.assumingMemoryBound(to: UInt8.self) {
            buffer.update(from: Array(extradata), count: extradata.count)
            context.pointee.extradata = buffer
            context.pointee.extradata_size = Int32(extradata.count)
        }
        var options: OpaquePointer?
        av_dict_set(&options, "max_frame_delay", "1", 0)
        let opened = avcodec_open2(context, codec, &options)
        av_dict_free(&options)
        self.context = context
        super.init()
        guard opened >= 0 else { throw MEError(.unsupportedFeature) }
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
            guard let data = Self.bytes(sampleBuffer) else { return completionHandler(nil, [], MEError(.invalidParameter)) }
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
        let format = AVPixelFormat(frame.pointee.format)
        guard let descriptor = av_pix_fmt_desc_get(format)?.pointee, descriptor.nb_components >= 3,
              descriptor.flags & UInt64(AV_PIX_FMT_FLAG_RGB | AV_PIX_FMT_FLAG_PAL) == 0, descriptor.flags & UInt64(AV_PIX_FMT_FLAG_PLANAR) != 0 else {
            throw MEError(.unsupportedFeature)
        }
        let depth = Int(descriptor.comp.0.depth)
        let full = frame.pointee.color_range == AVCOL_RANGE_JPEG || [AV_PIX_FMT_YUVJ420P, AV_PIX_FMT_YUVJ422P, AV_PIX_FMT_YUVJ444P].contains(format)
        let type: OSType
        switch (descriptor.log2_chroma_w, descriptor.log2_chroma_h, depth > 8) {
        case (1, 1, false): type = full ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        case (1, 1, true): type = full ? kCVPixelFormatType_420YpCbCr10BiPlanarFullRange : kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
        case (1, 0, false): type = full ? kCVPixelFormatType_422YpCbCr8BiPlanarFullRange : kCVPixelFormatType_422YpCbCr8BiPlanarVideoRange
        case (1, 0, true): type = full ? kCVPixelFormatType_422YpCbCr10BiPlanarFullRange : kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange
        case (0, 0, false): type = full ? kCVPixelFormatType_444YpCbCr8BiPlanarFullRange : kCVPixelFormatType_444YpCbCr8BiPlanarVideoRange
        case (0, 0, true): type = full ? kCVPixelFormatType_444YpCbCr10BiPlanarFullRange : kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange
        default: throw MEError(.unsupportedFeature)
        }
        let width = frame.pointee.width, height = frame.pointee.height
        if layout.map({ $0 != (type, width, height) }) ?? true {
            manager.pixelBufferAttributes = [
                kCVPixelBufferPixelFormatTypeKey as String: type,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferIOSurfacePropertiesKey as String: [String: String](),
            ]
            layout = (type, width, height)
        }
        let buffer = try manager.makePixelBuffer()
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        let chromaWidth = (Int(width) + (1 << descriptor.log2_chroma_w) - 1) >> descriptor.log2_chroma_w
        let chromaHeight = (Int(height) + (1 << descriptor.log2_chroma_h) - 1) >> descriptor.log2_chroma_h
        let source = (frame.pointee.data.0!, frame.pointee.data.1!, frame.pointee.data.2!)
        let stride = (Int(frame.pointee.linesize.0), Int(frame.pointee.linesize.1), Int(frame.pointee.linesize.2))
        let luma = CVPixelBufferGetBaseAddressOfPlane(buffer, 0)!.assumingMemoryBound(to: UInt8.self)
        let chroma = CVPixelBufferGetBaseAddressOfPlane(buffer, 1)!.assumingMemoryBound(to: UInt8.self)
        let lumaStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 0)
        let chromaStride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 1)
        if depth == 8 {
            for y in 0..<Int(height) { (luma + y * lumaStride).update(from: source.0 + y * stride.0, count: Int(width)) }
            for y in 0..<chromaHeight {
                let u = source.1 + y * stride.1, v = source.2 + y * stride.2, out = chroma + y * chromaStride
                for x in 0..<chromaWidth {
                    out[2 * x] = u[x]
                    out[2 * x + 1] = v[x]
                }
            }
        } else {
            let shift = UInt16(16 - depth)
            for y in 0..<Int(height) {
                let row = UnsafeRawPointer(source.0 + y * stride.0).assumingMemoryBound(to: UInt16.self)
                let out = UnsafeMutableRawPointer(luma + y * lumaStride).assumingMemoryBound(to: UInt16.self)
                for x in 0..<Int(width) { out[x] = row[x] << shift }
            }
            for y in 0..<chromaHeight {
                let u = UnsafeRawPointer(source.1 + y * stride.1).assumingMemoryBound(to: UInt16.self)
                let v = UnsafeRawPointer(source.2 + y * stride.2).assumingMemoryBound(to: UInt16.self)
                let out = UnsafeMutableRawPointer(chroma + y * chromaStride).assumingMemoryBound(to: UInt16.self)
                for x in 0..<chromaWidth {
                    out[2 * x] = u[x] << shift
                    out[2 * x + 1] = v[x] << shift
                }
            }
        }
        let colors = colorAttachments(primaries: frame.pointee.color_primaries, transfer: frame.pointee.color_trc, matrix: frame.pointee.colorspace, height: height)
        CVBufferSetAttachments(buffer, colors as CFDictionary, .shouldPropagate)
        return buffer
    }
}
