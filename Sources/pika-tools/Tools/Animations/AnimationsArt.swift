import SwiftUI

private extension View {
    func replays(_ taps: Binding<Int>, on value: some Equatable) -> some View {
        contentShape(Rectangle())
            .onTapGesture { taps.wrappedValue += 1 }
            .onChange(of: value) { taps.wrappedValue += 1 }
    }

    func ghost(_ visible: Bool) -> some View {
        saturation(0).opacity(visible ? 0.35 : 0).allowsHitTesting(false)
    }
}

private func ease(_ seconds: Double, delay: Double = 0) -> Animation {
    .easeInOut(duration: max(seconds, 0.001)).delay(delay)
}

struct AnimationsArt: View {
    let values: [AnimationSetting: Double]
    @State private var tick = 5
    @State private var taps = 0

    private func value(_ setting: AnimationSetting) -> Double { values[setting] ?? setting.macOS }

    var body: some View {
        let delay = value(.dockDelay), speed = value(.dockSpeed), sheet = value(.resize)
        let opens = value(.windowOpen) != 0
        let durations = [max(speed, 0.35) + 0.4, 0.6, max(delay + speed, 0.7) + 0.35, 0.55, 0.5, max(sheet, 0.2) + 1.3]
        let step = tick % durations.count
        let docked = step >= 2
        let open = step >= 4
        let dropped = step >= 5
        let ghosts = delay != AnimationSetting.dockDelay.macOS || speed != AnimationSetting.dockSpeed.macOS
        IllustrationRow {
            Stage {
                ArtWindow(size: CGSize(width: 136, height: 76)) {
                    ZStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach([62, 44, 54], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(10)
                        ArtSheet(size: CGSize(width: 88, height: 42))
                            .ghost(sheet != AnimationSetting.resize.macOS)
                            .offset(y: dropped ? 2 : -48)
                            .animation(ease(AnimationSetting.resize.macOS), value: step)
                        ArtSheet(size: CGSize(width: 88, height: 42))
                            .offset(y: dropped ? 2 : -48)
                            .animation(ease(sheet), value: step)
                            .zIndex(-1)
                    }
                    .clipped()
                }
                .scaleEffect(open ? 1 : 0.9)
                .opacity(open ? 1 : 0)
                .animation(step == 4 ? (opens ? .easeOut(duration: 0.2) : nil) : .easeIn(duration: 0.2), value: step)
                .position(x: 150, y: 50)
                ArtDock()
                    .position(x: 150, y: docked ? 107 : 152)
                    .animation(step == 2 ? ease(speed, delay: delay) : step == 0 ? ease(speed) : nil, value: step)
                ArtDock()
                    .ghost(ghosts)
                    .position(x: 150, y: docked ? 107 : 152)
                    .animation(step == 2 ? ease(0.5, delay: 0.2) : step == 0 ? ease(0.5) : nil, value: step)
                if step == 4 {
                    ArtRipple().position(x: 150, y: 103)
                }
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 226, y: 38) : step < 3 ? CGPoint(x: 150, y: 118) : CGPoint(x: 152, y: 100))
                    .animation(step == 2 ? nil : .smooth(duration: 0.5), value: step)
            }
        }
        .replays($taps, on: values)
        .loop($tick, durations, replay: taps)
    }
}

struct AnimationThumb<Content: View>: View {
    let durations: [Double]
    let value: Double
    let content: (Int) -> Content
    @State private var tick: Int
    @State private var taps = 0

    init(durations: [Double], value: Double, @ViewBuilder content: @escaping (Int) -> Content) {
        self.durations = durations
        self.value = value
        self.content = content
        _tick = State(initialValue: durations.count - 1)
    }

    var body: some View {
        IllustrationRow(size: CGSize(width: 104, height: 64)) {
            ZStack { content(tick % durations.count) }
                .frame(width: 104, height: 64)
        }
        .replays($taps, on: value)
        .loop($tick, durations, replay: taps)
    }
}

struct DockDelayArt: View {
    let delay: Double
    let speed: Double

    var body: some View {
        let ghost = delay != AnimationSetting.dockDelay.macOS
        AnimationThumb(durations: [max(speed, 0.3) + 0.4, 0.55, max(delay, 0.2) + max(speed, 0.001) + 1], value: delay) { step in
            ArtDock()
                .scaleEffect(0.5)
                .position(x: 52, y: step == 2 ? 53 : 80)
                .animation(step == 2 ? ease(speed, delay: delay) : ease(speed), value: step)
            ArtDock()
                .scaleEffect(0.5)
                .ghost(ghost)
                .position(x: 52, y: step == 2 ? 53 : 80)
                .animation(step == 2 ? ease(speed, delay: 0.2) : ease(speed), value: step)
            ArtCursor()
                .scaleEffect(0.8)
                .cursor(at: step == 0 ? CGPoint(x: 76, y: 12) : CGPoint(x: 52, y: 56))
                .animation(step == 1 || step == 0 ? .smooth(duration: 0.45) : nil, value: step)
        }
    }
}

