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

private struct Lines: View {
    var widths: [CGFloat] = [62, 44, 54]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Array(widths.enumerated()), id: \.offset) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: $0.element, height: 4) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
    }
}

private struct Click: View {
    let at: CGPoint
    let visible: Bool
    var id = 0

    var body: some View {
        if visible {
            ArtRipple().id(id).position(at)
        }
    }
}

struct AnimationsArt: View {
    let values: [AnimationSetting: Double]
    @State private var tick = 6
    @State private var taps = 0

    private func value(_ setting: AnimationSetting) -> Double { values[setting] ?? setting.macOS }

    var body: some View {
        let delay = value(.dockDelay), speed = value(.dockSpeed), sheet = value(.resize)
        let opens = value(.windowOpen) != 0
        let durations = [max(speed + 0.4, 1.2), 0.95, max(delay + speed, 0.7) + 0.35, 0.85, 0.15, 0.5, max(sheet, 0.2) + 1.3]
        let step = tick % durations.count
        let docked = step >= 2
        let open = step >= 5
        let dropped = step >= 6
        let ghosts = delay != AnimationSetting.dockDelay.macOS || speed != AnimationSetting.dockSpeed.macOS
        let icon = CGPoint(x: 150, y: 103)
        IllustrationRow {
            Stage {
                ArtWindow(size: CGSize(width: 136, height: 76)) {
                    ZStack(alignment: .top) {
                        Lines()
                        ArtSheet(size: CGSize(width: 88, height: 42))
                            .ghost(sheet != AnimationSetting.resize.macOS)
                            .offset(y: dropped ? 4 : -48)
                            .animation(ease(AnimationSetting.resize.macOS), value: step)
                        ArtSheet(size: CGSize(width: 88, height: 42))
                            .offset(y: dropped ? 4 : -48)
                            .animation(ease(sheet), value: step)
                    }
                    .clipped()
                }
                .scaleEffect(open ? 1 : 0.9)
                .opacity(open ? 1 : 0)
                .animation(step == 5 ? (opens ? .easeOut(duration: 0.2) : nil) : .easeIn(duration: 0.2), value: step)
                .position(x: 150, y: 50)
                ArtDock()
                    .ghost(ghosts)
                    .position(x: 150, y: docked ? 107 : 152)
                    .animation(step == 2 ? ease(0.5, delay: 0.2) : step == 0 ? ease(0.5) : nil, value: step)
                ArtDock()
                    .position(x: 150, y: docked ? 107 : 152)
                    .animation(step == 2 ? ease(speed, delay: delay) : step == 0 ? ease(speed) : nil, value: step)
                Click(at: icon, visible: (4...5).contains(step))
                ArtCursor(pressed: step == 4)
                    .cursor(at: step == 0 ? CGPoint(x: 226, y: 38) : step < 3 ? CGPoint(x: 150, y: 118) : CGPoint(x: icon.x + 2, y: icon.y - 3))
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
    let rest: Int?
    let content: (Int) -> Content
    @State private var tick: Int
    @State private var taps = 0

    init(durations: [Double], value: Double, rest: Int? = nil, @ViewBuilder content: @escaping (Int) -> Content) {
        self.durations = durations
        self.value = value
        self.rest = rest
        self.content = content
        _tick = State(initialValue: rest ?? durations.count - 1)
    }

    var body: some View {
        IllustrationRow {
            Stage { content(tick % durations.count) }
        }
        .replays($taps, on: value)
        .loop($tick, durations, replay: taps, rest: rest)
    }
}

private struct DockRevealArt: View {
    let delay: Double
    let speed: Double
    let paceDelay: Double
    let paceSpeed: Double
    let value: Double

    var body: some View {
        let ghost = delay != paceDelay || speed != paceSpeed
        AnimationThumb(durations: [max(speed, paceSpeed, 0.3) + 0.9, 0.9, max(delay, paceDelay) + max(speed, paceSpeed) + 1], value: value) { step in
            let shown = step == 2
            ArtDock()
                .ghost(ghost)
                .position(x: 150, y: shown ? 104 : 152)
                .animation(shown ? ease(paceSpeed, delay: paceDelay) : ease(paceSpeed), value: step)
            ArtDock()
                .position(x: 150, y: shown ? 104 : 152)
                .animation(shown ? ease(speed, delay: delay) : ease(speed), value: step)
            ArtCursor()
                .cursor(at: step == 0 ? CGPoint(x: 214, y: 40) : CGPoint(x: 166, y: 120))
                .animation(.smooth(duration: 0.45), value: step == 0)
        }
    }
}

struct DockDelayArt: View {
    let delay: Double
    let speed: Double

    var body: some View {
        DockRevealArt(delay: delay, speed: speed, paceDelay: AnimationSetting.dockDelay.macOS, paceSpeed: speed, value: delay)
    }
}

struct DockSpeedArt: View {
    let delay: Double
    let speed: Double

    var body: some View {
        DockRevealArt(delay: delay, speed: speed, paceDelay: delay, paceSpeed: AnimationSetting.dockSpeed.macOS, value: speed)
    }
}

struct BounceArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [1, 0.28, 0.28, 0.28, 0.28, 0.9], value: on ? 1 : 0) { step in
            let up = on && (step == 1 || step == 3)
            ArtDock(jump: up ? 22 : 0, badge: step >= 1)
                .position(x: 150, y: 104)
                .animation(up ? .easeOut(duration: 0.28) : .easeIn(duration: 0.28), value: step)
        }
    }
}

