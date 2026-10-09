import AppKit
import CoreAudio
import SwiftUI

final class PetStage: NSObject {
    static let shared = PetStage()
    static let scale: CGFloat = 2.4
    static let width: CGFloat = 72
    static let height: CGFloat = 190
    static let ground: CGFloat = 4

    private let launched = ProcessInfo.processInfo.systemUptime
    private var window: NSPanel?
    private var field: NSPanel?
    private var bubble: NSPanel?
    private var link: CADisplayLink?
    private let view = FigureView(PetPose()) { pose, night, fill in
        PetFigure.shadow(pose, fill: fill)
        PetFigure.draw(pose, night: night, fill: fill)
    }
    private let ballView = FigureView(BallPose(), paint: BallFigure.draw)
    private let grip = PetHand()
    private let ballGrip = PetHand()
    private var raised = false, tossed = false
    private var fake: CGPoint?
    private var anchor = CGPoint.zero
    private var grabbed = 0.0
    private var physics = PetPhysics(bounds: CGRect(x: 0, y: ground, width: 600, height: height - ground))
    private var ball = BallPhysics(bounds: CGRect(x: 0, y: ground, width: 600, height: height - ground), x: 300)
    private var press: CGPoint?
    private var monitor: Any?
    private var chase = 0.0
    private var last: CFTimeInterval?
    private var observers: [(NotificationCenter, NSObjectProtocol)] = []
    private var asleep = false, locked = false, fullscreen = false
    private var recheck: Timer?
    private var nextTalk: TimeInterval
    private var deck: [PetPhrase] = []
    private var phrase: PetPhrase?

    private override init() {
        nextTalk = launched + .random(in: 600...840)
    }

    private let dev = Bundle.main.bundleIdentifier?.hasSuffix(".dev") == true

    private var demo: String? {
        dev ? UserDefaults.standard.string(forKey: "pet-demo") : nil
    }

    func start() {
        guard window == nil else { return }
        let window = Self.panel(view, grip), field = Self.panel(ballView, ballGrip)
        self.window = window
        self.field = field

        let link = view.displayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30)
        link.isPaused = true
        link.add(to: .main, forMode: .common)
        self.link = link

        let workspace = NSWorkspace.shared.notificationCenter, local = NotificationCenter.default, distributed = DistributedNotificationCenter.default()
        watch(local, NSApplication.didChangeScreenParametersNotification) { $0.layout() }
        watch(local, NSWindow.didChangeOcclusionStateNotification, window) { _ in }
        watch(local, NSWindow.didChangeOcclusionStateNotification, field) { _ in }
        watch(workspace, NSWorkspace.screensDidSleepNotification) { $0.asleep = true }
        watch(workspace, NSWorkspace.screensDidWakeNotification) { $0.asleep = false }
        watch(workspace, NSWorkspace.sessionDidResignActiveNotification) { $0.locked = true }
        watch(workspace, NSWorkspace.sessionDidBecomeActiveNotification) { $0.locked = false }
        watch(distributed, Notification.Name("com.apple.screenIsLocked")) { $0.locked = true }
        watch(distributed, Notification.Name("com.apple.screenIsUnlocked")) { $0.locked = false }
        watch(workspace, NSWorkspace.accessibilityDisplayOptionsDidChangeNotification) { $0.physics.calm = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
        for name in [NSWorkspace.didActivateApplicationNotification, NSWorkspace.activeSpaceDidChangeNotification] {
            watch(workspace, name) { stage in DispatchQueue.main.async { stage.checkFullscreen() } }
        }

        monitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in self?.pressed(event.locationInWindow) }

