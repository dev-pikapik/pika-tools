import AppKit
import os

final class ImageCanvas: NSView {
    weak var controller: ImageController?
    let picture = CALayer()
    private var grabbing = false

    override var acceptsFirstResponder: Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        picture.contentsGravity = .resize
        picture.minificationFilter = .trilinear
        layer?.addSublayer(picture)
        registerForDraggedTypes([.fileURL])
        setAccessibilityRole(.image)
    }

    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        controller?.canvasResized()
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard let action = ImageAction(key: event.charactersIgnoringModifiers ?? "", modifiers: event.modifierFlags), controller?.perform(action) == true else { return super.performKeyEquivalent(with: event) }
        controller?.showControls()
        return true
    }

    override func cancelOperation(_ sender: Any?) {
        _ = controller?.perform(.leaveFullScreen)
    }

    override func magnify(with event: NSEvent) {
        controller?.zoom(by: max(0.1, 1 + event.magnification), at: anchor(of: event))
    }

    override func scrollWheel(with event: NSEvent) {
        let (dx, dy) = (event.scrollingDeltaX, event.scrollingDeltaY)
        if event.modifierFlags.contains(.command) {
            controller?.zoom(by: exp(dy * (event.hasPreciseScrollingDeltas ? 0.01 : 0.1)), at: anchor(of: event))
        } else {
            controller?.pan(by: CGSize(width: dx, height: -dy))
        }
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            controller?.toggleActual(at: anchor(of: event))
        } else if controller?.canPan == true {
            grabbing = true
            NSCursor.closedHand.push()
        } else {
            window?.performDrag(with: event)
        }
    }

    override func mouseDragged(with event: NSEvent) {
        controller?.pan(by: CGSize(width: event.deltaX, height: -event.deltaY))
    }

    override func mouseUp(with event: NSEvent) {
        if grabbing {
            grabbing = false
            NSCursor.pop()
        }
    }

    override func mouseMoved(with event: NSEvent) {
        controller?.showControls()
    }

    override func mouseExited(with event: NSEvent) {
        controller?.hideControls()
    }

    override func resetCursorRects() {
        if controller?.canPan == true { addCursorRect(bounds, cursor: .openHand) }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self))
    }

    override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
        Self.files(sender).isEmpty ? [] : .copy
    }

    override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
        let urls = Self.files(sender)
        guard !urls.isEmpty else { return false }
        controller?.onOpen?(urls)
        return true
    }

    private static func files(_ sender: any NSDraggingInfo) -> [URL] {
        (sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL]) ?? []
    }

    private func anchor(of event: NSEvent) -> CGPoint {
        let point = convert(event.locationInWindow, from: nil)
        return CGPoint(x: point.x - bounds.midX, y: point.y - bounds.midY)
    }
}

enum ImagePanel {
    static func make() -> NSView {
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
    }

    static func fill(_ panel: NSView, with row: NSView) {
        if #available(macOS 26.0, *), let glass = panel as? NSGlassEffectView {
            glass.contentView = row
            return
        }
        panel.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            row.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
        ])
    }
}

final class ImageController: NSWindowController, NSWindowDelegate, NSMenuItemValidation {
    private static let background = NSColor(white: 0.11, alpha: 1)
    private let canvas = ImageCanvas()
    private let message = NSTextField(labelWithString: "")
    private let caption = NSTextField(labelWithString: "")
    private let loading = NSProgressIndicator()
    private let controls = ImagePanel.make()
    private let previousButton = NSButton()
    private let nextButton = NSButton()
    private let rotateButton = NSButton()
    private let zoomOutButton = NSButton()
    private let zoomInButton = NSButton()
    private let zoomButton = NSButton()
    private let slideshowButton = NSButton()
    private let fullScreenButton = NSButton()
    private let queue = DispatchQueue(label: "pikapik.image-decoder", qos: .userInitiated)
    private let latest = OSAllocatedUnfairLock(initialState: 0)
    private var generation = 0
    private var shown = -1
    private var index = 0
    private var probe: ImageProbe?
    private var viewport = ImageViewport()
    private var requested = 0
    private var contentsLongSide = 1
    private var sized = false
    private var animation: ImageAnimation?
    private var slideshow: Timer?
    private var hideTimer: Timer?
    private var detailTimer: Timer?
    private var loadingTimer: Timer?
    private var cursorHidden = false
    private(set) var urls: [URL] = []
    var onOpen: (([URL]) -> Void)?
    var onClose: ((ImageController) -> Void)?

