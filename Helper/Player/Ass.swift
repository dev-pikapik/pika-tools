import AppKit

final class AssFrame: Equatable {
    let image: CGImage
    let rect: CGRect
    let canvas: CGSize

    init(image: CGImage, rect: CGRect, canvas: CGSize) {
        self.image = image
        self.rect = rect
        self.canvas = canvas
    }

    static func == (left: AssFrame, right: AssFrame) -> Bool { left === right }
}

struct AssCanvas: Equatable {
    var size: CGSize
    var video: CGSize
    var scale: Double
}

/// One libass library and renderer for the open file. libass is not thread-safe, so every call goes through `lock`;
/// drawing happens on `queue`, never on the main thread, and a script that takes long to draw only delays its own subtitles.
final class AssEngine {
    static let fontLimit = 96 << 20
    static let fontFileLimit = 32 << 20
    static let activeLimit = 400
    static let imageLimit = 4000

    private struct Request {
        let track: AssTrack
        let time: Double
        let canvas: AssCanvas
        let done: (AssFrame?) -> Void
    }

    fileprivate let library: OpaquePointer
    private let renderer: OpaquePointer
    fileprivate let lock = NSLock()
    fileprivate let queue = DispatchQueue(label: "pikapik.ass", qos: .userInitiated)
    private let gate = NSLock()
    private var request: Request?
    private var busy = false
    private var forgotten = false
    private(set) var fontBytes = 0
    private var ready = false
    private var applied: AssCanvas?
    private weak var lastTrack: AssTrack?
    private var last: AssFrame?

    init?() {
        guard let library = ass_library_init() else { return nil }
        ass_set_message_cb(library, { _, _, _, _ in }, nil)
        guard let renderer = ass_renderer_init(library) else {
            ass_library_done(library)
            return nil
        }
        self.library = library
        self.renderer = renderer
        ass_set_cache_limits(renderer, 0, 64)
        ass_set_hinting(renderer, ASS_HINTING_NONE)
        ass_set_use_margins(renderer, 0)
    }

    deinit {
        ass_renderer_done(renderer)
        ass_library_done(library)
    }

    func addFont(name: String, data: Data) {
        lock.withLock {
            guard !ready, data.count <= Self.fontFileLimit, fontBytes + data.count <= Self.fontLimit else { return }
            fontBytes += data.count
            data.withUnsafeBytes { raw in
                ass_add_font(library, name, raw.baseAddress?.assumingMemoryBound(to: CChar.self), Int32(data.count))
            }
        }
    }

    /// Embedded fonts first, then the system ones through CoreText; nothing is downloaded.
    func finishFonts() {
        lock.withLock {
            guard !ready else { return }
            ass_set_fonts(renderer, nil, "Helvetica", Int32(ASS_FONTPROVIDER_AUTODETECT.rawValue), nil, 0)
            ready = true
        }
    }

    /// Nothing is waiting to be drawn and nothing is being drawn.
    var isIdle: Bool { gate.withLock { !busy } }

    /// The next draw reports its picture even when libass sees no change, for when the view was cleared.
    func forget() { gate.withLock { forgotten = true } }

    /// Calls `done` on the main queue when the picture differs from the previous one; only the newest request is drawn.
    func render(_ track: AssTrack, at time: Double, canvas: AssCanvas, done: @escaping (AssFrame?) -> Void) {
        let idle = gate.withLock { () -> Bool in
            request = Request(track: track, time: time, canvas: canvas, done: done)
            defer { busy = true }
            return !busy
        }
        if idle { queue.async { self.drain() } }
    }

    private func drain() {
        while let job = gate.withLock({ () -> Request? in
            let job = request
            request = nil
            busy = job != nil
            return job
        }) {
            if case .changed(let frame) = draw(job) { DispatchQueue.main.async { job.done(frame) } }
        }
    }

    private enum Outcome {
        case same
        case changed(AssFrame?)
    }