        locked = (CGSessionCopyCurrentDictionary() as? [String: Any])?["CGSSessionScreenIsLocked"] as? Bool ?? false
        layout()
        let width = physics.bounds.width, roof = physics.roof
        physics = PetPhysics(bounds: physics.bounds, x: width * (demo == nil ? .random(in: 0.1...0.9) : 0.12), facing: demo == nil && Bool.random() ? -1 : 1)
        physics.roof = roof
        physics.calm = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        ball = BallPhysics(bounds: physics.bounds, x: width * (demo == nil ? .random(in: 0.1...0.9) : 0.4))
        ball.roof = roof
        checkFullscreen()
    }

    func stop() {
        raised = false
        tossed = false
        link?.invalidate()
        link = nil
        recheck?.invalidate()
        recheck = nil
        observers.forEach { $0.0.removeObserver($0.1) }
        observers = []
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        press = nil
        hideBubble()
        bubble = nil
        window?.orderOut(nil)
        window = nil
        field?.orderOut(nil)
        field = nil
        last = nil
    }

    func jump() {
        guard window?.isVisible == true else { return }
        physics.jump()
    }

    fileprivate func grab(at point: CGPoint) {
        guard physics.grab(at: point) || ball.grab(at: point) else { return }
        NSCursor.closedHand.set()
        rise()
        place()
    }

    fileprivate func drop() {
        guard physics.state == .held || ball.held else { return }
        physics.release()
        ball.release()
        NSCursor.arrow.set()
    }

    private static var level: NSWindow.Level {
        NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
    }

    private static func panel(_ figure: NSView, _ hand: PetHand) -> NSPanel {
        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.isExcludedFromWindowsMenu = true
        panel.animationBehavior = .none
        panel.level = level
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.contentView = PetHand()
        panel.contentView?.wantsLayer = true
        panel.contentView?.addSubview(figure)
        panel.contentView?.addSubview(hand)
        hand.addTrackingArea(NSTrackingArea(rect: .zero, options: [.cursorUpdate, .activeAlways, .inVisibleRect], owner: hand))
        return panel
    }

    private func watch(_ center: NotificationCenter, _ name: Notification.Name, _ object: AnyObject? = nil, _ action: @escaping (PetStage) -> Void) {
        let token = center.addObserver(forName: name, object: object, queue: .main) { [weak self] _ in
            guard let self else { return }
            action(self)
            self.update()
        }
        observers.append((center, token))
    }

    private func layout() {
        guard let window, let field, let screen = NSScreen.screens.first else { return }
        let strip = CGRect(x: screen.frame.minX, y: screen.frame.minY, width: screen.frame.width, height: Self.height)
        for (panel, up) in [(window, raised), (field, tossed)] {
            panel.level = up ? .statusBar : Self.level
            panel.setFrame(up ? screen.frame : strip, display: false)
        }
        for figure in [view, ballView] as [NSView] { figure.frame = CGRect(x: figure.frame.minX, y: 0, width: Self.width, height: Self.height) }
        let top = max(Self.height, screen.visibleFrame.maxY - screen.frame.minY)
        let bounds = CGRect(x: 0, y: Self.ground, width: strip.width, height: top - Self.ground)
        physics.resize(bounds)
        ball.resize(bounds)
        let dock = screen.visibleFrame.minY - screen.frame.minY
        physics.roof = dock > Self.ground + PetPhysics.size.height ? dock : Self.height
        ball.roof = physics.roof
        place()
        if let bubble { show(bubble) }
    }

    func update() {
        guard let window, let field, let link else { return }
        let hidden = asleep || locked || fullscreen || GameModeTool.shared.isPlaying
        let toy = PetTool.shared.ball && !hidden
        if hidden {
            window.orderOut(nil)
            hideBubble()
        } else if !window.isVisible {
            window.orderFrontRegardless()
        }
        if toy != field.isVisible { toy ? field.orderFrontRegardless() : field.orderOut(nil) }
        if !toy { ball.release() }
        let waiting = (fullscreen || GameModeTool.shared.isPlaying) && !asleep && !locked
        if waiting != (recheck != nil) {
            recheck?.invalidate()
            recheck = waiting ? Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.checkFullscreen() } : nil
        }
        let paused = hidden || !window.occlusionState.contains(.visible) && !(toy && field.occlusionState.contains(.visible))
        if paused {
            drop()
            window.ignoresMouseEvents = true
            field.ignoresMouseEvents = true
        }
        if paused, !link.isPaused { last = nil }
        if !paused, link.isPaused { physics.resize(physics.bounds) }
        link.isPaused = paused
    }

    private func checkFullscreen() {
        let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier
        let display = CGDisplayBounds(CGMainDisplayID())
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        fullscreen = pid != nil && windows.contains { info in
            guard info[kCGWindowOwnerPID as String] as? pid_t == pid, info[kCGWindowLayer as String] as? Int == 0,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary else { return false }
            return CGRect(dictionaryRepresentation: bounds) == display
        }
        update()
    }

    @objc private func tick(_ link: CADisplayLink) {
        let dt = last.map { link.timestamp - $0 } ?? 0
        last = link.timestamp
        play(demo)
        let point = fake ?? cursor
        if NSEvent.pressedMouseButtons & 1 == 0 { press = nil }
        physics.ledge = demo == "platform" ? demoLedge : selection
        ball.ledge = physics.ledge
        physics.step(dt, cursor: point)
        let toy = field?.isVisible == true, now = ProcessInfo.processInfo.systemUptime
        if toy {
            physics.kick(&ball)
            ball.step(dt, cursor: physics.state == .held ? nil : point, body: physics.aloft ? nil : (physics.previous, physics.frame))
            if ball.impact > 700, physics.grounded || physics.state == .jump { physics.bump(ball.frame) }
            if ball.nudged { chase = min(chase, now + 0.4) }
            if now >= chase {
                physics.face(ball.center.x)
                chase = now + .random(in: 6...16)
            }
        }
        if physics.state == .held || ball.held, fake == nil, NSEvent.pressedMouseButtons & 1 == 0 { drop() }
        rise()
        place()
        let catchable = point.map(physics.touches) ?? false, reachable = toy && (point.map(ball.touches) ?? false)
        if let window, window.ignoresMouseEvents == (catchable || physics.state == .held) { window.ignoresMouseEvents.toggle() }
        if let field, field.ignoresMouseEvents == (reachable || ball.held) { field.ignoresMouseEvents.toggle() }
        if phrase != nil, physics.state != .sit { hideBubble() }
        talk(ProcessInfo.processInfo.systemUptime)
    }

    private var cursor: CGPoint? {
        guard let screen = NSScreen.screens.first else { return nil }
        let point = NSEvent.mouseLocation
        guard physics.state == .held || ball.held || screen.frame.contains(point) else { return nil }
        return CGPoint(x: point.x - screen.frame.minX, y: point.y - screen.frame.minY)
    }

    private var selection: CGRect? {
        guard let press, let screen = NSScreen.screens.first else { return nil }
        let point = NSEvent.mouseLocation
        let rect = CGRect(x: min(press.x, point.x), y: min(press.y, point.y), width: abs(point.x - press.x), height: abs(point.y - press.y))
        return rect.width > 4 && rect.height > 4 ? rect.offsetBy(dx: -screen.frame.minX, dy: -screen.frame.minY) : nil
    }

    private var demoLedge: CGRect? {
        ProcessInfo.processInfo.systemUptime.truncatingRemainder(dividingBy: 14) < 9 ? CGRect(x: physics.bounds.width * 0.2, y: 0, width: 220, height: 16) : nil
    }

    private func pressed(_ point: CGPoint) {
        guard link?.isPaused == false, let screen = NSScreen.screens.first else { return press = nil }
        let spot = CGPoint(x: point.x, y: screen.frame.maxY - point.y)
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        let top = windows.first { info in
            guard info[kCGWindowOwnerPID as String] as? pid_t != getpid(), info[kCGWindowAlpha as String] as? Double ?? 1 > 0,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary, let rect = CGRect(dictionaryRepresentation: bounds) else { return false }
            return rect.contains(spot)
        }
        press = top?[kCGWindowLayer as String] as? Int ?? -1 < 0 ? point : nil
    }

    private func place() {
        put(view, physics.origin.x)
        view.pose = PetPose(physics, scale: Self.scale, time: ProcessInfo.processInfo.systemUptime)
        if grip.frame != physics.frame { grip.frame = physics.frame }
        put(ballView, ball.center.x)
        ballView.pose = BallPose(ball, scale: Self.scale)
        if ballGrip.frame != ball.frame { ballGrip.frame = ball.frame }
    }

    private func put<Pose>(_ figure: FigureView<Pose>, _ x: CGFloat) {
        let scale = window?.backingScaleFactor ?? 2
        let left = x - Self.width / 2, snapped = (left * scale).rounded(.down) / scale
        if figure.frame.minX != snapped { figure.setFrameOrigin(CGPoint(x: snapped, y: 0)) }
        figure.shift = left - snapped
    }

    private func rise() {
        guard physics.aloft != raised || ball.aloft != tossed else { return }
        raised = physics.aloft
        tossed = ball.aloft
        layout()
    }

    private func play(_ demo: String?) {
        switch demo {
        case "jump" where physics.state == .walk && physics.clock > 0.8:
            physics.jump()
        case "tumble" where physics.state == .walk && physics.clock > 1.2:
            physics.bump(physics.frame.offsetBy(dx: physics.facing * 20, dy: 0))
        case "sit" where phrase == nil, "update" where phrase == nil:
            let version = Version.parts(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
            let next = "\(version.first ?? 1).\(version.dropFirst().first.map { $0 + 1 } ?? 1).0"
            say(demo == "sit" ? PetPhrases.all[0] : PetPhrases.update(next), for: .infinity)
        case "hold" where physics.state == .walk && physics.clock > 1.5, "throw" where physics.state == .walk && physics.clock > 1.5:
            fake = CGPoint(x: physics.origin.x, y: physics.frame.maxY - PetPhysics.scruff)
            anchor = fake ?? .zero
            grab(at: anchor)
        case "hold" where physics.state == .held, "throw" where physics.state == .held:
            let t = physics.clock
            fake = CGPoint(x: anchor.x + 80 * sin(t * 3), y: anchor.y + 300 * min(t, 1))
            if demo == "throw", t > 2.1 {
                fake = nil
                drop()
            }
        case "ball" where ball.resting && physics.state == .walk && physics.clock > 2:
            ball.kick(CGVector(dx: physics.origin.x > ball.center.x ? 420 : -420, dy: 260))
        case "carry" where ball.resting && physics.state == .walk && physics.clock > 2:
            fake = ball.center
            anchor = ball.center
            grabbed = ProcessInfo.processInfo.systemUptime
            grab(at: anchor)
        case "carry" where ball.held:
            let t = ProcessInfo.processInfo.systemUptime - grabbed
            fake = CGPoint(x: anchor.x + 80 * sin(t * 3), y: anchor.y + 300 * min(t, 1))
            if t > 2.1 {
                fake = nil
                drop()
            }
        default:
            break
        }
    }

    private func talk(_ now: TimeInterval) {
        guard now >= nextTalk, physics.state == .walk, demo == nil else { return }
        guard PetTool.shared.talks else { return nextTalk = now + .random(in: 1200...1800) }
        let typing = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .keyDown) < 5
        if typing || GameModeTool.shared.isPlaying || Self.microphoneInUse { return nextTalk = now + 45 }
        guard !behindDock else { return }
        say(nextPhrase(), for: 4.4)
        nextTalk = now + .random(in: 1200...1800)
    }

    private var behindDock: Bool {
        guard let screen = NSScreen.screens.first, screen.visibleFrame.minY > screen.frame.minY else { return false }
        let x = physics.origin.x / physics.bounds.width
        return x > 0.18 && x < 0.82
    }

    private func nextPhrase() -> PetPhrase {
        let state = MainActor.assumeIsolated { Updater.shared.state }
        if !dev, case .available(let version) = state, UserDefaults.standard.string(forKey: "pet-told-update") != version {
            UserDefaults.standard.set(version, forKey: "pet-told-update")
            return PetPhrases.update(version)
        }
        if deck.isEmpty { deck = PetPhrases.all.filter { $0.id != "space" || PetTool.shared.listening }.shuffled() }
        return deck.removeLast()
    }

    private static var microphoneInUse: Bool {
        var device = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &device) == noErr else { return false }
        var running = UInt32(0)
        size = UInt32(MemoryLayout<UInt32>.size)
        address.mSelector = kAudioDevicePropertyDeviceIsRunningSomewhere
        return AudioObjectGetPropertyData(device, &address, 0, nil, &size, &running) == noErr && running != 0
    }

    private func say(_ phrase: PetPhrase, for seconds: Double) {
        guard physics.sit(seconds) else { return }
        hideBubble()
        let clickable = phrase.id == "update" || phrase.link != nil
        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.isExcludedFromWindowsMenu = true
        panel.animationBehavior = .none
        panel.level = Self.level
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        panel.ignoresMouseEvents = !clickable
        panel.contentView = BubbleHost(rootView: PetBubble(text: phrase.text, clickable: clickable, tail: 0) { [weak self] in self?.open(phrase) })
        panel.alphaValue = 0
        bubble = panel
        self.phrase = phrase
        show(panel)
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { $0.duration = 0.25; panel.animator().alphaValue = 1 }
    }

    private func show(_ panel: NSPanel) {
        guard let window, let host = panel.contentView as? BubbleHost else { return }
        let size = host.fittingSize
        let pet = window.frame.minX + physics.origin.x
        let screen = window.frame
        let x = min(max(pet - size.width / 2, screen.minX + 4), screen.maxX - size.width - 4)
        let tail = min(max(pet - x - size.width / 2, -size.width / 2 + 26), size.width / 2 - 26)
        if host.rootView.tail != tail { host.rootView.tail = tail }
        let frame = CGRect(x: x, y: screen.minY + physics.frame.maxY - 4, width: size.width, height: size.height).integral
        if panel.frame != frame { panel.setFrame(frame, display: true) }
    }

    private func hideBubble() {
        guard let panel = bubble else { return }
        bubble = nil
        phrase = nil
        NSAnimationContext.runAnimationGroup { $0.duration = 0.25; panel.animator().alphaValue = 0 } completionHandler: { panel.orderOut(nil) }
    }

    private func open(_ phrase: PetPhrase) {
        if phrase.id == "update" {
            SettingsWindow.show(.about)
        } else if let link = phrase.link {
            NSWorkspace.shared.open(link)
        }
        hideBubble()
    }
}

