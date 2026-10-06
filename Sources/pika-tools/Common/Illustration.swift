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
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Art.radius, style: .continuous)
        let dark = scheme == .dark
        content
            .frame(maxWidth: .infinity)
            .frame(height: Art.height)
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
            .accessibilityHidden(true)
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = true

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification)) { note in
                guard let window = note.object as? NSWindow, window === SettingsWindow.window else { return }
                visible = window.occlusionState.contains(.visible)
            }
            .task(id: visible && !reduceMotion) {
                guard visible, !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(durations[tick % durations.count]))
                    guard !Task.isCancelled else { return }
                    tick += 1
                }
            }
    }
}

extension View {
    func loop(_ tick: Binding<Int>, _ durations: [Double]) -> some View {
        modifier(Loop(tick: tick, durations: durations))
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
    @ViewBuilder var content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach([Art.red, Art.yellow, Art.green], id: \.self) { Circle().fill($0).frame(width: 6, height: 6) }
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

struct ArtDock: View {
    var appDot = true

    private static let colors: [Color] = [.teal, .orange, .accentColor, .pink, .green]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 5.5, style: .continuous)
                        .fill(LinearGradient(colors: [Self.colors[index], Self.colors[index].opacity(0.65)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 22, height: 22)
                        .overlay {
                            if index == 2 {
                                Image(systemName: "macwindow").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                            }
                        }
                    Circle()
                        .fill(Color.primary.opacity(0.55))
                        .frame(width: 3, height: 3)
                        .opacity(index == 1 || (index == 2 && appDot) ? 1 : 0)
                }
            }
        }
        .padding(.horizontal, 7)
        .padding(.top, 5)
        .padding(.bottom, 3)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.75), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
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

    var body: some View {
        Arrow()
            .fill(.black)
            .overlay(Arrow().stroke(.white, lineWidth: 1))
            .frame(width: 12, height: 18, alignment: .topLeading)
            .shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
    }
}

extension View {
    func cursor(at point: CGPoint) -> some View {
        position(x: point.x + 6, y: point.y + 9)
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
    @ViewBuilder var label: Label

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 6, style: .continuous)
        shape
            .fill(down ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            .overlay(shape.strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
            .overlay {
                label
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(down ? Color.white : Color.primary)
            }
            .frame(width: width, height: 26)
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
