import CoreGraphics
import Foundation

@main
enum TestGameAppStore {
    static func main() {
        let frame = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let gap = GameRules.cornerGap
        let pixels = [CGPoint(x: 0, y: 0), CGPoint(x: 1439, y: 0), CGPoint(x: 0, y: 899), CGPoint(x: 1439, y: 899)]
        let inside = [CGPoint(x: 1, y: 1), CGPoint(x: 1438, y: 1), CGPoint(x: 1, y: 898), CGPoint(x: 1438, y: 898)]
        for corner in 0..<4 {
            for start in [pixels[corner], inside[corner]] {
                let point = GameRules.fenceCorners(start, in: frame) ?? start
                precondition(abs(point.x - pixels[corner].x) + abs(point.y - pixels[corner].y) >= gap, "corner \(corner) from \(start): \(point)")
                precondition(point.x >= 1 && point.x <= 1438 && point.y >= 1 && point.y <= 898, "corner \(corner) from \(start): \(point)")
            }
            precondition(GameRules.fenceCorners(pixels[corner], in: frame) != nil)
        }
        if gap > 0 {
            precondition(GameRules.fenceCorners(CGPoint(x: 8, y: 8), in: frame) == nil)
            precondition(GameRules.fenceCorners(CGPoint(x: 7, y: 8), in: frame) != nil)
            precondition(GameRules.fenceCorners(CGPoint(x: 1431, y: 891), in: frame) == nil)
            precondition(GameRules.fenceCorners(CGPoint(x: 1432, y: 891), in: frame) != nil)
        }
        print("corners: ok")

        precondition(GameRules.fenceCorners(CGPoint(x: 720, y: 450), in: frame) == nil)
        precondition(GameRules.fenceCorners(CGPoint(x: 700, y: 0), in: frame) == CGPoint(x: 700, y: 1))
        precondition(GameRules.fenceCorners(CGPoint(x: 1439, y: 450), in: frame) == CGPoint(x: 1438, y: 450))
        print("edges: ok")

        precondition(GameRules.fenceCorners(CGPoint(x: 0, y: 0), in: frame, corners: [0]) == nil)
        precondition(GameRules.fenceCorners(CGPoint(x: 0, y: 0), in: frame, corners: [0, 1, 2, 3]) == nil)
        let other = GameRules.fenceCorners(CGPoint(x: 1439, y: 0), in: frame, corners: [0]) ?? CGPoint(x: 1439, y: 0)
        precondition(abs(other.x - 1439) + abs(other.y) >= gap)
        print("allowed corners: ok")

        let before = GameModeTool.screenLocked
        GameModeTool.shared.received("com.apple.screenIsLocked")
        #if APPSTORE
        precondition(GameModeTool.screenLocked)
        #endif
        precondition(!GameModeTool.shared.isPlaying)
        GameModeTool.shared.received("com.apple.screenIsUnlocked")
        precondition(GameModeTool.screenLocked == before)
        print("lock: ok")
    }
}
