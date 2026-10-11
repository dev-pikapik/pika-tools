import SwiftUI

extension SystemShortcutFrame {
    @ViewBuilder var pointerScene: some View {
        if let pointer = entry.pointer {
            let hit = story.hit
            switch pointer.kind {
            case .swipe:
                Color(white: 0.06)
                desk.offset(x: -176 * (1 - hit))
                game.offset(x: 176 * hit)
            case .mission:
                desk
                Color.black.opacity(0.45 * hit)
                ForEach([24.0, 146.0], id: \.self) { x in
                    window.scaleEffect(0.9 + 0.1 * hit).opacity(hit).position(x: x, y: 70)
                }
                game.clipShape(RoundedRectangle(cornerRadius: 10 * hit, style: .continuous))
                    .shadow(color: .black.opacity(0.3 * hit), radius: 6, y: 2)
                    .scaleEffect(1 - 0.58 * hit)
                    .offset(y: 16 * hit)
            case .pinch:
                desk
                Color.black.opacity(0.3 * hit)
                VStack(spacing: 7) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 7) {
                            ForEach(0..<4, id: \.self) { column in tile(Self.tiles[row * 4 + column]) }
                        }
                    }
                }
                .scaleEffect(0.9 + 0.1 * hit).opacity(hit)
                game.scaleEffect(1 - 0.9 * hit).opacity(1 - hit)
            case .edge:
                game
                notificationStack
            case .corner:
                let right = (pointer.corner ?? 1) % 2 == 1, bottom = (pointer.corner ?? 1) >= 2
                let reach = CGFloat(story.reach)
                game
                RadialGradient(
                    colors: [.white.opacity(0.85), .clear],
                    center: UnitPoint(x: right ? 1 : 0, y: bottom ? 1 : 0), startRadius: 0, endRadius: 46
                )
                .opacity(story.reach)
                panel {
                    Image(systemName: pointer.symbol).font(.system(size: 25)).foregroundStyle(Color.accentColor).padding(17)
                }
                ArtCursor()
                    .position(x: 85 + ((right ? 160 : 3) - 85) * reach + 6, y: 54 + ((bottom ? 100 : 3) - 54) * reach + 9)
            case .button:
                game
                panel {
                    VStack(spacing: 9) {
                        Image(systemName: pointer.symbol).font(.system(size: 25)).foregroundStyle(Color.accentColor)
                        Capsule().fill(Color.primary.opacity(0.2)).frame(width: 62, height: 5)
                    }.padding(13)
                }
            }
        }
    }

    func pointerCause(_ pointer: PointerTrigger) -> some View {
        let touch = story.phase > 1.15 && story.phase < GameStory.press + 0.3
        let move = CGFloat(GameStory.ramp(story.phase, 1.25, 0.4))
        return HStack(spacing: 7) {
            switch pointer.kind {
            case .corner:
                ForEach(Array(pointer.modifiers.enumerated()), id: \.offset) { _, glyph in
                    ArtKey(down: story.down, width: 19, height: 18) { Text(verbatim: String(glyph)) }
                }
            case .button:
                ArtMouse(sideButtons: true, forward: touch).scaleEffect(0.7).frame(width: 17, height: 27)
            default:
                if pointer.trackpad {
                    ArtTrackpad(
                        touch: touch,
                        slide: pointer.kind == .mission ? 4 - 8 * move : 0,
                        swipe: pointer.kind == .swipe ? -5 + 10 * move : pointer.kind == .edge ? 12 - 20 * move : 0,
                        pinch: pointer.kind == .pinch ? 1.3 - 0.6 * move : 1,
                        width: 34, fingers: pointer.fingers
                    )
                }
                if pointer.mouse {
                    magicMouse(pointer.kind == .mission ? tap : touch, shift: pointer.kind == .swipe ? -3 + 6 * move : 0)
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: story.down)
        .overlay {
            if let pulse = story.pulse, pointer.kind != .corner || !pointer.modifiers.isEmpty {
                RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(Color.accentColor, lineWidth: 1.5)
                    .padding(-3).scaleEffect(1 + 0.22 * pulse).opacity(1 - pulse)
            }
        }
        .opacity(story.cap)
        .offset(y: 5 * (1 - story.cap))
    }

    private static let tiles: [Color] = [.teal, .orange, .pink, .indigo, .green, .blue, .purple, .red]

    private var tap: Bool { (1.2..<1.32).contains(story.phase) || (1.45..<1.57).contains(story.phase) }

    private var desk: some View { ArtScreen(glow: 1, radius: 0) { Color.clear } }

    private var window: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color(nsColor: .windowBackgroundColor))
            .frame(width: 40, height: 26)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 2.5) {
                    ForEach([Art.red, Art.yellow, Art.green], id: \.self) { Circle().fill($0).frame(width: 3.5, height: 3.5) }
                }.padding(3.5)
            }
            .shadow(color: .black.opacity(0.3), radius: 4, y: 1.5)
    }

    private func tile(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .top, endPoint: .bottom))
            .frame(width: 24, height: 24)
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
    }

    private func magicMouse(_ touching: Bool, shift: CGFloat) -> some View {
        ArtMouse()
            .overlay {
                HStack(spacing: 3) {
                    ForEach(0..<2, id: \.self) { _ in Circle().frame(width: 6, height: 6) }
                }
                .foregroundStyle(Color.accentColor)
                .opacity(touching ? 0.9 : 0)
                .offset(x: shift, y: 3)
            }
            .scaleEffect(0.7)
            .frame(width: 17, height: 27)
    }
}
