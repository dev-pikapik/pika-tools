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

    func event(_ data: Data, styles: AssStyles) -> (text: String, block: SubtitleBlock?)? {
        switch self {
        case .subrip: return nonEmpty(SubtitleText.clean(String(decoding: data, as: UTF8.self))).map { ($0, nil) }
        case .ass: return SubtitleParser.assEvent(packet: String(decoding: data, as: UTF8.self), styles: styles)
        case .movText: return SubtitleParser.movText(data).map { ($0, nil) }
        case .picture: return nil
        case .webvtt:
            if data.count >= 8, ["vttc", "vtte"].contains(String(decoding: data[(data.startIndex + 4)..<(data.startIndex + 8)], as: UTF8.self)) { return SubtitleParser.webVTTBox(data).map { ($0, nil) } }
            return nonEmpty(SubtitleText.clean(String(decoding: data, as: UTF8.self))).map { ($0, nil) }
        }
    }

    private func nonEmpty(_ text: String) -> String? { text.isEmpty ? nil : text }
}

struct SubtitleStream {
    let index: Int32
    let format: SubtitleFormat?
    let language: String?
    let title: String?
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
    private let lock = NSLock()
    private let wake = DispatchSemaphore(value: 0)
    private var stopped = false
    private var planned: (from: Double, to: Double)
    private var jump: Double?
    private static let lead = 30.0
    private static let window = 600.0
    private static let margin = 60.0
    private let pictureBudget: Int

    private struct Reader {
        let format: SubtitleFormat
        let scale: Double
        let styles: AssStyles
        let pictures: PictureDecoder?
    }

    init(url: URL, start: Double, onStreams: @escaping ([SubtitleStream]) -> Void, onCues: @escaping (Int32, [SubtitleCue]) -> Void, onPictures: @escaping (Int32, [PictureCue]) -> Void = { _, _ in }, pictureBudget: Int = 32 << 20) {
        self.url = url
        self.pictureBudget = pictureBudget
        self.onStreams = onStreams
        self.onCues = onCues
        self.onPictures = onPictures
        let from = max(0, start - Self.lead)
        planned = (from, from + Self.lead + Self.window)
        jump = from
        DispatchQueue.global(qos: .utility).async { self.run() }
    }

    func cancel() {
        lock.withLock { stopped = true }
        wake.signal()
    }

    func cover(_ position: Double) {
        let signal = lock.withLock { () -> Bool in
            guard !stopped else { return false }
            if position >= planned.from, position <= planned.to {
                guard position > planned.to - Self.margin else { return false }
                planned.to += Self.window
            } else {
                let from = max(0, position - Self.lead)
                planned = (from, from + Self.lead + Self.window)
                jump = from
            }
            return true
        }
        if signal { wake.signal() }
    }

    private var isStopped: Bool { lock.withLock { stopped } }

    private func deliver(_ streams: [SubtitleStream]) {
        DispatchQueue.main.async { [onStreams] in onStreams(streams) }
    }

    private func run() {
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
            guard stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_SUBTITLE else { continue }
            let format = SubtitleFormat(stream.pointee.codecpar.pointee.codec_id)
            streams.append(SubtitleStream(index: stream.pointee.index, format: format, language: streamTag(stream, "language"), title: streamTag(stream, "title")))
            if let format, stream.pointee.time_base.den > 0 {
                let parameters = stream.pointee.codecpar.pointee
                let pictures = format == .picture ? PictureDecoder(stream) : nil
                guard format != .picture || pictures != nil else { continue }
                stream.pointee.discard = AVDISCARD_DEFAULT
                let header = format == .ass && parameters.extradata_size > 0 ? parameters.extradata.map { String(decoding: UnsafeBufferPointer(start: $0, count: Int(parameters.extradata_size)), as: UTF8.self) } : nil
                active[stream.pointee.index] = Reader(format: format, scale: Double(stream.pointee.time_base.num) / Double(stream.pointee.time_base.den), styles: header.map(AssScript.styles) ?? AssStyles(), pictures: pictures)
            }
        }
        deliver(streams)
        guard !active.isEmpty, !isStopped else { return }
        var cues: [Int32: [SubtitleCue]] = [:]
        var seen = Set<String>()
        var changed = Set<Int32>()
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
            changed = []
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
                    } else if let data = packet.pointee.data, let item = reader.format.event(Data(bytes: data, count: Int(packet.pointee.size)), styles: reader.styles) {
                        let length = packet.pointee.duration > 0 ? Double(packet.pointee.duration) * scale : 4
                        let key = "\(index)|\(begin)|\(item.text)"
                        if seen.insert(key).inserted {
                            cues[index, default: []].append(SubtitleCue(start: begin, end: begin + length, text: item.text, block: item.block))
                            changed.insert(index)
                        }
                    }
                }
                reached = max(reached, begin)
                if Date().timeIntervalSince(lastDelivery) > 0.5 { flush() }
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
                for reader in active.values { reader.pictures?.flush() }
                latest = [:]
                reached = -.infinity
            }
            if reached >= limit {
                flush()
                wake.wait()
                continue
            }
            read(until: limit)
            flush()
        }
    }
}

