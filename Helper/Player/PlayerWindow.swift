import AppKit
import AVFoundation
import MediaPlayer
import UniformTypeIdentifiers

final class VideoView: NSView {
    weak var controller: PlayerController?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        controller?.showControls()
        guard let action = PlayerAction(key: event.charactersIgnoringModifiers ?? "", modifiers: event.modifierFlags), controller?.perform(action) == true else { return super.keyDown(with: event) }
    }

    override func scrollWheel(with event: NSEvent) {
        controller?.scroll(event)
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
        Self.playable(sender) == nil ? [] : .copy
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        guard let url = Self.playable(sender) else { return false }
        controller?.load(url)
        return true
    }

    private static func playable(_ sender: any NSDraggingInfo) -> URL? {
        (sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL])?.first { PlayerFormats.plays($0) || FolderAccess.isFolder($0) }
    }

    override func isAccessibilityElement() -> Bool { true }
    override func accessibilityRole() -> NSAccessibility.Role? { .group }
    override func accessibilityLabel() -> String? { controller?.isMusic == true ? String(localized: "Music") : String(localized: "Video") }
    override func accessibilityValue() -> Any? { controller?.state }
}

final class Scrubber: NSSlider {
    var onHover: ((Double?) -> Void)?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self))
    }

    override func mouseMoved(with event: NSEvent) {
        let knob = Double((cell as? NSSliderCell)?.knobThickness ?? 0), width = Double(bounds.width)
        let x = Double(convert(event.locationInWindow, from: nil).x)
        onHover?(max(0, min(1, (x - knob / 2) / max(width - knob, 1))))
    }

    override func mouseExited(with event: NSEvent) {
        onHover?(nil)
    }
}

