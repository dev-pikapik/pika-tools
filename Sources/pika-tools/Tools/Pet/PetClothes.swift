import SwiftUI

struct PetClothes {
    enum Layer { case back, feet, base, legs, outer, neck, prop, whiskers, face, head, glass }

    let pose: PetPose, night: Bool, body: Path, width: CGFloat, height: CGFloat, eye: CGPoint, paws: [CGRect], ground: CGFloat, place: CGAffineTransform

    func draw(_ layer: Layer, _ fill: (Path, Color) -> Void) {
        for (path, color) in shapes(layer) { fill(path.applying(place), color) }
    }

    private typealias Ink = (r: Double, g: Double, b: Double)
    private typealias Layers = [(Path, Color)]

    private enum Dye {
        static let ink: Ink = (0.15, 0.14, 0.19), satin: Ink = (0.30, 0.28, 0.37)
        static let white: Ink = (0.98, 0.97, 0.95), cream: Ink = (0.98, 0.93, 0.80), mist: Ink = (0.78, 0.80, 0.87)
        static let navy: Ink = (0.18, 0.23, 0.42), midnight: Ink = (0.16, 0.19, 0.36)
        static let denim: Ink = (0.33, 0.50, 0.74), denimDeep: Ink = (0.23, 0.37, 0.60), denimLight: Ink = (0.58, 0.72, 0.92)
        static let blue: Ink = (0.30, 0.53, 0.87), blueDeep: Ink = (0.20, 0.37, 0.68)
        static let mustard: Ink = (0.93, 0.70, 0.22), mustardDeep: Ink = (0.77, 0.53, 0.12)
        static let yellow: Ink = (1.0, 0.83, 0.26), yellowDeep: Ink = (0.85, 0.61, 0.12)
        static let gold: Ink = (0.98, 0.78, 0.29), goldDeep: Ink = (0.80, 0.56, 0.15)
        static let sage: Ink = (0.60, 0.74, 0.60), sageDeep: Ink = (0.45, 0.59, 0.47), leaf: Ink = (0.48, 0.70, 0.46)
        static let lavender: Ink = (0.76, 0.68, 0.94), lavenderDeep: Ink = (0.58, 0.50, 0.84)
        static let violet: Ink = (0.50, 0.36, 0.78), violetDeep: Ink = (0.37, 0.25, 0.62)
        static let purple: Ink = (0.45, 0.32, 0.72), purpleDeep: Ink = (0.31, 0.21, 0.53)
        static let pink: Ink = (0.98, 0.66, 0.78), pinkDeep: Ink = (0.93, 0.47, 0.65), blush: Ink = (0.99, 0.82, 0.88)
        static let turquoise: Ink = (0.24, 0.74, 0.74), turquoiseDeep: Ink = (0.14, 0.55, 0.57)
        static let tan: Ink = (0.84, 0.64, 0.42), tanDeep: Ink = (0.64, 0.45, 0.28), brown: Ink = (0.37, 0.25, 0.18), oat: Ink = (0.82, 0.71, 0.53)
        static let steel: Ink = (0.68, 0.72, 0.80), steelDeep: Ink = (0.50, 0.54, 0.64), silver: Ink = (0.86, 0.87, 0.91)
        static let bronze: Ink = (0.80, 0.60, 0.32), bronzeDeep: Ink = (0.58, 0.40, 0.20), ivory: Ink = (0.97, 0.93, 0.82)
        static let indigo: Ink = (0.29, 0.33, 0.66), indigoDeep: Ink = (0.20, 0.23, 0.50)
        static let glass: Ink = (0.80, 0.90, 1.0), string: Ink = (0.36, 0.40, 0.48), feather: Ink = (0.87, 0.88, 0.95)
        static let shade: Ink = (0.10, 0.08, 0.20)
        static let chestnut: Ink = (0.58, 0.33, 0.19), chestnutDeep: Ink = (0.40, 0.21, 0.12), espresso: Ink = (0.19, 0.09, 0.06)
        static let pine: Ink = (0.16, 0.45, 0.43), pineDeep: Ink = (0.10, 0.31, 0.31)
    }

    private func c(_ k: Ink, _ a: Double = 1) -> Color {
        let l = night ? 0.12 : 0
        return Color(red: k.r + (1 - k.r) * l, green: k.g + (1 - k.g) * l, blue: k.b + (1 - k.b) * l, opacity: a)
    }

    private var neck: CGFloat { -height / 2 + 6.4 }
    private var chest: CGFloat { -height / 2 + 5.7 }
    private var waist: CGFloat { height / 2 - 2.6 }
    private var half: CGFloat { width / 2 }
    private var sealed: Bool { pose.outfit[.head] == .helmet }
    private var walk: CGFloat { pose.air ? 0 : 1 - pose.sit }

    private func shapes(_ layer: Layer) -> Layers {
        let o = pose.outfit
        switch layer {
        case .back: return o[.back].map { inside(back($0)) } ?? []
        case .feet: return o[.feet].map(shoes) ?? []
        case .base, .outer:
            guard let item = o[.body], [.hoodie, .labcoat, .tux, .tailcoat, .tweed].contains(item) == (layer == .outer) else { return [] }
            return top(item)
        case .legs: return o[.legs].map(legs) ?? []
        case .neck: return (o[.back] == .cape ? collar : []) + (o[.neck].map(scarf) ?? [])
        case .prop: return o[.back] == .cane ? cane : []
        case .whiskers: return o[.whiskers].map(moustache) ?? []
        case .face: return o[.face].map(face) ?? []
        case .head:
            guard let item = o[.head] else { return [] }
            if item == .helmet { return dome }
            let fit = CGAffineTransform(scaleX: width / 12, y: height / 11).concatenating(CGAffineTransform(translationX: 0, y: -height / 2))
            return hat(item).map { ($0.0.applying(fit), $0.1) }
        case .glass: return o[.head] == .helmet ? glass : []
        }
    }

