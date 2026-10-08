import SwiftUI

struct PetPose: Equatable {
    var step = 0.0
    var lift: CGFloat = 0
    var squash: CGFloat = 0
    var tilt: CGFloat = 0
    var sit: CGFloat = 0
    var facing: CGFloat = 1
    var air = false
    var hang = false
    var dizzy = false
    var blink = false
}

enum PetFigure {
    static let eye = Color(red: 0.13, green: 0.10, blue: 0.20)

    static func shadow(_ pose: PetPose, fill: (Path, Color) -> Void) {
        let f = max(0, 1 - pose.lift / 30)
        guard f > 0 else { return }
        fill(Path(ellipseIn: CGRect(x: -7.5 * f, y: -1.7, width: 15 * f, height: 3.6)), .black.opacity(0.05 * f))
        fill(Path(ellipseIn: CGRect(x: -5.5 * f, y: -1, width: 11 * f, height: 2.4)), .black.opacity(0.12 * f))
    }

    static func draw(_ pose: PetPose, night: Bool, fill: (Path, Color) -> Void) {
        let body = night ? Color(red: 1, green: 0.53, blue: 0.46) : Color(red: 1, green: 0.45, blue: 0.38)
        let feet = night ? Color(red: 0.86, green: 0.36, blue: 0.36) : Color(red: 0.80, green: 0.30, blue: 0.29)
        let air = pose.air, hang = pose.hang, sit = pose.sit
        let bob = air ? 0 : 0.8 * abs(sin(pose.step)) * (1 - sit)
        let squash = pose.squash + 0.06 * sit
        let width = 12 * (1 + squash), height = 11 * (1 - squash)
        let raise = 1.8 - 1.4 * sit
        let upright = hang ? 1 : abs(cos(pose.tilt)), lean = hang ? 0 : abs(sin(pose.tilt))
        let centre = -((height / 2 + raise) * upright + (width / 2 + 0.6) * lean) - pose.lift - bob
        let pivot = hang ? height / 2 : 0
        let place = CGAffineTransform(translationX: 0, y: pivot)
            .concatenating(CGAffineTransform(rotationAngle: pose.tilt))
            .concatenating(CGAffineTransform(translationX: 0, y: centre - pivot))
            .concatenating(CGAffineTransform(scaleX: pose.facing, y: 1))

        var paws = Path()
        for side in [-1.0, 1.0] {
            let stride = air ? 0 : 1.8 * sin(pose.step) * side * (1 - sit)
            let up = air ? 0.8 : 1.3 * max(0, cos(pose.step) * side) * (1 - sit)
            let x = (hang ? 2.9 : 2.7) * side - 2 + stride
            let walking = air ? height / 2 - (hang ? 0.5 : 0.6) : height / 2 - 0.8 - up + bob
            let y = walking + (-2.6 - centre - walking) * sit
            paws.addRoundedRect(in: CGRect(x: x + (3.4 + 1.6 * side - x - 2) * sit, y: y, width: 4, height: 2.6), cornerSize: CGSize(width: 1.3, height: 1.3))
        }
        paws = paws.applying(place)
        if sit < 0.5 { fill(paws, feet) }
        fill(Path(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerRadius: 4, style: .continuous).applying(place), body)
        if sit >= 0.5 { fill(paws, feet) }

        let eye = CGPoint(x: 2.6, y: -height / 2 + 3.8)
        if pose.dizzy {
            var cross = Path()
            for angle in [CGFloat.pi / 4, -.pi / 4] {
                cross.addPath(Path(roundedRect: CGRect(x: -1.6, y: -0.4, width: 3.2, height: 0.8), cornerRadius: 0.4)
                    .applying(CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: eye.x, y: eye.y))))
            }
            fill(cross.applying(place), Self.eye)
        } else {
            let tall: CGFloat = pose.blink ? 0.5 : 2.5
            fill(Path(ellipseIn: CGRect(x: eye.x - 1.25, y: eye.y - tall / 2, width: 2.5, height: tall)).applying(place), Self.eye)
        }
    }
}

extension PetPose {
    init(_ pet: PetPhysics, scale: CGFloat, time: Double) {
        self.init(step: Double(pet.walked / scale) * .pi * 5 / 28, lift: (pet.origin.y - pet.bounds.minY) / scale, facing: pet.facing)
        let fall = pet.calm ? 0 : .pi / 2 * pet.heading * pet.facing
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
        case .walk:
            squash = pet.landed < 0.15 ? 0.14 * (1 - pet.landed / 0.15) : 0
        case .turn:
            break
        }
        blink = !dizzy && time.truncatingRemainder(dividingBy: 3.8) < 0.13
    }

    static func ease(_ x: Double) -> CGFloat {
        let x = min(max(x, 0), 1)
        return x * x * (3 - 2 * x)
    }
}
