import CoreGraphics

enum PetMark { case none, heart, sparkles, ask, bang, drop, puff, zzz }

struct PetFace: Equatable {
    var open: CGFloat = 1
    var smile: CGFloat = 0
    var brow: CGFloat = 0
    var lift: CGFloat = 0
    var brows: CGFloat = 0
    var curve: CGFloat = 0
    var gape: CGFloat = 0
    var mouth: CGFloat = 0
    var blush: CGFloat = 0
    var look = CGVector.zero
    var mark = PetMark.none
    var glow: CGFloat = 0

    static func mix(_ a: PetFace, _ b: PetFace, _ t: CGFloat) -> PetFace {
        if t <= 0 { return a }
        if t >= 1 { return b }
        func lerp(_ x: CGFloat, _ y: CGFloat) -> CGFloat { x + (y - x) * t }
        var f = PetFace(
            open: lerp(a.open, b.open), smile: lerp(a.smile, b.smile), brow: lerp(a.brow, b.brow), lift: lerp(a.lift, b.lift), brows: lerp(a.brows, b.brows),
            curve: lerp(a.curve, b.curve), gape: lerp(a.gape, b.gape), mouth: lerp(a.mouth, b.mouth), blush: lerp(a.blush, b.blush),
            look: CGVector(dx: lerp(a.look.dx, b.look.dx), dy: lerp(a.look.dy, b.look.dy))
        )
        if a.mark == .none || b.mark == .none || a.mark == b.mark {
            f.mark = a.mark == .none ? b.mark : a.mark
            f.glow = lerp(a.glow, b.glow)
        } else if t < 0.5 {
            f.mark = a.mark
            f.glow = a.glow * (1 - 2 * t)
        } else {
            f.mark = b.mark
            f.glow = b.glow * (2 * t - 1)
        }
        return f
    }
}

enum PetMood: String, CaseIterable {
    case calm, happy, excited, proud, curious, surprised, shy, bored, sleepy, grumpy

    var rank: Int {
        switch self {
        case .surprised: 9
        case .grumpy: 8
        case .excited: 7
        case .proud: 6
        case .happy: 5
        case .shy: 4
        case .curious: 3
        case .sleepy: 2
        case .bored: 1
        case .calm: 0
        }
    }

    var length: Double {
        switch self {
        case .surprised: 1
        case .excited, .happy: 2.5
        case .proud, .grumpy, .shy, .curious: 3
        case .sleepy: 4
        case .bored: 5
        case .calm: 0
        }
    }

    var rest: Double {
        switch self {
        case .surprised, .calm: 0
        case .happy: 3
        case .excited, .grumpy: 5
        case .proud: 30
        case .shy: 45
        case .curious: 120
        case .bored: 600
        case .sleepy: 900
        }
    }

    var own: Bool { self == .curious || self == .bored || self == .sleepy }

    func face(_ progress: Double) -> PetFace {
        switch self {
        case .calm: PetFace()
        case .happy: PetFace(smile: 1, curve: 0.7, gape: 0.2, mouth: 1, blush: 0.4, mark: .heart, glow: 1)
        case .excited: PetFace(open: 1.1, smile: 1, lift: 0.6, brows: 1, curve: 1, gape: 0.7, mouth: 1, blush: 0.4, mark: .sparkles, glow: 1)
        case .proud: PetFace(open: 0.5, lift: 0.5, brows: 1, curve: 0.6, mouth: 1, look: CGVector(dx: 0.3, dy: -0.5), mark: .sparkles, glow: 1)
        case .curious: PetFace(open: 1.2, lift: 0.9, brows: 1, gape: 0.5, mouth: 1, mark: .ask, glow: 1)
        case .surprised: PetFace(open: 1.35, lift: 1, brows: 1, gape: 0.7, mouth: 1, mark: .bang, glow: 1)
        case .shy: PetFace(smile: 1, brow: -0.6, brows: 1, curve: 0.4, mouth: 1, blush: 1, look: CGVector(dx: -0.3, dy: 0.5), mark: .drop, glow: 1)
        case .bored: PetFace(open: 0.55, lift: -0.3, brows: 1, curve: -0.15, mouth: 1, look: CGVector(dx: 0, dy: 0.5))
        case .sleepy: PetFace(open: 0.3, gape: CGFloat(sin(Double.pi * min(1, progress))), mouth: 1, mark: .zzz, glow: 1)
        case .grumpy: PetFace(open: 0.8, brow: 1, lift: -0.3, brows: 1, curve: -0.8, mouth: 1, mark: .puff, glow: 1)
        }
    }
}

struct PetMind {
    static let rise = 0.25
    static let fall = 0.4
    static let gap = 180.0

    private(set) var mood = PetMood.calm
    var gaze = CGVector.zero
    private var began = 0.0
    private var until = 0.0
    private var from = PetFace()
    private var ended: [PetMood: Double] = [:]
    private var owned = -Double.infinity

    @discardableResult
    mutating func feel(_ next: PetMood, at now: Double) -> Bool {
        guard next != .calm else { return false }
        let active = now < until
        if active, next == mood {
            until = now + next.length
            return false
        }
        if active, next.rank < mood.rank { return false }
        if now < (next == mood ? until : ended[next] ?? -.infinity) + next.rest { return false }
        if next.own {
            guard now >= owned + Self.gap else { return false }
            owned = now
        }
        from = face(at: now)
        if mood != .calm { ended[mood] = min(until, now) }
        mood = next
        began = now
        until = now + next.length
        return true
    }

    func face(at now: Double) -> PetFace {
        guard mood != .calm, now < until + Self.fall else { return PetFace() }
        var goal = mood.face((now - began) / mood.length)
        if mood == .curious { goal.look = gaze }
        if now < began + Self.rise { return .mix(from, goal, Self.ease((now - began) / Self.rise)) }
        if now < until { return goal }
        return .mix(goal, PetFace(), Self.ease((now - until) / Self.fall))
    }

    private static func ease(_ x: Double) -> CGFloat {
        let x = min(max(x, 0), 1)
        return CGFloat(x * x * (3 - 2 * x))
    }
}
