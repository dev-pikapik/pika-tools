import AppKit
import Foundation

@main
enum TestThumbnails {
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

    static func wait(_ seconds: Double, until done: () -> Bool) {
        let end = Date(timeIntervalSinceNow: seconds)
        while !done(), Date() < end { RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.02)) }
    }

    static func pixels(_ image: CGImage) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = CGContext(data: &data, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: image.width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return data
    }

    static func average(_ data: [UInt8]) -> (r: Int, g: Int, b: Int) {
        var sum = (0, 0, 0)
        for i in stride(from: 0, to: data.count, by: 4) { sum = (sum.0 + Int(data[i]), sum.1 + Int(data[i + 1]), sum.2 + Int(data[i + 2])) }
        let count = data.count / 4
        return (sum.0 / count, sum.1 / count, sum.2 / count)
    }

    static func thumbnail(_ url: URL, size: CGSize, duration: Double, at fraction: Double) -> CGImage? {
        let thumbnails = Thumbnails(url: url, size: size, duration: duration)
        defer { thumbnails.close() }
        let bucket = PlayerThumbnail.bucket(fraction * duration, duration: duration)
        var ready = false
        thumbnails.onReady = { if $0 == bucket { ready = true } }
        precondition(thumbnails.image(for: bucket) == nil, "nothing is ready before the first request")
        wait(20) { ready }
        return ready ? thumbnails.image(for: bucket) : nil
    }

    static func fillAll(_ url: URL) -> (count: Int, released: Bool) {
        weak var gone: Thumbnails?
        var ready = Set<Int>()
        do {
            let thumbnails = Thumbnails(url: url, size: CGSize(width: 320, height: 180), duration: 10)
            gone = thumbnails
            thumbnails.onReady = { ready.insert($0) }
            _ = thumbnails.image(for: 50)
            wait(60) { ready.count == PlayerThumbnail.buckets }
            check(thumbnails.image(for: 0) != nil && thumbnails.image(for: 99) != nil, "a ready picture is returned at once")
            thumbnails.close()
        }
        wait(5) { gone == nil }
        return (ready.count, gone == nil)
    }

    static func main() {
        setvbuf(stdout, nil, _IOLBF, 0)
        guard let ffmpeg = ffmpeg() else {
            print("skipped: no ffmpeg (set FFMPEG=/path/to/ffmpeg)")
            return
        }
        NSApplication.shared.setActivationPolicy(.prohibited)
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pikapik-thumbnails-\(getpid())")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let picture = ["-f", "lavfi", "-i", "testsrc2=size=320x180:rate=25:duration=10"]
        let clips: [(String, URL)] = [
            ("H.264 in MP4 (decoded by VideoToolbox)", make(ffmpeg, "h264.mp4", in: folder, picture + ["-c:v", "libx264", "-g", "25", "-pix_fmt", "yuv420p"])),
            ("MPEG-4 in AVI (decoded by FFmpeg)", make(ffmpeg, "mpeg4.avi", in: folder, picture + ["-c:v", "mpeg4", "-g", "25", "-pix_fmt", "yuv420p"])),
            ("VP9 in WebM (decoded by FFmpeg)", make(ffmpeg, "vp9.webm", in: folder, picture + ["-c:v", "libvpx-vp9", "-g", "25", "-pix_fmt", "yuv420p"])),
        ]
        for (name, url) in clips {
            let middle = thumbnail(url, size: CGSize(width: 320, height: 180), duration: 10, at: 0.5)
            check(middle.map { $0.width == 320 && $0.height == 180 } ?? false, "\(name): the 50 % picture is 320 × 180, sharp on a Retina screen")
            let data = middle.map(pixels) ?? []
            let colors = Set(stride(from: 0, to: data.count, by: 4).map { (offset: Int) -> Int in Int(data[offset]) << 16 | Int(data[offset + 1]) << 8 | Int(data[offset + 2]) })
            check(colors.count > 50, "\(name): the picture is not empty")
            let start = thumbnail(url, size: CGSize(width: 320, height: 180), duration: 10, at: 0)
            check(start.map(pixels) != nil && start.map(pixels)! != data, "\(name): the start and the middle show different frames")
        }

        let red = make(ffmpeg, "red.mp4", in: folder, ["-f", "lavfi", "-i", "color=c=red:size=320x180:rate=25:duration=4", "-c:v", "libx264", "-pix_fmt", "yuv420p"])
        let color = thumbnail(red, size: CGSize(width: 320, height: 180), duration: 4, at: 0.5).map(pixels).map(average)
        check(color.map { $0.r > 200 && $0.g < 60 && $0.b < 60 } ?? false, "red stays red: \(String(describing: color))")

        let tall = make(ffmpeg, "tall.mp4", in: folder, ["-f", "lavfi", "-i", "testsrc2=size=180x320:rate=25:duration=4", "-c:v", "libx264", "-pix_fmt", "yuv420p"])
        let shape = thumbnail(tall, size: CGSize(width: 180, height: 320), duration: 4, at: 0.5)
        check(shape.map { $0.width == 100 && $0.height == 180 } ?? false, "a tall video keeps its shape: \(shape.map { "\($0.width) × \($0.height)" } ?? "none")")

        let (count, released) = fillAll(clips[0].1)
        check(count == PlayerThumbnail.buckets, "one hover fills all \(PlayerThumbnail.buckets) pictures in the background (\(count))")
        check(released, "closing frees the thumbnails")

        let chapterList = folder.appendingPathComponent("chapters.txt")
        try! Data(";FFMETADATA1\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=0\nEND=4000\ntitle=One\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=4000\nEND=7000\ntitle=Two\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=7000\nEND=10000\n".utf8).write(to: chapterList)
        for container in ["mkv", "mp4"] {
            let url = make(ffmpeg, "chapters.\(container)", in: folder, picture + ["-i", chapterList.path, "-map_metadata", "1", "-map_chapters", "1", "-map", "0:v", "-c:v", "libx264", "-pix_fmt", "yuv420p"])
            let found = (try? Engine(url))?.chapters ?? []
            check(found.map(\.start) == [0, 4, 7] && found.map(\.title) == ["One", "Two", ""], "\(container): chapters are read with their times and names: \(found.map { "\($0.start) \($0.title)" })")
        }
        check((try? Engine(clips[0].1))?.chapters.isEmpty == true, "a file without chapters has none")

        let audio = make(ffmpeg, "sound.mka", in: folder, ["-f", "lavfi", "-i", "sine=duration=4", "-c:a", "aac"])
        let broken = folder.appendingPathComponent("broken.mkv")
        try! Data("not a video".utf8).write(to: broken)
        for (name, url) in [("an audio file", audio), ("a broken file", broken)] {
            check(thumbnail(url, size: CGSize(width: 320, height: 180), duration: 4, at: 0.5) == nil, "\(name): no picture, nothing breaks")
        }
        print(failures == 0 ? "all thumbnail checks passed" : "\(failures) thumbnail checks FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
