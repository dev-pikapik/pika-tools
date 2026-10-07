import AVFoundation
import Accelerate
import ImageIO
import PDFKit
import UniformTypeIdentifiers
import zlib

struct CompressorError: LocalizedError {
    var errorDescription: String? = String(localized: "The file can’t be opened. It may be damaged or locked with a password.")
}

enum Compressor {
    private static let videoTypes: [String: AVFileType] = ["mov": .mov, "mp4": .mp4, "m4v": .m4v]
    private static let imageTypes: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "gif", "bmp", "pdf"]
    private static let soundTypes: Set<String> = ["wav", "aiff", "aif", "aifc", "caf", "flac"]

    static func canCompress(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return imageTypes.contains(ext) || soundTypes.contains(ext) || videoTypes[ext] != nil
    }

    static func fileExtension(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        return soundTypes.contains(ext) ? "m4a" : ext == "bmp" ? "png" : url.pathExtension
    }

    static func compress(_ source: URL, to output: URL, progress: @escaping @Sendable (Double) -> Void) async throws {
        let ext = source.pathExtension.lowercased()
        switch ext {
        case "png": try png(source, to: output)
        case "jpg", "jpeg": try reencode(source, to: output, quality: 0.8)
        case "heic", "heif": try reencode(source, to: output, quality: 0.7)
        case "tif", "tiff", "gif": try reencode(source, to: output, quality: nil)
        case "bmp": try reencode(source, to: output, as: .png, quality: nil)
        case "pdf": try pdf(source, to: output)
        case "wav", "aiff", "aif", "aifc", "caf", "flac": try await Converter.convert(source, to: "m4a", output: output, progress: progress)
        default:
            guard let type = videoTypes[ext] else { throw CompressorError() }
            try await export(source, to: output, type: type, preset: AVAssetExportPresetHEVCHighestQuality, progress: progress)
        }
    }

    static func reencode(_ source: URL, to output: URL, as target: UTType? = nil, quality: Double?) throws {
        guard let image = CGImageSourceCreateWithURL(source as CFURL, nil),
              let sourceType = CGImageSourceGetType(image),
              case let type = target.map({ $0.identifier as CFString }) ?? sourceType,
              case let total = CGImageSourceGetCount(image), total > 0,
              case let count = type == sourceType || target == .tiff ? total : 1,
              let destination = CGImageDestinationCreateWithURL(output as CFURL, type, count, nil)
        else { throw CompressorError() }
        if type == sourceType, let gif = (CGImageSourceCopyProperties(image, nil) as? [CFString: Any])?[kCGImagePropertyGIFDictionary] {
            CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: gif] as CFDictionary)
        }
        let options: [CFString: Any] = quality.map { [kCGImageDestinationLossyCompressionQuality: $0] } ?? [:]
        let tiff = type == UTType.tiff.identifier as CFString
        let jpeg = type == UTType.jpeg.identifier as CFString
        for index in 0..<count {
            let frame = tiff || jpeg ? CGImageSourceCreateImageAtIndex(image, index, nil) : nil
            let opaque = frame.map { [.none, .noneSkipFirst, .noneSkipLast].contains($0.alphaInfo) } ?? true
            if tiff || !opaque {
                guard let frame, let ready = opaque ? frame : flattened(frame) else { throw CompressorError() }
                var properties = (CGImageSourceCopyPropertiesAtIndex(image, index, nil) as? [CFString: Any] ?? [:]).merging(options) { $1 }
                if tiff {
                    var dictionary = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any] ?? [:]
                    dictionary[kCGImagePropertyTIFFCompression] = 5
                    dictionary[kCGImagePropertyTIFFTileWidth] = nil
                    dictionary[kCGImagePropertyTIFFTileLength] = nil
                    properties[kCGImagePropertyTIFFDictionary] = dictionary
                }
                CGImageDestinationAddImage(destination, ready, properties as CFDictionary)
            } else {
                CGImageDestinationAddImageFromSource(destination, image, index, options as CFDictionary)
            }
            if quality != nil, let gainMap = CGImageSourceCopyAuxiliaryDataInfoAtIndex(image, index, kCGImageAuxiliaryDataTypeHDRGainMap) {
                CGImageDestinationAddAuxiliaryDataInfo(destination, kCGImageAuxiliaryDataTypeHDRGainMap, gainMap)
            }
        }
        guard CGImageDestinationFinalize(destination) else { throw CompressorError() }
    }

    private static func flattened(_ image: CGImage) -> CGImage? {
        let original = image.colorSpace.map { $0.model == .indexed ? $0.baseColorSpace ?? $0 : $0 }
        let space = original.flatMap { $0.model == .rgb || $0.model == .monochrome ? $0 : nil } ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        guard let context = CGContext(
            data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 0, space: space,
            bitmapInfo: (space.model == .rgb ? CGImageAlphaInfo.noneSkipLast : CGImageAlphaInfo.none).rawValue
        ) else { return nil }
        context.setFillColor(.white)
        context.fill(rect)
        context.draw(image, in: rect)
        return context.makeImage()
    }

    static func upright(_ file: CGImageSource) -> CGImage? {
        guard let image = CGImageSourceCreateImageAtIndex(file, 0, nil) else { return nil }
        let properties = CGImageSourceCopyPropertiesAtIndex(file, 0, nil) as? [CFString: Any] ?? [:]
        guard let orientation = properties[kCGImagePropertyOrientation] as? Int, orientation > 1 else { return image }
        return CGImageSourceCreateThumbnailAtIndex(file, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(image.width, image.height),
        ] as CFDictionary) ?? image
    }

    private static func pdf(_ source: URL, to output: URL) throws {
        guard let document = PDFDocument(url: source), !document.isEncrypted, let page = document.page(at: 0)
        else { throw CompressorError() }
        document.removePage(at: 0)
        document.insert(page, at: 0)
        guard document.write(to: output, withOptions: [.saveImagesAsJPEGOption: true])
        else { throw CompressorError() }
    }

    static func export(_ source: URL, to output: URL, type: AVFileType, preset: String, progress: @escaping @Sendable (Double) -> Void) async throws {
        guard let session = AVAssetExportSession(asset: AVURLAsset(url: source), presetName: preset)
        else { throw CompressorError() }
        session.outputURL = output
        session.outputFileType = type
        session.exportAsynchronously {}
        while [.waiting, .exporting].contains(session.status) {
            if Task.isCancelled {
                session.cancelExport()
                throw CancellationError()
            }
            progress(Double(session.progress))
            try? await Task.sleep(for: .milliseconds(200))
        }
        guard session.status == .completed else { throw session.error ?? CompressorError() }
    }
}

