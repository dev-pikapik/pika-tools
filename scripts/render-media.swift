import AppKit
import SwiftUI

func AXIsProcessTrusted() -> Bool { true }
func CGPreflightListenEventAccess() -> Bool { true }
func CGPreflightScreenCaptureAccess() -> Bool { true }

@main
@MainActor
enum RenderMedia {
    static let out = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    static let fps = 15
    static let card = CGSize(width: 340, height: Art.height)

    static let cards: [(name: String, seconds: Double, art: AnyView)] = [
        ("keep-awake", 4.0, AnyView(KeepAwakeCard())),
        ("fans", 1.6, AnyView(FanScene(rpm: 2500, maximum: 6000, manual: false))),
        ("command-keys", 4.5, AnyView(CommandKeysArt())),
        ("compress", 6.6, AnyView(CompressArt(on: true))),
        ("convert", 8.05, AnyView(ConvertArt(on: true))),
        ("archive", 11.9, AnyView(ArchiveArt(on: true))),
        ("input-switch", 7.9, AnyView(InputSwitchArt(on: true))),
        ("quit-on-close", 4.5, AnyView(QuitOnCloseArt(on: true))),
        ("window-zoom", 5.95, AnyView(WindowZoomArt(on: true))),
        ("dock-hide", 5.1, AnyView(DockHideArt(on: true))),
        ("new-file", 7.1, AnyView(NewFileArt(on: true))),
        ("finder-cut", 3.7, AnyView(FinderCutArt(on: true))),
        ("finder-open", 4.7, AnyView(FinderOpenArt(on: true))),
        ("finder-delete", 3.2, AnyView(FinderDeleteArt(on: true))),
        ("game-mode", 8.0, AnyView(GameModeArt(on: true))),
        ("game-fps", 4.0, AnyView(FrameRatePicture(corner: .topRight, on: true, select: { _ in }))),
        ("pet", 16.65, AnyView(PetArt(on: true))),
        ("speed-test", 5.4, AnyView(SpeedTestArt())),
        ("side-buttons", 5.1, AnyView(SideButtonsArt(on: true, swapped: false))),
        ("wheel-lines", 3.2, AnyView(ScrollStepArt(on: true, distance: 30))),
        ("wheel-direction", 3.0, AnyView(ScrollDirectionArt(trackpadNatural: true, mouseNatural: false))),
        ("linear-pointer", 4.0, AnyView(PointerArt(on: true))),
        ("key-repeat", 4.55, AnyView(KeyRepeatArt(on: true))),
        ("home-end", 5.0, AnyView(HomeEndArt(on: true))),
        ("animations", 6.2, AnyView(AnimationsArt(values: AnimationSpeed.preset(0.5)))),
        ("leftover-permissions", 3.8, AnyView(LeftoversArt())),
        ("uninstaller", 6.0, AnyView(TrashWatchArt(on: true))),
        ("whats-new/1.23.2/game-shortcuts", 4.2, AnyView(SwitchRowsArt(rows: [(AnyView(KeyCaps(keys: ["⌘Q"])), 64), (AnyView(KeyCaps(keys: ["⌘W"])), 52), (AnyView(KeyCaps(keys: ["⌘Tab", "⌘`"])), 40)]))),
        ("whats-new/1.25.0/game-pictures", 4.2, AnyView(SwitchRowsArt(rows: [(AnyView(GameRuleFrame(rule: .commandQ, story: .still(on: false), height: 32)), 64), (AnyView(GameRuleFrame(rule: .spotlight, story: .still(on: false), height: 32)), 52), (AnyView(GameRuleFrame(rule: .missionControl, story: .still(on: false), height: 32)), 72)], height: 36))),
        ("whats-new/1.26.1/game-previews", 6.2, AnyView(IllustrationRow { HStack(spacing: 14) { GameRuleArt(rule: .spotlight, keys: ["⌘Space"], height: 96); GameRuleArt(rule: .showDesktop, keys: ["F11"], height: 96) } })),
        ("whats-new/1.25.1/dock-games", 3.85, AnyView(DockShelfArt())),
        ("whats-new/1.28.0/app-shelf", 3.85, AnyView(DockShelfArt(symbol: "safari.fill"))),
        ("whats-new/1.29.0/pet-ball", PetBallArt.length, AnyView(PetBallArt())),
        ("whats-new/1.31.0/system-shortcuts", 6.2, AnyView(SystemShortcutsCard())),
        ("whats-new/1.31.2/game-settings", 5.4, AnyView(GameSettingsCard())),
        ("whats-new/1.31.3/game-preview", 5.4, AnyView(UnifiedGamePreviewCard())),
        ("whats-new/1.31.4/game-choices", 5.4, AnyView(GameChoicesCard())),
        ("whats-new/1.33.0/permissions", 5.4, AnyView(PermissionsCard())),
        ("whats-new/1.34.0/pointer-shortcuts", 5.4, AnyView(PointerShortcutsCard())),
        ("whats-new/1.35.0/wardrobe", WardrobeCard.length, AnyView(WardrobeCard())),
    ]

