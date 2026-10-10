import SwiftUI

struct SystemShortcutArt: View {
    let entry: SystemGameShortcut
    var on: Bool
    var background = false
    @State private var origin = (r: 0.0, g: 0.0)

    var body: some View {
        Group {
            if entry.kind == .existing, let rule = entry.previewRule {
                GameRuleArt(rule: rule, keys: entry.text.map { [$0] } ?? [], on: on)
            } else {
                ArtTimeline { time in
                    SystemShortcutFrame(entry: entry, story: time.map(story) ?? .still(on: on), background: background)
                }
            }
        }
        .onChange(of: on) { old, new in
            let time = Date.now.timeIntervalSinceReferenceDate
            let game = origin.g + GameStory.game(lead + origin.r + time, on: old)
            origin = (GameStory.replay - lead - time, game - GameStory.game(GameStory.replay, on: new))
        }
    }

    private var lead: Double { Double(entry.id % 19) * 2.3 }

    private func story(_ time: Double) -> GameStory {
        let phase = lead + origin.r + time
        return GameStory(phase: GameStory.mod(phase, GameStory.period(on)), time: origin.g + GameStory.game(phase, on: on), on: on)
    }
}

struct SystemShortcutFrame: View {
    let entry: SystemGameShortcut
    let story: GameStory
    var height: CGFloat = 108
    var background = false

    var body: some View {
        let scale = height / 108
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        Color.clear
            .frame(width: 170 * scale, height: height)
            .overlay {
                ZStack {
                    scene
                    keys.position(x: 85, y: 94)
                }
                .frame(width: 170, height: 108)
                .scaleEffect(scale)
            }
            .clipShape(shape)
            .overlay(shape.hairline(Color.primary.opacity(0.14)))
            .shadow(color: .black.opacity(0.18), radius: height / 18, y: height / 36)
            .accessibilityHidden(true)
    }

    private var game: some View {
        GameScene(time: story.time)
            .frame(width: 196, height: 108)
            .offset(x: 9)
            .frame(width: 170, height: 108)
    }