    private func hat(_ item: PetItem) -> Layers {
        let s = CGFloat(pose.step)
        switch item {
        case .cap:
            var blue = blob([P(-6.3, 2.2), P(-6.0, -0.3), P(-4.4, -1.9), P(-1.4, -2.6), P(1.9, -2.4), P(4.6, -1.2), P(6.1, 0.8), P(6.0, 1.9), P(0, 2.1)])
            blue.addPath(blob([P(3.6, 0.9), P(7.3, 0.8), P(9.8, 1.4), P(10.0, 2.1), P(7.3, 2.0), P(3.6, 2.0)]))
            var deep = ribbon(trace([P(4.4, 1.75), P(7.3, 1.75), P(9.85, 1.95)]), { _ in 0.6 })
            deep.addPath(ribbon(trace([P(-0.6, -2.4), P(2.4, -1.6), P(4.4, 0.6)]), { _ in 0.5 }))
            deep.addPath(ribbon(trace([P(-0.6, -2.4), P(-3.5, -1.5), P(-5.3, 0.9)]), { _ in 0.5 }))
            deep.addPath(oval(-0.6, -2.55, 0.8, 0.45))
            let shine = blob([P(-5.0, -0.2), P(-3.8, -1.4), P(-1.8, -2.0), P(-1.6, -1.6), P(-3.5, -0.8)])
            return [(blue, c(Dye.blue)), (deep, c(Dye.blueDeep)), (shine, c(Dye.white, 0.25))]
        case .beanie:
            var knit = blob([P(-6.0, 1.2), P(-5.7, -1.4), P(-3.8, -3.1), P(-0.6, -3.7), P(2.8, -3.3), P(5.3, -1.6), P(6.0, 1.2)])
            let cuff = trace([P(-6.3, 1.2), P(0, 1.5), P(6.2, 1.15)])
            knit.addPath(ribbon(cuff, { _ in 2.0 }))
            var ribs = ribbon(trace([P(-6.0, 0.15), P(0, 0.45), P(6.0, 0.1)]), { _ in 0.45 })
            for k in 0..<10 {
                let x = -5.1 + CGFloat(k) * 1.15, y = 1.2 + 0.3 * (1 - x * x / 40)
                ribs.addPath(Path(roundedRect: CGRect(x: x - 0.25, y: y - 0.7, width: 0.5, height: 1.5), cornerRadius: 0.25))
            }
            let shine = blob([P(-4.6, -1.0), P(-3.4, -2.4), P(-1.4, -3.0), P(-1.2, -2.5), P(-3.0, -1.6)])
            return [(knit, c(Dye.mustard)), (ribs, c(Dye.mustardDeep)), (shine, c(Dye.white, 0.25)), (fluff(P(-0.3, -4.3), 1.6), c(Dye.cream))]
        case .party:
            let lean = CGAffineTransform(translationX: 0, y: -1.2).concatenating(CGAffineTransform(rotationAngle: -0.2)).concatenating(CGAffineTransform(translationX: 0, y: 1.2))
            let cone = poly(trace([P(-2.9, 1.0), P(0, 1.65), P(2.9, 1.0)], 4) + [P(0.25, -6.6), P(-0.25, -6.6)])
            var bands = Path()
            for k in 0..<3 { bands.addPath(poly([P(-4, -0.6 - CGFloat(k) * 2.6), P(4, -2.4 - CGFloat(k) * 2.6), P(4, -1.3 - CGFloat(k) * 2.6), P(-4, 0.5 - CGFloat(k) * 2.6)])) }
            let side = poly([P(0.1, -6.4), P(2.9, 1.0), P(1.6, 1.45)])
            return [(cone.applying(lean), c(Dye.pink)), (bands.intersection(cone).applying(lean), c(Dye.white)), (side.applying(lean), c(Dye.shade, 0.12)), (fluff(P(0, -6.9), 1.2).applying(lean), c(Dye.gold))]
        case .flowers:
            var petals = [Path(), Path(), Path()], hearts = Path(), leaves = Path()
            let xs: [CGFloat] = [-5.6, -3.8, -1.9, 0.1, 2.1, 4.0, 5.6]
            for (i, x) in xs.enumerated() {
                let y = 0.2 + 0.05 * x * x, r: CGFloat = i % 2 == 0 ? 1.25 : 1.05
                for k in 0..<5 {
                    let a = CGFloat(k) * 2 * .pi / 5 + CGFloat(i) * 0.7
                    petals[i % 3].addPath(oval(x + cos(a) * r * 0.55, y + sin(a) * r * 0.55, r * 0.5, r * 0.5))
                }
                hearts.addPath(oval(x, y, r * 0.36, r * 0.36))
                if i < xs.count - 1 {
                    let m = (x + xs[i + 1]) / 2
                    leaves.addPath(oval(m, 0.95 + 0.05 * m * m, 0.45, 0.95).turned(i % 2 == 0 ? 0.9 : -0.9, P(m, 0.95 + 0.05 * m * m)))
                }
            }
            return [(leaves, c(Dye.leaf)), (petals[0], c(Dye.pink)), (petals[1], c(Dye.lavender)), (petals[2], c(Dye.white)), (hearts, c(Dye.gold))]
        case .bunny:
            let bounce = pose.air ? -0.3 : 0.1 * sin(2 * s - 0.6) * walk
            let back = ear(P(-2.2, 0.4), -0.34 + bounce, 0, 7.0), front = ear(P(0.9, 0.2), 0.14 + bounce * 1.3, 0.9 + bounce, 7.2)
            let band = ribbon(trace([P(-5.6, 2.4), P(-4.6, 0.6), P(-2.5, -0.25), P(0, -0.4), P(2.5, -0.25), P(4.6, 0.6), P(5.6, 2.4)]), { _ in 0.9 })
            var deep = back.0
            deep.addPath(band)
            return [(deep, c(Dye.lavenderDeep)), (back.1, c(Dye.pinkDeep)), (front.0, c(Dye.lavender)), (front.1, c(Dye.pink))]
        case .cowboy:
            var tan = blob([P(-3.5, 0.9), P(-3.3, -2.0), P(-2.9, -4.0), P(-1.6, -4.6), P(-0.2, -4.0), P(1.2, -4.6), P(2.6, -4.1), P(3.2, -2.0), P(3.5, 0.9)])
            tan.addPath(blob([P(-8.6, -0.7), P(-6.4, 0.4), P(-3.4, 0.95), P(0, 1.05), P(3.4, 0.95), P(6.4, 0.4), P(8.6, -0.7), P(8.3, 0.4), P(5.6, 1.7), P(0, 2.3), P(-5.6, 1.7), P(-8.3, 0.4)]))
            let band = poly([P(-3.42, -0.5), P(3.42, -0.5), P(3.45, 0.98), P(0, 1.08), P(-3.45, 0.98)])
            let under = ribbon(trace([P(-8.0, 0.35), P(-5.6, 1.45), P(0, 2.0), P(5.6, 1.45), P(8.0, 0.35)]), { _ in 0.6 })
            let shine = blob([P(-2.5, -3.7), P(-1.9, -4.1), P(-1.6, -1.2), P(-2.3, -0.9)])
            return [(tan, c(Dye.tan)), (band, c(Dye.brown)), (under, c(Dye.tanDeep)), (shine, c(Dye.white, 0.22))]
        case .tophat:
            let lean = CGAffineTransform(translationX: 0, y: -1.0).concatenating(CGAffineTransform(rotationAngle: -0.08)).concatenating(CGAffineTransform(translationX: 0, y: 1.0))
            var ink = poly([P(-3.0, 0.7), P(-2.9, -3.0), P(-3.3, -6.6), P(3.3, -6.6), P(2.9, -3.0), P(3.0, 0.7)])
            ink.addPath(blob([P(-5.3, -0.3), P(-3.0, 0.35), P(0, 0.5), P(3.0, 0.35), P(5.3, -0.3), P(5.1, 0.45), P(2.9, 1.25), P(0, 1.4), P(-2.9, 1.25), P(-5.1, 0.45)]))
            let band = poly([P(-2.96, -1.6), P(2.96, -1.6), P(3.0, 0.4), P(-3.0, 0.4)])
            let shine = poly([P(-2.3, -6.2), P(-1.4, -6.2), P(-1.35, -1.9), P(-2.15, -1.9)])
            return [(ink.applying(lean), c(Dye.ink)), (band.applying(lean), c(Dye.violet)), (shine.applying(lean), c(Dye.white, 0.16))]
        case .detective:
            var cap = blob([P(-6.2, 2.0), P(-6.0, -0.4), P(-4.3, -2.1), P(-1.4, -2.8), P(1.7, -2.7), P(4.4, -1.8), P(6.0, 0.2), P(6.1, 2.0), P(0, 2.2)])
            cap.addPath(blob([P(3.8, 1.3), P(6.6, 1.3), P(8.6, 2.2), P(8.5, 2.9), P(6.2, 2.7), P(3.8, 2.4)]))
            cap.addPath(blob([P(-3.8, 1.3), P(-6.6, 1.4), P(-8.5, 2.4), P(-8.3, 3.1), P(-6.0, 2.8), P(-3.8, 2.5)]))
            var v = Path(), h = Path()
            for k in 0..<10 { v.addRect(CGRect(x: -8.4 + CGFloat(k) * 1.8, y: -3.2, width: 0.6, height: 6.6)) }
            for k in 0..<4 { h.addRect(CGRect(x: -9, y: -2.3 + CGFloat(k) * 1.6, width: 18, height: 0.6)) }
            var dark = ribbon(trace([P(-6.0, 1.95), P(0, 2.15), P(6.0, 1.95)]), { _ in 0.5 })
            dark.addPath(oval(-0.9, -3.0, 0.8, 0.45).turned(0.3, P(-0.9, -3.0)))
            dark.addPath(oval(0.9, -3.0, 0.8, 0.45).turned(-0.3, P(0.9, -3.0)))
            dark.addPath(oval(0, -2.85, 0.45, 0.45))
            return [(cap, c(Dye.oat)), (v.intersection(cap), c(Dye.brown, 0.32)), (h.intersection(cap), c(Dye.brown, 0.32)), (dark, c(Dye.brown))]
        case .pirate:
            let edge = [P(-7.5, -0.2), P(-6.1, -2.0), P(-3.8, -3.4), P(-1.7, -3.0), P(0.7, -4.4), P(2.9, -3.5), P(5.0, -3.4), P(6.9, -1.6), P(7.8, 0.5)]
            let shape = blob(edge + [P(5.2, 1.5), P(1.0, 2.1), P(-3.2, 1.7), P(-6.3, 0.9)])
            let trim = ribbon(trace(edge), { _ in 0.7 })
            let shine = blob([P(-4.6, -2.2), P(-2.4, -2.4), P(-2.6, -1.8), P(-4.4, -1.6)])
            return [(shape, c(Dye.ink)), (trim, c(Dye.gold)), (shine, c(Dye.white, 0.18))]
        case .propeller:
            let r: CGFloat = 6.2, h: CGFloat = 4.6, base: CGFloat = 1.9
            func meridian(_ a: CGFloat, _ up: Bool) -> [CGPoint] {
                (0...6).map { k in let t = CGFloat(up ? k : 6 - k) / 6 * .pi / 2; return P(r * cos(t) * sin(a), base - h * sin(t)) }
            }
            let dome = poly(meridian(-.pi / 2, true) + meridian(.pi / 2, false))
            var gores = Path()
            for (a, b) in [(-70.0, -10.0), (50.0, 90.0)] { gores.addPath(poly(meridian(a * .pi / 180, true) + meridian(b * .pi / 180, false))) }
            var navy = ribbon(trace([P(-6.1, 1.5), P(0, 1.7), P(6.1, 1.5)]), { _ in 0.8 })
            navy.addPath(Path(CGRect(x: -0.3, y: -4.0, width: 0.6, height: 1.5)))
            let spin = s * 1.7 + pose.lift * 0.6, reach = 1.75 * cos(spin)
            var blades = oval(reach, -4.25, abs(reach) + 0.35, 0.5 + 0.15 * abs(sin(spin)))
            blades.addPath(oval(-reach, -4.25, abs(reach) + 0.35, 0.5 + 0.15 * abs(sin(spin))))
            return [(dome, c(Dye.turquoise)), (gores, c(Dye.mustard)), (navy, c(Dye.navy)), (blades, c(Dye.pink)), (oval(0, -4.25, 0.5, 0.5), c(Dye.navy))]
        case .wizard:
            let sway = (pose.air ? 0.6 : 0.25 * sin(s * 2)) * (1 - pose.sit)
            let line = trace([P(0, 1.0), P(-0.3, -2.5), P(-0.8, -5.2), P(-1.9 - sway, -6.9), P(-3.8 - sway, -6.4 + sway)], 5)
            var cone = ribbon(line, { 6.6 * pow(1 - $0, 1.15) + 0.5 })
            cone.addPath(oval(line[line.count - 1].x, line[line.count - 1].y, 0.3, 0.3))
            let lip = poly((0...12).map { k in let t = CGFloat(k) / 12 * .pi; return P(7.0 * cos(t), 1.0 + 1.15 * sin(t)) })
            var purple = cone
            purple.addPath(lip)
            var stars = star(P(0.9, -1.9), 1.05)
            stars.addPath(star(P(-1.3, -4.5), 0.75))
            stars.addPath(star(P(2.1, -0.1), 0.55))
            let side = ribbon(Array(line.prefix(line.count * 2 / 3)), { 1.6 * (1 - $0) + 0.3 }).offsetBy(dx: 2.0, dy: 0).intersection(cone)
            return [(oval(0, 1.0, 7.0, 1.15), c(Dye.purpleDeep)), (purple, c(Dye.purple)), (side, c(Dye.shade, 0.16)), (stars, c(Dye.gold))]
        case .viking:
            var horns = Path()
            for d in [-1.0, 1.0] as [CGFloat] {
                let line = trace([P(4.3 * d, 0.4), P(6.5 * d, -0.6), P(8.0 * d, -2.7), P(8.2 * d, -5.2)])
                horns.addPath(ribbon(line, { 1.9 * (1 - $0) + 0.3 }))
            }
            let dome = blob([P(-6.1, 1.9), P(-5.6, -0.6), P(-3.6, -2.2), P(0, -2.6), P(3.6, -2.2), P(5.6, -0.6), P(6.1, 1.9)])
            var bronze = ribbon(trace([P(-6.1, 1.3), P(0, 1.55), P(6.1, 1.3)]), { _ in 1.3 })
            bronze.addPath(ribbon(trace([P(-0.6, 1.0), P(-0.4, -1.4), P(-0.1, -2.6)]), { _ in 1.0 }))
            var rivets = Path()
            for x in [-4.6, -2.6, 1.6, 3.8] as [CGFloat] { rivets.addPath(oval(x, 1.35 + 0.006 * x * x, 0.3, 0.3)) }
            rivets.addPath(oval(-0.45, -0.6, 0.28, 0.28))
            let shine = blob([P(-4.6, -0.6), P(-3.4, -1.7), P(-1.6, -2.1), P(-1.5, -1.6), P(-3.2, -1.0)])
            return [(horns, c(Dye.ivory)), (dome, c(Dye.steel)), (shine, c(Dye.white, 0.3)), (bronze, c(Dye.bronze)), (rivets, c(Dye.bronzeDeep))]
        case .crown:
            let lean = CGAffineTransform(translationX: 0, y: -0.6).concatenating(CGAffineTransform(rotationAngle: -0.1)).concatenating(CGAffineTransform(translationX: 0, y: 0.6))
            var back = Path(), gold = poly([P(-3.9, -0.7), P(3.9, -0.7), P(3.9, 0.9), P(2.0, 1.25), P(0, 1.35), P(-2.0, 1.25), P(-3.9, 0.9)])
            for x in [-1.3, 1.3] as [CGFloat] {
                back.addPath(poly([P(x - 1.1, -0.5), P(x, -3.2), P(x + 1.1, -0.5)]))
                back.addPath(oval(x, -3.35, 0.45, 0.45))
            }
            for (x, h) in [(-2.6, 2.7), (0, 3.6), (2.6, 2.7)] as [(CGFloat, CGFloat)] {
                gold.addPath(poly([P(x - 1.3, -0.5), P(x, -0.5 - h), P(x + 1.3, -0.5)]))
                gold.addPath(oval(x, -0.7 - h, 0.55, 0.55))
            }
            var pinks = oval(-2.3, 0.3, 0.55, 0.48)
            pinks.addPath(oval(2.3, 0.3, 0.55, 0.48))
            var shine = oval(-2.75, -3.55, 0.2, 0.2)
            shine.addPath(poly([P(-3.55, -0.4), P(-2.95, -0.4), P(-3.05, 0.75), P(-3.55, 0.7)]))
            shine.addPath(poly([P(-0.35, -1.0), P(0, -3.3), P(0.15, -3.0), P(-0.05, -1.0)]))
            return [(back.applying(lean), c(Dye.goldDeep)), (gold.applying(lean), c(Dye.gold)), (oval(0, 0.32, 0.8, 0.62).applying(lean), c(Dye.turquoise)), (pinks.applying(lean), c(Dye.pink)), (shine.applying(lean), c(Dye.white, 0.6))]
        case .bowler:
            let lean = CGAffineTransform(translationX: 0, y: -1.0).concatenating(CGAffineTransform(rotationAngle: -0.07)).concatenating(CGAffineTransform(translationX: 0, y: 1.0))
            let dome = blob([P(-4.1, 1.0), P(-4.4, -1.0), P(-3.6, -3.3), P(-1.6, -4.7), P(1.6, -4.7), P(3.6, -3.3), P(4.4, -1.0), P(4.1, 1.0), P(0, 1.1)])
            var ink = dome
            ink.addPath(blob([P(-6.7, -0.4), P(-4.6, 0.4), P(0, 0.8), P(4.6, 0.4), P(6.7, -0.4), P(6.3, 0.7), P(3.6, 1.7), P(0, 1.9), P(-3.6, 1.7), P(-6.3, 0.7)]))
            let band = poly([P(-4.6, -0.7), P(4.6, -0.7), P(4.6, 0.9), P(-4.6, 0.9)]).intersection(dome)
            let shine = blob([P(-3.4, -1.4), P(-2.6, -3.0), P(-1.2, -3.9), P(-0.9, -3.5), P(-2.1, -2.6), P(-2.7, -1.1)])
            return [(ink.applying(lean), c(Dye.ink)), (band.applying(lean), c(Dye.satin)), (shine.applying(lean), c(Dye.white, 0.2))]
        case .quiff:
            let sway = (pose.air ? 0.7 : 0.25 * sin(s * 2)) * (1 - pose.sit)
            let hair = blob([P(-6.1, 3.4), P(-6.4, 1.0), P(-5.2, -1.0), P(-2.9, -2.0), P(-0.6, -3.5), P(1.8, -5.6 - sway * 0.3), P(4.4 + sway * 0.5, -6.9), P(6.6 + sway, -6.4), P(7.6 + sway, -4.6), P(5.9 + sway * 0.4, -4.1), P(5.0, -2.4), P(5.2, 0.2), P(4.4, 1.2), P(2.0, 1.0), P(-1.0, 0.9), P(-3.6, 1.6)], sharp: [8])
            var deep = ribbon(trace([P(-5.4, 0.6), P(-2.6, -0.8), P(0.2, -2.6), P(2.8, -4.6), P(5.2 + sway * 0.5, -5.8)]), { 0.5 - 0.3 * $0 })
            deep.addPath(ribbon(trace([P(-3.4, 1.0), P(-0.6, -0.4), P(2.0, -2.2), P(4.4, -3.8), P(6.6 + sway * 0.6, -4.6)]), { 0.5 - 0.3 * $0 }))
            deep.addPath(ribbon(trace([P(0.4, 0.9), P(2.8, -0.2), P(5.0, -1.8)]), { 0.45 - 0.2 * $0 }))
            let shine = ribbon(trace([P(-2.2, -1.9), P(0.4, -3.6), P(2.6, -5.5), P(4.8 + sway * 0.5, -6.2)]), { 0.2 + 0.7 * sin(.pi * $0) })
            return [(hair, c(Dye.chestnut)), (deep, c(Dye.chestnutDeep)), (shine, c(Dye.white, 0.25))]
        case .curls:
            let spots: [(CGFloat, CGFloat, CGFloat)] = [(-5.2, 1.5, 1.3), (-5.5, -0.7, 1.5), (-3.9, -2.3, 1.7), (-1.1, -3.2, 1.8), (1.8, -2.9, 1.7), (4.2, -1.8, 1.6), (5.5, 0.1, 1.35), (-2.9, -0.3, 1.5), (0.4, -0.9, 1.6), (3.1, 0.1, 1.4)]
            var edge = Path(), fill = Path(), spirals = Path(), shine = Path()
            for (k, d) in spots.enumerated() {
                let bob = pose.air ? -0.25 : 0.2 * sin(2 * s + CGFloat(k) * 1.3) * walk
                let o = P(d.0, d.1 + bob), r = d.2
                edge.addPath(oval(o.x + 0.1, o.y + 0.15, r + 0.3, r + 0.3))
                fill.addPath(oval(o.x, o.y, r, r))
                let turn = CGFloat(k) * 1.9
                spirals.addPath(ribbon((0...10).map { j in let t = CGFloat(j) / 10, a = turn + t * 4.4, q = r * 0.66 * (1 - 0.65 * t); return P(o.x + q * cos(a), o.y + q * sin(a)) }, { _ in 0.34 }))
                shine.addPath(oval(o.x - r * 0.45, o.y - r * 0.5, r * 0.25, r * 0.18).turned(-0.6, P(o.x - r * 0.45, o.y - r * 0.5)))
            }
            return [(edge, c(Dye.chestnutDeep)), (fill, c(Dye.chestnut)), (spirals, c(Dye.chestnutDeep)), (shine, c(Dye.white, 0.3))]
        case .bun:
            let sway = (pose.air ? 0.4 : 0.15 * sin(s * 2)) * (1 - pose.sit)
            let cap = blob([P(-6.3, 3.6), P(-6.1, 2.0), P(-5.3, 0.4), P(-3.8, -0.6), P(-1.8, -1.1), P(0.4, -1.1), P(2.8, -0.9), P(4.6, -0.2), P(5.5, 0.9), P(5.5, 1.8), P(4.2, 1.3), P(2, 1.0), P(-0.5, 0.9), P(-3.0, 1.4), P(-4.6, 2.4), P(-5.3, 3.5)])
            let o = P(-0.8 - sway, -3.5)
            var knot = oval(o.x, o.y, 2.6, 2.5)
            knot.addPath(oval(o.x, o.y + 2.0, 1.6, 0.9))
            var deep = ribbon(trace([P(o.x - 1.9, o.y + 0.2), P(o.x - 1.2, o.y - 1.7), P(o.x + 0.4, o.y - 2.2), P(o.x + 1.8, o.y - 1.2)]), { _ in 0.35 })
            deep.addPath(ribbon(trace([P(o.x - 1.3, o.y + 1.0), P(o.x - 0.4, o.y - 0.5), P(o.x + 0.7, o.y - 1.2)]), { _ in 0.35 }))
            deep.addPath(ribbon(trace([P(o.x + 0.2, o.y + 1.4), P(o.x + 1.2, o.y + 0.2), P(o.x + 1.9, o.y - 0.5)]), { _ in 0.35 }))
            let band = oval(o.x, o.y + 2.0, 1.55, 0.55)
            let shine = oval(o.x - 0.9, o.y - 1.1, 0.7, 0.45).turned(-0.6, P(o.x - 0.9, o.y - 1.1))
            return [(cap, c(Dye.chestnut)), (knot, c(Dye.chestnut)), (deep, c(Dye.chestnutDeep)), (band, c(Dye.turquoise)), (oval(o.x - 0.3, o.y + 2.0, 0.6, 0.2), c(Dye.white, 0.35)), (shine, c(Dye.white, 0.28))]
        default:
            return []
        }
    }