    static func main() {
        NSApplication.shared.setActivationPolicy(.accessory)
        Task {
            let only = Set(CommandLine.arguments.dropFirst(3).filter { !$0.hasPrefix("-") && !$0.hasPrefix("(") })
            if CommandLine.arguments[2] == "cards" {
                for card in cards where only.isEmpty || only.contains(card.name) {
                    for dark in [false, true] { await render(card.name, card.seconds, card.art, dark: dark) }
                }
            } else {
                await settings(CommandLine.arguments[2])
            }
            exit(0)
        }
        NSApplication.shared.run()
    }

    static func render(_ name: String, _ seconds: Double, _ art: AnyView, dark: Bool) async {
        let page = dark ? Color(red: 13 / 255, green: 17 / 255, blue: 23 / 255) : .white
        let host = NSHostingView(rootView: art
            .background(RoundedRectangle(cornerRadius: Art.radius, style: .continuous).fill(page))
            .frame(width: card.width, height: card.height))
        let window = NSWindow(contentRect: CGRect(origin: CGPoint(x: -8000, y: -8000), size: card), styleMask: .borderless, backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.contentView = host
        window.orderFrontRegardless()
        let start = ContinuousClock.now
        var frames: [[UInt32]] = []
        for index in 0..<Int((seconds * Double(fps)).rounded()) {
            try? await Task.sleep(until: start + .seconds(seconds + Double(index) / Double(fps)), clock: .continuous)
            frames.append(pixels(host))
        }
        window.orderOut(nil)
        let url = out.appendingPathComponent("\(name)-\(dark ? "dark" : "light").png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? APNG.encode(frames, width: Int(card.width) * 2, height: Int(card.height) * 2, fps: fps).write(to: url)
        print(url.lastPathComponent, frames.count)
    }

    static func pixels(_ view: NSView) -> [UInt32] {
        let size = view.bounds.size
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width) * 2, pixelsHigh: Int(size.height) * 2, bitsPerSample: 16, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = size
        view.cacheDisplay(in: view.bounds, to: rep)
        return APNG.bytes(rep.cgImage!)
    }

    static func settings(_ language: String) async {
        for dark in [false, true] {
            NSApp.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            SettingsWindow.show(.keyboard)
            NSApp.activate(ignoringOtherApps: true)
            guard let window = SettingsWindow.window else { return }
            try? await Task.sleep(for: .seconds(2))
            let name = "settings-\(language)-\(dark ? "dark" : "light").png"
            let capture = Process()
            capture.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            capture.arguments = ["-x", "-o", "-l", String(window.windowNumber), out.appendingPathComponent(name).path]
            try? capture.run()
            capture.waitUntilExit()
            print(name)
        }
    }
}

private struct KeepAwakeCard: View {
    @State private var tick = 0

    var body: some View {
        KeepAwakeScene(on: tick % 2 == 1, bright: true, closed: false, hasLid: true, remaining: nil)
            .loop($tick, [1.4, 2.6])
    }
}

private struct SystemShortcutsCard: View {
    private let entries = SystemShortcutCatalog.load()

    var body: some View {
        IllustrationRow(loop: [1.4, 2.4, 2.4]) { tick in
            HStack(spacing: 8) {
                ForEach([SystemShortcutKind.screenshot, .language, .window], id: \.self) { kind in
                    if let entry = entries.first(where: { $0.kind == kind }) {
                        SystemShortcutFrame(entry: entry, story: .still(on: tick > 0), height: 60, background: kind == .language && tick > 0)
                    }
                }
            }
        }
    }
}

private struct PointerShortcutsCard: View {
    private let entries: [SystemGameShortcut] = {
        let prefs: [String: Any] = ["TrackpadFourFingerVertSwipeGesture": 0, "MouseTwoFingerDoubleTapGesture": 3, "wvous-br-corner": 14]
        return PointerShortcuts.rows(read: { _, key in prefs[key] }, names: { $1 })
    }()

    var body: some View {
        IllustrationRow(loop: [2.2, 3.2]) { tick in
            HStack(spacing: 8) {
                ForEach(entries.filter { [100_002, 100_003, 100_013].contains($0.id) }) { entry in
                    SystemShortcutFrame(entry: entry, story: .still(on: tick % 2 == 1), height: 60)
                }
            }
        }
    }
}

private struct GameSettingsCard: View {
    var body: some View {
        IllustrationRow(loop: [1.8, 3.6]) { tick in
            VStack(spacing: 7) {
                HStack(spacing: 9) {
                    Image(systemName: GameShortcutGroup.language.symbol)
                        .font(.system(size: 15)).foregroundStyle(Color.accentColor)
                        .frame(width: 28, height: 28)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: GameShortcutGroup.language.title).font(.system(size: 12, weight: .semibold))
                        Text(verbatim: GameShortcutGroup.language.detail).font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 2)
                    Text(verbatim: "2").font(.system(size: 10)).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right").font(.system(size: 8, weight: .semibold))
                        .rotationEffect(.degrees(tick % 2 == 1 ? 90 : 0)).foregroundStyle(.secondary)
                }
                if tick % 2 == 1 {
                    HStack(spacing: 12) {
                        GameRuleFrame(rule: .focusKeys, keys: ["⌃Space"], story: .still(on: true), height: 54)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: GameShortcutDescription.language.text).font(.system(size: 10, weight: .medium))
                            Text(verbatim: GameShortcutMode.automatic.title).font(.system(size: 9)).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    HStack(spacing: 9) {
                        Image(systemName: GameShortcutGroup.screenshots.symbol).foregroundStyle(Color.accentColor).frame(width: 28)
                        Text(verbatim: GameShortcutGroup.screenshots.title).font(.system(size: 12, weight: .semibold))
                        Spacer()
                        Text(verbatim: "9").font(.system(size: 10)).foregroundStyle(.secondary)
                        Image(systemName: "chevron.right").font(.system(size: 8, weight: .semibold)).foregroundStyle(.secondary)
                    }.frame(height: 36)
                }
            }
            .padding(.horizontal, 18)
            .animation(.easeInOut(duration: 0.25), value: tick)
        }
    }
}

