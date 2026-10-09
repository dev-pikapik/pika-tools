import SwiftUI

@Observable
final class PetTool: Tool {
    static let shared = PetTool()

    let id = "pet"
    let icon = "pawprint"
    var title: String { String(localized: "Pet") }
    var tab: SettingsTab { .pet }
    var isActive: Bool { isEnabled }
    private(set) var listening = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var talks: Bool {
        didSet { UserDefaults.standard.set(talks, forKey: "pet-talks") }
    }

    var ball: Bool {
        didSet {
            UserDefaults.standard.set(ball, forKey: "pet-ball")
            PetStage.shared.update()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: "pet") as? Bool ?? true
        talks = UserDefaults.standard.object(forKey: "pet-talks") as? Bool ?? true
        ball = UserDefaults.standard.object(forKey: "pet-ball") as? Bool ?? true
    }

    var isDefault: Bool { isEnabled && talks && ball }

    func reset() {
        isEnabled = true
        talks = true
        ball = true
    }

    func load() {
        isEnabled = UserDefaults.standard.object(forKey: "pet") as? Bool ?? true
        talks = UserDefaults.standard.object(forKey: "pet-talks") as? Bool ?? true
        ball = UserDefaults.standard.object(forKey: "pet-ball") as? Bool ?? true
    }

    var settingsView: AnyView {
        AnyView(PetSettings(tool: self))
    }

    func refresh() {
        stopTap()
        guard isEnabled else { return PetStage.shared.stop() }
        PetStage.shared.start()
        startTap()
    }

    fileprivate func resume() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
    }

    private func startTap() {
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: 1 << CGEventType.keyDown.rawValue,
            callback: petCallback,
            userInfo: nil
        ) else { return }
        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        listening = true
    }

    private func stopTap() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        listening = false
    }
}

private func petCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { PetTool.shared.resume() }
    case .keyDown where event.getIntegerValueField(.keyboardEventKeycode) == 49
        && event.getIntegerValueField(.keyboardEventAutorepeat) == 0
        && event.flags.isDisjoint(with: [.maskCommand, .maskControl, .maskAlternate]):
        PetStage.shared.jump()
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct PetPage: View {
    @Bindable private var tool = PetTool.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .pet, text: String(localized: "A little friend who lives at the bottom of your screen"))
            Section {
                PetArt(on: tool.isEnabled)
                tool.settingsView
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .environment(\.inSettings, true)
    }
}

private struct PetSettings: View {
    @Bindable var tool: PetTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: String(localized: "Pet on the desktop"),
            subtitle: Text("Walks along the bottom of the screen, behind your windows and the Dock. Try picking it up!"),
            hint: Text("Walks behind your windows"),
            help: tool.listening ? Text("Press Space and it jumps. Put the pointer in its way and it jumps over it") : Text("Put the pointer in its way and it jumps over it"),
            isOn: $tool.isEnabled
        )
        if inSettings {
            ToggleRow(
                icon: "text.bubble",
                title: String(localized: "Talks sometimes"),
                subtitle: Text("Every now and then it sits down for a chat and tells you when an update is out"),
                isOn: $tool.talks
            )
            .disabled(!tool.isEnabled)
            ToggleRow(
                icon: "soccerball",
                title: String(localized: "Ball"),
                subtitle: Text("A ball rolls along the bottom of the screen. Your pet kicks it, and you can kick it with the pointer or pick it up and throw it"),
                isOn: $tool.ball
            )
            .disabled(!tool.isEnabled)
        }
        if inSettings, tool.isEnabled, !tool.listening {
            LabeledContent(String(localized: "To make it jump when you press Space, allow Input Monitoring")) {
                Button("Open", systemImage: "arrow.up.forward.app") { Permissions.shared.openSettings("Privacy_ListenEvent") }
            }
            .foregroundStyle(.secondary)
        }
    }
}

struct PetArt: View {
    let on: Bool
    @Environment(\.colorScheme) private var scheme

    private enum Move { case walk, hop, leap, turn, sit, tumble, lie, getUp }