struct WindowOpenArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [1.3, 1.15, 0.15, 1.3, 1.15, 0.15], value: on ? 1 : 0, rest: 3) { step in
            let open = (3...5).contains(step)
            let plus = CGPoint(x: 190, y: 21)
            let close = CGPoint(x: 89, y: 39)
            ArtWindow(size: CGSize(width: 150, height: 80), active: !open) { Lines(widths: [70, 48, 58]) }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 4)
                }
                .position(x: 126, y: 54)
            ArtWindow(size: CGSize(width: 150, height: 80)) { Lines(widths: [52, 66, 40]) }
                .scaleEffect(open ? 1 : 0.9)
                .opacity(open ? 1 : 0)
                .animation(on ? (open ? .easeOut(duration: 0.2) : .easeIn(duration: 0.15)) : nil, value: open)
                .position(x: 154, y: 72)
            Click(at: plus, visible: step == 2 || step == 3)
            Click(at: close, visible: step == 5 || step == 0)
            ArtCursor(pressed: step == 2 || step == 5)
                .cursor(at: step == 0 ? CGPoint(x: 252, y: 98) : step < 4 ? CGPoint(x: plus.x - 1, y: plus.y - 2) : CGPoint(x: close.x - 1, y: close.y - 2))
                .animation(.smooth(duration: 0.4), value: step)
        }
    }
}

struct ResizeArt: View {
    let seconds: Double

    var body: some View {
        let macOS = AnimationSetting.resize.macOS
        let slide = max(seconds, macOS)
        AnimationThumb(durations: [max(slide + 0.6, 1.2), 1.1, 0.15, slide + 0.8, 1.05, 0.15], value: seconds, rest: 3) { step in
            let shown = (3...5).contains(step)
            let save = CGPoint(x: 230, y: 19)
            let done = CGPoint(x: 196, y: 80)
            ArtWindow(size: CGSize(width: 190, height: 100)) {
                ZStack(alignment: .top) {
                    Lines(widths: [92, 64, 80])
                    ArtSheet(size: CGSize(width: 124, height: 58))
                        .ghost(seconds != macOS)
                        .offset(y: shown ? 6 : -64)
                        .animation(ease(macOS), value: shown)
                    ArtSheet(size: CGSize(width: 124, height: 58))
                        .offset(y: shown ? 6 : -64)
                        .animation(ease(seconds), value: shown)
                }
                .clipped()
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 14, height: 14)
                    .padding(.trailing, 5)
            }
            .position(x: 150, y: 62)
            Click(at: save, visible: step == 2 || step == 3)
            Click(at: done, visible: step == 5 || step == 0)
            ArtCursor(pressed: step == 2 || step == 5)
                .cursor(at: step == 0 ? CGPoint(x: 262, y: 104) : step < 4 ? CGPoint(x: save.x - 1, y: save.y - 2) : CGPoint(x: done.x - 1, y: done.y - 2))
                .animation(.smooth(duration: 0.4), value: step)
        }
    }
}

struct QuickLookArt: View {
    let seconds: Double