    private func draw(_ job: Request) -> Outcome {
        lock.lock()
        defer { lock.unlock() }
        if gate.withLock({ defer { forgotten = false }; return forgotten }) {
            lastTrack = nil
            last = nil
        }
        let canvas = job.canvas
        guard ready, (2..<8192).contains(canvas.size.width), (2..<8192).contains(canvas.size.height), job.time.isFinite, abs(job.time) < 1e12 else { return .same }
        var fresh = lastTrack !== job.track
        if applied != canvas {
            applied = canvas
            fresh = true
            ass_set_frame_size(renderer, Int32(canvas.size.width), Int32(canvas.size.height))
            let video = canvas.video.width >= 1 && canvas.video.height >= 1 ? canvas.video : canvas.size
            ass_set_storage_size(renderer, Int32(video.width), Int32(video.height))
            ass_set_font_scale(renderer, canvas.scale)
        }
        let now = Int64((job.time * 1000).rounded())
        var drawn: AssFrame?
        if job.track.active(at: now) <= Self.activeLimit {
            var change: Int32 = 0
            if let images = ass_render_frame(renderer, job.track.pointer, now, &change) {
                drawn = change == 0 && !fresh ? last : Self.composite(images, canvas: canvas.size)
            }
            lastTrack = job.track
        } else {
            lastTrack = nil
        }
        guard drawn !== last else { return .same }
        last = drawn
        return .changed(drawn)
    }

    private static func composite(_ first: UnsafeMutablePointer<ASS_Image>, canvas: CGSize) -> AssFrame? {
        let (width, height) = (Int(canvas.width), Int(canvas.height))
        var box: (minX: Int, minY: Int, maxX: Int, maxY: Int)?
        var images: [UnsafeMutablePointer<ASS_Image>] = []
        var next: UnsafeMutablePointer<ASS_Image>? = first
        while let image = next, images.count < imageLimit {
            next = image.pointee.next
            let (x, y, w, h) = (Int(image.pointee.dst_x), Int(image.pointee.dst_y), Int(image.pointee.w), Int(image.pointee.h))
            guard w > 0, h > 0, image.pointee.color & 0xFF != 0xFF, image.pointee.bitmap != nil, image.pointee.stride >= w, x > -1 << 20, y > -1 << 20, x < width, y < height else { continue }
            let (left, top, right, bottom) = (max(0, x), max(0, y), min(width, x + w), min(height, y + h))
            guard right > left, bottom > top else { continue }
            images.append(image)
            box = box.map { (min($0.minX, left), min($0.minY, top), max($0.maxX, right), max($0.maxY, bottom)) } ?? (left, top, right, bottom)
        }
        guard let box else { return nil }
        let (boxWidth, boxHeight) = (box.maxX - box.minX, box.maxY - box.minY)
        let stride = boxWidth * 4
        guard boxWidth * boxHeight <= 64 << 20, let pixels = calloc(boxHeight, stride)?.assumingMemoryBound(to: UInt8.self) else { return nil }
        for image in images {
            let source = image.pointee
            let color = source.color
            let opacity = 255 - Int(color & 0xFF)
            let (red, green, blue) = (Int(color >> 24 & 0xFF), Int(color >> 16 & 0xFF), Int(color >> 8 & 0xFF))
            let (x, y) = (Int(source.dst_x), Int(source.dst_y))
            for row in max(0, box.minY - y)..<min(Int(source.h), box.maxY - y) {
                let mask = source.bitmap + row * Int(source.stride)
                var out = pixels + (y + row - box.minY) * stride
                let columns = max(0, box.minX - x)..<min(Int(source.w), box.maxX - x)
                out += (x + columns.lowerBound - box.minX) * 4
                for column in columns {
                    let alpha = (Int(mask[column]) * opacity + 127) / 255
                    if alpha > 0 {
                        let keep = 255 - alpha
                        out[0] = UInt8((blue * alpha + 127) / 255 + Int(out[0]) * keep / 255)
                        out[1] = UInt8((green * alpha + 127) / 255 + Int(out[1]) * keep / 255)
                        out[2] = UInt8((red * alpha + 127) / 255 + Int(out[2]) * keep / 255)
                        out[3] = UInt8(alpha + Int(out[3]) * keep / 255)
                    }
                    out += 4
                }
            }
        }
        guard let provider = CGDataProvider(dataInfo: nil, data: pixels, size: boxHeight * stride, releaseData: { _, data, _ in free(UnsafeMutableRawPointer(mutating: data)) }),
              let image = CGImage(width: boxWidth, height: boxHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: stride, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return nil }
        return AssFrame(image: image, rect: CGRect(x: box.minX, y: box.minY, width: boxWidth, height: boxHeight), canvas: canvas)
    }
}

