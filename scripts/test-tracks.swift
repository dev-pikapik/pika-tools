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
    }

    static func picture(of host: NSView, background: CGFloat) -> Picture {
        host.window?.displayIfNeeded()
        var picture = Picture(data: [UInt8](repeating: 0, count: 800 * 450 * 4))
        picture.data.withUnsafeMutableBytes { raw in
            let context = CGContext(data: raw.baseAddress, width: 800, height: 450, bitsPerComponent: 8, bytesPerRow: 800 * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.setFillColor(gray: background, alpha: 1)
            context.fill(CGRect(x: 0, y: 0, width: 800, height: 450))
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
    }

    static func scan(_ url: URL, start: Double = 0, expecting: Int, for seconds: Double = 8) async -> Found {
        let found = Found()
        let scanner = SubtitleScanner(url: url, start: start, onStreams: { found.streams = $0 }, onCues: { found.cues[$0] = $1 })
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline, found.streams == nil || found.cues.values.reduce(0, { $0 + $1.count }) < expecting { try? await Task.sleep(for: .milliseconds(50)) }
        scanner.cancel()
        return found
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

        for (name, url, format) in [("mov_text in MP4", movText, SubtitleFormat.movText), ("ASS in MKV", ass, .ass), ("WebVTT in MKV", vtt, .webvtt)] {
            found = await scan(url, expecting: 2)
            let cues = found.cues.values.first ?? []
            check(found.streams?.count == 1 && found.streams?.first?.format == format && cues.count == 2 && SubtitleText.plain(cues[0].text) == "First English line" && abs(cues[0].start - 1) < 0.01 && abs(cues[1].start - 4) < 0.01 && !cues[1].text.contains("<"), "\(name): \(cues.count) cues, first at \(cues.first?.start ?? -1) s")
        }
        found = await scan(plain, expecting: 1, for: 2)
        check(found.streams?.isEmpty == true && found.cues.isEmpty, "a file without subtitles finds none")
        found = await scan(long, start: 90, expecting: 3)
        let all = found.cues.values.first ?? []
        check(all.count == 3 && all.map(\.start) == [10, 70, 100], "a long file read from the middle first still gives every cue once: \(all.map(\.start))")
        check(SubtitleFormat(AV_CODEC_ID_HDMV_PGS_SUBTITLE) == nil && SubtitleFormat(AV_CODEC_ID_DVD_SUBTITLE) == nil && SubtitleFormat(AV_CODEC_ID_DVB_SUBTITLE) == nil, "picture subtitles (PGS, VobSub, DVB) are recognised as not supported")

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
                _ = await scan(broken, expecting: .max, for: 1)
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

        subtitles.open(tracks, resume: 0, saved: "", audioLanguage: nil, neighbours: neighbours)
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

        subtitles.open(tracks, resume: 0, saved: "off", audioLanguage: nil, neighbours: neighbours)
        await settle { subtitles.tracks.count == 4 }
        try? await Task.sleep(for: .milliseconds(200))
        check(subtitles.selected == nil && !subtitles.chosen, "a remembered Off stays off")
        subtitles.close()
        subtitles.open(tracks, resume: 0, saved: "e4", audioLanguage: nil, neighbours: nil)
        await settle { subtitles.selected != nil }
        check(subtitles.selected == "e4", "a remembered track is chosen again: \(subtitles.selected ?? "none")")
        subtitles.close()

        let notSubtitles = folder.appendingPathComponent("junk.srt")
        try! Data((0..<5000).map { _ in UInt8.random(in: 0...255) }).write(to: notSubtitles)
        var refused = false
        subtitles.open(plain, resume: 0, saved: "", audioLanguage: nil, neighbours: [])
        subtitles.load(notSubtitles, select: true, failed: { refused = true })
        await settle { refused }
        check(refused && subtitles.tracks.isEmpty, "a file that is not subtitles is refused and not listed")
        subtitles.close()

        drawing()

        print(failures == 0 ? "all track checks passed" : "\(failures) track checks FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
