import AppKit
import CoreMedia

enum SubtitleFormat {
    case subrip, ass, webvtt, movText, picture

    init?(_ codec: AVCodecID) {
        switch codec {
        case AV_CODEC_ID_SUBRIP, AV_CODEC_ID_TEXT: self = .subrip
        case AV_CODEC_ID_ASS, AV_CODEC_ID_SSA: self = .ass
        case AV_CODEC_ID_WEBVTT: self = .webvtt
        case AV_CODEC_ID_MOV_TEXT: self = .movText
        case AV_CODEC_ID_HDMV_PGS_SUBTITLE, AV_CODEC_ID_DVD_SUBTITLE, AV_CODEC_ID_DVB_SUBTITLE:
            guard avcodec_find_decoder(codec) != nil else { return nil }
            self = .picture
        default: return nil
        }
    }

    func text(_ data: Data) -> String? {
        switch self {
        case .subrip: return nonEmpty(SubtitleText.clean(String(decoding: data, as: UTF8.self)))
        case .ass, .picture: return nil
        case .movText: return SubtitleParser.movText(data)
        case .webvtt:
            if data.count >= 8, ["vttc", "vtte"].contains(String(decoding: data[(data.startIndex + 4)..<(data.startIndex + 8)], as: UTF8.self)) { return SubtitleParser.webVTTBox(data) }
            return nonEmpty(SubtitleText.clean(String(decoding: data, as: UTF8.self)))
        }
    }

    private func nonEmpty(_ text: String) -> String? { text.isEmpty ? nil : text }
}

struct SubtitleStream {
    let index: Int32
    let format: SubtitleFormat?
    let language: String?
    let title: String?
    var ass: AssTrack?
}

struct PictureBitmap {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    let indices: Data
    let palette: [UInt32]

    var image: CGImage? {
        guard width > 0, height > 0, indices.count >= width * height else { return nil }
        var pixels = [UInt32](repeating: 0, count: width * height)
        indices.withUnsafeBytes { raw in
            for at in 0..<pixels.count { pixels[at] = palette[Int(raw[at])] }
        }
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                       bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue),
                       provider: CGDataProvider(data: Data(bytes: pixels, count: pixels.count * 4) as CFData)!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
}

final class PictureCue: Equatable {
    let start: Double
    let end: Double
    let canvas: CGSize
    let bitmaps: [PictureBitmap]
    private var drawn: [(image: CGImage, frame: CGRect)]?

    init(start: Double, end: Double, canvas: CGSize, bitmaps: [PictureBitmap]) {
        self.start = start
        self.end = end
        self.canvas = canvas
        self.bitmaps = bitmaps
    }

    static func == (left: PictureCue, right: PictureCue) -> Bool { left === right }

    var byteSize: Int { bitmaps.reduce(0) { $0 + $1.indices.count } }

    func ending(at time: Double) -> PictureCue {
        let copy = PictureCue(start: start, end: max(start, min(end, time)), canvas: canvas, bitmaps: bitmaps)
        copy.drawn = drawn
        return copy
    }

    var images: [(image: CGImage, frame: CGRect)] {
        if drawn == nil {
            drawn = bitmaps.compactMap { bitmap in bitmap.image.map { ($0, CGRect(x: bitmap.x, y: bitmap.y, width: bitmap.width, height: bitmap.height)) } }
        }
        return drawn ?? []
    }
}

final class PictureDecoder {
    struct Event {
        let start: Double
        let duration: Double
        let canvas: CGSize
        let bitmaps: [PictureBitmap]
    }

    private var context: UnsafeMutablePointer<AVCodecContext>?

    init?(_ stream: UnsafeMutablePointer<AVStream>) {
        guard let codec = avcodec_find_decoder(stream.pointee.codecpar.pointee.codec_id), let context = avcodec_alloc_context3(codec) else { return nil }
        var opened: UnsafeMutablePointer<AVCodecContext>? = context
        guard avcodec_parameters_to_context(context, stream.pointee.codecpar) >= 0 else {
            avcodec_free_context(&opened)
            return nil
        }
        context.pointee.pkt_timebase = stream.pointee.time_base
        guard avcodec_open2(context, codec, nil) >= 0 else {
            avcodec_free_context(&opened)
            return nil
        }
        self.context = context
    }

