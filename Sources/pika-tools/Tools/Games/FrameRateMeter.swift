import AppKit
import os
import ScreenCaptureKit
import SwiftUI

@Observable
final class FrameRateModel {
    var shown = FrameRateShown.measuring
    var wide = false
}

struct FramePill: View {
    let shown: FrameRateShown
    var wide = false
    var scale: CGFloat = 1

    private var number: String {
        switch shown {
        case .measuring: "—"
        case .paused: "0"
        case .live(let fps): String(fps)
        }
    }

    private var isLive: Bool {
        if case .live = shown { true } else { false }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4 * scale) {
            ZStack(alignment: isLive ? .trailing : .center) {
                Text(verbatim: wide ? "000" : "00").hidden()
                Text(verbatim: number).foregroundStyle(.white.opacity(isLive ? 1 : 0.5))
            }
            .font(.system(size: 15 * scale, weight: .semibold).monospacedDigit())
            Text(verbatim: "FPS")
                .font(.system(size: 9 * scale, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 10 * scale)
        .padding(.vertical, 5 * scale)
        .background(.black.opacity(0.55), in: Capsule())
        .overlay(Capsule().hairline(Color.white.opacity(0.22)))
        .fixedSize()
    }
}

private struct LivePill: View {
    let model: FrameRateModel

    var body: some View {
        FramePill(shown: model.shown, wide: model.wide)
    }
}

final class FrameRateMeter: NSObject {
    static let shared = FrameRateMeter()

    static var hasTrace: Bool {
        #if APPSTORE
        false
        #else
        PerfTrace.exists
        #endif
    }

    private static let narrow = fitting(wide: false)
    private static let wide = fitting(wide: true)

    private static func fitting(wide: Bool) -> CGSize {
        NSHostingView(rootView: FramePill(shown: .measuring, wide: wide)).fittingSize
    }

    private let model = FrameRateModel()
    private lazy var panel = makePanel()
    private var game: pid_t?
    private var corner = FrameRateCorner.standard
    private var session = 0
    private var source = FrameRateSource(traceCanRun: false, at: 0)
    private var ticker: Timer?
    private var follower: CADisplayLink?
    private var gameWindow: CGWindowID?
    private var followed = CGRect.null
    private var movedAt = 0.0
    private var calm = false
    private var capture: ScreenFrames?
    #if !APPSTORE
    private var trace: PerfTrace?
    #endif

    private override init() {}

    private var now: Double { ProcessInfo.processInfo.systemUptime }
    private var pillSize: CGSize { model.wide ? Self.wide : Self.narrow }

    func show(_ pid: pid_t, corner: FrameRateCorner) {
        self.corner = corner
        if game != pid { begin(pid) }
        place(locate())
    }

    func hide() {
        guard game != nil else { return }
        end()
        fade(to: 0) { [weak self] in
            if self?.game == nil { self?.panel.orderOut(nil) }
        }
    }

