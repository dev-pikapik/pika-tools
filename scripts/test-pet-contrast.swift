import SwiftUI

enum PetStage { static let scale: CGFloat = 2.4 }

@main
enum TestPetContrast {
    static let side: CGFloat = 6, floor = 3.0, limit = 0.1, deep = 2, thick = 3
    static let width = Int(48 * side), height = Int(58 * side)
    static let backdrops: [(name: String, level: Double)] = [("#FFF", 1), ("#1E1E1E", 30.0 / 255)]
    static let steps = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    static func linear(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }

    static func light(_ r: Double, _ g: Double, _ b: Double) -> Double { 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b) }

    static func rgba(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let c = color.resolve(in: EnvironmentValues())
        return (Double(c.red), Double(c.green), Double(c.blue), Double(c.opacity))
    }

    static func share(_ pose: PetPose, bare: PetPose, night: Bool, backdrop: Double, runs: inout [Int]) -> Double {
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
        func contrast(_ x: Int, _ y: Int) -> Double? {
            guard covered(x, y) else { return nil }
            let i = (y * width + x) * 4, a = Double(data[i + 3]) / 255
            let px = (0..<3).map { Double(data[i + $0]) / 255 + (1 - a) * backdrop }
            if a > 0.99, own.contains(where: { abs($0.r - px[0]) + abs($0.g - px[1]) + abs($0.b - px[2]) < 0.02 }) { return nil }
            let l = light(px[0], px[1], px[2])
            return (max(l, ground) + 0.05) / (min(l, ground) + 0.05)
        }
        let rim = rgba(PetClothes.rim)
        func isRim(_ x: Int, _ y: Int) -> Bool {
            let i = (y * width + x) * 4
            return covered(x, y) && data[i + 3] == 255 && (0..<3).allSatisfy { abs(Double(data[i + $0]) / 255 - [rim.r, rim.g, rim.b][$0]) < 0.01 }
        }
        func run(_ x: Int, _ y: Int, _ out: (Int, Int)) -> Int {
            var n = 0
            while isRim(x - n * out.0, y - n * out.1) { n += 1 }
            return n
        }
        var edge = 0, low = 0
        for y in 0..<height {
            for x in 0..<width where covered(x, y) {
                guard let out = steps.first(where: { !covered(x + $0.0, y + $0.1) }), contrast(x, y) != nil else { continue }
                edge += 1
                let onRim = isRim(x, y)
                if onRim { runs.append(run(x, y, out)) }
                if contrast(x, y)! < floor || (onRim && (1..<deep).contains { (contrast(x - $0 * out.0, y - $0 * out.1) ?? floor) < floor }) { low += 1 }
            }
        }
        return edge == 0 ? 0 : Double(low) / Double(edge)
    }

    static func main() {
        let poses: [(String, (inout PetPose) -> Void)] = [
            ("walk", { $0.step = 0.9; $0.bounce = 1 }),
            ("sit", { $0.sit = 1 }),
            ("air", { $0.air = true; $0.lift = 9; $0.squash = -0.09 }),
        ]
        var worst: [String: [(Double, String)]] = [:], count = 0, runs: [Int] = []
        func measure(_ name: String, _ dress: (inout PetPose) -> Void) {
            worst[name] = backdrops.map { _ in (0, "") }
            for (pose, tweak) in poses {
                for facing in [CGFloat(1), -1] {
                    var bare = PetPose()
                    tweak(&bare)
                    bare.facing = facing
                    var dressed = bare
                    dress(&dressed)
                    for night in [false, true] {
                        for (i, backdrop) in backdrops.enumerated() {
                            let value = share(dressed, bare: bare, night: night, backdrop: backdrop.level, runs: &runs)
                            if value > worst[name]![i].0 { worst[name]![i] = (value, "\(pose), \(night ? "night" : "day")") }
                            count += 1
                        }
                    }
                }
            }
        }
        for item in PetItem.allCases { measure(item.rawValue) { $0.outfit = [item.slot: item] } }
        for mark in PetMark.allCases where mark != .none { measure("mark \(mark)") { $0.face = PetFace(mark: mark, glow: 1) } }

        let ranked = worst.sorted { ($0.value.map(\.0).max() ?? 0) > ($1.value.map(\.0).max() ?? 0) }
        let failed = ranked.filter { $0.value.contains { $0.0 > limit } }
        let wide = runs.sorted().dropFirst(runs.count / 2).first ?? 0, fits = (deep...thick).contains(wide)
        let pt = String(format: "%.1f", PetClothes.stroke.lineWidth / 2 * PetStage.scale)
        if failed.isEmpty && fits && !CommandLine.arguments.contains("table") {
            print("outlines of \(worst.count) items and marks keep \(Int(floor)):1 on white and on #1E1E1E and stick out \(wide) render px (scale \(Int(side)), about \(pt) pt on screen), in \(count) renders: ok")
            return
        }
        print("share of the outline below \(Int(floor)):1 in its first \(deep) render px, per backdrop (\(backdrops.map(\.name).joined(separator: ", ")))")
        for (key, values) in failed.isEmpty ? Array(ranked.prefix(5)) : failed {
            print(values.map { String(format: "%5.1f%%", $0.0 * 100) }.joined(separator: " ") + "  " + key + " (" + values.map(\.1).joined(separator: "; ") + ")")
        }
        print("outline sticks out \(wide) render px at scale \(Int(side)) (median, about \(pt) pt on screen)")
        if !failed.isEmpty { print("at most \(Int(limit * 100))% of an outline may be below \(Int(floor)):1 in its first \(deep) render px on either backdrop") }
        if !fits { print("the outline must stick out \(deep) to \(thick) render px") }
        if !failed.isEmpty || !fits { exit(1) }
    }
}
