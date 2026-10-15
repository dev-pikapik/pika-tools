import SwiftUI

struct PetPose: Equatable {
    var step = 0.0
    var lift: CGFloat = 0
    var floor: CGFloat = 0
    var squash: CGFloat = 0
    var tilt: CGFloat = 0
    var sit: CGFloat = 0
    var facing: CGFloat = 1
    var air = false
    var hang = false
    var dizzy = false
    var blink = false
    var lid: CGFloat = 0
    var bounce: CGFloat = 0
    var nap = 0.0
    var dream: CGFloat = 1
    var face = PetFace()
    var twinkle = 0.0
    var outfit: [PetSlot: PetItem] = [:]
}

enum PetFigure {
    static let eye = Color(red: 0.13, green: 0.10, blue: 0.20)

    static func shadow(_ pose: PetPose, fill: (Path, Color) -> Void) {
        let f = max(0, 1 - pose.lift / 30)
        guard f > 0 else { return }
        fill(Path(ellipseIn: CGRect(x: -7.5 * f, y: -1.7 - pose.floor, width: 15 * f, height: 3.6)), .black.opacity(0.05 * f))
        fill(Path(ellipseIn: CGRect(x: -5.5 * f, y: -1 - pose.floor, width: 11 * f, height: 2.4)), .black.opacity(0.12 * f))
    }