    deinit { avcodec_free_context(&context) }

    func flush() { avcodec_flush_buffers(context) }

    func decode(_ packet: UnsafeMutablePointer<AVPacket>, begin: Double, scale: Double, fallback: CGSize) -> Event? {
        guard let context else { return nil }
        var subtitle = AVSubtitle()
        var got: Int32 = 0
        guard avcodec_decode_subtitle2(context, &subtitle, &got, packet) >= 0, got != 0 else { return nil }
        defer { avsubtitle_free(&subtitle) }
        var bitmaps: [PictureBitmap] = []
        for position in 0..<Int(min(subtitle.num_rects, 16)) {
            guard let rect = subtitle.rects?[position]?.pointee, rect.type == SUBTITLE_BITMAP, rect.w > 0, rect.h > 0, rect.w <= 8192, rect.h <= 8192,
                  let pixels = rect.data.0, let colors = rect.data.1, rect.linesize.0 >= rect.w else { continue }
            let width = Int(rect.w), height = Int(rect.h), stride = Int(rect.linesize.0)
            var indices = Data(count: width * height)
            indices.withUnsafeMutableBytes { target in
                for row in 0..<height { memcpy(target.baseAddress! + row * width, pixels + row * stride, width) }
            }
            var palette = [UInt32](repeating: 0, count: 256)
            let source = UnsafeRawPointer(colors)
            for at in 0..<min(max(Int(rect.nb_colors), 0), 256) {
                let color = source.loadUnaligned(fromByteOffset: at * 4, as: UInt32.self)
                let alpha = color >> 24
                func premultiplied(_ shift: UInt32) -> UInt32 { (((color >> shift) & 0xFF) * alpha + 127) / 255 }
                palette[at] = alpha << 24 | premultiplied(16) << 16 | premultiplied(8) << 8 | premultiplied(0)
            }
            bitmaps.append(PictureBitmap(x: Int(rect.x), y: Int(rect.y), width: width, height: height, indices: indices, palette: palette))
        }
        var canvas = CGSize(width: Int(context.pointee.width), height: Int(context.pointee.height))
        if canvas.width < 1 || canvas.height < 1 { canvas = fallback }
        if let right = bitmaps.map({ $0.x + $0.width }).max(), let bottom = bitmaps.map({ $0.y + $0.height }).max(), canvas.width < CGFloat(right) || canvas.height < CGFloat(bottom) {
            canvas = CGSize(width: max(canvas.width, CGFloat(right)), height: max(canvas.height, CGFloat(bottom)))
        }
        let shown = subtitle.end_display_time > subtitle.start_display_time ? Double(subtitle.end_display_time - subtitle.start_display_time) / 1000 : 0
        let duration = shown > 0 ? min(shown, 60) : packet.pointee.duration > 0 ? Double(packet.pointee.duration) * scale : 5
        return Event(start: begin + Double(subtitle.start_display_time) / 1000, duration: duration, canvas: canvas, bitmaps: bitmaps)
    }
}

final class SubtitleScanner {
    private let url: URL
    private let onStreams: ([SubtitleStream]) -> Void
    private let onCues: (Int32, [SubtitleCue]) -> Void
    private let onPictures: (Int32, [PictureCue]) -> Void
    private let onAss: (Int32) -> Void
    private let engine: AssEngine?
    private let lock = NSLock()
    private let wake = DispatchSemaphore(value: 0)
    private var stopped = false
    private var planned: (from: Double, to: Double)
    private var jump: Double?
    private var playhead = 0.0
    private var stalledAt: Double?
    private static let lead = 30.0
    private static let window = 600.0
    private static let margin = 60.0
    private let pictureBudget: Int

    private struct Reader {
        let format: SubtitleFormat
        let scale: Double
        let pictures: PictureDecoder?
        let ass: AssTrack?
    }

