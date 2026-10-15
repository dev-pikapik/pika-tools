import AppKit
import Foundation
import UniformTypeIdentifiers

enum ImageFormats {
    static let all: [(name: String, extensions: [String])] = [
        ("JPEG", ["jpg", "jpeg"]), ("PNG", ["png", "apng"]), ("HEIC", ["heic", "heif"]), ("AVIF", ["avif"]), ("WebP", ["webp"]), ("JPEG XL", ["jxl"]),
        ("RAW", ["dng", "cr2", "cr3", "nef", "arw", "raf", "orf", "rw2"]), ("PSD", ["psd"]), ("TIFF", ["tif", "tiff"]), ("GIF", ["gif"]),
        ("SVG", ["svg"]), ("ICO", ["ico"]), ("ICNS", ["icns"]), ("BMP", ["bmp"]), ("TGA", ["tga"]), ("EXR", ["exr"]), ("HDR", ["hdr"]), ("JPEG 2000", ["jp2"]),
    ]

    static let previewApp = "com.apple.Preview"

    static var extensions: [String] { all.flatMap(\.extensions) }

    static var types: [UTType] { PlayerFormats.types(of: extensions) }

    static func opens(_ url: URL) -> Bool {
        extensions.contains(url.pathExtension.lowercased()) || UTType(filenameExtension: url.pathExtension)?.conforms(to: .image) == true
    }
}

enum ImageList {
    static func split(_ urls: [URL]) -> (images: [URL], rest: [URL]) {
        var images: [URL] = [], rest: [URL] = []
        for url in urls {
            if isFolder(url) { images += pictures(in: url) } else if ImageFormats.opens(url) { images.append(url) } else { rest.append(url) }
        }
        var seen = Set<URL>()
        return (sorted(images.filter { seen.insert($0.standardizedFileURL).inserted }), rest)
    }

    static func neighbours(in files: [URL]) -> [URL] {
        sorted(files.filter { ImageFormats.opens($0) && !isFolder($0) })
    }

    static func step(_ index: Int, by direction: Int, count: Int, wrap: Bool) -> Int? {
        guard count > 0 else { return nil }
        let next = index + direction
        if (0..<count).contains(next) { return next }
        return wrap && count > 1 ? (next + count) % count : nil
    }

    static func position(_ index: Int, of count: Int) -> String {
        String(localized: "\(index + 1) of \(count)")
    }

    private static func sorted(_ urls: [URL]) -> [URL] {
        urls.sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
    }