    private func ear(_ base: CGPoint, _ angle: CGFloat, _ flop: CGFloat, _ length: CGFloat) -> (Path, Path) {
        let bend = P(base.x + sin(angle) * length * 0.6, base.y - cos(angle) * length * 0.6)
        let tip = P(bend.x + sin(angle + flop) * length * 0.4, bend.y - cos(angle + flop) * length * 0.4)
        let mid = P(base.x + sin(angle) * length * 0.3, base.y - cos(angle) * length * 0.3)
        let line = trace([base, mid, bend, tip], 5)
        var outer = ribbon(line, { 1.6 + 1.6 * sin(.pi * min(1, $0 * 1.12)) })
        outer.addPath(oval(tip.x, tip.y, 0.95, 0.95))
        return (outer, ribbon(line, { 0.6 + 1.0 * sin(.pi * $0) }, 0.16...0.88))
    }

    private var dome: Layers {
        let line = height / 2 - 0.9
        var details = Path(roundedRect: CGRect(x: -4.9, y: line - 0.35, width: 1.1, height: 0.7), cornerRadius: 0.3)
        details.addPath(Path(roundedRect: CGRect(x: 2.6, y: line - 0.35, width: 1.1, height: 0.7), cornerRadius: 0.3))
        return [(Path(roundedRect: CGRect(x: -7.5, y: line - 0.75, width: 15, height: 1.5), cornerRadius: 0.75), c(Dye.white)), (details, c(Dye.blue))]
    }

    private var glass: Layers {
        let r: CGFloat = 8.8, line = height / 2 - 0.9, rise = sqrt(r * r - 7.2 * 7.2), cy = line - rise, a0 = asin(rise / r)
        let arc = (0...28).map { k in let a = .pi - a0 + CGFloat(k) / 28 * (.pi + 2 * a0); return P(r * cos(a), cy + r * sin(a)) }
        let rim = ribbon(arc, { _ in 0.5 })
        let glint = (0...8).map { k in let a = .pi + 0.45 + CGFloat(k) / 8 * 0.75; return P((r - 1.3) * cos(a), cy + (r - 1.3) * sin(a)) }
        var shine = ribbon(glint, { 0.5 + 0.5 * sin(.pi * $0) })
        shine.addPath(oval(4.6, cy - 5.6, 0.45, 0.45))
        return [(poly(arc), c(Dye.glass, 0.16)), (rim, c(Dye.white, 0.55)), (shine, c(Dye.white, 0.8))]
    }