    init(url: URL, start: Double, onStreams: @escaping ([SubtitleStream]) -> Void, onCues: @escaping (Int32, [SubtitleCue]) -> Void, onPictures: @escaping (Int32, [PictureCue]) -> Void = { _, _ in }, engine: AssEngine? = nil, onAss: @escaping (Int32) -> Void = { _ in }, pictureBudget: Int = 32 << 20) {
        self.url = url
        self.engine = engine
        self.onAss = onAss
        self.pictureBudget = pictureBudget
        self.onStreams = onStreams
        self.onCues = onCues
        self.onPictures = onPictures
        let from = max(0, start - Self.lead)
        planned = (from, from + Self.lead + Self.window)
        jump = from
        playhead = start
        DispatchQueue.global(qos: .utility).async { self.run() }
    }

    func cancel() {
        lock.withLock { stopped = true }
        wake.signal()
    }

    func cover(_ position: Double) {
        let signal = lock.withLock { () -> Bool in
            guard !stopped else { return false }
            playhead = position
            if position >= planned.from, position <= planned.to {
                if let at = stalledAt {
                    guard position - at >= 5 else { return false }
                    stalledAt = nil
                    return true
                }
                guard position > planned.to - Self.margin else { return false }
                planned.to += Self.window
            } else {
                let from = max(0, position - Self.lead)
                planned = (from, from + Self.lead + Self.window)
                jump = from
                stalledAt = nil
            }
            return true
        }
        if signal { wake.signal() }
    }

    private var isStopped: Bool { lock.withLock { stopped } }

    private func deliver(_ streams: [SubtitleStream]) {
        DispatchQueue.main.async { [onStreams] in onStreams(streams) }
    }

    private static func track(_ stream: UnsafeMutablePointer<AVStream>, in engine: AssEngine?) -> AssTrack? {
        let parameters = stream.pointee.codecpar.pointee
        guard let engine, parameters.extradata_size > 0, let header = parameters.extradata else { return nil }
        return AssTrack(engine: engine, header: Data(bytes: header, count: Int(parameters.extradata_size)))
    }

    private static func font(_ stream: UnsafeMutablePointer<AVStream>) -> (name: String, data: Data)? {
        let parameters = stream.pointee.codecpar.pointee
        guard parameters.extradata_size > 0, Int(parameters.extradata_size) <= AssEngine.fontFileLimit, let bytes = parameters.extradata else { return nil }
        let name = streamTag(stream, "filename") ?? "font"
        let kind = streamTag(stream, "mimetype")?.lowercased() ?? ""
        guard ["ttf", "otf", "ttc", "otc"].contains((name as NSString).pathExtension.lowercased()) || ["font", "truetype", "opentype"].contains(where: kind.contains) else { return nil }
        return (name, Data(bytes: bytes, count: Int(parameters.extradata_size)))
    }

