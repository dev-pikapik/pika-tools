import CoreGraphics

struct BallPhysics {
    static let radius: CGFloat = 7
    static let bounce: CGFloat = 0.7
    static let wall: CGFloat = 0.75
    static let rolling: CGFloat = 70
    static let springy: CGFloat = 0.4
    static let grip: CGFloat = 0.4
    static let chip: CGFloat = 0.3
    static let fastest: CGFloat = 1400
    static let nudge: CGFloat = 120
    static let tick = 1.0 / 240

    private(set) var bounds: CGRect
    private(set) var center: CGPoint
    private(set) var vx: CGFloat = 0
    private(set) var vy: CGFloat = 0
    private(set) var spin: CGFloat = 0
    private(set) var angle: CGFloat = 0
    private(set) var held = false
    private(set) var thrown = false
    private(set) var nudged = false
    private(set) var impact: CGFloat = 0
    private(set) var previous = CGRect.null
    var roof = CGFloat.infinity
    var ledge: CGRect?
    var dock: CGRect?
    private var cursor: CGRect?
    private var trail = Trail()
    private var age = 0.0
    private var supported = false

    init(bounds: CGRect, x: CGFloat) {
        self.bounds = bounds
        center = CGPoint(x: x, y: bounds.minY + Self.radius)
        resize(bounds)
    }

    var frame: CGRect {
        CGRect(x: center.x - Self.radius, y: center.y - Self.radius, width: 2 * Self.radius, height: 2 * Self.radius)
    }

    var aloft: Bool { held || thrown }

    var resting: Bool { !aloft && vx == 0 && vy == 0 }

    var floor: CGFloat {
        guard let ledge, frame.minY >= ledge.maxY - 0.5, ledge.minX...ledge.maxX ~= center.x else { return bounds.minY }
        return ledge.maxY
    }

    func touches(_ point: CGPoint) -> Bool {
        PetPhysics.touches(point, previous, frame)
    }

    mutating func step(_ dt: Double, cursor point: CGPoint?, body: (CGRect, CGRect)? = nil) {
        let next = point.map(PetPhysics.cursorRect)
        let last = cursor ?? next
        let dt = min(max(dt, 0), 0.25)
        previous = frame
        nudged = false
        impact = 0
        let n = Int((dt / Self.tick).rounded(.up))
        for i in 0..<n {
            let s0 = CGFloat(i) / CGFloat(n), s1 = CGFloat(i + 1) / CGFloat(n)
            var pointer: (CGRect, CGRect)?
            if let last, let next { pointer = (PetPhysics.mix(last, next, s0), PetPhysics.mix(last, next, s1)) }
            advance(dt / Double(n), pointer, body.map { (PetPhysics.mix($0.0, $0.1, s0), PetPhysics.mix($0.0, $0.1, s1)) })
        }
        cursor = next
    }

    mutating func kick(_ v: CGVector) {
        (vx, vy) = Trail.limit(v.dx, v.dy, Self.fastest)
        spin = -vx / Self.radius
    }

    @discardableResult
    mutating func grab(at point: CGPoint) -> Bool {
        guard !held, touches(point) else { return false }
        held = true
        thrown = false
        (vx, vy, spin) = (0, 0, 0)
        trail = Trail()
        hang(point)
        previous = frame
        return true
    }

    mutating func release() {
        guard held else { return }
        held = false
        thrown = true
        (vx, vy) = Trail.limit(vx, vy, PetPhysics.fling)
    }

    mutating func resize(_ bounds: CGRect) {
        self.bounds = bounds
        center.x = min(max(center.x, bounds.minX + Self.radius), bounds.maxX - Self.radius)
        center.y = min(max(center.y, bounds.minY + Self.radius), bounds.maxY - Self.radius)
        cursor = nil
        previous = frame
    }

    private mutating func advance(_ h: Double, _ pointer: (CGRect, CGRect)?, _ body: (CGRect, CGRect)?) {
        age += h
        if held {
            if let pointer { hang(CGPoint(x: pointer.1.minX, y: pointer.1.maxY)) }
            (vx, vy) = trail.velocity(center, at: age)
            return
        }
        let h = CGFloat(h), a0 = frame
        supported = false
        vy -= PetPhysics.gravity * h
        center.x += vx * h
        center.y += vy * h
        angle += spin * h
        if case let (b0, b1)? = pointer, hypot(b1.midX - b0.midX, b1.midY - b0.midY) >= Self.nudge * h, let push = hit(a0, b0, b1, h) {
            nudged = true
            if abs(push.0) > abs(push.1), frame.minY - floor < 2 { vy += Self.chip * abs(push.0) }
            (vx, vy) = Trail.limit(vx, vy, Self.fastest)
        }
        if case let (p0, p1)? = body, let push = hit(a0, p0, p1, h) {
            impact = max(impact, hypot(push.0, push.1))
        }
        if let ledge { collide(ledge) }
        if !thrown, let dock { collide(CGRect(x: dock.minX, y: dock.maxY, width: dock.width, height: max(bounds.maxY - dock.maxY, 0) + 2 * Self.radius)) }
        let top = thrown ? bounds.maxY : min(bounds.maxY, roof)
        if center.y + Self.radius > top {
            center.y = top - Self.radius
            if vy > 0 { vy = -vy * Self.bounce }
        }
        if center.y - Self.radius < bounds.minY {
            center.y = bounds.minY + Self.radius
            contact((0, 1))
        }
        if center.x - Self.radius < bounds.minX {
            center.x = bounds.minX + Self.radius
            if vx < 0 { vx = -vx * Self.wall }
        } else if center.x + Self.radius > bounds.maxX {
            center.x = bounds.maxX - Self.radius
            if vx > 0 { vx = -vx * Self.wall }
        }
        guard supported else { return }
        if abs(vx + spin * Self.radius) < 1 {
            vx = vx > 0 ? max(0, vx - Self.rolling * h) : min(0, vx + Self.rolling * h)
            spin = -vx / Self.radius
        }
        if abs(vx) < 3, abs(vy) < 1, abs(spin) * Self.radius < 3 { (vx, vy, spin) = (0, 0, 0) }
    }