    var canPan: Bool {
        guard let probe else { return false }
        return viewport.canPan(probe.size, in: canvas.bounds.size)
    }

    init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.collectionBehavior = .fullScreenPrimary
        window.minSize = NSSize(width: 400, height: 200)
        window.backgroundColor = Self.background
        super.init(window: window)
        window.delegate = self
        build(window)
        window.center()
        NotificationCenter.default.addObserver(self, selector: #selector(occlusionChanged), name: NSWindow.didChangeOcclusionStateNotification, object: window)
    }

    required init?(coder: NSCoder) { nil }

    private func build(_ window: NSWindow) {
        canvas.controller = self
        canvas.wantsLayer = true
        canvas.layer?.backgroundColor = Self.background.cgColor
        window.contentView = canvas
        window.makeFirstResponder(canvas)

        message.textColor = .white.withAlphaComponent(0.8)
        message.font = .systemFont(ofSize: 15, weight: .medium)
        message.alignment = .center
        message.lineBreakMode = .byTruncatingTail
        message.isHidden = true
        message.setAccessibilityElement(false)
        caption.textColor = .white.withAlphaComponent(0.8)
        caption.font = .systemFont(ofSize: 13, weight: .medium)
        caption.alignment = .center
        caption.lineBreakMode = .byTruncatingMiddle
        caption.setAccessibilityElement(false)
        loading.style = .spinning
        loading.controlSize = .regular
        loading.isDisplayedWhenStopped = false
        loading.appearance = NSAppearance(named: .darkAqua)
        controls.appearance = NSAppearance(named: .darkAqua)

        configure(previousButton, "chevron.left", String(localized: "Previous Image"), #selector(previous))
        configure(nextButton, "chevron.right", String(localized: "Next Image"), #selector(next))
        configure(rotateButton, "rotate.left", String(localized: "Rotate Left"), #selector(rotateLeft))
        configure(zoomOutButton, "minus.magnifyingglass", String(localized: "Zoom Out"), #selector(zoomOut))
        configure(zoomInButton, "plus.magnifyingglass", String(localized: "Zoom In"), #selector(zoomIn))
        configure(slideshowButton, "play.square.stack", String(localized: "Start Slideshow"), #selector(toggleSlideshow))
        configure(fullScreenButton, "arrow.up.left.and.arrow.down.right", String(localized: "Full Screen"), #selector(fullScreen))
        zoomButton.isBordered = false
        zoomButton.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        zoomButton.contentTintColor = .labelColor
        zoomButton.refusesFirstResponder = true
        zoomButton.target = self
        zoomButton.action = #selector(toggleActualFromButton)
        zoomButton.setAccessibilityLabel(String(localized: "Zoom"))
        zoomButton.widthAnchor.constraint(equalToConstant: 48).isActive = true

        let row = NSStackView(views: [previousButton, nextButton, rotateButton, zoomOutButton, zoomButton, zoomInButton, slideshowButton, fullScreenButton])
        row.spacing = 10
        row.distribution = .equalSpacing
        row.edgeInsets = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        for view in [message, caption, loading, controls, row] as [NSView] { view.translatesAutoresizingMaskIntoConstraints = false }
        canvas.addSubview(message)
        canvas.addSubview(caption)
        canvas.addSubview(loading)
        canvas.addSubview(controls)
        NSLayoutConstraint.activate([
            message.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: canvas.centerYAnchor),
            message.widthAnchor.constraint(lessThanOrEqualTo: canvas.widthAnchor, constant: -40),
            caption.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            caption.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 6),
            caption.widthAnchor.constraint(lessThanOrEqualTo: canvas.widthAnchor, constant: -180),
            loading.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: canvas.centerYAnchor),
            controls.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            controls.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -16),
            controls.heightAnchor.constraint(equalToConstant: 44),
            controls.widthAnchor.constraint(equalToConstant: 360),
            controls.widthAnchor.constraint(lessThanOrEqualTo: canvas.widthAnchor, constant: -32),
        ])
        ImagePanel.fill(controls, with: row)
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

    func show(_ urls: [URL], at start: Int = 0) {
        self.urls = urls
        stopSlideshow()
        open(start)
    }

    func focus(_ url: URL) -> Bool {
        guard let found = urls.firstIndex(where: { $0.standardizedFileURL == url.standardizedFileURL }) else { return false }
        window?.deminiaturize(nil)
        showWindow(nil)
        if found != index { open(found) }
        return true
    }

    private func open(_ newIndex: Int) {
        guard urls.indices.contains(newIndex) else { return }
        index = newIndex
        invalidate()
        let (generation, url) = (generation, urls[newIndex])
        animation = nil
        window?.title = url.lastPathComponent
        window?.subtitle = urls.count > 1 ? ImageList.position(newIndex, of: urls.count) : ""
        caption.stringValue = urls.count > 1 ? "\(url.lastPathComponent) — \(ImageList.position(newIndex, of: urls.count))" : url.lastPathComponent
        window?.representedURL = url
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        controls.isHidden = false
        updateButtons()
        showControls()
        loadingTimer?.invalidate()
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in self?.loading.startAnimation(nil) }
        queue.async { [weak self] in
            guard let self, self.latest.withLock({ $0 }) == generation else { return }
            let probe = ImageDecoder.probe(url)
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == self.generation else { return }
                self.begin(probe, url, generation)
            }
        }
    }

    private func invalidate() {
        generation += 1
        let current = generation
        latest.withLock { $0 = current }
    }

    private func begin(_ probe: ImageProbe?, _ url: URL, _ generation: Int) {
        guard let probe else { return fail() }
        let fresh = ImageViewport()
        if !sized {
            sized = true
            size(window: probe.size)
        }
        if probe.animated, let started = ImageAnimation(url, onFrame: { [weak self] frame in
            guard let self, generation == self.generation else { return }
            if self.shown != generation { self.present(frame, probe, level: 0, fresh) } else { self.set(frame) }
        }) {
            animation = started
            return
        }
        let wanted = detail(of: probe, fresh)
        queue.async { [weak self] in
            guard let self, self.latest.withLock({ $0 }) == generation else { return }
            let image = ImageDecoder.decode(url, probe, maxPixel: wanted)
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == self.generation else { return }
                if let image { self.present(image, probe, level: wanted, fresh) } else { self.fail() }
            }
        }
    }

    private func present(_ image: CGImage, _ probe: ImageProbe, level: Int, _ fresh: ImageViewport) {
        shown = generation
        self.probe = probe
        viewport = fresh
        requested = level
        message.isHidden = true
        loadingTimer?.invalidate()
        loading.stopAnimation(nil)
        set(image)
        canvas.setAccessibilityLabel(urls[index].lastPathComponent)
        changed()
    }

    private func fail() {
        shown = generation
        probe = nil
        loadingTimer?.invalidate()
        loading.stopAnimation(nil)
        set(nil)
        message.stringValue = String(localized: "Can’t open this image. It may be damaged or in a format macOS doesn’t support.")
        message.isHidden = false
        zoomButton.title = ""
        canvas.window?.invalidateCursorRects(for: canvas)
    }

    private func set(_ image: CGImage?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        canvas.picture.contents = image
        canvas.picture.isHidden = image == nil
        CATransaction.commit()
        contentsLongSide = max(1, image.map { max($0.width, $0.height) } ?? 1)
        if image != nil { render() }
    }

    private func size(window size: CGSize) {
        guard let window, !window.styleMask.contains(.fullScreen), let screen = window.screen ?? NSScreen.main, size.width > 0, size.height > 0 else { return }
        let room = screen.visibleFrame.insetBy(dx: 40, dy: 40).size
        let scale = min(1, room.width / size.width, room.height / size.height)
        let content = NSSize(width: max(window.minSize.width, (size.width * scale).rounded()), height: max(window.minSize.height, (size.height * scale).rounded()))
        var frame = window.frameRect(forContentRect: NSRect(origin: .zero, size: content))
        frame.origin = NSPoint(x: window.frame.midX - frame.width / 2, y: window.frame.maxY - frame.height)
        window.setFrame(frame, display: true)
        if !screen.visibleFrame.contains(window.frame) { window.center() }
    }

    private var screenPixels: Int {
        Int(NSScreen.screens.map { max($0.frame.width, $0.frame.height) * $0.backingScaleFactor }.max() ?? 3456)
    }

    private func detail(of probe: ImageProbe, _ viewport: ImageViewport) -> Int {
        let scale = viewport.layout(probe.size, in: canvas.bounds.size).scale
        return ImageDetail.pixels(longSide: max(probe.size.width, probe.size.height) * scale, backing: window?.backingScaleFactor ?? 2, screen: screenPixels, full: probe.longSide, vector: probe.vector)
    }

    func canvasResized() {
        render()
        scheduleDetail()
    }

    private func render(animated: Bool = false) {
        guard let probe else { return }
        let bounds = canvas.bounds, layout = viewport.layout(probe.size, in: bounds.size)
        let backing = window?.backingScaleFactor ?? 2
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(0.2)
        let picture = canvas.picture
        picture.bounds = CGRect(origin: .zero, size: probe.size)
        picture.position = CGPoint(x: bounds.midX + layout.offset.width, y: bounds.midY + layout.offset.height)
        picture.setAffineTransform(CGAffineTransform(rotationAngle: -CGFloat(viewport.turns) * .pi / 2).scaledBy(x: layout.scale, y: layout.scale))
        picture.magnificationFilter = max(probe.size.width, probe.size.height) * layout.scale * backing / CGFloat(contentsLongSide) >= 3 ? .nearest : .linear
        CATransaction.commit()
    }

    private func changed(animated: Bool = false) {
        render(animated: animated)
        guard let probe else { return }
        zoomButton.title = ImageViewport.percent(viewport.layout(probe.size, in: canvas.bounds.size).scale)
        canvas.setAccessibilityValue(urls.count > 1 ? ImageList.position(index, of: urls.count) : nil)
        canvas.window?.invalidateCursorRects(for: canvas)
        scheduleDetail()
    }

    private func scheduleDetail() {
        detailTimer?.invalidate()
        detailTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [weak self] _ in self?.refreshDetail() }
    }