    private func face(_ item: PetItem) -> Layers {
        let e = eye, edge = half
        switch item {
        case .shades:
            let o = P(e.x + 0.15, e.y + 0.1 + 0.8 * abs(sin(pose.tilt)))
            func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { P(o.x + x, o.y + y) }
            var ink = blob([q(-2.1, -1.5), q(2.3, -1.5), q(2.45, -0.6), q(1.7, 1.25), q(0.2, 1.55), q(-1.5, 1.2), q(-2.2, -0.4)])
            ink.addPath(ribbon(trace([q(-2.3, -1.4), q(2.5, -1.4)]), { _ in 0.8 }))
            ink.addPath(ribbon(trace([q(-2.0, -1.1), P(-0.8, o.y - 0.8), P(-2.8, o.y - 0.4)]), { _ in 0.65 }))
            ink.addPath(ribbon(trace([q(2.3, -0.9), P(edge - 0.2, o.y - 0.9)]), { _ in 0.6 }))
            ink.addPath(blob([P(edge - 0.5, o.y - 1.4), P(edge + 0.5, o.y - 1.2), P(edge + 0.6, o.y + 0.2), P(edge + 0.1, o.y + 1.0), P(edge - 0.5, o.y + 0.8)]))
            var shine = poly([q(-1.4, -0.95), q(-0.5, -0.95), q(-1.5, 1.0), q(-2.0, 0.5)])
            shine.addPath(poly([q(0.1, -0.95), q(0.5, -0.95), q(-0.5, 1.2), q(-0.9, 1.2)]))
            return [(ink, c(Dye.ink)), (shine, c(Dye.white, 0.4))]
        case .round:
            let o = P(e.x + 0.1, e.y)
            var rim = ring(o, 2.1, 1.5)
            rim.addPath(ribbon(trace([P(o.x - 2.0, o.y - 0.4), P(-0.6, o.y - 0.5), P(-2.6, o.y - 0.2)]), { _ in 0.6 }))
            rim.addPath(ribbon(trace([P(o.x + 2.0, o.y - 0.5), P(o.x + 2.6, o.y - 0.75), P(edge - 0.2, o.y - 0.6)]), { _ in 0.6 }))
            rim.addPath(ribbon(trace([P(edge - 0.2, o.y - 1.9), P(edge + 0.45, o.y - 1.1), P(edge + 0.55, o.y + 0.4), P(edge + 0.05, o.y + 1.6)]), { _ in 0.6 }))
            let glint = ribbon((0...6).map { k in let a = 3.5 + CGFloat(k) / 6 * 0.9; return P(o.x + 1.05 * cos(a), o.y + 1.05 * sin(a)) }, { _ in 0.4 })
            return [(oval(o.x, o.y, 1.5, 1.5), c(Dye.white, 0.2)), (rim, c(Dye.ink)), (glint, c(Dye.white, 0.8))]
        case .hearts:
            let o = P(e.x + 0.2, e.y + 0.1)
            var frame = heart(o, 2.6)
            frame.addPath(heart(o, 1.95, hole: true))
            frame.addPath(ribbon(trace([P(o.x - 2.4, o.y - 0.9), P(-0.6, o.y - 0.8), P(-2.6, o.y - 0.4)]), { _ in 0.6 }))
            frame.addPath(ribbon(trace([P(o.x + 2.4, o.y - 0.9), P(edge - 0.2, o.y - 0.9)]), { _ in 0.6 }))
            frame.addPath(heart(P(edge + 0.1, o.y), 0.9).applying(CGAffineTransform(translationX: -(edge + 0.1), y: -o.y).concatenating(CGAffineTransform(scaleX: 0.55, y: 1.6)).concatenating(CGAffineTransform(translationX: edge + 0.1, y: o.y))))
            return [(heart(o, 1.95), c(Dye.pinkDeep, 0.55)), (frame, c(Dye.blush)), (oval(o.x - 0.9, o.y - 0.7, 0.35, 0.35), c(Dye.white, 0.8))]
        case .mask:
            let o = e
            func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { P(o.x + x, o.y + y) }
            var mask = blob([q(-3.7, -1.7), q(-1.6, -1.8), q(0.4, -2.1), q(2.3, -1.9), P(edge + 0.35, o.y - 1.25), P(edge + 0.45, o.y + 0.25), P(edge - 0.35, o.y + 0.95), q(1.9, 1.6), q(0.2, 1.9), q(-1.5, 1.5), q(-2.8, 0.3)], sharp: [0])
            mask.addPath(blob([q(-1.85, -0.15), q(-0.7, -1.45), q(0.8, -1.55), q(1.75, -0.4), q(1.3, 1.1), q(-0.3, 1.45)], sharp: [0], hole: true))
            let k = P(-edge + 0.1, o.y + 0.1)
            mask.addPath(ribbon(trace([q(-3.0, -0.75), P((k.x + o.x - 3.0) / 2, o.y - 0.3), k]), { _ in 0.75 }))
            mask.addPath(oval(k.x, k.y, 0.65, 0.65))
            let f = pose.air ? sin(pose.lift * 0.9) : sin(2 * CGFloat(pose.step)) * walk
            let droop: CGFloat = sealed ? 2.2 : pose.air ? -0.6 : 0.5
            mask.addPath(ribbon(trace([k, P(k.x - 1.7, k.y - 0.5 + 0.3 * f + droop * 0.4), P(k.x - (sealed ? 2.4 : 3.3), k.y - 0.6 + droop + 0.6 * f)]), { 1.15 - 0.4 * $0 }))
            mask.addPath(ribbon(trace([k, P(k.x - 1.5, k.y + 0.8 - 0.3 * f + droop * 0.4), P(k.x - (sealed ? 2.0 : 2.8), k.y + 1.8 + droop - 0.5 * f)]), { 1.15 - 0.4 * $0 }))
            let sheen = ribbon(trace([q(-2.6, -1.35), q(-0.6, -1.75), q(1.6, -1.6)]), { 0.2 + 0.4 * sin(.pi * $0) })
            return [(mask, c(Dye.midnight)), (sheen, c(Dye.white, 0.22))]
        case .monocle:
            let o = P(e.x + 0.1, e.y)
            let drop = pose.air ? sin(pose.lift * 0.8) : sin(CGFloat(pose.step) + 0.5) * walk
            let end = pose.air ? P(o.x - 4.6 + 0.5 * drop, o.y + 4.2) : P(o.x - 3.8 + 0.5 * drop, o.y + 5.2)
            let chain = trace([P(o.x - 1.5, o.y + 1.5), P(o.x - 3.4, o.y + 2.0), end])
            let rim = ring(o, 2.15, 1.6)
            var gold = rim
            gold.addPath(ribbon(chain, { _ in 0.32 }))
            gold.addPath(oval(end.x, end.y, 0.42, 0.42))
            let crescent = rim.subtracting(rim.applying(CGAffineTransform(translationX: -0.45, y: -0.45)))
            let glint = ribbon((0...6).map { k in let a = 3.5 + CGFloat(k) / 6 * 0.9; return P(o.x + 1.1 * cos(a), o.y + 1.1 * sin(a)) }, { _ in 0.4 })
            return [(oval(o.x, o.y, 1.6, 1.6), c(Dye.glass, 0.22)), (gold, c(Dye.gold)), (crescent, c(Dye.goldDeep)), (glint, c(Dye.white, 0.8))]
        default:
            return []
        }
    }

    private var collar: Layers {
        let n = neck
        return [(ribbon(trace([P(-half + 0.2, n - 0.5), P(0, n + 0.25), P(3.6, n + 0.55), P(half - 0.2, n + 0.2)]), { _ in 0.75 }), c(Dye.violet)), (oval(3.6, n + 0.55, 0.62, 0.62), c(Dye.gold))]
    }

    private var cane: Layers {
        let w = half, s = CGFloat(pose.step), air = pose.air
        let bob = air ? 0 : 0.8 * (1 + 0.7 * pose.bounce) * abs(sin(s)) * (1 - pose.sit)
        let floor = height / 2 + 1.8 - 1.4 * pose.sit + (pose.outfit[.feet] == .skates ? 1.2 * (1 - pose.sit) : 0) + bob
        let grip = P(w + 1.0, waist + 1.4)
        let tip = air ? P(grip.x + 5.0 * sin(0.3 + 0.3 * sin(pose.lift * 0.8)), grip.y + 4.8) : P(grip.x + 0.8 + 1.4 * sin(s) * walk, floor - 0.9 * max(0, cos(s)) * walk)
        let shaft = trace([grip, P((grip.x + tip.x) / 2, (grip.y + tip.y) / 2), tip], 4)
        let crook = trace([grip, P(grip.x, grip.y - 1.0), P(grip.x + 0.5, grip.y - 1.8), P(grip.x + 1.3, grip.y - 2.0), P(grip.x + 2.0, grip.y - 1.4)])
        var gold = ribbon(crook, { 1.05 - 0.15 * $0 })
        gold.addPath(ribbon(Array(shaft.prefix(3)), { _ in 1.1 }))
        gold.addPath(oval(crook[crook.count - 1].x, crook[crook.count - 1].y, 0.55, 0.55))
        let ferrule = ribbon(Array(shaft.suffix(3)), { _ in 1.05 })
        let gleam = ribbon(Array(shaft.dropFirst(3)), { _ in 0.22 }).offsetBy(dx: -0.26, dy: 0)
        let glint = ribbon(trace([P(grip.x - 0.1, grip.y - 1.7), P(grip.x + 0.6, grip.y - 1.35)]), { _ in 0.28 })
        return [(ribbon(shaft, { _ in 0.95 }), c(Dye.satin)), (gleam, c(Dye.mist, 0.55)), (gold, c(Dye.gold)), (ferrule, c(Dye.steel)), (glint, c(Dye.white, 0.7))]
    }

    private func moustache(_ item: PetItem) -> Layers {
        let e = eye, s = CGFloat(pose.step), y = e.y + 2.5, x: CGFloat = 4.9
        let f = pose.air ? sin(pose.lift * 0.9) : sin(2 * s) * walk
        switch item {
        case .handlebar:
            var hair = oval(x, y + 0.35, 0.9, 0.6)
            var shine = Path()
            for d in [-1.0, 1.0] as [CGFloat] {
                let g = f * (d > 0 ? 1 : -0.8)
                let line = trace([P(x, y + 0.3), P(x + 0.8 * d, y + 0.5), P(x + 1.5 * d, y + 0.4), P(x + 1.95 * d, y + 0.3 * g), P(x + 1.85 * d, y - 0.5 + 0.3 * g), P(x + 1.45 * d, y - 0.65 + 0.3 * g)], 4)
                hair.addPath(ribbon(line, { 0.4 + 1.1 * pow(1 - $0, 1.3) }))
                shine.addPath(ribbon(Array(line.prefix(9)), { 0.25 * (1 - $0) }).offsetBy(dx: 0, dy: -0.25))
            }
            return [(hair, c(Dye.chestnutDeep)), (shine, c(Dye.white, 0.3))]
        case .chevron:
            let g = 0.2 * f
            let hair = blob([P(x - 2.0, y - 0.05), P(x - 1.0, y - 0.35), P(x, y - 0.4), P(x + 1.2, y - 0.35), P(x + 2.1, y + 0.05 + g), P(x + 1.7, y + 0.7 + g), P(x + 0.9, y + 0.85), P(x, y + 0.55), P(x - 0.9, y + 0.85), P(x - 1.7, y + 0.6 - g)], sharp: [3])
            var streaks = ribbon(trace([P(x - 1.6, y - 0.05), P(x - 0.4, y - 0.2), P(x + 0.8, y - 0.2), P(x + 1.7, y)]), { _ in 0.22 })
            streaks.addPath(ribbon(trace([P(x - 1.2, y + 0.3), P(x - 0.3, y + 0.15)]), { _ in 0.18 }))
            return [(hair, c(Dye.chestnutDeep)), (streaks, c(Dye.chestnut))]
        case .pencil:
            var hair = Path()
            for d in [-1.0, 1.0] as [CGFloat] {
                let line = trace([P(x - 0.4 + 0.3 * d, y), P(x - 0.4 + 1.1 * d, y + 0.05), P(x - 0.4 + 1.9 * d, y - 0.2 + 0.3 * f * d), P(x - 0.4 + 2.4 * d, y - 0.6 + 0.3 * f * d)], 4)
                hair.addPath(ribbon(line, { 1.1 - 0.7 * $0 }))
            }
            return [(hair, c(Dye.espresso))]
        default:
            return []
        }
    }

