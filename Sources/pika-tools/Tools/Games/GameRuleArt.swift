import SwiftUI

struct GameRuleArt: View {
    let rule: GameRule
    var keys: [String] = []
    var on = false
    var height: CGFloat = 108
    @State private var origin = (r: 0.0, g: 0.0)

    var body: some View {
        ArtTimeline { time in
            GameRuleFrame(rule: rule, keys: keys, story: time.map(story) ?? .still(on: on), height: height)
        }
        .onChange(of: on) { old, new in
            let t = Date.now.timeIntervalSinceReferenceDate
            let g = origin.g + GameStory.game(lead + origin.r + t, on: old)
            origin = (GameStory.replay - lead - t, g - GameStory.game(GameStory.replay, on: new))
        }
    }

    private var lead: Double {
        Double(GameRule.allCases.firstIndex(of: rule) ?? 0) * 2.3
    }

    private func story(_ t: Double) -> GameStory {
        let r = lead + origin.r + t
        return GameStory(phase: GameStory.mod(r, GameStory.period(on)), time: origin.g + GameStory.game(r, on: on), on: on)
    }
}

struct GameStory {
    static let press = 1.6, start = 1.7, hold = 2.2, replay = 0.6

    var phase: Double
    var time: Double
    var on: Bool

    static func period(_ on: Bool) -> Double { on ? 4 : 4 + hold }

    static func game(_ r: Double, on: Bool) -> Double {
        let loops = (r / period(on)).rounded(.down), phase = r - loops * period(on)
        return loops * 4 + (on || phase < start ? phase : max(start, phase - hold))
    }

    static func still(on: Bool) -> GameStory {
        GameStory(phase: on ? press + 0.25 : start + 1, time: start, on: on)
    }

    static func mod(_ a: Double, _ b: Double) -> Double {
        a - (a / b).rounded(.down) * b
    }

    static func ramp(_ x: Double, _ from: Double, _ length: Double) -> Double {
        let t = min(max((x - from) / length, 0), 1)
        return t * t * (3 - 2 * t)
    }

    var end: Double { on ? 2.9 : Self.start + Self.hold - 0.5 }
    var cap: Double { Self.ramp(phase, 0.9, 0.35) * (1 - Self.ramp(phase, end, 0.4)) }
    var down: Bool { phase >= Self.press && phase < Self.press + 0.14 }
    var hit: Double { on ? 0 : Self.ramp(phase, Self.start, 0.35) * (1 - Self.ramp(phase, Self.start + Self.hold - 0.45, 0.45)) }
    var pulse: Double? { on && phase >= Self.press && phase < Self.press + 0.7 ? (phase - Self.press) / 0.7 : nil }
    var reach: Double { Self.ramp(phase, 0.7, 0.7) * (1 - Self.ramp(phase, end + 0.2, 0.9)) }
}

struct GameRuleFrame: View {
    let rule: GameRule
    var keys: [String] = []
    let story: GameStory
    var height: CGFloat = 108

