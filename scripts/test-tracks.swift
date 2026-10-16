import AppKit
import CoreMedia
import Foundation

@main
enum TestTracks {
    static var failures = 0

    static func check(_ ok: Bool, _ what: String) {
        print((ok ? "ok" : "FAILED") + ": " + what)
        if !ok { failures += 1 }
    }

    struct Picture {
        var width = 800
        var height = 450
        var data: [UInt8]

        func white() -> (count: Int, low: Int, high: Int, centre: Double) {
            var count = 0, low = height, high = -1, sum = 0.0
            for row in 0..<height {
                for column in 0..<width {
                    let at = (row * width + column) * 4
                    if data[at] > 240, data[at + 1] > 240, data[at + 2] > 240 {
                        count += 1
                        low = min(low, height - 1 - row)
                        high = max(high, height - 1 - row)
                        sum += Double(column)
                    }
                }
            }
            return (count, low, high, count == 0 ? 0 : sum / Double(count))
        }

        func dark() -> Int { stride(from: 0, to: data.count, by: 4).filter { data[$0] < 200 }.count }

        func box(_ match: (Int, Int, Int) -> Bool) -> (count: Int, left: Int, right: Int, low: Int, high: Int) {
            var found = (count: 0, left: width, right: -1, low: height, high: -1)
            for row in 0..<height {
                for column in 0..<width {
                    let at = (row * width + column) * 4
                    guard match(Int(data[at]), Int(data[at + 1]), Int(data[at + 2])) else { continue }
                    found = (found.count + 1, min(found.left, column), max(found.right, column), min(found.low, height - 1 - row), max(found.high, height - 1 - row))
                }
            }
            return found
        }
    }

    static let red = { (r: Int, g: Int, b: Int) in r > 170 && g < 90 && b < 90 }
    static let green = { (r: Int, g: Int, b: Int) in g > 170 && r < 90 && b < 90 }

    struct Shape {
        let x, y, width, height: Int
        let ycrcb: [UInt8]
    }

    static func pgs(_ events: [(time: Double, shape: Shape?)], width: Int, height: Int) -> Data {
        var out = [UInt8]()
        func big(_ value: Int, _ count: Int) -> [UInt8] {
            var bytes = [UInt8]()
            for place in 0..<count { bytes.append(UInt8((value >> (8 * (count - 1 - place))) & 0xFF)) }
            return bytes
        }
        func segment(_ time: Double, _ kind: UInt8, _ body: [UInt8]) {
            out += [0x50, 0x47]
            out += big(Int(time * 90000), 4)
            out += big(0, 4)
            out += [kind]
            out += big(body.count, 2)
            out += body
        }
        for (number, event) in events.enumerated() {
            let shape = event.shape
            var composition: [UInt8] = big(width, 2) + big(height, 2)
            composition += [0x10] + big(number + 1, 2)
            composition += [shape == nil ? 0 : 0x80, 0, 0, shape == nil ? 0 : 1]
            var window: [UInt8] = [0]
            if let shape {
                composition += big(0, 2) + [0, 0] + big(shape.x, 2) + big(shape.y, 2)
                window = [1, 0] + big(shape.x, 2) + big(shape.y, 2) + big(shape.width, 2) + big(shape.height, 2)
            }
            segment(event.time, 0x16, composition)
            segment(event.time, 0x17, window)
            if let shape {
                segment(event.time, 0x14, [0, 0, 1] + shape.ycrcb + [255])
                let rows = (0..<shape.height).flatMap { _ in [UInt8](repeating: 1, count: shape.width) + [0, 0] }
                let data = big(shape.width, 2) + big(shape.height, 2) + rows
                segment(event.time, 0x15, big(0, 2) + [0, 0xC0] + big(data.count, 3) + data)
            }
            segment(event.time, 0x80, [])
        }
        return Data(out)
    }

    static func picture(of host: NSView, background: CGFloat, width: Int = 800, height: Int = 450) -> Picture {
        host.window?.displayIfNeeded()
        var picture = Picture(width: width, height: height, data: [UInt8](repeating: 0, count: width * height * 4))
        picture.data.withUnsafeMutableBytes { raw in
            let context = CGContext(data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.setFillColor(gray: background, alpha: 1)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            host.layer?.render(in: context)
        }
        return picture
    }

    static func drawing() {
        let host = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 450))
        host.wantsLayer = true
        let window = NSWindow(contentRect: host.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = host
        let view = SubtitleView(frame: host.bounds)
        host.addSubview(view)
        host.layoutSubtreeIfNeeded()
        check(picture(of: host, background: 0).white().count == 0, "nothing is drawn while no subtitle is shown")
        view.show("Hello, subtitle line")
        let plain = picture(of: host, background: 0).white()
        check(plain.count > 200 && plain.high < 150 && abs(plain.centre - 400) < 40, "the text is white, at the bottom and in the middle")
        host.appearance = NSAppearance(named: .darkAqua)
        let dark = picture(of: host, background: 0).white()
        host.appearance = NSAppearance(named: .aqua)
        let light = picture(of: host, background: 0).white()
        check(plain.count > 0 && dark.count == plain.count && light.count == plain.count, "the text looks the same in the dark and the light theme")
        check(plain.count > 0 && picture(of: host, background: 1).dark() > 100, "on a white picture the shadow still draws the letters")
        view.lift(200)
        let raised = picture(of: host, background: 0).white()
        check(raised.count > 0 && raised.low >= 190, "the text rises above the panel")
        view.lift(0)
        let normal = picture(of: host, background: 0).white()
        view.scale = 2
        let large = picture(of: host, background: 0).white()
        check(normal.count > 0 && large.high - large.low > (normal.high - normal.low) * 3 / 2, "the larger size makes taller text")
        view.scale = 1
        view.show("Hello\nsecond line")
        let two = picture(of: host, background: 0).white()
        check(two.count > 0 && two.high - two.low > (normal.high - normal.low) * 3 / 2, "two lines take two lines of height")
        view.show(nil)
        check(picture(of: host, background: 0).white().count == 0, "the text goes away when the subtitle ends")
    }