/// One script: the track of an embedded stream or of an external .ass/.ssa file. It keeps at most `budget` bytes of events.
final class AssTrack {
    static let budget = 24 << 20
    static let packetLimit = 1 << 16
    static let headerLimit = 4 << 20

    private let engine: AssEngine
    fileprivate let pointer: UnsafeMutablePointer<ASS_Track>
    private var bytes = 0

    init?(engine: AssEngine, header: Data) {
        guard header.count <= Self.headerLimit else { return nil }
        let created = engine.lock.withLock { () -> UnsafeMutablePointer<ASS_Track>? in
            guard let track = ass_new_track(engine.library) else { return nil }
            header.withUnsafeBytes { raw in ass_process_codec_private(track, raw.baseAddress?.assumingMemoryBound(to: CChar.self), Int32(header.count)) }
            ass_set_check_readorder(track, 0)
            return track
        }
        guard let created else { return nil }
        self.engine = engine
        pointer = created
    }

    init?(engine: AssEngine, script: String) {
        var text = Array(script.utf8)
        guard text.count <= SubtitleParser.sizeLimit else { return nil }
        let read = engine.lock.withLock { text.withUnsafeMutableBytes { raw in ass_read_memory(engine.library, raw.baseAddress?.assumingMemoryBound(to: CChar.self), raw.count, nil) } }
        guard let read else { return nil }
        self.engine = engine
        pointer = read
        engine.lock.withLock { bytes = recount() }
    }

    deinit {
        let (engine, pointer) = (engine, pointer)
        engine.queue.async { engine.lock.withLock { ass_free_track(pointer) } }
    }

    var isEmpty: Bool { engine.lock.withLock { pointer.pointee.n_events == 0 } }

    var isFull: Bool { engine.lock.withLock { bytes >= Self.budget } }

    func add(_ packet: UnsafeRawBufferPointer, start: Double, duration: Double) {
        guard packet.count <= Self.packetLimit, start.isFinite, duration.isFinite, abs(start) < 1e12, abs(duration) < 1e12 else { return }
        engine.lock.withLock {
            ass_process_chunk(pointer, packet.baseAddress?.assumingMemoryBound(to: CChar.self), Int32(packet.count), Int64((start * 1000).rounded()), Int64((duration * 1000).rounded()))
            bytes += packet.count + MemoryLayout<ASS_Event>.size
        }
    }

    func flush() {
        engine.lock.withLock {
            ass_flush_events(pointer)
            bytes = 0
        }
    }

    /// Drops the events that ended before `time` and returns the memory they used.
    func prune(before time: Double) {
        engine.lock.withLock {
            ass_prune_events(pointer, Int64(max(0, time) * 1000))
            bytes = recount()
        }
    }

    fileprivate func active(at time: Int64) -> Int {
        var count = 0
        for number in 0..<Int(pointer.pointee.n_events) {
            let event = pointer.pointee.events[number]
            if event.Start <= time, time - event.Start < event.Duration { count += 1 }
        }
        return count
    }

    private func recount() -> Int {
        (0..<Int(pointer.pointee.n_events)).reduce(0) { total, number in
            total + MemoryLayout<ASS_Event>.size + (pointer.pointee.events[number].Text.map { strlen($0) } ?? 0)
        }
    }
}