    private static let canvas = CGSize(width: 170, height: 108)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let scale = height / Self.canvas.height
        Color.clear
            .frame(width: Self.canvas.width * scale, height: height)
            .overlay {
                ZStack {
                    scene
                    cause.position(x: 85, y: story.on ? 94 : rule == .hide ? 50 : rule == .appWindows ? 63 : 94)
                }
                .frame(width: Self.canvas.width, height: Self.canvas.height)
                .scaleEffect(scale)
            }
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.18), radius: height / 18, y: height / 36)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var scene: some View {
        let p = story.hit
        switch rule {
        case .commandQ, .commandW:
            desk
            game().scaleEffect(1 - 0.08 * p).opacity(1 - p)
        case .hide:
            desk
            ArtDock().position(x: 85, y: 87 + 36 * (1 - p))
            game(dim: false).scaleEffect(1 - 0.9 * p, anchor: UnitPoint(x: 0.5, y: 0.8)).opacity(1 - p)
        case .appSwitcher:
            let panel = CGRect(x: 18, y: 28, width: 134, height: 52)
            popup(panel, radius: 16) {
                HStack(spacing: 6) {
                    ForEach([Color.teal, .orange, .pink], id: \.self) { color in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 30, height: 30)
                            .padding(5)
                            .background(Color.primary.opacity(color == .orange ? 0.16 : 0), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .frame(width: panel.width, height: panel.height)
                .artGlass(radius: 16)
            }
        case .spotlight:
            let bar = CGRect(x: 17, y: 26, width: 136, height: 32)
            popup(bar) { ArtSpotlight(width: bar.width, height: bar.height) }
        case .emoji:
            let panel = CGRect(x: 46, y: 14, width: 102, height: 66)
            popup(panel, radius: 12) {
                Grid(horizontalSpacing: 7, verticalSpacing: 5) {
                    GridRow { Text(verbatim: "😀"); Text(verbatim: "🎮"); Text(verbatim: "⭐️") }
                    GridRow { Text(verbatim: "🍕"); Text(verbatim: "🐱"); Text(verbatim: "🚀") }
                }
                .font(.system(size: 20))
                .frame(width: panel.width, height: panel.height)
                .artGlass(radius: 12)
            }
        case .globe:
            let panel = CGRect(x: 96, y: 8, width: 66, height: 52)
            popup(panel, radius: 16) {
                VStack(spacing: 8) {
                    HStack(spacing: 7) {
                        ForEach(0..<3, id: \.self) { Circle().fill($0 < 2 ? Color.accentColor : Color.primary.opacity(0.16)).frame(width: 14, height: 14) }
                    }
                    Capsule().fill(Color.primary.opacity(0.16)).frame(width: 52, height: 9)
                        .overlay(alignment: .leading) { Capsule().fill(.white).frame(width: 32, height: 9) }
                }
                .frame(width: panel.width, height: panel.height)
                .artGlass(radius: 16)
            }
        case .siri:
            game()
            if p > 0 {
                Circle()
                    .fill(AngularGradient(colors: [.pink, .purple, .blue, .cyan, .pink], center: .center))
                    .frame(width: 46, height: 46)
                    .overlay(Circle().fill(.white.opacity(0.35)).frame(width: 20, height: 20).blur(radius: 6))
                    .shadow(color: .purple.opacity(0.8), radius: 11)
                    .scaleEffect(0.6 + 0.4 * p)
                    .opacity(p)
                    .position(x: 128, y: 34)
            }
        case .launchpad:
            game(dim: false).blur(radius: 5 * p)
            Color.black.opacity(0.15 * p)
            if p > 0 {
                ZStack {
                    ArtSpotlight(width: 62, height: 14).position(x: 85, y: 15)
                    Grid(horizontalSpacing: 13, verticalSpacing: 12) {
                        ForEach(0..<2, id: \.self) { row in
                            GridRow {
                                ForEach(0..<4, id: \.self) { column in
                                    let color = [Color.teal, .orange, .pink, .green, .indigo, .yellow, .red, .blue][row * 4 + column]
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .fill(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                        .frame(width: 25, height: 25)
                                        .shadow(color: .black.opacity(0.15), radius: 1.5, y: 1)
                                }
                            }
                        }
                    }
                    .position(x: 85, y: 58)
                }
                .scaleEffect(1.08 - 0.08 * p)
                .opacity(p)
            }
        case .missionControl:
            desk
            if p > 0 {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(.white.opacity(index == 0 ? 0.85 : 0.4))
                            .frame(width: 32, height: 18)
                    }
                }
                .position(x: 85, y: 13 - 12 * (1 - p))
                ForEach(0..<3, id: \.self) { index in
                    card(width: 46).scaleEffect(0.9 + 0.1 * p).opacity(p).position(x: index == 1 ? 56 : 114, y: index == 0 ? 42 : 72)
                }
            }
            zoom(to: CGPoint(x: 56, y: 42), width: 46)
        case .appWindows:
            desk
            Color.black.opacity(0.45 * p)
            if p > 0 {
                ForEach([30.0, 140.0], id: \.self) { x in
                    card(game: true, width: 46).scaleEffect(0.9 + 0.1 * p).opacity(p).position(x: x, y: 36)
                }
                ArtDock(icon: 18).position(x: 85, y: 89 + 32 * (1 - p))
            }
            zoom(to: CGPoint(x: 85, y: 36), width: 46)
        case .showDesktop:
            desk
            if p > 0 {
                ArtFile().scaleEffect(1.5).opacity(p).position(x: 85, y: 54)
                card(width: 66).opacity(p).position(x: 124 + 40 * p, y: 64 + 8 * p)
            }
            zoom(to: CGPoint(x: 6, y: 42), width: 66)
        case .desktops, .desktopNumbers, .swipes:
            Color(white: 0.06)
            desk.offset(x: -176 * (1 - p))
            game(dim: false).offset(x: 176 * p)
        case .lookUp:
            game()
            if p > 0 {
                VStack(alignment: .leading, spacing: 7) {
                    Text(verbatim: "Aa").font(.system(size: 21, weight: .bold, design: .serif)).foregroundStyle(.primary)
                    Capsule().fill(Color.primary.opacity(0.2)).frame(width: 68, height: 5)
                    Capsule().fill(Color.primary.opacity(0.2)).frame(width: 48, height: 5)
                }
                .padding(11)
                .frame(width: 102, alignment: .leading)
                .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 7, y: 3)
                .scaleEffect(0.92 + 0.08 * p, anchor: .bottomLeading)
                .opacity(p)
                .position(x: 91, y: 46)
            }
        case .focusKeys:
            game()
            HStack(spacing: 9) {
                Image(systemName: "apple.logo").font(.system(size: 12))
                Capsule().fill(Color.primary.opacity(0.3)).frame(width: 24, height: 5)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 4)
                    .overlay(Capsule().strokeBorder(Color.accentColor, lineWidth: 2.5))
                Capsule().fill(Color.primary.opacity(0.3)).frame(width: 20, height: 5)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .frame(width: Self.canvas.width, height: 23)
            .background(Color(nsColor: .windowBackgroundColor))
            .shadow(color: .black.opacity(0.15 * p), radius: 3, y: 1)
            .position(x: 85, y: 11.5 - 24 * (1 - p))
        case .controlClick:
            game()
            if p > 0 {
                ArtMenu(width: 76) {
                    ArtMenuRow(width: 40)
                    ArtMenuRow(width: 30)
                    ArtMenuRow(width: 44)
                }
                .scaleEffect(0.94 + 0.06 * p, anchor: .topLeading)
                .opacity(p)
                .position(x: 90, y: 59)
            }
            ArtCursor(pressed: story.down)
                .position(glide(from: CGPoint(x: 118, y: 80), to: CGPoint(x: 50, y: 32), bend: 14))
        case .cursor:
            game()
            ArtDock().position(x: 85, y: 128 - 40 * p)
            Capsule()
                .fill(.white.opacity(0.9))
                .frame(width: 86, height: 4)
                .blur(radius: 2)
                .position(x: 85, y: 106)
                .opacity(story.pulse.map { sin($0 * .pi) } ?? 0)
            ArtCursor()
                .scaleEffect(1.3, anchor: .topLeading)
                .position(glide(from: CGPoint(x: 112, y: 46), to: CGPoint(x: 88, y: 92), bend: -10))
        case .display:
            game(dim: false)
            Color.black.opacity(0.82 * p)
        }
    }

    @ViewBuilder
    private var cause: some View {
        let shown = story.cap
        Group {
            switch rule {
            case .cursor:
                EmptyView()
            case .swipes:
                let touch = story.phase > 1.15 && story.phase < Self.lift
                ArtTrackpad(touch: touch, swipe: -5 + 10 * GameStory.ramp(story.phase, 1.25, 0.4), width: 34, fingers: 3)
            case .display:
                ArtKey(down: false, width: 26, height: 18) { Image(systemName: "gamecontroller.fill") }
            default:
                HStack(spacing: 3) {
                    ForEach(Array(glyphs.enumerated()), id: \.offset) { _, glyph in
                        ArtKey(down: story.down, width: max(19, CGFloat(glyph.count) * 5.6 + 10), height: 18) {
                            if let symbol = Self.symbols[glyph] { Image(systemName: symbol) } else { Text(verbatim: glyph) }
                        }
                    }
                }
                .animation(.easeOut(duration: 0.1), value: story.down)
            }
        }
        .overlay {
            if let pulse = story.pulse {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.accentColor, lineWidth: 1.5)
                    .padding(-3)
                    .scaleEffect(1 + 0.22 * pulse)
                    .opacity(1 - pulse)
            }
        }
        .opacity(shown)
        .offset(y: 5 * (1 - shown))
    }

    private static let lift = GameStory.press + 0.3
    private static let symbols = ["🌐": "globe", "🎤": "mic.fill"]

    private var glyphs: [String] {
        keys.first { !$0.isEmpty && $0 != "…" }.map(KeyCaps.caps) ?? []
    }

    private func glide(from: CGPoint, to: CGPoint, bend: CGFloat) -> CGPoint {
        let t = story.reach
        let x = from.x + (to.x - from.x) * t, y = from.y + (to.y - from.y) * t
        let arc = 4 * t * (1 - t) * bend, length = max(hypot(to.x - from.x, to.y - from.y), 1)
        return CGPoint(x: x - (to.y - from.y) / length * arc + 6, y: y + (to.x - from.x) / length * arc + 9)
    }

    private func game(dim: Bool = true) -> some View {
        ZStack {
            GameScene(time: story.time)
            if dim { Color.black.opacity(0.2 * story.hit) }
        }
        .frame(width: 196, height: 108)
        .offset(x: 9)
        .frame(width: Self.canvas.width, height: Self.canvas.height)
    }

    private func popup(_ frame: CGRect, radius: CGFloat? = nil, @ViewBuilder content: () -> some View) -> some View {
        let p = story.hit
        return ZStack {
            game()
            if p > 0 {
                ZStack {
                    game().glassBackdrop(frame, radius: radius)
                    content().position(x: frame.midX, y: frame.midY)
                }
                .scaleEffect(0.96 + 0.04 * p)
                .opacity(p)
            }
        }
    }

    private func zoom(to point: CGPoint, width: CGFloat) -> some View {
        let p = story.hit, scale = 1 - (1 - width / Self.canvas.width) * p
        return game(dim: false)
            .clipShape(RoundedRectangle(cornerRadius: 4 / scale * p, style: .continuous))
            .shadow(color: .black.opacity(0.3 * p), radius: 4 / scale, y: 1.5 / scale)
            .scaleEffect(scale)
            .position(x: 85 + (point.x - 85) * p, y: 54 + (point.y - 54) * p)
    }

    private var desk: some View {
        ArtScreen(glow: 1, radius: 0) { Color.clear }
    }

    private func card(game: Bool = false, width: CGFloat = 50) -> some View {
        ZStack(alignment: .topLeading) {
            if game {
                self.game(dim: false).scaleEffect(width / 156)
            } else {
                Color(nsColor: .windowBackgroundColor)
                HStack(spacing: 2.5) {
                    ForEach([Art.red, Art.yellow, Art.green], id: \.self) { Circle().fill($0).frame(width: 4, height: 4) }
                }
                .padding(4)
            }
        }
        .frame(width: width, height: width * 0.62)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 1.5)
    }
}

