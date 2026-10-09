import AppKit
import SwiftUI

enum Art {
    static let height: CGFloat = 128
    static let radius: CGFloat = 12
    static let stage = CGSize(width: 300, height: 128)
    static let red = Color(red: 1, green: 0.37, blue: 0.34)
    static let yellow = Color(red: 1, green: 0.74, blue: 0.18)
    static let green = Color(red: 0.16, green: 0.78, blue: 0.25)

    static func metal(_ scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark ? [Color(white: 0.46), Color(white: 0.30)] : [Color(white: 0.94), Color(white: 0.77)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct IllustrationRow<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ArtCard { content }
            .hostedApart()
            .frame(maxWidth: .infinity)
            .frame(height: Art.height)
            .accessibilityHidden(true)
    }
}

extension IllustrationRow {
    init<Scene: View>(loop durations: [Double], replay: Int = 0, rest: Int? = nil, from tick: Int = 0, @ViewBuilder scene: @escaping (Int) -> Scene) where Content == ArtLoop<Scene> {
        self.init { ArtLoop(durations: durations, replay: replay, rest: rest, tick: tick, scene: scene) }
    }
}

struct ArtLoop<Scene: View>: View {
    let durations: [Double]
    var replay = 0
    var rest: Int?
    @State var tick = 0
    @ViewBuilder let scene: (Int) -> Scene

    var body: some View {
        scene(tick).loop($tick, durations, replay: replay, rest: rest)
    }
}

private struct ArtCard<Content: View>: View {
    @ViewBuilder var content: Content
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Art.radius, style: .continuous)
        let dark = scheme == .dark
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.accentColor.opacity(dark ? 0.26 : 0.15), Color.accentColor.opacity(dark ? 0.09 : 0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: shape
            )
            .clipShape(shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
    }
}

private struct ArtHost: NSViewRepresentable {
    let content: AnyView

    func makeNSView(context: Context) -> ArtHostingView {
        let view = ArtHostingView(rootView: AnyView(EmptyView()))
        view.sizingOptions = []
        view.show(content, context.environment)
        return view
    }

    func updateNSView(_ view: ArtHostingView, context: Context) {
        view.show(content, context.environment)
    }
}

private final class ArtHostingView: NSHostingView<AnyView> {
    private static let frameTime = 1.0 / 30
    private var rendered = 0.0
    private var waiting = false
    private var parked = false
    private var scrolling: NSObjectProtocol?
    private var constraintsDue = false
    private var updatingConstraints = false
    private var content = AnyView(EmptyView())
    private var environment = EnvironmentValues()
    private var playing = true

    func show(_ content: AnyView, _ environment: EnvironmentValues) {
        self.content = content
        self.environment = environment
        refresh()
    }

    private func refresh() {
        var environment = environment
        environment.artPlaying = playing
        rootView = AnyView(content.environment(\.self, environment))
    }

    private func play() {
        guard (shown >= 0.5) != playing else { return }
        playing.toggle()
        refresh()
    }

    override var needsUpdateConstraints: Bool {
        get { updatingConstraints }
        set { if newValue { constraintsDue = true } }
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        scrolling.map(NotificationCenter.default.removeObserver)
        scrolling = enclosingScrollView.map {
            NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: $0.contentView, queue: .main) { [weak self] _ in
                guard let self else { return }
                self.play()
                guard self.parked, self.shown > 0 else { return }
                self.parked = false
                self.needsLayout = true
            }
        }
    }

    override func layout() {
        let shown = shown
        if (shown >= 0.5) != playing { DispatchQueue.main.async { [weak self] in self?.play() } }
        guard shown > 0 else {
            parked = true
            return
        }
        let now = CACurrentMediaTime()
        let frame = ((now + 0.002) / Self.frameTime).rounded(.down)
        guard frame > rendered else {
            if !waiting {
                waiting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + (frame + 1) * Self.frameTime - now) { [weak self] in
                    self?.waiting = false
                    self?.needsLayout = true
                }
            }
            return
        }
        rendered = frame
        if constraintsDue {
            constraintsDue = false
            updatingConstraints = true
            updateConstraintsForSubtreeIfNeeded()
            updatingConstraints = false
        }
        super.layout()
    }

    private var shown: CGFloat {
        guard let root = window?.contentView else { return 0 }
        let frame = convert(bounds, to: nil)
        var rect = frame.intersection(root.convert(root.bounds, to: nil))
        if let scroll = enclosingScrollView { rect = rect.intersection(scroll.convert(scroll.bounds, to: nil)) }
        return rect.isEmpty ? 0 : rect.width * rect.height / (frame.width * frame.height)
    }
}

