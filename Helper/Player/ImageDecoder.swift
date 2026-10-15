import AppKit
import ImageIO
import UniformTypeIdentifiers

struct ImageProbe {
    let size: CGSize
    let animated: Bool
    let vector: Bool

    var longSide: Int { Int(max(size.width, size.height)) }
}

enum ImageDecoder {
    private static let animated: [UTType] = [.gif, .png, .webP, UTType("public.heics")].compactMap { $0 }

    static func probe(_ url: URL) -> ImageProbe? {
        if isVector(url) {
            guard let image = NSImage(contentsOf: url), image.size.width >= 1, image.size.height >= 1 else { return nil }
            return ImageProbe(size: image.size, animated: false, vector: true)
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              CGImageSourceGetCount(source) > 0,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int, let height = properties[kCGImagePropertyPixelHeight] as? Int, width > 0, height > 0 else { return nil }
        let size = ImageDetail.oriented(width: width, height: height, orientation: properties[kCGImagePropertyOrientation] as? Int ?? 1)
        let type = CGImageSourceGetType(source).flatMap { UTType($0 as String) }
        return ImageProbe(size: size, animated: CGImageSourceGetCount(source) > 1 && animated.contains { type?.conforms(to: $0) == true }, vector: false)
    }

    static func decode(_ url: URL, _ probe: ImageProbe, maxPixel: Int) -> CGImage? {
        probe.vector ? rasterize(url, maxPixel: maxPixel) : thumbnail(url, maxPixel: maxPixel)
    }

    private static func isVector(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "svg"
    }

    private static func thumbnail(_ url: URL, maxPixel: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary), CGImageSourceGetCount(source) > 0 else { return nil }
        return CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
        ] as CFDictionary)
    }

    private static func rasterize(_ url: URL, maxPixel: Int) -> CGImage? {
        guard let image = NSImage(contentsOf: url), image.size.width >= 1, image.size.height >= 1 else { return nil }
        let scale = CGFloat(maxPixel) / max(image.size.width, image.size.height)
        let (width, height) = (max(1, Int((image.size.width * scale).rounded())), max(1, Int((image.size.height * scale).rounded())))
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        return context.makeImage()
    }
}

final class ImageAnimation {
    init?(_ url: URL, onFrame: @escaping (CGImage) -> Void) {
        let status = CGAnimateImageAtURLWithBlock(url as CFURL, nil) { [weak self] _, frame, stop in
            guard self != nil else {
                stop.pointee = true
                return
            }
            onFrame(frame)
        }
        guard status == 0 else { return nil }
    }
}
