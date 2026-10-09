import CoreGraphics

struct PetPhysics {
    enum State { case walk, turn, jump, tumble, lie, getUp, sit, held, thrown }

    static let size = CGSize(width: 30, height: 32)
    static let pointer = CGSize(width: 16, height: 22)
    static let gravity: CGFloat = 1000
    static let hop: CGFloat = 44
    static let highest: CGFloat = 110
    static let reach: CGFloat = 48
    static let margin: CGFloat = 4
    static let fling: CGFloat = 1800
    static let scruff: CGFloat = 6
    static let shyness = 1.0
    static let tick = 1.0 / 120

    private(set) var bounds: CGRect
    private(set) var origin: CGPoint
    private(set) var facing: CGFloat
    private(set) var heading: CGFloat
    private(set) var state = State.walk
    private(set) var clock = 0.0
    private(set) var hold = 0.0
    private(set) var landed = Double.infinity
    private(set) var walked: CGFloat = 0
    private(set) var vx: CGFloat = 0
    private(set) var vy: CGFloat = 0
    private(set) var shy = 0.0
    var calm = false
    private var cursor: CGRect?
    private var armed = true
    private var mark = CGRect.null
    private var previous = CGRect.null
    private var age = 0.0
    private var trail: [(time: Double, point: CGPoint)] = []

    init(bounds: CGRect, x: CGFloat? = nil, facing: CGFloat = 1) {
        self.bounds = bounds
        origin = CGPoint(x: x ?? bounds.midX, y: bounds.minY)
        self.facing = facing
        heading = facing
        resize(bounds)
    }

    var frame: CGRect {
        CGRect(x: origin.x - Self.size.width / 2, y: origin.y, width: Self.size.width, height: Self.size.height)
    }

    var pace: CGFloat { calm ? 22 : 36 }

    var grounded: Bool { state != .jump && state != .tumble && state != .held && state != .thrown }

    var aloft: Bool { state == .held || state == .thrown || state == .jump || state == .tumble }

    static func cursorRect(at point: CGPoint) -> CGRect {
        CGRect(x: point.x, y: point.y - pointer.height, width: pointer.width, height: pointer.height)
    }

    static func sweep(_ a0: CGRect, _ a1: CGRect, _ b0: CGRect, _ b1: CGRect) -> CGFloat? {
        let box = b0.insetBy(dx: -a0.width / 2, dy: -a0.height / 2)
        let axes = [
            (a0.midX, (a1.midX - a0.midX) - (b1.midX - b0.midX), box.minX, box.maxX),
            (a0.midY, (a1.midY - a0.midY) - (b1.midY - b0.midY), box.minY, box.maxY),
        ]
        var enter: CGFloat = 0, exit: CGFloat = 1
        for (p, d, lo, hi) in axes {
            if abs(d) < 1e-9 {
                if p <= lo || p >= hi { return nil }
                continue
            }
            let t0 = (lo - p) / d, t1 = (hi - p) / d
            enter = max(enter, min(t0, t1))
            exit = min(exit, max(t0, t1))
            if enter >= exit { return nil }
        }
        return enter
    }

    mutating func step(_ dt: Double, cursor point: CGPoint?) {
        let next = point.map(Self.cursorRect)
        let last = cursor ?? next
        let dt = min(max(dt, 0), 0.25)
        previous = frame
        let n = max(1, Int((dt / Self.tick).rounded(.up)))
        for i in 0..<n {
            var b0: CGRect?, b1: CGRect?
            if let last, let next {
                b0 = Self.mix(last, next, CGFloat(i) / CGFloat(n))
                b1 = Self.mix(last, next, CGFloat(i + 1) / CGFloat(n))
            }
            advance(dt / Double(n), b0, b1)
        }
        cursor = next
    }

    @discardableResult
    mutating func jump() -> Bool {
        guard state == .walk || state == .turn || state == .sit else { return false }
        vx = state == .walk ? facing * pace : 0
        if state == .turn { facing = heading }
        vy = (2 * Self.gravity * max(0, min(Self.hop, bounds.height - Self.size.height))).squareRoot()
        enter(.jump)
        return true
    }

    @discardableResult
    mutating func sit(_ seconds: Double) -> Bool {
        guard state == .walk || state == .turn else { return false }
        if state == .turn { facing = heading }
        enter(.sit, seconds)
        return true
    }

    func touches(_ point: CGPoint) -> Bool {
        let dot = CGRect(origin: point, size: .zero)
        return frame.contains(point) || Self.sweep(dot, dot, previous, frame) != nil
    }

    @discardableResult
    mutating func grab(at point: CGPoint) -> Bool {
        guard state != .held, touches(point) else { return false }
        vx = 0
        vy = 0
        trail = []
        enter(.held)
        hang(point)
        previous = frame
        return true
    }

    mutating func release() {
        guard state == .held else { return }
        let speed = hypot(vx, vy), cap = calm ? Self.fling / 2 : Self.fling
        if speed > cap {
            vx *= cap / speed
            vy *= cap / speed
        }
        if abs(vx) > 1 { facing = vx > 0 ? 1 : -1 }
        heading = facing
        shy = Self.shyness
        armed = false
        mark = cursor ?? .null
        enter(.thrown)
    }

    mutating func bump(_ rect: CGRect) {
        heading = rect.midX > origin.x ? -1 : rect.midX < origin.x ? 1 : -facing
        armed = false
        mark = rect
        if calm, grounded { return turn(to: heading) }
        vx = calm ? 0 : heading * 70
        vy = calm ? min(vy, 0) : state == .jump ? min(vy, 60) : 220
        enter(.tumble)
    }