extension Compressor {
    private static func png(_ source: URL, to output: URL) throws {
        guard let file = CGImageSourceCreateWithURL(source as CFURL, nil),
              CGImageSourceGetCount(file) == 1,
              let image = upright(file)
        else { throw CompressorError() }
        let properties = CGImageSourceCopyPropertiesAtIndex(file, 0, nil) as? [CFString: Any] ?? [:]

        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
        let original = image.colorSpace.flatMap { $0.model == .rgb && $0.copyICCData() != nil ? $0 : nil }
        let space = original ?? sRGB
        guard let format = vImage_CGImageFormat(
            bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: space,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        ), let buffer = try? vImage_Buffer(cgImage: image, format: format)
        else { throw CompressorError() }
        defer { buffer.free() }

        let width = Int(buffer.width), height = Int(buffer.height)
        var pixels = [UInt32](repeating: 0, count: width * height)
        pixels.withUnsafeMutableBufferPointer { out in
            for y in 0..<height {
                let row = buffer.data.advanced(by: y * buffer.rowBytes).assumingMemoryBound(to: UInt32.self)
                for x in 0..<width {
                    let pixel = UInt32(littleEndian: row[x])
                    out[y * width + x] = pixel >> 24 == 0 ? 0 : pixel
                }
            }
        }

        let (palette, indices) = try Quantizer(pixels: pixels, width: width, height: height).run()

        var png = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        func chunk(_ type: String, _ body: [UInt8]) {
            let data = Array(type.utf8) + body
            png.append(contentsOf: bigEndian(UInt32(body.count)) + data + bigEndian(UInt32(crc32(0, data, uInt(data.count)))))
        }
        chunk("IHDR", bigEndian(UInt32(width)) + bigEndian(UInt32(height)) + [8, 3, 0, 0, 0])
        if let original, original.name != CGColorSpace.sRGB, let icc = original.copyICCData() as Data? {
            chunk("iCCP", Array("ICC Profile".utf8) + [0, 0] + (try deflate(Array(icc))))
        } else {
            chunk("sRGB", [0])
        }
        if let dpiX = properties[kCGImagePropertyDPIWidth] as? Double, let dpiY = properties[kCGImagePropertyDPIHeight] as? Double {
            chunk("pHYs", bigEndian(UInt32((dpiX / 0.0254).rounded())) + bigEndian(UInt32((dpiY / 0.0254).rounded())) + [1])
        }
        chunk("PLTE", palette.flatMap { [UInt8($0 & 0xFF), UInt8($0 >> 8 & 0xFF), UInt8($0 >> 16 & 0xFF)] })
        let alphas = palette.map { UInt8($0 >> 24) }.prefix { $0 < 255 }
        if !alphas.isEmpty { chunk("tRNS", Array(alphas)) }
        var raw = [UInt8](repeating: 0, count: (width + 1) * height)
        for y in 0..<height {
            raw.replaceSubrange((y * (width + 1) + 1)..<((y + 1) * (width + 1)), with: indices[(y * width)..<((y + 1) * width)])
        }
        try Task.checkCancellation()
        chunk("IDAT", try deflate(raw))
        chunk("IEND", [])
        try png.write(to: output, options: .withoutOverwriting)
    }