struct DockSpeedArt: View {
    let speed: Double

    var body: some View {
        let ghost = speed != AnimationSetting.dockSpeed.macOS
        AnimationThumb(durations: [max(speed, 0.5) + 0.5, max(speed, 0.5) + 1], value: speed) { step in
            ArtDock()
                .scaleEffect(0.5)
                .position(x: 52, y: step == 1 ? 53 : 80)
                .animation(ease(speed), value: step)
            ArtDock()
                .scaleEffect(0.5)
                .ghost(ghost)
                .position(x: 52, y: step == 1 ? 53 : 80)
                .animation(ease(AnimationSetting.dockSpeed.macOS), value: step)
        }
    }
}

struct BounceArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [1, 0.3, 0.3, 0.3, 0.3, 0.9], value: on ? 1 : 0) { step in
            ArtDock(jump: on && (step == 1 || step == 3) ? 18 : 0, badge: step >= 1)
                .scaleEffect(0.6)
                .position(x: 52, y: 50)
                .animation(step == 1 || step == 3 ? .easeOut(duration: 0.3) : .easeIn(duration: 0.3), value: step)
        }
    }
}

struct WindowOpenArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [0.7, 1.4], value: on ? 1 : 0) { step in
            ArtWindow(size: CGSize(width: 64, height: 40)) { Color.clear }
                .scaleEffect(step == 1 ? 1 : 0.9)
                .opacity(step == 1 ? 1 : 0)
                .animation(on ? (step == 1 ? .easeOut(duration: 0.2) : .easeIn(duration: 0.15)) : nil, value: step)
                .position(x: 52, y: 32)
        }
    }
}

struct ResizeArt: View {
    let seconds: Double

    var body: some View {
        let macOS = AnimationSetting.resize.macOS
        AnimationThumb(durations: [max(seconds, macOS) + 0.6, max(seconds, macOS) + 1.1], value: seconds) { step in
            ArtWindow(size: CGSize(width: 80, height: 50)) {
                ZStack(alignment: .top) {
                    ArtSheet(size: CGSize(width: 54, height: 28))
                        .ghost(seconds != macOS)
                        .offset(y: step == 1 ? 1 : -32)
                        .animation(step == 1 ? ease(macOS) : nil, value: step)
                    ArtSheet(size: CGSize(width: 54, height: 28))
                        .offset(y: step == 1 ? 1 : -32)
                        .animation(step == 1 ? ease(seconds) : nil, value: step)
                        .zIndex(-1)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .position(x: 52, y: 32)
        }
    }
}

struct QuickLookArt: View {
    let seconds: Double

    var body: some View {
        let macOS = AnimationSetting.quickLook.macOS
        AnimationThumb(durations: [max(seconds, macOS) + 0.7, max(seconds, macOS) + 1.1], value: seconds) { step in
            ArtFile(selected: true)
                .scaleEffect(0.75)
                .position(x: 20, y: 34)
            panel(open: step == 1)
                .animation(ease(seconds), value: step)
            panel(open: step == 1)
                .ghost(seconds != macOS)
                .animation(ease(macOS), value: step)
        }
    }

    private func panel(open: Bool) -> some View {
        ArtQuickLook(size: CGSize(width: 60, height: 46))
            .scaleEffect(open ? 1 : 0.2)
            .opacity(open ? 1 : 0)
            .position(x: open ? 66 : 20, y: open ? 32 : 28)
    }
}

struct FinderColumnsArt: View {
    let multiplier: Double

    private static let base = 0.11

    var body: some View {
        let seconds = Self.base * multiplier
        AnimationThumb(durations: [max(seconds, Self.base) + 0.9, max(seconds, Self.base) + 0.9], value: multiplier) { step in
            ArtWindow(size: CGSize(width: 84, height: 50)) {
                ZStack(alignment: .leading) {
                    columns(selected: step == 1 ? 2 : 1)
                        .ghost(multiplier != 1)
                        .offset(x: step == 1 ? -30 : 0)
                        .animation(ease(Self.base), value: step)
                    columns(selected: step == 1 ? 2 : 1)
                        .offset(x: step == 1 ? -30 : 0)
                        .animation(ease(seconds), value: step)
                        .zIndex(-1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipped()
            }
            .position(x: 52, y: 32)
        }
    }

    private func columns(selected: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { column in
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(0..<3, id: \.self) { row in
                        Capsule()
                            .fill(row == 0 && column < selected ? Color.accentColor : Color.primary.opacity(0.14))
                            .frame(width: 18, height: 3.5)
                    }
                }
                .frame(width: 26, height: 36, alignment: .topLeading)
                .padding(.leading, 4)
                .overlay(alignment: .trailing) { Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 0.5) }
                .opacity(column <= selected ? 1 : 0)
            }
        }
        .padding(.top, 4)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct FinderWindowArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [0.8, 1.4], value: on ? 1 : 0) { step in
            Image(systemName: "folder.fill")
                .font(.system(size: 20))
                .foregroundStyle(.cyan)
                .position(x: 20, y: 34)
            ArtWindow(size: CGSize(width: 58, height: 38)) { Color.clear }
                .scaleEffect(step == 1 ? 1 : 0.2)
                .opacity(step == 1 ? 1 : 0)
                .position(x: step == 1 ? 66 : 20, y: step == 1 ? 30 : 34)
                .animation(on ? .easeOut(duration: 0.25) : nil, value: step)
        }
    }
}

