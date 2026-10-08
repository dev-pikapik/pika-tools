import SwiftUI

struct GameRuleArt: View {
    let rule: GameRule
    @Environment(\.isEnabled) private var isEnabled

    private static let canvas = CGSize(width: 120, height: 76)
    private static let size = CGSize(width: 50, height: 32)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)
        Color.clear
            .frame(width: Self.size.width, height: Self.size.height)
            .overlay {
                ZStack { scene }
                    .frame(width: Self.canvas.width, height: Self.canvas.height)
                    .scaleEffect(Self.size.width / Self.canvas.width)
            }
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
            .opacity(isEnabled ? 1 : 0.5)
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
            ArtWindow(size: CGSize(width: 96, height: 58)) { GameScene(hop: false).scaleEffect(0.5).frame(width: 96, height: 44).clipped() }
                .position(x: 60, y: 40)
            Circle()
                .strokeBorder(.white, lineWidth: 2.5)
                .frame(width: 16, height: 16)
                .position(x: 22, y: 18)
        case .appSwitcher:
            game
            HStack(spacing: 6) {
                ForEach([Color.teal, .orange, .pink], id: \.self) { color in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 22, height: 22)
                        .padding(3)
                        .background(color == .orange ? Color.white.opacity(0.45) : .clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(6)
            .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .hide:
            game
            Image(systemName: "arrow.down")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
                .position(x: 60, y: 28)
            ArtDock().scaleEffect(0.75).position(x: 60, y: 64)
        case .spotlight:
            game
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").font(.system(size: 12, weight: .bold)).foregroundStyle(.secondary)
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 40, height: 5)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(width: 96, height: 26)
            .background(Color(nsColor: .windowBackgroundColor), in: Capsule())
            .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
            .position(x: 60, y: 30)
        case .siri:
            game
            Circle()
                .fill(AngularGradient(colors: [.pink, .purple, .blue, .cyan, .pink], center: .center))
                .frame(width: 34, height: 34)
                .overlay(Circle().fill(.white.opacity(0.35)).frame(width: 14, height: 14).blur(radius: 4))
                .shadow(color: .purple.opacity(0.8), radius: 8)
                .position(x: 90, y: 24)
        case .launchpad:
            desk.blur(radius: 3)
            Grid(horizontalSpacing: 9, verticalSpacing: 9) {
                ForEach(0..<2, id: \.self) { row in
                    GridRow {
                        ForEach(0..<4, id: \.self) { column in
                            let color = [Color.teal, .orange, .pink, .green, .indigo, .yellow, .red, .blue][row * 4 + column]
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 18, height: 18)
                        }
                    }
                }
            }
        case .missionControl:
            desk
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(.white.opacity(index == 0 ? 0.85 : 0.4))
                        .frame(width: 24, height: 13)
                }
            }
            .position(x: 60, y: 13)
            Grid(horizontalSpacing: 8, verticalSpacing: 6) {
                GridRow { card(game: true); card() }
                GridRow { card(); card() }
            }
            .position(x: 60, y: 48)
        case .appWindows:
            desk
            Color.black.opacity(0.45)
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { _ in card(game: true, width: 32) }
            }
            .position(x: 60, y: 34)
            ArtDock().scaleEffect(0.6).position(x: 60, y: 68)
        case .showDesktop:
            desk
            ArtFile().scaleEffect(1.1).position(x: 60, y: 40)
            card(game: true, width: 46).position(x: 4, y: 30)
            card(width: 46).position(x: 116, y: 50)
        case .desktops:
            HStack(spacing: 3) {
                game.frame(width: 70)
                desk.frame(width: 70)
            }
            .offset(x: -15)
            arrows
        case .desktopNumbers:
            desk
            HStack(spacing: 6) {
                ForEach(1..<4, id: \.self) { number in
                    ZStack {
                        if number == 1 { game } else { Color.white.opacity(0.3) }
                        Text(verbatim: "\(number)").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    }
                    .frame(width: 32, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                }
            }
        case .swipes:
            plain
            ArtTrackpad(touch: true).scaleEffect(1.3)
            arrows.offset(y: -2)
        case .emoji:
            game
            Grid(horizontalSpacing: 4, verticalSpacing: 3) {
                GridRow { Text(verbatim: "😀"); Text(verbatim: "🎮"); Text(verbatim: "⭐️") }
                GridRow { Text(verbatim: "🍕"); Text(verbatim: "🐱"); Text(verbatim: "🚀") }
            }
            .font(.system(size: 14))
            .padding(6)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
            .position(x: 68, y: 36)
        case .lookUp:
            game
            VStack(alignment: .leading, spacing: 5) {
                Text(verbatim: "Aa").font(.system(size: 15, weight: .bold, design: .serif)).foregroundStyle(.primary)
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 48, height: 4)
                Capsule().fill(Color.primary.opacity(0.2)).frame(width: 34, height: 4)
            }
            .padding(8)
            .frame(width: 72, alignment: .leading)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
            .position(x: 64, y: 38)
        case .focusKeys:
            game
            HStack(spacing: 6) {
                Image(systemName: "apple.logo").font(.system(size: 9))
                Capsule().fill(Color.white).frame(width: 18, height: 9)
                    .overlay(Capsule().strokeBorder(Color.accentColor, lineWidth: 2.5).padding(-3))
                Capsule().fill(Color.primary.opacity(0.3)).frame(width: 14, height: 4)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .frame(width: 120, height: 16)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.85))
            .position(x: 60, y: 8)
            Image(systemName: "keyboard.fill")
                .font(.system(size: 26))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
                .position(x: 60, y: 50)
        case .globe:
            plain
            ArtKey(down: false, width: 40) { Image(systemName: "globe") }.scaleEffect(1.5)
        case .controlClick:
            game
            ArtCursor().cursor(at: CGPoint(x: 34, y: 22))
            ArtMenu(width: 54) {
                ArtMenuRow(width: 28, active: true)
                ArtMenuRow(width: 22)
                ArtMenuRow(width: 30)
            }
            .position(x: 76, y: 44)
        case .cursor:
            game
            ArtDock().scaleEffect(0.75).position(x: 60, y: 86).opacity(0.5)
            Capsule()
                .fill(.white.opacity(0.9))
                .frame(width: 60, height: 3)
                .blur(radius: 1.5)
                .position(x: 60, y: 75)
            ArtCursor().scaleEffect(1.3).cursor(at: CGPoint(x: 64, y: 52))
        case .display:
            game
            badge(Art.yellow, "sun.max.fill")
        }
    }

    private var game: some View {
        GameScene(hop: false)
            .frame(width: 196, height: 108)
            .scaleEffect(Self.canvas.height / 108)
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
            .font(.system(size: 14, weight: .heavy))
            .foregroundStyle(.white)
            .padding(6)
            .background(.black.opacity(0.45), in: Capsule())
    }

    private func badge(_ color: Color, _ symbol: String) -> some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(Image(systemName: symbol).font(.system(size: 15, weight: .heavy)).foregroundStyle(.white))
            .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
            .position(x: 92, y: 22)
    }

    private func card(game: Bool = false, width: CGFloat = 40) -> some View {
        ZStack {
            if game { self.game.scaleEffect(width / 110) } else { Color(nsColor: .windowBackgroundColor) }
        }
        .frame(width: width, height: width * 0.62)
        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
    }
}
