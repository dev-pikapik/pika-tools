import AppKit
import SwiftUI

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let source = root.appendingPathComponent("Resources/AppIcon.icon")
let output = root.appendingPathComponent("Resources/AppIcon.icns")

func color(_ spec: String) -> NSColor {
    let parts = spec.split(separator: ":")
    let c = parts[1].split(separator: ",").map { CGFloat(Double($0)!) }
    let space: NSColorSpace = parts[0] == "display-p3" ? .displayP3 : .sRGB
    return NSColor(colorSpace: space, components: c, count: 4)
}

let json = try JSONSerialization.jsonObject(with: Data(contentsOf: source.appendingPathComponent("icon.json"))) as! [String: Any]
let args = CommandLine.arguments
let preview = args.count == 4 && args[1] == "--preview" ? (dark: args[2] == "dark", path: args[3]) : nil
let dark = preview?.dark ?? false
let fills = json["fill-specializations"] as! [[String: Any]]
let fill = fills.first { ($0["appearance"] as? String) == (dark ? "dark" : nil) }!["value"] as! [String: Any]
let background = NSGradient(colors: (fill["linear-gradient"] as! [String]).map(color))!
let layers = (json["groups"] as! [[String: Any]])
    .flatMap { $0["layers"] as! [[String: Any]] }
    .reversed()
    .map { ($0["name"] as! String, NSImage(contentsOf: source.appendingPathComponent("Assets/\($0["image-name"] as! String)"))!) }

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    ctx.imageInterpolation = .high
    NSGraphicsContext.current = ctx
    let cg = ctx.cgContext
    let k = CGFloat(px) / 1024
    cg.scaleBy(x: k, y: k)

    let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
    let shape = RoundedRectangle(cornerRadius: 185.4, style: .continuous).path(in: tile).cgPath

    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: -10 * k), blur: 20 * k, color: NSColor(white: 0, alpha: 0.3).cgColor)
    cg.addPath(shape)
    cg.setFillColor(.black)
    cg.fillPath()
    cg.restoreGState()

    cg.saveGState()
    cg.addPath(shape)
    cg.clip()
    background.draw(in: tile, angle: -90)
    NSGradient(colors: [NSColor(white: 1, alpha: 0.12), NSColor(white: 1, alpha: 0)])!
        .draw(in: CGRect(x: 100, y: 512, width: 824, height: 412), angle: -90)

    cg.setShadow(offset: CGSize(width: 0, height: -14 * k), blur: 28 * k,
                 color: NSColor(white: 0, alpha: dark ? 0.5 : 0.22).cgColor)
    cg.beginTransparencyLayer(auxiliaryInfo: nil)
    if px <= 32 {
        cg.translateBy(x: 512, y: 512)
        cg.scaleBy(x: 1.3, y: 1.3)
        cg.translateBy(x: -556, y: -437)
        layers.first { $0.0 == "arrow" }!.1.draw(in: tile)
    } else {
        for layer in layers { layer.1.draw(in: tile) }
    }
    cg.endTransparencyLayer()
    cg.restoreGState()

    cg.addPath(shape)
    cg.setStrokeColor(dark ? NSColor(white: 1, alpha: 0.18).cgColor : NSColor(white: 0, alpha: 0.12).cgColor)
    cg.setLineWidth(max(2, 1 / k))
    cg.strokePath()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

if let preview {
    try render(1024).write(to: URL(fileURLWithPath: preview.path))
    exit(0)
}

let iconset = FileManager.default.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    try render(size).write(to: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
    try render(size * 2).write(to: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconset.path, "-o", output.path]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else { exit(1) }
print("Done: \(output.path)")
print("Iconset: \(iconset.path)")