private struct UnifiedGamePreviewCard: View {
    @State private var tick = 0

    var body: some View {
        let background = tick % 2 == 0
        VStack(alignment: .leading, spacing: 7) {
            IllustrationRow {
                GameRuleFrame(rule: .focusKeys, keys: ["⌃Space"], story: .still(on: true), height: 108)
            }
            .frame(width: 680).scaleEffect(0.5).frame(width: 340, height: 64)
            HStack(spacing: 8) {
                Text(verbatim: GameShortcutGroup.language.title).font(.system(size: 12, weight: .medium))
                Spacer(minLength: 4)
                Text(verbatim: (background ? GameShortcutMode.automatic : .system).title).font(.system(size: 10))
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 7))
            }
            Text(verbatim: background ? GameShortcutDescription.language.text : String(localized: "macOS runs the action normally, even if it opens a window or takes focus from the game."))
                .font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(2)
        }
        .padding(.bottom, 8)
        .loop($tick, [2.7, 2.7])
    }
}

private struct GameChoicesCard: View {
    private let entry = SystemGameShortcut(id: 60, name: "", section: "input_sources", sectionName: "", rawName: "", key: 49, character: 32, modifiers: 0x40000, enabled: true)

    var body: some View {
        IllustrationRow(loop: [2.7, 2.7]) { tick in
            VStack(spacing: 4) {
                ForEach([GameShortcutMode.automatic, .pause], id: \.self) { mode in
                    let selected = mode == (tick % 2 == 0 ? .automatic : .pause)
                    HStack(alignment: .top, spacing: 7) {
                        Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.accentColor).opacity(selected ? 1 : 0).frame(width: 12).padding(.top, 1)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(verbatim: mode.title).font(.system(size: 11, weight: .medium))
                            Text(verbatim: entry.explanation(for: mode, rules: Set(GameRule.allCases)))
                                .font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(7)
                    .background(Color.accentColor.opacity(selected ? 0.1 : 0), in: RoundedRectangle(cornerRadius: 7))
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

private struct PermissionsCard: View {
    var body: some View {
        IllustrationRow(loop: [2.7, 2.7]) { tick in
            let allowed = tick % 2 == 1
            let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
            VStack(spacing: 0) {
                PermissionArtRow(permission: .accessibility, granted: true)
                PermissionArtRow(permission: .inputMonitoring, granted: true)
                PermissionArtRow(permission: .fans, granted: allowed)
                Divider().padding(.horizontal, 10)
                HStack(spacing: 8) {
                    SectionIcon(symbol: "fan", color: .blue, size: 18)
                    Capsule().fill(Color.primary.opacity(0.14)).frame(height: 4)
                        .overlay(alignment: .leading) { Capsule().fill(Color.accentColor).frame(width: 52, height: 4) }
                        .overlay(alignment: .leading) { Circle().fill(.white).frame(width: 12, height: 12).shadow(color: .black.opacity(0.25), radius: 1, y: 0.5).offset(x: 46) }
                }
                .padding(.horizontal, 10)
                .frame(height: 26)
                .opacity(allowed ? 1 : 0.4)
            }
            .frame(width: 300)
            .background(Color(nsColor: .controlBackgroundColor), in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            .animation(.smooth(duration: 0.3), value: allowed)
        }
    }
}

private struct PermissionArtRow: View {
    let permission: Permission
    let granted: Bool

    var body: some View {
        HStack(spacing: 8) {
            SectionIcon(symbol: permission.symbol, color: .blue, size: 18)
            Text(verbatim: permission.title).font(.system(size: 11, weight: .medium))
            Spacer(minLength: 4)
            Text(granted ? "Turn Off" : "Allow")
                .font(.system(size: 9.5))
                .padding(.horizontal, 7)
                .frame(height: 17)
                .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(granted ? Color.green : Color.orange)
        }
        .padding(.horizontal, 10)
        .frame(height: 26)
    }
}

private struct CommandKeysArt: View {
    @State private var tick = 0

    var body: some View {
        let step = tick % 5
        let closed = step >= 3
        IllustrationRow {
            Stage {
                ArtWindow {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .keyframeAnimator(initialValue: 0.0, trigger: tick / 5 + (step >= 1 ? 1 : 0)) { content, x in
                    content.offset(x: x)
                } keyframes: { _ in
                    KeyframeTrack {
                        for x in [-6.0, 5, -4, 3, 0] { LinearKeyframe(x, duration: 0.07) }
                    }
                }
                .scaleEffect(closed ? 0.9 : 1)
                .opacity(closed ? 0 : 1)
                .position(x: 150, y: 46)
                HStack(spacing: 6) {
                    ArtKey(down: step == 3, width: 40) { Text(verbatim: "⇧") }
                    ArtKey(down: step == 1 || step == 3) { Text(verbatim: "⌘") }
                    ArtKey(down: step == 1 || step == 3) { Text(verbatim: "Q") }
                }
                .position(x: 150, y: 104)
            }
            .animation(.smooth(duration: 0.3), value: step)
        }
        .loop($tick, [0.9, 0.9, 0.5, 1.0, 1.2])
    }
}

private struct DockShelfArt: View {
    var symbol = "gamecontroller.fill"
    @State private var tick = 0

    private static let colors: [Color] = [.teal, .orange, .purple, .pink]

    var body: some View {
        let step = tick % 4
        IllustrationRow {
            Stage {
                HStack(spacing: 14) {
                    ForEach(Self.colors.indices, id: \.self) { index in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(LinearGradient(colors: [Self.colors[index], Self.colors[index].opacity(0.65)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if index == 2 { Image(systemName: symbol).font(.system(size: 18)).foregroundStyle(.white) }
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    if index == 2 && step == 3 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 17, weight: .semibold))
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, Color.accentColor)
                                            .offset(x: 4, y: 4)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .scaleEffect(index == 2 && step == 2 ? 0.9 : 1)
                            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 28, height: 4)
                        }
                    }
                }
                .padding(14)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .position(x: 150, y: 64)
                ArtCursor(pressed: step == 2)
                    .cursor(at: step == 0 ? CGPoint(x: 238, y: 108) : CGPoint(x: 168, y: 52))
            }
            .animation(.smooth(duration: 0.4), value: step)
        }
        .loop($tick, [1.2, 1.1, 0.15, 1.4])
    }
}

private struct SwitchRowsArt: View {
    let rows: [(lead: AnyView, line: CGFloat)]
    var height: CGFloat = 32
    @State private var tick = 0

    var body: some View {
        let step = tick % 4
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        rows[index].lead
                        Capsule().fill(Color.primary.opacity(0.12)).frame(width: rows[index].line, height: 4)
                        Spacer(minLength: 0)
                        ArtSwitch(on: step != index + 1)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: height)
                }
            }
            .frame(width: 252)
            .background(Color(nsColor: .controlBackgroundColor), in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            .animation(.smooth(duration: 0.3), value: step)
        }
        .loop($tick, [1.2, 1.0, 1.0, 1.0])
    }
}

private struct ArtSwitch: View {
    let on: Bool

    var body: some View {
        Capsule()
            .fill(on ? Color.accentColor : Color.primary.opacity(0.16))
            .frame(width: 26, height: 15)
            .overlay {
                Circle()
                    .fill(.white)
                    .frame(width: 13, height: 13)
                    .shadow(color: .black.opacity(0.2), radius: 0.5, y: 0.5)
                    .offset(x: on ? 5.5 : -5.5)
            }
    }
}

private struct PetBallArt: View {
    static let length = 7.2
    @Environment(\.colorScheme) private var scheme

    private static let ground: CGFloat = 100
    private static let scale: CGFloat = 1.2

    private static func arc(_ p: Double, _ height: CGFloat) -> CGFloat { 4 * height * CGFloat(p * (1 - p)) }

    private static func pet(_ t: Double) -> (x: CGFloat, pose: PetPose) {
        var pose = PetPose()
        pose.blink = t.truncatingRemainder(dividingBy: 3.1) < 0.13
        func walk(_ from: CGFloat, _ to: CGFloat, _ p: Double) -> CGFloat {
            pose.facing = to > from ? 1 : -1
            pose.step = p * Double(max(1, (abs(to - from) / scale * 5 / 56).rounded())) * 2 * .pi
            return from + (to - from) * CGFloat(p)
        }
        switch t {
        case ..<1.0: return (walk(40, 66, t / 1.0), pose)
        case ..<1.35:
            let swing = sin(.pi * (t - 1.0) / 0.35)
            pose.step = .pi / 3 * swing
            pose.tilt = -0.14 * swing
            return (66, pose)
        case ..<3.0: return (walk(66, 120, (t - 1.35) / 1.65), pose)
        case ..<3.6:
            pose.facing = t < 3.35 ? 1 : -1
            return (120, pose)
        case ..<4.4: return (walk(120, 94, (t - 3.6) / 0.8), pose)
        case ..<4.95:
            let p = (t - 4.4) / 0.55
            pose.facing = -1
            pose.air = true
            pose.lift = arc(p, 11)
            pose.squash = -0.09 * abs(1 - 2 * CGFloat(p))
            return (94 - 32 * CGFloat(p), pose)
        case ..<5.6:
            let x = walk(62, 40, (t - 4.95) / 0.65)
            if t - 4.95 < 0.15 { pose.squash = 0.14 * (1 - CGFloat(t - 4.95) / 0.15) }
            return (x, pose)
        default:
            pose.facing = t < 5.9 ? -1 : 1
            return (40, pose)
        }
    }

    private static func ball(_ t: Double) -> (x: CGFloat, pose: BallPose) {
        let r = BallPhysics.radius / PetStage.scale
        var x: CGFloat = 78, pose = BallPose()
        switch t {
        case 1.2..<2.8:
            let p = (t - 1.2) / 1.6
            x = 78 + 72 * CGFloat(1 - (1 - p) * (1 - p))
            pose.lift = p < 0.4 ? arc(p / 0.4, 10) : p < 0.6 ? arc((p - 0.4) / 0.2, 3) : 0
        case 2.8..<3.3: x = 150
        case 3.3..<4.6:
            let p = (t - 3.3) / 1.3
            x = 150 - 72 * PetPose.ease(p)
            pose.lift = p < 0.75 ? arc(p / 0.75, 26) : arc((p - 0.75) / 0.25, 4)
        default: break
        }
        pose.angle = (x - 78) / scale / r
        return (x, pose)
    }

    private static func cursor(_ t: Double) -> CGPoint {
        let point = switch t {
        case 2.3..<3.25: CGPoint(x: 166, y: 88)
        case 3.25..<4.3: CGPoint(x: 128, y: 84)
        default: CGPoint(x: 150, y: 30)
        }
        return CGPoint(x: point.x + 52, y: point.y + 10)
    }

    var body: some View {
        let night = scheme == .dark
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            ArtTimeline { time in
                let t = time.map { GameStory.mod($0, Self.length) } ?? 0.5
                let pet = Self.pet(t), ball = Self.ball(t)
                Stage {
                    ZStack {
                        LinearGradient(
                            colors: night ? [Color(red: 0.10, green: 0.11, blue: 0.27), Color(red: 0.29, green: 0.20, blue: 0.42)]
                                : [Color(red: 0.60, green: 0.79, blue: 0.98), Color(red: 0.99, green: 0.86, blue: 0.80)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .overlay {
                            Ellipse()
                                .fill(night ? Color(red: 0.36, green: 0.25, blue: 0.50) : Color(red: 1, green: 0.78, blue: 0.70))
                                .frame(width: 300, height: 90)
                                .offset(x: 40, y: 70)
                        }
                        ArtWindow(size: CGSize(width: 84, height: 52)) {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach([46.0, 60, 34], id: \.self) {
                                    Capsule().fill(Color.primary.opacity(0.12)).frame(width: $0, height: 4)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 9)
                        }
                        .position(x: 54, y: 36)
                        Canvas { context, _ in
                            var figure = context
                            figure.translateBy(x: pet.x, y: Self.ground)
                            figure.scaleBy(x: Self.scale, y: Self.scale)
                            PetFigure.shadow(pet.pose) { figure.fill($0, with: .color($1)) }
                            PetFigure.draw(pet.pose, night: night) { figure.fill($0, with: .color($1)) }
                            var toy = context
                            toy.translateBy(x: ball.x, y: Self.ground)
                            toy.scaleBy(x: Self.scale, y: Self.scale)
                            BallFigure.draw(ball.pose, night: night) { toy.fill($0, with: .color($1)) }
                        }
                    }
                    .frame(width: 196, height: 108)
                    .clipShape(shape)
                    .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    .position(x: 150, y: 64)
                    ArtCursor()
                        .cursor(at: Self.cursor(t))
                }
            }
        }
    }
}

private struct WardrobeCard: View {
    static let length = 9.6

    var body: some View {
        IllustrationRow {
            ArtTimeline { time in
                WardrobeScene(t: time.map { GameStory.mod($0, Self.length) } ?? 7.5)
            }
        }
    }
}

private struct WardrobeScene: View {
    let t: Double
    @Environment(\.colorScheme) private var scheme

    private static let award = PetAward.stylist
    private static let looks = ["wizard", "astronaut", "pirate", "hero"].compactMap { id in PetLook.all.first { $0.id == id }?.outfit }
    private static let lens = CGRect(x: -13, y: -22, width: 26, height: 23)
    private static let tiles = [CGPoint(x: 193, y: 37), CGPoint(x: 247, y: 37), CGPoint(x: 193, y: 91), CGPoint(x: 247, y: 91)]
    private static let picks = [0.7, 2.2, 3.7, 5.2]
    private static let swap = 0.1
    private static let ground = CGPoint(x: 82, y: 112)
    private static let scale: CGFloat = 3.4
    private static let centre = CGPoint(x: 220, y: 64)
    private static let medalSize: CGFloat = 78
    private static let confetti = [Art.yellow, Color(red: 1, green: 0.56, blue: 0.70), Art.yellow, Color.accentColor]
    private static let twinkles: [(offset: CGPoint, start: Double, size: CGFloat)] = [
        (CGPoint(x: -50, y: -36), 7.0, 6), (CGPoint(x: 52, y: -38), 7.3, 5), (CGPoint(x: 56, y: 24), 7.55, 6),
        (CGPoint(x: -46, y: 34), 7.8, 4.5), (CGPoint(x: 4, y: -56), 8.05, 4),
    ]

    private static let route: [(Double, CGPoint)] = {
        let tips = tiles.map { CGPoint(x: $0.x + 10, y: $0.y + 8) }
        var stops = [(0.1, CGPoint(x: tips[0].x + 6, y: -26)), (picks[0] - 0.1, tips[0])]
        for k in 1..<tips.count {
            stops += [(picks[k - 1] + 0.5, tips[k - 1]), (picks[k] - 0.1, tips[k])]
        }
        return stops + [(picks[tips.count - 1] + 0.5, tips[tips.count - 1]), (6.3, CGPoint(x: 336, y: 128))]
    }()

    private var current: Int { Self.picks.lastIndex { t >= $0 + Self.swap } ?? Self.picks.count - 1 }

    private var pose: PetPose {
        var pose = PetPose(outfit: Self.looks[current])
        pose.blink = GameStory.mod(t + 0.4, 3.2) < 0.13
        let jumps = Self.picks.map { ($0 + Self.swap, 6.0) } + [(6.6, 7.5), (7.2, 7.5)]
        for (start, height) in jumps {
            let p = (t - start) / 0.5
            if (0..<1).contains(p) {
                pose.air = true
                pose.lift = 4 * height * p * (1 - p)
                pose.squash = -0.09 * abs(1 - 2 * p)
            } else if (1..<1.4).contains(p) {
                pose.squash = 0.14 * (1 - (p - 1) / 0.4)
            }
        }
        return pose
    }

    private static func star(_ centre: CGPoint, _ radius: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: centre.x, y: centre.y - radius))
        path.addQuadCurve(to: CGPoint(x: centre.x + radius, y: centre.y), control: centre)
        path.addQuadCurve(to: CGPoint(x: centre.x, y: centre.y + radius), control: centre)
        path.addQuadCurve(to: CGPoint(x: centre.x - radius, y: centre.y), control: centre)
        path.addQuadCurve(to: CGPoint(x: centre.x, y: centre.y - radius), control: centre)
        return path
    }

    private func burst(_ context: GraphicsContext, at centre: CGPoint, from start: Double, reach: CGSize) {
        let p = (t - start) / 0.8
        guard (0..<1).contains(p) else { return }
        let out = CGFloat(0.55 + 0.45 * (1 - (1 - p) * (1 - p)))
        for k in 0..<8 {
            let angle = CGFloat(k) * .pi / 4 + 0.39
            let point = CGPoint(x: centre.x + reach.width * out * cos(angle), y: centre.y + reach.height * out * sin(angle))
            let radius = (k.isMultiple(of: 2) ? 5.5 : 3.5) * CGFloat(sin(.pi * p))
            context.fill(Self.star(point, radius), with: .color(Self.confetti[k % Self.confetti.count]))
        }
    }

    private func tile(_ index: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        let selected = index == current
        return PetThumb(outfit: Self.looks[index], lens: Self.lens)
            .frame(width: 38, height: 34)
            .frame(width: 46, height: 46)
            .background(selected ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor), in: shape)
            .overlay(shape.strokeBorder(selected ? Color.accentColor : Color.primary.opacity(0.12), lineWidth: selected ? 2 : 0.5))
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .scaleEffect((0..<0.14).contains(t - Self.picks[index]) ? 0.92 : 1)
            .position(Self.tiles[index])
    }

