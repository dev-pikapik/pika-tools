import AudioToolbox
import CoreMedia
import VideoToolbox

struct TrackFormat {
    let mediaType: CMMediaType
    let description: CMFormatDescription
    var convert: ((Data) -> Data)?
    var audioDecoder: AudioDecoder?
}

func makeTrackFormat(_ stream: UnsafeMutablePointer<AVStream>, decodeOrderTimes: Bool) -> TrackFormat? {
    let par = stream.pointee.codecpar.pointee
    let extradata = par.extradata.map { Data(bytes: $0, count: Int(par.extradata_size)) } ?? Data()
    switch par.codec_type {
    case AVMEDIA_TYPE_VIDEO: return makeVideoFormat(stream, par, extradata, decodeOrderTimes)
    case AVMEDIA_TYPE_AUDIO: return makeAudioFormat(par, extradata)
    default: return nil
    }
}

private func makeVideoFormat(_ stream: UnsafeMutablePointer<AVStream>, _ par: AVCodecParameters, _ extradata: Data, _ decodeOrderTimes: Bool) -> TrackFormat? {
    guard par.width > 0, par.height > 0 else { return nil }
    var extensions = videoExtensions(stream, par)
    var codec: FourCharCode
    var convert: ((Data) -> Data)?
    switch par.codec_id {
    case AV_CODEC_ID_H264, AV_CODEC_ID_HEVC:
        let hevc = par.codec_id == AV_CODEC_ID_HEVC
        if extradata.first == 1 {
            extensions[kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms] = [hevc ? "hvcC" : "avcC": extradata]
            codec = hevc ? kCMVideoCodecType_HEVC : kCMVideoCodecType_H264
        } else {
            let wanted: [UInt8] = hevc ? [32, 33, 34] : [7, 8]
            let sets = annexBUnits(extradata).filter { wanted.contains(hevc ? ($0.first ?? 0) >> 1 & 0x3f : ($0.first ?? 0) & 0x1f) }
            guard let description = parameterSetFormat(sets, hevc: hevc, extensions: extensions) else { return nil }
            return TrackFormat(mediaType: kCMMediaType_Video, description: description, convert: annexBToLengthPrefixed)
        }
        convert = { annexBUnits($0).isEmpty || !isAnnexB($0) ? $0 : annexBToLengthPrefixed($0) }
    case AV_CODEC_ID_AV1 where extradata.first == 0x81 && VTIsHardwareDecodeSupported(kCMVideoCodecType_AV1):
        extensions[kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms] = ["av1C": extradata]
        codec = kCMVideoCodecType_AV1
    default:
        guard let own = PikaCodec.video.first(where: { $0.0 == par.codec_id }) else { return nil }
        codec = PikaCodec.fourCC(own.1)
        var tag = par.codec_tag.bigEndian
        extensions[kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms] = [PikaCodec.atom: Data(bytes: &tag, count: 4) + [decodeOrderTimes ? 1 : 0] + extradata]
    }
    var description: CMFormatDescription?
    CMVideoFormatDescriptionCreate(allocator: nil, codecType: codec, width: par.width, height: par.height, extensions: extensions as CFDictionary, formatDescriptionOut: &description)
    return description.map { TrackFormat(mediaType: kCMMediaType_Video, description: $0, convert: convert) }
}

private func videoExtensions(_ stream: UnsafeMutablePointer<AVStream>, _ par: AVCodecParameters) -> [CFString: Any] {
    var extensions: [CFString: Any] = [:]
    let aspect = stream.pointee.sample_aspect_ratio.num > 0 ? stream.pointee.sample_aspect_ratio : par.sample_aspect_ratio
    if aspect.num > 0, aspect.den > 0, aspect.num != aspect.den {
        extensions[kCMFormatDescriptionExtension_PixelAspectRatio] = [
            kCMFormatDescriptionKey_PixelAspectRatioHorizontalSpacing: aspect.num,
            kCMFormatDescriptionKey_PixelAspectRatioVerticalSpacing: aspect.den,
        ]
    }
    let color = colorAttachments(primaries: par.color_primaries, transfer: par.color_trc, matrix: par.color_space, height: par.height)
    for (key, value) in color { extensions[key] = value }
    if par.color_range == AVCOL_RANGE_JPEG { extensions[kCMFormatDescriptionExtension_FullRangeVideo] = true }
    return extensions
}

private func isAnnexB(_ data: Data) -> Bool {
    data.starts(with: [0, 0, 1]) || data.starts(with: [0, 0, 0, 1])
}