    var body: some View {
        let macOS = AnimationSetting.quickLook.macOS
        let zoom = max(seconds, macOS)
        AnimationThumb(durations: [zoom + 0.8, 0.15, zoom + 1.1, 0.15], value: seconds, rest: 2) { step in
            let open = step == 1 || step == 2
            ArtWindow(size: CGSize(width: 132, height: 80)) {
                HStack(spacing: 4) {
                    ArtFile()
                    VStack(spacing: 4) {
                        ArtPhoto(width: 22)
                            .frame(height: 23)
                        Capsule().fill(Color.accentColor).frame(width: 22, height: 4)
                            .frame(width: 30, height: 9)
                    }
                    .padding(4)
                    .background(Color.accentColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    ArtFile()
                }
            }
            .position(x: 82, y: 52)
            ArtKey(down: step == 1 || step == 3, width: 64, height: 20) { Image(systemName: "space") }
                .animation(.easeOut(duration: 0.08), value: step)
                .position(x: 82, y: 111)
            panel(open: open)
                .ghost(seconds != macOS)
                .animation(ease(macOS, delay: 0.04), value: open)
            panel(open: open)
                .animation(ease(seconds, delay: 0.04), value: open)
        }
    }

    private func panel(open: Bool) -> some View {
        ArtQuickLook(size: CGSize(width: 132, height: 100))
            .scaleEffect(open ? 1 : 0.16)
            .opacity(open ? 1 : 0)
            .position(x: open ? 226 : 82, y: open ? 62 : 53)
    }
}

struct FinderColumnsArt: View {
    let multiplier: Double

    private static let base = 0.11
    private static let column: CGFloat = 66

    var body: some View {
        let seconds = Self.base * multiplier
        let scroll = max(seconds, Self.base)
        AnimationThumb(durations: [1.3, 1.1, 0.15, scroll + 0.75, 1.1, 0.15, scroll + 0.75], value: multiplier, rest: 3) { step in
            let deep = (3...5).contains(step)
            let item = CGPoint(x: 51 + Self.column * 2 + 24, y: 56)
            let back = CGPoint(x: 51 + 24, y: 56)
            ArtWindow(size: CGSize(width: Self.column * 3, height: 96)) {
                ZStack(alignment: .topLeading) {
                    columns(deep: deep)
                        .ghost(multiplier != 1)
                        .offset(x: deep ? -Self.column : 0)
                        .animation(ease(Self.base), value: deep)
                    columns(deep: deep)
                        .offset(x: deep ? -Self.column : 0)
                        .animation(ease(seconds), value: deep)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipped()
            }
            .position(x: 150, y: 64)
            Click(at: step < 4 ? item : back, visible: step == 2 || step == 3 || step == 5 || step == 6, id: step < 4 ? 0 : 1)
            ArtCursor(pressed: step == 2 || step == 5)
                .cursor(at: step == 0 ? CGPoint(x: 262, y: 104) : step < 4 ? CGPoint(x: item.x - 1, y: item.y - 2) : CGPoint(x: back.x - 1, y: back.y - 2))
                .animation(.smooth(duration: 0.4), value: step)
        }
    }

    private func columns(deep: Bool) -> some View {
        let selected = [0, 1, deep ? 1 : nil, nil]
        return HStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { column in
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<5, id: \.self) { row in
                        let picked = selected[column] == row
                        let focused = picked && (column == 2 || !deep && column == 1)
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                                .fill(focused ? Color.white : Color(red: 0.36, green: 0.66, blue: 0.96))
                                .frame(width: 8, height: 6.5)
                            Capsule()
                                .fill(focused ? Color.white.opacity(0.9) : Color.primary.opacity(0.16))
                                .frame(width: [30, 22, 34, 26, 18][(row + column) % 5], height: 3.5)
                            Spacer(minLength: 0)
                            if column < 3 && row < 3 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 5, weight: .bold))
                                    .foregroundStyle(focused ? Color.white : Color.secondary)
                            }
                        }
                        .padding(.horizontal, 5)
                        .frame(height: 13)
                        .background(picked ? (focused ? Color.accentColor : Color.primary.opacity(0.12)) : .clear, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
                .padding(.horizontal, 3)
                .padding(.top, 6)
                .frame(width: Self.column, alignment: .topLeading)
                .frame(maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .trailing) { Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 0.5) }
                .opacity(column < 3 || deep ? 1 : 0)
            }
        }
    }
}

struct FinderWindowArt: View {
    let on: Bool