struct Stage<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack { content }
            .frame(width: Art.stage.width, height: Art.stage.height)
    }
}

private struct Loop: ViewModifier {
    @Binding var tick: Int
    let durations: [Double]
    let replay: Int
    let rest: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.artPlaying) private var playing
    @State private var visible = true
    @State private var played = 0

    private struct Run: Equatable {
        let visible: Bool
        let reduceMotion: Bool
        let replay: Int
    }

    func body(content: Content) -> some View {
        content
            .settingsVisibility($visible)
            .task(id: Run(visible: visible && playing, reduceMotion: reduceMotion, replay: replay)) {
                let replaying = replay != played
                played = replay
                guard visible, playing, !reduceMotion || replaying else { return }
                if replaying { tick = 0 }
                var steps = reduceMotion ? rest ?? durations.count - 1 : Int.max
                var deadline = ContinuousClock.now
                while steps > 0, !Task.isCancelled {
                    deadline += .seconds(durations[tick % durations.count])
                    try? await Task.sleep(until: deadline, clock: .continuous)
                    guard !Task.isCancelled else { return }
                    tick += 1
                    steps -= 1
                }
            }
    }
}

struct ArtTimeline<Content: View>: View {
    @ViewBuilder var content: (Double?) -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.artPlaying) private var playing
    @State private var visible = true
    @State private var shown = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion || !visible || !shown || !playing)) { context in
            content(reduceMotion ? nil : context.date.timeIntervalSinceReferenceDate)
        }
        .onAppear { shown = true }
        .onDisappear { shown = false }
        .settingsVisibility($visible)
    }
}

private struct ArtPlayingKey: EnvironmentKey {
    static let defaultValue = true
}

private extension EnvironmentValues {
    var artPlaying: Bool {
        get { self[ArtPlayingKey.self] }
        set { self[ArtPlayingKey.self] = newValue }
    }
}

extension View {
    func settingsVisibility(_ visible: Binding<Bool>) -> some View {
        onReceive(NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification)) { note in
            guard let window = note.object as? NSWindow, window === SettingsWindow.window else { return }
            visible.wrappedValue = window.occlusionState.contains(.visible)
        }
    }

    func hostedApart() -> some View {
        ArtHost(content: AnyView(self))
    }

    func loop(_ tick: Binding<Int>, _ durations: [Double], replay: Int = 0, rest: Int? = nil) -> some View {
        modifier(Loop(tick: tick, durations: durations, replay: replay, rest: rest))
    }

    func spring(_ value: some Equatable, reduceMotion: Bool) -> some View {
        animation(reduceMotion ? nil : .spring(duration: 0.6, bounce: 0.15), value: value)
    }
}