private func annexBUnits(_ data: Data) -> [Data] {
    let bytes = [UInt8](data)
    var starts: [(Int, Int)] = []
    var i = 0
    while i + 2 < bytes.count {
        if bytes[i] == 0, bytes[i + 1] == 0, bytes[i + 2] == 1 {
            starts.append((i, i + 3))
            i += 3
        } else {
            i += 1
        }
    }
    return starts.enumerated().map { n, start in
        var end = n + 1 < starts.count ? starts[n + 1].0 : bytes.count
        while end > start.1, bytes[end - 1] == 0, n + 1 < starts.count { end -= 1 }
        return Data(bytes[start.1..<end])
    }.filter { !$0.isEmpty }
}

private func annexBToLengthPrefixed(_ data: Data) -> Data {
    var out = Data(capacity: data.count + 16)
    for unit in annexBUnits(data) {
        var length = UInt32(unit.count).bigEndian
        out.append(Data(bytes: &length, count: 4))
        out.append(unit)
    }
    return out
}

private func parameterSetFormat(_ sets: [Data], hevc: Bool, extensions: [CFString: Any]) -> CMFormatDescription? {
    guard sets.count >= (hevc ? 3 : 2) else { return nil }
    let buffers = sets.map { [UInt8]($0) }
    var description: CMFormatDescription?
    func create(_ pointers: [UnsafePointer<UInt8>]) {
        let sizes = buffers.map(\.count)
        if hevc {
            CMVideoFormatDescriptionCreateFromHEVCParameterSets(allocator: nil, parameterSetCount: pointers.count, parameterSetPointers: pointers, parameterSetSizes: sizes, nalUnitHeaderLength: 4, extensions: extensions as CFDictionary, formatDescriptionOut: &description)
        } else {
            CMVideoFormatDescriptionCreateFromH264ParameterSets(allocator: nil, parameterSetCount: pointers.count, parameterSetPointers: pointers, parameterSetSizes: sizes, nalUnitHeaderLength: 4, formatDescriptionOut: &description)
        }
    }
    func nest(_ index: Int, _ pointers: [UnsafePointer<UInt8>]) {
        guard index < buffers.count else { return create(pointers) }
        buffers[index].withUnsafeBufferPointer { nest(index + 1, pointers + [$0.baseAddress!]) }
    }
    nest(0, [])
    return description
}

