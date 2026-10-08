import SwiftUI

struct GameRuleArt: View {
    let rule: GameRule
    var height: CGFloat = 108

    private static let canvas = CGSize(width: 170, height: 108)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let scale = height / Self.canvas.height
        Color.clear
            .frame(width: Self.canvas.width * scale, height: height)
            .overlay {
                ZStack { scene }
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
        switch rule {
        case .commandQ:
            game
            badge(Art.red, "xmark")
        case .commandW:
            desk
            ArtWindow(size: CGSize(width: 136, height: 82)) {
                GameScene(hop: false).frame(width: 196, height: 108).scaleEffect(0.7).frame(width: 136, height: 68).clipped()
            }
            .position(x: 85, y: 57)
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 2.5)
                .frame(width: 17, height: 17)
                .position(x: 27, y: 23)
        case .appSwitcher:
            let panel = CGRect(x: 18, y: 28, width: 134, height: 52)
            game
            game.glassBackdrop(panel, radius: 16)
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
            .position(x: panel.midX, y: panel.midY)
        case .hide:
            game
            Image(systemName: "arrow.down")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 3)
                .position(x: 85, y: 38)
            ArtDock().position(x: 85, y: 87)
        case .spotlight:
            let bar = CGRect(x: 17, y: 26, width: 136, height: 32)
            game
            game.glassBackdrop(bar)
            ArtSpotlight(width: bar.width, height: bar.height)
                .position(x: bar.midX, y: bar.midY)
        case .siri:
            game
            Circle()
                .fill(AngularGradient(colors: [.pink, .purple, .blue, .cyan, .pink], center: .center))
                .frame(width: 46, height: 46)
                .overlay(Circle().fill(.white.opacity(0.35)).frame(width: 20, height: 20).blur(radius: 6))
                .shadow(color: .purple.opacity(0.8), radius: 11)
                .position(x: 128, y: 34)
        case .launchpad:
            desk.blur(radius: 4)
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
            .position(x: 85, y: 64)
        case .missionControl:
            desk
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(.white.opacity(index == 0 ? 0.85 : 0.4))
                        .frame(width: 32, height: 18)
                }
            }
            .position(x: 85, y: 15)
            Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow { card(game: true); card() }
                GridRow { card(); card() }
            }
            .position(x: 85, y: 67)
        case .appWindows:
            desk
            Color.black.opacity(0.45)
            HStack(spacing: 9) {
                ForEach(0..<3, id: \.self) { _ in card(game: true, width: 46) }
            }
            .position(x: 85, y: 42)
            ArtDock(icon: 18).position(x: 85, y: 89)
        case .showDesktop:
            desk
            ArtFile().scaleEffect(1.5).position(x: 85, y: 54)
            card(game: true, width: 66).position(x: 6, y: 42)
            card(width: 66).position(x: 164, y: 72)
        case .desktops:
            HStack(spacing: 6) {
                game.frame(width: 82).clipped()
                desk.frame(width: 82)
            }
            arrows
        case .desktopNumbers:
            desk
            HStack(spacing: 9) {
                ForEach(1..<4, id: \.self) { number in
                    ZStack {
                        if number == 1 { game } else { Color.white.opacity(0.3) }
                        Text(verbatim: "\(number)").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    }
                    .frame(width: 44, height: 33)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                }
            }
        case .swipes:
            plain
            ArtTrackpad(touch: true, width: 80, fingers: 3).position(x: 85, y: 37)
            arrows.position(x: 85, y: 86)
        case .emoji:
            let panel = CGRect(x: 46, y: 18, width: 102, height: 66)
            game
            game.glassBackdrop(panel, radius: 12)
            Grid(horizontalSpacing: 7, verticalSpacing: 5) {
                GridRow { Text(verbatim: "😀"); Text(verbatim: "🎮"); Text(verbatim: "⭐️") }
                GridRow { Text(verbatim: "🍕"); Text(verbatim: "🐱"); Text(verbatim: "🚀") }
            }
            .font(.system(size: 20))
            .frame(width: panel.width, height: panel.height)
            .artGlass(radius: 12)
            .position(x: panel.midX, y: panel.midY)
        case .lookUp:
            game
            VStack(alignment: .leading, spacing: 7) {
                Text(verbatim: "Aa").font(.system(size: 21, weight: .bold, design: .serif)).foregroundStyle(.primary)
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 68, height: 5)
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 48, height: 5)
            }
            .padding(11)
            .frame(width: 102, alignment: .leading)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 7, y: 3)
            .position(x: 91, y: 54)
        case .focusKeys:
            game
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
            .position(x: 85, y: 11.5)
            Image(systemName: "keyboard.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 3)
                .position(x: 85, y: 70)
        case .globe:
            plain
            ArtKey(down: false, width: 60, height: 39) { Image(systemName: "globe") }
        case .controlClick:
            game
            ArtMenu(width: 76) {
                ArtMenuRow(width: 40)
                ArtMenuRow(width: 30)
                ArtMenuRow(width: 44)
            }
            .position(x: 52 + 38, y: 34 + 25)
            ArtCursor().cursor(at: CGPoint(x: 50, y: 32))
        case .cursor:
            game
            ArtDock().position(x: 85, y: 126).opacity(0.5)
            Capsule()
                .fill(.white.opacity(0.9))
                .frame(width: 86, height: 4)
                .blur(radius: 2)
                .position(x: 85, y: 106)
            ArtCursor().scaleEffect(1.3, anchor: .topLeading).cursor(at: CGPoint(x: 88, y: 66))
        case .display:
            game
            badge(Art.yellow, "sun.max.fill")
        }
    }

    private var game: some View {
        GameScene(hop: false)
            .frame(width: 196, height: 108)
            .offset(x: 9)
            .frame(width: Self.canvas.width, height: Self.canvas.height)
    }

    private var desk: some View {
        ArtScreen(glow: 1, radius: 0) { Color.clear }
    }

    private var plain: some View {
        LinearGradient(colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.1)], startPoint: .top, endPoint: .bottom)
    }

    private var arrows: some View {
        Image(systemName: "arrow.left.arrow.right")
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(.white)
            .padding(8)
            .background(.black.opacity(0.45), in: Capsule())
    }

    private func badge(_ color: Color, _ symbol: String) -> some View {
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(Image(systemName: symbol).font(.system(size: 20, weight: .heavy)).foregroundStyle(.white))
            .shadow(color: .black.opacity(0.3), radius: 4, y: 1.5)
            .position(x: 130, y: 31)
    }

    private func card(game: Bool = false, width: CGFloat = 50) -> some View {
        ZStack(alignment: .topLeading) {
            if game {
                self.game.scaleEffect(width / 156)
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