struct ChoiceTile<Content: View>: View {
    let title: String
    let selected: Bool
    var size = CGSize(width: 67, height: 44)
    let action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                content
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(.separator, lineWidth: 0.5)
                    }
                    .overlay {
                        if selected {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .strokeBorder(Color.accentColor, lineWidth: 3)
                                .padding(-4)
                        }
                    }
                    .accessibilityHidden(true)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(selected ? Color.accentColor : Color.primary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct ArtScreen<Content: View>: View {
    let glow: Double
    var radius: CGFloat = 4
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color(white: 0.06)
            ZStack {
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(colors: [.white.opacity(0.35), .clear], center: .topTrailing, startRadius: 0, endRadius: 70)
                VStack(spacing: 0) {
                    Rectangle().fill(.black.opacity(0.22)).frame(height: 4)
                    Spacer(minLength: 0)
                    Capsule().fill(.white.opacity(0.35)).frame(width: 30, height: 3).padding(.bottom, 3)
                }
            }
            .opacity(glow)
            content
            LinearGradient(colors: [.white.opacity(0.10), .clear], startPoint: .topLeading, endPoint: UnitPoint(x: 0.5, y: 0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

struct ArtLaptop<Face: View>: View {
    let lid: Double
    let glow: Double
    @ViewBuilder var face: Face
    @Environment(\.colorScheme) private var scheme

    private let width: CGFloat = 120

    var body: some View {
        let metal = Art.metal(scheme)
        let baseWidth = width * 1.16
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color(white: 0.04))
                        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(metal, lineWidth: 1.5))
                    ArtScreen(glow: glow) { face }
                        .padding(4)
                        .overlay(alignment: .top) {
                            Capsule().fill(Color(white: 0.04)).frame(width: 16, height: 4).padding(.top, 4)
                        }
                }
                .frame(width: width, height: width * 0.64)
                .scaleEffect(y: max(1 - lid, 0.001), anchor: .bottom)
                .opacity(1 - lid)
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .fill(metal)
                    .frame(width: baseWidth, height: 5)
                    .opacity(lid)
            }
            UnevenRoundedRectangle(topLeadingRadius: 1, bottomLeadingRadius: 5, bottomTrailingRadius: 5, topTrailingRadius: 1)
                .fill(metal)
                .frame(width: baseWidth, height: 6)
                .overlay(alignment: .top) {
                    Capsule().fill(.black.opacity(0.18)).frame(width: 20, height: 2)
                }
        }
        .shadow(color: Color.accentColor.opacity(glow * 0.5), radius: 18 * glow)
    }
}

struct ArtMonitor<Face: View>: View {
    let glow: Double
    @ViewBuilder var face: Face
    @Environment(\.colorScheme) private var scheme

    private let width: CGFloat = 112

    var body: some View {
        let metal = Art.metal(scheme)
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(white: 0.04))
                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(metal, lineWidth: 1.5))
                ArtScreen(glow: glow) { face }
                    .padding(3.5)
            }
            .frame(width: width, height: width * 0.6)
            Rectangle().fill(metal).frame(width: 12, height: 9)
            Capsule().fill(metal).frame(width: 40, height: 4)
        }
        .shadow(color: Color.accentColor.opacity(glow * 0.5), radius: 18 * glow)
    }
}

struct ArtWindow<Content: View>: View {
    var size = CGSize(width: 108, height: 64)
    var active = true
    @ViewBuilder var content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach([Art.red, Art.yellow, Art.green], id: \.self) { Circle().fill(active ? $0 : Color.primary.opacity(0.18)).frame(width: 6, height: 6) }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 7)
            .frame(height: 14)
            .background(Color.primary.opacity(0.06))
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: size.width, height: size.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
    }
}

struct ArtSheet: View {
    var size = CGSize(width: 78, height: 40)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        VStack(alignment: .leading, spacing: 4) {
            Capsule().fill(Color.primary.opacity(0.14)).frame(width: size.width * 0.45, height: 3.5)
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
                .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
                .frame(height: 7)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Spacer(minLength: 0)
                Capsule().fill(Color.primary.opacity(0.12)).frame(width: 17, height: 7)
                Capsule().fill(Color.accentColor).frame(width: 17, height: 7)
            }
        }
        .padding(6)
        .frame(width: size.width, height: size.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
    }
}

