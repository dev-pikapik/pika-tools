import SwiftUI

enum PetStage { static let scale: CGFloat = 2.4 }

@main
enum TestPetMarks {
    static let side: CGFloat = 4, gap: CGFloat = 0.4
    static let size = CGSize(width: 48 * side, height: 58 * side)

    static func mask(_ paths: [Path]) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: Int(size.width * size.height))
        data.withUnsafeMutableBytes { raw in
            let ctx = CGContext(data: raw.baseAddress, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width), space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)!
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: side, y: -side)
            ctx.translateBy(x: 24, y: 52)
            ctx.setFillColor(gray: 1, alpha: 1)
            for path in paths { ctx.addPath(path.cgPath); ctx.fillPath() }
        }
        return data
    }

    static func touches(_ pose: PetPose, _ mark: PetMark) -> Bool {
        let env = EnvironmentValues()
        func fills(_ pose: PetPose) -> [(Path, Color)] {
            var all: [(Path, Color)] = []
            PetFigure.draw(pose, night: false) { all.append(($0, $1)) }
            return all.filter { $0.1.resolve(in: env).opacity > 0.4 }
        }
        var bare = pose, marked = pose
        bare.face = PetFace()
        marked.face = PetFace(mark: mark, glow: 1)
        let rest = fills(bare), all = fills(marked)
        let near = all[rest.count...].map { $0.0.union($0.0.strokedPath(StrokeStyle(lineWidth: 2 * gap, lineCap: .round, lineJoin: .round))) }
        return zip(mask(rest.map(\.0)), mask(near)).contains { $0 > 127 && $1 > 127 }
    }

    static func main() {
        let marks: [PetMark] = [.heart, .sparkles, .ask, .bang, .drop, .puff, .zzz]
        let poses: [(String, (inout PetPose) -> Void)] = [
            ("stand", { $0.step = 0 }),
            ("sit", { $0.sit = 1 }),
            ("jump", { $0.air = true; $0.lift = 9; $0.squash = -0.09 }),
            ("held", { $0.air = true; $0.hang = true; $0.squash = -0.05; $0.tilt = 0.07; $0.lift = 6 }),
        ]
        var count = 0
        for item in [nil] + PetItem.allCases.filter({ $0.slot == .head || $0.slot == .back }).map(Optional.init) {
            for (name, tweak) in poses {
                for facing in [CGFloat(1), -1] {
                    for mark in marks {
                        var pose = PetPose(outfit: item.map { [$0.slot: $0] } ?? [:])
                        tweak(&pose)
                        pose.facing = facing
                        precondition(!touches(pose, mark), "\(mark) touches \(item?.rawValue ?? "the bare pet") while \(name), facing \(facing)")
                        count += 1
                    }
                }
            }
        }
        print("marks stay \(gap) away from the pet and its hats in \(count) poses: ok")
    }
}
