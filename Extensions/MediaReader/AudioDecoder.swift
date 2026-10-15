import AudioToolbox
import Foundation

final class AudioDecoder {
    private static let formats: [AVSampleFormat] = [AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP, AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P, AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P]
    let format: AudioStreamBasicDescription
    private var context: UnsafeMutablePointer<AVCodecContext>?
    private var frame = av_frame_alloc()
    private var packet = av_packet_alloc()

    init?(_ parameters: AVCodecParameters) {
        var parameters = parameters
        guard let codec = avcodec_find_decoder(parameters.codec_id), let context = avcodec_alloc_context3(codec) else { return nil }
        guard avcodec_parameters_to_context(context, &parameters) >= 0, avcodec_open2(context, codec, nil) >= 0,
              Self.formats.contains(context.pointee.sample_fmt) else {
            var failed: UnsafeMutablePointer<AVCodecContext>? = context
            avcodec_free_context(&failed)
            return nil
        }
        self.context = context
        let channels = UInt32(context.pointee.ch_layout.nb_channels)
        format = AudioStreamBasicDescription(mSampleRate: Float64(context.pointee.sample_rate), mFormatID: kAudioFormatLinearPCM,
                                             mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked, mBytesPerPacket: 4 * channels, mFramesPerPacket: 1,
                                             mBytesPerFrame: 4 * channels, mChannelsPerFrame: channels, mBitsPerChannel: 32, mReserved: 0)
    }

    deinit {
        avcodec_free_context(&context)
        av_frame_free(&frame)
        av_packet_free(&packet)
    }

    private static func sample(_ plane: UnsafeRawPointer, _ index: Int, _ format: AVSampleFormat) -> Float {
        switch format {
        case AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P: Float(plane.load(fromByteOffset: index * 2, as: Int16.self)) / 32768
        case AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P: Float(plane.load(fromByteOffset: index * 4, as: Int32.self)) / 2147483648
        default: plane.load(fromByteOffset: index * 4, as: Float.self)
        }
    }

    func flush() {
        avcodec_flush_buffers(context)
    }

    func decode(_ data: UnsafePointer<UInt8>?, _ size: Int32) -> Data {
        guard let context, let frame, let packet, let data, size > 0 else { return Data() }
        packet.pointee.data = UnsafeMutablePointer(mutating: data)
        packet.pointee.size = size
        defer { packet.pointee.data = nil; packet.pointee.size = 0 }
        guard avcodec_send_packet(context, packet) >= 0 else { return Data() }
        var out = Data()
        while avcodec_receive_frame(context, frame) >= 0 {
            let channels = Int(frame.pointee.ch_layout.nb_channels)
            let count = Int(frame.pointee.nb_samples)
            var samples = [Float](repeating: 0, count: count * channels)
            let layout = AVSampleFormat(rawValue: frame.pointee.format)
            let planar = av_sample_fmt_is_planar(layout) != 0
            for channel in 0..<(planar ? channels : 1) {
                guard let plane = frame.pointee.extended_data[channel] else { continue }
                for i in 0..<(planar ? count : count * channels) {
                    samples[planar ? i * channels + channel : i] = Self.sample(plane, i, layout)
                }
            }
            samples.withUnsafeBytes { out.append(contentsOf: $0) }
            av_frame_unref(frame)
        }
        return out
    }
}