    private var medal: some View {
        let size = Self.medalSize
        let arrive = min(max((t - 6.3) / 0.6, 0), 1)
        let overshoot = 1 + 2.70158 * pow(arrive - 1, 3) + 1.70158 * pow(arrive - 1, 2)
        let leave = GameStory.ramp(t, 8.95, 0.4)
        let sweep = (t - 7.0) / 0.8
        return Medal(award: Self.award, size: size)
            .overlay {
                if (0..<1).contains(sweep) {
                    let glint = 1.3 * sweep - 0.15
                    MedalShape(kind: Self.award.kind, inset: size * 0.08)
                        .fill(LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0), location: 0.2),
                                .init(color: .white.opacity(0.5), location: 0.42),
                                .init(color: .white.opacity(0.9), location: 0.5),
                                .init(color: .white.opacity(0.5), location: 0.58),
                                .init(color: .white.opacity(0), location: 0.8),
                            ],
                            startPoint: UnitPoint(x: glint - 0.3, y: glint - 0.3),
                            endPoint: UnitPoint(x: glint + 0.3, y: glint + 0.3)
                        ))
                }
            }
            .scaleEffect((0.25 + 0.75 * overshoot) * (1 - 0.2 * leave))
            .rotationEffect(.degrees((1 - arrive) * -16))
            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
            .offset(y: 1.5 * sin(2 * .pi * t / 2.4))
            .opacity(GameStory.ramp(t, 6.3, 0.25) * (1 - leave))
            .position(Self.centre)
    }

    private var pointer: some View {
        var tip = Self.route[Self.route.count - 1].1
        if let next = Self.route.firstIndex(where: { t < $0.0 }) {
            let (t0, from) = Self.route[max(next - 1, 0)], (t1, to) = Self.route[next]
            let e = next > 0 ? CGFloat(GameStory.ramp(t, t0, t1 - t0)) : 0
            tip = CGPoint(x: from.x + (to.x - from.x) * e, y: from.y + (to.y - from.y) * e)
        }
        return ArtCursor(pressed: Self.picks.contains { (0..<0.14).contains(t - $0) })
            .position(x: tip.x + 6, y: tip.y + 9)
    }

    var body: some View {
        let night = scheme == .dark
        let grid = t < 7 ? 1 - GameStory.ramp(t, 6.0, 0.35) : GameStory.ramp(t, 9.2, 0.35)
        Stage {
            ZStack {
                ForEach(0..<Self.tiles.count, id: \.self) { tile($0) }
            }
            .scaleEffect(0.88 + 0.12 * grid, anchor: UnitPoint(x: Self.centre.x / 300, y: 0.5))
            .opacity(grid)
            medal
            Canvas { context, _ in
                var figure = context
                figure.translateBy(x: Self.ground.x, y: Self.ground.y)
                figure.scaleBy(x: Self.scale, y: Self.scale)
                PetFigure.shadow(pose) { figure.fill($0, with: .color($1)) }
                PetFigure.draw(pose, night: night) { figure.fill($0, with: .color($1)) }
                for pick in Self.picks {
                    burst(context, at: CGPoint(x: Self.ground.x, y: Self.ground.y - 40), from: pick + Self.swap, reach: CGSize(width: 58, height: 40))
                }
                burst(context, at: Self.centre, from: 6.5, reach: CGSize(width: 62, height: 50))
                for twinkle in Self.twinkles {
                    let p = (t - twinkle.start) / 0.7
                    guard (0..<1).contains(p) else { continue }
                    let at = CGPoint(x: Self.centre.x + twinkle.offset.x, y: Self.centre.y + twinkle.offset.y)
                    context.fill(Self.star(at, twinkle.size * CGFloat(sin(.pi * p))), with: .color(Art.yellow))
                }
            }
            pointer
        }
    }
}