struct SubtitleScene: Equatable {
    var blocks: [SubtitleBlock] = []
    var pictures: [PictureCue] = []

    var text: String? { blocks.isEmpty ? nil : blocks.map(\.text).joined(separator: "\n") }
}

final class SubtitleView: NSView {
    private final class Group {
        let edge = CATextLayer()
        let fill = CATextLayer()

        init() {
            for layer in [edge, fill] {
                layer.isWrapped = true
                layer.truncationMode = .none
                layer.isHidden = true
            }
            fill.shadowColor = NSColor.black.cgColor
            fill.shadowOpacity = 0.95
            fill.shadowRadius = 3
            fill.shadowOffset = CGSize(width: 0, height: -1)
        }
    }

    private var groups: [Int: Group] = [:]
    private var stickers: [CALayer] = []
    private(set) var scene = SubtitleScene()
    private var raised: CGFloat = 0
    var shown: String? { scene.text }
    var scale = 1.0 { didSet { relayout(animated: false) } }
    var videoSize = CGSize.zero { didSet { relayout(animated: false) } }

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        setAccessibilityElement(false)
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func layout() {
        super.layout()
        relayout(animated: false)
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
        show(SubtitleScene(blocks: text.map { [SubtitleBlock(plain: $0)] } ?? []))
    }

    func lift(_ inset: CGFloat) {
        guard inset != raised else { return }
        raised = inset
        relayout(animated: true)
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
        let byPlace = usable ? Dictionary(grouping: scene.blocks, by: \.alignment) : [:]
        for (place, group) in groups where byPlace[place] == nil {
            group.edge.isHidden = true
            group.fill.isHidden = true
        }
        for (place, blocks) in byPlace { layoutText(blocks, place: place) }
        layoutPictures(usable ? scene.pictures : [])
    }

    private func layoutText(_ blocks: [SubtitleBlock], place: Int) {
        let group = groups[place] ?? { let made = Group(); layer?.addSublayer(made.edge); layer?.addSublayer(made.fill); groups[place] = made; return made }()
        let styled = blocks[0].height > 0
        let region = styled ? videoRect : bounds
        let unit = styled ? region.height / blocks[0].height : 1
        let base = SubtitleStyle.fontSize(forHeight: Double(region.height), scale: scale)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = place % 3 == 1 ? .left : place % 3 == 0 ? .right : .center
        let fill = NSMutableAttributedString()
        let edge = NSMutableAttributedString()
        var outline = 0.0
        for (number, block) in blocks.enumerated() {
            let width = styled ? block.outline * Double(unit) : 0
            outline = max(outline, width)
            for (at, var span) in block.spans.enumerated() {
                if number > 0, at == 0 { span.text = "\n" + span.text }
                let size = span.size.map { $0 * Double(unit) * scale } ?? base
                let font = Self.font(span, cell: size, base: base, fitted: span.size != nil)
                var attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: Self.color(span.color) ?? NSColor.white, .paragraphStyle: paragraph]
                if span.underline { attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue }
                if span.strike { attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
                fill.append(NSAttributedString(string: span.text, attributes: attributes))
                attributes[.strokeColor] = Self.color(span.outline) ?? NSColor.black
                attributes[.strokeWidth] = width > 0 ? 2 * width / Double(font.pointSize) * 100 : 0
                edge.append(NSAttributedString(string: span.text, attributes: attributes))
            }
        }
        let (left, right, vertical) = styled ? (blocks.map(\.marginL).max() ?? 0, blocks.map(\.marginR).max() ?? 0, blocks.map(\.marginV).max() ?? 0) : (0, 0, 0)
        let pad = ceil(outline) + 4
        let limit = styled ? max(40, region.width - CGFloat(left + right) * unit) : region.width * 0.86
        let measured = fill.boundingRect(with: CGSize(width: limit, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading])
        let size = CGSize(width: min(region.width, ceil(measured.width)) + 2 * pad, height: ceil(measured.height) + 2 * pad)
        var x = region.midX - size.width / 2
        if place % 3 == 1 { x = region.minX + CGFloat(left) * unit - pad }
        if place % 3 == 0 { x = region.maxX - CGFloat(right) * unit - size.width + pad }
        if place % 3 == 2 { x += CGFloat(left - right) * unit / 2 }
        var y = region.midY - size.height / 2
        let inset = styled ? CGFloat(vertical) * unit : region.height * 0.05
        if place <= 3 { y = max(raised, region.minY + inset - pad) }
        if place >= 7 { y = region.maxY - inset - size.height + pad }
        let frame = CGRect(x: x.rounded(), y: y.rounded(), width: size.width, height: size.height)
        let mode: CATextLayerAlignmentMode = place % 3 == 1 ? .left : place % 3 == 0 ? .right : .center
        let scaleFactor = window?.backingScaleFactor ?? 2
        for (layer, text) in [(group.edge, edge), (group.fill, fill)] {
            layer.contentsScale = scaleFactor
            layer.alignmentMode = mode
            layer.string = text
            layer.frame = frame
            layer.isHidden = layer === group.edge && outline <= 0
        }
    }