    private func refreshDetail() {
        guard let probe, animation == nil, shown == generation else { return }
        let wanted = detail(of: probe, viewport)
        guard wanted != requested else { return }
        requested = wanted
        let (generation, url) = (generation, urls[index])
        queue.async { [weak self] in
            guard let self, self.latest.withLock({ $0 }) == generation else { return }
            let image = ImageDecoder.decode(url, probe, maxPixel: wanted)
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == self.generation, self.requested == wanted, let image else { return }
                self.set(image)
            }
        }
    }

    @objc private func occlusionChanged(_ notification: Notification) {
        guard let window, let probe, probe.animated else { return }
        if window.occlusionState.contains(.visible) {
            if animation == nil { open(index) }
        } else {
            animation = nil
            invalidate()
            shown = -1
        }
    }

    func perform(_ action: ImageAction) -> Bool {
        switch action {
        case .previous: go(-1)
        case .next: go(1)
        case .slideshow: toggleSlideshow()
        case .zoomIn: zoom(by: ImageViewport.step, at: .zero)
        case .zoomOut: zoom(by: 1 / ImageViewport.step, at: .zero)
        case .fit:
            viewport.fitToWindow()
            changed()
        case .actualSize:
            guard let probe else { return true }
            viewport.set(1, image: probe.size, in: canvas.bounds.size)
            changed()
        case .rotateLeft: rotate(-1)
        case .rotateRight: rotate(1)
        case .leaveFullScreen:
            if slideshow != nil {
                stopSlideshow()
                return true
            }
            guard window?.styleMask.contains(.fullScreen) == true else { return false }
            fullScreen(nil)
        }
        return true
    }

    func zoom(by factor: CGFloat, at anchor: CGPoint) {
        guard let probe else { return }
        viewport.zoom(by: factor, around: anchor, image: probe.size, in: canvas.bounds.size)
        changed()
    }

    func pan(by delta: CGSize) {
        guard let probe, canPan else { return }
        viewport.pan(by: delta, image: probe.size, in: canvas.bounds.size)
        render()
    }

    func toggleActual(at anchor: CGPoint) {
        guard let probe else { return }
        viewport.toggleActual(around: anchor, image: probe.size, in: canvas.bounds.size)
        changed()
    }

    private func rotate(_ direction: Int) {
        guard probe != nil else { return }
        viewport.rotate(direction)
        changed(animated: true)
    }

    private func go(_ direction: Int, wrap: Bool = false) {
        guard let next = ImageList.step(index, by: direction, count: urls.count, wrap: wrap) else { return }
        open(next)
        if slideshow != nil { startSlideshow() }
    }

    @objc private func toggleSlideshow() {
        if slideshow != nil { stopSlideshow() } else if urls.count > 1 { startSlideshow() }
    }

    private func startSlideshow() {
        slideshow?.invalidate()
        slideshow = Timer.scheduledTimer(withTimeInterval: ImageSlideshow.interval, repeats: true) { [weak self] _ in self?.go(1, wrap: true) }
        updateButtons()
    }

    private func stopSlideshow() {
        slideshow?.invalidate()
        slideshow = nil
        updateButtons()
    }

    private func updateButtons() {
        let many = urls.count > 1
        previousButton.isHidden = !many
        nextButton.isHidden = !many
        slideshowButton.isHidden = !many
        previousButton.isEnabled = ImageList.step(index, by: -1, count: urls.count, wrap: false) != nil
        nextButton.isEnabled = ImageList.step(index, by: 1, count: urls.count, wrap: false) != nil
        let label = slideshow == nil ? String(localized: "Start Slideshow") : String(localized: "Stop Slideshow")
        slideshowButton.image = NSImage(systemSymbolName: slideshow == nil ? "play.square.stack" : "pause.fill", accessibilityDescription: label)
        slideshowButton.setAccessibilityLabel(label)
    }

    @objc private func previous(_ sender: Any?) { go(-1) }
    @objc private func next(_ sender: Any?) { go(1) }
    @objc private func rotateLeft(_ sender: Any?) { rotate(-1) }
    @objc private func zoomOut(_ sender: Any?) { zoom(by: 1 / ImageViewport.step, at: .zero) }
    @objc private func zoomIn(_ sender: Any?) { zoom(by: ImageViewport.step, at: .zero) }
    @objc private func toggleActualFromButton(_ sender: Any?) { toggleActual(at: .zero) }

    @objc private func fullScreen(_ sender: Any?) {
        window?.toggleFullScreen(sender)
    }

    @objc func imageAction(_ sender: NSMenuItem) {
        showControls()
        if let action = sender.representedObject as? ImageAction { _ = perform(action) }
    }

    func showControls() {
        guard !controls.isHidden || probe != nil || urls.count > 0 else { return }
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
        let overBar = window.mouseLocationOutsideOfEventStream.y > canvas.bounds.height - 28
        let visible = PlayerChrome.visibility(playing: true, overControls: window.isKeyWindow && (controls.bounds.contains(pointer) || overBar), fullScreen: fullScreen, idle: idle)
        let alpha: CGFloat = visible.controls ? 1 : 0
        controls.animator().alphaValue = alpha
        caption.animator().alphaValue = alpha
        window.standardWindowButton(.closeButton)?.superview?.animator().alphaValue = alpha
        if visible.cursor == cursorHidden {
            cursorHidden = !visible.cursor
            NSCursor.setHiddenUntilMouseMoves(cursorHidden)
        }
    }

    func validateMenuItem(_ item: NSMenuItem) -> Bool {
        guard item.action == #selector(imageAction), let action = item.representedObject as? ImageAction else { return false }
        switch action {
        case .previous: return ImageList.step(index, by: -1, count: urls.count, wrap: false) != nil
        case .next: return ImageList.step(index, by: 1, count: urls.count, wrap: false) != nil
        case .slideshow:
            item.title = slideshow == nil ? String(localized: "Start Slideshow") : String(localized: "Stop Slideshow")
            return urls.count > 1
        case .zoomIn, .zoomOut, .fit, .actualSize, .rotateLeft, .rotateRight: return probe != nil
        case .leaveFullScreen: return false
        }
    }

    func windowWillClose(_ notification: Notification) {
        invalidate()
        [hideTimer, detailTimer, loadingTimer, slideshow].forEach { $0?.invalidate() }
        animation = nil
        canvas.picture.contents = nil
        canvas.controller = nil
        onClose?(self)
    }
}
