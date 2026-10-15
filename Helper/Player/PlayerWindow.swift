import AppKit
import AVFoundation
import UniformTypeIdentifiers

final class VideoView: NSView {
    weak var controller: PlayerController?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard event.modifierFlags.intersection([.command, .control, .option]).isEmpty,
              let action = PlayerAction(key: event.charactersIgnoringModifiers ?? ""), controller?.perform(action) == true else { return super.keyDown(with: event) }
    }

    override func cancelOperation(_ sender: Any?) {
        _ = controller?.perform(.leaveFullScreen)
    }

    override func mouseMoved(with event: NSEvent) {
        controller?.showControls()
    }

    override func mouseExited(with event: NSEvent) {
        controller?.hideControls()
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 { _ = controller?.perform(.fullScreen) }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self))
    }

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        Self.video(sender) == nil ? [] : .copy
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        guard let url = Self.video(sender) else { return false }
        controller?.load(url)
        return true
    }

    private static func video(_ sender: any NSDraggingInfo) -> URL? {
        (sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL])?.first(where: PlayerFormats.plays)
    }

    override func isAccessibilityElement() -> Bool { true }
    override func accessibilityRole() -> NSAccessibility.Role? { .group }
    override func accessibilityLabel() -> String? { String(localized: "Video") }
    override func accessibilityValue() -> Any? { controller?.state }
}

final class PlayerController: NSWindowController, NSWindowDelegate, NSMenuItemValidation {
    static let volumeKey = "volume"
    private let video = VideoView()
    private let message = NSTextField(labelWithString: String(localized: "Drop a video here"))
    private let controls = NSVisualEffectView()
    private let playButton = NSButton()
    private let fullScreenButton = NSButton()
    private let elapsed = NSTextField(labelWithString: "0:00")
    private let remaining = NSTextField(labelWithString: "-0:00")
    private let scrubber = NSSlider(value: 0, minValue: 0, maxValue: 1, target: nil, action: nil)
    private let volume = NSSlider(value: 1, minValue: 0, maxValue: 1, target: nil, action: nil)
    private var engine: Engine?
    private var observer: Any?
    private var hideTimer: Timer?
    private var playing = false
    private var failed = false
    var onClose: ((PlayerController) -> Void)?

    var isEmpty: Bool { engine == nil }

    var state: String {
        if failed { return message.stringValue }
        guard let engine else { return message.stringValue }
        let now = PlayerTime.text(PlayerTime.clamp(engine.synchronizer.currentTime().seconds, duration: engine.duration.seconds)), total = PlayerTime.text(engine.duration.seconds)
        return playing ? String(localized: "Playing, \(now) of \(total)") : String(localized: "Paused, \(now) of \(total)")
    }