    var body: some View {
        AnimationThumb(durations: [1.2, 1.1, 0.1, 0.08, 0.1, 1.2, 1.1, 0.15], value: on ? 1 : 0, rest: 5) { step in
            let open = (5...7).contains(step)
            let folder = CGPoint(x: 52, y: 60)
            let close = CGPoint(x: 111, y: 23)
            VStack(spacing: 4) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(LinearGradient(colors: [Color(red: 0.45, green: 0.75, blue: 1), Color(red: 0.27, green: 0.6, blue: 0.95)], startPoint: .top, endPoint: .bottom))
                    .padding(.horizontal, 4)
                    .background(Color.primary.opacity(step >= 2 ? 0.12 : 0), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                Capsule().fill(step >= 2 ? Color.accentColor : Color.primary.opacity(0.22)).frame(width: 26, height: 4)
                    .animation(nil, value: step)
            }
            .position(x: folder.x, y: folder.y + 6)
            ArtWindow(size: CGSize(width: 170, height: 92)) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([26, 20, 24], id: \.self) { Capsule().fill(Color.primary.opacity(0.14)).frame(width: CGFloat($0), height: 3.5) }
                    }
                    .padding(8)
                    .frame(width: 44)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(Color.primary.opacity(0.05))
                    HStack(spacing: 6) {
                        ArtFile()
                        ArtFile()
                        ArtFile()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .scaleEffect(open ? 1 : 0.18)
            .opacity(open ? 1 : 0)
            .position(x: open ? 186 : folder.x, y: open ? 62 : folder.y)
            .animation(on ? (open ? .easeOut(duration: 0.3) : .easeIn(duration: 0.22)) : nil, value: open)
            Click(at: folder, visible: (2...5).contains(step), id: step < 4 ? 0 : 1)
            Click(at: close, visible: step == 7 || step == 0)
            ArtCursor(pressed: step == 2 || step == 4 || step == 7)
                .cursor(at: step == 0 ? CGPoint(x: 120, y: 104) : step < 6 ? CGPoint(x: folder.x + 2, y: folder.y) : CGPoint(x: close.x - 1, y: close.y - 2))
                .animation(.smooth(duration: 0.4), value: step)
        }
    }
}

struct MinimizeArt: View {
    let effect: Int

    private static let window = CGRect(x: 70, y: 8, width: 136, height: 72)
    private static let slot = CGRect(x: 168, y: 109 - 10 * 72 / 136, width: 20, height: 20 * 72 / 136)
    private static let yellow = CGPoint(x: 70 + 21, y: 8 + 8)
    private static let thumb = CGPoint(x: 178, y: 109)

    var body: some View {
        AnimationThumb(durations: [1.2, 0.15, 1.1, 1.15, 0.15, 0.95], value: Double(effect), rest: 0) { step in
            let minimized = (2...4).contains(step)
            let room = (2...4).contains(step)
            dock(room: room)
                .animation(.easeInOut(duration: 0.25).delay(room ? 0 : 0.4), value: room)
                .position(x: 150, y: 109)
            window(minimized ? 1 : 0)
                .animation(.easeInOut(duration: 0.55), value: minimized)
            Click(at: Self.yellow, visible: step == 1 || step == 2)
            Click(at: Self.thumb, visible: step == 4 || step == 5)
            ArtCursor(pressed: step == 1 || step == 4)
                .cursor(at: step < 3 ? CGPoint(x: Self.yellow.x - 1, y: Self.yellow.y - 2) : CGPoint(x: Self.thumb.x - 1, y: Self.thumb.y - 2))
                .animation(.smooth(duration: 0.45), value: step == 0 || step == 3)
        }
    }

    private func window(_ progress: Double) -> some View {
        let size = Self.window.size
        let warp = { (part: Path) in Genie(progress: progress, effect: effect, window: Self.window, slot: Self.slot, part: part) }
        let body = RoundedRectangle(cornerRadius: 9, style: .continuous).path(in: CGRect(origin: .zero, size: size))
        let bar = UnevenRoundedRectangle(topLeadingRadius: 9, topTrailingRadius: 9, style: .continuous).path(in: CGRect(x: 0, y: 0, width: size.width, height: 16))
        let lights = [Art.red, Art.yellow, Art.green]
        return ZStack {
            warp(body).fill(Color(nsColor: .windowBackgroundColor)).shadow(color: .black.opacity(0.18), radius: 5, y: 2)
            warp(bar).fill(Color.primary.opacity(0.06))
            ForEach(0..<3, id: \.self) { index in
                warp(Circle().path(in: CGRect(x: 7.5 + CGFloat(index) * 10, y: 4.5, width: 7, height: 7))).fill(lights[index])
            }
            ForEach(Array([46, 32, 40].enumerated()), id: \.offset) { index, width in
                warp(Capsule().path(in: CGRect(x: 12, y: 26 + CGFloat(index) * 9, width: CGFloat(width), height: 4))).fill(Color.primary.opacity(0.12))
            }
            warp(RoundedRectangle(cornerRadius: 4, style: .continuous).path(in: CGRect(x: 72, y: 24, width: 52, height: 38)))
                .fill(LinearGradient(colors: [Color(red: 0.38, green: 0.65, blue: 0.96), Color(red: 0.47, green: 0.79, blue: 0.43)], startPoint: .top, endPoint: .bottom))
            warp(body).stroke(Color.primary.opacity(0.16), lineWidth: 0.5)
        }
        .frame(width: Art.stage.width, height: Art.stage.height)
    }

