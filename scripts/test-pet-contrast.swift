import SwiftUI

enum PetStage { static let scale: CGFloat = 2.4 }

@main
enum TestPetContrast {
    static let side: CGFloat = 6, floor = 1.5, limit = 0.1
    static let width = Int(48 * side), height = Int(58 * side)

    static func linear(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }

    static func light(_ r: Double, _ g: Double, _ b: Double) -> Double { 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b) }

    static func rgba(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let c = color.resolve(in: EnvironmentValues())
        return (Double(c.red), Double(c.green), Double(c.blue), Double(c.opacity))
    }

    static func share(_ pose: PetPose, bare: PetPose, night: Bool, backdrop: Double) -> Double {
        func fills(_ pose: PetPose) -> [(Path, Color)] {
            var all: [(Path, Color)] = []
            PetFigure.draw(pose, night: night) { all.append(($0, $1)) }
            return all
        }
        let own = fills(bare).map { rgba($0.1) }.filter { $0.a > 0.99 }
        var data = [UInt8](repeating: 0, count: width * height * 4)
        data.withUnsafeMutableBytes { raw in
            let ctx = CGContext(data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            ctx.setShouldAntialias(false)
            ctx.translateBy(x: 0, y: CGFloat(height))
            ctx.scaleBy(x: side, y: -side)
            ctx.translateBy(x: 24, y: 52)
            for (path, color) in fills(pose) {
                let c = rgba(color)
                ctx.setFillColor(red: c.r, green: c.g, blue: c.b, alpha: c.a)
                ctx.addPath(path.cgPath)
                ctx.fillPath()
            }
        }
        func covered(_ x: Int, _ y: Int) -> Bool { x >= 0 && y >= 0 && x < width && y < height && data[(y * width + x) * 4 + 3] > 0 }
        let ground = light(backdrop, backdrop, backdrop)
        var edge = 0, low = 0
        for y in 0..<height {
            for x in 0..<width where covered(x, y) && !(covered(x - 1, y) && covered(x + 1, y) && covered(x, y - 1) && covered(x, y + 1)) {
                let i = (y * width + x) * 4, a = Double(data[i + 3]) / 255
                let px = (0..<3).map { Double(data[i + $0]) / 255 + (1 - a) * backdrop }
                if a > 0.99, own.contains(where: { abs($0.r - px[0]) + abs($0.g - px[1]) + abs($0.b - px[2]) < 0.02 }) { continue }
                let l = light(px[0], px[1], px[2])
                edge += 1
                if (max(l, ground) + 0.05) / (min(l, ground) + 0.05) < floor { low += 1 }
            }
        }
        return edge == 0 ? 0 : Double(low) / Double(edge)
    }

    static func main() {
        let dark = CommandLine.arguments.contains("dark")
        let backdrop = dark ? 30.0 / 255 : 1
        let poses: [(String, (inout PetPose) -> Void)] = [
            ("walk", { $0.step = 0.9; $0.bounce = 1 }),
            ("sit", { $0.sit = 1 }),
            ("air", { $0.air = true; $0.lift = 9; $0.squash = -0.09 }),
        ]
        var worst: [String: (Double, String)] = [:], count = 0
        func measure(_ name: String, _ dress: (inout PetPose) -> Void) {
            for (pose, tweak) in poses {
                for facing in [CGFloat(1), -1] {
                    var bare = PetPose()
                    tweak(&bare)
                    bare.facing = facing
                    var dressed = bare
                    dress(&dressed)
                    let value = share(dressed, bare: bare, night: dark, backdrop: backdrop)
                    if value > worst[name]?.0 ?? -1 { worst[name] = (value, pose) }
                    count += 1
                }
            }
        }
        for item in PetItem.allCases { measure(item.rawValue) { $0.outfit = [item.slot: item] } }
        for mark in PetMark.allCases where mark != .none { measure("mark \(mark)") { $0.face = PetFace(mark: mark, glow: 1) } }

        let ranked = worst.sorted { $0.value.0 > $1.value.0 }
        if dark || CommandLine.arguments.contains("table") {
            for (key, (value, pose)) in ranked.prefix(8) { print(String(format: "%5.1f%%  %@, %@", value * 100, key, pose)) }
        }
        if dark { return }
        let failed = ranked.filter { $0.value.0 > limit }
        for (key, (value, pose)) in failed {
            print("\(key) while \(pose): \(Int((value * 100).rounded()))% of its outline is below \(floor):1 on white, at most \(Int(limit * 100))% is allowed")
        }
        if !failed.isEmpty { exit(1) }
        print("outlines of \(worst.count) items and marks stay readable on white in \(count) poses: ok")
    }
}
