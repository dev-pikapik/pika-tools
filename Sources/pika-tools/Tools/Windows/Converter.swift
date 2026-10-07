import AVFoundation
import ImageIO
import UniformTypeIdentifiers

enum Converter {
    private static let images: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "gif", "bmp", "webp"]
    private static let videos: Set<String> = ["mov", "mp4", "m4v"]
    private static let sounds: Set<String> = ["wav", "aiff", "aif", "mp3", "m4a", "caf"]
    private static let formats = [
        "jpg": "jpeg", "jpeg": "jpeg", "png": "png", "heic": "heic", "heif": "heic", "tif": "tiff", "tiff": "tiff",
        "mp4": "mp4", "mov": "mov", "m4a": "m4a", "wav": "wav", "aiff": "aiff", "aif": "aiff",
    ]

    static func targets(for url: URL) -> [String] {
        let ext = url.pathExtension.lowercased()
        if images.contains(ext) { return ["jpeg", "png", "heic", "tiff", "pdf"] }
        if videos.contains(ext) { return ["mp4", "mov", "m4a"] }
        if sounds.contains(ext) { return ["m4a", "wav", "aiff"] }
        return []
    }

    static func format(of url: URL) -> String? {
        formats[url.pathExtension.lowercased()]
    }

    static func fileExtension(for target: String) -> String {
        target == "jpeg" ? "jpg" : target
    }

    static func convert(_ source: URL, to target: String, output: URL, progress: @escaping @Sendable (Double) -> Void) async throws {
        switch target {
        case "jpeg": try Compressor.reencode(source, to: output, as: .jpeg, quality: 0.9)
        case "heic": try Compressor.reencode(source, to: output, as: .heic, quality: 0.8)
        case "png": try Compressor.reencode(source, to: output, as: .png, quality: nil)
        case "tiff": try Compressor.reencode(source, to: output, as: .tiff, quality: nil)
        case "pdf": try pdf(source, to: output)
        case "mp4": try await movie(source, to: output, type: .mp4, progress: progress)
        case "mov": try await movie(source, to: output, type: .mov, progress: progress)
        case "m4a":
            guard try await !AVURLAsset(url: source).loadTracks(withMediaType: .audio).isEmpty
            else { throw CompressorError(errorDescription: String(localized: "There’s no sound in this file.")) }
            try await Compressor.export(source, to: output, type: .m4a, preset: AVAssetExportPresetAppleM4A, progress: progress)
        case "wav": try await pcm(source, to: output, type: .wav, progress: progress)
        case "aiff": try await pcm(source, to: output, type: .aiff, progress: progress)
        default: throw CompressorError()
        }
    }

    private static func pdf(_ source: URL, to output: URL) throws {
        guard let file = CGImageSourceCreateWithURL(source as CFURL, nil), let image = Compressor.upright(file)
        else { throw CompressorError() }
        let properties = CGImageSourceCopyPropertiesAtIndex(file, 0, nil) as? [CFString: Any] ?? [:]
        let dpi = (properties[kCGImagePropertyDPIWidth] as? Double).flatMap { $0 > 0 ? $0 : nil } ?? 72
        var page = CGRect(x: 0, y: 0, width: Double(image.width) * 72 / dpi, height: Double(image.height) * 72 / dpi)
        guard let context = CGContext(output as CFURL, mediaBox: &page, nil) else { throw CompressorError() }
        context.beginPDFPage(nil)
        context.draw(image, in: page)
        context.endPDFPage()
        context.closePDF()
    }

    private static func movie(_ source: URL, to output: URL, type: AVFileType, progress: @escaping @Sendable (Double) -> Void) async throws {
        let fits = await AVAssetExportSession.compatibility(ofExportPreset: AVAssetExportPresetPassthrough, with: AVURLAsset(url: source), outputFileType: type)
        let preset = fits ? AVAssetExportPresetPassthrough : AVAssetExportPresetHEVCHighestQuality
        try await Compressor.export(source, to: output, type: type, preset: preset, progress: progress)
    }

    private static func pcm(_ source: URL, to output: URL, type: AVFileType, progress: @escaping @Sendable (Double) -> Void) async throws {
        let asset = AVURLAsset(url: source)
        guard let track = try await asset.loadTracks(withMediaType: .audio).first,
              let format = try await track.load(.formatDescriptions).first,
              let basic = CMAudioFormatDescriptionGetStreamBasicDescription(format)?.pointee
        else { throw CompressorError(errorDescription: String(localized: "There’s no sound in this file.")) }
        let duration = try await asset.load(.duration).seconds
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: basic.mSampleRate,
            AVNumberOfChannelsKey: basic.mChannelsPerFrame,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: type == .aiff,
            AVLinearPCMIsNonInterleaved: false,
        ]
        var layoutSize = 0
        var written = settings
        if let layout = CMAudioFormatDescriptionGetChannelLayout(format, sizeOut: &layoutSize) {
            written[AVChannelLayoutKey] = Data(bytes: layout, count: layoutSize)
        }
        let reader = try AVAssetReader(asset: asset)
        let samples = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(samples)
        let writer = try AVAssetWriter(outputURL: output, fileType: type)
        let input = AVAssetWriterInput(mediaType: .audio, outputSettings: written)
        writer.add(input)
        guard reader.startReading(), writer.startWriting() else { throw reader.error ?? writer.error ?? CompressorError() }
        writer.startSession(atSourceTime: .zero)
        do {
            while let buffer = samples.copyNextSampleBuffer() {
                while !input.isReadyForMoreMediaData { try await Task.sleep(for: .milliseconds(5)) }
                try Task.checkCancellation()
                guard input.append(buffer) else { throw writer.error ?? CompressorError() }
                if duration > 0 { progress(CMSampleBufferGetPresentationTimeStamp(buffer).seconds / duration) }
            }
            guard reader.status == .completed else { throw reader.error ?? CompressorError() }
        } catch {
            reader.cancelReading()
            writer.cancelWriting()
            throw error
        }
        input.markAsFinished()
        await writer.finishWriting()
        guard writer.status == .completed else { throw writer.error ?? CompressorError() }
    }
}