    @ViewBuilder private var scene: some View {
        let hit = story.hit
        switch entry.kind {
        case .screenshot:
            game
            Color.white.opacity(hit * 0.65)
            if hit > 0 {
                game.scaleEffect(0.26).frame(width: 44, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(.white, lineWidth: 1))
                    .shadow(radius: 4)
                    .opacity(hit)
                    .position(x: 139, y: 70)
            }
        case .selection:
            game
            Color.black.opacity(0.4 * hit)
            if hit > 0 {
                Rectangle().strokeBorder(.white, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .frame(width: 108, height: 63).position(x: 85, y: 47)
                    .opacity(hit)
                Image(systemName: "plus").font(.system(size: 15, weight: .light)).foregroundStyle(.white)
                    .position(x: 32 + 105 * story.reach, y: 17 + 60 * story.reach).opacity(hit)
            }
        case .capturePanel:
            game
            if hit > 0 {
                HStack(spacing: 9) {
                    ForEach(["rectangle", "rectangle.dashed", "record.circle", "xmark"], id: \.self) { symbol in
                        Image(systemName: symbol).font(.system(size: 12, weight: .medium))
                            .foregroundStyle(symbol == "record.circle" ? Art.red : Color.primary)
                    }
                }
                .frame(width: 124, height: 28)
                .artGlass(radius: 9)
                .position(x: 85, y: 72 + 15 * (1 - hit)).opacity(hit)
            }
        case .zoom:
            ArtScreen(glow: 1, radius: 0) { Color.clear }
            game.scaleEffect(1 + (entry.rawName.lowercased().contains("out") ? -0.35 : 1.1) * hit, anchor: .center)
            hud(symbol: "plus.magnifyingglass", progress: 0.7)
        case .contrast:
            game.contrast(1 + (entry.rawName.lowercased().contains("decrease") ? -0.6 : 2) * hit)
            hud(symbol: entry.kind.symbol, progress: 0.8)
        case .invert:
            ZStack {
                game.opacity(1 - hit)
                game.colorInvert().opacity(hit)
            }
            hud(symbol: entry.kind.symbol, progress: 0.7)
        case .brightness:
            game.brightness((entry.rawName.lowercased().contains("decrease") ? -0.45 : 0.35) * hit)
            hud(symbol: entry.kind.symbol, progress: entry.rawName.lowercased().contains("decrease") ? 0.25 : 0.8)
        case .volume:
            game
            hud(symbol: entry.kind.symbol, progress: 0.65)
        case .window:
            ArtScreen(glow: 1, radius: 0) { Color.clear }
            let raw = entry.rawName.lowercased()
            let x = raw.contains("left") ? -41.0 : raw.contains("right") ? 41.0 : 0
            let y = raw.contains("top") ? -25.0 : raw.contains("bottom") ? 25.0 : 0
            let size = raw.contains("fill") || raw.contains("fullscreen") ? 1.08 : raw.contains("center") ? 0.72 : 0.52
            game.clipShape(RoundedRectangle(cornerRadius: 4 * hit))
                .shadow(color: .black.opacity(0.3 * hit), radius: 4, y: 2)
                .scaleEffect(1 + (size - 1) * hit)
                .offset(x: x * hit, y: y * hit)
        case .language:
            game
            if background {
                Text(verbatim: story.phase >= GameStory.press ? "АБВ" : "ABC")
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 5).padding(.vertical, 3).artGlass(radius: 5)
                    .position(x: 150, y: 13)
            } else {
            panel {
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Image(systemName: "globe"); Text(verbatim: "ABC") }
                    HStack { Image(systemName: "checkmark"); Text(verbatim: "АБВ") }
                        .foregroundStyle(Color.accentColor)
                }.font(.system(size: 12, weight: .medium)).padding(12)
            }
            }
        case .note:
            game
            panel {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "note.text").font(.system(size: 19)).foregroundStyle(Art.yellow)
                    ForEach([62.0, 49, 57], id: \.self) { width in Capsule().fill(Color.primary.opacity(0.2)).frame(width: width, height: 4) }
                }.padding(12)
            }
        case .notifications:
            game
            if hit > 0 {
                VStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 6) {
                            Image(systemName: "bell.fill").foregroundStyle(Color.accentColor)
                            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 44, height: 4)
                        }.font(.system(size: 10)).padding(8).artGlass(radius: 7)
                    }
                }.offset(x: 35 * (1 - hit)).opacity(hit).position(x: 125, y: 46)
            }
        case .voice:
            game
            panel {
                HStack(spacing: 5) {
                    Image(systemName: entry.kind.symbol).font(.system(size: 21)).foregroundStyle(Color.accentColor)
                    ForEach(Array([12.0, 24, 17, 28, 12].enumerated()), id: \.offset) { _, size in
                        Capsule().fill(Color.accentColor).frame(width: 3, height: size)
                    }
                }.padding(14)
            }
        case .captions:
            game
            panel {
                VStack(alignment: .leading, spacing: 7) {
                    Image(systemName: entry.kind.symbol).foregroundStyle(Color.accentColor)
                    ForEach([70.0, 58, 64], id: \.self) { width in
                        Capsule().fill(Color.primary.opacity(0.35)).frame(width: width, height: 4)
                    }
                }.padding(12)
            }
        case .presenter:
            game
            if hit > 0 {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: entry.rawName.lowercased().contains("small") ? 37 : 68))
                    .foregroundStyle(.white, Color.accentColor)
                    .background(Circle().fill(Color.accentColor))
                    .scaleEffect(0.7 + 0.3 * hit).opacity(hit)
                    .position(x: 127, y: 59)
            }
        case .focusMode:
            game
            panel {
                Image(systemName: entry.kind.symbol).font(.system(size: 25)).foregroundStyle(.purple)
                    .padding(17)
            }
        case .forceQuit:
            game
            panel {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach([Color.teal, .orange, .pink], id: \.self) { color in
                        HStack {
                            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 9, height: 9)
                            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 45, height: 4)
                        }
                    }
                    Capsule().fill(Art.red).frame(width: 37, height: 7).frame(maxWidth: .infinity, alignment: .trailing)
                }.padding(12)
            }
        case .existing, .other:
            game
            panel {
                VStack(spacing: 9) {
                    Image(systemName: entry.kind.symbol).font(.system(size: 25)).foregroundStyle(Color.accentColor)
                    Capsule().fill(Color.primary.opacity(0.2)).frame(width: 62, height: 5)
                }.padding(13)
            }
        }
    }

    private var keys: some View {
        let glyphs = entry.text.map(KeyCaps.caps) ?? []
        return HStack(spacing: 3) {
            if glyphs.isEmpty {
                ArtKey(down: story.down, width: 24, height: 18) { Image(systemName: entry.kind.symbol) }
            } else {
                ForEach(Array(glyphs.enumerated()), id: \.offset) { _, glyph in
                    ArtKey(down: story.down, width: max(19, CGFloat(glyph.count) * 5.6 + 10), height: 18) { Text(verbatim: glyph) }
                }
            }
        }
        .overlay {
            if let pulse = story.pulse {
                RoundedRectangle(cornerRadius: 7).strokeBorder(Color.accentColor, lineWidth: 1.5)
                    .padding(-3).scaleEffect(1 + 0.22 * pulse).opacity(1 - pulse)
            }
        }
        .opacity(story.cap)
        .offset(y: 5 * (1 - story.cap))
        .animation(.easeOut(duration: 0.1), value: story.down)
    }

    private func panel<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content().artGlass(radius: 11)
            .scaleEffect(0.92 + 0.08 * story.hit)
            .opacity(story.hit)
            .position(x: 99, y: 43)
    }

    private func hud(symbol: String, progress: CGFloat) -> some View {
        panel {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 24)).foregroundStyle(.primary)
                Capsule().fill(Color.primary.opacity(0.15)).frame(width: 65, height: 5)
                    .overlay(alignment: .leading) { Capsule().fill(Color.primary).frame(width: 65 * progress, height: 5) }
            }.padding(14)
        }
    }
}