struct GameScene: View {
    var time = GameStory.start
    @Environment(\.colorScheme) private var scheme

    private static let hero: CGFloat = 58, ground: CGFloat = 82
    private static let stars: [CGPoint] = [
        CGPoint(x: 46, y: 14), CGPoint(x: 70, y: 32), CGPoint(x: 96, y: 12), CGPoint(x: 120, y: 30), CGPoint(x: 182, y: 16), CGPoint(x: 18, y: 32), CGPoint(x: 176, y: 46),
    ]

    var body: some View {
        let night = scheme == .dark
        Canvas { context, _ in Self.draw(&context, time, night) } symbols: {
            Text(Image(systemName: "heart.fill")).font(.system(size: 6.5)).foregroundStyle(Art.red).tag(0)
        }
    }

    private static func circle(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }

    private static func draw(_ c: inout GraphicsContext, _ t: Double, _ night: Bool) {
        let sky = night ? [Color(red: 0.05, green: 0.07, blue: 0.19), Color(red: 0.19, green: 0.19, blue: 0.40)] : [Color(red: 0.52, green: 0.75, blue: 0.98), Color(red: 0.87, green: 0.94, blue: 1)]
        c.fill(Path(CGRect(x: 0, y: 0, width: 196, height: 108)), with: .linearGradient(Gradient(colors: sky), startPoint: .zero, endPoint: CGPoint(x: 0, y: 92)))
        if night {
            for (index, star) in stars.enumerated() {
                let glow = 0.55 + 0.35 * sin(t * .pi / 2 + Double(index) * 1.9)
                c.fill(circle(star.x, star.y, index % 3 == 0 ? 1.1 : 0.8), with: .color(.white.opacity(glow)))
            }
            let moon = Color(red: 0.98, green: 0.95, blue: 0.84)
            c.fill(circle(150, 26, 16), with: .color(moon.opacity(0.07)))
            c.fill(circle(150, 26, 12), with: .color(moon.opacity(0.08)))
            var crescent = c
            crescent.clip(to: circle(155, 22.5, 7.6), options: .inverse)
            crescent.fill(circle(150, 26, 8.5), with: .color(moon))
        } else {
            let sun = Color(red: 1, green: 0.83, blue: 0.42)
            c.fill(circle(150, 26, 16), with: .color(sun.opacity(0.22)))
            c.fill(circle(150, 26, 9.5), with: .color(sun))
            var clouds = Path()
            for cloud in [CGPoint(x: 46, y: 30), CGPoint(x: 104, y: 17), CGPoint(x: 186, y: 44)] {
                clouds.addRoundedRect(in: CGRect(x: cloud.x - 13, y: cloud.y - 3, width: 26, height: 8), cornerSize: CGSize(width: 4, height: 4))
                clouds.addPath(circle(cloud.x - 4, cloud.y - 3, 6))
                clouds.addPath(circle(cloud.x + 5, cloud.y - 1.5, 4.5))
            }
            c.fill(clouds, with: .color(.white.opacity(0.92)))
        }

        let hill = CGFloat(GameStory.mod(t * 21, 84))
        var far = Path(), near = Path()
        for k in -1...2 {
            let x = CGFloat(k) * 84 - hill
            far.addEllipse(in: CGRect(x: x - 22, y: 64, width: 108, height: 70))
            near.addEllipse(in: CGRect(x: x + 42, y: 74, width: 64, height: 46))
        }
        c.fill(far, with: .color(night ? Color(red: 0.13, green: 0.16, blue: 0.32) : Color(red: 0.71, green: 0.88, blue: 0.76)))
        c.fill(near, with: .color(night ? Color(red: 0.16, green: 0.20, blue: 0.38) : Color(red: 0.61, green: 0.83, blue: 0.68)))

        let shift = CGFloat(GameStory.mod(t * 28 - 111.2, 56))
        let gaps = (-1...4).map { CGFloat($0) * 56 - shift }
        var grass = Path(), soil = Path()
        for gap in gaps {
            grass.addRoundedRect(in: CGRect(x: gap + 7, y: ground, width: 42, height: 40), cornerSize: CGSize(width: 5, height: 5), style: .continuous)
            soil.addRect(CGRect(x: gap + 7, y: ground + 4.5, width: 42, height: 40))
        }
        c.fill(grass, with: .color(night ? Color(red: 0.40, green: 0.47, blue: 0.78) : Color(red: 0.42, green: 0.77, blue: 0.50)))
        c.fill(soil, with: .color(night ? Color(red: 0.20, green: 0.23, blue: 0.44) : Color(red: 0.97, green: 0.85, blue: 0.67)))

        let gold = Color(red: 1, green: 0.78, blue: 0.24), shine = Color(red: 1, green: 0.92, blue: 0.62)
        let spin = 0.55 + 0.45 * abs(cos(t * .pi))
        for gap in gaps where gap > hero - 10 {
            let taken = max(0, hero - gap) / 10, y = 50 - 8 * taken, fade = 1 - taken
            if night { c.fill(circle(gap, y, 7), with: .color(gold.opacity(0.18 * fade))) }
            let w = 3.6 * spin * (1 + 0.4 * taken), h = 3.6 * (1 + 0.4 * taken)
            c.fill(Path(ellipseIn: CGRect(x: gap - w, y: y - h, width: w * 2, height: h * 2)), with: .color(gold.opacity(fade)))
            c.fill(Path(ellipseIn: CGRect(x: gap - w * 0.55, y: y - h * 0.55, width: w * 1.1, height: h * 1.1)), with: .color(shine.opacity(fade)))
        }

        let gap = gaps.min { abs($0 - hero) < abs($1 - hero) } ?? 0
        let jump = (hero + 14 - gap) / 28
        let air = jump > 0 && jump < 1
        let lift = air ? 60 * jump * (1 - jump) : 0
        let squash = air ? -0.09 * abs(1 - 2 * jump) : jump >= 1 && jump < 1.2 ? 0.14 * (1.2 - jump) / 0.2 : 0
        let pose = PetPose(step: t * .pi * 5, lift: lift, squash: squash, air: air)
        var figure = c
        figure.translateBy(x: hero, y: ground)
        if abs(gap - hero) > 9 { PetFigure.shadow(pose) { figure.fill($0, with: .color($1)) } }
        PetFigure.draw(pose, night: night) { figure.fill($0, with: .color($1)) }

        guard let heart = c.resolveSymbol(id: 0) else { return }
        for index in 0..<3 {
            c.draw(heart, at: CGPoint(x: 16 + 8.5 * CGFloat(index), y: 11))
        }
    }
}