struct ArtQuickLook: View {
    var size = CGSize(width: 96, height: 72)

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "xmark").font(.system(size: 5, weight: .bold)).foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Capsule().fill(Color.primary.opacity(0.14)).frame(width: size.width * 0.3, height: 3)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 7)
            .frame(height: 12)
            ArtLandscape(size: CGSize(width: size.width - 10, height: size.height - 17))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .padding([.horizontal, .bottom], 5)
        }
        .frame(width: size.width, height: size.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.22), radius: 7, y: 4)
    }
}

struct ArtDock: View {
    var appDot = true
    var jump: CGFloat = 0
    var badge = false
    var icon: CGFloat = 22

    private static let colors: [Color] = [.teal, .orange, .accentColor, .pink, .green]

    var body: some View {
        let unit = icon / 22
        let shape = RoundedRectangle(cornerRadius: 10 * unit, style: .continuous)
        HStack(spacing: 6 * unit) {
            ForEach(0..<5, id: \.self) { index in
                VStack(spacing: 3 * unit) {
                    RoundedRectangle(cornerRadius: 5.5 * unit, style: .continuous)
                        .fill(LinearGradient(colors: [Self.colors[index], Self.colors[index].opacity(0.65)], startPoint: .top, endPoint: .bottom))
                        .frame(width: icon, height: icon)
                        .overlay {
                            if index == 2 {
                                Image(systemName: "macwindow").font(.system(size: 11 * unit, weight: .semibold)).foregroundStyle(.white)
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if index == 2 && badge {
                                Circle().fill(Art.red).frame(width: 8 * unit, height: 8 * unit).offset(x: 3 * unit, y: -3 * unit)
                            }
                        }
                        .offset(y: index == 2 ? -jump : 0)
                    Circle()
                        .fill(Color.primary.opacity(0.55))
                        .frame(width: 3 * unit, height: 3 * unit)
                        .opacity(index == 1 || (index == 2 && appDot) ? 1 : 0)
                }
            }
        }
        .padding(.horizontal, 7 * unit)
        .padding(.top, 5 * unit)
        .padding(.bottom, 3 * unit)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.75), in: shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
    }
}

struct ArtCursor: View {
    private struct Arrow: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 15))
                path.addLine(to: CGPoint(x: 3.8, y: 11.6))
                path.addLine(to: CGPoint(x: 6.4, y: 17.4))
                path.addLine(to: CGPoint(x: 8.8, y: 16.3))
                path.addLine(to: CGPoint(x: 6.3, y: 10.8))
                path.addLine(to: CGPoint(x: 11.2, y: 10.8))
                path.closeSubpath()
            }
        }
    }

    var pressed = false

    var body: some View {
        Arrow()
            .fill(.black)
            .overlay(Arrow().stroke(.white, lineWidth: 1))
            .frame(width: 12, height: 18, alignment: .topLeading)
            .scaleEffect(pressed ? 0.84 : 1, anchor: .topLeading)
            .shadow(color: .black.opacity(pressed ? 0.15 : 0.25), radius: pressed ? 0.8 : 1.5, y: pressed ? 0.5 : 1)
            .animation(.easeOut(duration: 0.12), value: pressed)
    }
}

extension View {
    func cursor(at point: CGPoint) -> some View {
        modifier(CursorGlide(point: point))
    }
}

private struct CursorGlide: ViewModifier {
    let point: CGPoint
    @State private var last: CGPoint?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let distance = last.map { hypot(point.x - $0.x, point.y - $0.y) } ?? 0
        let duration = 0.5 + 0.12 * log2(1 + distance / 12)
        content
            .offset(y: point.y)
            .transaction { $0.animation = reduceMotion ? nil : .timingCurve(0.3, 0.12, 0.36, 1, duration: duration) }
            .offset(x: point.x)
            .transaction { $0.animation = reduceMotion ? nil : .timingCurve(0.42, 0, 0.22, 1, duration: duration) }
            .position(x: 6, y: 9)
            .onAppear { last = point }
            .onChange(of: point) { last = point }
    }
}