    private static let script: [(move: Move, time: Double, dx: CGFloat)] = [
        (.walk, 4.8, 106), (.hop, 0.55, 12), (.walk, 0.9, 20), (.turn, 0.7, 0), (.walk, 0.2, -4), (.sit, 3.4, 0),
        (.leap, 0.75, -60), (.walk, 3.9, -86), (.tumble, 0.45, 12), (.lie, 0.5, 0), (.getUp, 0.5, 0),
    ]
    private static let length = script.reduce(0) { $0 + $1.time }
    private static let screen = CGSize(width: 196, height: 108)
    private static let ground: CGFloat = 105
    private static let scale: CGFloat = 1.2
    private static let still = 8.6
    private static let rest = CGPoint(x: 44, y: 34)

    private struct Frame {
        var x: CGFloat = 46
        var pose = PetPose()
        var bubble = 0.0
    }

    private static func frame(_ t: Double) -> Frame {
        var frame = Frame(), start = 0.0, previous = Move.getUp
        for (move, time, dx) in script {
            guard t >= start + time else {
                let p = (t - start) / time
                frame.x += dx * p
                frame.pose.facing = dx > 0 || move == .getUp || move == .turn && p < 0.5 ? 1 : -1
                let fall = CGFloat.pi / 2 * frame.pose.facing
                switch move {
                case .walk:
                    let cycles = max(1, (abs(dx) / scale * 5 / 56).rounded())
                    frame.pose.step = p * cycles * 2 * .pi
                    let landed = t - start
                    if previous == .hop || previous == .leap, landed < 0.15 { frame.pose.squash = 0.14 * (1 - landed / 0.15) }
                case .hop, .leap, .tumble:
                    let height: CGFloat = move == .hop ? 10 : move == .leap ? 22 : 6
                    frame.pose.air = true
                    frame.pose.lift = 4 * height * p * (1 - p)
                    if move == .tumble {
                        frame.pose.tilt = fall * PetPose.ease((t - start) / 0.3)
                    } else {
                        frame.pose.squash = -0.09 * abs(1 - 2 * p)
                    }
                case .lie:
                    frame.pose.tilt = fall
                    frame.pose.dizzy = true
                case .getUp:
                    frame.pose.tilt = fall * (1 - PetPose.ease(p))
                    frame.pose.dizzy = p < 0.5
                case .sit:
                    let local = t - start
                    frame.pose.sit = PetPose.ease(min(local, time - local) / 0.25)
                    frame.bubble = Double(PetPose.ease(min(local - 0.35, time - 0.35 - local) / 0.2))
                case .turn:
                    break
                }
                frame.pose.blink = !frame.pose.dizzy && t.truncatingRemainder(dividingBy: 3.8) < 0.13
                return frame
            }
            start += time
            frame.x += dx
            previous = move
        }
        return frame
    }

    private static func cursor(_ t: Double) -> CGPoint {
        let point = switch t {
        case 7.9..<11.6: CGPoint(x: 144, y: 88)
        case 13..<15.9: CGPoint(x: 14, y: 88)
        default: rest
        }
        return CGPoint(x: point.x + 52, y: point.y + 10)
    }

    var body: some View {
        let night = scheme == .dark
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            ArtTimeline { time in
                let t = time.map { GameStory.mod($0, Self.length) } ?? Self.still
                let frame = Self.frame(t)
                Stage {
                    ArtKey(down: (4.72..<4.9).contains(t), width: 44, height: 20) {
                        Text("Space").lineLimit(1).minimumScaleFactor(0.5).padding(.horizontal, 3)
                    }
                    .position(x: 26, y: 64)
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
                            figure.translateBy(x: frame.x, y: Self.ground)
                            figure.scaleBy(x: Self.scale, y: Self.scale)
                            PetFigure.shadow(frame.pose) { figure.fill($0, with: .color($1)) }
                            PetFigure.draw(frame.pose, night: night) { figure.fill($0, with: .color($1)) }
                        }
                        .opacity(on ? 1 : 0)
                        ArtDock(icon: 12)
                            .offset(y: 41.7)
                        PetArtBubble()
                            .scaleEffect(0.6 + 0.4 * frame.bubble, anchor: .bottom)
                            .opacity(on ? frame.bubble : 0)
                            .position(x: frame.x, y: Self.ground - 31)
                    }
                    .frame(width: Self.screen.width, height: Self.screen.height)
                    .clipShape(shape)
                    .overlay(shape.strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    .position(x: 150, y: 64)
                    ArtCursor()
                        .cursor(at: Self.cursor(t))
                }
                .animation(.smooth(duration: 0.4), value: on)
            }
        }
    }
}

private struct PetArtBubble: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(Art.red)
            .frame(width: 22, height: 15)
            .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }
}
