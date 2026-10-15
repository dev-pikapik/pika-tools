import AudioToolbox
import Foundation

final class AudioDecoder {
    let format: AudioStreamBasicDescription
    private var context: UnsafeMutablePointer<AVCodecContext>?
    private var frame = av_frame_alloc()
    private var packet = av_packet_alloc()

    init?(_ parameters: AVCodecParameters) {
        var parameters = parameters
        guard let codec = avcodec_find_decoder(parameters.codec_id), let context = avcodec_alloc_context3(codec) else { return nil }
        guard avcodec_parameters_to_context(context, &parameters) >= 0, avcodec_open2(context, codec, nil) >= 0,
              [AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP].contains(context.pointee.sample_fmt) else {
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
            if frame.pointee.format == AV_SAMPLE_FMT_FLTP.rawValue {
                for channel in 0..<channels {
                    guard let plane = frame.pointee.extended_data[channel] else { continue }
                    plane.withMemoryRebound(to: Float.self, capacity: count) { source in
                        for i in 0..<count { samples[i * channels + channel] = source[i] }
                    }
                }
            } else if let plane = frame.pointee.extended_data[0] {
                plane.withMemoryRebound(to: Float.self, capacity: count * channels) { source in
                    for i in 0..<count * channels { samples[i] = source[i] }
                }
            }
            samples.withUnsafeBytes { out.append(contentsOf: $0) }
            av_frame_unref(frame)
        }
        return out
    }
}
