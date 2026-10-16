import AppKit
import ImageIO
import UniformTypeIdentifiers

/// Draws ASS scripts through the player's libass wrapper and compares the frames with small reference PNGs in
/// scripts/ass-reference, the way libass compares its own test scripts: a pixel counts as different only above a tolerance,
/// and only a small share of different pixels is allowed. The scripts draw shapes instead of text, so the frames do not
/// depend on the fonts of the Mac that runs the test. UPDATE=1 writes new references.
/// Every file in scripts/ass-corpus (animation, karaoke, \move, \t, \clip, broken tags) and many random changes
/// of those files are drawn in a child process with a time limit: no file may crash or hang the player.
@main
enum TestAss {
    static let size = CGSize(width: 160, height: 90)
    static let header = "[Script Info]\nScriptType: v4.00+\nPlayResX: 160\nPlayResY: 90\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: Default,Helvetica,20,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0,0,7,0,0,0,1\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n"

    static func main() {
        let arguments = CommandLine.arguments
        if arguments.count == 3, arguments[1] == "--draw" { return child(path: arguments[2], mutate: false) }
        if arguments.count == 4, arguments[1] == "--mutate" { return child(path: arguments[2], mutate: true, seed: UInt64(arguments[3]) ?? 1) }
        guard let engine = AssEngine() else { fatalError("libass did not start") }
        engine.finishFonts()
        frames(engine)
        limits(engine)
        corpus()
        print("ASS through libass: moving and karaoke frames match the references, memory and crowd limits hold, the corpus draws without a crash or a hang: ok")
    }

    // MARK: frames

    static func canvas(_ scale: Double = 1) -> AssCanvas { AssCanvas(size: size, video: size, scale: scale) }

    /// Waits until the engine has drawn the request; the answer comes on the main queue before the sentinel does.
    static func draw(_ engine: AssEngine, _ track: AssTrack, at time: Double, canvas: AssCanvas) -> AssFrame? {
        var result: AssFrame?
        engine.forget()
        engine.render(track, at: time, canvas: canvas) { result = $0 }
        while !engine.isIdle { RunLoop.main.run(until: Date().addingTimeInterval(0.001)) }
        var delivered = false
        DispatchQueue.main.async { delivered = true }
        while !delivered { RunLoop.main.run(until: Date().addingTimeInterval(0.001)) }
        return result
    }