struct MinimizeArt: View {
    let effect: Int
    @State private var tick = 1
    @State private var taps = 0
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let step = tick % 2
        let dark = scheme == .dark
        ZStack {
            MinimizeShape(progress: step == 1 ? 1 : 0, effect: effect)
                .fill(Color(nsColor: .windowBackgroundColor))
                .overlay(MinimizeShape(progress: step == 1 ? 1 : 0, effect: effect).stroke(Color.primary.opacity(0.2), lineWidth: 0.5))
                .animation(.easeInOut(duration: 0.5), value: step)
            HStack(spacing: 2.5) {
                ForEach([Art.red, Art.yellow, Art.green], id: \.self) { Circle().fill($0).frame(width: 3.5, height: 3.5) }
            }
            .position(x: 19, y: 9)
            .opacity(step == 1 ? 0 : 1)
            .animation(.easeInOut(duration: step == 1 ? 0.1 : 0.3).delay(step == 1 ? 0 : 0.3), value: step)
            HStack(spacing: 3) {
                ForEach([Color.teal, .accentColor, .orange], id: \.self) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous).fill($0).frame(width: 7, height: 7)
                }
            }
            .padding(2)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.75), in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            .position(x: 33.5, y: 38.5)
        }
        .frame(width: 67, height: 44)
        .background(LinearGradient(colors: [Color.accentColor.opacity(dark ? 0.26 : 0.15), Color.accentColor.opacity(dark ? 0.09 : 0.05)], startPoint: .top, endPoint: .bottom))
        .replays($taps, on: effect)
        .loop($tick, [1.2, 1.2], replay: taps)
    }
}

private struct MinimizeShape: Shape {
    var progress: Double
    let effect: Int

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let window = CGRect(x: 10, y: 5, width: 47, height: 26)
        let icon = CGRect(x: 30, y: 35, width: 7, height: 7)
        func mix(_ a: CGFloat, _ b: CGFloat, _ t: Double) -> CGFloat { a + (b - a) * CGFloat(min(max(t, 0), 1)) }
        let p = progress
        let top: (y: CGFloat, width: CGFloat)
        let bottom: (y: CGFloat, width: CGFloat)
        switch effect {
        case 1:
            let frame = CGRect(
                x: mix(window.minX, icon.minX, p), y: mix(window.minY, icon.minY, p),
                width: mix(window.width, icon.width, p), height: mix(window.height, icon.height, p)
            )
            return Path(roundedRect: frame, cornerRadius: mix(4, 1.5, p), style: .continuous)
        case 2:
            top = (mix(window.minY, icon.minY, p * p), mix(window.width, icon.width, p))
            bottom = (mix(window.maxY, icon.maxY, p / 0.35), mix(window.width, icon.width * 0.6, p / 0.35))
        default:
            top = (mix(window.minY, icon.minY, (p - 0.35) / 0.65), mix(window.width, icon.width, (p - 0.3) / 0.7))
            bottom = (mix(window.maxY, icon.maxY, p / 0.5), mix(window.width, icon.width, p / 0.5))
        }
        let center = window.midX + (icon.midX - window.midX) * CGFloat(min(p * 1.5, 1))
        let middle = (top.y + bottom.y) / 2
        let curved = effect == 0
        return Path { path in
            path.move(to: CGPoint(x: center - top.width / 2, y: top.y))
            path.addLine(to: CGPoint(x: center + top.width / 2, y: top.y))
            if curved {
                path.addCurve(to: CGPoint(x: icon.midX + bottom.width / 2, y: bottom.y),
                              control1: CGPoint(x: center + top.width / 2, y: middle),
                              control2: CGPoint(x: icon.midX + bottom.width / 2, y: middle))
            } else {
                path.addLine(to: CGPoint(x: icon.midX + bottom.width / 2, y: bottom.y))
            }
            path.addLine(to: CGPoint(x: icon.midX - bottom.width / 2, y: bottom.y))
            if curved {
                path.addCurve(to: CGPoint(x: center - top.width / 2, y: top.y),
                              control1: CGPoint(x: icon.midX - bottom.width / 2, y: middle),
                              control2: CGPoint(x: center - top.width / 2, y: middle))
            }
            path.closeSubpath()
        }
    }
}