    private func run() {
        defer { engine?.finishFonts() }
        let descriptor = open(url.path, O_RDONLY)
        guard descriptor >= 0 else { return deliver([]) }
        defer { close(descriptor) }
        let reader = ByteReader(size: lseek(descriptor, 0, SEEK_END)) { buffer, count, offset in
            let read = pread(descriptor, buffer, Int(count), offset)
            return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
        }
        defer { withExtendedLifetime(reader) {} }
        av_log_set_level(AV_LOG_QUIET)
        let bufferSize: Int32 = 1 << 16
        func release(_ io: UnsafeMutablePointer<AVIOContext>) {
            var io: UnsafeMutablePointer<AVIOContext>? = io
            av_freep(&io!.pointee.buffer)
            avio_context_free(&io)
        }
        guard let buffer = av_malloc(Int(bufferSize)),
              let io = avio_alloc_context(buffer.assumingMemoryBound(to: UInt8.self), bufferSize, 0, Unmanaged.passUnretained(reader).toOpaque(), readBytes, nil, seekBytes) else { return deliver([]) }
        var opened = avformat_alloc_context()
        opened?.pointee.pb = io
        guard avformat_open_input(&opened, url.lastPathComponent, nil, nil) == 0, let context = opened else {
            release(io)
            return deliver([])
        }
        defer {
            let io = context.pointee.pb
            var closing: UnsafeMutablePointer<AVFormatContext>? = context
            avformat_close_input(&closing)
            if let io { release(io) }
        }
        _ = avformat_find_stream_info(context, nil)
        let origin = context.pointee.start_time == PikaNoTimestamp ? 0 : Double(context.pointee.start_time) / Double(AV_TIME_BASE)
        var streams: [SubtitleStream] = []
        var active: [Int32: Reader] = [:]
        var clocks: [Int32: Double] = [:]
        var canvas = CGSize.zero
        for position in 0..<Int(context.pointee.nb_streams) {
            guard let stream = context.pointee.streams[position] else { continue }
            stream.pointee.discard = AVDISCARD_ALL
            if clocks.isEmpty, stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_VIDEO, stream.pointee.disposition & AV_DISPOSITION_ATTACHED_PIC == 0, stream.pointee.time_base.den > 0 {
                stream.pointee.discard = AVDISCARD_NONKEY
                clocks[stream.pointee.index] = Double(stream.pointee.time_base.num) / Double(stream.pointee.time_base.den)
                canvas = CGSize(width: Int(stream.pointee.codecpar.pointee.width), height: Int(stream.pointee.codecpar.pointee.height))
            }
            if stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_ATTACHMENT, let font = Self.font(stream) { engine?.addFont(name: font.name, data: font.data) }
            guard stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_SUBTITLE else { continue }
            var format = SubtitleFormat(stream.pointee.codecpar.pointee.codec_id)
            let script = format == .ass ? Self.track(stream, in: engine) : nil
            if format == .ass, script == nil { format = nil }
            streams.append(SubtitleStream(index: stream.pointee.index, format: format, language: streamTag(stream, "language"), title: streamTag(stream, "title"), ass: script))
            if let format, stream.pointee.time_base.den > 0 {
                let pictures = format == .picture ? PictureDecoder(stream) : nil
                guard format != .picture || pictures != nil else { continue }
                stream.pointee.discard = AVDISCARD_DEFAULT
                active[stream.pointee.index] = Reader(format: format, scale: Double(stream.pointee.time_base.num) / Double(stream.pointee.time_base.den), pictures: pictures, ass: script)
            }
        }
        engine?.finishFonts()
        deliver(streams)
        guard !active.isEmpty, !isStopped else { return }
        var cues: [Int32: [SubtitleCue]] = [:]
        var seen = Set<String>()
        var changed = Set<Int32>()
        var assChanged = Set<Int32>()
        var stalled = false
        var pictures: [Int32: [Double: PictureCue]] = [:]
        var latest: [Int32: PictureCue] = [:]
        var picturesChanged = Set<Int32>()
        var pictureBytes = 0
        var lastDelivery = Date()
        func flush() {
            for index in changed {
                let copy = cues[index] ?? []
                DispatchQueue.main.async { [onCues] in onCues(index, copy) }
            }
            for index in picturesChanged {
                let copy = (pictures[index] ?? [:]).values.sorted { $0.start < $1.start }
                DispatchQueue.main.async { [onPictures] in onPictures(index, copy) }
            }
            for index in assChanged { DispatchQueue.main.async { [onAss] in onAss(index) } }
            changed = []
            assChanged = []
            picturesChanged = []
            lastDelivery = Date()
        }
        func store(_ index: Int32, _ event: PictureDecoder.Event) {
            if let last = latest[index], last.end > event.start, pictures[index]?[last.start] != nil {
                pictures[index]?[last.start] = last.ending(at: event.start)
                picturesChanged.insert(index)
            }
            latest[index] = nil
            guard !event.bitmaps.isEmpty else { return }
            let cue = PictureCue(start: event.start, end: event.start + event.duration, canvas: event.canvas, bitmaps: event.bitmaps)
            if let old = pictures[index]?[cue.start] { pictureBytes -= old.byteSize }
            pictures[index, default: [:]][cue.start] = cue
            pictureBytes += cue.byteSize
            latest[index] = cue
            picturesChanged.insert(index)
            while pictureBytes > pictureBudget {
                let all = pictures.flatMap { index, map in map.values.map { (index, $0) } }
                guard let far = all.max(by: { abs($0.1.start - cue.start) < abs($1.1.start - cue.start) }), far.1 !== cue else { break }
                pictures[far.0]?[far.1.start] = nil
                pictureBytes -= far.1.byteSize
                picturesChanged.insert(far.0)
            }
        }
        func relieve(_ track: AssTrack) -> Bool {
            let from = lock.withLock { playhead } - Self.lead
            track.prune(before: from)
            lock.withLock { planned.from = max(planned.from, from) }
            return !track.isFull
        }
        guard let packet = av_packet_alloc() else { return }
        defer {
            var freed: UnsafeMutablePointer<AVPacket>? = packet
            av_packet_free(&freed)
        }
        var reached = -Double.infinity
        func read(until limit: Double) {
            var failures = 0
            while !isStopped, lock.withLock({ jump == nil }) {
                let result = av_read_frame(context, packet)
                guard result >= 0 else {
                    failures += 1
                    if result == PikaErrorEOF || context.pointee.pb.pointee.error < 0 || failures > 64 {
                        reached = .infinity
                        lock.withLock { planned.to = .infinity }
                        return
                    }
                    continue
                }
                failures = 0
                defer { av_packet_unref(packet) }
                let index = packet.pointee.stream_index
                guard packet.pointee.pts != PikaNoTimestamp, packet.pointee.size > 0, let scale = active[index]?.scale ?? clocks[index] else { continue }
                let begin = Double(packet.pointee.pts) * scale - origin
                guard begin.isFinite else { continue }
                if let reader = active[index] {
                    if let decoder = reader.pictures {
                        if let event = decoder.decode(packet, begin: begin, scale: scale, fallback: canvas) { store(index, event) }
                    } else if let data = packet.pointee.data {
                        let length = packet.pointee.duration > 0 ? Double(packet.pointee.duration) * scale : 4
                        if let track = reader.ass {
                            track.add(UnsafeRawBufferPointer(start: data, count: Int(packet.pointee.size)), start: begin, duration: length)
                            assChanged.insert(index)
                            if track.isFull, !relieve(track) { stalled = true }
                        } else if let text = reader.format.text(Data(bytes: data, count: Int(packet.pointee.size))) {
                            let key = "\(index)|\(begin)|\(text)"
                            if seen.insert(key).inserted {
                                cues[index, default: []].append(SubtitleCue(start: begin, end: begin + length, text: text))
                                changed.insert(index)
                            }
                        }
                    }
                }
                reached = max(reached, begin)
                if Date().timeIntervalSince(lastDelivery) > 0.5 { flush() }
                if stalled {
                    lock.withLock { stalledAt = playhead }
                    return
                }
                if begin > limit { return }
            }
        }
        while !isStopped {
            let (target, limit) = lock.withLock { () -> (Double?, Double) in
                defer { jump = nil }
                return (jump, planned.to)
            }
            if let target {
                if av_seek_frame(context, -1, Int64((target + origin) * Double(AV_TIME_BASE)), AVSEEK_FLAG_BACKWARD) < 0 { av_seek_frame(context, -1, Int64(origin * Double(AV_TIME_BASE)), AVSEEK_FLAG_BACKWARD) }
                context.pointee.pb.pointee.error = 0
                for reader in active.values {
                    reader.pictures?.flush()
                    reader.ass?.flush()
                }
                latest = [:]
                reached = -.infinity
                stalled = false
            }
            if reached >= limit || stalled {
                flush()
                wake.wait()
                stalled = false
                continue
            }
            read(until: limit)
            flush()
        }
    }
}

