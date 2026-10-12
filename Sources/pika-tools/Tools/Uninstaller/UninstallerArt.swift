import SwiftUI

struct UninstallerArt: View {
    var replay = 0
    @Environment(\.appDropTarget) private var target
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.0, 0.8, 0.45, 0.45, 0.45, 0.7, 0.5, 86_400.0]

    var body: some View {
        let lit = target != nil
        IllustrationRow(loop: Self.durations, replay: replay) { tick in
            UninstallerScene(step: reduceMotion ? 0 : tick % Self.durations.count, lit: lit)
        }
    }
}

private struct UninstallerScene: View {
    let step: Int
    let lit: Bool

    private static let bin = CGPoint(x: 226, y: 78)
    private static let mouth = CGPoint(x: 226, y: 60)
    private static let tile = CGPoint(x: 100, y: 66)
    private static let files = [CGPoint(x: 38, y: 34), CGPoint(x: 56, y: 68), CGPoint(x: 36, y: 100)]

    var body: some View {
        Stage {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 96, height: 96)
                .blur(radius: 24)
                .opacity(lit ? 0.5 : 0)
                .position(Self.bin)
                .animation(.smooth(duration: 0.3), value: lit)
            ForEach(0..<3, id: \.self) { index in
                ArtFile()
                    .modifier(Glide(gone: (2 + index...5).contains(step), rest: Self.files[index], mouth: Self.mouth, scale: 0.7))
            }
            AppTile()
                .modifier(Glide(gone: (1...5).contains(step), rest: Self.tile, mouth: Self.mouth, scale: 1))
            Bin(open: (1...4).contains(step) || lit, lit: lit)
                .position(Self.bin)
        }
    }
}

private struct Glide: ViewModifier {
    let gone: Bool
    let rest: CGPoint
    let mouth: CGPoint
    let scale: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(gone ? scale * 0.4 : scale)
            .position(gone ? mouth : rest)
            .animation(gone && !reduceMotion ? .smooth(duration: 0.6) : nil, value: gone)
            .opacity(gone ? 0 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3).delay(gone ? 0.35 : 0), value: gone)
    }
}

private struct AppTile: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        shape
            .fill(LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            .overlay(shape.hairline(Color.white.opacity(0.25)))
            .overlay {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)
            .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }
}

private struct Bin: View {
    let open: Bool
    let lit: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let ease: Animation? = reduceMotion ? nil : .smooth(duration: 0.3)
        ZStack(alignment: .top) {
            BinBody()
                .fill(Art.metal(scheme))
                .overlay { BinBody().fill(Color.accentColor.opacity(lit ? 0.45 : 0)) }
                .overlay { BinBody().stroke(Color.primary.opacity(0.22), lineWidth: 0.75) }
                .overlay {
                    HStack(spacing: 7) {
                        ForEach(0..<3, id: \.self) { _ in Capsule().fill(Color.primary.opacity(0.2)).frame(width: 3, height: 32) }
                    }
                    .offset(y: 3)
                }
                .frame(width: 50, height: 56)
                .offset(y: 8)
            lid
        }
        .frame(width: 66, height: 64)
        .scaleEffect(lit ? 1.06 : 1, anchor: .bottom)
        .animation(ease, value: lit)
        .animation(ease, value: open)
    }

    private var lid: some View {
        let slab = RoundedRectangle(cornerRadius: 3.5, style: .continuous)
        return ZStack(alignment: .top) {
            Capsule()
                .fill(Art.metal(scheme))
                .overlay(Capsule().stroke(Color.primary.opacity(0.22), lineWidth: 0.75))
                .frame(width: 16, height: 5)
            slab
                .fill(Art.metal(scheme))
                .overlay(slab.hairline(Color.primary.opacity(0.22)))
                .frame(width: 62, height: 8)
                .offset(y: 4)
        }
        .frame(width: 62, height: 12, alignment: .top)
        .rotationEffect(.degrees(open ? -28 : 0), anchor: .bottomLeading)
    }
}

private struct BinBody: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.08
        let corner: CGFloat = 6
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - corner))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - inset - corner, y: rect.maxY), control: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + inset + corner, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX + inset, y: rect.maxY - corner), control: CGPoint(x: rect.minX + inset, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