    private static func isFolder(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private static func pictures(in folder: URL) -> [URL] {
        ((try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []).filter(ImageFormats.opens)
    }
}

enum ImageAction: Equatable {
    case previous, next, slideshow, zoomIn, zoomOut, fit, actualSize, rotateLeft, rotateRight, leaveFullScreen

    private static let (left, right) = ("\u{F702}", "\u{F703}")

    static let bindings: [(action: ImageAction, key: String, modifiers: NSEvent.ModifierFlags)] = [
        (.previous, left, []), (.next, right, []),
        (.slideshow, "f", [.command, .shift]), (.slideshow, " ", []),
        (.zoomIn, "+", .command), (.zoomIn, "=", .command), (.zoomIn, "+", [.command, .shift]), (.zoomIn, "=", [.command, .shift]), (.zoomOut, "-", .command),
        (.fit, "0", .command), (.actualSize, "9", .command),
        (.rotateLeft, "l", .command), (.rotateRight, "r", .command),
        (.leaveFullScreen, "\u{1B}", []),
    ]

    init?(key: String, modifiers: NSEvent.ModifierFlags = []) {
        let held = modifiers.intersection([.command, .control, .option, .shift])
        guard let found = Self.bindings.first(where: { $0.key == key.lowercased() && $0.modifiers == held }) else { return nil }
        self = found.action
    }
}

enum ImageSlideshow {
    static let interval = 3.0
}

enum ImageDetail {
    static let limit = 16384
    static let maxArea = 128_000_000
    static let vectorLimit = 8192

    static func pixels(longSide: CGFloat, backing: CGFloat, screen: Int, image: CGSize, vector: Bool = false) -> Int {
        let needed = Int((longSide * backing).rounded(.up))
        if vector {
            var size = 512
            while size < needed, size < vectorLimit { size *= 2 }
            return size
        }
        let full = fullSide(of: image)
        return needed <= screen ? min(screen, full) : full
    }

    static func fullSide(of image: CGSize) -> Int {
        let side = max(image.width, image.height)
        guard side >= 1 else { return 1 }
        let scale = min(1, CGFloat(limit) / side, (CGFloat(maxArea) / (image.width * image.height)).squareRoot())
        return max(1, Int(side * scale + 0.000001))
    }

    static func oriented(width: Int, height: Int, orientation: Int) -> CGSize {
        (5...8).contains(orientation) ? CGSize(width: height, height: width) : CGSize(width: width, height: height)
    }
}

struct ImageViewport: Equatable {
    static let step: CGFloat = 1.25
    static let maxZoom: CGFloat = 16

    var turns = 0
    var zoom: CGFloat?
    var offset = CGSize.zero

    func turned(_ image: CGSize) -> CGSize {
        turns.isMultiple(of: 2) ? image : CGSize(width: image.height, height: image.width)
    }

    func fit(_ image: CGSize, in view: CGSize) -> CGFloat {
        let size = turned(image)
        guard size.width > 0, size.height > 0, view.width > 0, view.height > 0 else { return 1 }
        return min(1, view.width / size.width, view.height / size.height)
    }

    func layout(_ image: CGSize, in view: CGSize) -> (scale: CGFloat, offset: CGSize) {
        let scale = zoom ?? fit(image, in: view)
        return (scale, Self.clamped(offset, shown: Self.scaled(turned(image), scale), in: view))
    }

    func canPan(_ image: CGSize, in view: CGSize) -> Bool {
        let shown = Self.scaled(turned(image), layout(image, in: view).scale)
        return shown.width > view.width + 0.5 || shown.height > view.height + 0.5
    }

    mutating func zoom(by factor: CGFloat, around anchor: CGPoint = .zero, image: CGSize, in view: CGSize) {
        set(layout(image, in: view).scale * factor, around: anchor, image: image, in: view)
    }

    mutating func set(_ scale: CGFloat, around anchor: CGPoint = .zero, image: CGSize, in view: CGSize) {
        let current = layout(image, in: view)
        let target = min(max(scale, fit(image, in: view) / 4), Self.maxZoom)
        let ratio = target / current.scale
        zoom = target
        offset = Self.clamped(CGSize(width: anchor.x - (anchor.x - current.offset.width) * ratio, height: anchor.y - (anchor.y - current.offset.height) * ratio), shown: Self.scaled(turned(image), target), in: view)
    }

    mutating func toggleActual(around anchor: CGPoint, image: CGSize, in view: CGSize) {
        if let zoom, abs(zoom - 1) < 0.001 { fitToWindow() } else { set(1, around: anchor, image: image, in: view) }
    }

    mutating func fitToWindow() {
        zoom = nil
        offset = .zero
    }

    mutating func rotate(_ direction: Int) {
        turns += direction
        offset = .zero
    }

    mutating func pan(by delta: CGSize, image: CGSize, in view: CGSize) {
        guard zoom != nil else { return }
        let current = layout(image, in: view)
        offset = Self.clamped(CGSize(width: current.offset.width + delta.width, height: current.offset.height + delta.height), shown: Self.scaled(turned(image), current.scale), in: view)
    }

    static func percent(_ scale: CGFloat) -> String {
        Double(scale).formatted(.percent.precision(.fractionLength(0)))
    }

    private static func scaled(_ size: CGSize, _ scale: CGFloat) -> CGSize {
        CGSize(width: size.width * scale, height: size.height * scale)
    }

    private static func clamped(_ offset: CGSize, shown: CGSize, in view: CGSize) -> CGSize {
        let room = CGSize(width: max(0, shown.width - view.width) / 2, height: max(0, shown.height - view.height) / 2)
        return CGSize(width: min(max(offset.width, -room.width), room.width), height: min(max(offset.height, -room.height), room.height))
    }
}
