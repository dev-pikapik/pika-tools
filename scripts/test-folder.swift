import AppKit
import MediaPlayer

@main
enum TestFolder {
    static var failures = 0

    static func check(_ ok: Bool, _ what: String) {
        print((ok ? "ok" : "FAILED") + ": " + what)
        if !ok { failures += 1 }
    }

    static let ffmpeg = ((ProcessInfo.processInfo.environment["FFMPEG"].map { [$0] } ?? []) + ["/opt/homebrew/bin/ffmpeg", "/usr/local/bin/ffmpeg"]).first { FileManager.default.isExecutableFile(atPath: $0) }

    static func make(_ name: String, in folder: URL, _ arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpeg!)
        process.arguments = ["-hide_banner", "-loglevel", "error", "-y"] + arguments + [folder.appendingPathComponent(name).path]
        try! process.run()
        process.waitUntilExit()
    }

    static func wait(_ seconds: Double, until: () -> Bool = { false }) {
        let end = Date(timeIntervalSinceNow: seconds)
        while Date() < end, !until() { RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05)) }
    }

    static func row(in view: NSView) -> NSStackView? {
        if let stack = view as? NSStackView, stack.arrangedSubviews.count > 10 { return stack }
        return view.subviews.lazy.compactMap { row(in: $0) }.first
    }

    static func main() {
        setvbuf(stdout, nil, _IOLBF, 0)
        guard ffmpeg != nil else { return print("skipped: no ffmpeg (set FFMPEG=/path/to/ffmpeg)") }
        NSApplication.shared.setActivationPolicy(.prohibited)
        UserDefaults.standard.setVolatileDomain(["volume": Float(0)], forName: UserDefaults.argumentDomain)
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pika-folder-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        make("cover.jpg", in: folder, ["-f", "lavfi", "-i", "color=c=0xe94560:s=64x64", "-frames:v", "1"])
        let sine = ["-f", "lavfi", "-i", "sine=frequency=440:duration=3:sample_rate=44100"]
        let covered = sine + ["-i", folder.appendingPathComponent("cover.jpg").path, "-map", "0:a", "-map", "1:v", "-c:v", "copy", "-disposition:v:0", "attached_pic"]
        let tags = ["-metadata", "title=Тест 音楽", "-metadata", "artist=Артист", "-metadata", "album=Альбом"]
        make("01 first.mp3", in: folder, covered + ["-c:a", "libmp3lame", "-q:a", "5", "-id3v2_version", "3"] + tags)
        make("02 second.flac", in: folder, sine + ["-c:a", "flac"])
        make("10 third.m4a", in: folder, ["-f", "lavfi", "-i", "sine=frequency=330:duration=8:sample_rate=44100", "-c:a", "aac", "-b:a", "96k"] + tags)
        try! Data("text".utf8).write(to: folder.appendingPathComponent("notes.txt"))
        try? FileManager.default.removeItem(at: folder.appendingPathComponent("cover.jpg"))

        let player = PlayerController()
        if let window = player.window, let panel = row(in: window.contentView!) {
            for view in panel.arrangedSubviews {
                view.isHidden = false
                if let label = view as? NSTextField, label.stringValue.contains(":") { label.stringValue = "-10:00:00" }
            }
            let needed = panel.fittingSize.width + 32
            check(needed <= window.minSize.width, "the bottom row with every button and ten-hour times needs \(Int(needed)) pt; the narrowest window is \(Int(window.minSize.width)) pt")
        } else {
            check(false, "the bottom row of buttons is found")
        }
        let center = MPNowPlayingInfoCenter.default()
        let name = { player.window?.representedURL?.lastPathComponent ?? "-" }

        player.load(folder)
        wait(2, until: { player.state.hasPrefix("Playing") })
        check(name() == "01 first.mp3", "a folder opens at its first song: \(name())")
        let info = center.nowPlayingInfo ?? [:]
        check(info[MPMediaItemPropertyTitle] as? String == "Тест 音楽" && info[MPMediaItemPropertyArtist] as? String == "Артист" && info[MPMediaItemPropertyAlbumTitle] as? String == "Альбом", "Now Playing has title, artist and album")
        check(info[MPMediaItemPropertyArtwork] != nil, "Now Playing has the cover")
        check((info[MPMediaItemPropertyPlaybackDuration] as? Double).map { abs($0 - 3) < 0.4 } == true, "Now Playing duration: \(info[MPMediaItemPropertyPlaybackDuration] ?? "-")")
        check(info[MPNowPlayingInfoPropertyPlaybackRate] as? Double == 1 && center.playbackState == .playing, "Now Playing says playing, rate 1")
        let commands = MPRemoteCommandCenter.shared()
        check(commands.playCommand.isEnabled && commands.pauseCommand.isEnabled && commands.nextTrackCommand.isEnabled && commands.previousTrackCommand.isEnabled && commands.changePlaybackPositionCommand.isEnabled, "the remote commands are on")

        player.setPlaying(false)
        wait(0.5)
        check(center.playbackState == .paused && center.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] as? Double == 0, "pausing shows paused, rate 0")
        player.setPlaying(true)
        wait(0.5)
        check(center.playbackState == .playing, "playing again shows playing")

        wait(5, until: { name() == "02 second.flac" })
        check(name() == "02 second.flac", "the next song starts by itself: \(name())")
        wait(1)
        check(center.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String == "02 second" && center.nowPlayingInfo?[MPMediaItemPropertyArtwork] == nil, "Now Playing changed to the second song, no cover left over")
        wait(5, until: { name() == "10 third.m4a" })
        check(name() == "10 third.m4a", "then the third (2 before 10): \(name())")
        wait(10, until: { !player.state.hasPrefix("Playing") })
        let atEnd = name()
        wait(2.5)
        check(name() == atEnd && atEnd == "10 third.m4a", "after the last song nothing starts again: \(name()), \(player.state)")
        check(!player.perform(.next) || name() == "10 third.m4a", "Next on the last song does nothing")

        player.seek(0)
        wait(0.3)
        _ = player.perform(.previous)
        wait(1, until: { name() == "02 second.flac" })
        check(name() == "02 second.flac", "Previous near the start goes to the earlier song: \(name())")
        wait(4.5, until: { name() == "10 third.m4a" })
        wait(0.5)
        player.seek(5)
        wait(0.3)
        _ = player.perform(.previous)
        wait(0.5)
        check(name() == "10 third.m4a", "Previous after 3 seconds restarts the song: \(name())")

        player.window?.close()
        wait(0.5)
        check(center.nowPlayingInfo == nil && center.playbackState == .stopped, "closing the window clears Now Playing")

        print(failures == 0 ? "all folder checks passed" : "\(failures) folder checks FAILED")
        exit(failures == 0 ? 0 : 1)
    }
}