    private func scarf(_ item: PetItem) -> Layers {
        let n = neck + (item == .cravat && pose.outfit[.whiskers] != nil ? 0.9 : 0), w = half, s = CGFloat(pose.step)
        switch item {
        case .bowtie:
            let o = P(3.5, n + (pose.outfit[.whiskers] == nil ? 1.05 : 1.85))
            var ink = blob([P(o.x - 0.3, o.y - 0.4), P(o.x - 2.2, o.y - 1.25), P(o.x - 2.5, o.y), P(o.x - 2.2, o.y + 1.25), P(o.x - 0.3, o.y + 0.4)])
            ink.addPath(blob([P(o.x + 0.3, o.y - 0.4), P(o.x + 1.8, o.y - 1.15), P(o.x + 2.05, o.y), P(o.x + 1.8, o.y + 1.15), P(o.x + 0.3, o.y + 0.4)]))
            var folds = poly([P(o.x - 0.5, o.y - 0.35), P(o.x - 2.0, o.y - 1.0), P(o.x - 2.2, o.y - 0.2)])
            folds.addPath(poly([P(o.x + 0.5, o.y - 0.35), P(o.x + 1.6, o.y - 0.95), P(o.x + 1.8, o.y - 0.2)]))
            return [(ink, c(Dye.ink)), (folds, c(Dye.white, 0.16)), (Path(roundedRect: CGRect(x: o.x - 0.55, y: o.y - 0.65, width: 1.1, height: 1.3), cornerRadius: 0.45), c(Dye.satin))]
        case .scarf:
            let sway = sin(s + 0.8) * walk
            let tail: [CGPoint] = sealed ? [P(-w + 0.6, n + 0.9), P(-w - 0.5, n + 2.4), P(-w - 0.7, n + 4.0)]
                : pose.air ? [P(-w + 0.6, n + 0.6), P(-w - 1.6, n - 0.1 + 0.4 * sin(pose.lift * 0.8)), P(-w - 3.8, n - 0.5 - 0.5 * sin(pose.lift * 0.8))]
                : [P(-w + 0.6, n + 0.9), P(-w - 1.3 + 0.3 * sway, n + 2.0 + 0.4 * sway), P(-w - 3.0 + 0.5 * sway, n + 3.3 - 0.6 * sway)]
            let wrap = trace([P(-w - 0.3, n + 0.25), P(0, n + 0.6), P(w + 0.3, n + 0.3)], 8)
            let end = trace([P(2.6, n + 0.9), P(2.8 + 0.15 * sway, n + 2.6), P(3.0 + 0.3 * sway, n + 4.3)], 6), back = trace(tail, 6)
            var teal = ribbon(wrap, { _ in 2.1 })
            teal.addPath(oval(-w - 0.3, n + 0.25, 1.05, 1.05))
            teal.addPath(oval(w + 0.3, n + 0.3, 1.05, 1.05))
            teal.addPath(ribbon(end, { _ in 1.9 }))
            teal.addPath(ribbon(back, { _ in 1.85 }))
            var cream = Path()
            for k in 0..<5 { cream.addPath(ribbon(wrap, { _ in 2.1 }, CGFloat(k) * 0.2 + 0.06...CGFloat(k) * 0.2 + 0.13)) }
            for t in [0.3, 0.62] as [CGFloat] {
                cream.addPath(ribbon(end, { _ in 1.9 }, t...t + 0.14))
                cream.addPath(ribbon(back, { _ in 1.85 }, t...t + 0.14))
            }
            var fringe = Path()
            for line in [end, back] {
                let a = line[line.count - 2], b = line[line.count - 1], d = hypot(b.x - a.x, b.y - a.y)
                let u = P((b.x - a.x) / d, (b.y - a.y) / d)
                for k in [-0.6, 0, 0.6] as [CGFloat] {
                    let p0 = P(b.x - u.y * k, b.y + u.x * k)
                    fringe.addPath(ribbon([p0, P(p0.x + u.x * 0.9, p0.y + u.y * 0.9)], { _ in 0.42 }))
                }
            }
            teal.addPath(fringe)
            let shadow = ribbon(trace([P(-w + 0.5, n + 1.7), P(0, n + 2.0), P(w - 0.5, n + 1.75)]), { _ in 0.9 })
            return [(shadow, c(Dye.shade, 0.14)), (teal, c(Dye.turquoise)), (cream, c(Dye.cream))]
        case .cravat:
            let flick = pose.air ? 0.6 * sin(pose.lift * 0.8) : 0.3 * sin(s + 0.8) * walk
            let left = blob([P(1.0, n + 0.1), P(2.5, n - 0.5), P(4.1, n - 0.2), P(4.2, n + 1.0), P(3.9, n + 3.4), P(2.7, n + 3.0), P(1.6, n + 1.4)], sharp: [5])
            let right = blob([P(3.9, n - 0.2), P(5.4, n - 0.6), P(6.4, n + 0.2), P(6.0, n + 1.5), P(5.6 + flick, n + 3.1), P(4.5 + flick, n + 3.6), P(4.0, n + 1.1)], sharp: [5])
            var trim = ribbon(trace([P(2.8, n + 3.1), P(3.9, n + 3.45)]), { _ in 0.38 })
            trim.addPath(ribbon(trace([P(4.6 + flick, n + 3.4), P(5.7 + flick, n + 3.0)]), { _ in 0.38 }))
            let knot = oval(4.0, n + 0.55, 1.05, 0.85)
            let pin = P(4.0, n + 0.6)
            return [(left, c(Dye.lavender)), (right, c(Dye.lavender)), (trim, c(Dye.cream)), (knot, c(Dye.lavenderDeep)), (oval(2.7, n + 0.2, 0.9, 0.4), c(Dye.white, 0.4)), (oval(5.2, n + 0.1, 0.8, 0.35), c(Dye.white, 0.3)), (oval(pin.x, pin.y, 0.5, 0.5), c(Dye.goldDeep)), (oval(pin.x, pin.y, 0.36, 0.36), c(Dye.gold)), (oval(pin.x - 0.12, pin.y - 0.12, 0.1, 0.1), c(Dye.white, 0.85))]
        case .bandana:
            let f = pose.air ? sin(pose.lift * 0.9) : sin(2 * s) * walk
            var deep = ribbon(trace([P(-w + 0.1, n + 0.25), P(0, n + 0.55), P(w - 0.1, n + 0.3)]), { _ in 1.1 })
            deep.addPath(oval(-w + 0.1, n + 0.25, 0.55, 0.55))
            deep.addPath(oval(w - 0.1, n + 0.3, 0.55, 0.55))
            let k = P(-w + 0.2, n + 0.4)
            deep.addPath(oval(k.x, k.y, 0.8, 0.75))
            if !sealed {
                deep.addPath(ribbon(trace([k, P(k.x - 1.2, k.y - 0.5 + 0.2 * f), P(k.x - 2.2, k.y - 0.9 + 0.4 * f)]), { 0.9 - 0.3 * $0 }))
                deep.addPath(ribbon(trace([k, P(k.x - 1.1, k.y + 0.6 - 0.2 * f), P(k.x - 1.9, k.y + 1.4 - 0.3 * f)]), { 0.9 - 0.3 * $0 }))
            }
            let tri = blob([P(0.8, n + 0.2), P(w + 0.1, n + 0.1), P(w - 0.4, n + 1.6), P(3.9, n + 3.8), P(2.3, n + 2.4)], sharp: [3])
            var dots = Path()
            for d in [P(2.6, n + 1.1), P(4.3, n + 0.9), P(3.8, n + 2.3), P(5.3, n + 1.2), P(3.2, n + 1.7)] { dots.addPath(oval(d.x, d.y, 0.36, 0.36)) }
            return [(deep, c(Dye.indigoDeep)), (tri, c(Dye.indigo)), (dots, c(Dye.white))]
        default:
            return []
        }
    }

    private func torso(_ lift: CGFloat, to end: CGFloat) -> Path {
        let n = chest + lift, w = half
        let line = trace([P(-w - 1, n - 0.1), P(-2.5, n + 0.1), P(1.8, n + 0.5), P(3.8, n + 0.65), P(w + 1, n + 0.1)], 4)
        return body.intersection(poly(line + [P(w + 1, end), P(-w - 1, end)]))
    }

    private func shirt(_ lift: CGFloat, hem: CGFloat, flare f: CGFloat) -> Path {
        let w = half, top = max(chest + 0.8, height / 2 - 4.5)
        var p = torso(lift, to: hem)
        guard f > 0 else { return p }
        p.addPath(poly([P(-w, top), P(-w + 2.5, hem), P(-w - f, hem)]))
        p.addPath(poly([P(w, top), P(w + f, hem), P(w - 2.5, hem)]))
        return p
    }

    private var sleeves: Path {
        let n = chest, w = half
        var p = blob([P(-w + 0.4, n + 0.2), P(-w - 0.6, n + 0.6), P(-w - 0.85, n + 2.0), P(-w + 0.4, n + 2.3)])
        p.addPath(blob([P(w - 0.4, n + 0.3), P(w + 0.55, n + 0.65), P(w + 0.75, n + 1.95), P(w - 0.4, n + 2.15)]))
        return p
    }

    private var cuffs: Path {
        let n = chest, w = half
        var p = ribbon(trace([P(-w - 0.6, n + 0.75), P(-w - 0.85, n + 2.05)]), { _ in 0.6 })
        p.addPath(ribbon(trace([P(w + 0.5, n + 0.8), P(w + 0.7, n + 1.95)]), { _ in 0.6 }))
        return p
    }