    static func draw(_ pose: PetPose, night: Bool, fill: (Path, Color) -> Void) {
        let body = night ? Color(red: 1, green: 0.53, blue: 0.46) : Color(red: 1, green: 0.45, blue: 0.38)
        let feet = night ? Color(red: 0.86, green: 0.36, blue: 0.36) : Color(red: 0.80, green: 0.30, blue: 0.29)
        let air = pose.air, hang = pose.hang, sit = pose.sit
        let rise: CGFloat = pose.outfit[.feet] == .skates ? 1.2 : 0
        let bob = air ? 0 : 0.8 * (1 + 0.7 * pose.bounce) * abs(sin(pose.step)) * (1 - sit)
        let squash = pose.squash + 0.06 * sit
        let width = 12 * (1 + squash), height = 11 * (1 - squash)
        let raise = 1.8 - 1.4 * sit + rise * (1 - sit)
        let upright = hang ? 1 : abs(cos(pose.tilt)), lean = hang ? 0 : abs(sin(pose.tilt))
        let centre = -((height / 2 + raise) * upright + (width / 2 + 0.6) * lean) - pose.lift - pose.floor - bob
        let pivot = hang ? height / 2 : 0
        let place = CGAffineTransform(translationX: 0, y: pivot)
            .concatenating(CGAffineTransform(rotationAngle: pose.tilt))
            .concatenating(CGAffineTransform(translationX: 0, y: centre - pivot))
            .concatenating(CGAffineTransform(scaleX: pose.facing, y: 1))

        var paws = Path(), soles: [CGRect] = []
        for side in [-1.0, 1.0] {
            let stride = air ? 0 : 1.8 * sin(pose.step) * side * (1 - sit)
            let up = air ? 0.8 : 1.3 * max(0, cos(pose.step) * side) * (1 - sit)
            let x = (hang ? 2.9 : 2.7) * side - 2 + stride
            let walking = air ? height / 2 - (hang ? 0.5 : 0.6) : height / 2 - 0.8 - up + bob
            let y = walking + (-2.6 - rise - centre - walking) * sit
            let paw = CGRect(x: x + (3.4 + 1.6 * side - x - 2) * sit, y: y, width: 4, height: 2.6)
            paws.addRoundedRect(in: paw, cornerSize: CGSize(width: 1.3, height: 1.3))
            soles.append(paw)
        }
        paws = paws.applying(place)
        let shape = Path(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: 4, style: .continuous)
        let eye = CGPoint(x: 2.6, y: -height / 2 + 3.8)
        let wear = PetClothes(pose: pose, night: night, body: shape, width: width, height: height, eye: eye, paws: soles, ground: -centre, place: place)
        wear.draw(.back, fill)
        if sit < 0.5 { fill(paws, feet); wear.draw(.feet, fill) }
        fill(shape.applying(place), body)
        wear.draw(.base, fill)
        wear.draw(.legs, fill)
        wear.draw(.outer, fill)
        if sit >= 0.5 { fill(paws, feet); wear.draw(.feet, fill) }
        wear.draw(.neck, fill)
        wear.draw(.prop, fill)

        let face = pose.lid >= 1 ? PetFace() : pose.face
        let seat = CGPoint(x: eye.x + 0.5 * face.look.dx, y: eye.y + 0.5 * face.look.dy)
        func put(_ path: Path, _ color: Color) { fill(path.applying(place), color) }
        if face.blush > 0 {
            put(Path(ellipseIn: CGRect(x: seat.x - 3.4, y: seat.y + 0.6, width: 3.2, height: 1.9)), Color(red: 1, green: 0.76, blue: 0.82).opacity(0.55 * face.blush))
        }
        if pose.dizzy {
            var cross = Path()
            for angle in [CGFloat.pi / 4, -.pi / 4] {
                cross.addPath(Path(roundedRect: CGRect(x: -1.6, y: -0.4, width: 3.2, height: 0.8), cornerRadius: 0.4)
                    .applying(CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: eye.x, y: eye.y))))
            }
            fill(cross.applying(place), Self.eye)
        } else {
            let tall = (pose.blink ? 0.5 : 2.5 - 2 * pose.lid) * face.open * (1 - face.smile), wide = 2.5 + 0.8 * max(0, face.open - 1)
            put(Path(ellipseIn: CGRect(x: seat.x - wide / 2, y: seat.y - tall / 2, width: wide, height: tall)), Self.eye)
            if face.smile > 0 {
                var arc = Path()
                arc.move(to: CGPoint(x: -1.3, y: 0.6))
                arc.addQuadCurve(to: CGPoint(x: 1.3, y: 0.6), control: CGPoint(x: 0, y: -1.6))
                put(arc.strokedPath(StrokeStyle(lineWidth: 0.7, lineCap: .round)).applying(CGAffineTransform(translationX: seat.x, y: seat.y)), Self.eye.opacity(face.smile))
            }
        }
        if face.brows > 0 {
            let bar = Path(roundedRect: CGRect(x: -1.1, y: -0.25, width: 2.2, height: 0.5), cornerRadius: 0.25)
            put(bar.applying(CGAffineTransform(rotationAngle: 0.5 * face.brow).concatenating(CGAffineTransform(translationX: seat.x, y: seat.y - 1.9 - 0.8 * face.lift))), Self.eye.opacity(face.brows))
        }
        if face.mouth > 0 {
            let bowl = max(0, face.curve), half = 0.9 + 0.35 * bowl, open = 2.2 * face.gape, inset = 0.8 * half * abs(face.curve)
            let mid = CGPoint(x: seat.x + 0.6, y: seat.y + 2.9)
            let left = CGPoint(x: mid.x - half, y: mid.y), right = CGPoint(x: mid.x + half, y: mid.y)
            func bend(_ shift: CGFloat) -> CGFloat { mid.y + (0.9 * face.curve + shift) * 4 / 3 }
            let top = bend(-open * (0.5 - 0.3 * bowl)), bottom = bend(open * (0.5 + 0.3 * bowl)), low = inset * max(0, 1 - 2 * face.gape)
            var lip = Path()
            lip.move(to: left)
            lip.addCurve(to: right, control1: CGPoint(x: left.x + inset, y: top), control2: CGPoint(x: right.x - inset, y: top))
            var gap = lip
            gap.addCurve(to: left, control1: CGPoint(x: right.x - low, y: bottom), control2: CGPoint(x: left.x + low, y: bottom))
            put(gap.union(gap.strokedPath(StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round))), Self.eye.opacity(face.mouth))
        }
        wear.draw(.whiskers, fill)
        wear.draw(.face, fill)
        wear.draw(.head, fill)
        wear.draw(.glass, fill)

        for k in 0..<3 {
            let age = pose.nap - 0.8 - Double(k) * 0.9
            guard age >= 0 else { break }
            let t = (age / 2.7).truncatingRemainder(dividingBy: 1)
            let size = 2.2 + 1.4 * t
            let spot = CGPoint(x: pose.facing * (4.5 + 6.5 * t), y: centre - height / 2 + 1 - 15 * t)
            fill(zed(size).applying(CGAffineTransform(translationX: spot.x, y: spot.y)), (night ? body : feet).opacity(pose.dream * min(1, 4 * t) * (1 - t * t)))
        }

        if face.glow > 0 {
            var crown: CGFloat = switch pose.outfit[.head] {
            case .flowers: 1
            case .cap: 3.5
            case .detective: 4
            case .helmet: 4.5
            case .cowboy, .pirate, .crown: 5
            case .propeller, .bowler: 5.5
            case .viking, .curls: 6
            case .beanie, .bun: 6.5
            case .tophat: 7.5
            case .quiff: 8.5
            case .bunny: 8
            case .wizard, .party: 8.5
            default: 0
            }
            if pose.outfit[.back] == .umbrella { crown = max(crown, 9.5) }
            mark(face, top: centre - max(width, height) / 2, crown: crown, facing: pose.facing, time: pose.twinkle, fill: fill)
        }
    }

    private static func zed(_ size: CGFloat) -> Path {
        var z = Path()
        z.addLines([CGPoint(x: -size / 2, y: -size / 2), CGPoint(x: size / 2, y: -size / 2), CGPoint(x: -size / 2, y: size / 2), CGPoint(x: size / 2, y: size / 2)])
        return z.strokedPath(StrokeStyle(lineWidth: 0.7, lineCap: .round, lineJoin: .round))
    }

    private static func mark(_ face: PetFace, top: CGFloat, crown: CGFloat, facing: CGFloat, time: Double, fill: (Path, Color) -> Void) {
        let a = face.glow, float = 0.6 * sin(time * 3)
        let c = CGPoint(x: facing * 2.2, y: top - crown - 5.5 - float), back = -facing
        func shift(_ path: Path, _ x: CGFloat, _ y: CGFloat) -> Path { path.applying(CGAffineTransform(translationX: x, y: y)) }
        switch face.mark {
        case .none:
            break
        case .heart:
            var heart = Path()
            heart.move(to: CGPoint(x: 0, y: 2.2))
            heart.addCurve(to: CGPoint(x: -2.3, y: -0.5), control1: CGPoint(x: -1.2, y: 1.4), control2: CGPoint(x: -2.3, y: 0.8))
            heart.addCurve(to: CGPoint(x: 0, y: -0.8), control1: CGPoint(x: -2.3, y: -2.3), control2: CGPoint(x: -0.3, y: -2.2))
            heart.addCurve(to: CGPoint(x: 2.3, y: -0.5), control1: CGPoint(x: 0.3, y: -2.2), control2: CGPoint(x: 2.3, y: -2.3))
            heart.addCurve(to: CGPoint(x: 0, y: 2.2), control1: CGPoint(x: 2.3, y: 0.8), control2: CGPoint(x: 1.2, y: 1.4))
            fill(shift(heart, c.x, c.y), Color(red: 1, green: 0.36, blue: 0.52).opacity(a))
        case .sparkles:
            for (k, spot) in [(-2.6, 1.2, 2.3), (2.6, -0.8, 1.8), (0.2, -3.4, 1.3)].map({ (CGFloat($0.0), CGFloat($0.1), CGFloat($0.2)) }).enumerated() {
                let r = spot.2 * CGFloat(0.75 + 0.25 * sin(time * 6 + Double(k) * 2.1))
                var star = Path()
                star.addLines((0..<8).map { i in
                    let angle = CGFloat(i) * .pi / 4, reach = i % 2 == 0 ? r : r * 0.32
                    return CGPoint(x: c.x + spot.0 + reach * sin(angle), y: c.y + spot.1 - reach * cos(angle))
                })
                star.closeSubpath()
                fill(star, Color(red: 1, green: 0.8, blue: 0.22).opacity(a))
            }
        case .ask:
            var hook = Path()
            hook.addLines(stride(from: 160.0, through: -70, by: -15).map { deg in
                CGPoint(x: 1.5 * cos(deg * .pi / 180), y: -1.5 * sin(deg * .pi / 180))
            })
            hook.addLine(to: CGPoint(x: 0, y: 2.1))
            let ink = Color(red: 0.3, green: 0.62, blue: 1).opacity(a)
            fill(shift(hook.strokedPath(StrokeStyle(lineWidth: 1.1, lineCap: .round, lineJoin: .round)), c.x, c.y - 0.6), ink)
            fill(Path(ellipseIn: CGRect(x: c.x - 0.65, y: c.y + 2.4, width: 1.3, height: 1.3)), ink)
        case .bang:
            let ink = Color(red: 1, green: 0.34, blue: 0.24).opacity(a)
            fill(Path(roundedRect: CGRect(x: c.x - 0.9, y: c.y - 2.8, width: 1.8, height: 3.9), cornerRadius: 0.9), ink)
            fill(Path(ellipseIn: CGRect(x: c.x - 0.9, y: c.y + 1.8, width: 1.8, height: 1.8)), ink)
        case .drop:
            var drop = Path()
            drop.move(to: CGPoint(x: 0, y: -1.8))
            drop.addCurve(to: CGPoint(x: 1.1, y: 0.5), control1: CGPoint(x: 0.3, y: -0.9), control2: CGPoint(x: 1.1, y: -0.2))
            drop.addCurve(to: CGPoint(x: -1.1, y: 0.5), control1: CGPoint(x: 1.1, y: 1.8), control2: CGPoint(x: -1.1, y: 1.8))
            drop.addCurve(to: CGPoint(x: 0, y: -1.8), control1: CGPoint(x: -1.1, y: -0.2), control2: CGPoint(x: -0.3, y: -0.9))
            fill(shift(drop, back * 4.4, top - crown - 3.4 - float), Color(red: 0.5, green: 0.78, blue: 1).opacity(a))
        case .zzz:
            for (x, y, size) in [(-1.8, 1.6, 2.2), (1.4, -1.4, 3.2)] as [(CGFloat, CGFloat, CGFloat)] {
                fill(shift(zed(size), c.x + x, c.y + y), Color(red: 0.45, green: 0.5, blue: 0.95).opacity(a))
            }
        case .puff:
            for (x, y, r) in [(4.2, 1.6, 1.2), (5.9, 0.6, 1.7), (7.6, 1.6, 1.2)] {
                fill(Path(ellipseIn: CGRect(x: -back * x - r, y: top - crown - y - 0.8 - float - r, width: 2 * r, height: 2 * r)), Color(white: 0.7).opacity(a))
            }
        }
    }
}