    static var windows: [NSWindow] = []

    static func makeHost(width: Int = 800, height: Int = 450) -> (NSView, SubtitleView) {
        let host = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        host.wantsLayer = true
        let window = NSWindow(contentRect: host.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = host
        windows.append(window)
        let view = SubtitleView(frame: host.bounds)
        host.addSubview(view)
        host.layoutSubtreeIfNeeded()
        return (host, view)
    }

    static let assStyle = "Style: Default,Helvetica,20,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2,0,2,10,10,10,1"

    static func assScript(_ lines: [String], style: String = assStyle) -> String {
        "[Script Info]\nPlayResX: 512\nPlayResY: 288\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n\(style)\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n"
            + lines.map { "Dialogue: 0,0:00:00.00,0:00:09.00,Default,,0,0,0,,\($0)\n" }.joined()
    }

    /// Waits until libass has drawn the request; its answer comes on the main queue before the sentinel does.
    static func drawn(_ engine: AssEngine, _ track: AssTrack, at time: Double, canvas: AssCanvas) async -> AssFrame? {
        var result: AssFrame?
        engine.forget()
        engine.render(track, at: time, canvas: canvas) { result = $0 }
        while !engine.isIdle { try? await Task.sleep(for: .milliseconds(1)) }
        var delivered = false
        DispatchQueue.main.async { delivered = true }
        while !delivered { try? await Task.sleep(for: .milliseconds(1)) }
        return result
    }

    @MainActor static func assDrawing() async {
        guard let engine = AssEngine() else { return check(false, "ASS: libass starts") }
        engine.finishFonts()
        let (host, view) = makeHost()
        func shot(_ lines: String..., at time: Double = 1, in view: SubtitleView = view, host: NSView = host, width: Int = 800, height: Int = 450) async -> Picture {
            view.show(ass: await drawn(engine, AssTrack(engine: engine, script: assScript(lines))!, at: time, canvas: view.assCanvas))
            return picture(of: host, background: 0.35, width: width, height: height)
        }
        let whiteBox = { (picture: Picture) in picture.box { $0 > 240 && $1 > 240 && $2 > 240 } }
        let plain = (await shot("Hello world"))
        let white = whiteBox(plain)
        check(white.count > 200 && white.low < 90 && abs((white.left + white.right) / 2 - 400) < 40, "ASS: the default style is white text at the bottom centre")
        let edge = plain.box { $0 < 60 && $1 < 60 && $2 < 60 }.count
        check(edge > 150, "ASS: the style outline draws a dark edge around the letters: \(edge) dark pixels")
        let tinted = (await shot("{\\c&H0000FF&}Hello world"))
        check(tinted.box(red).count > 200 && whiteBox(tinted).count == 0, "ASS: \\c colours the letters red (BGR order)")
        check((await shot("{\\3c&H00FF00&\\bord4}Hello world")).box(green).count > 300, "ASS: \\3c and \\bord paint a green outline")
        let regular = (await shot("{\\bord0}Hello world"))
        check(regular.box { $0 < 20 && $1 < 20 && $2 < 20 }.count == 0, "ASS: \\bord0 removes the outline")
        let (bold, underlined, italic) = (whiteBox((await shot("{\\bord0\\b1}Hello world"))), whiteBox((await shot("{\\bord0\\u1}Hello world"))), whiteBox((await shot("{\\bord0\\i1}Hello world"))))
        let flat = whiteBox(regular)
        check(bold.count > flat.count && underlined.count > flat.count && italic.count != flat.count, "ASS: \\b, \\u and \\i change how the letters look: \(flat.count) / \(bold.count) / \(underlined.count) / \(italic.count)")
        var places: [Int: (count: Int, left: Int, right: Int, low: Int, high: Int)] = [:]
        for place in [1, 3, 5, 7, 9] { places[place] = whiteBox(await shot("{\\an\(place)}Hello world")) }
        check(places[1]!.left < 80 && places[1]!.low < 90 && places[3]!.right > 720 && places[3]!.low < 90, "ASS: \\an1 and \\an3 sit in the bottom corners")
        check(places[7]!.left < 80 && places[7]!.high > 360 && places[9]!.right > 720 && places[9]!.high > 360, "ASS: \\an7 and \\an9 sit in the top corners")
        check(abs((places[5]!.low + places[5]!.high) / 2 - 225) < 30 && abs((places[5]!.left + places[5]!.right) / 2 - 400) < 40, "ASS: \\an5 sits in the middle")
        let (taller, tallView) = makeHost(width: 1600, height: 900)
        let big = whiteBox((await shot("{\\bord0}Hello world", in: tallView, host: taller, width: 1600, height: 900)))
        check(flat.count > 0 && big.high - big.low > (flat.high - flat.low) * 3 / 2, "ASS: the letters grow with the height of the picture (font 20 of 288)")
        let mixed = (await shot("{\\c&H0000FF&}Red {\\c&HFF0000&}Blue"))
        check(mixed.box(red).count > 100 && mixed.box { $2 > 170 && $0 < 90 && $1 < 90 }.count > 100, "ASS: two colours in one line are both drawn")
        let (start, later) = (whiteBox((await shot("{\\an7\\bord0\\move(0,0,100,100,0,1000)}Hello", at: 0.05))), whiteBox((await shot("{\\an7\\bord0\\move(0,0,100,100,0,1000)}Hello", at: 0.95))))
        check(start.count > 50 && later.count > 50 && later.left - start.left > 100 && start.high - later.high > 100, "ASS: \\move carries the text across the picture: \(start) to \(later)")
        let karaoke = [await shot("{\\an5\\bord0\\k100}Sing {\\k100}along", at: 0.1), await shot("{\\an5\\bord0\\k100}Sing {\\k100}along", at: 1.9)]
        check(karaoke[0].box(red).count > 100 && karaoke[0].box(red).count > karaoke[1].box(red).count, "ASS: karaoke paints the words that have not been sung yet in the secondary colour")
        let both = (await shot("{\\an8}Top", "Bottom"))
        check(whiteBox(both).low < 90 && whiteBox(both).high > 360, "ASS: two lines with different places both show")
        view.videoSize = CGSize(width: 400, height: 300)
        host.layoutSubtreeIfNeeded()
        let boxed = whiteBox((await shot("{\\an7}Hello", "{\\an9}Hello")))
        check(boxed.left >= 100 && boxed.right <= 700, "ASS: the text stays on the video, not on the bars beside it: \(boxed.left)...\(boxed.right)")
        view.videoSize = .zero
        view.show(ass: nil)
        check(picture(of: host, background: 0).white().count == 0, "ASS: the picture goes away when the subtitle ends")
    }

    static func pictureDrawing(_ cue: PictureCue, _ later: PictureCue) {
        let (host, view) = makeHost()
        view.videoSize = CGSize(width: 320, height: 180)
        view.show(SubtitleScene(pictures: [cue]))
        let shown = picture(of: host, background: 0.3).box(red)
        check(shown.count > 7000 && abs(shown.left - 250) < 8 && abs(shown.right - 549) < 8 && abs(shown.low - 75) < 8 && abs(shown.high - 149) < 8, "picture subtitle: red box at its place and scale (\(shown))")
        view.videoSize = CGSize(width: 320, height: 240)
        let boxed = picture(of: host, background: 0.3).box(red)
        check(boxed.count > 5000 && abs(boxed.left - 288) < 8 && abs(boxed.right - 512) < 8 && abs(boxed.high - 149) < 8, "picture subtitle: 4:3 video leaves the bars empty and shifts the box in (\(boxed))")
        view.videoSize = CGSize(width: 320, height: 180)
        view.lift(200)
        check(picture(of: host, background: 0.3).box(red).low >= 195, "picture subtitle: rises above the control panel")
        view.lift(0)
        view.show(SubtitleScene(pictures: [later]))
        let next = picture(of: host, background: 0.3)
        check(next.box(red).count == 0 && next.box(green).count > 3000, "picture subtitle: the next line replaces the first")
        view.show(SubtitleScene())
        check(picture(of: host, background: 0.3).box { red($0, $1, $2) || green($0, $1, $2) }.count == 0, "picture subtitle: nothing is left when the line ends")
    }

    static func ffmpeg() -> String? {
        ((ProcessInfo.processInfo.environment["FFMPEG"].map { [$0] } ?? []) + ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg"]).first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    @discardableResult
    static func make(_ ffmpeg: String, _ name: String, in folder: URL, _ arguments: [String]) -> URL {
        let url = folder.appendingPathComponent(name)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpeg)
        process.arguments = ["-hide_banner", "-loglevel", "error", "-y"] + arguments + [url.path]
        try! process.run()
        process.waitUntilExit()
        precondition(process.terminationStatus == 0, "ffmpeg could not make \(name)")
        return url
    }

    static func write(_ text: String, _ name: String, in folder: URL) -> URL {
        let url = folder.appendingPathComponent(name)
        try! text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    final class Found {
        var streams: [SubtitleStream]?
        var cues: [Int32: [SubtitleCue]] = [:]
        var pictures: [Int32: [PictureCue]] = [:]
        var changes = 0
    }

    static func scan(_ url: URL, start: Double = 0, expecting: Int, for seconds: Double = 8, engine: AssEngine? = nil) async -> Found {
        let found = Found()
        let scanner = SubtitleScanner(url: url, start: start, onStreams: { found.streams = $0 }, onCues: { found.cues[$0] = $1 }, onPictures: { found.pictures[$0] = $1 }, engine: engine)
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline, found.streams == nil || found.cues.values.reduce(0, { $0 + $1.count }) + found.pictures.values.reduce(0, { $0 + $1.count }) < expecting { try? await Task.sleep(for: .milliseconds(50)) }
        scanner.cancel()
        return found
    }

    static func watch(_ url: URL, start: Double = 0) -> (Found, SubtitleScanner) {
        let found = Found()
        return (found, SubtitleScanner(url: url, start: start, onStreams: { found.streams = $0 }, onCues: { found.cues[$0] = $1 }, onPictures: { found.pictures[$0] = $1 }))
    }

    static func starts(_ found: Found) -> [Double] { (found.cues.values.first ?? []).map(\.start).sorted() }

    static func waitFor(_ seconds: Double = 10, _ done: () -> Bool) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline, !done() { try? await Task.sleep(for: .milliseconds(50)) }
    }

    static func main() async {
        setvbuf(stdout, nil, _IOLBF, 0)
        _ = NSApplication.shared
        guard let ffmpeg = ffmpeg() else {
            print("skipped: no ffmpeg (set FFMPEG=/path/to/ffmpeg)")
            return
        }
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tracks-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }

        let english = write("1\n00:00:01,000 --> 00:00:03,000\nFirst English line\n\n2\n00:00:04,000 --> 00:00:06,000\nSecond <i>English</i> line\n", "en.srt", in: folder)
        let russian = write("1\n00:00:01,000 --> 00:00:03,000\nПервая русская строка\n\n2\n00:00:04,000 --> 00:00:06,000\nВторая <i>русская</i> строка\n", "ru.srt", in: folder)
        let late = write("1\n00:00:10,000 --> 00:00:12,000\nEarly\n\n2\n00:01:10,000 --> 00:01:12,000\nMiddle\n\n3\n00:01:40,000 --> 00:01:42,000\nLate\n", "late.srt", in: folder)
        let video = ["-f", "lavfi", "-i", "testsrc=size=320x180:rate=25:duration=8"]
        let tone: (Int) -> [String] = { ["-f", "lavfi", "-i", "sine=frequency=\($0):duration=8"] }
        let two = video + tone(440) + tone(880) + ["-i", english.path, "-i", russian.path, "-map", "0:v", "-map", "1:a", "-map", "2:a", "-map", "3", "-map", "4",
                                                   "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac",
                                                   "-metadata:s:a:0", "language=eng", "-metadata:s:a:0", "title=Main mix", "-metadata:s:a:1", "language=rus",
                                                   "-metadata:s:s:0", "language=eng", "-metadata:s:s:1", "language=rus", "-metadata:s:s:1", "title=Full"]
        let tracks = make(ffmpeg, "tracks.mkv", in: folder, two + ["-c:s", "srt"])
        let movText = make(ffmpeg, "movtext.mp4", in: folder, video + tone(440) + ["-i", english.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "mov_text", "-metadata:s:s:0", "language=eng"])
        let ass = make(ffmpeg, "ass.mkv", in: folder, video + tone(440) + ["-i", english.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "ass"])
        let vtt = make(ffmpeg, "vtt.mkv", in: folder, video + tone(440) + ["-i", english.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "webvtt"])
        let plain = make(ffmpeg, "plain.mp4", in: folder, video + tone(440) + ["-map", "0:v", "-map", "1:a", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac"])
        let long = make(ffmpeg, "long.mkv", in: folder, ["-f", "lavfi", "-i", "testsrc=size=160x90:rate=5:duration=120", "-f", "lavfi", "-i", "sine=frequency=440:duration=120", "-i", late.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "srt"])

        var found = await scan(tracks, expecting: 4)
        let first = found.streams ?? []
        check(first.count == 2 && first.allSatisfy { $0.format == .subrip } && first.map(\.language) == ["eng", "rus"] && first[1].title == "Full", "MKV: two text tracks with language and title")
        let (a, b) = (found.cues[first.first?.index ?? -1] ?? [], found.cues[first.last?.index ?? -1] ?? [])
        check(a.count == 2 && a[0].start == 1 && a[0].end == 3 && SubtitleText.plain(a[0].text) == "First English line" && SubtitleText.plain(a[1].text) == "Second English line", "MKV: English cues with exact times and no tags")
        check(b.count == 2 && SubtitleText.plain(b[0].text) == "Первая русская строка" && b[1].start == 4, "MKV: Russian cues")
        check(SubtitleText.spans(a[1].text).contains { $0.italic && $0.text == "English" }, "MKV: italic kept as a style, not as a tag")

        for (name, url, format) in [("mov_text in MP4", movText, SubtitleFormat.movText), ("WebVTT in MKV", vtt, .webvtt)] {
            found = await scan(url, expecting: 2)
            let cues = found.cues.values.first ?? []
            check(found.streams?.count == 1 && found.streams?.first?.format == format && cues.count == 2 && SubtitleText.plain(cues[0].text) == "First English line" && abs(cues[0].start - 1) < 0.01 && abs(cues[1].start - 4) < 0.01 && !cues[1].text.contains("<"), "\(name): \(cues.count) cues, first at \(cues.first?.start ?? -1) s")
        }
        let libass = AssEngine()!
        let sung = Found()
        let sungScanner = SubtitleScanner(url: ass, start: 0, onStreams: { sung.streams = $0 }, onCues: { _, _ in }, engine: libass, onAss: { _ in sung.changes += 1 })
        await waitFor { sung.changes > 0 }
        sungScanner.cancel()
        let sungTrack = sung.streams?.first?.ass
        check(sung.streams?.count == 1 && sung.streams?.first?.format == .ass && sung.streams?.first?.language == nil && sungTrack?.isEmpty == false && sung.cues.isEmpty, "ASS in MKV: the track keeps its events for libass, not as plain cues")
        if let sungTrack {
            let screen = AssCanvas(size: CGSize(width: 640, height: 360), video: CGSize(width: 320, height: 180), scale: 1)
            let first = await drawn(libass, sungTrack, at: 1.5, canvas: screen)
            let between = await drawn(libass, sungTrack, at: 3.5, canvas: screen)
            let second = await drawn(libass, sungTrack, at: 4.5, canvas: screen)
            check(first != nil && between == nil && second != nil && first.map { $0.rect.midY > 180 } == true, "ASS in MKV: libass draws the line at 1.5 s and 4.5 s, nothing between, at the bottom")
        }
        let fontFile = ["/System/Library/Fonts/Supplemental/Arial.ttf", "/System/Library/Fonts/Supplemental/Courier New.ttf", "/System/Library/Fonts/Supplemental/Times New Roman.ttf"].first { FileManager.default.fileExists(atPath: $0) }
        if let fontFile {
            let withFont = make(ffmpeg, "ass-font.mkv", in: folder, video + tone(440) + ["-i", english.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "ass", "-attach", fontFile, "-metadata:s:t:0", "mimetype=application/x-truetype-font"])
            let fonts = AssEngine()!
            let carried = await scan(withFont, expecting: 0, for: 4, engine: fonts)
            await waitFor { fonts.fontBytes > 0 }
            check(carried.streams?.count == 1 && fonts.fontBytes == (try? Data(contentsOf: URL(fileURLWithPath: fontFile)).count), "ASS in MKV: the font attached to the file goes to libass (\(fonts.fontBytes) bytes)")
        } else {
            check(false, "no system font to attach to the test file")
        }
        found = await scan(plain, expecting: 1, for: 2)
        check(found.streams?.isEmpty == true && found.cues.isEmpty, "a file without subtitles finds none")
        let (middle, middleScanner) = watch(long, start: 90)
        await waitFor { starts(middle) == [70, 100] }
        check(starts(middle) == [70, 100], "reading starts half a minute before the position: \(starts(middle))")
        middleScanner.cover(5)
        await waitFor { starts(middle) == [10, 70, 100] }
        check(starts(middle) == [10, 70, 100], "moving the position far away reads there, every cue once: \(starts(middle))")
        middleScanner.cancel()

        let far = write("1\n00:00:10,000 --> 00:00:12,000\nStart\n\n2\n00:11:40,000 --> 00:11:42,000\nAfter ten minutes\n\n3\n00:23:20,000 --> 00:23:22,000\nNear the end\n", "far.srt", in: folder)
        let hour = make(ffmpeg, "hour.mkv", in: folder, ["-f", "lavfi", "-i", "testsrc=size=160x90:rate=5:duration=1500", "-f", "lavfi", "-i", "sine=frequency=440:duration=1500", "-i", far.path, "-map", "0:v", "-map", "1:a", "-map", "2", "-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p", "-c:a", "aac", "-c:s", "srt"])
        let (ahead, aheadScanner) = watch(hour)
        await waitFor { starts(ahead) == [10] }
        try? await Task.sleep(for: .seconds(1.5))
        check(starts(ahead) == [10], "a long film is read only ten minutes ahead, not to the end: \(starts(ahead))")
        aheadScanner.cover(580)
        await waitFor { starts(ahead) == [10, 700] }
        check(starts(ahead) == [10, 700], "coming close to the end of the read part reads the next ten minutes: \(starts(ahead))")
        aheadScanner.cover(1390)
        await waitFor { starts(ahead) == [10, 700, 1400] }
        check(starts(ahead) == [10, 700, 1400], "a jump to the end of the film reads there: \(starts(ahead))")
        aheadScanner.cancel()
        check([AV_CODEC_ID_HDMV_PGS_SUBTITLE, AV_CODEC_ID_DVD_SUBTITLE, AV_CODEC_ID_DVB_SUBTITLE].allSatisfy { SubtitleFormat($0) == .picture } && SubtitleFormat(AV_CODEC_ID_DVD_SUBTITLE) != nil && SubtitleFormat(AV_CODEC_ID_DVB_SUBTITLE) != nil, "picture subtitles (PGS, VobSub, DVB) are recognised and can be decoded")
        check(SubtitleFormat(AV_CODEC_ID_DVB_TELETEXT) == nil && SubtitleFormat(AV_CODEC_ID_EIA_608) == nil, "other subtitle kinds (teletext, closed captions) stay marked as not shown")

        let shapes: [(time: Double, shape: Shape?)] = [(0, Shape(x: 100, y: 120, width: 120, height: 30, ycrcb: [63, 240, 102])), (2, nil), (3, Shape(x: 30, y: 20, width: 80, height: 24, ycrcb: [173, 26, 42])), (4.5, nil)]
        let sup = folder.appendingPathComponent("lines.sup")
        try! pgs(shapes, width: 320, height: 180).write(to: sup)
        let encode = ["-c:v", "libx264", "-preset", "ultrafast", "-pix_fmt", "yuv420p"]
        let pgsFile = make(ffmpeg, "pgs.mkv", in: folder, video + ["-i", sup.path, "-map", "0:v", "-map", "1:s"] + encode + ["-c:s", "copy"])
        let vobFile = make(ffmpeg, "vob.mkv", in: folder, video + ["-i", sup.path, "-map", "0:v", "-map", "1:s"] + encode + ["-c:s", "dvdsub"])
        let dvbFile = make(ffmpeg, "dvb.ts", in: folder, video + ["-i", sup.path, "-map", "0:v", "-map", "1:s"] + encode + ["-c:s", "dvbsub", "-f", "mpegts"])
        var pictureCues: [PictureCue] = []
        for (name, url, expecting) in [("PGS in MKV", pgsFile, 2), ("VobSub in MKV", vobFile, 2), ("DVB in MPEG-TS", dvbFile, 1)] {
            found = await scan(url, expecting: expecting)
            let cues = (found.pictures.values.first ?? []).sorted { $0.start < $1.start }
            check(found.streams?.count == 1 && found.streams?.first?.format == .picture && found.cues.isEmpty, "\(name): one picture track, no text cues")
            check(cues.count >= expecting && abs(cues[0].start) < 0.05 && cues[0].end > cues[0].start + 0.5, "\(name): the first line starts at 0 s and lasts: \(cues.map { "\($0.start)-\($0.end)" })")
            let bitmap = cues.first?.bitmaps.first
            let middle = bitmap.map { $0.palette[Int($0.indices[($0.height / 2) * $0.width + $0.width / 2])] } ?? 0
            check(bitmap.map { abs($0.x - 100) <= 4 && abs($0.y - 120) <= 4 && abs($0.width - 120) <= 6 && abs($0.height - 30) <= 4 } == true && cues.first?.canvas == CGSize(width: 320, height: 180), "\(name): the box keeps its place and size: \(bitmap.map { "\($0.x),\($0.y) \($0.width)x\($0.height)" } ?? "none") on \(cues.first?.canvas ?? .zero)")
            check(middle >> 24 > 200 && red(Int(middle >> 16 & 0xFF), Int(middle >> 8 & 0xFF), Int(middle & 0xFF)), "\(name): the box is red and opaque (\(String(middle, radix: 16)))")
            check(cues.first?.images.count == 1 && cues.first?.images.first?.image.width == bitmap?.width, "\(name): the bitmap turns into one picture")
            if name.hasPrefix("PGS") {
                check(abs(cues[0].end - 2) < 0.05 && abs(cues[1].start - 3) < 0.05 && abs(cues[1].end - 4.5) < 0.05, "\(name): the empty set after a line ends it on time")
                pictureCues = cues
            }
        }
        pictureDrawing(pictureCues[0], pictureCues[1])

        let crowd = (0..<60).map { (time: Double($0) / 2, shape: Shape(x: 0, y: 0, width: 320, height: 180, ycrcb: [63, 240, 102])) as (time: Double, shape: Shape?) }
        let crowdFile = folder.appendingPathComponent("crowd.sup")
        try! pgs(crowd, width: 320, height: 180).write(to: crowdFile)
        let heavy = make(ffmpeg, "heavy.mkv", in: folder, video + ["-i", crowdFile.path, "-map", "0:v", "-map", "1:s"] + encode + ["-c:s", "copy"])
        let kept = Found()
        let limited = SubtitleScanner(url: heavy, start: 0, onStreams: { kept.streams = $0 }, onCues: { _, _ in }, onPictures: { kept.pictures[$0] = $1 }, pictureBudget: 1 << 20)
        await waitFor { (kept.pictures.values.first?.last?.start ?? 0) > 29 }
        limited.cancel()
        let held = kept.pictures.values.first ?? []
        check(held.count > 5 && held.count < 30 && held.reduce(0, { $0 + $1.byteSize }) <= (1 << 20) + 60_000 && (held.last?.start ?? 0) > 29, "many big pictures stay under the memory limit: \(held.count) kept of 60, \(held.reduce(0) { $0 + $1.byteSize } / 1000) KB")

        var damaged = 0
        for url in [tracks, movText, ass, long] {
            let data = try! Data(contentsOf: url)
            var variants = [Data(data.prefix(data.count * 4 / 10)), Data(data.prefix(300)), Data(), Data((0..<4096).map { _ in UInt8.random(in: 0...255) })]
            for round in 0..<3 {
                var hit = data
                let at = data.count / 4 * (round + 1)
                hit.replaceSubrange(at..<min(data.count, at + 4000), with: Data((0..<4000).map { _ in UInt8.random(in: 0...255) }))
                variants.append(hit)
            }
            for bytes in variants {
                let broken = folder.appendingPathComponent("broken-" + url.lastPathComponent)
                try! bytes.write(to: broken)
                damaged += 1
                _ = await scan(broken, expecting: .max, for: 1, engine: libass)
            }
        }
        _ = await scan(folder.appendingPathComponent("missing.mkv"), expecting: 1, for: 1)
        check(true, "\(damaged) damaged files and a missing one scanned without a crash or a hang")

        guard let engine = try? Engine(tracks) else {
            check(false, "tracks.mkv did not open")
            exit(1)
        }
        let audio = engine.audioTracks
        check(audio.count == 2 && audio.map(\.language) == ["eng", "rus"] && audio[0].title == "Main mix" && engine.audioTrack === audio[0], "the player lists both audio tracks and plays the first")
        engine.volume = 0
        engine.muted = true
        engine.seek(to: .zero, rate: 1)
        try? await Task.sleep(for: .seconds(1.5))
        let (before, wall) = (engine.synchronizer.currentTime().seconds, Date())
        engine.selectAudio(audio[1])
        check(engine.audioTrack === audio[1], "the choice shows at once")
        try? await Task.sleep(for: .seconds(1.2))
        let jump = engine.synchronizer.currentTime().seconds - before - Date().timeIntervalSince(wall)
        check(abs(jump) < 0.25 && !engine.failed, "switching audio on the fly does not move the time (off by \(String(format: "%.3f", jump)) s)")
        let deadline = Date().addingTimeInterval(8)
        while engine.finished == nil, Date() < deadline { try? await Task.sleep(for: .milliseconds(50)) }
        check(engine.finished != nil && !engine.failed, "the second track plays to the end")

        let descriptor = open(tracks.path, O_RDONLY)
        defer { close(descriptor) }
        if let demuxer = try? Demuxer(name: "tracks.mkv", size: lseek(descriptor, 0, SEEK_END), read: { buffer, count, offset in
            let read = pread(descriptor, buffer, Int(count), offset)
            return read < 0 ? -EIO : read == 0 ? PikaErrorEOF : Int32(read)
        }) {
            let pair = demuxer.tracks.filter { $0.format.mediaType == kCMMediaType_Audio }
            demuxer.select(pair[1], replacing: pair[0])
            var packet = (try? demuxer.locate(pair[1], pair[1].ticks(CMTime(seconds: 2, preferredTimescale: 90000)))) ?? nil
            let start = packet.map { pair[1].time($0.pts).seconds } ?? -1
            var count = 0, last = 0.0, built = true
            while let current = packet {
                built = built && ((try? demuxer.sampleBuffer([current], pair[1])) != nil)
                last = pair[1].time(current.pts + current.duration).seconds
                count += 1
                packet = (try? demuxer.next(current, pair[1])) ?? nil
                demuxer.forget(before: current, pair[1])
            }
            check(abs(start - 2) < 0.05 && abs(last - 8) < 0.1 && count > 100 && built, "the demuxer gives the second track from 2 s to the end: \(count) packets, \(String(format: "%.2f", start))...\(String(format: "%.2f", last)) s")
        } else {
            check(false, "the demuxer did not open tracks.mkv")
        }

        engine.seek(to: CMTime(seconds: 2, preferredTimescale: 90000), rate: 0)
        try? await Task.sleep(for: .seconds(0.5))
        let paused = engine.synchronizer.currentTime().seconds
        engine.selectAudio(audio[0])
        try? await Task.sleep(for: .seconds(0.6))
        check(abs(engine.synchronizer.currentTime().seconds - paused) < 0.02 && engine.synchronizer.rate == 0 && engine.audioTrack === audio[0], "on pause the switch leaves the place and the pause alone")

        engine.seek(to: CMTime(seconds: 1, preferredTimescale: 90000), rate: 1)
        for round in 0..<40 {
            engine.selectAudio(audio[round % 2])
            if round % 5 == 0 { engine.seek(to: CMTime(seconds: Double(round % 7), preferredTimescale: 90000), rate: 1) }
            try? await Task.sleep(for: .milliseconds(Int.random(in: 0...120)))
        }
        try? await Task.sleep(for: .seconds(0.5))
        check(!engine.failed && engine.synchronizer.currentTime().seconds.isFinite, "40 quick switches with seeks in between: still playing")
        engine.stop()

        guard let single = try? Engine(plain) else {
            check(false, "plain.mp4 did not open")
            exit(1)
        }
        check(single.audioTracks.count == 1 && single.audioTrack === single.audioTracks[0], "a file with one audio track lists just that one")
        single.selectAudio(single.audioTracks[0])
        single.stop()

        let sidecar = write("1\n00:00:02,000 --> 00:00:03,000\nSide file\n", "tracks.srt", in: folder)
        let other = write("1\n00:00:02,000 --> 00:00:03,000\nOther\n", "another.srt", in: folder)
        let named = write("1\n00:00:02,000 --> 00:00:03,000\nNamed\n", "tracks.ru.srt", in: folder)
        let neighbours = [sidecar, other, named, tracks]
        let subtitles = Subtitles()
        var now = 1.5
        subtitles.position = { now }
        func settle(_ done: @escaping () -> Bool) async {
            let limit = Date().addingTimeInterval(8)
            while !done(), Date() < limit { try? await Task.sleep(for: .milliseconds(50)) }
        }

        subtitles.open(tracks, resume: 0, saved: "", delay: 0, audioLanguage: nil, neighbours: neighbours)
        await settle { subtitles.tracks.count == 4 && subtitles.selected != nil }
        check(subtitles.tracks.map(\.id).sorted() == ["e3", "e4", "f:tracks.ru.srt", "f:tracks.srt"], "side files with the video's name are found, other names are not: \(subtitles.tracks.map(\.id))")
        check(subtitles.selected == "f:tracks.ru.srt" || subtitles.selected == "f:tracks.srt", "a side file is chosen by itself: \(subtitles.selected ?? "none")")
        subtitles.choose("e3")
        await settle { subtitles.view.shown != nil }
        check(subtitles.view.shown == "First English line" && subtitles.chosen, "an embedded track shows its line at 1.5 s")
        now = 3.5
        subtitles.refresh()
        check(subtitles.view.shown == nil, "no line between two cues")
        subtitles.shift(by: 0.5)
        check(subtitles.delay == 0.5 && subtitles.view.shown?.contains("0.5") == true || subtitles.view.shown?.contains("0,5") == true, "a delay change tells its new value on the picture: \(subtitles.view.shown ?? "nothing")")
        try? await Task.sleep(for: .seconds(1.4))
        now = 3.4
        subtitles.refresh()
        check(subtitles.view.shown == "First English line", "with +0.5 s the first line is still up at 3.4 s")
        subtitles.shift(by: -0.5)
        try? await Task.sleep(for: .seconds(1.4))
        check(subtitles.delay == 0 && subtitles.view.shown == nil, "back to 0 the line is gone at 3.4 s")
        subtitles.choose(nil)
        now = 1.5
        subtitles.refresh()
        check(subtitles.view.shown == nil && subtitles.selected == nil, "Off shows nothing")
        subtitles.cycle()
        check(subtitles.selected == subtitles.tracks.first?.id, "the key goes to the first track after Off")
        subtitles.cycle()
        subtitles.cycle()
        subtitles.cycle()
        subtitles.cycle()
        check(subtitles.selected == nil, "after the last track the key goes back to Off")
        let size = subtitles.scale
        subtitles.resize(by: 0.1)
        subtitles.resize(by: 10)
        check(subtitles.scale == 3, "the size stops at 300 %")
        subtitles.resize(by: -10)
        check(subtitles.scale == 0.5, "the size stops at 50 %")
        subtitles.resize(by: size - 0.5)
        try? await Task.sleep(for: .seconds(1.4))
        subtitles.close()
        check(subtitles.tracks.isEmpty && subtitles.view.shown == nil, "closing the video clears the subtitles")

        subtitles.open(tracks, resume: 0, saved: "off", delay: 0, audioLanguage: nil, neighbours: neighbours)
        await settle { subtitles.tracks.count == 4 }
        try? await Task.sleep(for: .milliseconds(200))
        check(subtitles.selected == nil && !subtitles.chosen, "a remembered Off stays off")
        subtitles.close()
        subtitles.open(tracks, resume: 0, saved: "e4", delay: 0, audioLanguage: nil, neighbours: nil)
        await settle { subtitles.selected != nil }
        check(subtitles.selected == "e4", "a remembered track is chosen again: \(subtitles.selected ?? "none")")
        subtitles.close()
        subtitles.open(tracks, resume: 0, saved: "e4", delay: 0.4, audioLanguage: nil, neighbours: nil)
        check(subtitles.delay == 0.4, "a remembered delay is applied")
        subtitles.close()
        check(subtitles.delay == 0, "closing the video forgets the delay")

        let notSubtitles = folder.appendingPathComponent("junk.srt")
        try! Data((0..<5000).map { _ in UInt8.random(in: 0...255) }).write(to: notSubtitles)
        var refused = false
        subtitles.open(plain, resume: 0, saved: "", delay: 0, audioLanguage: nil, neighbours: [])
        subtitles.load(notSubtitles, select: true, failed: { refused = true })
        await settle { refused }
        check(refused && subtitles.tracks.isEmpty, "a file that is not subtitles is refused and not listed")
        subtitles.close()

        subtitles.open(pgsFile, resume: 0, saved: "", delay: 0, audioLanguage: nil, neighbours: nil)
        await settle { subtitles.tracks.count == 1 }
        let pictureTrack = subtitles.tracks.first
        check(pictureTrack?.available == true && pictureTrack?.title.contains("can’t") == false, "a picture track is in the list and can be chosen: \(pictureTrack?.title ?? "none")")
        subtitles.choose(pictureTrack?.id)
        now = 1
        await settle { !subtitles.view.scene.pictures.isEmpty }
        check(subtitles.view.scene.pictures.count == 1 && subtitles.view.ass == nil, "a picture track shows its picture at 1 s")
        now = 2.5
        subtitles.refresh()
        check(subtitles.view.scene.pictures.isEmpty, "between two pictures nothing shows")
        now = 3.5
        subtitles.refresh()
        check(subtitles.view.scene.pictures.count == 1 && subtitles.view.scene.pictures[0].start == 3, "the second picture shows at 3.5 s")
        check(subtitles.ticking, "while the video plays the subtitle clock runs")
        subtitles.playing = { false }
        subtitles.refresh()
        check(!subtitles.ticking, "on pause the subtitle clock stops")
        now = 1
        subtitles.refresh()
        check(subtitles.view.scene.pictures.count == 1 && subtitles.view.scene.pictures[0].start == 0 && !subtitles.ticking, "on pause a seek changes the picture once, and the clock stays off")
        subtitles.announce("Subtitles: test")
        check(subtitles.ticking && subtitles.view.shown == "Subtitles: test", "on pause a message still shows")
        await settle { subtitles.view.shown == nil && !subtitles.ticking }
        check(!subtitles.ticking && subtitles.view.shown == nil && subtitles.view.scene.pictures.count == 1, "after the message the clock stops again and the picture is back")
        subtitles.playing = { true }
        subtitles.refresh()
        check(subtitles.ticking, "on play the clock runs again")
        subtitles.close()
        check(!subtitles.ticking, "closing the video stops the clock")

        drawing()
        subtitles.view.frame = NSRect(x: 0, y: 0, width: 800, height: 450)
        subtitles.open(ass, resume: 0, saved: "", delay: 0, audioLanguage: nil, neighbours: nil)
        await settle { subtitles.tracks.count == 1 }
        subtitles.choose(subtitles.tracks.first?.id)
        now = 1.5
        subtitles.refresh()
        await settle { subtitles.view.ass != nil }
        check(subtitles.view.ass != nil && subtitles.view.shown == nil && subtitles.ticking, "an ASS track shows libass's picture at 1.5 s and the clock runs for animation: picture \(subtitles.view.ass != nil), text \(subtitles.view.shown ?? "none"), clock \(subtitles.ticking), tracks \(subtitles.tracks.map(\.id)), chosen \(subtitles.selected ?? "none")")
        now = 3.5
        subtitles.refresh()
        await settle { subtitles.view.ass == nil }
        check(subtitles.view.ass == nil, "between two ASS lines nothing shows")
        subtitles.playing = { false }
        now = 4.5
        subtitles.refresh()
        await settle { subtitles.view.ass != nil }
        check(subtitles.view.ass != nil && !subtitles.ticking, "on pause a seek draws the ASS line once, and the clock stays off")
        subtitles.playing = { true }
        subtitles.close()
        check(subtitles.view.ass == nil && subtitles.tracks.isEmpty, "closing the video clears the ASS picture")
        let sideScript = write(assScript(["{\\an8\\k50}Side script"]), "side.ass", in: folder)
        subtitles.open(plain, resume: 0, saved: "", delay: 0, audioLanguage: nil, neighbours: [])
        subtitles.load(sideScript, select: true, failed: {})
        now = 1
        await settle { subtitles.view.ass != nil }
        check(subtitles.tracks.count == 1 && subtitles.view.ass != nil, "an .ass file opened from the menu is drawn by libass")
        subtitles.close()

        await assDrawing()

        print(failures == 0 ? "all track checks passed" : "\(failures) track checks FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