    private func top(_ item: PetItem) -> Layers {
        let n = chest, w = half, b = height / 2
        let rib = ribbon(trace([P(-w + 0.3, n + 0.25), P(-2.5, n + 0.45), P(1.8, n + 0.85), P(3.8, n + 1.0), P(w - 0.3, n + 0.45)], 4), { _ in 0.7 })
        let free = pose.outfit[.legs] == nil
        switch item {
        case .tee:
            var tee = shirt(-0.4, hem: free ? b - 1.3 : waist + 0.5, flare: free ? 0.4 : 0)
            tee.addPath(sleeves)
            var deep = ribbon(trace([P(-1.2, n - 0.03), P(1.8, n + 0.46), P(3.8, n + 0.56), P(w - 0.25, n + 0.06)], 4), { 0.35 + 0.55 * sin(.pi * $0) })
            deep.addPath(cuffs)
            return [(tee, c(Dye.turquoise)), (deep, c(Dye.turquoiseDeep)), (heart(P(3.6, n + 2.4), 0.95), c(Dye.pink))]
        case .stripes:
            var white = shirt(-0.3, hem: free ? b - 1.6 : waist + 0.5, flare: free ? 0.4 : 0)
            white.addPath(sleeves)
            var bands = Path()
            for k in 0..<6 { bands.addRect(CGRect(x: -w - 2, y: n + 0.8 + CGFloat(k) * 1.45, width: 2 * w + 4, height: 0.72)) }
            return [(white, c(Dye.white)), (bands.intersection(white), c(Dye.navy))]
        case .hero:
            let trunk = torso(0, to: b + 1)
            var suit = trunk
            suit.addPath(sleeves)
            suit.addPath(trousers)
            var gold = ring(P(3.5, n + 2.2), 1.45, 0.95)
            gold.addPath(oval(3.5, n + 2.45, 0.42, 0.32))
            for (dx, dy) in [(-0.42, -0.25), (0, -0.48), (0.42, -0.25)] as [(CGFloat, CGFloat)] { gold.addPath(oval(3.5 + dx, n + 2.2 + dy, 0.17, 0.17)) }
            gold.addPath(cuffs)
            gold.addPath(trunk.intersection(Path(CGRect(x: -w - 1, y: b - 2.3, width: 2 * w + 2, height: 0.85))))
            return [(suit, c(Dye.midnight)), (gold, c(Dye.gold)), (Path(roundedRect: CGRect(x: 3.1, y: b - 2.45, width: 1.4, height: 1.15), cornerRadius: 0.3), c(Dye.goldDeep))]
        case .suit:
            var white = torso(0, to: b + 1)
            white.addPath(sleeves)
            white.addPath(trousers)
            var blue = rib
            blue.addPath(Path(roundedRect: CGRect(x: 2.2, y: n + 1.5, width: 2.8, height: 1.7), cornerRadius: 0.45))
            blue.addPath(cuffs)
            var boots = Path()
            for p in paws where pose.sit < 0.5 && p.maxY - 0.95 > b - 0.3 { boots.addPath(Path(CGRect(x: p.minX - 0.1, y: p.maxY - 1.65, width: p.width + 0.2, height: 0.7))) }
            var lights = oval(2.9, n + 2.35, 0.32, 0.32)
            lights.addPath(oval(3.9, n + 2.35, 0.32, 0.32))
            return [(white, c(Dye.white))] + (boots.isEmpty ? [] : [(boots, c(Dye.mist))]) + [(blue, c(Dye.blue)), (lights, c(Dye.white))]
        case .hoodie:
            let hem = b - 1.0
            var sage = shirt(-0.1, hem: hem, flare: 0.45)
            sage.addPath(sleeves)
            let roll = trace([P(-w + 0.15, n - 0.35), P(-2.5, n - 0.2), P(1.8, n + 0.25), P(3.8, n + 0.4), P(w - 0.2, n - 0.05)], 4)
            var deep = ribbon(roll.map { P($0.x, $0.y + 0.62) }, { 0.55 + 0.2 * (1 - $0) })
            deep.addPath(cuffs)
            deep.addPath(sage.intersection(Path(CGRect(x: -w - 1, y: hem - 0.75, width: 2 * w + 2, height: 0.75))))
            deep.addPath(blob([P(1.0, hem - 2.45), P(4.3, hem - 2.45), P(5.0, hem - 0.95), P(0.4, hem - 0.95)]))
            sage.addPath(ribbon(roll, { 1.5 - 0.5 * $0 }))
            var cords = ribbon([P(3.2, n + 0.8), P(3.1, n + 1.7)], { _ in 0.5 })
            cords.addPath(ribbon([P(4.6, n + 0.7), P(4.7, n + 1.55)], { _ in 0.5 }))
            cords.addPath(oval(3.1, n + 1.8, 0.32, 0.42))
            cords.addPath(oval(4.7, n + 1.65, 0.32, 0.42))
            return [(sage, c(Dye.sage)), (deep, c(Dye.sageDeep)), (cords, c(Dye.cream))]
        case .labcoat:
            var white = torso(0, to: b + 1)
            white.addPath(poly([P(-w + 0.6, b - 1.6), P(2.9, b - 1.6), P(3.1, b + 0.7), P(-w - 0.5, b + 0.7)]))
            white.addPath(sleeves)
            let v = poly([P(2.3, n + 0.3), P(5.3, n + 0.3), P(3.9, n + 2.4)])
            var mist = poly([P(2.1, n + 0.35), P(3.0, n + 0.35), P(3.8, n + 2.6), P(2.5, n + 1.6)])
            mist.addPath(poly([P(5.5, n + 0.35), P(4.7, n + 0.35), P(4.0, n + 2.6), P(5.3, n + 1.5)]))
            mist.addPath(ribbon([P(3.9, n + 2.2), P(3.9, b + 0.6)], { _ in 0.4 }))
            mist.addPath(ring(P(3.3, n + 3.0), 0.35, 0))
            mist.addPath(ring(P(3.3, n + 4.3), 0.35, 0))
            mist.addPath(ribbon([P(-0.4, n + 1.9), P(1.8, n + 1.9)], { _ in 0.5 }))
            var pen = Path(roundedRect: CGRect(x: 0.2, y: n + 0.7, width: 0.6, height: 1.6), cornerRadius: 0.3)
            pen.addPath(Path(CGRect(x: 0.65, y: n + 0.9, width: 0.35, height: 0.9)))
            return [(white, c(Dye.white)), (v, c(Dye.white)), (mist, c(Dye.mist)), (pen, c(Dye.blue))]
        case .tailcoat:
            let flap = (pose.air ? 0.5 + 0.1 * sin(pose.lift * 0.6) : 0.1 * sin(2 * CGFloat(pose.step)) * walk) - (pose.hang ? pose.tilt * 0.5 : 0)
            let hem = b + 0.4, pivot = P(-w + 1.0, waist - 0.6)
            var coat = torso(-0.1, to: b + 1).intersection(poly([P(-w - 1, n - 1), P(w + 1, n - 1), P(w + 1, waist - 0.2), P(1.6, waist + 0.1), P(-1.0, waist + 1.3), P(-3.2, b), P(-w - 1, b + 1)]))
            coat.addPath(sleeves)
            let tails = poly([P(-w - 0.4, waist - 0.9), P(-1.8, waist - 0.9), P(-2.4, hem), P(-3.3, hem - 1.3), P(-4.1, hem), P(-w - 1.1, hem - 0.3)]).turned(flap, pivot)
            let pleat = ribbon(trace([P(-3.3, hem - 1.3), P(-3.3, waist - 0.5)]), { _ in 0.35 }).turned(flap, pivot)
            let n = n + (pose.outfit[.whiskers] == nil ? 0 : 0.5)
            let shirt = poly([P(2.4, n + 0.25), P(5.8, n + 0.2), P(4.1, n + 3.7)])
            var lapel = poly([P(1.7, n + 0.3), P(2.7, n + 0.2), P(4.1, n + 3.7), P(3.4, n + 3.4), P(3.0, n + 2.0)])
            lapel.addPath(poly([P(5.6, n + 0.15), P(w - 0.1, n + 0.45), P(5.4, n + 1.9), P(4.9, n + 2.8), P(4.1, n + 3.7)]))
            var rose = oval(5.1, n + 1.3, 0.55, 0.55)
            rose.addPath(oval(4.8, n + 1.05, 0.3, 0.3))
            return [(coat, c(Dye.midnight)), (tails, c(Dye.midnight)), (pleat, c(Dye.shade, 0.35)), (shirt, c(Dye.white)), (lapel, c(Dye.indigo)), (rose, c(Dye.pink))]
        case .tweed:
            var jacket = torso(-0.1, to: b + 1)
            jacket.addPath(sleeves)
            var weave = Path(), check = Path()
            for r in 0..<6 {
                for k in 0..<12 {
                    let x = -w - 0.6 + CGFloat(k) * 1.15, y = n - 0.2 + CGFloat(r) * 1.0, up = k % 2 == 0
                    weave.addPath(poly([P(x, y + (up ? 0.8 : 0)), P(x + 0.4, y + (up ? 0.8 : 0)), P(x + 1.55, y + (up ? 0 : 0.8)), P(x + 1.15, y + (up ? 0 : 0.8))]))
                }
            }
            for k in 0..<5 { check.addRect(CGRect(x: -w - 0.2 + CGFloat(k) * 3.2, y: n - 1, width: 0.5, height: 12)) }
            for k in 0..<3 { check.addRect(CGRect(x: -w - 2, y: n + 0.8 + CGFloat(k) * 2.5, width: 2 * w + 4, height: 0.5)) }
            let shirt = poly([P(2.1, n + 0.4), P(w - 0.2, n + 0.3), P(3.9, n + 3.1)])
            var lapel = ribbon([P(1.9, n + 0.5), P(3.8, n + 3.2)], { 1.1 - 0.5 * $0 })
            lapel.addPath(ribbon([P(w - 0.3, n + 1.0), P(4.0, n + 3.2)], { 0.9 - 0.4 * $0 }))
            var buttons = oval(4.0, n + 3.9, 0.32, 0.32)
            buttons.addPath(oval(4.0, n + 4.9, 0.32, 0.32))
            var patch = oval(w + 0.15, n + 1.3, 0.42, 0.58)
            patch.addPath(oval(-w - 0.1, n + 1.3, 0.42, 0.58))
            let welt = ribbon([P(0.2, n + 1.7), P(1.9, n + 1.5)], { _ in 0.35 })
            let square = poly([P(0.5, n + 1.6), P(0.6, n + 0.7), P(1.0, n + 1.1), P(1.4, n + 0.6), P(1.7, n + 1.5)])
            return [(jacket, c(Dye.oat)), (weave.intersection(jacket), c(Dye.tan, 0.9)), (check.intersection(jacket), c(Dye.chestnut, 0.85)), (shirt, c(Dye.cream)), (lapel, c(Dye.tanDeep)), (patch, c(Dye.brown)), (welt, c(Dye.brown)), (square, c(Dye.pink)), (buttons, c(Dye.brown))]
        case .waistcoat:
            let vest = torso(0, to: b + 0.4)
            let shirt = poly([P(2.2, n + 0.4), P(w - 0.2, n + 0.3), P(3.9, n + 2.4)])
            var trim = ribbon([P(2.0, n + 0.45), P(3.9, n + 2.5)], { 0.6 - 0.2 * $0 })
            trim.addPath(ribbon([P(w - 0.3, n + 0.95), P(4.0, n + 2.5)], { 0.55 - 0.2 * $0 }))
            trim.addPath(ribbon([P(-0.4, n + 2.6), P(1.4, n + 2.5)], { _ in 0.35 }))
            var buttons = Path()
            for k in 0..<3 { buttons.addPath(oval(4.0, n + 2.9 + CGFloat(k) * 1.1, 0.3, 0.3)) }
            let watch = P(2.0, n + 2.3)
            var gold = ribbon(trace([P(4.0, n + 1.5), P(3.6, n + 2.2), P(2.8, n + 2.0), P(2.0, n + 1.1)]), { _ in 0.26 })
            gold.addPath(ring(watch, 0.9, 0.62))
            gold.addPath(oval(watch.x, watch.y - 1.05, 0.25, 0.3))
            return [(vest, c(Dye.pine)), (shirt, c(Dye.cream)), (trim, c(Dye.pineDeep)), (buttons, c(Dye.gold)), (oval(watch.x, watch.y, 0.65, 0.65), c(Dye.ivory)), (gold, c(Dye.gold)), (oval(watch.x - 0.18, watch.y - 0.18, 0.12, 0.12), c(Dye.white, 0.8))]
        case .tux:
            var ink = torso(-0.1, to: b + 1)
            ink.addPath(blob([P(-w + 0.3, waist - 1.6), P(-w + 2.6, waist + 0.2), P(-w + 2.0, b + 0.7), P(-w + 0.4, b + 1.0), P(-w - 0.5, waist + 0.3)]))
            let white = poly([P(1.3, n + 0.45), P(w - 0.15, n + 0.25), P(w - 0.45, n + 1.5), P(3.85, b - 0.4)])
            var satin = ribbon([P(1.25, n + 0.45), P(3.7, b - 0.5)], { 1.0 - 0.5 * $0 })
            satin.addPath(ribbon([P(w - 0.35, n + 1.3), P(4.05, b - 0.5)], { 0.8 - 0.35 * $0 }))
            var studs = oval(3.95, n + 2.0, 0.27, 0.27)
            studs.addPath(oval(3.95, n + 2.9, 0.27, 0.27))
            let rim = ink.subtracting(ink.applying(CGAffineTransform(translationX: 0.55, y: -0.45)))
            return [(ink, c(Dye.ink)), (rim, c(Dye.satin)), (white, c(Dye.white)), (satin, c(Dye.satin)), (studs, c(Dye.ink))]
        default:
            return []
        }
    }

    private var trousers: Path {
        var legs = Path()
        guard pose.sit < 0.5 else { return legs }
        let b = height / 2
        for p in paws where p.maxY - 0.95 > b - 0.9 {
            legs.addPath(Path(roundedRect: CGRect(x: p.minX - 0.1, y: b - 1.6, width: p.width + 0.2, height: p.maxY - 0.95 - (b - 1.6)), cornerRadius: 0.5))
        }
        return legs
    }