extension PetPose {
    init(_ pet: PetPhysics, scale: CGFloat, time: Double) {
        self.init(
            step: Double(pet.walked / scale) * .pi * 5 / 28, lift: (pet.origin.y - pet.floor) / scale, floor: (pet.floor - pet.bounds.minY) / scale, facing: pet.facing
        )
        let fall = pet.calm ? 0 : .pi / 2 * pet.heading * pet.facing
        let sleepy = min(0.75, max(0, -pet.zest))
        switch pet.state {
        case .jump:
            air = true
            squash = -0.09 * min(1, abs(pet.vy) / 300)
        case .tumble:
            air = true
            tilt = fall * Self.ease(pet.clock / 0.3)
        case .lie:
            tilt = fall
            dizzy = true
        case .getUp:
            tilt = fall * (1 - Self.ease(pet.clock / pet.hold))
            dizzy = pet.clock < pet.hold / 2
        case .sit:
            sit = Self.ease(min(pet.clock, pet.hold - pet.clock) / 0.25)
        case .held:
            air = true
            hang = true
            squash = -0.05
            tilt = pet.calm ? 0 : pet.facing * max(-0.5, min(0.5, pet.vx / 1400)) + 0.07 * sin(time * 4.5)
        case .thrown:
            air = true
            squash = -0.09 * min(1, abs(pet.vy) / 300)
            tilt = pet.calm ? 0 : -max(-0.3, min(0.3, pet.vy / 2400))
        case .kick:
            let swing = sin(.pi * min(1, pet.clock / pet.hold))
            step = .pi / 3 * swing
            tilt = -0.14 * swing
        case .walk:
            squash = pet.landed < 0.15 ? 0.14 * (1 - pet.landed / 0.15) : 0
            lid = sleepy
            bounce = max(0, pet.zest)
        case .turn:
            lid = sleepy
        case .doze:
            sit = Self.ease(pet.clock / 0.5)
            squash = 0.04 * sin(pet.clock * 2 * .pi / 3.6)
            lid = 1
            nap = pet.calm ? (pet.clock > 1 ? 2.4 : 0) : pet.clock
        case .wake:
            let t = pet.clock / pet.hold
            sit = 1 - Self.ease(t / 0.45)
            squash = -0.12 * sin(.pi * min(1, t / 0.75))
            lid = sleepy + (1 - sleepy) * (1 - Self.ease((t - 0.3) / 0.4))
            nap = pet.calm ? (pet.napped > 1 ? 2.4 : 0) : pet.napped + pet.clock
            dream = 1 - Self.ease(t / 0.35)
        }
        blink = !dizzy && time.truncatingRemainder(dividingBy: 3.8) < 0.13
    }

