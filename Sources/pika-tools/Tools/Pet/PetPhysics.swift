import CoreGraphics

struct PetPhysics {
    enum State { case walk, turn, jump, tumble, lie, getUp, sit, kick, held, thrown }

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
    static let runUp: CGFloat = 24
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
    var roof = CGFloat.infinity
    var dock: CGRect?
    var ledge: CGRect?
    private(set) var previous = CGRect.null
    private var cursor: CGRect?
    private var armed = true
    private var mark = CGRect.null
    private var age = 0.0
    private var trail = Trail()

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

    var aloft: Bool { state == .held || state == .thrown }

    var floor: CGFloat {
        guard let ledge, origin.y >= ledge.maxY - 0.5, ledge.minX...ledge.maxX ~= origin.x else { return bounds.minY }
        return ledge.maxY
    }

    static func cursorRect(at point: CGPoint) -> CGRect {
        CGRect(x: point.x, y: point.y - pointer.height, width: pointer.width, height: pointer.height)
    }

    static func desktop(_ spot: CGPoint, _ windows: [(layer: Int, frame: CGRect)], displays: [CGRect]) -> Bool {
        let top = windows.first { window in
            window.frame.contains(spot) && !(window.layer > 0 && displays.contains { window.frame.contains($0) })
        }
        return top.map { $0.layer < 0 } ?? true
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
        vy = (2 * Self.gravity * min(Self.hop, headroom(to: origin.x + vx * 2 * (2 * Self.hop / Self.gravity).squareRoot()))).squareRoot()
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
        Self.touches(point, previous, frame)
    }

    static func touches(_ point: CGPoint, _ previous: CGRect, _ frame: CGRect) -> Bool {
        let dot = CGRect(origin: point, size: .zero)
        return frame.contains(point) || sweep(dot, dot, previous, frame) != nil
    }

    @discardableResult
    mutating func kick(_ ball: inout BallPhysics) -> Bool {
        guard state == .walk, !ball.aloft else { return false }
        let b = ball.frame
        guard (b.midX - origin.x) * facing > 0, b.minY < origin.y + 10, b.maxY > origin.y else { return false }
        let gap = facing > 0 ? b.minX - frame.maxX : frame.minX - b.maxX
        guard gap < 2, gap > -b.width / 2 else { return false }
        var room = facing > 0 ? ball.bounds.maxX - b.maxX : b.minX - ball.bounds.minX
        if let dock = ball.dock, facing > 0 ? dock.minX >= b.maxX : dock.maxX <= b.minX { room = min(room, facing > 0 ? dock.minX - b.maxX : b.minX - dock.maxX) }
        let power = walked.truncatingRemainder(dividingBy: 97) / 97
        if room > 4 * Self.size.width {
            ball.kick(CGVector(dx: facing * (calm ? 140 : 220 + 160 * power), dy: calm ? 60 : 140 + 160 * (1 - power)))
        } else {
            ball.kick(CGVector(dx: -facing * (calm ? 120 : 170), dy: calm ? 420 : 520), over: true)
        }
        enter(.kick, 0.4)
        return true
    }

    @discardableResult
    mutating func face(_ x: CGFloat) -> Bool {
        guard state == .walk, (x - origin.x) * facing < -Self.size.width else { return false }
        turn(to: -facing)
        return true
    }

    @discardableResult
    mutating func grab(at point: CGPoint) -> Bool {
        guard state != .held, touches(point) else { return false }
        vx = 0
        vy = 0
        trail = Trail()
        enter(.held)
        hang(point)
        previous = frame
        return true
    }

    mutating func release() {
        guard state == .held else { return }
        (vx, vy) = Trail.limit(vx, vy, calm ? Self.fling / 2 : Self.fling)
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
        vy = calm ? min(vy, 0) : state == .jump ? min(vy, 60) : min(220, (2 * Self.gravity * headroom(to: origin.x)).squareRoot())
        enter(.tumble)
    }

    mutating func resize(_ bounds: CGRect) {
        self.bounds = bounds
        origin.x = clamp(origin.x)
        origin.y = level(origin.y)
        if grounded, !standing { origin.y = bounds.minY }
        cursor = nil
        previous = frame
    }