    private func legs(_ item: PetItem) -> Layers {
        let t = waist, w = half, b = height / 2
        let pants = body.intersection(Path(CGRect(x: -w - 1, y: t, width: 2 * w + 2, height: b - t + 1)))
        switch item {
        case .jeans:
            var denim = pants
            denim.addPath(trousers)
            var deep = pants.intersection(Path(CGRect(x: -w - 1, y: t, width: 2 * w + 2, height: 0.8)))
            for p in paws where pose.sit < 0.5 && p.maxY - 0.95 > b - 0.3 { deep.addPath(Path(CGRect(x: p.minX - 0.1, y: p.maxY - 1.55, width: p.width + 0.2, height: 0.6))) }
            deep.addPath(blob([P(-4.7, t + 1.25), P(-2.2, t + 1.25), P(-2.3, t + 2.5), P(-3.45, t + 3.0), P(-4.6, t + 2.5)], sharp: [0, 1]))
            let seam = ribbon(trace([P(2.0, t + 0.8), P(2.9, t + 1.7), P(4.1, t + 2.2)]), { _ in 0.6 })
            return [(denim, c(Dye.denim)), (deep, c(Dye.denimDeep)), (seam, c(Dye.denimLight))]
        case .overalls:
            let n = neck
            var denim = pants
            denim.addPath(trousers)
            denim.addPath(Path(roundedRect: CGRect(x: 1.0, y: n + 0.3, width: 4.6, height: t - n + 0.4), cornerRadius: 0.5))
            denim.addPath(ribbon(trace([P(1.5, n + 0.6), P(-1.6, n + 0.1), P(-w + 0.2, n - 0.35)]), { _ in 0.95 }))
            denim.addPath(ribbon(trace([P(5.1, n + 0.6), P(w - 0.1, n - 0.2)]), { _ in 0.95 }))
            let deep = Path(roundedRect: CGRect(x: 2.0, y: n + 1.4, width: 2.6, height: 1.6), cornerRadius: 0.4)
            var seams = ribbon([P(1.5, n + 1.1), P(1.5, t + 0.2)], { _ in 0.6 })
            seams.addPath(ribbon([P(5.1, n + 1.1), P(5.1, t + 0.2)], { _ in 0.6 }))
            var buttons = oval(1.6, n + 0.75, 0.45, 0.45)
            buttons.addPath(oval(5.05, n + 0.7, 0.45, 0.45))
            return [(denim, c(Dye.denim)), (deep, c(Dye.denimDeep)), (seams, c(Dye.denimLight)), (buttons, c(Dye.silver))]
        case .tutu:
            var low = Path(), high = Path(), dots = Path()
            for k in 0..<11 { let x = -7.2 + CGFloat(k) * 1.44; low.addPath(oval(x, t + 0.7 + 0.02 * x * x, 1.15, 1.15)) }
            for k in 0..<9 { let x = -6.4 + CGFloat(k) * 1.6; high.addPath(oval(x, t + 0.05 + 0.02 * x * x, 1.05, 1.05)) }
            for (x, y) in [(-4.8, 0.3), (-1.6, 0.1), (1.8, 0.4), (4.6, 0.2), (-3.0, 1.6), (3.2, 1.7)] as [(CGFloat, CGFloat)] { dots.addPath(oval(x, t + y, 0.22, 0.22)) }
            let band = ribbon(trace([P(-w + 0.4, t - 0.75), P(0, t - 0.6), P(w - 0.4, t - 0.75)]), { _ in 0.9 })
            return [(low, c(Dye.pinkDeep)), (high, c(Dye.pink)), (band, c(Dye.lavenderDeep)), (dots, c(Dye.white, 0.85))]
        default:
            return []
        }
    }

    private func shoes(_ item: PetItem) -> Layers {
        var a = Path(), b = Path(), d = Path(), e = Path(), f = Path()
        let turn = CGFloat(pose.step) * 2.2
        for p in paws {
            switch item {
            case .sneakers:
                a.addPath(Path(roundedRect: CGRect(x: p.minX - 0.2, y: p.minY - 0.15, width: p.width + 0.6, height: p.height + 0.15), cornerRadius: 1.3))
                b.addPath(Path(roundedRect: CGRect(x: p.minX - 0.25, y: p.maxY - 0.8, width: p.width + 0.75, height: 0.85), cornerRadius: 0.42))
                b.addPath(Path(roundedRect: CGRect(x: p.minX + 1.9, y: p.minY + 0.15, width: 0.5, height: 0.9), cornerRadius: 0.25))
                b.addPath(Path(roundedRect: CGRect(x: p.minX + 2.8, y: p.minY + 0.35, width: 0.5, height: 0.9), cornerRadius: 0.25))
            case .boots:
                a.addPath(blob([P(p.minX - 0.1, p.minY - 1.7), P(p.minX + 2.7, p.minY - 1.7), P(p.minX + 2.8, p.minY - 0.2), P(p.maxX + 0.35, p.minY + 0.7), P(p.maxX + 0.35, p.maxY), P(p.minX - 0.2, p.maxY)], sharp: [0, 1, 4, 5]))
                b.addPath(Path(roundedRect: CGRect(x: p.minX - 0.25, y: p.maxY - 0.6, width: p.width + 0.65, height: 0.65), cornerRadius: 0.3))
                b.addPath(Path(CGRect(x: p.minX - 0.1, y: p.minY - 1.7, width: 2.8, height: 0.45)))
                d.addPath(oval(p.maxX - 0.4, p.minY + 1.1, 0.55, 0.3))
                d.addPath(Path(roundedRect: CGRect(x: p.minX + 0.4, y: p.minY - 1.0, width: 0.45, height: 1.7), cornerRadius: 0.22))
            case .spats:
                a.addPath(Path(roundedRect: CGRect(x: p.minX - 0.2, y: p.minY - 0.15, width: p.width + 0.6, height: p.height + 0.15), cornerRadius: 1.3))
                d.addPath(Path(roundedRect: CGRect(x: p.minX - 0.25, y: p.maxY - 0.6, width: p.width + 0.65, height: 0.65), cornerRadius: 0.3))
                b.addPath(Path(roundedRect: CGRect(x: p.minX - 0.1, y: p.minY - 1.3, width: p.width * 0.68, height: 1.3 + p.height * 0.62), cornerRadius: 0.55))
                for k in 0..<3 { e.addPath(oval(p.minX + p.width * 0.68 - 0.5, p.minY - 0.7 + CGFloat(k) * 0.55, 0.15, 0.15)) }
                f.addPath(Path(roundedRect: CGRect(x: p.minX + 0.2, y: p.minY - 1.0, width: 0.4, height: 1.5), cornerRadius: 0.2))
            case .skates:
                for x in [p.minX + 0.9, p.maxX - 0.7] {
                    let o = P(x, p.maxY + 0.35)
                    a.addPath(oval(o.x, o.y, 0.85, 0.85))
                    for k in 0..<2 {
                        let ang = turn + CGFloat(k) * .pi / 2, u = P(cos(ang) * 0.6, sin(ang) * 0.6)
                        b.addPath(ribbon([P(o.x - u.x, o.y - u.y), P(o.x + u.x, o.y + u.y)], { _ in 0.4 }))
                    }
                    b.addPath(oval(o.x, o.y, 0.26, 0.26))
                }
                d.addPath(Path(roundedRect: CGRect(x: p.minX - 0.1, y: p.maxY - 0.3, width: p.width + 0.3, height: 0.55), cornerRadius: 0.27))
                e.addPath(Path(roundedRect: CGRect(x: p.minX - 0.15, y: p.minY - 1.0, width: p.width + 0.5, height: p.height + 0.75), cornerRadius: 1.2))
                f.addPath(oval(p.maxX + 0.3, p.maxY - 0.15, 0.5, 0.45))
                f.addPath(Path(roundedRect: CGRect(x: p.minX + 1.9, y: p.minY - 0.7, width: 0.5, height: 1.0), cornerRadius: 0.25))
            default:
                break
            }
        }
        switch item {
        case .sneakers: return [(a, c(Dye.white)), (b, c(Dye.blue))]
        case .boots: return [(a, c(Dye.yellow)), (b, c(Dye.yellowDeep)), (d, c(Dye.white, 0.55))]
        case .spats: return [(a, c(Dye.ink)), (d, c(Dye.satin)), (b, c(Dye.cream)), (e, c(Dye.ink)), (f, c(Dye.white, 0.6))]
        case .skates: return [(a, c(Dye.turquoise)), (b, c(Dye.white)), (d, c(Dye.steelDeep)), (e, c(Dye.white)), (f, c(Dye.pink))]
        default: return []
        }
    }

    private func inside(_ layers: Layers) -> Layers {
        let edge: CGFloat = 14.7
        let r = layers.reduce(CGRect.null) { $0.union($1.0.applying(place).boundingRect) }
        guard r.minX < -edge || r.maxX > edge else { return layers }
        let o = P(-half + 1.2, neck - 0.6).applying(place).x
        let k = min(r.maxX > edge ? (edge - o) / (r.maxX - o) : 1, r.minX < -edge ? (o + edge) / (o - r.minX) : 1)
        let squeeze = place.concatenating(CGAffineTransform(a: k, b: 0, c: 0, d: 1, tx: o * (1 - k), ty: 0)).concatenating(place.inverted())
        return layers.map { ($0.0.applying(squeeze), $0.1) }
    }

