import CoreMedia
import CoreVideo
import Foundation

enum MediaError: Int, CustomNSError {
    case unsupportedFeature = -19320, allocationFailure, invalidParameter, parsingFailure, internalFailure
    case noSamples = -19327

    static let errorDomain = "MediaExtensionErrorDomain"
    var errorCode: Int { rawValue }
}

enum PikaCodec {
    static let atom = "pika"
    static let video: [(AVCodecID, String)] = [
        (AV_CODEC_ID_VP8, "Pvp8"), (AV_CODEC_ID_VP9, "Pvp9"), (AV_CODEC_ID_AV1, "Pav1"),
        (AV_CODEC_ID_MPEG1VIDEO, "Pmp1"), (AV_CODEC_ID_MPEG2VIDEO, "Pmp2"), (AV_CODEC_ID_MPEG4, "Pmp4"),
        (AV_CODEC_ID_MSMPEG4V1, "Pms1"), (AV_CODEC_ID_MSMPEG4V2, "Pms2"), (AV_CODEC_ID_MSMPEG4V3, "Pms3"),
        (AV_CODEC_ID_WMV1, "Pwm1"), (AV_CODEC_ID_WMV2, "Pwm2"), (AV_CODEC_ID_WMV3, "Pwm3"), (AV_CODEC_ID_VC1, "Pvc1"),
        (AV_CODEC_ID_THEORA, "Pthe"), (AV_CODEC_ID_FLV1, "Pflv"), (AV_CODEC_ID_H263, "P263"),
    ]

    static func fourCC(_ text: String) -> FourCharCode {
        text.utf8.reduce(0) { $0 << 8 | FourCharCode($1) }
    }
}

func colorAttachments(primaries: AVColorPrimaries, transfer: AVColorTransferCharacteristic, matrix: AVColorSpace, height: Int32) -> [CFString: CFString] {
    let hd = height > 576
    var result: [CFString: CFString] = [:]
    switch primaries {
    case AVCOL_PRI_BT709: result[kCVImageBufferColorPrimariesKey] = kCVImageBufferColorPrimaries_ITU_R_709_2
    case AVCOL_PRI_BT470BG: result[kCVImageBufferColorPrimariesKey] = kCVImageBufferColorPrimaries_EBU_3213
    case AVCOL_PRI_SMPTE170M, AVCOL_PRI_SMPTE240M: result[kCVImageBufferColorPrimariesKey] = kCVImageBufferColorPrimaries_SMPTE_C
    case AVCOL_PRI_BT2020: result[kCVImageBufferColorPrimariesKey] = kCVImageBufferColorPrimaries_ITU_R_2020
    default: result[kCVImageBufferColorPrimariesKey] = hd ? kCVImageBufferColorPrimaries_ITU_R_709_2 : kCVImageBufferColorPrimaries_SMPTE_C
    }
    switch transfer {
    case AVCOL_TRC_SMPTE2084: result[kCVImageBufferTransferFunctionKey] = kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ
    case AVCOL_TRC_ARIB_STD_B67: result[kCVImageBufferTransferFunctionKey] = kCVImageBufferTransferFunction_ITU_R_2100_HLG
    case AVCOL_TRC_BT2020_10, AVCOL_TRC_BT2020_12: result[kCVImageBufferTransferFunctionKey] = kCVImageBufferTransferFunction_ITU_R_2020
    default: result[kCVImageBufferTransferFunctionKey] = kCVImageBufferTransferFunction_ITU_R_709_2
    }
    switch matrix {
    case AVCOL_SPC_BT709: result[kCVImageBufferYCbCrMatrixKey] = kCVImageBufferYCbCrMatrix_ITU_R_709_2
    case AVCOL_SPC_BT470BG, AVCOL_SPC_SMPTE170M: result[kCVImageBufferYCbCrMatrixKey] = kCVImageBufferYCbCrMatrix_ITU_R_601_4
    case AVCOL_SPC_BT2020_NCL, AVCOL_SPC_BT2020_CL: result[kCVImageBufferYCbCrMatrixKey] = kCVImageBufferYCbCrMatrix_ITU_R_2020
    default: result[kCVImageBufferYCbCrMatrixKey] = hd ? kCVImageBufferYCbCrMatrix_ITU_R_709_2 : kCVImageBufferYCbCrMatrix_ITU_R_601_4
    }
    return result
}

func openVideoCodec(_ codecType: CMVideoCodecType, _ description: CMVideoFormatDescription, lowDelay: Bool) throws -> (UnsafeMutablePointer<AVCodecContext>, Bool) {
    let atoms = CMFormatDescriptionGetExtension(description, extensionKey: kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms) as? [String: Data]
    guard let atom = atoms?[PikaCodec.atom], atom.count >= 5,
          let id = PikaCodec.video.first(where: { PikaCodec.fourCC($0.1) == codecType })?.0,
          let codec = id == AV_CODEC_ID_AV1 ? avcodec_find_decoder_by_name("libdav1d") : avcodec_find_decoder(id),
          let context = avcodec_alloc_context3(codec) else { throw MediaError.unsupportedFeature }
    let bytes = [UInt8](atom)
    let presentationOrder = bytes[4] != 0
    let dimensions = CMVideoFormatDescriptionGetDimensions(description)
    context.pointee.codec_tag = bytes[0..<4].reduce(0) { $0 << 8 | UInt32($1) }
    context.pointee.width = dimensions.width
    context.pointee.height = dimensions.height
    context.pointee.thread_count = 0
    context.pointee.thread_type = lowDelay ? FF_THREAD_SLICE : FF_THREAD_FRAME | FF_THREAD_SLICE
    if lowDelay, !presentationOrder { context.pointee.flags |= AV_CODEC_FLAG_LOW_DELAY }
    let extradata = bytes[5...]
    if !extradata.isEmpty, let buffer = av_mallocz(extradata.count + Int(AV_INPUT_BUFFER_PADDING_SIZE))?.assumingMemoryBound(to: UInt8.self) {
        buffer.update(from: Array(extradata), count: extradata.count)
        context.pointee.extradata = buffer
        context.pointee.extradata_size = Int32(extradata.count)
    }
    var options: OpaquePointer?
    if lowDelay { av_dict_set(&options, "max_frame_delay", "1", 0) }
    let opened = avcodec_open2(context, codec, &options)
    av_dict_free(&options)
    guard opened >= 0 else {
        var failed: UnsafeMutablePointer<AVCodecContext>? = context
        avcodec_free_context(&failed)
        throw MediaError.unsupportedFeature
    }
    return (context, presentationOrder)
}

func makePixelBuffer(_ frame: UnsafeMutablePointer<AVFrame>, _ make: (OSType, Int32, Int32) throws -> CVPixelBuffer) throws -> CVPixelBuffer {
    let format = AVPixelFormat(frame.pointee.format)
    guard let descriptor = av_pix_fmt_desc_get(format)?.pointee, descriptor.nb_components >= 3,
          descriptor.flags & UInt64(AV_PIX_FMT_FLAG_RGB | AV_PIX_FMT_FLAG_PAL) == 0, descriptor.flags & UInt64(AV_PIX_FMT_FLAG_PLANAR) != 0 else {
        throw MediaError.unsupportedFeature
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
    default: throw MediaError.unsupportedFeature
    }
    let width = frame.pointee.width, height = frame.pointee.height
    let buffer = try make(type, width, height)
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
