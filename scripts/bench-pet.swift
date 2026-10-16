import SwiftUI

enum PetStage { static let scale: CGFloat = 2.4 }

struct Cost {
    var flat = Double.infinity, outlined = Double.infinity
    var extra: Double { outlined - flat }
}

struct Row {
    let name: String
    let walk: Cost, idle: Cost, night: Cost
    var worst: Double { max(walk.extra, idle.extra, night.extra) }

    var text: String {
        func part(_ label: String, _ c: Cost) -> String { String(format: "%@ %.4f -> %.4f (%+.4f)", label, c.flat, c.outlined, c.extra) }
        return "\(name.padding(toLength: 14, withPad: " ", startingAt: 0)) \(part("walk", walk))   \(part("idle", idle))   \(part("night walk", night))"
    }
}

@main
enum BenchPet {
    static let frames = 300, rounds = 5, limit = 0.3, lookLimit = 0.5
    static let raster = CommandLine.arguments.contains("raster")
    static let environment = EnvironmentValues()
    static let context = CGContext(data: nil, width: 256, height: 256, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    static let place = CGAffineTransform(translationX: 128, y: 200).scaledBy(x: PetStage.scale, y: -PetStage.scale)
    nonisolated(unsafe) static var sink = 0

    static func milliseconds(_ outfit: [PetSlot: PetItem], walking: Bool, night: Bool, outlined: Bool) -> Double {
        var pose = PetPose()
        pose.outfit = outfit
        let start = DispatchTime.now().uptimeNanoseconds
        for i in 0..<frames {
            if walking {
                pose.step = Double(i) * 0.13
                pose.bounce = CGFloat(i % 7) / 7
            } else {
                pose.blink = i % 2 == 0
                pose.twinkle = Double(i)
            }
            PetFigure.draw(pose, night: night, outlined: outlined) { path, color in
                let shape = path.applying(place).cgPath, c = color.resolve(in: environment)
                sink &+= shape.isEmpty ? 0 : 1
                if raster {
                    context.addPath(shape)
                    context.setFillColor(red: CGFloat(c.red), green: CGFloat(c.green), blue: CGFloat(c.blue), alpha: CGFloat(c.opacity))
                    context.fillPath()
                }
            }
        }
        return Double(DispatchTime.now().uptimeNanoseconds - start) / 1e6 / Double(frames)
    }

    static func cost(_ outfit: [PetSlot: PetItem], walking: Bool, night: Bool) -> Cost {
        var cost = Cost()
        for _ in 0..<rounds {
            cost.flat = min(cost.flat, milliseconds(outfit, walking: walking, night: night, outlined: false))
            cost.outlined = min(cost.outlined, milliseconds(outfit, walking: walking, night: night, outlined: true))
        }
        return cost
    }

    static func main() {
        let items = PetItem.allCases.map { ($0.rawValue, [$0.slot: $0]) }
        let looks = PetLook.all.map { ("look \($0.id)", Dictionary($0.items.map { ($0.slot, $0) }, uniquingKeysWith: { $1 })) }
        _ = cost(items[0].1, walking: true, night: false)
        func measure(_ outfits: [(String, [PetSlot: PetItem])]) -> [Row] {
            outfits.map { Row(name: $0.0, walk: cost($0.1, walking: true, night: false), idle: cost($0.1, walking: false, night: false), night: cost($0.1, walking: true, night: true)) }
        }
        let itemRows = measure(items), lookRows = measure(looks)
        print("ms per frame, \(raster ? "draw, path and colour, raster" : "draw, path and colour"), without outline -> with outline")
        print("worst items:")
        for row in itemRows.sorted(by: { $0.worst > $1.worst }).prefix(5) { print("  " + row.text) }
        print("worst looks:")
        for row in lookRows.sorted(by: { $0.worst > $1.worst }).prefix(3) { print("  " + row.text) }
        if let detective = itemRows.first(where: { $0.name == "detective" }) { print("detective:\n  " + detective.text) }
        let over = itemRows.filter { $0.worst > limit }.map { (limit, $0) } + lookRows.filter { $0.worst > lookLimit }.map { (lookLimit, $0) }
        for (limit, row) in over { print("over \(limit) ms: " + row.text) }
        if !over.isEmpty { exit(1) }
        print("outline adds at most \(limit) ms per frame to each of \(itemRows.count) items and \(lookLimit) ms to each of \(lookRows.count) looks, walking, idle and at night: ok")
    }
}
