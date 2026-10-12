import AppKit
import os
import ScreenCaptureKit
import SwiftUI

@Observable
final class FrameRateModel {
    var shown = FrameRateShown.measuring
}

struct FramePill: View {
    let shown: FrameRateShown
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
        HStack(spacing: 4 * scale) {
            ZStack(alignment: .trailing) {
                Text(verbatim: "000").hidden()
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
        FramePill(shown: model.shown)
    }
}

final class FrameRateMeter {
    static let shared = FrameRateMeter()

    static var hasTrace: Bool {
        #if APPSTORE
        false
        #else
        PerfTrace.exists
        #endif
    }

    private let model = FrameRateModel()
    private lazy var panel = makePanel()
    private var game: pid_t?
    private var corner = FrameRateCorner.standard
    private var session = 0
    private var source = FrameRateSource(traceCanRun: false, at: 0)
    private var ticker: Timer?
    private var capture: ScreenFrames?
    #if !APPSTORE
    private var trace: PerfTrace?
    #endif

    private init() {}

    private var now: Double { ProcessInfo.processInfo.systemUptime }

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
        fade(to: 1)
    }

    private func end() {
        ticker?.invalidate()
        ticker = nil
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
        model.shown = FrameRateShown(fps)
    }

    private func tick() {
        let spot = locate()
        place(spot)
        let time = now
        if source.traceStalled(at: time) { model.shown = .paused }
        if capture == nil, source.startsCapture(at: time, allowed: CGPreflightScreenCaptureAccess) {
            capture = ScreenFrames(display: spot?.display ?? CGMainDisplayID())
        }
        if let current = capture, let display = spot?.display, display != current.display {
            current.stop()
            capture = ScreenFrames(display: display)
        }
        if let capture {
            capture.follow(spot?.window)
            model.shown = capture.takeRate(at: time).map(FrameRateShown.init) ?? .measuring
        }
    }

    private func locate() -> (window: CGRect, display: CGDirectDisplayID)? {
        guard let game, let window = GameModeTool.window(of: game),
              let display = GameModeTool.display(at: CGPoint(x: window.midX, y: window.midY))
        else { return nil }
        return (window, display)
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
        let frame = FramePillPlace.frame(of: panel.frame.size, corner: corner, in: area, belowTitleBar: belowTitleBar)
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
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: view.fittingSize), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
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