    mutating func move(by offset: CGVector, to bounds: CGRect) {
        self.bounds = bounds
        origin = CGPoint(x: clamp(origin.x + offset.dx), y: level(origin.y + offset.dy))
        mark = mark.offsetBy(dx: offset.dx, dy: offset.dy)
        trail = Trail()
        cursor = nil
        previous = frame
    }

    mutating func recover() {
        guard ![origin.x, origin.y, vx, vy].allSatisfy(\.isFinite) || !bounds.insetBy(dx: -1, dy: -1).contains(frame) else { return }
        origin = CGPoint(x: origin.x.isFinite ? clamp(origin.x) : bounds.midX, y: bounds.minY)
        vx = 0
        vy = 0
        trail = Trail()
        enter(.walk)
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
            if let ledge, climb(ledge) { return }
            if let cap, overlaps(cap), (a0.midX < cap.midX) == (facing > 0) { return turn(to: -facing) }
            let x = origin.x + facing * pace * CGFloat(h)
            origin.x = clamp(x)
            if let cap, overlaps(cap), !overlaps(cap, at: a0.midX) {
                origin.x = a0.midX
                return turn(to: -facing)
            }
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
        case .getUp, .sit, .kick:
            if clock >= hold { enter(.walk) }
        case .held:
            if let b1 { hang(CGPoint(x: b1.minX, y: b1.maxY)) }
            follow()
        case .jump, .tumble, .thrown:
            fly(CGFloat(h), from: a0)
        }
        if let ledge, grounded { settle(ledge, from: a0) }
        if grounded, origin.y > bounds.minY, !standing {
            vx = state == .walk ? facing * pace : 0
            vy = 0
            enter(.jump)
        }
        guard shy == 0, armed, let b0, let b1, state == .walk || state == .turn || state == .jump || state == .sit,
              let t = Self.sweep(a0, frame, b0, b1) else { return }
        let a1 = frame
        origin = CGPoint(x: a0.midX + (a1.midX - a0.midX) * t, y: grounded ? origin.y : a0.minY + (a1.minY - a0.minY) * t)
        bump(Self.mix(b0, b1, t))
    }

    private mutating func fly(_ h: CGFloat, from a0: CGRect) {
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
        if let ledge, ledge.maxY + Self.size.height <= roof, strike(ledge, from: a0) { return land() }
        if state != .thrown, let cap { strike(cap, from: a0) }
        guard origin.y <= bounds.minY else { return }
        origin.y = bounds.minY
        guard vy <= 0 else { return }
        land()
    }

    @discardableResult
    private mutating func strike(_ rect: CGRect, from a0: CGRect) -> Bool {
        guard overlaps(rect) else { return false }
        if a0.minY >= rect.maxY - 0.5, vy <= 0, rect.minX...rect.maxX ~= origin.x {
            origin.y = rect.maxY
            return true
        } else if a0.maxY <= rect.minY + 0.5, vy > 0 {
            origin.y = rect.minY - Self.size.height
            vy = 0
        } else {
            let x = clamp(a0.midX < rect.midX ? rect.minX - Self.size.width / 2 : rect.maxX + Self.size.width / 2)
            if !overlaps(rect, at: x) {
                origin.x = x
                vx = state == .thrown ? -vx * 0.6 : 0
            }
        }
        return false
    }

    private mutating func land() {
        let impact = hypot(vx, vy)
        vx = 0
        vy = 0
        switch state {
        case .thrown where !calm && impact >= 640:
            vx = facing * 60
            vy = min(160, (2 * Self.gravity * headroom(to: origin.x)).squareRoot())
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
        (vx, vy) = trail.velocity(origin, at: age)
    }

    private mutating func climb(_ ledge: CGRect) -> Bool {
        let gap = facing > 0 ? ledge.minX - frame.maxX : frame.minX - ledge.maxX
        let rise = ledge.maxY - origin.y
        guard gap >= 0, gap <= Self.runUp, rise > 0.5, ledge.minY < frame.maxY else { return false }
        let landing = min(16, ledge.width / 2) + Self.size.width / 2
        let d = gap + landing / 2
        let height = max(rise + 8, rise / (1 - pow(landing / 2 / d, 2)))
        guard height <= Self.highest, origin.y + height + Self.size.height <= ceiling(to: origin.x + facing * (gap + landing)) else { return false }
        vy = (2 * Self.gravity * height).squareRoot()
        vx = facing * d * Self.gravity / vy
        enter(.jump)
        return true
    }

    private mutating func settle(_ ledge: CGRect, from a0: CGRect) {
        guard overlaps(ledge) else { return }
        let up = ledge.maxY - origin.y
        let left = clamp(ledge.minX - Self.size.width / 2), right = clamp(ledge.maxX + Self.size.width / 2)
        var sides = [left, right].filter { !overlaps(ledge, at: $0) }.sorted { abs($0 - origin.x) < abs($1 - origin.x) }
        if a0.midX < ledge.minX || a0.midX > ledge.maxX { sides.sort { abs($0 - a0.midX) < abs($1 - a0.midX) } }
        let lift = ledge.minX...ledge.maxX ~= origin.x && ledge.maxY + Self.size.height <= ceiling(to: origin.x)
        if lift, up <= sides.first.map({ abs($0 - origin.x) }) ?? .infinity {
            origin.y = ledge.maxY
        } else if let x = sides.first {
            let away: CGFloat = x < origin.x ? -1 : 1
            origin.x = x
            if state == .walk, away != facing { turn(to: away) }
        }
    }

    private var standing: Bool {
        guard let ledge else { return false }
        return abs(origin.y - ledge.maxY) < 0.5 && ledge.minX...ledge.maxX ~= origin.x
    }

    private func overlaps(_ ledge: CGRect, at x: CGFloat? = nil) -> Bool {
        var f = frame
        if let x { f.origin.x = x - Self.size.width / 2 }
        return f.minX < ledge.maxX - 1e-6 && ledge.minX < f.maxX - 1e-6 && f.minY < ledge.maxY - 1e-6 && ledge.minY < f.maxY - 1e-6
    }

    private func ceiling(to x: CGFloat) -> CGFloat {
        guard let dock, min(origin.x, x) - Self.size.width / 2 < dock.maxX, max(origin.x, x) + Self.size.width / 2 > dock.minX else { return min(bounds.maxY, roof) }
        return min(bounds.maxY, roof, dock.maxY)
    }

    private var cap: CGRect? {
        dock.map { CGRect(x: $0.minX, y: bounds.minY - Self.size.height, width: $0.width, height: bounds.height + 2 * Self.size.height) }
    }

    private mutating func leap(_ b: CGRect) -> Bool {
        let d = abs(b.midX - origin.x)
        let span = (b.width + Self.size.width) / 2 + Self.margin
        guard d <= Self.reach, d > span else { return false }
        let lift = b.maxY - origin.y + Self.margin
        let height = max(lift + 24, lift / (1 - span * span / (d * d)))
        let land = origin.x + 2 * d * facing
        guard height <= Self.highest, origin.y + height + Self.size.height <= ceiling(to: land), clamp(land) == land else { return false }
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

    private func headroom(to x: CGFloat) -> CGFloat {
        let room = ceiling(to: x) - origin.y - Self.size.height
        return max(0, min(bounds.maxY - origin.y - Self.size.height, origin.y > bounds.minY ? room : max(Self.hop / 2, room)))
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

    static func mix(_ a: CGRect, _ b: CGRect, _ t: CGFloat) -> CGRect {
        a.offsetBy(dx: (b.minX - a.minX) * t, dy: (b.minY - a.minY) * t)
    }
}

struct Trail {
    private var points: [(time: Double, point: CGPoint)] = []

    mutating func velocity(_ point: CGPoint, at time: Double) -> (CGFloat, CGFloat) {
        points.append((time, point))
        points.removeAll { $0.time < time - 0.08 }
        guard let first = points.first, time - first.time > 0.02 else { return (0, 0) }
        let t = CGFloat(time - first.time)
        return ((point.x - first.point.x) / t, (point.y - first.point.y) / t)
    }

    static func limit(_ vx: CGFloat, _ vy: CGFloat, _ cap: CGFloat) -> (CGFloat, CGFloat) {
        let speed = hypot(vx, vy)
        return speed > cap ? (vx * cap / speed, vy * cap / speed) : (vx, vy)
    }
}