private func makeAudioFormat(_ par: AVCodecParameters, _ extradata: Data) -> TrackFormat? {
    let channels = UInt32(par.ch_layout.nb_channels)
    guard channels > 0, par.sample_rate > 0 else { return nil }
    var asbd = AudioStreamBasicDescription(mSampleRate: Float64(par.sample_rate), mFormatID: 0, mFormatFlags: 0, mBytesPerPacket: 0, mFramesPerPacket: UInt32(max(par.frame_size, 0)), mBytesPerFrame: 0, mChannelsPerFrame: channels, mBitsPerChannel: 0, mReserved: 0)
    var cookie = Data()
    var convert: ((Data) -> Data)?
    var decoder: AudioDecoder?
    switch par.codec_id {
    case AV_CODEC_ID_AAC:
        let config = extradata.isEmpty ? adtsConfig(par) : extradata
        cookie = esds(config)
        var size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        guard cookie.withUnsafeBytes({ AudioFormatGetProperty(kAudioFormatProperty_ASBDFromESDS, UInt32($0.count), $0.baseAddress, &size, &asbd) }) == noErr else { return nil }
        convert = { $0.count > 7 && $0[$0.startIndex] == 0xff && $0[$0.startIndex + 1] & 0xf0 == 0xf0 ? $0.dropFirst($0[$0.startIndex + 1] & 1 == 0 ? 9 : 7) : $0 }
    case AV_CODEC_ID_MP1: asbd.mFormatID = kAudioFormatMPEGLayer1
    case AV_CODEC_ID_MP2: asbd.mFormatID = kAudioFormatMPEGLayer2
    case AV_CODEC_ID_MP3: asbd.mFormatID = kAudioFormatMPEGLayer3
    case AV_CODEC_ID_AC3: asbd.mFormatID = kAudioFormatAC3; asbd.mFramesPerPacket = 1536
    case AV_CODEC_ID_EAC3: asbd.mFormatID = kAudioFormatEnhancedAC3; asbd.mFramesPerPacket = 1536
    case AV_CODEC_ID_FLAC:
        asbd.mFormatID = kAudioFormatFLAC
        cookie = flacCookie(extradata)
        var size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        guard cookie.withUnsafeBytes({ AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, UInt32($0.count), $0.baseAddress, &size, &asbd) }) == noErr else { return nil }
    case AV_CODEC_ID_OPUS:
        asbd.mFormatID = kAudioFormatOpus
        asbd.mSampleRate = 48000
        asbd.mFramesPerPacket = 960
        cookie = extradata
    case AV_CODEC_ID_ALAC:
        asbd.mFormatID = kAudioFormatAppleLossless
        cookie = extradata.count > 24 ? extradata.suffix(24) : extradata
    case AV_CODEC_ID_PCM_S16LE, AV_CODEC_ID_PCM_S16BE, AV_CODEC_ID_PCM_S24LE, AV_CODEC_ID_PCM_S24BE, AV_CODEC_ID_PCM_S32LE, AV_CODEC_ID_PCM_S32BE,
         AV_CODEC_ID_PCM_F32LE, AV_CODEC_ID_PCM_F32BE, AV_CODEC_ID_PCM_U8:
        let bits = UInt32(av_get_bits_per_sample(par.codec_id))
        let big = [AV_CODEC_ID_PCM_S16BE, AV_CODEC_ID_PCM_S24BE, AV_CODEC_ID_PCM_S32BE, AV_CODEC_ID_PCM_F32BE].contains(par.codec_id)
        let float = par.codec_id == AV_CODEC_ID_PCM_F32LE || par.codec_id == AV_CODEC_ID_PCM_F32BE
        asbd = AudioStreamBasicDescription(mSampleRate: Float64(par.sample_rate), mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: (float ? kAudioFormatFlagIsFloat : bits > 8 ? kAudioFormatFlagIsSignedInteger : 0) | (big ? kAudioFormatFlagIsBigEndian : 0) | kAudioFormatFlagIsPacked,
            mBytesPerPacket: bits / 8 * channels, mFramesPerPacket: 1, mBytesPerFrame: bits / 8 * channels, mChannelsPerFrame: channels, mBitsPerChannel: bits, mReserved: 0)
    case AV_CODEC_ID_WMAV1, AV_CODEC_ID_WMAV2, AV_CODEC_ID_VORBIS, AV_CODEC_ID_APE, AV_CODEC_ID_DSD_LSBF_PLANAR:
        guard let software = AudioDecoder(par) else { return nil }
        decoder = software
        asbd = software.format
    default:
        return nil
    }
    var layout = AudioChannelLayout()
    layout.mChannelLayoutTag = kAudioChannelLayoutTag_UseChannelBitmap
    layout.mChannelBitmap = AudioChannelBitmap(rawValue: UInt32(truncatingIfNeeded: par.ch_layout.order == AV_CHANNEL_ORDER_NATIVE ? par.ch_layout.u.mask : 0))
    let useLayout = asbd.mFormatID == kAudioFormatLinearPCM && channels > 2 && layout.mChannelBitmap.rawValue != 0
    var description: CMFormatDescription?
    let status = cookie.withUnsafeBytes { bytes in withUnsafePointer(to: &layout) { layout in
        CMAudioFormatDescriptionCreate(allocator: nil, asbd: &asbd, layoutSize: useLayout ? MemoryLayout<AudioChannelLayout>.size : 0, layout: useLayout ? layout : nil,
                                       magicCookieSize: bytes.count, magicCookie: bytes.baseAddress, extensions: nil, formatDescriptionOut: &description)
    } }
    guard status == noErr, let description else { return nil }
    return TrackFormat(mediaType: kCMMediaType_Audio, description: description, convert: convert, audioDecoder: decoder)
}

private func adtsConfig(_ par: AVCodecParameters) -> Data {
    let rates: [Int32] = [96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350]
    let index = UInt8(rates.firstIndex(of: par.sample_rate) ?? 4)
    let object = UInt8(max(par.profile, 0) + 1)
    let channels = UInt8(par.ch_layout.nb_channels)
    return Data([object << 3 | index >> 1, (index & 1) << 7 | channels << 3])
}

private func esds(_ config: Data) -> Data {
    func descriptor(_ tag: UInt8, _ body: Data) -> Data {
        let n = body.count
        return Data([tag, 0x80 | UInt8(n >> 21 & 0x7f), 0x80 | UInt8(n >> 14 & 0x7f), 0x80 | UInt8(n >> 7 & 0x7f), UInt8(n & 0x7f)]) + body
    }
    let decoderConfig = descriptor(0x04, Data([0x40, 0x15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) + descriptor(0x05, config))
    return descriptor(0x03, Data([0, 0, 0]) + decoderConfig + descriptor(0x06, Data([2])))
}

private func flacCookie(_ extradata: Data) -> Data {
    var blocks = extradata.starts(with: Array("fLaC".utf8)) ? Data(extradata.dropFirst(4)) : extradata
    if blocks.count == 34 { blocks = Data([0x80, 0, 0, 34]) + blocks }
    var size = UInt32(12 + blocks.count).bigEndian
    return Data(bytes: &size, count: 4) + Data("dfLa".utf8) + Data([0, 0, 0, 0]) + blocks
}