struct SubtitleScene: Equatable {
    var text: String?
    var pictures: [PictureCue] = []
}

final class SubtitleView: NSView {
    private let label = CATextLayer()
    private let assLayer = CALayer()
    private var stickers: [CALayer] = []
    private(set) var scene = SubtitleScene()
    private(set) var ass: AssFrame?
    private var raised: CGFloat = 0
    var shown: String? { scene.text }
    var onResize: () -> Void = {}
    var scale = 1.0 { didSet { relayout(animated: false) } }
    var videoSize = CGSize.zero { didSet { relayout(animated: false) } }

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        label.alignmentMode = .center
        label.isWrapped = true
        label.truncationMode = .none
        label.shadowColor = NSColor.black.cgColor
        label.shadowOpacity = 0.95
        label.shadowRadius = 3
        label.shadowOffset = CGSize(width: 0, height: -1)
        label.isHidden = true
        assLayer.magnificationFilter = .linear
        assLayer.minificationFilter = .trilinear
        assLayer.isHidden = true
        layer?.addSublayer(label)
        layer?.addSublayer(assLayer)
        setAccessibilityElement(false)
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func layout() {
        super.layout()
        relayout(animated: false)
        onResize()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        relayout(animated: false)
    }

    func show(_ scene: SubtitleScene) {
        guard scene != self.scene else { return }
        self.scene = scene
        relayout(animated: false)
    }