    mutating func resize(_ bounds: CGRect) {
        self.bounds = bounds
        origin.x = clamp(origin.x)
        origin.y = level(origin.y)
        if grounded { origin.y = bounds.minY }
        cursor = nil
        previous = frame
    }

    private mutating func advance(_ h: Double, _ b0: CGRect?, _ b1: CGRect?) {
        clock += h
        landed += h
        age += h
        shy = max(0, shy - h)
        if !armed, let b1, hypot(b1.minX - mark.minX, b1.minY - mark.minY) > 8 || gap(b1) > Self.reach { armed = true }
        let a0 = frame
        switch state {
        case .walk:
            if shy == 0, let b1, ahead(b1) {
                if !armed, gap(b1) < Self.margin { return turn(to: -facing) }
                if armed, leap(b1) { return }
            }
            let x = origin.x + facing * pace * CGFloat(h)
            origin.x = clamp(x)
            walked += abs(origin.x - a0.midX)
            if origin.x != x { turn(to: -facing) }
        case .turn:
            if clock >= hold / 2 { facing = heading }
            if clock >= hold { enter(.walk) }
        case .lie:
            if clock >= hold {
                facing = heading
                enter(.getUp, calm ? 0.3 : 0.5)
            }
        case .getUp, .sit:
            if clock >= hold { enter(.walk) }
        case .held:
            if let b1 { hang(CGPoint(x: b1.minX, y: b1.maxY)) }
            follow()
        case .jump, .tumble, .thrown:
            fly(CGFloat(h))
        }
        guard shy == 0, armed, let b0, let b1, state == .walk || state == .turn || state == .jump || state == .sit,
              let t = Self.sweep(a0, frame, b0, b1) else { return }
        let a1 = frame
        origin = CGPoint(x: a0.midX + (a1.midX - a0.midX) * t, y: a0.minY + (a1.minY - a0.minY) * t)
        bump(Self.mix(b0, b1, t))
    }

    private mutating func fly(_ h: CGFloat) {
        let x = origin.x + vx * h
        origin.x = clamp(x)
        if origin.x != x, state == .thrown {
            vx *= -0.6
            facing = vx > 0 ? 1 : -1
            heading = facing
        } else if origin.x != x {
            vx = 0
        }
        if calm, state == .thrown { vy = max(vy, -320) }
        origin.y += vy * h - Self.gravity * h * h / 2
        vy -= Self.gravity * h
        if origin.y > bounds.maxY - Self.size.height {
            origin.y = bounds.maxY - Self.size.height
            vy = min(vy, 0)
        }
        guard origin.y <= bounds.minY else { return }
        origin.y = bounds.minY
        guard vy <= 0 else { return }
        let impact = hypot(vx, vy)
        vx = 0
        vy = 0
        switch state {
        case .thrown where !calm && impact >= 640:
            vx = facing * 60
            vy = 160
            enter(.tumble)
        case .jump, .thrown:
            landed = 0
            enter(.walk)
        default:
            calm ? turn(to: heading) : enter(.lie, 0.5)
        }
    }

    private mutating func hang(_ point: CGPoint) {
        origin = CGPoint(x: clamp(point.x), y: level(point.y - Self.size.height + Self.scruff))
    }

    private mutating func follow() {
        trail.append((age, origin))
        trail.removeAll { $0.time < age - 0.08 }
        guard let first = trail.first, age - first.time > 0.02 else { return (vx, vy) = (0, 0) }
        vx = (origin.x - first.point.x) / CGFloat(age - first.time)
        vy = (origin.y - first.point.y) / CGFloat(age - first.time)
    }

    private mutating func leap(_ b: CGRect) -> Bool {
        let d = abs(b.midX - origin.x)
        let span = (b.width + Self.size.width) / 2 + Self.margin
        guard d <= Self.reach, d > span else { return false }
        let lift = b.maxY - bounds.minY + Self.margin
        let height = max(lift + 24, lift / (1 - span * span / (d * d)))
        let land = origin.x + 2 * d * facing
        guard height <= Self.highest, height + Self.size.height <= bounds.height, clamp(land) == land else { return false }
        vy = (2 * Self.gravity * height).squareRoot()
        vx = facing * d / (2 * height / Self.gravity).squareRoot()
        armed = false
        mark = b
        enter(.jump)
        return true
    }

    private mutating func turn(to direction: CGFloat) {
        heading = direction
        enter(.turn, 0.7)
    }

    private mutating func enter(_ next: State, _ seconds: Double = 0) {
        state = next
        clock = 0
        hold = seconds
    }

    private func ahead(_ b: CGRect) -> Bool {
        (b.midX - origin.x) * facing > 0 && b.minY < frame.maxY + Self.margin && b.maxY > frame.minY
    }

    private func gap(_ b: CGRect) -> CGFloat {
        abs(b.midX - origin.x) - (b.width + Self.size.width) / 2
    }

    private func level(_ y: CGFloat) -> CGFloat {
        max(bounds.minY, min(y, bounds.maxY - Self.size.height))
    }

    private func clamp(_ x: CGFloat) -> CGFloat {
        min(max(x, bounds.minX + Self.size.width / 2), bounds.maxX - Self.size.width / 2)
    }

    private static func mix(_ a: CGRect, _ b: CGRect, _ t: CGFloat) -> CGRect {
        a.offsetBy(dx: (b.minX - a.minX) * t, dy: (b.minY - a.minY) * t)
    }
}
