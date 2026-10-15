import AppKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
enum TestImages {
    static func main() throws {
        let tiny = CGSize(width: 100, height: 50), big = CGSize(width: 4000, height: 3000), view = CGSize(width: 800, height: 600)
        var port = ImageViewport()
        precondition(port.fit(big, in: view) == 0.2)
        precondition(port.fit(tiny, in: view) == 1)
        precondition(port.layout(big, in: view).scale == 0.2)
        port.rotate(1)
        precondition(port.fit(CGSize(width: 3000, height: 4000), in: view) == 0.2)
        port.rotate(-3)
        precondition(port.turns == -2 && port.turned(big) == big)
        print("a picture fits the window and small ones are not stretched: ok")

        port = ImageViewport()
        port.zoom(by: ImageViewport.step, image: big, in: view)
        precondition(abs(port.layout(big, in: view).scale - 0.25) < 1e-9)
        port.set(100, image: big, in: view)
        precondition(port.zoom == ImageViewport.maxZoom)
        port.set(0.0001, image: big, in: view)
        precondition(abs(port.zoom! - 0.05) < 1e-9)
        port.toggleActual(around: .zero, image: big, in: view)
        precondition(port.zoom == 1)
        port.toggleActual(around: .zero, image: big, in: view)
        precondition(port.zoom == nil && port.offset == .zero)
        print("zoom stays between a quarter of fit and 1600 percent, double click toggles 100 percent: ok")

        port = ImageViewport()
        let anchor = CGPoint(x: 100, y: 50)
        port.set(1, around: anchor, image: big, in: view)
        precondition(port.offset == CGSize(width: -400, height: -200), "\(port.offset)")
        port.pan(by: CGSize(width: 99999, height: -99999), image: big, in: view)
        precondition(port.offset == CGSize(width: 1600, height: -1200), "\(port.offset)")
        precondition(port.canPan(big, in: view))
        port.rotate(1)
        precondition(port.offset == .zero)
        port.fitToWindow()
        precondition(!port.canPan(big, in: view))
        port.pan(by: CGSize(width: 50, height: 50), image: big, in: view)
        precondition(port.offset == .zero)
        port.set(1, image: tiny, in: view)
        precondition(!port.canPan(tiny, in: view))
        print("zoom keeps the point under the pointer, panning stops at the edges and only when zoomed: ok")

        precondition(ImageViewport.percent(0.25).contains("25") && ImageViewport.percent(1).contains("100"))
        precondition(ImageList.step(0, by: -1, count: 3, wrap: false) == nil)
        precondition(ImageList.step(2, by: 1, count: 3, wrap: false) == nil)
        precondition(ImageList.step(2, by: 1, count: 3, wrap: true) == 0)
        precondition(ImageList.step(0, by: -1, count: 3, wrap: true) == 2)
        precondition(ImageList.step(0, by: 1, count: 1, wrap: true) == nil)
        precondition(ImageList.step(0, by: 1, count: 0, wrap: true) == nil)
        precondition(ImageList.position(2, of: 12).contains("3") && ImageList.position(2, of: 12).contains("12"))
        print("next and previous stop at the ends, the slideshow wraps, the title reads 3 of 12: ok")

        let dir = FileManager.default.temporaryDirectory.appending(path: "pikapik-test-images-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir.appending(path: "sub"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        for name in ["10.png", "2.png", "a.JPG", "notes.txt", "clip.mkv", "song.mp3", "sub/e.gif", "anim.apng", "logo.svg", "shot.dng", ".hidden.png"] {
            try Data([0]).write(to: dir.appending(path: name))
        }
        let (found, rest) = ImageList.split([dir])
        precondition(found.map(\.lastPathComponent) == ["2.png", "10.png", "a.JPG", "anim.apng", "logo.svg", "shot.dng"], "\(found.map(\.lastPathComponent))")
        precondition(rest.isEmpty)
        let (some, others) = ImageList.split([dir.appending(path: "notes.txt"), dir.appending(path: "2.png"), dir.appending(path: "clip.mkv"), dir.appending(path: "2.png"), dir.appending(path: "sub/e.gif")])
        precondition(some.map(\.lastPathComponent) == ["2.png", "e.gif"] && others.map(\.lastPathComponent) == ["notes.txt", "clip.mkv"])
        precondition(ImageFormats.opens(URL(fileURLWithPath: "/x/y.apng")) && ImageFormats.opens(URL(fileURLWithPath: "/x/y.SVG")) && !ImageFormats.opens(URL(fileURLWithPath: "/x/y.mkv")))
        precondition(Set(ImageFormats.extensions).count == ImageFormats.extensions.count)
        precondition(Set(ImageFormats.extensions).isDisjoint(with: PlayerFormats.extensions))
        precondition(ImageFormats.types.allSatisfy { !$0.isDynamic } && ImageFormats.types.count >= 20)
        print("folders and mixed files are split into pictures in natural order and everything else: ok")
        try FileManager.default.createDirectory(at: dir.appending(path: "folder.png"), withIntermediateDirectories: true)
        let listed = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        precondition(ImageList.neighbours(in: listed).map(\.lastPathComponent) == ["2.png", "10.png", "a.JPG", "anim.apng", "logo.svg", "shot.dng"], "\(ImageList.neighbours(in: listed).map(\.lastPathComponent))")
        try FileManager.default.removeItem(at: dir.appending(path: "folder.png"))
        print("the pictures next to one opened file are listed in natural order, without folders: ok")

        var seen = Set<String>()
        for binding in ImageAction.bindings {
            precondition(seen.insert("\(binding.key)\(binding.modifiers.rawValue)").inserted, "duplicate \(binding)")
            precondition(ImageAction(key: binding.key, modifiers: binding.modifiers) == binding.action)
        }
        precondition(ImageAction(key: "=", modifiers: .command) == .zoomIn && ImageAction(key: "r", modifiers: [.command, .capsLock]) == .rotateRight)
        precondition(ImageAction(key: "r") == nil && ImageAction(key: "f") == nil && ImageAction(key: "q", modifiers: .command) == nil)
        print("keys never clash and only pictures’ own keys are claimed: ok")

        precondition(ImageDetail.pixels(longSide: 1000, backing: 2, screen: 3456, full: 12000) == 3456)
        precondition(ImageDetail.pixels(longSide: 1000, backing: 2, screen: 3456, full: 2000) == 2000)
        precondition(ImageDetail.pixels(longSide: 8000, backing: 2, screen: 3456, full: 12000) == 12000)
        precondition(ImageDetail.pixels(longSide: 8000, backing: 2, screen: 3456, full: 30000) == ImageDetail.limit)
        precondition(ImageDetail.pixels(longSide: 100, backing: 2, screen: 3456, full: 100, vector: true) == 512)
        precondition(ImageDetail.pixels(longSide: 1000, backing: 2, screen: 3456, full: 100, vector: true) == 2048)
        precondition(ImageDetail.pixels(longSide: 90000, backing: 2, screen: 3456, full: 100, vector: true) == ImageDetail.vectorLimit)
        precondition(ImageDetail.oriented(width: 400, height: 300, orientation: 6) == CGSize(width: 300, height: 400))
        precondition(ImageDetail.oriented(width: 400, height: 300, orientation: 3) == CGSize(width: 400, height: 300))
        precondition(ImageDetail.oriented(width: 400, height: 300, orientation: 0) == CGSize(width: 400, height: 300))
        print("a large picture is first decoded to screen size, full size only when zoomed: ok")

        let source = try sample(width: 64, height: 32)
        var written = 0
        for (type, name, orientation) in [(UTType.png, "a.png", 1), (.jpeg, "b.jpg", 6), (.tiff, "c.tif", 8), (.bmp, "d.bmp", 1), (.gif, "e.gif", 1), (.heic, "f.heic", 1), (UTType("public.jpeg-2000")!, "g.jp2", 1)] {
            let url = dir.appending(path: name)
            guard write([source], as: type, to: url, orientation: orientation) else { print("  no writer for \(name), skipped"); continue }
            written += 1
            let turned = (5...8).contains(orientation)
            let probe = try unwrap(ImageDecoder.probe(url), name)
            precondition(probe.size == CGSize(width: turned ? 32 : 64, height: turned ? 64 : 32), "\(name) \(probe.size)")
            precondition(!probe.animated && !probe.vector)
            let full = try unwrap(ImageDecoder.decode(url, probe, maxPixel: probe.longSide), name)
            precondition(max(full.width, full.height) == probe.longSide, "\(name) \(full.width)x\(full.height)")
            precondition(turned == (full.height > full.width), "\(name) orientation not applied")
            let small = try unwrap(ImageDecoder.decode(url, probe, maxPixel: 16), name)
            precondition(max(small.width, small.height) == 16, "\(name) \(small.width)x\(small.height)")
            let data = try Data(contentsOf: url)
            for cut in [0, 1, data.count / 4, data.count / 2, data.count - 1] {
                let broken = dir.appending(path: "broken-\(name)")
                try data.prefix(cut).write(to: broken)
                if let probe = ImageDecoder.probe(broken) { _ = ImageDecoder.decode(broken, probe, maxPixel: 64) }
            }
        }
        precondition(written >= 6, "only \(written) writers")
        print("\(written) formats are read, turned upright and decoded at any size; cut files do not crash: ok")

        let moving = dir.appending(path: "moving.gif")
        let second = try sample(width: 64, height: 32, hue: 0.5)
        precondition(write([source, second], as: .gif, to: moving, orientation: 1))
        precondition(ImageDecoder.probe(moving)?.animated == true)
        precondition(ImageDecoder.probe(dir.appending(path: "e.gif"))?.animated == false)
        print("an animated picture is told apart from a still one: ok")

        let vector = dir.appending(path: "v.svg")
        try #"<svg xmlns="http://www.w3.org/2000/svg" width="120" height="60"><rect width="120" height="60" fill="red"/></svg>"#.write(to: vector, atomically: true, encoding: .utf8)
        let svg = try unwrap(ImageDecoder.probe(vector), "svg")
        precondition(svg.vector && svg.size == CGSize(width: 120, height: 60), "\(svg.size)")
        let drawn = try unwrap(ImageDecoder.decode(vector, svg, maxPixel: 480), "svg")
        precondition(drawn.width == 480 && drawn.height == 240, "\(drawn.width)x\(drawn.height)")
        print("vector pictures are drawn sharp at the size asked for: ok")

        let garbage = dir.appending(path: "garbage.jpg")
        try Data((0..<4096).map { UInt8(truncatingIfNeeded: $0 &* 31 &+ 7) }).write(to: garbage)
        let empty = dir.appending(path: "empty.png")
        try Data().write(to: empty)
        let badSVG = dir.appending(path: "bad.svg")
        try Data("not a picture".utf8).write(to: badSVG)
        for url in [garbage, empty, badSVG, dir.appending(path: "missing.tif"), dir] {
            precondition(ImageDecoder.probe(url) == nil, "\(url.lastPathComponent) should not open")
        }
        print("damaged, empty and missing files are refused without a crash: ok")
    }

    static func unwrap<T>(_ value: T?, _ name: String) throws -> T {
        guard let value else { fatalError("\(name) did not decode") }
        return value
    }

    static func sample(width: Int, height: Int, hue: CGFloat = 0.1) throws -> CGImage {
        let context = try unwrap(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue), "context")
        context.setFillColor(NSColor(hue: hue, saturation: 0.8, brightness: 0.9, alpha: 1).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width / 4, height: height / 4))
        return try unwrap(context.makeImage(), "image")
    }

    static func write(_ images: [CGImage], as type: UTType, to url: URL, orientation: Int) -> Bool {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, type.identifier as CFString, images.count, nil) else { return false }
        for image in images {
            CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: orientation] as CFDictionary)
        }
        return CGImageDestinationFinalize(destination)
    }
}
