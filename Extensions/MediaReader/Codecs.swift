import CoreMedia
import CoreVideo

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