    private static func bigEndian(_ value: UInt32) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    private static func deflate(_ data: [UInt8]) throws -> [UInt8] {
        var size = compressBound(uLong(data.count))
        var out = [UInt8](repeating: 0, count: Int(size))
        guard compress2(&out, &size, data, uLong(data.count), data.count > 8_000_000 ? Z_DEFAULT_COMPRESSION : Z_BEST_COMPRESSION) == Z_OK else { throw CompressorError() }
        return Array(out.prefix(Int(size)))
    }
}

private struct Quantizer {
    let pixels: [UInt32]
    let width: Int
    let height: Int

    func run() throws -> (palette: [UInt32], indices: [UInt8]) {
        var unique = Set<UInt32>()
        var last: UInt32?
        for pixel in pixels where pixel != last {
            last = pixel
            unique.insert(pixel)
            if unique.count > 256 { break }
        }
        if unique.count <= 256 {
            let palette = unique.sorted { $0 >> 24 < 255 && $1 >> 24 == 255 }
            let lookup = Dictionary(uniqueKeysWithValues: palette.enumerated().map { ($1, UInt8($0)) })
            var indices = [UInt8](repeating: 0, count: pixels.count)
            var previous: (UInt32, UInt8) = (palette[0], 0)
            for (i, pixel) in pixels.enumerated() {
                if pixel != previous.0 { previous = (pixel, lookup[pixel]!) }
                indices[i] = previous.1
            }
            return (palette, indices)
        }
        return try dither()
    }

    private func dither() throws -> (palette: [UInt32], indices: [UInt8]) {
        let hasTransparent = pixels.contains(0)
        let entries = histogram()
        let colors = refine(cut(entries, into: hasTransparent ? 255 : 256), with: entries)
        var nearest = Nearest(palette: colors.map { Self.premultiplied(Self.straight($0)) })
        var palette = nearest.colors.map(Self.straight)
        let transparent = palette.count
        if hasTransparent { palette.append(0) }

        var indices = [UInt8](repeating: 0, count: pixels.count)
        var current = [SIMD4<Float>](repeating: .zero, count: width + 2)
        var next = current
        let top = SIMD4<Float>(repeating: 255)
        for y in 0..<height {
            if y % 32 == 0 { try Task.checkCancellation() }
            swap(&current, &next)
            for x in next.indices { next[x] = .zero }
            for x in 0..<width {
                let pixel = pixels[y * width + x]
                if pixel == 0 {
                    indices[y * width + x] = UInt8(transparent)
                    continue
                }
                var color = simd_clamp(Self.premultiplied(pixel) + current[x + 1], .zero, top)
                color = simd_min(color, SIMD4(repeating: color.w))
                let index = nearest.find(color)
                indices[y * width + x] = UInt8(index)
                var error = (color - nearest.colors[index]) * 0.875
                let size = simd_length_squared(error)
                if size > 256 { error *= 16 / size.squareRoot() }
                current[x + 2] += error * (7 / 16)
                next[x] += error * (3 / 16)
                next[x + 1] += error * (5 / 16)
                next[x + 2] += error * (1 / 16)
            }
        }

        let order = palette.indices.sorted { palette[$0] >> 24 < 255 && palette[$1] >> 24 == 255 }
        var position = [UInt8](repeating: 0, count: palette.count)
        for (new, old) in order.enumerated() { position[old] = UInt8(new) }
        return (order.map { palette[$0] }, indices.map { position[Int($0)] })
    }

    private func histogram() -> [Entry] {
        var step = max(1, pixels.count / 1_000_000)
        while step > 1, Self.gcd(step, width) != 1 { step += 1 }
        var counts: [UInt32: Float] = [:]
        for i in stride(from: 0, to: pixels.count, by: step) where pixels[i] != 0 {
            counts[pixels[i], default: 0] += 1
        }
        return counts.map { Entry(color: Self.premultiplied($0.key), weight: $0.value) }
    }