    func show(_ text: String?) {
        show(SubtitleScene(text: text))
    }

    func show(ass: AssFrame?) {
        guard ass !== self.ass else { return }
        self.ass = ass
        relayout(animated: false)
    }

    func lift(_ inset: CGFloat) {
        guard inset != raised else { return }
        raised = inset
        relayout(animated: true)
    }

    var assCanvas: AssCanvas {
        let region = videoRect
        let factor = window?.backingScaleFactor ?? 2
        return AssCanvas(size: CGSize(width: (region.width * factor).rounded(), height: (region.height * factor).rounded()), video: videoSize, scale: scale)
    }

    private var videoRect: CGRect {
        guard videoSize.width > 0, videoSize.height > 0 else { return bounds }
        let fit = min(bounds.width / videoSize.width, bounds.height / videoSize.height)
        let size = CGSize(width: videoSize.width * fit, height: videoSize.height * fit)
        return CGRect(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width, height: size.height)
    }

    private func relayout(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        defer { CATransaction.commit() }
        let usable = bounds.width > 40 && bounds.height > 40
        layoutText(usable ? scene.text : nil)
        layoutPictures(usable ? scene.pictures : [])
        layoutAss(usable ? ass : nil)
    }

    private func layoutText(_ text: String?) {
        guard let text else {
            label.isHidden = true
            return
        }
        label.contentsScale = window?.backingScaleFactor ?? 2
        let attributed = Self.attributed(text, size: SubtitleStyle.fontSize(forHeight: Double(bounds.height), scale: scale))
        let rect = attributed.boundingRect(with: CGSize(width: bounds.width * 0.86, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading])
        let size = CGSize(width: min(bounds.width, ceil(rect.width) + 8), height: ceil(rect.height) + 2)
        label.string = attributed
        label.frame = CGRect(x: ((bounds.width - size.width) / 2).rounded(), y: max(raised, bounds.height * 0.05).rounded(), width: size.width, height: size.height)
        label.isHidden = false
    }

    private func place(_ canvas: CGSize, _ rects: [CGRect]) -> [CGRect] {
        let region = videoRect
        guard canvas.width > 0, canvas.height > 0 else { return [] }
        let (sx, sy) = (region.width / canvas.width, region.height / canvas.height)
        return rects.map { CGRect(x: region.minX + $0.minX * sx, y: region.maxY - $0.maxY * sy, width: $0.width * sx, height: $0.height * sy) }
    }

    private func lifted(_ rects: [CGRect]) -> [CGRect] {
        let lift = max(0, raised - (rects.map(\.minY).min() ?? raised))
        return rects.map { $0.offsetBy(dx: 0, dy: lift) }
    }

    private func layoutAss(_ frame: AssFrame?) {
        guard let frame, let rect = lifted(place(frame.canvas, [frame.rect])).first else {
            assLayer.isHidden = true
            return
        }
        assLayer.contents = frame.image
        assLayer.frame = rect
        assLayer.isHidden = false
    }

    private func layoutPictures(_ all: [PictureCue]) {
        let cues = all.filter { $0.canvas.width > 0 && $0.canvas.height > 0 }
        let images = cues.flatMap { $0.images.map(\.image) }
        let placed = lifted(cues.flatMap { place($0.canvas, $0.images.map(\.frame)) })
        while stickers.count < placed.count {
            let layer = CALayer()
            layer.magnificationFilter = .linear
            layer.minificationFilter = .trilinear
            self.layer?.addSublayer(layer)
            stickers.append(layer)
        }
        for (number, layer) in stickers.enumerated() {
            guard number < placed.count else {
                layer.isHidden = true
                continue
            }
            layer.contents = images[number]
            layer.frame = placed[number]
            layer.isHidden = false
        }
    }

