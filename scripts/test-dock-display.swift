import CoreGraphics

@main
struct TestDockDisplay {
    static func main() {
        let laptop = DockFence.Display(id: 1, frame: CGRect(x: 0, y: 0, width: 1512, height: 982))
        let right = DockFence.Display(id: 2, frame: CGRect(x: 1512, y: 0, width: 1920, height: 1080))
        let below = DockFence.Display(id: 3, frame: CGRect(x: 0, y: 982, width: 1512, height: 982))
        let side = [laptop, right]

        let hit = DockFence.pressing(CGPoint(x: 2400, y: 1079), side)
        precondition(hit?.display.id == 2 && hit?.edge == .bottom)
        precondition(DockFence.away(CGPoint(x: 2400, y: 1079), from: .bottom, of: right.frame, by: DockFence.gap) == CGPoint(x: 2400, y: 1077))
        precondition(DockFence.pressing(CGPoint(x: 2400, y: 1079.6), side)?.edge == .bottom)
        precondition(DockFence.pressing(CGPoint(x: 2400, y: 1076), side) == nil)
        print("bottom edge of the other display: ok")

        precondition(DockFence.pressing(CGPoint(x: 1515, y: 1079), side) == nil)
        precondition(DockFence.pressing(CGPoint(x: 3429, y: 1079), side) == nil)
        print("hot corners stay free: ok")

        precondition(DockFence.pressing(CGPoint(x: 700, y: 981), [laptop, below]) == nil)
        precondition(DockFence.pressing(CGPoint(x: 700, y: 1963), [laptop, below])?.display.id == 3)
        precondition(DockFence.pressing(CGPoint(x: 1511, y: 500), side) == nil)
        precondition(DockFence.pressing(CGPoint(x: 1512, y: 500), side) == nil)
        precondition(DockFence.pressing(CGPoint(x: 0, y: 500), side)?.edge == .left)
        precondition(DockFence.pressing(CGPoint(x: 3431, y: 500), side)?.edge == .right)
        precondition(DockFence.away(CGPoint(x: 0, y: 500), from: .left, of: laptop.frame, by: 6) == CGPoint(x: 6, y: 500))
        precondition(DockFence.pressing(CGPoint(x: 700, y: 400), side) == nil)
        print("edges shared with another display and side edges: ok")

        precondition(DockFence.dock([(1, 0, 0, 0), (2, 56, 0, 0)]).map { $0.id == 2 && $0.edge == .bottom } == true)
        precondition(DockFence.dock([(1, 0, 4, 0)]).map { $0.id == 1 && $0.edge == .left } == true)
        precondition(DockFence.dock([(1, 0, 0, 0.25), (2, 0, 0, 0)]) == nil)
        print("finding the Dock, hidden or not: ok")

        precondition(DockFence.spot(on: right, edge: .bottom, side) == CGPoint(x: 2472, y: 1079))
        precondition(DockFence.spot(on: laptop, edge: .bottom, [laptop, below]) == nil)
        let wide = DockFence.Display(id: 4, frame: CGRect(x: 0, y: 982, width: 1000, height: 600))
        precondition(DockFence.spot(on: laptop, edge: .bottom, [laptop, wide]) == CGPoint(x: 1512 * 0.8, y: 981))
        print("a spot to bring the Dock back: ok")
    }
}