    private mutating func hit(_ a0: CGRect, _ b0: CGRect, _ b1: CGRect, _ h: CGFloat) -> (CGFloat, CGFloat)? {
        guard let t = PetPhysics.sweep(a0, frame, b0, b1) else { return nil }
        let a = PetPhysics.mix(a0, frame, t), b = PetPhysics.mix(b0, b1, t)
        let dx = a.midX - b.midX, dy = a.midY - b.midY
        let gx = abs(dx) - (a.width + b.width) / 2, gy = abs(dy) - (a.height + b.height) / 2
        let n: (CGFloat, CGFloat) = gx > gy ? (dx < 0 ? -1 : 1, 0) : (0, dy < 0 ? -1 : 1)
        center = CGPoint(x: a.midX, y: a.midY)
        if n.0 > 0 { center.x = max(center.x, b1.maxX + Self.radius) }
        if n.0 < 0 { center.x = min(center.x, b1.minX - Self.radius) }
        if n.1 > 0 { center.y = max(center.y, b1.maxY + Self.radius) }
        if n.1 < 0 { center.y = min(center.y, b1.minY - Self.radius) }
        let rn = (vx - (b1.midX - b0.midX) / h) * n.0 + (vy - (b1.midY - b0.midY) / h) * n.1
        guard rn < 0 else { return (0, 0) }
        let push = (-(1 + Self.springy) * rn * n.0, -(1 + Self.springy) * rn * n.1)
        vx += push.0
        vy += push.1
        return push
    }

    private mutating func collide(_ ledge: CGRect) {
        let p = CGPoint(x: min(max(center.x, ledge.minX), ledge.maxX), y: min(max(center.y, ledge.minY), ledge.maxY))
        let dx = center.x - p.x, dy = center.y - p.y, d = hypot(dx, dy)
        guard d < Self.radius else { return }
        var n = (dx / d, dy / d)
        if d > 1e-6 {
            center = CGPoint(x: p.x + n.0 * Self.radius, y: p.y + n.1 * Self.radius)
        } else {
            let r = 2 * Self.radius, top = thrown ? bounds.maxY : min(bounds.maxY, roof)
            let exits: [(CGFloat, (CGFloat, CGFloat), Bool)] = [
                (center.x - ledge.minX, (-1, 0), ledge.minX - r >= bounds.minX), (ledge.maxX - center.x, (1, 0), ledge.maxX + r <= bounds.maxX),
                (center.y - ledge.minY, (0, -1), ledge.minY - r >= bounds.minY), (ledge.maxY - center.y, (0, 1), ledge.maxY + r <= top),
            ]
            guard let exit = exits.filter(\.2).min(by: { $0.0 < $1.0 }) else { return }
            n = exit.1
            center.x += n.0 * (exit.0 + Self.radius)
            center.y += n.1 * (exit.0 + Self.radius)
        }
        contact(n)
    }

    private mutating func contact(_ n: (CGFloat, CGFloat)) {
        let rn = vx * n.0 + vy * n.1
        guard rn < 0 else { return }
        let e = -rn < 40 ? 0 : Self.bounce
        vx -= (1 + e) * rn * n.0
        vy -= (1 + e) * rn * n.1
        let slip = vx * n.1 - vy * n.0 + spin * Self.radius
        let limit = Self.grip * (1 + e) * -rn
        let dt = min(max(-0.4 * slip, -limit), limit)
        vx += dt * n.1
        vy -= dt * n.0
        spin += 1.5 * dt / Self.radius
        guard n.1 > 0.7 else { return }
        supported = true
        if thrown, center.y + Self.radius + vy * vy / (2 * PetPhysics.gravity) <= ceiling { thrown = false }
    }

    private var ceiling: CGFloat {
        guard let dock, frame.minX < dock.maxX, frame.maxX > dock.minX else { return min(bounds.maxY, roof) }
        return min(bounds.maxY, roof, dock.maxY)
    }

    private mutating func hang(_ point: CGPoint) {
        center = CGPoint(
            x: min(max(point.x, bounds.minX + Self.radius), bounds.maxX - Self.radius),
            y: min(max(point.y, bounds.minY + Self.radius), bounds.maxY - Self.radius)
        )
    }
}