    private func begin(_ pid: pid_t) {
        end()
        game = pid
        session += 1
        model.shown = .measuring
        model.wide = false
        var tracing = false
        #if !APPSTORE
        let current = session
        trace = PerfTrace(pid: pid) { [weak self] fps in self?.traced(fps, in: current) }
        tracing = trace != nil
        #endif
        source = FrameRateSource(traceCanRun: tracing, at: now)
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
        place(locate())
        if !panel.isVisible { panel.alphaValue = 0 }
        panel.orderFrontRegardless()
        follower = panel.displayLink(target: self, selector: #selector(follow))
        follower?.add(to: .main, forMode: .common)
        fade(to: 1)
    }

    private func end() {
        ticker?.invalidate()
        ticker = nil
        follower?.invalidate()
        follower = nil
        gameWindow = nil
        followed = .null
        calm = false
        capture?.stop()
        capture = nil
        #if !APPSTORE
        trace?.stop()
        trace = nil
        #endif
        game = nil
    }

    private func traced(_ fps: Double, in session: Int) {
        guard session == self.session, game != nil else { return }
        source.traced(at: now)
        capture?.stop()
        capture = nil
        present(FrameRateShown(fps))
    }

    private func present(_ shown: FrameRateShown) {
        model.shown = shown
        guard !model.wide, case .live(let fps) = shown, fps >= 100 else { return }
        model.wide = true
        place(locate())
    }

    private func tick() {
        let spot = locate()
        place(spot)
        let time = now
        if source.traceStalled(at: time) { model.shown = .paused }
        if capture == nil, source.wantsCapture(at: time) {
            if source.startsCapture(at: time, allowed: CGPreflightScreenCaptureAccess) {
                capture = ScreenFrames(display: spot?.display ?? CGMainDisplayID())
            } else if Self.hasTrace, !GameModeTool.shared.needsRecording {
                GameModeTool.shared.needsRecording = true
            }
        }
        if let current = capture, let display = spot?.display, display != current.display {
            current.stop()
            capture = ScreenFrames(display: display)
        }
        if let capture {
            capture.follow(spot?.window)
            present(capture.takeRate(at: time).map(FrameRateShown.init) ?? .measuring)
        }
    }

    // Checks the game window on every frame of the screen, so the pill moves together with it.
    // After half a second without movement it checks 30 times a second.
    @objc private func follow(_ link: CADisplayLink) {
        if let gameWindow, let frame = Self.frame(of: gameWindow), frame != followed {
            followed = frame
            movedAt = link.timestamp
            place(spot(frame))
            capture?.follow(frame)
        }
        let calm = link.timestamp - movedAt > 0.5
        guard calm != self.calm else { return }
        self.calm = calm
        link.preferredFrameRateRange = calm ? CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30) : .default
    }

    private static func frame(of window: CGWindowID) -> CGRect? {
        guard let info = (CGWindowListCopyWindowInfo(.optionIncludingWindow, window) as? [[String: Any]])?.first,
              info[kCGWindowIsOnscreen as String] as? Bool == true,
              let bounds = info[kCGWindowBounds as String] as? NSDictionary
        else { return nil }
        return CGRect(dictionaryRepresentation: bounds)
    }

    private func locate() -> (window: CGRect, display: CGDirectDisplayID)? {
        let found = game.flatMap(GameModeTool.window(of:))
        gameWindow = found?.id
        return found.flatMap { spot($0.frame) }
    }

    private func spot(_ window: CGRect) -> (window: CGRect, display: CGDirectDisplayID)? {
        GameModeTool.display(of: window).map { (window, $0) }
    }

    private func place(_ spot: (window: CGRect, display: CGDirectDisplayID)?) {
        let area: CGRect
        var belowTitleBar = false
        if let spot {
            area = FramePillPlace.cocoa(spot.window, primaryHeight: NSScreen.screens.first?.frame.height ?? 0)
            let screen = NSScreen.screens.first { $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID == spot.display }
            belowTitleBar = !FramePillPlace.isFullscreen(window: spot.window, display: CGDisplayBounds(spot.display), top: screen?.safeAreaInsets.top ?? 0)
        } else {
            area = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame ?? .zero
        }
        let frame = FramePillPlace.frame(of: pillSize, corner: corner, in: area, belowTitleBar: belowTitleBar)
        if frame != panel.frame { panel.setFrame(frame, display: false) }
    }

    private func fade(to alpha: CGFloat, then done: @escaping () -> Void = {}) {
        let duration = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.2
        guard duration > 0 else {
            panel.alphaValue = alpha
            return done()
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            panel.animator().alphaValue = alpha
        }, completionHandler: done)
    }

    private func makePanel() -> NSPanel {
        let view = NSHostingView(rootView: LivePill(model: model))
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: pillSize), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.contentView = view
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        return panel
    }
}

#if !APPSTORE
final class PerfTrace {
    static let path = "/usr/bin/metalperftrace"
    static var exists: Bool { FileManager.default.isExecutableFile(atPath: path) }

    private let process = Process()
    private let lifeline = Pipe()
    private let output: FileHandle