struct ArtRipple: View {
    @State private var spread = false

    var body: some View {
        Circle()
            .strokeBorder(Color.accentColor, lineWidth: 2)
            .frame(width: 24, height: 24)
            .scaleEffect(spread ? 1.5 : 0.3)
            .opacity(spread ? 0 : 0.9)
            .onAppear { withAnimation(.easeOut(duration: 0.55)) { spread = true } }
    }
}

struct ArtKey<Label: View>: View {
    let down: Bool
    var width: CGFloat = 34
    var height: CGFloat = 26
    @ViewBuilder var label: Label

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: height * 0.23, style: .continuous)
        shape
            .fill(down ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            .overlay(shape.strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
            .overlay {
                label
                    .font(.system(size: height / 2, weight: .medium, design: .rounded))
                    .foregroundStyle(down ? Color.white : Color.primary)
            }
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(down ? 0.05 : 0.2), radius: down ? 0.5 : 2, y: down ? 0.5 : 2)
            .scaleEffect(down ? 0.93 : 1)
    }
}

struct ArtFile: View {
    var selected = false
    var renaming = false

    var body: some View {
        let page = RoundedRectangle(cornerRadius: 3, style: .continuous)
        VStack(spacing: 4) {
            page
                .fill(Color(nsColor: .textBackgroundColor))
                .overlay(page.strokeBorder(Color.primary.opacity(0.25), lineWidth: 0.5))
                .overlay {
                    VStack(spacing: 2.5) {
                        ForEach(0..<3, id: \.self) { _ in Capsule().fill(Color.primary.opacity(0.2)).frame(width: 10, height: 1.5) }
                    }
                }
                .frame(width: 18, height: 23)
            ZStack {
                if renaming {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color(nsColor: .textBackgroundColor))
                        .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).strokeBorder(Color.accentColor, lineWidth: 1.2))
                        .overlay(alignment: .leading) {
                            Rectangle().fill(Color.accentColor).frame(width: 1, height: 5).padding(.leading, 4)
                        }
                        .frame(width: 30, height: 9)
                } else {
                    Capsule().fill(selected ? Color.accentColor : Color.primary.opacity(0.2)).frame(width: 22, height: 4)
                }
            }
            .frame(width: 30, height: 9)
        }
        .padding(4)
        .background(Color.accentColor.opacity(selected ? 0.2 : 0), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct ArtLandscape: View {
    let size: CGSize

    var body: some View {
        let width = size.width, height = size.height
        ZStack {
            LinearGradient(colors: [Color(red: 0.38, green: 0.65, blue: 0.96), Color(red: 0.76, green: 0.88, blue: 1)], startPoint: .top, endPoint: .bottom)
            Circle().fill(Art.yellow).frame(width: width * 0.18, height: width * 0.18).position(x: width * 0.74, y: height * 0.3)
            Ellipse().fill(Color(red: 0.47, green: 0.79, blue: 0.43)).frame(width: width * 1.1, height: height * 0.7).position(x: width * 0.2, y: height * 1.02)
            Ellipse().fill(Color(red: 0.24, green: 0.63, blue: 0.33)).frame(width: width * 1.2, height: height * 0.6).position(x: width * 0.86, y: height * 1.08)
        }
        .frame(width: width, height: height)
    }
}

struct ArtSpotlight: View {
    var width: CGFloat = 118
    var height: CGFloat = 22

    var body: some View {
        HStack(spacing: height * 0.24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: height * 0.42, weight: .semibold))
                .foregroundStyle(Color.primary.opacity(0.6))
            Capsule().fill(Color.primary.opacity(0.22)).frame(width: width * 0.4, height: height * 0.18)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, height * 0.38)
        .frame(width: width, height: height)
        .artGlass(radius: height / 2)
    }
}

