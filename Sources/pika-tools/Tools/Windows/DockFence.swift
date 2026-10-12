import CoreGraphics

/// Where a push of the pointer would carry the Dock to another display, and where to step back to.
/// Frames are in global display coordinates: the origin is the top left of the main display and y grows down.
enum DockFence {
    enum Edge { case bottom, left, right }

    struct Display {
        let id: CGDirectDisplayID
        let frame: CGRect
    }

    /// How close to an edge counts as touching it, how much of each end stays free for hot corners,
    /// and how far the pointer steps back.
    static let reach: CGFloat = 2, corner: CGFloat = 8, gap: CGFloat = 3

    /// The display and edge the Dock takes room on: the biggest cut from a display's usable area.
    /// A hidden Dock still keeps a few points.
    static func dock(_ cuts: [(id: CGDirectDisplayID, bottom: CGFloat, left: CGFloat, right: CGFloat)]) -> (id: CGDirectDisplayID, edge: Edge)? {
        var best: (id: CGDirectDisplayID, edge: Edge, size: CGFloat)?
        for cut in cuts {
            for (edge, size) in [(Edge.bottom, cut.bottom), (.left, cut.left), (.right, cut.right)] where size > max(0.5, best?.size ?? 0) {
                best = (cut.id, edge, size)
            }
        }
        return best.map { ($0.id, $0.edge) }
    }

    /// The display whose outer edge the pointer is pressing against. An edge that touches another display doesn't count.
    static func pressing(_ point: CGPoint, _ displays: [Display]) -> (display: Display, edge: Edge)? {
        guard let display = displays.first(where: { $0.frame.contains(point) })
            ?? displays.first(where: { $0.frame.insetBy(dx: -1, dy: -1).contains(point) }) else { return nil }
        let frame = display.frame
        func free(_ outside: CGPoint) -> Bool { !displays.contains { $0.frame.contains(outside) } }
        let alongX = point.x > frame.minX + corner && point.x < frame.maxX - corner
        let alongY = point.y > frame.minY + corner && point.y < frame.maxY - corner
        if alongX, frame.maxY - point.y < reach, free(CGPoint(x: point.x, y: frame.maxY)) { return (display, .bottom) }
        if alongY, point.x - frame.minX < reach, free(CGPoint(x: frame.minX - 1, y: point.y)) { return (display, .left) }
        if alongY, frame.maxX - point.x < reach, free(CGPoint(x: frame.maxX, y: point.y)) { return (display, .right) }
        return nil
    }

    static func away(_ point: CGPoint, from edge: Edge, of frame: CGRect, by gap: CGFloat) -> CGPoint {
        switch edge {
        case .bottom: CGPoint(x: point.x, y: frame.maxY - gap)
        case .left: CGPoint(x: frame.minX + gap, y: point.y)
        case .right: CGPoint(x: frame.maxX - gap, y: point.y)
        }
    }

    /// A point on the display's outer edge where a push brings the Dock there.
    static func spot(on display: Display, edge: Edge, _ displays: [Display]) -> CGPoint? {
        let frame = display.frame
        return [0.5, 0.35, 0.65, 0.2, 0.8].lazy.map { share -> CGPoint in
            switch edge {
            case .bottom: CGPoint(x: frame.minX + frame.width * share, y: frame.maxY - 1)
            case .left: CGPoint(x: frame.minX, y: frame.minY + frame.height * share)
            case .right: CGPoint(x: frame.maxX - 1, y: frame.minY + frame.height * share)
            }
        }.first { point in
            pressing(point, displays).map { $0.display.id == display.id && $0.edge == edge } ?? false
        }
    }
}