    init?(pid: pid_t, rate: @escaping (Double) -> Void) {
        var primary: Int32 = 0
        var secondary: Int32 = 0
        guard Self.exists, openpty(&primary, &secondary, nil, nil, nil) == 0 else { return nil }
        output = FileHandle(fileDescriptor: primary, closeOnDealloc: true)
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "\(Self.path) listen --json --pid \"$1\" --interval 1 & c=$!; read x; kill $c", "sh", String(pid)]
        process.standardInput = lifeline
        process.standardOutput = FileHandle(fileDescriptor: secondary, closeOnDealloc: false)
        process.standardError = FileHandle.nullDevice
        var reader = PerfTraceReader()
        output.readabilityHandler = { handle in
            var buffer = [UInt8](repeating: 0, count: 4096)
            let count = read(handle.fileDescriptor, &buffer, buffer.count)
            guard count > 0 else {
                handle.readabilityHandler = nil
                return
            }
            for fps in reader.feed(buffer.prefix(count)) { DispatchQueue.main.async { rate(fps) } }
        }
        do {
            try process.run()
        } catch {
            output.readabilityHandler = nil
            close(secondary)
            return nil
        }
        close(secondary)
    }

    func stop() {
        output.readabilityHandler = nil
        try? lifeline.fileHandleForWriting.close()
    }
}
#endif

final class ScreenFrames: NSObject, SCStreamOutput, SCStreamDelegate {
    let display: CGDirectDisplayID

    private struct Count {
        var window = CGRect.null
        var output = CGSize.zero
        var since: Double?
        var frames = 0
    }

    private let bounds: CGRect
    private let count = OSAllocatedUnfairLock(initialState: Count())
    private let queue = DispatchQueue(label: "pikapik.frame-rate", qos: .utility)
    private var task: Task<Void, Never>?
    private var stream: SCStream?

    init(display: CGDirectDisplayID) {
        self.display = display
        bounds = CGDisplayBounds(display)
        super.init()
        task = Task { @MainActor in await open() }
    }

    func follow(_ window: CGRect?) {
        count.withLock { $0.window = window ?? .null }
    }

    func takeRate(at now: Double) -> Double? {
        count.withLock { state in
            guard let since = state.since, now > since else { return nil }
            defer { state.since = now; state.frames = 0 }
            return Double(state.frames) / (now - since)
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        guard let stream else { return }
        self.stream = nil
        Task { try? await stream.stopCapture() }
    }

    @MainActor
    private func open() async {
        guard let content = try? await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true),
              !Task.isCancelled,
              let screen = content.displays.first(where: { $0.displayID == display })
        else { return }
        let config = SCStreamConfiguration()
        config.width = max(screen.width / 8, 1)
        config.height = max(screen.height / 8, 1)
        config.minimumFrameInterval = .zero
        config.queueDepth = 6
        config.showsCursor = false
        count.withLock { $0.output = CGSize(width: config.width, height: config.height) }
        let stream = SCStream(filter: SCContentFilter(display: screen, excludingWindows: []), configuration: config, delegate: self)
        do {
            try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)
            try await stream.startCapture()
        } catch {
            return
        }
        guard !Task.isCancelled else {
            try? await stream.stopCapture()
            return
        }
        self.stream = stream
        count.withLock { $0.since = ProcessInfo.processInfo.systemUptime }
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer buffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen,
              let info = (CMSampleBufferGetSampleAttachmentsArray(buffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]])?.first,
              info[.status] as? Int == SCFrameStatus.complete.rawValue
        else { return }
        let dirty = (info[.dirtyRects] as? [CFDictionary] ?? []).compactMap { CGRect(dictionaryRepresentation: $0) }
        count.withLock { state in
            let target = FrameCoverage.target(window: state.window, display: bounds, output: state.output)
            if FrameCoverage.presents(dirty: dirty, target: target) { state.frames += 1 }
        }
    }

    func stream(_ stream: SCStream, didStopWithError error: Error) {
        count.withLock { $0.since = nil }
    }
}
