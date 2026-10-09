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
    private var bubble: NSPanel?
    private var link: CADisplayLink?
    private let view = PetView()
    private let grip = PetHand()
    private var raised = false
    private var fake: CGPoint?
    private var anchor = CGPoint.zero
    private var physics = PetPhysics(bounds: CGRect(x: 0, y: ground, width: 600, height: height - ground))
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
        let window = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.hidesOnDeactivate = false
        window.ignoresMouseEvents = true
        window.isReleasedWhenClosed = false
        window.isExcludedFromWindowsMenu = true
        window.animationBehavior = .none
        window.level = Self.level
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.contentView = PetHand()
        window.contentView?.wantsLayer = true
        window.contentView?.addSubview(view)
        window.contentView?.addSubview(grip)
        grip.addTrackingArea(NSTrackingArea(rect: .zero, options: [.cursorUpdate, .activeAlways, .inVisibleRect], owner: grip))
        self.window = window

        let link = view.displayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30)
        link.isPaused = true
        link.add(to: .main, forMode: .common)
        self.link = link

        let workspace = NSWorkspace.shared.notificationCenter, local = NotificationCenter.default, distributed = DistributedNotificationCenter.default()
        watch(local, NSApplication.didChangeScreenParametersNotification) { $0.layout() }
        watch(local, NSWindow.didChangeOcclusionStateNotification, window) { _ in }
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

        locked = (CGSessionCopyCurrentDictionary() as? [String: Any])?["CGSSessionScreenIsLocked"] as? Bool ?? false
        layout()
        let width = physics.bounds.width, roof = physics.roof
        physics = PetPhysics(bounds: physics.bounds, x: width * (demo == nil ? .random(in: 0.1...0.9) : 0.12), facing: demo == nil && Bool.random() ? -1 : 1)
        physics.roof = roof
        physics.calm = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        checkFullscreen()
    }

    func stop() {
        raised = false
        link?.invalidate()
        link = nil
        recheck?.invalidate()
        recheck = nil
        observers.forEach { $0.0.removeObserver($0.1) }
        observers = []
        hideBubble()
        bubble = nil
        window?.orderOut(nil)
        window = nil
        last = nil
    }

    func jump() {
        guard window?.isVisible == true else { return }
        physics.jump()
    }

    fileprivate func grab(at point: CGPoint) {
        guard physics.grab(at: point) else { return }
        NSCursor.closedHand.set()
        rise()
        place()
    }

    fileprivate func drop() {
        guard physics.state == .held else { return }
        physics.release()
        NSCursor.arrow.set()
    }

    private static var level: NSWindow.Level {
        NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
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
        guard let window, let screen = NSScreen.screens.first else { return }
        let frame = raised ? screen.frame : CGRect(x: screen.frame.minX, y: screen.frame.minY, width: screen.frame.width, height: Self.height)
        window.level = raised ? .statusBar : Self.level
        window.setFrame(frame, display: false)
        view.frame = CGRect(x: view.frame.minX, y: 0, width: Self.width, height: Self.height)
        let top = max(Self.height, screen.visibleFrame.maxY - screen.frame.minY)
        physics.resize(CGRect(x: 0, y: Self.ground, width: frame.width, height: top - Self.ground))
        let dock = screen.visibleFrame.minY - screen.frame.minY
        physics.roof = dock > Self.ground + PetPhysics.size.height ? dock : .infinity
        place()
        if let bubble { show(bubble) }
    }

    private func update() {
        guard let window, let link else { return }
        let hidden = asleep || locked || fullscreen || GameModeTool.shared.isPlaying
        if hidden {
            window.orderOut(nil)
            hideBubble()
        } else if !window.isVisible {
            window.orderFrontRegardless()
        }
        let waiting = (fullscreen || GameModeTool.shared.isPlaying) && !asleep && !locked
        if waiting != (recheck != nil) {
            recheck?.invalidate()
            recheck = waiting ? Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.checkFullscreen() } : nil
        }
        let paused = hidden || !window.occlusionState.contains(.visible)
        if paused {
            drop()
            window.ignoresMouseEvents = true
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
        physics.step(dt, cursor: point)
        if physics.state == .held, fake == nil, NSEvent.pressedMouseButtons & 1 == 0 { drop() }
        rise()
        place()
        let catchable = point.map(physics.touches) ?? false
        if let window, window.ignoresMouseEvents == (catchable || physics.state == .held) { window.ignoresMouseEvents.toggle() }
        if phrase != nil, physics.state != .sit { hideBubble() }
        talk(ProcessInfo.processInfo.systemUptime)
    }

    private var cursor: CGPoint? {
        guard let screen = NSScreen.screens.first else { return nil }
        let point = NSEvent.mouseLocation
        guard physics.state == .held || screen.frame.contains(point) else { return nil }
        return CGPoint(x: point.x - screen.frame.minX, y: point.y - screen.frame.minY)
    }

    private func place() {
        let scale = window?.backingScaleFactor ?? 2
        let left = physics.origin.x - Self.width / 2
        let x = (left * scale).rounded(.down) / scale
        if view.frame.minX != x { view.setFrameOrigin(CGPoint(x: x, y: 0)) }
        view.shift = left - x
        view.pose = PetPose(physics, scale: Self.scale, time: ProcessInfo.processInfo.systemUptime)
        if grip.frame != physics.frame { grip.frame = physics.frame }
    }

    private func rise() {
        guard physics.aloft != raised else { return }
        raised = physics.aloft
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

private final class PetView: NSView {
    var pose = PetPose() { didSet { if pose != oldValue { render() } } }
    var shift: CGFloat = 0 { didSet { if shift != oldValue { render() } } }
    private var shapes: [CAShapeLayer] = []
    private let environment = EnvironmentValues()

    private var night: Bool { effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua }

    override init(frame: NSRect) {
        super.init(frame: frame)
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
        PetFigure.shadow(pose, fill: fill)
        PetFigure.draw(pose, night: night, fill: fill)
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