    private static func attributed(_ text: String, size: CGFloat) -> NSAttributedString {
        let base = NSFont.systemFont(ofSize: size, weight: .semibold)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let result = NSMutableAttributedString()
        for span in SubtitleText.spans(text) {
            var traits: NSFontDescriptor.SymbolicTraits = []
            if span.italic { traits.insert(.italic) }
            if span.bold { traits.insert(.bold) }
            let font = traits.isEmpty ? base : NSFont(descriptor: base.fontDescriptor.withSymbolicTraits(traits), size: size) ?? base
            result.append(NSAttributedString(string: span.text, attributes: [.font: font, .foregroundColor: NSColor.white, .paragraphStyle: style]))
        }
        return result
    }
}

final class Subtitles {
    struct Entry {
        let id: String
        let title: String
        let language: String?
        var cues: SubtitleCues
        var pictures: [PictureCue] = []
        var ass: AssTrack?
        let available: Bool
    }

    private static let scaleKey = "subtitleScale"
    let view = SubtitleView()
    private(set) var tracks: [Entry] = []
    private(set) var selected: String?
    private(set) var chosen = false
    private(set) var delay = 0.0
    private(set) var scale: Double
    var position: () -> Double = { 0 }
    var playing: () -> Bool = { true }
    var ticking: Bool { timer != nil }
    private var scanner: SubtitleScanner?
    private var engine: AssEngine?
    private var generation = 0
    private var timer: Timer?
    private var interval = 0.0
    private var shown = SubtitleScene()
    private var flash: (text: String, until: Date)?
    private var decided = false
    private var saved = ""
    private var audioLanguage: String?
    private var loading = 0
    private var embeddedKnown = false

    init() {
        scale = SubtitleStyle.clampedScale(UserDefaults.standard.object(forKey: Self.scaleKey) as? Double ?? 1)
        view.scale = scale
        view.onResize = { [weak self] in self?.refresh() }
    }

    func install(in parent: NSView, below sibling: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(view, positioned: .below, relativeTo: sibling)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }

    func open(_ file: URL, resume: Double, saved: String, delay: Double, audioLanguage: String?, neighbours: [URL]?) {
        close()
        self.delay = delay
        generation += 1
        let current = generation
        self.saved = saved
        self.audioLanguage = audioLanguage
        engine = AssEngine()
        for url in SubtitleFiles.matching(video: file, among: neighbours ?? []) { load(url, select: false) }
        scanner = SubtitleScanner(url: file, start: resume, onStreams: { [weak self] in
            guard let self, self.generation == current else { return }
            self.adopt($0)
        }, onCues: { [weak self] index, cues in
            guard let self, self.generation == current else { return }
            if let at = self.tracks.firstIndex(where: { $0.id == "e\(index)" }) { self.tracks[at].cues = SubtitleCues(cues) }
            self.refresh()
        }, onPictures: { [weak self] index, pictures in
            guard let self, self.generation == current else { return }
            if let at = self.tracks.firstIndex(where: { $0.id == "e\(index)" }) { self.tracks[at].pictures = pictures }
            self.refresh()
        }, engine: engine, onAss: { [weak self] _ in
            guard let self, self.generation == current else { return }
            self.refresh()
        })
    }

    func close() {
        generation += 1
        scanner?.cancel()
        scanner = nil
        engine = nil
        tracks = []
        selected = nil
        chosen = false
        decided = false
        delay = 0
        flash = nil
        loading = 0
        embeddedKnown = false
        saved = ""
        updateTimer()
        view.show(SubtitleScene())
        view.show(ass: nil)
        shown = SubtitleScene()
    }

    func load(_ url: URL, select: Bool, failed: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        let current = generation
        let engine = engine
        loading += 1
        DispatchQueue.global(qos: .userInitiated).async {
            let text = (try? Data(contentsOf: url, options: .mappedIfSafe)).flatMap(SubtitleParser.decode)
            let isASS = text.map(SubtitleParser.isASS) == true
            let script = isASS ? engine.flatMap { engine in text.flatMap { AssTrack(engine: engine, script: $0) } } : nil
            let usable = script?.isEmpty == false
            let cues = isASS ? [] : text.map(SubtitleParser.parse) ?? []
            DispatchQueue.main.async { [self] in
                guard generation == current else { return }
                loading -= 1
                guard !cues.isEmpty || usable else {
                    failed?()
                    return decide()
                }
                let id = "f:" + url.lastPathComponent
                let track = Entry(id: id, title: url.lastPathComponent, language: nil, cues: SubtitleCues(cues), ass: usable ? script : nil, available: true)
                if let at = tracks.firstIndex(where: { $0.id == id }) { tracks[at] = track } else { tracks.append(track) }
                if select {
                    choose(id)
                    done?()
                } else {
                    decide()
                }
            }
        }
    }

