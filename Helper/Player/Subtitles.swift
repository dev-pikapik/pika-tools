import AppKit
import CoreMedia

enum SubtitleFormat {
    case subrip, ass, webvtt, movText

    init?(_ codec: AVCodecID) {
        switch codec {
        case AV_CODEC_ID_SUBRIP, AV_CODEC_ID_TEXT: self = .subrip
        case AV_CODEC_ID_ASS, AV_CODEC_ID_SSA: self = .ass
        case AV_CODEC_ID_WEBVTT: self = .webvtt
        case AV_CODEC_ID_MOV_TEXT: self = .movText
        default: return nil
        }
    }

    func text(_ data: Data) -> String? {
        switch self {
        case .subrip: return nonEmpty(SubtitleText.clean(String(decoding: data, as: UTF8.self)))
        case .ass: return SubtitleParser.ass(packet: String(decoding: data, as: UTF8.self))
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
}

final class SubtitleScanner {
    private let url: URL
    private let onStreams: ([SubtitleStream]) -> Void
    private let onCues: (Int32, [SubtitleCue]) -> Void
    private let lock = NSLock()
    private let wake = DispatchSemaphore(value: 0)
    private var stopped = false
    private var planned: (from: Double, to: Double)
    private var jump: Double?
    private static let lead = 30.0
    private static let window = 600.0
    private static let margin = 60.0

    init(url: URL, start: Double, onStreams: @escaping ([SubtitleStream]) -> Void, onCues: @escaping (Int32, [SubtitleCue]) -> Void) {
        self.url = url
        self.onStreams = onStreams
        self.onCues = onCues
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
        var active: [Int32: (format: SubtitleFormat, scale: Double)] = [:]
        var clocks: [Int32: Double] = [:]
        for position in 0..<Int(context.pointee.nb_streams) {
            guard let stream = context.pointee.streams[position] else { continue }
            stream.pointee.discard = AVDISCARD_ALL
            if clocks.isEmpty, stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_VIDEO, stream.pointee.disposition & AV_DISPOSITION_ATTACHED_PIC == 0, stream.pointee.time_base.den > 0 {
                stream.pointee.discard = AVDISCARD_NONKEY
                clocks[stream.pointee.index] = Double(stream.pointee.time_base.num) / Double(stream.pointee.time_base.den)
            }
            guard stream.pointee.codecpar.pointee.codec_type == AVMEDIA_TYPE_SUBTITLE else { continue }
            let format = SubtitleFormat(stream.pointee.codecpar.pointee.codec_id)
            streams.append(SubtitleStream(index: stream.pointee.index, format: format, language: streamTag(stream, "language"), title: streamTag(stream, "title")))
            if let format, stream.pointee.time_base.den > 0 {
                stream.pointee.discard = AVDISCARD_DEFAULT
                active[stream.pointee.index] = (format, Double(stream.pointee.time_base.num) / Double(stream.pointee.time_base.den))
            }
        }
        deliver(streams)
        guard !active.isEmpty, !isStopped else { return }
        var cues: [Int32: [SubtitleCue]] = [:]
        var seen = Set<String>()
        var changed = Set<Int32>()
        var lastDelivery = Date()
        func flush() {
            for index in changed {
                let copy = cues[index] ?? []
                DispatchQueue.main.async { [onCues] in onCues(index, copy) }
            }
            changed = []
            lastDelivery = Date()
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
                guard packet.pointee.pts != PikaNoTimestamp, let scale = active[index]?.scale ?? clocks[index] else { continue }
                let begin = Double(packet.pointee.pts) * scale - origin
                guard begin.isFinite else { continue }
                if let format = active[index]?.format, let data = packet.pointee.data, let text = format.text(Data(bytes: data, count: Int(packet.pointee.size))) {
                    let length = packet.pointee.duration > 0 ? Double(packet.pointee.duration) * scale : 4
                    let key = "\(index)|\(begin)|\(text)"
                    if seen.insert(key).inserted {
                        cues[index, default: []].append(SubtitleCue(start: begin, end: begin + length, text: text))
                        changed.insert(index)
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

final class SubtitleView: NSView {
    private let label = CATextLayer()
    private(set) var shown: String?
    private var raised: CGFloat = 0
    var scale = 1.0 { didSet { relayout(animated: false) } }

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
        layer?.addSublayer(label)
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
        label.contentsScale = window?.backingScaleFactor ?? 2
    }

    func show(_ text: String?) {
        guard text != shown else { return }
        shown = text
        relayout(animated: false)
    }

    func lift(_ inset: CGFloat) {
        guard inset != raised else { return }
        raised = inset
        relayout(animated: true)
    }

    private func relayout(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        defer { CATransaction.commit() }
        guard let text = shown, bounds.width > 40, bounds.height > 40 else {
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
    private var scanner: SubtitleScanner?
    private var generation = 0
    private var timer: Timer?
    private var shown: String?
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
        view.show(nil)
        shown = nil
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
        var text: String?
        if let flash, flash.until > Date() {
            text = flash.text
        } else {
            flash = nil
            if let selected, let track = tracks.first(where: { $0.id == selected }) { text = track.cues.text(at: position(), delay: delay) }
            updateTimer()
        }
        if text != shown {
            shown = text
            view.show(text)
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
        let wanted = selected != nil || flash != nil
        if wanted, timer == nil {
            timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in self?.refresh() }
            RunLoop.main.add(timer!, forMode: .common)
        } else if !wanted {
            timer?.invalidate()
            timer = nil
        }
    }
}