    private func cut(_ entries: [Entry], into target: Int) -> [SIMD4<Float>] {
        var entries = entries
        var boxes = [Box(entries[...], start: 0)]
        while boxes.count < target,
              let pick = boxes.indices.filter({ boxes[$0].count > 1 && boxes[$0].score > 0 }).max(by: { boxes[$0].score < boxes[$1].score }) {
            let box = boxes[pick]
            let range = box.start..<(box.start + box.count)
            entries[range].sort { $0.color[box.axis] < $1.color[box.axis] }
            var half = box.weight / 2
            var split = range.lowerBound
            while split < range.upperBound - 1, half > 0 {
                half -= entries[split].weight
                split += 1
            }
            split = max(split, range.lowerBound + 1)
            boxes[pick] = Box(entries[range.lowerBound..<split], start: range.lowerBound)
            boxes.append(Box(entries[split..<range.upperBound], start: split))
        }
        return boxes.map(\.mean)
    }

    private func refine(_ palette: [SIMD4<Float>], with entries: [Entry]) -> [SIMD4<Float>] {
        var palette = palette
        for _ in 0..<3 {
            var nearest = Nearest(palette: palette)
            var sums = [SIMD4<Float>](repeating: .zero, count: palette.count)
            var weights = [Float](repeating: 0, count: palette.count)
            for entry in entries {
                let index = nearest.find(entry.color)
                sums[index] += entry.color * entry.weight
                weights[index] += entry.weight
            }
            palette = nearest.colors.indices.map { weights[$0] > 0 ? sums[$0] / weights[$0] : nearest.colors[$0] }
        }
        return palette
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

    static func premultiplied(_ pixel: UInt32) -> SIMD4<Float> {
        let alpha = Float(pixel >> 24)
        let color = SIMD3<Float>(Float(pixel & 0xFF), Float(pixel >> 8 & 0xFF), Float(pixel >> 16 & 0xFF)) * (alpha / 255)
        return SIMD4(color, alpha)
    }

    static func straight(_ color: SIMD4<Float>) -> UInt32 {
        let alpha = color.w.rounded()
        guard alpha > 0 else { return 0 }
        let rgb = (SIMD3(color.x, color.y, color.z) * (255 / color.w)).rounded(.toNearestOrAwayFromZero).clamped(lowerBound: .zero, upperBound: SIMD3(repeating: 255))
        return UInt32(rgb.x) | UInt32(rgb.y) << 8 | UInt32(rgb.z) << 16 | UInt32(min(alpha, 255)) << 24
    }
}

private struct Entry {
    var color: SIMD4<Float>
    var weight: Float
}

private struct Box {
    let start: Int
    let count: Int
    let weight: Float
    let mean: SIMD4<Float>
    let score: Float
    let axis: Int

    init(_ entries: ArraySlice<Entry>, start: Int) {
        self.start = start
        count = entries.count
        var sum = SIMD4<Float>.zero, squares = SIMD4<Float>.zero, weight: Float = 0
        for entry in entries {
            sum += entry.color * entry.weight
            squares += entry.color * entry.color * entry.weight
            weight += entry.weight
        }
        self.weight = weight
        mean = sum / weight
        let variance = squares / weight - mean * mean
        score = variance.sum() * weight
        axis = variance.indices.max { variance[$0] < variance[$1] } ?? 0
    }
}

private struct Nearest {
    let colors: [SIMD4<Float>]
    private var cells = [Int32](repeating: -1, count: 1 << 20)
    private var lengths = [UInt8](repeating: 0, count: 1 << 20)
    private var pool: [SIMD4<Float>] = []
    private var poolIndices: [UInt8] = []

    init(palette: [SIMD4<Float>]) {
        colors = palette
    }

    mutating func find(_ color: SIMD4<Float>) -> Int {
        let cell = simd_clamp(color, .zero, SIMD4(repeating: 255)) / 8
        let r = Int(cell.x), g = Int(cell.y), b = Int(cell.z), a = Int(cell.w)
        let key = a << 15 | r << 10 | g << 5 | b
        if cells[key] < 0 { fill(key, low: SIMD4(Float(r), Float(g), Float(b), Float(a)) * 8) }
        let start = Int(cells[key])
        let end = start + Int(lengths[key]) + 1
        let best = pool.withUnsafeBufferPointer { pool in
            var best = start
            var bestDistance = Float.infinity
            for i in start..<end {
                let distance = simd_distance_squared(color, pool[i])
                if distance < bestDistance { best = i; bestDistance = distance }
            }
            return best
        }
        return Int(poolIndices[best])
    }

    private mutating func fill(_ key: Int, low: SIMD4<Float>) {
        let high = low + 8
        let limit = colors.map { simd_length_squared(simd_max(simd_abs($0 - low), simd_abs($0 - high))) }.min() ?? 0
        let inside = colors.indices.filter { index in
            simd_length_squared(simd_max(low - colors[index], .zero) + simd_max(colors[index] - high, .zero)) <= limit
        }
        cells[key] = Int32(pool.count)
        lengths[key] = UInt8(inside.count - 1)
        pool.append(contentsOf: inside.map { colors[$0] })
        poolIndices.append(contentsOf: inside.map(UInt8.init))
    }
}