    static func rgba(_ frame: AssFrame?) -> [UInt8] {
        let (width, height) = frame.map { (Int($0.canvas.width), Int($0.canvas.height)) } ?? (Int(size.width), Int(size.height))
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        pixels.withUnsafeMutableBytes { raw in
            let context = CGContext(data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
            if let frame { context.draw(frame.image, in: CGRect(x: frame.rect.minX, y: CGFloat(height) - frame.rect.maxY, width: frame.rect.width, height: frame.rect.height)) }
        }
        return pixels
    }

    /// The box of the visible pixels; the picture itself also holds the transparent margin libass adds around a shape.
    static func solid(_ frame: AssFrame) -> CGRect {
        let (width, pixels) = (Int(frame.canvas.width), rgba(frame))
        var box = (minX: Int.max, minY: Int.max, maxX: -1, maxY: -1)
        for at in stride(from: 3, to: pixels.count, by: 4) where pixels[at] > 128 {
            let (x, y) = (at / 4 % width, at / 4 / width)
            box = (min(box.minX, x), min(box.minY, y), max(box.maxX, x), max(box.maxY, y))
        }
        return CGRect(x: box.minX, y: box.minY, width: box.maxX - box.minX + 1, height: box.maxY - box.minY + 1)
    }

    static func png(_ pixels: [UInt8]) -> Data {
        var copy = pixels
        let image = copy.withUnsafeMutableBytes { raw -> CGImage in
            CGContext(data: raw.baseAddress, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                      bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!.makeImage()!
        }
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        precondition(CGImageDestinationFinalize(destination))
        return data as Data
    }

    static func decoded(_ data: Data) -> [UInt8] {
        let image = CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithData(data as CFData, nil)!, 0, nil)!
        return rgba(AssFrame(image: image, rect: CGRect(origin: .zero, size: size), canvas: size))
    }

    static func compare(_ name: String, _ frame: AssFrame?) {
        let pixels = rgba(frame)
        let path = "scripts/ass-reference/\(name).png"
        if ProcessInfo.processInfo.environment["UPDATE"] != nil {
            try! FileManager.default.createDirectory(atPath: "scripts/ass-reference", withIntermediateDirectories: true)
            try! png(pixels).write(to: URL(fileURLWithPath: path))
            print("wrote \(path)")
            return
        }
        guard let data = FileManager.default.contents(atPath: path) else { fatalError("no reference \(path); run with UPDATE=1") }
        let reference = decoded(data)
        var different = 0
        for at in stride(from: 0, to: pixels.count, by: 4) where (0..<4).contains(where: { abs(Int(pixels[at + $0]) - Int(reference[at + $0])) > 24 }) { different += 1 }
        precondition(Double(different) / Double(pixels.count / 4) <= 0.01, "\(name): \(different) of \(pixels.count / 4) pixels differ from \(path)")
    }

    static func frames(_ engine: AssEngine) {
        func script(_ events: String) -> AssTrack { AssTrack(engine: engine, script: header + events)! }
        func draw(_ track: AssTrack, at time: Double, canvas: AssCanvas) -> AssFrame? { Self.draw(engine, track, at: time, canvas: canvas) }
        let moving = script("Dialogue: 0,0:00:00.00,0:00:02.00,Default,,0,0,0,,{\\an7\\move(0,10,100,10,0,1000)\\p1}m 0 0 l 20 0 20 20 0 20\n")
        for (name, time, x) in [("move-start", 0.0, 0), ("move-half", 0.5, 50), ("move-end", 1.0, 100), ("move-after", 1.5, 100)] {
            let frame = draw(moving, at: time, canvas: canvas())
            guard let frame else { fatalError("\\move: nothing drawn at \(time) s") }
            let box = solid(frame)
            precondition(abs(Int(box.minX) - x) <= 1 && abs(Int(box.minY) - 10) <= 1 && abs(Int(box.width) - 20) <= 1 && abs(Int(box.height) - 20) <= 1, "\\move at \(time) s: \(box)")
            compare(name, frame)
        }
        precondition(draw(moving, at: 2.5, canvas: canvas()) == nil && draw(moving, at: -1, canvas: canvas()) == nil, "\\move: drawn outside its time")

        let karaoke = script("Dialogue: 0,0:00:00.00,0:00:03.00,Default,,0,0,0,,{\\pos(10,30)\\k50\\p1}m 0 0 l 30 0 30 30 0 30{\\k50\\p1}m 0 0 l 30 0 30 30 0 30{\\k50\\p1}m 0 0 l 30 0 30 30 0 30\n")
        var colours: [(red: Int, white: Int)] = []
        for (name, time) in [("karaoke-0", 0.25), ("karaoke-1", 0.75), ("karaoke-2", 1.25), ("karaoke-3", 1.75)] {
            let frame = draw(karaoke, at: time, canvas: canvas())
            guard let frame else { fatalError("karaoke: nothing drawn at \(time) s") }
            let pixels = rgba(frame)
            var counts = (red: 0, white: 0)
            for at in stride(from: 0, to: pixels.count, by: 4) {
                let (r, g, b, a) = (Int(pixels[at + 2]), Int(pixels[at + 1]), Int(pixels[at]), Int(pixels[at + 3]))
                if a > 200, r > 200, g < 60, b < 60 { counts.red += 1 }
                if a > 200, r > 200, g > 200, b > 200 { counts.white += 1 }
            }
            colours.append(counts)
            compare(name, frame)
        }
        for (counts, expected) in zip(colours, [(1800, 900), (900, 1800), (0, 2700), (0, 2700)]) {
            precondition(abs(counts.red - expected.0) <= 45 && abs(counts.white - expected.1) <= 45, "karaoke: \(counts) instead of \(expected) (waiting syllables red, sung ones white, 900 pixels each)")
        }
        let clipped = script("Dialogue: 0,0:00:00.00,0:00:02.00,Default,,0,0,0,,{\\an7\\pos(0,0)\\clip(0,0,50,45)\\p1}m 0 0 l 100 0 100 90 0 90\n")
        guard let cut = draw(clipped, at: 0.5, canvas: canvas()) else { fatalError("\\clip: nothing drawn") }
        let cutBox = solid(cut)
        precondition(cutBox.maxX <= 51 && cutBox.maxY <= 46 && cutBox.width > 40 && cutBox.height > 40, "\\clip: \(cutBox)")
        compare("clip", cut)
        let half = draw(moving, at: 0.5, canvas: AssCanvas(size: CGSize(width: 320, height: 180), video: size, scale: 1))
        precondition(half.map { solid($0) }.map { abs(Int($0.minX) - 100) <= 2 && abs(Int($0.width) - 40) <= 2 } == true, "a frame twice as large: \(String(describing: half.map { solid($0) }))")
        let text = script("Dialogue: 0,0:00:00.00,0:00:02.00,Default,,0,0,0,,{\\an5\\pos(80,45)\\fs30\\b1}Hello, ASS 字幕 שלום\n")
        precondition((draw(text, at: 0.5, canvas: canvas()).map { solid($0).width } ?? 0) > 20, "text: nothing drawn with the system fonts")
        print("frames: \\move at four times, karaoke at four times, \\clip, size, text: ok")
    }

    // MARK: limits

    static func limits(_ engine: AssEngine) {
        func script(_ events: String) -> AssTrack { AssTrack(engine: engine, script: header + events)! }
        func draw(_ track: AssTrack, at time: Double, canvas: AssCanvas) -> AssFrame? { Self.draw(engine, track, at: time, canvas: canvas) }
        let track = AssTrack(engine: engine, header: Data(header.utf8))!
        let line = Array(("0,0,Default,,0,0,0,,{\\an7\\pos(1,1)}" + String(repeating: "x", count: 1000)).utf8)
        var added = 0
        while !track.isFull, added < 100_000 {
            line.withUnsafeBytes { track.add($0, start: Double(added) * 0.1, duration: 2) }
            added += 1
        }
        precondition(track.isFull && added > 20_000 && added < 30_000, "the event limit stops at \(added) events")
        track.prune(before: 1500)
        precondition(!track.isFull, "pruning events that ended frees the memory")
        track.flush()
        precondition(track.isEmpty && !track.isFull, "flush empties the track")
        line.withUnsafeBytes { track.add($0, start: 0, duration: 1) }
        let big = [UInt8](repeating: 65, count: AssTrack.packetLimit + 1)
        big.withUnsafeBytes { track.add($0, start: 1, duration: 1) }
        precondition(!track.isEmpty, "one normal event is kept")
        track.flush()
        big.withUnsafeBytes { track.add($0, start: 1, duration: 1) }
        precondition(track.isEmpty, "a packet over the limit is skipped")
        for time in [Double.nan, .infinity, -.infinity, 1e300, -1e300] { line.withUnsafeBytes { track.add($0, start: time, duration: 1) } }
        line.withUnsafeBytes { track.add($0, start: 1, duration: .nan) }
        precondition(track.isEmpty, "times that are not numbers are skipped")
        precondition(AssTrack(engine: engine, header: Data(count: AssTrack.headerLimit + 1)) == nil && AssTrack(engine: engine, script: String(repeating: " ", count: SubtitleParser.sizeLimit + 1)) == nil, "headers and scripts over the limit are refused")

        let crowd = script((0..<2000).map { "Dialogue: 0,0:00:00.00,0:00:05.00,Default,,0,0,0,,{\\an7\\pos(\($0 % 150),\($0 % 80))\\blur3\\bord2}Crowd \($0)" }.joined(separator: "\n") + "\n")
        let started = Date()
        precondition(draw(crowd, at: 1, canvas: canvas()) == nil, "more than \(AssEngine.activeLimit) lines at once are not drawn")
        precondition(Date().timeIntervalSince(started) < 3, "a crowd of lines is skipped quickly")
        let few = script((0..<50).map { "Dialogue: 0,0:00:00.00,0:00:05.00,Default,,0,0,0,,{\\an7\\pos(\($0 * 3),\($0))\\p1}m 0 0 l 4 0 4 4 0 4" }.joined(separator: "\n") + "\n")
        precondition(draw(few, at: 1, canvas: canvas()) != nil, "fifty lines at once are drawn")
        let fonts = AssEngine()!
        fonts.addFont(name: "huge.ttf", data: Data(count: AssEngine.fontFileLimit + 1))
        for _ in 0..<5 { fonts.addFont(name: "a.ttf", data: Data(count: 30 << 20)) }
        precondition(fonts.fontBytes == 90 << 20, "fonts stop at the total limit: \(fonts.fontBytes)")
        print("limits: events, packets, times, crowd, fonts: ok")
    }

    // MARK: corpus

    static func corpus() {
        let folder = "scripts/ass-corpus"
        let files = ((try? FileManager.default.contentsOfDirectory(atPath: folder)) ?? []).filter { $0.hasSuffix(".ass") }.sorted()
        precondition(files.count >= 10, "the corpus in \(folder) is missing")
        for file in files { run(["--draw", "\(folder)/\(file)"], what: file) }
        for (number, file) in files.enumerated() { run(["--mutate", "\(folder)/\(file)", String(number + 1)], what: "changes of \(file)") }
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent("pikapik-ass-\(getpid())")
        try! FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporary) }
        var long = header + "Dialogue: 0,0:00:00.00,0:00:09.00,Default,,0,0,0,,"
        long += String(repeating: "{\\t(0,100,", count: 3000) + "x" + String(repeating: ")}", count: 3000)
        var heavy = header
        for number in 0..<60_000 { heavy += "Dialogue: 0,0:00:\(String(format: "%02d", number % 60)).00,0:01:00.00,Default,,0,0,0,,{\\k5\\fscx\(number % 400)\\blur\(number % 20)}a\\Nb\n" }
        for (name, text) in [("nested", long), ("many", heavy), ("empty", ""), ("binary", String(decoding: (0..<4000).map { _ in UInt8.random(in: 0...255) }, as: UTF8.self))] {
            let path = temporary.appendingPathComponent(name + ".ass").path
            try! text.write(toFile: path, atomically: true, encoding: .utf8)
            run(["--draw", path], what: name)
        }
    }

    static func run(_ arguments: [String], what: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        let started = Date()
        try! process.run()
        while process.isRunning, Date().timeIntervalSince(started) < 60 { Thread.sleep(forTimeInterval: 0.05) }
        if process.isRunning {
            process.terminate()
            fatalError("\(what) hangs the renderer for more than 60 s")
        }
        precondition(process.terminationStatus == 0, "\(what) ends the renderer with status \(process.terminationStatus) (\(process.terminationReason == .uncaughtSignal ? "signal" : "exit"))")
    }

    /// Child process: draws a file, or random changes of it (as many as fit in six seconds), at several times and sizes.
    static func child(path: String, mutate: Bool, seed: UInt64 = 0) {
        var random = SplitMix(seed: seed)
        let original = FileManager.default.contents(atPath: path) ?? Data()
        guard let engine = AssEngine() else { exit(2) }
        engine.finishFonts()
        let started = Date()
        for round in 0..<(mutate ? 150 : 1) where Date().timeIntervalSince(started) < 6 {
            var bytes = original
            if mutate, !bytes.isEmpty {
                for _ in 0..<(1 + Int(random.next() % 12)) {
                    let at = Int(random.next() % UInt64(bytes.count))
                    switch random.next() % 4 {
                    case 0: bytes[at] = UInt8(truncatingIfNeeded: random.next())
                    case 1: bytes.remove(at: at)
                    case 2: bytes.insert(contentsOf: Array("\\{}(),&Hkt-9".utf8)[Int(random.next() % 12)...].prefix(1), at: at)
                    default: bytes.replaceSubrange(at..<min(bytes.count, at + 8), with: bytes[max(0, at - 8)..<at])
                    }
                }
            }
            guard let text = SubtitleParser.decode(bytes), let track = AssTrack(engine: engine, script: text) else { continue }
            for time in [0.1, 1, 3.7, 60] as [Double] {
                for scale in [1.0, 3] {
                    _ = draw(engine, track, at: time, canvas: AssCanvas(size: CGSize(width: round % 2 == 0 ? 320 : 97, height: round % 2 == 0 ? 180 : 211), video: size, scale: scale))
                }
            }
        }
        exit(0)
    }
}

struct SplitMix {
    var state: UInt64

    init(seed: UInt64) { state = seed &* 0x9E3779B97F4A7C15 &+ 1 }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}