private final class FigureView<Pose: Equatable>: NSView {
    var pose: Pose { didSet { if pose != oldValue { render() } } }
    var shift: CGFloat = 0 { didSet { if shift != oldValue { render() } } }
    private let paint: (Pose, Bool, (Path, Color) -> Void) -> Void
    private var shapes: [CAShapeLayer] = []
    private let environment = EnvironmentValues()

    private var night: Bool { effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua }

    init(_ pose: Pose, paint: @escaping (Pose, Bool, (Path, Color) -> Void) -> Void) {
        self.pose = pose
        self.paint = paint
        super.init(frame: .zero)
        wantsLayer = true
        layer?.shadowColor = .black
        layer?.shadowOffset = CGSize(width: 0, height: -1)
        layer?.shadowRadius = 1.5
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidChangeEffectiveAppearance() { render() }

    override func viewDidChangeBackingProperties() {
        shapes.forEach { $0.contentsScale = window?.backingScaleFactor ?? 2 }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        render()
    }

    private func render() {
        guard let layer else { return }
        let night = night
        let place = CGAffineTransform(translationX: bounds.midX + shift, y: PetStage.ground).scaledBy(x: PetStage.scale, y: -PetStage.scale)
        var index = 0
        let fill = { (path: Path, color: Color) in
            if index == self.shapes.count {
                let shape = CAShapeLayer()
                shape.contentsScale = self.window?.backingScaleFactor ?? 2
                layer.addSublayer(shape)
                self.shapes.append(shape)
            }
            self.shapes[index].path = path.applying(place).cgPath
            self.shapes[index].fillColor = color.resolve(in: self.environment).cgColor
            index += 1
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.shadowOpacity = night ? 0.5 : 0.22
        paint(pose, night, fill)
        shapes[index...].forEach { $0.path = nil }
        CATransaction.commit()
    }
}

private final class PetHand: NSView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func cursorUpdate(with event: NSEvent) { NSCursor.openHand.set() }
    override func mouseDown(with event: NSEvent) { PetStage.shared.grab(at: event.locationInWindow) }
    override func mouseDragged(with event: NSEvent) { NSCursor.closedHand.set() }
    override func mouseUp(with event: NSEvent) { PetStage.shared.drop() }
}

private final class BubbleHost: NSHostingView<PetBubble> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

private struct PetBubble: View {
    let text: String
    let clickable: Bool
    var tail: CGFloat
    let action: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 13, style: .continuous)
        let paper = Color(nsColor: .windowBackgroundColor)
        VStack(spacing: -0.5) {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(text)
                if clickable {
                    Image(systemName: "arrow.up.forward.circle.fill").foregroundStyle(Color.accentColor)
                }
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 230)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(paper, in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
            BubbleTail()
                .fill(paper)
                .frame(width: 16, height: 8)
                .offset(x: tail)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 7, y: 3)
        .padding(12)
        .contentShape(Rectangle())
        .onTapGesture { if clickable { action() } }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(clickable ? .isButton : [])
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.midX - 1, y: rect.minY + 2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX + 1, y: rect.minY + 2))
            path.closeSubpath()
        }
    }
}