private struct SpeedTestArt: View {
    @State private var tick = 0

    private static let speeds: [(Double?, Double?)] = [(nil, nil), (184, nil), (436, nil), (512, 46), (512, 98)]

    var body: some View {
        let step = tick % Self.speeds.count
        let (down, up) = Self.speeds[step]
        IllustrationRow {
            HStack(spacing: 0) {
                number("arrow.down", down, active: step == 1 || step == 2)
                Rectangle().fill(Color.primary.opacity(0.12)).frame(width: 0.5, height: 56)
                number("arrow.up", up, active: step == 3)
            }
            .frame(width: 260)
            .animation(.snappy, value: step)
        }
        .loop($tick, [1.0, 0.8, 0.8, 0.8, 2.0])
    }

    private func number(_ symbol: String, _ value: Double?, active: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(active ? Color.accentColor : .secondary)
            Text(verbatim: value.map(SpeedTest.format) ?? "–")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(value == nil ? .tertiary : .primary)
                .contentTransition(.numericText(value: value ?? 0))
        }
        .frame(maxWidth: .infinity)
    }
}

enum APNG {
    private static let table: [UInt32] = (0..<256).map { n in
        (0..<8).reduce(UInt32(n)) { c, _ in c & 1 == 1 ? 0xEDB8_8320 ^ (c >> 1) : c >> 1 }
    }