final class PlayerController: NSWindowController, NSWindowDelegate, NSMenuItemValidation {
    static let volumeKey = "volume"
    private static let resumeStore = "resume"
    private static let minimum = NSSize(width: 480, height: 200)
    private static let musicSize = NSSize(width: 560, height: 600)
    private let video = VideoView()
    private let music = MusicView()
    private let message = NSTextField(labelWithString: String(localized: "Drop a video or a song here"))
    private let controls: NSView = {
        if #available(macOS 26.0, *) {
            let glass = NSGlassEffectView()
            glass.style = .regular
            glass.tintColor = NSColor.black.withAlphaComponent(0.5)
            glass.cornerRadius = 12
            return glass
        }
        let blur = NSVisualEffectView()
        blur.material = .hudWindow
        blur.blendingMode = .withinWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true
        return blur
    }()
    private let preview = ThumbnailPreview()
    private let playButton = NSButton()
    private let previousButton = NSButton()
    private let nextButton = NSButton()
    private let fullScreenButton = NSButton()
    private let pipButton = NSButton()
    private let speaker = NSImageView()
    private let speedLabel = NSTextField(labelWithString: "")
    private let elapsed = NSTextField(labelWithString: "0:00")
    private let remaining = NSTextField(labelWithString: "-0:00")
    private let scrubber = Scrubber(value: 0, minValue: 0, maxValue: 1, target: nil, action: nil)
    private let marks = TimeMarks()
    private let volume = NSSlider(value: 1, minValue: 0, maxValue: 1, target: nil, action: nil)
    private var engine: Engine?
    private var observer: Any?
    private var hideTimer: Timer?
    private var thumbnails: Thumbnails?
    private var pip: PictureInPicture?
    private var hiddenForPip = false
    private var chapters: [Chapter] = []
    private var loop = PlayerLoop()
    private var hovered: Double?
    private var cursorHidden = false
    private var playing = false
    private var failed = false
    private var isLast = false
    private var declined = Set<String>()
    private var track: [String: Any] = [:]
    private var published: (Bool, Float)?
    private var speed: Float = 1
    private var muted = false
    private var wheel = PlayerWheel()
    private var resumeKey: String?
    private var lastSaved = Date.distantPast
    var onClose: ((PlayerController) -> Void)?

    static var output: String?

    var isEmpty: Bool { engine == nil }

    func setOutput(_ uid: String?) {
        guard let engine, let target = uid ?? (engine.output == nil ? nil : PlayerOutput.system()), target != engine.output else { return }
        engine.route(to: target)
    }

    var isMusic: Bool { engine.map { !$0.hasVideo } ?? false }

    var state: String {
        if failed { return message.stringValue }
        guard let engine else { return message.stringValue }
        let now = PlayerTime.text(PlayerTime.clamp(engine.synchronizer.currentTime().seconds, duration: engine.duration.seconds)), total = PlayerTime.text(engine.duration.seconds)
        return playing ? String(localized: "Playing, \(now) of \(total)") : String(localized: "Paused, \(now) of \(total)")
    }

    init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.collectionBehavior = .fullScreenPrimary
        window.minSize = Self.minimum
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

        controls.appearance = NSAppearance(named: .darkAqua)

        configure(playButton, "play.fill", String(localized: "Play"), #selector(playPause))
        configure(previousButton, "backward.fill", String(localized: "Previous in Folder"), #selector(previous))
        configure(nextButton, "forward.fill", String(localized: "Next in Folder"), #selector(next))
        configure(fullScreenButton, "arrow.up.left.and.arrow.down.right", String(localized: "Full Screen"), #selector(fullScreen))
        configure(pipButton, "pip.enter", String(localized: "Picture in Picture"), #selector(togglePictureInPicture))
        pipButton.isHidden = true
        for label in [elapsed, remaining, speedLabel] {
            label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
            label.textColor = .labelColor
            label.setAccessibilityElement(false)
        }
        scrubber.target = self
        scrubber.action = #selector(scrub)
        scrubber.isContinuous = true
        scrubber.controlSize = .small
        scrubber.refusesFirstResponder = true
        scrubber.setAccessibilityLabel(String(localized: "Position"))
        scrubber.onHover = { [weak self] in self?.hover($0) }
        marks.translatesAutoresizingMaskIntoConstraints = false
        scrubber.addSubview(marks)
        speaker.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: nil)
        speaker.contentTintColor = .labelColor
        speedLabel.isHidden = true
        volume.target = self
        volume.action = #selector(changeVolume)
        volume.controlSize = .small
        volume.refusesFirstResponder = true
        volume.setAccessibilityLabel(String(localized: "Volume"))
        volume.floatValue = UserDefaults.standard.object(forKey: Self.volumeKey) as? Float ?? 1

        let row = NSStackView(views: [previousButton, playButton, nextButton, elapsed, scrubber, remaining, speedLabel, speaker, volume, pipButton, fullScreenButton])
        row.spacing = 10
        row.edgeInsets = NSEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        row.setCustomSpacing(4, after: speaker)
        for view in [music, message, controls, row] as [NSView] { view.translatesAutoresizingMaskIntoConstraints = false }
        video.addSubview(music)
        video.addSubview(message)
        video.addSubview(controls)
        video.addSubview(preview)
        preview.isHidden = true
        let wide = controls.widthAnchor.constraint(equalToConstant: 560)
        wide.priority = .defaultHigh
        music.isHidden = true
        NSLayoutConstraint.activate([
            music.leadingAnchor.constraint(equalTo: video.leadingAnchor),
            music.trailingAnchor.constraint(equalTo: video.trailingAnchor),
            music.topAnchor.constraint(equalTo: video.topAnchor),
            music.bottomAnchor.constraint(equalTo: video.bottomAnchor),
            message.centerXAnchor.constraint(equalTo: video.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: video.centerYAnchor),
            message.widthAnchor.constraint(lessThanOrEqualTo: video.widthAnchor, constant: -40),
            controls.centerXAnchor.constraint(equalTo: video.centerXAnchor),
            controls.bottomAnchor.constraint(equalTo: video.bottomAnchor, constant: -16),
            controls.heightAnchor.constraint(equalToConstant: 44),
            controls.widthAnchor.constraint(lessThanOrEqualTo: video.widthAnchor, constant: -32),
            wide,
            volume.widthAnchor.constraint(equalToConstant: 70),
            scrubber.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            marks.leadingAnchor.constraint(equalTo: scrubber.leadingAnchor),
            marks.trailingAnchor.constraint(equalTo: scrubber.trailingAnchor),
            marks.topAnchor.constraint(equalTo: scrubber.topAnchor),
            marks.bottomAnchor.constraint(equalTo: scrubber.bottomAnchor),
        ])
        if #available(macOS 26.0, *), let glass = controls as? NSGlassEffectView {
            glass.contentView = row
        } else {
            controls.addSubview(row)
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: controls.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: controls.trailingAnchor),
                row.centerYAnchor.constraint(equalTo: controls.centerYAnchor),
            ])
        }
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

    func load(_ url: URL, advancing: Bool = false) {
        guard !FolderAccess.isFolder(url) else { return openFolder(url) }
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
            engine.muted = muted
            if let output = Self.output { engine.route(to: output) }
            engine.layer.frame = video.bounds
            engine.layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            video.layer?.insertSublayer(engine.layer, at: 0)
            let tags = engine.tags(), cover = tags.cover.flatMap(NSImage.init(data:))
            if engine.hasVideo {
                fit(engine.size)
            } else {
                fitMusic()
            }
            if !engine.hasVideo { music.show(title: PlayerTags.title(tags.title, file: url), subtitle: PlayerTags.subtitle(artist: tags.artist, album: tags.album), cover: cover) }
            music.isHidden = engine.hasVideo
            track = Self.trackInfo(tags, cover: cover, file: url, hasVideo: engine.hasVideo, duration: engine.duration.seconds)
            isLast = FolderAccess.files(in: url.deletingLastPathComponent()).map { PlaylistOrder.neighbour(of: url, kind: PlayerFormats.kind(of: url) ?? .video, among: $0, step: 1) == nil } ?? false
            observer = engine.synchronizer.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: .main) { [weak self] _ in self?.tick() }
            playing = true
            chapters = engine.chapters
            refreshMarks()
            setUpPictureInPicture(engine)
            if engine.hasVideo, engine.duration.seconds > 0 {
                let thumbnails = Thumbnails(url: url, size: engine.size, duration: engine.duration.seconds)
                thumbnails.onReady = { [weak self] _ in self?.hover(self?.hovered) }
                self.thumbnails = thumbnails
            }
            resumeKey = Self.resumeKey(url)
            engine.seek(to: CMTime(seconds: resumePosition(engine.duration.seconds), preferredTimescale: 90000), rate: speed)
            controls.isHidden = false
            update()
            showControls()
        } catch {
            fail(String(localized: "Can’t play this file. It may be damaged or in a format the player doesn’t support."))
            if advancing { go(1, explicit: false, advancing: true) }
        }
        NSAccessibility.post(element: video, notification: .valueChanged)
    }

    private func openFolder(_ folder: URL) {
        FolderAccess.remember(folder)
        guard let first = FolderAccess.files(in: folder).flatMap(PlaylistOrder.first(among:)) else {
            stop()
            window?.title = folder.lastPathComponent
            window?.representedURL = nil
            fail(String(localized: "There is nothing to play in this folder."))
            return
        }
        load(first)
    }

    private func fail(_ text: String) {
        failed = true
        message.stringValue = text
        message.isHidden = false
        music.isHidden = true
        controls.isHidden = true
    }

    private static func trackInfo(_ tags: MediaTags, cover: NSImage?, file: URL, hasVideo: Bool, duration: Double) -> [String: Any] {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: PlayerTags.title(tags.title, file: file),
            MPNowPlayingInfoPropertyMediaType: (hasVideo ? MPNowPlayingInfoMediaType.video : .audio).rawValue,
            MPMediaItemPropertyPlaybackDuration: duration,
        ]
        if let artist = PlayerTags.clean(tags.artist) { info[MPMediaItemPropertyArtist] = artist }
        if let album = PlayerTags.clean(tags.album) { info[MPMediaItemPropertyAlbumTitle] = album }
        if let cover { info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: cover.size) { _ in cover } }
        return info
    }

    private func stop() {
        guard let engine else { return }
        remember()
        thumbnails?.close()
        thumbnails = nil
        preview.isHidden = true
        chapters = []
        loop = PlayerLoop()
        refreshMarks()
        pip?.close()
        pip = nil
        returnFromPictureInPicture()
        refreshPictureInPicture()
        resumeKey = nil
        if let observer { engine.synchronizer.removeTimeObserver(observer) }
        observer = nil
        engine.stop()
        engine.layer.removeFromSuperlayer()
        self.engine = nil
        playing = false
        published = nil
        track = [:]
        NowPlaying.shared.clear(self)
    }

    private func fit(_ size: CGSize) {
        guard let window, let screen = window.screen ?? NSScreen.main, size.width > 0, size.height > 0 else {
            window?.contentAspectRatio = .zero
            return
        }
        let room = screen.visibleFrame.insetBy(dx: 40, dy: 40).size
        let scale = min(1, room.width / size.width, room.height / size.height)
        window.contentAspectRatio = size
        place(NSSize(width: max(Self.minimum.width, (size.width * scale).rounded()), height: max(Self.minimum.height, (size.height * scale).rounded())))
    }

    private func fitMusic() {
        window?.contentAspectRatio = .zero
        if !music.isHidden { return }
        place(Self.musicSize)
    }

    private func place(_ content: NSSize) {
        guard let window, !window.styleMask.contains(.fullScreen) else { return }
        var frame = window.frameRect(forContentRect: NSRect(origin: .zero, size: content))
        frame.origin = NSPoint(x: window.frame.midX - frame.width / 2, y: window.frame.maxY - frame.height)
        window.setFrame(frame, display: true)
        if let screen = window.screen ?? NSScreen.main, !screen.visibleFrame.contains(window.frame) { window.center() }
    }

    private func tick() {
        guard let engine else { return }
        if engine.failed, !failed {
            stop()
            fail(String(localized: "Can’t play this file. It may be damaged or in a format the player doesn’t support."))
            return
        }
        if engine.layer.sampleBufferRenderer.requiresFlushToResumeDecoding {
            engine.seek(to: engine.synchronizer.currentTime(), rate: rate)
        }
        let ended = engine.finished.map { engine.synchronizer.currentTime() >= $0 } ?? false
        if playing, let start = loop.wrap(at: ended ? .infinity : engine.position.seconds) {
            engine.seek(to: CMTime(seconds: start, preferredTimescale: 90000), rate: rate)
            update()
            return
        }
        if playing, Date().timeIntervalSince(lastSaved) >= 10 { remember() }
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished {
            playing = false
            engine.synchronizer.rate = 0
            showControls()
            if !engine.hasVideo, !isLast { go(1, explicit: false, advancing: true) }
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
        pip?.refresh()
        speedLabel.isHidden = speed == 1
        speedLabel.stringValue = "\(speed.formatted())×"
        speedLabel.setAccessibilityLabel(String(localized: "Speed"))
        nextButton.isEnabled = !isLast
        video.setAccessibilityValue(state)
        if published?.0 != playing || published?.1 != speed { publishNowPlaying() }
    }

    private func publishNowPlaying() {
        guard let engine else { return }
        published = (playing, speed)
        var info = track
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = PlayerTime.clamp(engine.position.seconds, duration: engine.duration.seconds)
        info[MPNowPlayingInfoPropertyPlaybackRate] = Double(rate)
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = Double(speed)
        NowPlaying.shared.publish(info, playing: playing, for: self)
    }

    private var rate: Float { playing ? speed : 0 }

    private var stepsByFrame: Bool { !playing && engine?.hasVideo == true }

    func perform(_ action: PlayerAction) -> Bool {
        switch action.resolved(playing: !stepsByFrame) {
        case .playPause: playPause(nil)
        case .skipBack: skip(-PlayerAction.skip)
        case .skipForward: skip(PlayerAction.skip)
        case .longBack: skip(-PlayerAction.longSkip)
        case .longForward: skip(PlayerAction.longSkip)
        case .frameBack: step(-1)
        case .frameForward: step(1)
        case .start: seek(0)
        case .end: seek(engine?.duration.seconds ?? 0)
        case .startOver: startOver()
        case .slower: setSpeed(PlayerSpeed.stepped(speed, -1))
        case .faster: setSpeed(PlayerSpeed.stepped(speed, 1))
        case .normalSpeed: setSpeed(1)
        case .louder: nudgeVolume(PlayerAction.volumeStep)
        case .quieter: nudgeVolume(-PlayerAction.volumeStep)
        case .mute: setMuted(!muted)
        case .fullScreen: fullScreen(nil)
        case .leaveFullScreen:
            guard window?.styleMask.contains(.fullScreen) == true else { return false }
            fullScreen(nil)
        case .snapshot: saveFrame()
        case .next: go(1, explicit: true)
        case .previous: previous(nil)
        case .floatOnTop: window?.level = window?.level == .floating ? .normal : .floating
        case .nextChapter: jumpChapter(1)
        case .previousChapter: jumpChapter(-1)
        case .loop: markLoop()
        case .pictureInPicture: togglePictureInPicture(nil)
        case .back, .forward: break
        }
        return true
    }

    @objc func menuAction(_ sender: NSMenuItem) {
        showControls()
        if let action = sender.representedObject as? PlayerAction { _ = perform(action) }
    }

    @objc func chooseSpeed(_ sender: NSMenuItem) {
        setSpeed(sender.representedObject as? Float ?? 1)
    }

    @objc func chooseChapter(_ sender: NSMenuItem) {
        guard chapters.indices.contains(sender.tag) else { return }
        seek(chapters[sender.tag].start)
        showControls()
    }

    @objc func moveToScreen(_ sender: NSMenuItem) {
        guard let window, let screen = sender.representedObject as? NSScreen else { return }
        let area = screen.visibleFrame
        let scale = min(1, area.width / window.frame.width, area.height / window.frame.height)
        let size = NSSize(width: (window.frame.width * scale).rounded(), height: (window.frame.height * scale).rounded())
        window.setFrame(NSRect(x: area.midX - size.width / 2, y: area.midY - size.height / 2, width: size.width, height: size.height), display: true, animate: true)
    }

    @objc func playPause(_ sender: Any?) {
        guard let engine else { return }
        playing.toggle()
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished {
            engine.seek(to: .zero, rate: speed)
        } else {
            engine.synchronizer.rate = rate
        }
        if !playing { remember() }
        update()
        showControls()
    }

    func setPlaying(_ value: Bool) {
        if playing != value { playPause(nil) }
    }

    @objc private func next(_ sender: Any?) {
        showControls()
        go(1, explicit: true)
    }

    @objc private func previous(_ sender: Any?) {
        showControls()
        if let engine, engine.position.seconds > 3 {
            seek(0)
        } else {
            go(-1, explicit: true)
        }
    }

    private func go(_ step: Int, explicit: Bool, advancing: Bool = false) {
        guard let url = window?.representedURL, let window else { return }
        let folder = url.deletingLastPathComponent()
        guard let files = FolderAccess.files(in: folder) else {
            guard explicit || !declined.contains(folder.path) else { return }
            declined.remove(folder.path)
            FolderAccess.ask(folder, in: window) { [weak self] granted in
                guard let self else { return }
                if granted { self.go(step, explicit: explicit, advancing: advancing) } else { self.declined.insert(folder.path) }
            }
            return
        }
        if let neighbour = PlaylistOrder.neighbour(of: url, kind: PlayerFormats.kind(of: url) ?? .video, among: files, step: step) {
            load(neighbour, advancing: advancing)
        } else if step > 0 {
            isLast = true
            update()
        }
    }

    @objc private func fullScreen(_ sender: Any?) {
        window?.toggleFullScreen(sender)
    }

    private func skip(_ seconds: Double) {
        guard let engine else { return }
        seek(engine.position.seconds + seconds)
        showControls()
    }

    func seek(_ seconds: Double) {
        guard let engine else { return }
        let target = PlayerTime.clamp(seconds, duration: engine.duration.seconds)
        if playing, let finished = engine.finished, engine.synchronizer.currentTime() >= finished { playing = false }
        engine.seek(to: CMTime(seconds: target, preferredTimescale: 90000), rate: rate)
        scrubber.doubleValue = target
        elapsed.stringValue = PlayerTime.text(target)
        remaining.stringValue = "-" + PlayerTime.text(engine.duration.seconds - target)
        publishNowPlaying()
    }

    private func step(_ direction: Int) {
        guard let engine else { return }
        if playing {
            playing = false
            engine.synchronizer.rate = 0
        }
        engine.step(direction)
        update()
        showControls()
    }

    private func setUpPictureInPicture(_ engine: Engine) {
        guard engine.hasVideo else { return }
        pip = PictureInPicture(layer: engine.layer, host: PictureInPicture.Host(
            duration: { [weak self] in self?.engine?.duration ?? .zero },
            isPlaying: { [weak self] in self?.playing ?? false },
            setPlaying: { [weak self] in if self?.playing != $0 { self?.playPause(nil) } },
            skip: { [weak self] in self?.skip($0) },
            changed: { [weak self] in self?.refreshPictureInPicture() },
            started: { [weak self] in self?.hideForPictureInPicture() },
            stopped: { [weak self] in self?.returnFromPictureInPicture() }
        ))
        refreshPictureInPicture()
    }

    private func refreshPictureInPicture() {
        pipButton.isHidden = pip?.isPossible != true
        let label = pip?.isActive == true ? String(localized: "Exit Picture in Picture") : String(localized: "Picture in Picture")
        pipButton.image = NSImage(systemSymbolName: pip?.isActive == true ? "pip.exit" : "pip.enter", accessibilityDescription: label)
        pipButton.setAccessibilityLabel(label)
    }

    private func hideForPictureInPicture() {
        guard let window, !window.styleMask.contains(.fullScreen), window.isVisible else { return }
        hiddenForPip = true
        window.orderOut(nil)
    }

    private func returnFromPictureInPicture() {
        guard hiddenForPip else { return }
        hiddenForPip = false
        window?.makeKeyAndOrderFront(nil)
    }

    @objc private func togglePictureInPicture(_ sender: Any?) {
        pip?.toggle()
    }

    private func jumpChapter(_ direction: Int) {
        guard let engine, !chapters.isEmpty else { return }
        let starts = chapters.map(\.start), now = engine.position.seconds
        guard let target = direction > 0 ? PlayerChapters.next(starts, after: now) : PlayerChapters.previous(starts, before: now) else { return }
        seek(target)
        showControls()
    }

    private func markLoop() {
        guard let engine else { return }
        loop.press(at: engine.position.seconds)
        refreshMarks()
        showControls()
    }

    private func refreshMarks() {
        let total = engine?.duration.seconds ?? 0
        marks.chapters = PlayerChapters.fractions(chapters.map(\.start), duration: total)
        marks.loop = [loop.start, loop.end].compactMap { $0 }.map { total > 0 ? $0 / total : 0 }
    }

    var chapterNames: [String] {
        chapters.enumerated().map { $0.element.title.isEmpty ? String(localized: "Chapter \($0.offset + 1)") : $0.element.title }
    }

    private var currentChapter: Int? {
        engine.flatMap { PlayerChapters.current(chapters.map(\.start), at: $0.position.seconds) }
    }

    private func startOver() {
        guard engine != nil else { return }
        playing = true
        seek(0)
        remember()
        update()
    }

    private func setSpeed(_ value: Float) {
        speed = value
        if playing { engine?.synchronizer.rate = value }
        update()
        showControls()
    }

    private func setMuted(_ value: Bool) {
        muted = value
        engine?.muted = value
        speaker.image = NSImage(systemSymbolName: value ? "speaker.slash.fill" : "speaker.wave.2.fill", accessibilityDescription: nil)
        showControls()
    }

    private func nudgeVolume(_ step: Float) {
        volume.floatValue = PlayerTime.volume(volume.floatValue, by: step)
        changeVolume(nil)
        showControls()
    }

    func scroll(_ event: NSEvent) {
        guard engine != nil, event.momentumPhase.isEmpty else { return }
        let inverted = event.isDirectionInvertedFromDevice
        var (right, up) = (event.scrollingDeltaX * (inverted ? 1 : -1), event.scrollingDeltaY * (inverted ? -1 : 1))
        if event.modifierFlags.contains(.shift), right == 0 { (right, up) = (up, 0) }
        let change = wheel.add(right: right, up: up, precise: event.hasPreciseScrollingDeltas, began: event.phase == .began || event.phase == .mayBegin, at: event.timestamp)
        if change.volume != 0 {
            volume.floatValue = max(0, min(1, volume.floatValue + change.volume))
            changeVolume(nil)
            showControls()
        }
        if change.seconds != 0 { skip(change.seconds) }
    }

    private func saveFrame() {
        guard let engine, let window else { return }
        let resume = playing
        playing = false
        engine.synchronizer.rate = 0
        update()
        let finish = { [weak self] in
            guard let self, resume, self.engine === engine else { return }
            self.playing = true
            engine.synchronizer.rate = self.speed
            self.update()
        }
        guard let image = engine.frameImage() else {
            frameFailed(finish)
            return
        }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = PlayerTime.snapshotName(window.representedURL?.lastPathComponent ?? "pikapik Player", at: engine.position.seconds)
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return finish() }
            let saved = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil).map { destination in
                CGImageDestinationAddImage(destination, image, nil)
                return CGImageDestinationFinalize(destination)
            } ?? false
            if saved { finish() } else { self?.frameFailed(finish) }
        }
    }

    private func frameFailed(_ finish: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = String(localized: "Couldn’t save the frame.")
        guard let window else { return finish() }
        alert.beginSheetModal(for: window) { _ in finish() }
    }

    private static func resumeKey(_ url: URL) -> String? {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]), let size = values.fileSize, let modified = values.contentModificationDate else { return nil }
        return PlayerResume.key(path: url.standardizedFileURL.path, size: Int64(size), modified: modified)
    }

    private func resumePosition(_ duration: Double) -> Double {
        guard let resumeKey, let saved = (UserDefaults.standard.dictionary(forKey: Self.resumeStore) as? [String: [Double]])?[resumeKey]?.first,
              PlayerResume.worthKeeping(saved, of: duration) else { return 0 }
        return saved
    }

    func remember() {
        lastSaved = Date()
        guard let engine, let resumeKey, engine.position.seconds.isFinite, engine.duration.seconds.isFinite else { return }
        let saved = UserDefaults.standard.dictionary(forKey: Self.resumeStore) as? [String: [Double]] ?? [:]
        UserDefaults.standard.set(PlayerResume.updated(saved, key: resumeKey, position: engine.position.seconds, duration: engine.duration.seconds, at: Date().timeIntervalSince1970), forKey: Self.resumeStore)
    }

    @objc private func scrub(_ sender: Any?) {
        hover(nil)
        seek(scrubber.doubleValue)
        showControls()
    }

    @objc private func changeVolume(_ sender: Any?) {
        if muted { setMuted(false) }
        engine?.volume = volume.floatValue
        UserDefaults.standard.set(volume.floatValue, forKey: Self.volumeKey)
    }

    func showControls() {
        guard engine != nil else { return }
        refreshControls(idle: 0)
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: PlayerChrome.hideDelay, repeats: false) { [weak self] _ in self?.refreshControls(idle: PlayerChrome.hideDelay) }
    }

    func hideControls() {
        refreshControls(idle: .infinity)
    }

    private func refreshControls(idle: Double) {
        guard let window else { return }
        let pointer = controls.convert(window.mouseLocationOutsideOfEventStream, from: nil)
        let fullScreen = window.styleMask.contains(.fullScreen)
        let visible = PlayerChrome.visibility(playing: playing, overControls: window.isKeyWindow && controls.bounds.contains(pointer), fullScreen: fullScreen, idle: idle, hides: engine?.hasVideo ?? true)
        controls.animator().alphaValue = visible.controls ? 1 : 0
        if !visible.controls { hover(nil) }
        if visible.cursor == cursorHidden {
            cursorHidden = !visible.cursor
            NSCursor.setHiddenUntilMouseMoves(cursorHidden)
        }
    }

    func hover(_ fraction: Double?) {
        hovered = fraction
        guard let engine, let fraction else {
            preview.isHidden = true
            return
        }
        let total = engine.duration.seconds, seconds = fraction * total
        let chapter = PlayerChapters.current(chapters.map(\.start), at: seconds).map { chapterNames[$0] }
        preview.show(time: PlayerTime.text(seconds), image: thumbnails?.image(for: PlayerThumbnail.bucket(seconds, duration: total)), chapter: chapter)
        preview.setFrameSize(preview.fittingSize)
        let point = video.convert(NSPoint(x: scrubber.bounds.minX + CGFloat(fraction) * scrubber.bounds.width, y: 0), from: scrubber)
        preview.setFrameOrigin(NSPoint(x: max(8, min(video.bounds.width - preview.frame.width - 8, point.x - preview.frame.width / 2)), y: controls.frame.maxY + 8))
        preview.isHidden = false
        showControls()
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        switch item.action {
        case #selector(chooseSpeed):
            item.state = item.representedObject as? Float == speed ? .on : .off
            return true
        case #selector(chooseChapter):
            item.state = item.tag == currentChapter ? .on : .off
            return true
        case #selector(moveToScreen):
            item.state = item.representedObject as? NSScreen == window?.screen ? .on : .off
            return window?.styleMask.contains(.fullScreen) == false
        case #selector(menuAction):
            guard let action = item.representedObject as? PlayerAction else { return false }
            switch action {
            case .playPause: item.title = playing ? String(localized: "Pause") : String(localized: "Play")
            case .back: item.title = stepsByFrame ? String(localized: "Previous Frame") : String(localized: "Back 5 Seconds")
            case .forward: item.title = stepsByFrame ? String(localized: "Next Frame") : String(localized: "Forward 5 Seconds")
            case .mute: item.title = muted ? String(localized: "Unmute") : String(localized: "Mute")
            case .floatOnTop:
                item.state = window?.level == .floating ? .on : .off
                return true
            case .snapshot: return engine?.hasVideo == true
            case .next: return window?.representedURL != nil && !isLast
            case .previous: return window?.representedURL != nil
            case .nextChapter, .previousChapter: return !chapters.isEmpty
            case .pictureInPicture:
                item.title = pip?.isActive == true ? String(localized: "Exit Picture in Picture") : String(localized: "Picture in Picture")
                return pip?.isPossible == true
            case .loop: item.title = loop.isSet ? String(localized: "Clear Loop") : loop.start == nil ? String(localized: "Set Loop Start") : String(localized: "Set Loop End")
            default: break
            }
            return engine != nil
        default:
            return engine != nil
        }
    }

    func windowWillClose(_ notification: Notification) {
        hideTimer?.invalidate()
        hiddenForPip = false
        stop()
        scrubber.onHover = nil
        onClose?(self)
    }
}
