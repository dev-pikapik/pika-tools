import SwiftUI

private extension FrameRateCorner {
    var alignment: Alignment {
        Alignment(horizontal: isLeft ? .leading : .trailing, vertical: isTop ? .top : .bottom)
    }

    var title: String {
        switch self {
        case .topLeft: String(localized: "Top left corner")
        case .topRight: String(localized: "Top right corner")
        case .bottomLeft: String(localized: "Bottom left corner")
        case .bottomRight: String(localized: "Bottom right corner")
        }
    }
}

struct FrameRateSettings: View {
    @Bindable var tool: GameModeTool
    private let permissions = Permissions.shared

    var body: some View {
        Section {
            FrameRatePicture(corner: tool.frameRateCorner, on: tool.showsFrameRate, select: { tool.frameRateCorner = $0 })
                .opacity(tool.isEnabled ? 1 : 0.5)
                .settingAnchor(String(localized: "Corner for FPS"))
            ToggleRow(
                icon: "speedometer",
                title: String(localized: "Show FPS"),
                subtitle: Text("Shows how smoothly the game runs"),
                help: Text(FrameRateMeter.hasTrace
                    ? String(localized: "FPS means frames per second: how many pictures the game draws each second. A few games, mostly older ones, can only be counted through screen recording, and then the number can’t go above the screen’s refresh rate.")
                    : String(localized: "FPS means frames per second: how many pictures the game draws each second. It’s counted through screen recording, so the number can’t go above the screen’s refresh rate."))
                    + Text(verbatim: " ") + Text("Calm games like chess draw a new picture only when something moves, so 0 is normal for them."),
                isOn: $tool.showsFrameRate
            )
            if Permission.screenRecording.isShown {
                LabeledContent("Needs a permission. Click to allow it.") {
                    Button("Allow") { permissions.ask([.screenRecording]) }
                }
                .foregroundStyle(.secondary)
            }
        }
        .disabled(!tool.isEnabled)
        .onAppear { permissions.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in permissions.refresh() }
    }
}

struct FrameRatePicture: View {
    let corner: FrameRateCorner
    let on: Bool
    let select: (FrameRateCorner) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let screen = CGSize(width: 196, height: 108)
    private static let pill: CGFloat = 0.7
    private static let inset: CGFloat = 6

    var body: some View {
        IllustrationRow {
            ArtTimeline { time in
                Stage {
                    let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
                    GameScene(time: time ?? GameStory.start)
                        .frame(width: Self.screen.width, height: Self.screen.height)
                        .overlay(alignment: corner.alignment) {
                            FramePill(shown: .live(60), scale: Self.pill)
                                .padding(Self.inset)
                                .opacity(on ? 1 : 0)
                        }
                        .clipShape(shape)
                        .overlay(shape.hairline(Color.primary.opacity(0.14)))
                        .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                        .spring(corner, reduceMotion: reduceMotion)
                        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: on)
                }
            }
        }
        .overlay {
            VStack(spacing: 0) {
                row(.topLeft, .topRight)
                row(.bottomLeft, .bottomRight)
            }
            .frame(width: Self.screen.width, height: Self.screen.height)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: "Corner for FPS"))
        }
    }

    private func row(_ left: FrameRateCorner, _ right: FrameRateCorner) -> some View {
        HStack(spacing: 0) {
            CornerButton(corner: left, selected: left == corner, visible: left == corner && on) { select(left) }
            CornerButton(corner: right, selected: right == corner, visible: right == corner && on) { select(right) }
        }
    }

    private struct CornerButton: View {
        let corner: FrameRateCorner
        let selected: Bool
        let visible: Bool
        let action: () -> Void
        @State private var hovering = false

        var body: some View {
            Button(action: action) {
                ZStack(alignment: corner.alignment) {
                    Color.clear
                    if hovering && !visible {
                        FramePill(shown: .live(60), scale: FrameRatePicture.pill)
                            .padding(FrameRatePicture.inset)
                            .opacity(0.4)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            .help(corner.title)
            .accessibilityLabel(corner.title)
            .accessibilityAddTraits(selected ? .isSelected : [])
        }
    }
}