private struct ArtGlass: ViewModifier {
    let radius: CGFloat
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        let dark = scheme == .dark
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        content
            .background(dark ? Color.black.opacity(0.28) : Color.white.opacity(0.5), in: shape)
            .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(dark ? 0.32 : 0.9), .white.opacity(dark ? 0.06 : 0.25)], startPoint: .top, endPoint: .bottom), lineWidth: 0.8))
            .shadow(color: .black.opacity(0.22), radius: min(radius / 2, 6), y: min(radius / 4.5, 2.5))
    }
}

extension View {
    func artGlass(radius: CGFloat) -> some View {
        modifier(ArtGlass(radius: radius))
    }

    func glassBackdrop(_ frame: CGRect, radius: CGFloat? = nil) -> some View {
        blur(radius: 6)
            .mask {
                RoundedRectangle(cornerRadius: radius ?? frame.height / 2, style: .continuous)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
            }
    }
}

struct ArtMouse: View {
    var wheel = false
    var sideButtons = false
    var back = false
    var forward = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let shape = UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 11, bottomTrailingRadius: 11, topTrailingRadius: 12)
        shape
            .fill(Art.metal(scheme))
            .overlay(shape.strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
            .overlay(alignment: .top) {
                Rectangle().fill(Color.primary.opacity(0.2)).frame(width: 0.5, height: 15)
            }
            .overlay(alignment: .top) {
                Capsule()
                    .fill(wheel ? Color.accentColor : Color.primary.opacity(0.35))
                    .frame(width: 3, height: 8)
                    .padding(.top, 4)
            }
            .overlay(alignment: .topLeading) {
                if sideButtons {
                    VStack(spacing: 2.5) {
                        side(forward)
                        side(back)
                    }
                    .offset(x: -1.5, y: 13)
                }
            }
            .frame(width: 24, height: 38)
            .shadow(color: .black.opacity(0.18), radius: 2, y: 1.5)
    }

    private func side(_ pressed: Bool) -> some View {
        Capsule()
            .fill(pressed ? Color.accentColor : Color.primary.opacity(0.35))
            .frame(width: 3.5, height: 7)
    }
}

struct ArtTrackpad: View {
    var touch = false
    var slide: CGFloat = 0
    var swipe: CGFloat = 0
    var width: CGFloat = 60
    var fingers = 2
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let unit = width / 60
        let shape = RoundedRectangle(cornerRadius: 7 * unit, style: .continuous)
        shape
            .fill(Art.metal(scheme))
            .overlay(shape.strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
            .overlay {
                HStack(spacing: 8 * unit) {
                    ForEach(0..<fingers, id: \.self) { _ in Circle().frame(width: 10 * unit, height: 10 * unit) }
                }
                .foregroundStyle(Color.accentColor)
                .opacity(touch ? 0.9 : 0)
                .offset(x: swipe, y: slide)
            }
            .frame(width: width, height: 42 * unit)
            .shadow(color: .black.opacity(0.18), radius: 2, y: 1.5)
    }
}

struct ArtMenu<Content: View>: View {
    var width: CGFloat = 100
    @ViewBuilder var content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        VStack(alignment: .leading, spacing: 1) { content }
            .padding(3)
            .frame(width: width)
            .background(Color(nsColor: .windowBackgroundColor), in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
    }
}

struct ArtMenuRow: View {
    var width: CGFloat = 40
    var title: Text?
    var active = false
    var submenu = false

    var body: some View {
        HStack(spacing: 0) {
            if let title {
                title
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(active ? Color.white : Color.primary)
                    .lineLimit(1)
            } else {
                Capsule().fill(Color.primary.opacity(0.18)).frame(width: width, height: 4)
            }
            Spacer(minLength: 0)
            if submenu {
                Image(systemName: "chevron.right")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(active ? Color.white : Color.secondary)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 14)
        .background(active ? Color.accentColor : .clear, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}