    static func bytes(_ image: CGImage) -> [UInt32] {
        var data = [UInt32](repeating: 0, count: image.width * image.height)
        let context = CGContext(data: &data, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return data
    }

    static func encode(_ frames: [[UInt32]], width: Int, height: Int, fps: Int) throws -> Data {
        let palette = quantize(frames)
        let indexed = map(frames, to: palette, width: width)
        var canvas = indexed[0]
        var parts: [(x: Int, y: Int, w: Int, h: Int, pixels: [UInt8], over: Bool, length: Int)] = [(0, 0, width, height, canvas, false, 1)]
        for frame in indexed.dropFirst() {
            var box = (minX: width, minY: height, maxX: -1, maxY: -1)
            for i in 0..<frame.count where frame[i] != canvas[i] {
                box = (min(box.minX, i % width), min(box.minY, i / width), max(box.maxX, i % width), max(box.maxY, i / width))
            }
            if box.maxX < 0 {
                parts[parts.count - 1].length += 1
                continue
            }
            let w = box.maxX - box.minX + 1, h = box.maxY - box.minY + 1
            var sub = [UInt8](repeating: 0, count: w * h)
            var over = true
            for y in 0..<h {
                for x in 0..<w {
                    let i = (box.minY + y) * width + box.minX + x
                    sub[y * w + x] = frame[i]
                    if frame[i] != canvas[i] {
                        if palette[Int(frame[i])] >> 24 < 255 { over = false }
                    } else {
                        sub[y * w + x] = 0
                    }
                    canvas[i] = frame[i]
                }
            }
            if !over {
                for y in 0..<h { sub.replaceSubrange(y * w..<(y + 1) * w, with: frame[(box.minY + y) * width + box.minX..<(box.minY + y) * width + box.minX + w]) }
            }
            parts.append((box.minX, box.minY, w, h, sub, over, 1))
        }

        var out: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
        var sequence: UInt32 = 0
        func be(_ value: some FixedWidthInteger) -> [UInt8] { withUnsafeBytes(of: value.bigEndian) { Array($0) } }
        func chunk(_ type: String, _ body: [UInt8]) {
            let typed = Array(type.utf8) + body
            out += be(UInt32(body.count)) + typed + be(~typed.reduce(~UInt32(0)) { table[Int(($0 ^ UInt32($1)) & 0xFF)] ^ ($0 >> 8) })
        }
        chunk("IHDR", be(UInt32(width)) + be(UInt32(height)) + [8, 3, 0, 0, 0])
        chunk("acTL", be(UInt32(parts.count)) + be(UInt32(0)))
        chunk("PLTE", palette.flatMap { color in
            let alpha = color >> 24
            return [0, 8, 16].map { UInt8(alpha == 0 ? 0 : min(255, (color >> $0 & 0xFF) * 255 / alpha)) }
        })
        chunk("tRNS", palette.map { UInt8($0 >> 24) })
        for (index, part) in parts.enumerated() {
            let frame: [UInt8] = be(UInt32(part.w)) + be(UInt32(part.h)) + be(UInt32(part.x)) + be(UInt32(part.y))
            let timing: [UInt8] = be(UInt16(part.length)) + be(UInt16(fps)) + [0, part.over ? 1 : 0]
            chunk("fcTL", be(sequence) + frame + timing)
            sequence += 1
            let data = try zlib((0..<part.h).flatMap { [0] + part.pixels[$0 * part.w..<($0 + 1) * part.w] })
            if index == 0 {
                chunk("IDAT", data)
            } else {
                chunk("fdAT", be(sequence) + data)
                sequence += 1
            }
        }
        chunk("IEND", [])
        return Data(out)
    }

    private static func quantize(_ frames: [[UInt32]]) -> [UInt32] {
        var counts: [UInt32: Int] = [:]
        for frame in frames { for color in frame where color >> 24 > 0 { counts[color, default: 0] += 1 } }
        var colors = counts.map { (color: $0.key, count: $0.value) }
        var boxes = [0..<colors.count]
        while boxes.count < 255 {
            var best: (score: Int, box: Int, shift: UInt32) = (0, -1, 0)
            for (index, box) in boxes.enumerated() where box.count > 1 {
                let weight = colors[box].reduce(0) { $0 + $1.count }
                for shift: UInt32 in [0, 8, 16, 24] {
                    let values = colors[box].map { $0.color >> shift & 0xFF }
                    let score = Int(values.max()! - values.min()!) * Int(Double(weight).squareRoot())
                    if score > best.score { best = (score, index, shift) }
                }
            }
            guard best.box >= 0 else { break }
            let box = boxes[best.box]
            colors[box].sort { $0.color >> best.shift & 0xFF < $1.color >> best.shift & 0xFF }
            let half = colors[box].reduce(0) { $0 + $1.count } / 2
            var split = box.lowerBound, total = 0
            while split < box.upperBound - 1, total + colors[split].count <= half || split == box.lowerBound {
                total += colors[split].count
                split += 1
            }
            boxes[best.box] = box.lowerBound..<split
            boxes.append(split..<box.upperBound)
        }
        let palette: [UInt32] = [0] + boxes.map { box in
            let weight = colors[box].reduce(0) { $0 + $1.count }
            return [0, 8, 16, 24].reduce(UInt32(0)) { color, shift in
                let sum = colors[box].reduce(0) { $0 + Int($1.color >> UInt32(shift) & 0xFF) * $1.count }
                return color | UInt32((sum + weight / 2) / weight) << UInt32(shift)
            }
        }
        return palette
    }

    private static let bayer = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

    private static func map(_ frames: [[UInt32]], to palette: [UInt32], width: Int) -> [[UInt8]] {
        var lookup: [UInt64: UInt8] = [:]
        func nearest(_ color: UInt32) -> UInt8 {
            UInt8(palette.indices.dropFirst().min { distance(palette[$0], color) < distance(palette[$1], color) }!)
        }
        return frames.map { frame in
            frame.indices.map { i in
                let color = frame[i]
                guard color >> 24 > 0 else { return 0 }
                let cell = bayer[(i / width & 3) * 4 + i % width & 3]
                if let index = lookup[UInt64(color) << 5 | UInt64(cell)] ?? lookup[UInt64(color) << 5 | 16] { return index }
                let exact = nearest(color)
                if color >> 24 < 255 || distance(palette[Int(exact)], color) <= 27 {
                    lookup[UInt64(color) << 5 | 16] = exact
                    return exact
                }
                let offset = (cell * 2 - 15) * 2 / 5
                let index = nearest([0, 8, 16].reduce(color & 0xFF00_0000) { sum, shift in
                    sum | UInt32(max(0, min(255, Int(color >> UInt32(shift) & 0xFF) + offset))) << UInt32(shift)
                })
                lookup[UInt64(color) << 5 | UInt64(cell)] = index
                return index
            }
        }
    }

    private static func distance(_ a: UInt32, _ b: UInt32) -> Int {
        [0, 8, 16, 24].reduce(0) { sum, shift in
            let d = Int(a >> UInt32(shift) & 0xFF) - Int(b >> UInt32(shift) & 0xFF)
            return sum + d * d
        }
    }

    private static func zlib(_ raw: [UInt8]) throws -> [UInt8] {
        let deflated = try (Data(raw) as NSData).compressed(using: .zlib) as Data
        var a: UInt32 = 1, b: UInt32 = 0
        for byte in raw {
            a = (a + UInt32(byte)) % 65521
            b = (b + a) % 65521
        }
        return [0x78, 0x9C] + deflated + withUnsafeBytes(of: (b << 16 | a).bigEndian) { Array($0) }
    }
}
