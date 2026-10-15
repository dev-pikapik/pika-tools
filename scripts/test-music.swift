import AVFoundation
import Foundation

@main
enum TestMusic {
    static var failures = 0

    static func check(_ ok: Bool, _ what: String) {
        print((ok ? "ok" : "FAILED") + ": " + what)
        if !ok { failures += 1 }
    }

    static func ffmpeg() -> String? {
        ((ProcessInfo.processInfo.environment["FFMPEG"].map { [$0] } ?? []) + ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg"]).first { FileManager.default.isExecutableFile(atPath: $0) }
    }

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

    static func play(_ engine: Engine, for seconds: Double) async -> Double {
        engine.volume = 0
        engine.muted = true
        engine.seek(to: .zero, rate: 1)
        try? await Task.sleep(for: .seconds(seconds))
        return engine.synchronizer.currentTime().seconds
    }

    static func main() async {
        setvbuf(stdout, nil, _IOLBF, 0)
        guard let ffmpeg = ffmpeg() else {
            print("skipped: no ffmpeg (set FFMPEG=/path/to/ffmpeg)")
            return
        }
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pika-music-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }

        let picture = make(ffmpeg, "cover.jpg", in: folder, ["-f", "lavfi", "-i", "color=c=0xe94560:s=64x64", "-frames:v", "1"])
        let (title, artist, album) = ("Тест — 音楽 🎵 Ünïcode", "Артист Ω", "Альбом №1")
        let tags = ["-metadata", "title=\(title)", "-metadata", "artist=\(artist)", "-metadata", "album=\(album)"]
        let sine = ["-f", "lavfi", "-i", "sine=frequency=440:duration=2:sample_rate=44100"]
        let covered = sine + ["-i", picture.path, "-map", "0:a", "-map", "1:v", "-c:v", "copy", "-disposition:v:0", "attached_pic"]
        let samples: [(name: String, arguments: [String], tagged: Bool, covered: Bool)] = [
            ("tagged.mp3", covered + ["-c:a", "libmp3lame", "-q:a", "5", "-id3v2_version", "3"] + tags, true, true),
            ("plain.mp3", sine + ["-c:a", "libmp3lame", "-q:a", "5"], false, false),
            ("plain.aac", sine + ["-c:a", "aac", "-b:a", "96k"], false, false),
            ("tagged.m4a", covered + ["-c:a", "aac", "-b:a", "96k"] + tags, true, true),
            ("alac.m4a", sine + ["-c:a", "alac"] + tags, true, false),
            ("tagged.flac", covered + ["-c:a", "flac"] + tags, true, true),
            ("24bit.flac", sine + ["-c:a", "flac", "-sample_fmt", "s32", "-bits_per_raw_sample", "24"], false, false),
            ("tagged.wav", sine + ["-c:a", "pcm_s16le"] + tags, true, false),
            ("96k.wav", ["-f", "lavfi", "-i", "sine=frequency=523:duration=2:sample_rate=96000", "-c:a", "pcm_s24le"], false, false),
            ("plain.aiff", sine + ["-c:a", "pcm_s16be"], false, false),
            ("alac.caf", sine + ["-c:a", "alac"], false, false),
            ("tagged.ogg", sine + ["-ac", "2", "-c:a", "vorbis", "-strict", "-2"] + tags, true, false),
            ("tagged.opus", sine + ["-c:a", "libopus", "-b:a", "96k"] + tags, true, false),
            ("tagged.wma", sine + ["-c:a", "wmav2"] + tags, true, false),
        ]

        var files: [URL] = []
        for sample in samples {
            let url = make(ffmpeg, sample.name, in: folder, sample.arguments)
            files.append(url)
            do {
                let engine = try Engine(url)
                let found = engine.tags()
                let now = await play(engine, for: 1.5)
                let ok = !engine.hasVideo && engine.hasAudio && abs(engine.duration.seconds - 2) < 0.4 && now > 0.5 && !engine.failed
                check(ok, "\(sample.name) plays as a song: \(String(format: "%.1f", engine.duration.seconds)) s, reached \(String(format: "%.1f", now)) s")
                check(sample.tagged ? found.title == title && found.artist == artist && found.album == album : found.title == nil && found.artist == nil && found.album == nil, "\(sample.name) tags: \(found.title ?? "-") | \(found.artist ?? "-") | \(found.album ?? "-")")
                check(sample.covered ? (found.cover?.count ?? 0) > 100 : found.cover == nil, "\(sample.name) cover: \(found.cover?.count ?? 0) bytes")
                engine.stop()
            } catch {
                check(false, "\(sample.name) did not open: \(error)")
            }
        }

        var damaged = 0, refused = 0
        for url in files {
            let data = try! Data(contentsOf: url)
            var variants = [Data(data.prefix(data.count * 4 / 10)), Data(data.prefix(300)), Data(), Data((0..<4096).map { _ in UInt8.random(in: 0...255) })]
            var hit = data
            hit.replaceSubrange(data.count / 2..<min(data.count, data.count / 2 + 400), with: Data((0..<400).map { _ in UInt8.random(in: 0...255) }))
            variants.append(hit)
            for bytes in variants {
                let broken = folder.appendingPathComponent("broken-" + url.lastPathComponent)
                try! bytes.write(to: broken)
                damaged += 1
                do {
                    let engine = try Engine(broken)
                    _ = engine.tags()
                    _ = await play(engine, for: 0.3)
                    engine.stop()
                } catch {
                    refused += 1
                }
            }
        }
        check(true, "\(damaged) damaged copies (cut, empty, random, hit in the middle): \(refused) refused, \(damaged - refused) played what they could, none crashed")

        let notMusic = folder.appendingPathComponent("notes.mp3")
        try! Data("not a song at all".utf8).write(to: notMusic)
        check((try? Engine(notMusic)) == nil, "a text file named .mp3 is refused")

        print(failures == 0 ? "all music checks passed" : "\(failures) music checks FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