    private func back(_ item: PetItem) -> Layers {
        let n = neck, w = half, s = CGFloat(pose.step)
        switch item {
        case .cape:
            let pivot = P(-w + 1.2, n - 0.6), hem = min(height / 2 + 1.4, ground - 0.3)
            let f = 0.35 * sin(2 * s) * walk
            let flap = (pose.air ? 0.85 + 0.12 * sin(pose.lift * 0.6) : 0.1 + 0.05 * sin(2 * s) * walk) - (pose.hang ? pose.tilt * 0.6 : 0)
            let cape = blob([P(-1.5, n - 0.8), P(-w + 0.4, n - 0.95), P(-w - 1.1, n + 0.5), P(-w - 2.3 + f, hem - 1.5), P(-w - 2.9 + f, hem), P(-w - 0.8 - f, hem + 0.25), P(-1.0, hem - 0.2)])
            var folds = ribbon(trace([P(-w - 0.3, n + 1.6), P(-w - 1.2 + f, hem - 1.0), P(-w - 1.6 + f, hem - 0.1)]), { 0.3 + 0.5 * $0 })
            folds.addPath(ribbon(trace([P(-w + 0.4, n + 2.4), P(-w - 0.1 - f, hem - 0.4), P(-w - 0.1 - f, hem + 0.1)]), { 0.2 + 0.5 * $0 }))
            return [(cape.turned(flap, pivot), c(Dye.violet)), (folds.turned(flap, pivot), c(Dye.violetDeep))]
        case .balloon:
            let tie = P(-w + 1.0, n + 0.6).applying(place)
            let lag = pose.air ? min(1, 0.5 + 5 * abs(pose.squash)) : 0
            let sway = 0.9 * sin(s * 0.5 + 0.8) * (1 - lag)
            let knot = P(min(max(tie.x - pose.facing * (3.0 + 1.5 * lag) + sway, -11.8), 11.8), tie.y - 12.0 + 3.0 * lag)
            let o = P(knot.x, knot.y - 3.3)
            let lean = CGAffineTransform(translationX: -knot.x, y: -knot.y).concatenating(CGAffineTransform(rotationAngle: sway * 0.08)).concatenating(CGAffineTransform(translationX: knot.x, y: knot.y))
            var ball = blob([P(o.x, o.y - 3.4), P(o.x + 2.6, o.y - 2.2), P(o.x + 2.8, o.y + 0.4), P(o.x + 1.4, o.y + 2.7), P(o.x, o.y + 3.3), P(o.x - 1.4, o.y + 2.7), P(o.x - 2.8, o.y + 0.4), P(o.x - 2.6, o.y - 2.2)])
            ball.addPath(poly([P(knot.x - 0.55, knot.y + 0.45), P(knot.x + 0.55, knot.y + 0.45), P(knot.x, knot.y - 0.3)]))
            let mid = P((tie.x + knot.x) / 2 + 1.2 * (1 - lag) + 1.8 * lag * pose.facing, (tie.y + knot.y) / 2)
            let string = ribbon(trace([tie, mid, P(knot.x, knot.y + 0.4)], 8), { _ in 0.45 })
            let shine = oval(o.x - 1.2, o.y - 1.5, 0.6, 1.0).turned(0.5, P(o.x - 1.2, o.y - 1.5))
            let back = place.inverted()
            return [(string.applying(back), c(Dye.string)), (ball.applying(lean).applying(back), c(Dye.turquoise)), (shine.applying(lean).applying(back), c(Dye.white, 0.55))]
        case .wings:
            let root = P(-w + 2.2, n - 1.4)
            let flap = (pose.air ? 0.3 * sin(pose.lift * 1.1) : 0.1 * sin(2 * s) * walk) - (pose.hang ? 0.2 : 0)
            func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { P(root.x + x, root.y + y) }
            let upper = [q(0, 0), q(-3.0, -4.6), q(-6.2, -6.6), q(-7.6, -5.6), q(-6.6, -2.4), q(-2.0, 0.2)]
            let lower = [q(-0.4, 0.6), q(-4.6, 1.0), q(-6.4, 2.8), q(-5.2, 4.2), q(-2.0, 2.8)]
            var pair = blob(upper)
            pair.addPath(blob(lower))
            var rims = Path()
            for wing in [upper, lower] {
                rims.addPath(blob(wing))
                let cx = wing.reduce(0) { $0 + $1.x } / CGFloat(wing.count), cy = wing.reduce(0) { $0 + $1.y } / CGFloat(wing.count)
                rims.addPath(blob(wing.map { P(cx + ($0.x - cx) * 0.8, cy + ($0.y - cy) * 0.8) }, hole: true))
            }
            let far = CGAffineTransform(translationX: 0.9, y: -0.7)
            return [(pair.turned(flap - 0.3, root).applying(far), c(Dye.lavender, 0.38)), (pair.turned(flap, root), c(Dye.glass, 0.6)), (rims.turned(flap, root), c(Dye.lavender, 0.85))]
        case .umbrella:
            let up = pose.air ? 1.1 + 0.5 * sin(pose.lift * 0.8) : 0
            let handle = P(-w - 0.6, waist + 0.1), top = P(-1.6, -height / 2 - (pose.outfit[.head] == nil ? 4.1 : 6.0) - up)
            let len = hypot(top.x - handle.x, top.y - handle.y)
            let u = P((top.x - handle.x) / len, (top.y - handle.y) / len)
            let at = CGAffineTransform(a: -u.y, b: u.x, c: u.x, d: u.y, tx: top.x, ty: top.y)
            let sway = 0.05 * sin(2 * s) * walk - (pose.air ? 0.1 : 0) - (pose.hang ? pose.tilt * 0.6 : 0)
            func rib(_ x: CGFloat, _ from: CGFloat, _ to: CGFloat) -> [CGPoint] {
                (0...6).map { k in let a = from + (to - from) * CGFloat(k) / 6; return P(x * cos(a), 4.4 * sin(a)) }
            }
            var even = Path(), odd = Path()
            for k in 0..<5 {
                let x0 = -7.2 + 2.88 * CGFloat(k), x1 = x0 + 2.88
                let scallop = (0...4).map { j in let t = CGFloat(j) / 4; return P(x1 + (x0 - x1) * t, 0.6 * sin(.pi * t)) }
                let panel = poly(rib(x0, .pi / 2, 0) + scallop.reversed() + rib(x1, 0, .pi / 2))
                if k % 2 == 0 { even.addPath(panel) } else { odd.addPath(panel) }
            }
            let wood = ribbon(trace([P(0, 0.5), P(0, -len / 2), P(0, -len)]), { _ in 0.6 })
            var crook = ribbon(trace([P(0, -len), P(0, -len - 1.4), P(-0.4, -len - 2.3), P(-1.3, -len - 2.6), P(-2.0, -len - 2.0)]), { _ in 0.95 })
            crook.addPath(oval(-2.0, -len - 2.0, 0.48, 0.48))
            var gold = ribbon([P(0, 4.0), P(0, 5.5)], { 0.5 - 0.3 * $0 })
            gold.addPath(oval(0, 0.4, 0.5, 0.5))
            gold.addPath(ribbon([P(0, -len - 0.1), P(0, -len - 0.8)], { _ in 1.15 }))
            let shine = ribbon(trace([P(-5.6, 1.6), P(-4.4, 2.9), P(-2.8, 3.7)]), { _ in 0.4 })
            func fit(_ path: Path) -> Path { path.applying(at).turned(sway, handle) }
            return [(fit(wood), c(Dye.chestnutDeep)), (fit(crook), c(Dye.chestnut)), (fit(odd), c(Dye.cream)), (fit(even), c(Dye.indigo)), (fit(gold), c(Dye.gold)), (fit(shine), c(Dye.white, 0.3))]
        case .angel:
            let root = P(-w + 2.4, n - 1.4)
            let flap = (pose.air ? 0.25 * sin(pose.lift * 1.1) : 0.08 * sin(2 * s) * walk) - (pose.hang ? 0.15 : 0)
            func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { P(root.x + x, root.y + y) }
            var primaries = Path()
            for (from, to) in [(q(-3.0, -2.6), q(-8.5, -4.3)), (q(-2.6, -1.6), q(-8.0, -2.2)), (q(-2.2, -0.8), q(-6.9, -0.3)), (q(-1.6, -0.2), q(-5.3, 1.2)), (q(-1.0, 0.2), q(-3.3, 1.9))] {
                primaries.addPath(ribbon([from, to], { 1.6 - 0.2 * $0 }))
                primaries.addPath(oval(to.x, to.y, 0.72, 0.72))
            }
            var coverts = blob([q(0.2, 0.2), q(-0.8, -3.8), q(-3.5, -6.2), q(-6.8, -6.4), q(-7.9, -4.9), q(-5.9, -3.2), q(-3.5, -1.4), q(-1.2, 0.6)])
            for (x, y) in [(-7.0, -4.5), (-5.6, -3.3), (-4.2, -2.2), (-2.8, -1.0)] as [(CGFloat, CGFloat)] { coverts.addPath(oval(root.x + x, root.y + y, 0.9, 0.9)) }
            var wing = primaries
            wing.addPath(coverts)
            let far = CGAffineTransform(translationX: -root.x, y: -root.y).concatenating(CGAffineTransform(scaleX: 0.85, y: 0.85)).concatenating(CGAffineTransform(translationX: root.x + 1.2, y: root.y - 1.0))
            return [(wing.turned(flap - 0.25, root).applying(far), c(Dye.mist)), (primaries.turned(flap, root), c(Dye.feather)), (coverts.turned(flap, root), c(Dye.white))]
        default:
            return []
        }
    }
}

private func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

private func area(_ p: [CGPoint]) -> CGFloat {
    var a: CGFloat = 0
    for i in p.indices { let q = p[(i + 1) % p.count]; a += p[i].x * q.y - q.x * p[i].y }
    return a
}

private func poly(_ p: [CGPoint], hole: Bool = false) -> Path {
    var path = Path()
    path.addLines((area(p) > 0) != hole ? p : p.reversed())
    path.closeSubpath()
    return path
}

private func blob(_ points: [CGPoint], sharp: Set<Int> = [], hole: Bool = false) -> Path {
    let flip = (area(points) > 0) == hole, n = points.count
    let p = flip ? Array(points.reversed()) : points
    let corner = flip ? Set(sharp.map { n - 1 - $0 }) : sharp
    var path = Path()
    path.move(to: p[0])
    for i in 0..<n {
        let a = p[(i + n - 1) % n], b = p[i], c = p[(i + 1) % n], d = p[(i + 2) % n]
        let c1 = corner.contains(i) ? b : CGPoint(x: b.x + (c.x - a.x) / 6, y: b.y + (c.y - a.y) / 6)
        let c2 = corner.contains((i + 1) % n) ? c : CGPoint(x: c.x - (d.x - b.x) / 6, y: c.y - (d.y - b.y) / 6)
        path.addCurve(to: c, control1: c1, control2: c2)
    }
    path.closeSubpath()
    return path
}

private func trace(_ p: [CGPoint], _ n: Int = 6) -> [CGPoint] {
    var out = [p[0]]
    for i in 0..<(p.count - 1) {
        let a = p[max(i - 1, 0)], b = p[i], c = p[i + 1], d = p[min(i + 2, p.count - 1)]
        for k in 1...n {
            let t = CGFloat(k) / CGFloat(n), t2 = t * t, t3 = t2 * t
            func f(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
                0.5 * (2 * b + (c - a) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (3 * b - a - 3 * c + d) * t3)
            }
            out.append(CGPoint(x: f(a.x, b.x, c.x, d.x), y: f(a.y, b.y, c.y, d.y)))
        }
    }
    return out
}

private func ribbon(_ c: [CGPoint], _ w: (CGFloat) -> CGFloat, _ range: ClosedRange<CGFloat> = 0...1) -> Path {
    let m = c.count - 1
    let lo = Int((range.lowerBound * CGFloat(m)).rounded()), hi = max(lo + 1, Int((range.upperBound * CGFloat(m)).rounded()))
    var l: [CGPoint] = [], r: [CGPoint] = []
    for i in lo...min(hi, m) {
        let a = c[max(i - 1, 0)], b = c[min(i + 1, m)]
        let dx = b.x - a.x, dy = b.y - a.y, len = max(hypot(dx, dy), 0.0001), h = w(CGFloat(i) / CGFloat(m)) / 2
        l.append(CGPoint(x: c[i].x - dy / len * h, y: c[i].y + dx / len * h))
        r.append(CGPoint(x: c[i].x + dy / len * h, y: c[i].y - dx / len * h))
    }
    return poly(l + r.reversed())
}

private func oval(_ x: CGFloat, _ y: CGFloat, _ rx: CGFloat, _ ry: CGFloat) -> Path {
    Path(ellipseIn: CGRect(x: x - rx, y: y - ry, width: 2 * rx, height: 2 * ry))
}

private func circle(_ o: CGPoint, _ r: CGFloat, hole: Bool = false) -> Path {
    var p = Path()
    p.addArc(center: o, radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: hole)
    p.closeSubpath()
    return p
}

private func ring(_ o: CGPoint, _ outer: CGFloat, _ inner: CGFloat) -> Path {
    var p = circle(o, outer)
    if inner > 0 { p.addPath(circle(o, inner, hole: true)) }
    return p
}

private func heart(_ o: CGPoint, _ size: CGFloat, hole: Bool = false) -> Path {
    poly((0..<28).map { k in
        let t = CGFloat(k) / 28 * 2 * .pi, s = sin(t), u = size / 16
        let a: CGFloat = 13 * cos(t) - 5 * cos(2 * t)
        let b: CGFloat = 2 * cos(3 * t) + cos(4 * t)
        return CGPoint(x: o.x + 16 * s * s * s * u, y: o.y - (a - b + 2.5) * u)
    }, hole: hole)
}

private func star(_ o: CGPoint, _ r: CGFloat) -> Path {
    poly((0..<10).map { k in
        let a = CGFloat(k) * .pi / 5 - .pi / 2, d = k % 2 == 0 ? r : r * 0.45
        return CGPoint(x: o.x + cos(a) * d, y: o.y + sin(a) * d)
    })
}

private func fluff(_ o: CGPoint, _ r: CGFloat) -> Path {
    var p = oval(o.x, o.y, r * 0.72, r * 0.72)
    for k in 0..<8 {
        let a = CGFloat(k) * .pi / 4 + 0.3
        p.addPath(oval(o.x + cos(a) * r * 0.6, o.y + sin(a) * r * 0.6, r * 0.42, r * 0.42))
    }
    return p
}

private extension Path {
    func turned(_ angle: CGFloat, _ o: CGPoint) -> Path {
        applying(CGAffineTransform(translationX: -o.x, y: -o.y).concatenating(CGAffineTransform(rotationAngle: angle)).concatenating(CGAffineTransform(translationX: o.x, y: o.y)))
    }
}