    init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.collectionBehavior = .fullScreenPrimary
        window.minSize = NSSize(width: 400, height: 200)
        window.backgroundColor = .black
        window.title = "pikapik Player"
        super.init(window: window)
        window.delegate = self
        build(window)
        window.center()
    }

    required init?(coder: NSCoder) { nil }

    private func build(_ window: NSWindow) {
        video.controller = self
        video.wantsLayer = true
        video.layer?.backgroundColor = NSColor.black.cgColor
        video.registerForDraggedTypes([.fileURL])
        window.contentView = video

        message.textColor = .white.withAlphaComponent(0.8)
        message.font = .systemFont(ofSize: 15, weight: .medium)
        message.alignment = .center
        message.lineBreakMode = .byTruncatingTail
        message.setAccessibilityElement(false)

        controls.material = .hudWindow
        controls.blendingMode = .withinWindow
        controls.state = .active
        controls.wantsLayer = true
        controls.layer?.cornerRadius = 12
        controls.layer?.masksToBounds = true

        configure(playButton, "play.fill", String(localized: "Play"), #selector(playPause))
        configure(fullScreenButton, "arrow.up.left.and.arrow.down.right", String(localized: "Full Screen"), #selector(fullScreen))
        for label in [elapsed, remaining] {
            label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
            label.textColor = .secondaryLabelColor
            label.setAccessibilityElement(false)
        }
        scrubber.target = self
        scrubber.action = #selector(scrub)
        scrubber.isContinuous = true
        scrubber.controlSize = .small
        scrubber.refusesFirstResponder = true
        scrubber.setAccessibilityLabel(String(localized: "Position"))
        let speaker = NSImageView(image: NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: nil)!)
        speaker.contentTintColor = .secondaryLabelColor
        volume.target = self
        volume.action = #selector(changeVolume)
        volume.controlSize = .small
        volume.refusesFirstResponder = true
        volume.setAccessibilityLabel(String(localized: "Volume"))
        volume.floatValue = UserDefaults.standard.object(forKey: Self.volumeKey) as? Float ?? 1

        let row = NSStackView(views: [playButton, elapsed, scrubber, remaining, speaker, volume, fullScreenButton])
        row.spacing = 10
        row.edgeInsets = NSEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        row.setCustomSpacing(4, after: speaker)
        controls.addSubview(row)
        for view in [message, controls, row] as [NSView] { view.translatesAutoresizingMaskIntoConstraints = false }
        video.addSubview(message)
        video.addSubview(controls)
        let wide = controls.widthAnchor.constraint(equalToConstant: 560)
        wide.priority = .defaultHigh
        NSLayoutConstraint.activate([
            message.centerXAnchor.constraint(equalTo: video.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: video.centerYAnchor),
            message.widthAnchor.constraint(lessThanOrEqualTo: video.widthAnchor, constant: -40),
            controls.centerXAnchor.constraint(equalTo: video.centerXAnchor),
            controls.bottomAnchor.constraint(equalTo: video.bottomAnchor, constant: -16),
            controls.heightAnchor.constraint(equalToConstant: 44),
            controls.widthAnchor.constraint(lessThanOrEqualTo: video.widthAnchor, constant: -32),
            wide,
            row.leadingAnchor.constraint(equalTo: controls.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: controls.trailingAnchor),
            row.centerYAnchor.constraint(equalTo: controls.centerYAnchor),
            volume.widthAnchor.constraint(equalToConstant: 70),
            scrubber.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
        controls.isHidden = true
    }

    private func configure(_ button: NSButton, _ symbol: String, _ label: String, _ action: Selector) {
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
        button.setAccessibilityLabel(label)
        button.isBordered = false
        button.contentTintColor = .labelColor
        button.refusesFirstResponder = true
        button.target = self
        button.action = action
        button.widthAnchor.constraint(equalToConstant: 22).isActive = true
    }

    func load(_ url: URL) {
        stop()
        window?.title = url.lastPathComponent
        window?.representedURL = url
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        do {
            let engine = try Engine(url)
            self.engine = engine
            failed = false
            message.isHidden = true
            engine.volume = volume.floatValue
            engine.layer.frame = video.bounds
            engine.layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            video.layer?.insertSublayer(engine.layer, at: 0)
            fit(engine.size)
            observer = engine.synchronizer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: .main) { [weak self] _ in self?.tick() }
            playing = true
            engine.seek(to: .zero, rate: 1)
            controls.isHidden = false
            update()
            showControls()
        } catch {
            failed = true
            message.stringValue = String(localized: "Can’t play this file. It may be damaged or in a format the player doesn’t support.")
            message.isHidden = false
            controls.isHidden = true
        }
        NSAccessibility.post(element: video, notification: .valueChanged)
    }

    private func stop() {
        guard let engine else { return }
        if let observer { engine.synchronizer.removeTimeObserver(observer) }
        observer = nil
        engine.stop()
        engine.layer.removeFromSuperlayer()
        self.engine = nil
        playing = false
    }

    private func fit(_ size: CGSize) {
        guard let window, let screen = window.screen ?? NSScreen.main, size.width > 0, size.height > 0 else {
            window?.contentAspectRatio = .zero
            return
        }
        let room = screen.visibleFrame.insetBy(dx: 40, dy: 40).size
        let scale = min(1, room.width / size.width, room.height / size.height)
        let content = NSSize(width: max(400, (size.width * scale).rounded()), height: max(200, (size.height * scale).rounded()))
        window.contentAspectRatio = size
        guard !window.styleMask.contains(.fullScreen) else { return }
        var frame = window.frameRect(forContentRect: NSRect(origin: .zero, size: content))
        frame.origin = NSPoint(x: window.frame.midX - frame.width / 2, y: window.frame.maxY - frame.height)
        window.setFrame(frame, display: true)
        if !screen.visibleFrame.contains(window.frame) { window.center() }
    }

    private func tick() {
        guard let engine else { return }
        if engine.failed, !failed {
            stop()
            failed = true
            message.stringValue = String(localized: "Can’t play this file. It may be damaged or in a format the player doesn’t support.")
            message.isHidden = false
            controls.isHidden = true
            return
        }
        if engine.layer.sampleBufferRenderer.requiresFlushToResumeDecoding {
            engine.seek(to: engine.synchronizer.currentTime(), rate: playing ? 1 : 0)
        }
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished {
            playing = false
            engine.synchronizer.rate = 0
            showControls()
        }
        update()
    }

    private func update() {
        guard let engine else { return }
        let total = engine.duration.seconds, now = PlayerTime.clamp(engine.synchronizer.currentTime().seconds, duration: total)
        elapsed.stringValue = PlayerTime.text(now)
        remaining.stringValue = "-" + PlayerTime.text(total - now)
        scrubber.maxValue = max(total, 0.001)
        scrubber.doubleValue = now
        let label = playing ? String(localized: "Pause") : String(localized: "Play")
        playButton.image = NSImage(systemSymbolName: playing ? "pause.fill" : "play.fill", accessibilityDescription: label)
        playButton.setAccessibilityLabel(label)
        video.setAccessibilityValue(state)
    }

    func perform(_ action: PlayerAction) -> Bool {
        switch action {
        case .playPause: playPause(nil)
        case .back: skip(-PlayerAction.skip)
        case .forward: skip(PlayerAction.skip)
        case .louder: nudgeVolume(PlayerAction.volumeStep)
        case .quieter: nudgeVolume(-PlayerAction.volumeStep)
        case .fullScreen: fullScreen(nil)
        case .leaveFullScreen:
            guard window?.styleMask.contains(.fullScreen) == true else { return false }
            fullScreen(nil)
        }
        return true
    }

    @objc func playPause(_ sender: Any?) {
        guard let engine else { return }
        playing.toggle()
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished {
            engine.seek(to: .zero, rate: 1)
        } else {
            engine.synchronizer.rate = playing ? 1 : 0
        }
        update()
        showControls()
    }

    @objc func skipBack(_ sender: Any?) { skip(-PlayerAction.skip) }
    @objc func skipForward(_ sender: Any?) { skip(PlayerAction.skip) }
    @objc func volumeUp(_ sender: Any?) { nudgeVolume(PlayerAction.volumeStep) }
    @objc func volumeDown(_ sender: Any?) { nudgeVolume(-PlayerAction.volumeStep) }

    @objc private func fullScreen(_ sender: Any?) {
        window?.toggleFullScreen(sender)
    }

    private func skip(_ seconds: Double) {
        guard let engine else { return }
        seek(engine.synchronizer.currentTime().seconds + seconds)
        showControls()
    }

    private func seek(_ seconds: Double) {
        guard let engine else { return }
        let target = PlayerTime.clamp(seconds, duration: engine.duration.seconds)
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished { playing = false }
        engine.seek(to: CMTime(seconds: target, preferredTimescale: 90000), rate: playing ? 1 : 0)
        scrubber.doubleValue = target
        elapsed.stringValue = PlayerTime.text(target)
        remaining.stringValue = "-" + PlayerTime.text(engine.duration.seconds - target)
    }

    private func nudgeVolume(_ step: Float) {
        volume.floatValue = PlayerTime.volume(volume.floatValue, by: step)
        changeVolume(nil)
        showControls()
    }

    @objc private func scrub(_ sender: Any?) {
        seek(scrubber.doubleValue)
        showControls()
    }

    @objc private func changeVolume(_ sender: Any?) {
        engine?.volume = volume.floatValue
        UserDefaults.standard.set(volume.floatValue, forKey: Self.volumeKey)
    }

    func showControls() {
        guard engine != nil else { return }
        controls.animator().alphaValue = 1
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in self?.hideControls() }
    }

    func hideControls() {
        guard playing, let window else { return }
        let pointer = controls.convert(window.mouseLocationOutsideOfEventStream, from: nil)
        guard !controls.bounds.contains(pointer) || !window.isKeyWindow else { return }
        controls.animator().alphaValue = 0
        if window.styleMask.contains(.fullScreen) { NSCursor.setHiddenUntilMouseMoves(true) }
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        if item.action == #selector(playPause) { item.title = playing ? String(localized: "Pause") : String(localized: "Play") }
        return engine != nil
    }

    func windowWillClose(_ notification: Notification) {
        hideTimer?.invalidate()
        stop()
        onClose?(self)
    }
}