    private func dock(room: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)
        return HStack(spacing: 5) {
            ForEach([Color.teal, .orange, .pink], id: \.self) { color in
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(LinearGradient(colors: [color, color.opacity(0.65)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 20, height: 20)
                    .overlay(alignment: .bottom) {
                        if color == .teal { Circle().fill(Color.primary.opacity(0.55)).frame(width: 2.5, height: 2.5).offset(y: 4) }
                    }
            }
            Rectangle().fill(Color.primary.opacity(0.2)).frame(width: 1, height: 18)
            Color.clear
                .frame(width: room ? 20 : 0, height: 20)
                .padding(.leading, room ? 0 : -5)
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.primary.opacity(0.08))
                .frame(width: 20, height: 20)
                .overlay(Image(systemName: "trash").font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.75), in: shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
    }
}

private struct Genie: Shape {
    var progress: Double
    let effect: Int
    let window: CGRect
    let slot: CGRect
    let part: Path

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var start = CGPoint.zero, last = CGPoint.zero
        func line(to end: CGPoint) {
            let count = max(Int((hypot(end.x - last.x, end.y - last.y) / 2).rounded(.up)), 1)
            for index in 1...count {
                let t = CGFloat(index) / CGFloat(count)
                path.addLine(to: warp(CGPoint(x: last.x + (end.x - last.x) * t, y: last.y + (end.y - last.y) * t)))
            }
            last = end
        }
        func curve(to end: CGPoint, _ a: CGPoint, _ b: CGPoint) {
            let from = last
            for index in 1...8 {
                let t = CGFloat(index) / 8, s = 1 - t
                let x = s * s * s * from.x + 3 * s * s * t * a.x + 3 * s * t * t * b.x + t * t * t * end.x
                let y = s * s * s * from.y + 3 * s * s * t * a.y + 3 * s * t * t * b.y + t * t * t * end.y
                path.addLine(to: warp(CGPoint(x: x, y: y)))
            }
            last = end
        }
        part.forEach { element in
            switch element {
            case .move(let to):
                path.move(to: warp(to))
                start = to
                last = to
            case .line(let to): line(to: to)
            case .quadCurve(let to, let control):
                curve(to: to, CGPoint(x: last.x + (control.x - last.x) * 2 / 3, y: last.y + (control.y - last.y) * 2 / 3), CGPoint(x: to.x + (control.x - to.x) * 2 / 3, y: to.y + (control.y - to.y) * 2 / 3))
            case .curve(let to, let a, let b): curve(to: to, a, b)
            case .closeSubpath:
                line(to: start)
                path.closeSubpath()
            }
        }
        return path
    }

    private func warp(_ point: CGPoint) -> CGPoint {
        func clamp(_ t: Double) -> CGFloat { CGFloat(min(max(t, 0), 1)) }
        func mix(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
        let u = point.x / window.width, v = point.y / window.height
        if effect == 1 {
            let t = CGFloat(progress)
            return CGPoint(
                x: mix(window.minX, slot.minX, t) + u * mix(window.width, slot.width, t),
                y: mix(window.minY, slot.minY, t) + v * mix(window.height, slot.height, t)
            )
        }
        let suck = effect == 2
        let pull = clamp(progress / (suck ? 0.4 : 0.5))
        let slide = clamp((progress - (suck ? 0.25 : 0.35)) / (suck ? 0.75 : 0.65))
        let top = mix(window.minY, slot.minY, slide)
        let bottom = mix(window.maxY, slot.maxY, pull)
        let y = mix(top, bottom, v)
        let f = clamp(Double((y - window.minY) / (slot.minY - window.minY)))
        let bend = (suck ? f : f * f * (3 - 2 * f)) * pull
        let left = mix(window.minX, slot.minX, bend)
        let right = mix(window.maxX, slot.maxX, bend)
        return CGPoint(x: mix(left, right, u), y: y)
    }
}