    func choose(_ id: String?) {
        selected = id.flatMap { id in tracks.contains { $0.id == id && $0.available } ? id : nil }
        chosen = true
        decided = true
        updateTimer()
        refresh()
    }

    func cycle() {
        let usable = tracks.filter(\.available).map(\.id)
        let next = selected.flatMap { usable.firstIndex(of: $0) }.map { $0 + 1 } ?? 0
        choose(next < usable.count ? usable[next] : nil)
    }

    func shift(by seconds: Double) {
        delay = ((delay + seconds) * 10).rounded() / 10
        announce(String(localized: "Subtitle Delay: \(delay.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always(includingZero: false)))) s"))
    }

    func resize(by step: Double) {
        scale = SubtitleStyle.clampedScale(scale + step)
        UserDefaults.standard.set(scale, forKey: Self.scaleKey)
        view.scale = scale
        announce(String(localized: "Subtitle Size: \(scale.formatted(.percent.precision(.fractionLength(0))))"))
    }

    func refresh() {
        scanner?.cover(position())
        var scene = SubtitleScene()
        let track = selected.flatMap { id in tracks.first { $0.id == id } }
        if let flash, flash.until > Date() {
            scene.text = flash.text
        } else {
            flash = nil
            if let track {
                let moment = position() - delay
                scene.text = track.cues.text(at: position(), delay: delay)
                scene.pictures = track.pictures.filter { $0.start <= moment && $0.end > moment }
            }
        }
        updateTimer()
        if scene != shown {
            shown = scene
            view.show(scene)
        }
        drawAss(track?.ass)
    }

    private func drawAss(_ script: AssTrack?) {
        guard let script, let engine else {
            engine?.forget()
            return view.show(ass: nil)
        }
        let (current, id) = (generation, selected)
        engine.render(script, at: position() - delay, canvas: view.assCanvas) { [weak self] frame in
            guard let self, self.generation == current, self.selected == id else { return }
            self.view.show(ass: frame)
        }
    }

    func announce(_ message: String) {
        flash = (message, Date().addingTimeInterval(1.2))
        updateTimer()
        refresh()
    }

    private func adopt(_ streams: [SubtitleStream]) {
        embeddedKnown = true
        for (number, stream) in streams.enumerated() {
            let name = PlayerTracks.title(language: stream.language, name: stream.title, number: number + 1)
            let title = stream.format == nil ? String(localized: "\(name) (can’t be shown)") : name
            tracks.append(Entry(id: "e\(stream.index)", title: title, language: PlayerTracks.language(stream.language), cues: SubtitleCues([]), ass: stream.ass, available: stream.format != nil))
        }
        decide()
        refresh()
    }

    private func decide() {
        guard !decided, embeddedKnown, loading == 0 else { return }
        decided = true
        guard !chosen else { return }
        let usable = tracks.filter(\.available)
        switch saved {
        case "off": selected = nil
        case let id where usable.contains { $0.id == id }: selected = id
        default:
            if let external = usable.first(where: { $0.id.hasPrefix("f:") }) {
                selected = external.id
            } else if let at = PlayerTracks.preferred(among: usable.map(\.language)), usable[at].language != PlayerTracks.language(audioLanguage) {
                selected = usable[at].id
            }
        }
        updateTimer()
        refresh()
    }

    private func updateTimer() {
        let wanted = (selected != nil && playing()) || flash != nil
        let rate = tracks.first { $0.id == selected }?.ass == nil ? 0.05 : 1.0 / 30
        if !wanted || rate != interval {
            timer?.invalidate()
            timer = nil
        }
        if wanted, timer == nil {
            interval = rate
            timer = Timer(timeInterval: rate, repeats: true) { [weak self] _ in self?.refresh() }
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
}