    private func layoutPictures(_ cues: [PictureCue]) {
        let region = videoRect
        var placed: [(CGImage, CGRect)] = []
        for cue in cues where cue.canvas.width > 0 && cue.canvas.height > 0 {
            let (sx, sy) = (region.width / cue.canvas.width, region.height / cue.canvas.height)
            for (image, frame) in cue.images {
                placed.append((image, CGRect(x: region.minX + frame.minX * sx, y: region.maxY - frame.maxY * sy, width: frame.width * sx, height: frame.height * sy)))
            }
        }
        let lift = max(0, raised - (placed.map(\.1.minY).min() ?? raised))
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
            layer.contents = placed[number].0
            layer.frame = placed[number].1.offsetBy(dx: 0, dy: lift)
            layer.isHidden = false
        }
    }

    private static func color(_ value: UInt32?) -> NSColor? {
        value.map { NSColor(srgbRed: CGFloat($0 >> 16 & 0xFF) / 255, green: CGFloat($0 >> 8 & 0xFF) / 255, blue: CGFloat($0 & 0xFF) / 255, alpha: 1) }
    }

    private static func font(_ span: SubtitleSpan, cell: Double, base: Double, fitted: Bool) -> NSFont {
        func make(_ size: Double) -> NSFont {
            let plain = span.font.flatMap { NSFont(name: $0, size: size) } ?? NSFont.systemFont(ofSize: size, weight: .semibold)
            var traits: NSFontDescriptor.SymbolicTraits = []
            if span.italic { traits.insert(.italic) }
            if span.bold { traits.insert(.bold) }
            return traits.isEmpty ? plain : NSFont(descriptor: plain.fontDescriptor.withSymbolicTraits(traits), size: size) ?? plain
        }
        guard fitted else { return make(cell) }
        let probe = make(cell)
        let height = Double(probe.ascender - probe.descender)
        return height > 0 ? make(max(8, cell * cell / height)) : probe
    }
}

final class Subtitles {
    struct Entry {
        let id: String
        let title: String
        let language: String?
        var cues: SubtitleCues
        var pictures: [PictureCue] = []
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
    private var generation = 0
    private var timer: Timer?
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
        })
    }

    func close() {
        generation += 1
        scanner?.cancel()
        scanner = nil
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
        shown = SubtitleScene()
    }

    func load(_ url: URL, select: Bool, failed: (() -> Void)? = nil, done: (() -> Void)? = nil) {
        let current = generation
        loading += 1
        DispatchQueue.global(qos: .userInitiated).async {
            let data = (try? Data(contentsOf: url, options: .mappedIfSafe)).flatMap { $0.count <= SubtitleParser.sizeLimit ? $0 : nil }
            let cues = data.map(SubtitleParser.parse) ?? []
            DispatchQueue.main.async { [self] in
                guard generation == current else { return }
                loading -= 1
                guard !cues.isEmpty else {
                    failed?()
                    return decide()
                }
                let id = "f:" + url.lastPathComponent
                let track = Entry(id: id, title: url.lastPathComponent, language: nil, cues: SubtitleCues(cues), available: true)
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
        if let flash, flash.until > Date() {
            scene.blocks = [SubtitleBlock(plain: flash.text)]
        } else {
            flash = nil
            if let selected, let track = tracks.first(where: { $0.id == selected }) {
                let moment = position() - delay
                scene.blocks = track.cues.active(at: position(), delay: delay).map { $0.block ?? SubtitleBlock(plain: $0.text) }
                scene.pictures = track.pictures.filter { $0.start <= moment && $0.end > moment }
            }
        }
        updateTimer()
        if scene != shown {
            shown = scene
            view.show(scene)
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
            tracks.append(Entry(id: "e\(stream.index)", title: title, language: PlayerTracks.language(stream.language), cues: SubtitleCues([]), available: stream.format != nil))
        }
        decide()
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
        if wanted, timer == nil {
            timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in self?.refresh() }
            RunLoop.main.add(timer!, forMode: .common)
        } else if !wanted {
            timer?.invalidate()
            timer = nil
        }
    }
}