    static func ease(_ x: Double) -> CGFloat {
        let x = min(max(x, 0), 1)
        return x * x * (3 - 2 * x)
    }
}

struct BallPose: Equatable {
    var lift: CGFloat = 0
    var floor: CGFloat = 0
    var angle: CGFloat = 0
}

enum BallFigure {
    static func draw(_ pose: BallPose, night: Bool, fill: (Path, Color) -> Void) {
        let r = BallPhysics.radius / PetStage.scale
        let f = max(0, 1 - pose.lift / 30)
        if f > 0 {
            fill(Path(ellipseIn: CGRect(x: -3.6 * f, y: -1.2 - pose.floor, width: 7.2 * f, height: 2.4)), .black.opacity(0.12 * f))
        }
        let place = CGAffineTransform(rotationAngle: -pose.angle).concatenating(CGAffineTransform(translationX: 0, y: -pose.floor - pose.lift - r))
        let disc = Path(ellipseIn: CGRect(x: -r, y: -r, width: 2 * r, height: 2 * r))
        fill(disc.applying(place), night ? Color(white: 0.9) : .white)
        var patches = pentagon(CGPoint.zero, r * 0.42, 0)
        for k in 0..<5 {
            let a = CGFloat(k) * .pi * 2 / 5 - .pi / 2
            patches.addPath(pentagon(CGPoint(x: cos(a) * r * 1.08, y: sin(a) * r * 1.08), r * 0.4, .pi / 5).intersection(disc))
        }
        fill(patches.applying(place), PetFigure.eye)
    }

    private static func pentagon(_ c: CGPoint, _ size: CGFloat, _ turn: CGFloat) -> Path {
        Path { path in
            path.addLines((0..<5).map { k in
                let a = CGFloat(k) * .pi * 2 / 5 - .pi / 2 + turn
                return CGPoint(x: c.x + cos(a) * size, y: c.y + sin(a) * size)
            })
            path.closeSubpath()
        }
    }
}

extension BallPose {
    init(_ ball: BallPhysics, scale: CGFloat) {
        self.init(lift: (ball.frame.minY - ball.floor) / scale, floor: (ball.floor - ball.bounds.minY) / scale, angle: ball.angle)
    }
}
