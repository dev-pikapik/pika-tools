import AVFoundation
import Foundation

@main
enum TestPlayerAirplayMedia {
    static var failures = 0
    static var tool = ""
    static var encoders = ""
    static let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pikapik-airplay-media-\(getpid())")

    static func check(_ ok: Bool, _ what: String) {
        print((ok ? "ok" : "FAILED") + ": " + what)
        if !ok { failures += 1 }
    }

    static func run(_ arguments: [String]) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return nil }
        DispatchQueue.global().asyncAfter(deadline: .now() + 240) { if process.isRunning { process.terminate() } }
        let text = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        process.waitUntilExit()
        return process.terminationStatus == 0 ? text : nil
    }

    static func make(_ name: String, _ arguments: [String]) -> URL? {
        let url = folder.appendingPathComponent(name)
        let made = run(["-hide_banner", "-loglevel", "error", "-y"] + arguments + [url.path]) != nil
        check(made, "ffmpeg makes \(name)")
        return made ? url : nil
    }

    static func can(_ encoder: String) -> Bool {
        let has = encoders.contains(" \(encoder) ")
        if !has { print("skipped: this ffmpeg has no \(encoder) encoder") }
        return has
    }

    static func canWrite(_ codec: AVVideoCodecType) -> Bool {
        guard let writer = try? AVAssetWriter(url: folder.appendingPathComponent("probe.mov"), fileType: .mov),
              writer.canApply(outputSettings: [AVVideoCodecKey: codec, AVVideoWidthKey: 160, AVVideoHeightKey: 90], forMediaType: .video) else {
            print("skipped: this Mac has no \(codec.rawValue) encoder")
            return false
        }
        return true
    }

    static func build(_ source: AirPlaySource, _ kind: Character, _ id: String, _ index: Int) throws -> AirPlayBuilt {
        let done = DispatchSemaphore(value: 0)
        var result: Result<AirPlayBuilt, Error>?
        source.build(kind: kind, id: id, index: index) {
            result = $0
            done.signal()
        }
        guard done.wait(timeout: .now() + 180) == .success, let result else { fatalError("\(kind)/\(id)/\(index) did not come in time") }
        return try result.get()
    }

    static func starts(_ source: AirPlaySource, _ kind: Character, _ id: String) -> [Double] {
        var total = 0.0
        var list: [Double] = []
        for line in (source.playlist(kind: kind, id: id) ?? "").split(separator: "\n") where line.hasPrefix("#EXTINF:") {
            list.append(total)
            total += Double(line.dropFirst(8).prefix { $0 != "," }) ?? 0
        }
        return list
    }

    static func integer(_ data: Data, _ at: Int, _ count: Int) -> Int {
        data[at..<at + count].reduce(0) { $0 << 8 | Int($1) }
    }

    static func box(_ data: Data, _ name: String) -> Int? {
        data.range(of: Data(name.utf8)).map(\.lowerBound)
    }

    static func origin(_ built: AirPlayBuilt) -> Double {
        guard let mdhd = box(built.initData, "mdhd"), let tfdt = box(built.media, "tfdt") else { fatalError("no time boxes") }
        let scale = Double(integer(built.initData, mdhd + (built.initData[mdhd + 4] == 1 ? 24 : 16), 4))
        return Double(integer(built.media, tfdt + 8, built.media[tfdt + 4] == 1 ? 8 : 4)) / scale
    }

    static func decode(_ built: AirPlayBuilt, _ type: AVFoundation.AVMediaType, _ settings: [String: Any], _ name: String) async throws -> [CMSampleBuffer] {
        let file = folder.appendingPathComponent("\(name).mp4")
        try (built.initData + built.media).write(to: file)
        let asset = AVURLAsset(url: file)
        guard let track = try await asset.loadTracks(withMediaType: type).first else { fatalError("\(name) has no track") }
        let reader = try AVAssetReader(asset: asset)
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        check(reader.startReading(), "\(name) opens: \(String(describing: reader.error))")
        var samples: [CMSampleBuffer] = []
        while let sample = output.copyNextSampleBuffer() { if CMSampleBufferGetNumSamples(sample) > 0 { samples.append(sample) } }
        check(reader.status == .completed, "\(name) reads to the end: \(String(describing: reader.error))")
        return samples
    }

    static func picture(_ built: AirPlayBuilt, _ name: String) async throws -> [CMSampleBuffer] {
        try await decode(built, .video, [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA], name)
    }

    static func colour(_ sample: CMSampleBuffer, _ x: Int, _ y: Int) -> (r: Int, g: Int, b: Int) {
        guard let buffer = CMSampleBufferGetImageBuffer(sample) else { fatalError("no picture") }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let row = CVPixelBufferGetBytesPerRow(buffer)
        let pixel = CVPixelBufferGetBaseAddress(buffer)!.assumingMemoryBound(to: UInt8.self) + y * row + x * 4
        return (Int(pixel[2]), Int(pixel[1]), Int(pixel[0]))
    }

    static func near(_ a: (r: Int, g: Int, b: Int), _ b: (r: Int, g: Int, b: Int), _ slack: Int = 40) -> Bool {
        abs(a.r - b.r) <= slack && abs(a.g - b.g) <= slack && abs(a.b - b.b) <= slack
    }

    static func piece(_ source: AirPlaySource, _ id: String, _ index: Int, name: String, expect: (r: Int, g: Int, b: Int), fps: Double, tolerance: Double) async throws {
        let list = starts(source, "v", id)
        guard index < list.count else { return check(false, "\(name): the list has segment \(index): \(list.count) segments") }
        let end = index + 1 < list.count ? list[index + 1] : list[index] + 6
        let built = try build(source, "v", id, index)
        let frames = try await picture(built, name)
        let begin = origin(built)
        check(abs(begin - list[index]) <= tolerance, "\(name): piece \(index) starts at its time: \(begin) vs \(list[index])")
        check(abs(Double(frames.count) - (end - list[index]) * fps) <= 2, "\(name): piece \(index) has its frames: \(frames.count) vs \((end - list[index]) * fps)")
        let seen = [frames.first, frames[frames.count / 2], frames.last].compactMap { $0 }.map { colour($0, 80, 45) }
        check(seen.allSatisfy { near($0, expect) }, "\(name): piece \(index) has the right colour \(expect): \(seen)")
    }

    static func sparse() async throws {
        guard can("libx264"),
              let url = make("sparse.mp4", ["-f", "lavfi", "-i", "color=c=0x2040d0:s=160x90:r=5:d=720", "-c:v", "libx264", "-preset", "ultrafast", "-g", "1500", "-keyint_min", "1500",
                                            "-sc_threshold", "0", "-pix_fmt", "yuv420p"]) else { return }
        let source = try AirPlaySource.open(url)
        let all = starts(source, "v", "h264")
        check(all.count >= 118 && all.count <= 122, "a 12 minute film with a key frame every 5 minutes is cut into pieces of about 6 s: \(all.count) pieces")
        check(zip(all, all.dropFirst()).allSatisfy { $1 - $0 < 6.5 }, "no piece is longer than 6.5 s")
        for index in [0, all.count / 2, all.count - 1] {
            try await piece(source, "h264", index, name: "sparse\(index)", expect: (0x20, 0x40, 0xd0), fps: 5, tolerance: 0.3)
        }
    }

    static func recoded(_ name: String, _ arguments: [String]) async throws {
        guard let url = make("\(name).mkv", ["-f", "lavfi", "-i", "color=c=0xd04020:s=160x90:r=24:d=14"] + arguments + ["-g", "48"]) else { return }
        let source = try AirPlaySource.open(url)
        let master = source.master()
        check(master.contains("hvc1"), "\(name): the list offers HEVC")
        for id in ["hevc", "h264"] where source.playlist(kind: "v", id: id) != nil {
            let codec: AVVideoCodecType = id == "hevc" ? .hevc : .h264
            guard canWrite(codec) else { continue }
            try await piece(source, id, 1, name: "\(name)-\(id)", expect: (0xd0, 0x40, 0x20), fps: 24, tolerance: 0.3)
        }
        check(source.playlist(kind: "v", id: "h264") != nil, "\(name): the list also offers H.264 for SDR film")
    }

    static func power(_ samples: [Float], _ frequency: Double, _ rate: Double) -> Double {
        let factor = 2 * cos(2 * Double.pi * frequency / rate)
        var (a, b) = (0.0, 0.0)
        for value in samples { (a, b) = (Double(value) + factor * a - b, a) }
        return a * a + b * b - factor * a * b
    }

    static func dts() async throws {
        guard can("libx264"), can("dca"),
              let url = make("dts.mkv", ["-f", "lavfi", "-i", "color=c=black:s=160x90:r=24:d=14", "-f", "lavfi", "-i", "sine=frequency=440:sample_rate=48000:duration=14",
                                        "-c:v", "libx264", "-g", "48", "-c:a", "dca", "-strict", "-2", "-ac", "2", "-b:a", "384k"]) else { return }
        let source = try AirPlaySource.open(url)
        check(source.master().contains("mp4a.40.2"), "DTS sound is offered as AAC")
        guard source.playlist(kind: "a", id: "1") != nil else { return check(false, "the list has the DTS sound track") }
        let list = starts(source, "a", "1")
        let built = try build(source, "a", "1", 1)
        let samples = try await decode(built, .audio, [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMBitDepthKey: 32, AVLinearPCMIsFloatKey: true, AVLinearPCMIsBigEndianKey: false,
                                                      AVLinearPCMIsNonInterleaved: false, AVNumberOfChannelsKey: 1, AVSampleRateKey: 48000], "dts")
        var pcm: [Float] = []
        for sample in samples {
            guard let block = CMSampleBufferGetDataBuffer(sample) else { continue }
            var length = 0
            var pointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &pointer)
            pcm += UnsafeBufferPointer(start: UnsafeRawPointer(pointer!).assumingMemoryBound(to: Float.self), count: length / 4)
        }
        let length = list.count > 2 ? list[2] - list[1] : 6
        check(abs(Double(pcm.count) / 48000 - length) < 0.25, "the DTS piece lasts as the list says: \(Double(pcm.count) / 48000) s vs \(length) s")
        check(abs(origin(built) - list[1]) < 0.1, "the DTS piece starts at its time: \(origin(built)) vs \(list[1])")
        let rms = (pcm.reduce(0.0) { $0 + Double($1 * $1) } / Double(max(pcm.count, 1))).squareRoot()
        check(rms > 0.04 && rms < 0.2, "the DTS piece has the sound level of the source: \(rms)")
        let tone = power(pcm, 440, 48000)
        check(tone > 50 * power(pcm, 660, 48000) && tone > 50 * power(pcm, 300, 48000), "the DTS piece plays the 440 Hz tone")
    }

    static func be(_ value: Int, _ count: Int) -> [UInt8] {
        (0..<count).map { UInt8(truncatingIfNeeded: value >> (8 * (count - 1 - $0))) }
    }

    static func join(_ pieces: [UInt8]...) -> [UInt8] {
        pieces.flatMap { $0 }
    }

    static func subtitleFile() -> Data {
        func part(_ time: Double, _ type: UInt8, _ body: [UInt8]) -> [UInt8] {
            join([0x50, 0x47], be(Int(time * 90_000), 4), be(0, 4), [type], be(body.count, 2), body)
        }
        let window = join([1, 0], be(60, 2), be(35, 2), be(40, 2), be(20, 2))
        let lines: [UInt8] = (0..<20).flatMap { _ in [0x00, 0x80 | 40, 0x01, 0x00, 0x00] }
        let shown = join(be(160, 2), be(90, 2), [0x10], be(0, 2), [0x80, 0x00, 0x00, 1], be(0, 2), [0, 0], be(60, 2), be(35, 2))
        let image = join(be(0, 2), [0, 0xC0], be(4 + lines.count, 3), be(40, 2), be(20, 2), lines)
        let cleared = join(be(160, 2), be(90, 2), [0x10], be(1, 2), [0x00, 0x00, 0x00, 0])
        return Data(join(part(1.5, 0x16, shown), part(1.5, 0x17, window), part(1.5, 0x14, [0, 0, 1, 235, 128, 128, 255]), part(1.5, 0x15, image), part(1.5, 0x80, []),
                         part(4.0, 0x16, cleared), part(4.0, 0x17, window), part(4.0, 0x80, [])))
    }

    static func burned() async throws {
        let sup = folder.appendingPathComponent("words.sup")
        try subtitleFile().write(to: sup)
        guard can("libx264"),
              let url = make("burn.mkv", ["-copyts", "-f", "lavfi", "-i", "color=c=0x203040:s=160x90:r=24:d=14", "-i", sup.path, "-map", "0:v", "-map", "1:s", "-c:v", "libx264", "-g", "48",
                                          "-pix_fmt", "yuv420p", "-c:s", "copy", "-disposition:s:0", "default+forced"]) else { return }
        let source = try AirPlaySource.open(url)
        check(source.master().contains("avc1"), "a film with picture subtitles is offered as H.264")
        guard canWrite(.h264) else { return }
        let dark = (r: 0x20, g: 0x30, b: 0x40)
        let first = try build(source, "v", "h264", 0)
        let frames = try await picture(first, "burn0")
        let begin = origin(first)
        func at(_ time: Double) -> CMSampleBuffer {
            frames.min { abs(begin + CMSampleBufferGetPresentationTimeStamp($0).seconds - time) < abs(begin + CMSampleBufferGetPresentationTimeStamp($1).seconds - time) }!
        }
        let before = colour(at(0.5), 80, 45)
        let during = colour(at(2.0), 80, 45)
        let outside = colour(at(2.0), 20, 10)
        let after = colour(at(5.0), 80, 45)
        check(near(before, dark), "before the words appear the picture is clean: \(before)")
        check(during.r > 190 && during.g > 190 && during.b > 190, "the words are burnt into the picture while they are shown: \(during)")
        check(near(outside, dark), "the picture outside the words is untouched: \(outside)")
        check(near(after, dark), "after the words disappear the picture is clean again: \(after)")
        let second = try build(source, "v", "h264", 1)
        let later = try await picture(second, "burn1")
        check(near(colour(later[later.count / 2], 80, 45), dark), "the next piece has no words")
    }

    static func attempt(_ name: String, _ body: () async throws -> Void) async {
        do { try await body() } catch { check(false, "\(name) runs without an error: \(error)") }
    }

    static func main() async throws {
        guard let found = ((ProcessInfo.processInfo.environment["FFMPEG"].map { [$0] } ?? []) + ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg"]).first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            print("skipped: no ffmpeg command to make the test films (set FFMPEG)")
            return
        }
        tool = found
        encoders = run(["-hide_banner", "-encoders"]) ?? ""
        setvbuf(stdout, nil, _IOLBF, 0)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        await attempt("sparse key frames", sparse)
        if can("libvpx-vp9") { await attempt("VP9") { try await recoded("vp9", ["-c:v", "libvpx-vp9", "-b:v", "300k", "-deadline", "realtime", "-cpu-used", "8"]) } }
        if can("libsvtav1") { await attempt("AV1") { try await recoded("av1", ["-c:v", "libsvtav1", "-preset", "12", "-pix_fmt", "yuv420p"]) } }
        await attempt("DTS", dts)
        await attempt("picture subtitles", burned)
        try? FileManager.default.removeItem(at: folder)
        print(failures == 0 ? "all AirPlay media checks passed" : "\(failures) AirPlay media checks FAILED")
        if failures > 0 { exit(1) }
    }
}
