import AppKit
import Foundation
import UniformTypeIdentifiers

@main
enum TestPlayer {
    static func main() async {
        let cases: [(Double, String)] = [(0, "0:00"), (3.9, "0:03"), (59.99, "0:59"), (60, "1:00"), (605, "10:05"), (3600, "1:00:00"), (3725.5, "1:02:05"), (-4, "0:00"), (.nan, "0:00"), (.infinity, "0:00")]
        for (seconds, text) in cases {
            precondition(PlayerTime.text(seconds) == text, "\(seconds) → \(PlayerTime.text(seconds)), wanted \(text)")
        }
        print("time reads like QuickTime, never negative or broken: ok")

        precondition(PlayerTime.clamp(-5, duration: 10) == 0)
        precondition(PlayerTime.clamp(4, duration: 10) == 4)
        precondition(PlayerTime.clamp(15, duration: 10) == 10)
        precondition(PlayerTime.clamp(15, duration: .nan) == 15)
        precondition(PlayerTime.clamp(15, duration: 0) == 15)
        precondition(PlayerTime.clamp(.nan, duration: 10) == 0)
        print("seeking stays between the start and the end: ok")

        precondition(PlayerTime.volume(0.95, by: 0.1) == 1)
        precondition(PlayerTime.volume(0.05, by: -0.1) == 0)
        var volume: Float = 0.5
        for _ in 0..<3 { volume = PlayerTime.volume(volume, by: PlayerAction.volumeStep) }
        precondition(volume == 0.8, "\(volume)")
        print("volume moves in tenths and stays between 0 and 1: ok")

        let (left, right, up, down) = ("\u{F702}", "\u{F703}", "\u{F700}", "\u{F701}")
        let keys: [(String, NSEvent.ModifierFlags, PlayerAction?)] = [
            (" ", [], .playPause), ("k", [], .playPause), ("K", [], .playPause), (left, [], .back), (right, [], .forward), (left, .shift, .skipBack), (right, .shift, .skipForward),
            ("j", [], .longBack), ("l", [], .longForward), (",", [], .frameBack), (".", [], .frameForward), (left, .option, .start), (right, .option, .end),
            (left, .command, .slower), (right, .command, .faster), ("[", [], .slower), ("]", [], .faster), ("\u{7F}", [], .normalSpeed),
            (up, [], .louder), (down, [], .quieter), ("m", [], .mute), ("f", [], .fullScreen), ("F", [], .fullScreen), ("f", .command, .fullScreen), ("f", [.command, .control], .fullScreen),
            ("\u{1B}", [], .leaveFullScreen), ("s", [], .snapshot), ("t", [], .floatOnTop),
            ("n", [], .next), ("N", [], .next), (">", .shift, .next), ("p", [], .previous), ("<", .shift, .previous), ("n", .command, nil), ("p", .option, nil),
            (up, .option, nil), (left, [.shift, .option], nil), ("f", .option, nil), ("a", [], nil), ("", [], nil),
        ]
        for (key, modifiers, action) in keys {
            precondition(PlayerAction(key: key, modifiers: modifiers) == action, "key \(key.unicodeScalars.map { String($0.value, radix: 16) }) \(modifiers.rawValue)")
        }
        precondition(PlayerAction(key: left, modifiers: [.shift, .function, .numericPad]) == .skipBack, "arrow keys always carry the function flag")
        let bound = Set(PlayerAction.bindings.map(\.action))
        for action in [PlayerAction.playPause, .back, .forward, .skipBack, .skipForward, .longBack, .longForward, .frameBack, .frameForward, .start, .end, .slower, .faster, .normalSpeed, .louder, .quieter, .mute, .fullScreen, .leaveFullScreen, .snapshot, .next, .previous, .floatOnTop] {
            precondition(bound.contains(action), "\(action) has no key")
        }
        precondition(Set(PlayerAction.bindings.map { "\($0.key)\($0.modifiers.rawValue)" }).count == PlayerAction.bindings.count, "a key is bound twice")
        precondition(PlayerAction.skip == 5 && PlayerAction.longSkip == 10)
        precondition(PlayerAction.back.resolved(playing: false) == .frameBack && PlayerAction.forward.resolved(playing: false) == .frameForward)
        precondition(PlayerAction.back.resolved(playing: true) == .skipBack && PlayerAction.forward.resolved(playing: true) == .skipForward)
        precondition(PlayerAction.mute.resolved(playing: false) == .mute && PlayerAction.skipBack.resolved(playing: false) == .skipBack)
        print("every key in the table does what its menu item says, and the arrows step a frame only on pause: ok")

        precondition(PlayerSpeed.all == [0.5, 0.75, 1, 1.25, 1.5, 2])
        precondition(PlayerSpeed.stepped(1, 1) == 1.25 && PlayerSpeed.stepped(1, -1) == 0.75)
        precondition(PlayerSpeed.stepped(2, 1) == 2 && PlayerSpeed.stepped(0.5, -1) == 0.5)
        precondition(PlayerSpeed.stepped(1.5, 1) == 2 && PlayerSpeed.stepped(0.75, -1) == 0.5)
        precondition(PlayerSpeed.stepped(1.1, 1) == 1.25 && PlayerSpeed.stepped(1.1, -1) == 1)
        var speed: Float = 1
        for _ in 0..<10 { speed = PlayerSpeed.stepped(speed, 1) }
        precondition(speed == 2)
        for _ in 0..<10 { speed = PlayerSpeed.stepped(speed, -1) }
        precondition(speed == 0.5)
        print("speed steps through 0.5 to 2 and stops at both ends: ok")

        let now = 1_000_000.0
        precondition(!PlayerResume.worthKeeping(60, of: 600) && PlayerResume.worthKeeping(60.5, of: 600))
        precondition(PlayerResume.worthKeeping(569, of: 600) && !PlayerResume.worthKeeping(570, of: 600) && !PlayerResume.worthKeeping(590, of: 600))
        precondition(!PlayerResume.worthKeeping(100, of: 120) && !PlayerResume.worthKeeping(100, of: .nan) && !PlayerResume.worthKeeping(.nan, of: 600))
        var saved = PlayerResume.updated([:], key: "a", position: 200, duration: 600, at: now)
        precondition(saved["a"] == [200, now])
        saved = PlayerResume.updated(saved, key: "a", position: 590, duration: 600, at: now + 1)
        precondition(saved.isEmpty, "a finished video must start from the top next time")
        saved = PlayerResume.updated(PlayerResume.updated([:], key: "a", position: 200, duration: 600, at: now), key: "a", position: 10, duration: 600, at: now + 1)
        precondition(saved.isEmpty, "Start Over forgets the place")
        saved = [:]
        for index in 0..<(PlayerResume.limit + 25) { saved = PlayerResume.updated(saved, key: "k\(index)", position: 100, duration: 600, at: now + Double(index)) }
        precondition(saved.count == PlayerResume.limit && saved["k0"] == nil && saved["k24"] == nil && saved["k25"] != nil && saved["k224"] != nil, "\(saved.count)")
        saved = PlayerResume.updated(saved, key: "k25", position: 300, duration: 600, at: now + 1000)
        saved = PlayerResume.updated(saved, key: "new", position: 100, duration: 600, at: now + 1001)
        precondition(saved.count == PlayerResume.limit && saved["k25"] != nil && saved["k26"] == nil && saved["new"] != nil, "the oldest entry goes first")
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let key = PlayerResume.key(path: "/a/Film.mkv", size: 1000, modified: date)
        precondition(key.count == 32 && key == PlayerResume.key(path: "/a/Film.mkv", size: 1000, modified: date.addingTimeInterval(0.4)))
        precondition(key != PlayerResume.key(path: "/b/Film.mkv", size: 1000, modified: date) && key != PlayerResume.key(path: "/a/Film.mkv", size: 1001, modified: date) && key != PlayerResume.key(path: "/a/Film.mkv", size: 1000, modified: date.addingTimeInterval(2)))
        print("the place is kept after 60 s and until 30 s before the end, for the last 200 videos: ok")

        func scroll(_ events: [(right: Double, up: Double, precise: Bool, began: Bool, at: Double)]) -> (volume: Float, seconds: Double) {
            var wheel = PlayerWheel()
            var total: (volume: Float, seconds: Double) = (0, 0)
            for event in events {
                let change = wheel.add(right: event.right, up: event.up, precise: event.precise, began: event.began, at: event.at)
                total = (total.volume + change.volume, total.seconds + change.seconds)
            }
            return total
        }
        precondition(scroll([(0, 3, true, true, 0), (0, 2, true, false, 0.01), (0, 2, true, false, 0.02)]) == (0, 0), "a light touch must do nothing")
        precondition(scroll([(2, 0, true, true, 0), (3, 1, true, false, 0.01)]) == (0, 0))
        let volumeSwipe = scroll([(0, 3, true, true, 0), (0, 3, true, false, 0.01), (0, 4, true, false, 0.02), (0, 10, true, false, 0.03)])
        precondition(volumeSwipe.seconds == 0 && abs(volumeSwipe.volume - 0.1) < 0.0001, "\(volumeSwipe)")
        let seekSwipe = scroll([(20, 2, true, true, 0), (20, 3, true, false, 0.01)])
        precondition(seekSwipe.volume == 0 && abs(seekSwipe.seconds - 10) < 0.0001, "\(seekSwipe)")
        precondition(scroll([(0, -40, true, true, 0)]).volume < 0 && scroll([(-40, 0, true, true, 0)]).seconds < 0)
        let notch = scroll([(0, 1, false, false, 0)])
        precondition(abs(notch.volume - 0.1) < 0.0001, "one wheel notch is one volume step: \(notch)")
        precondition(abs(scroll([(1, 0, false, false, 0)]).seconds - 5) < 0.0001, "one wheel notch is the 5 second jump")
        precondition(scroll([(0, 5, true, false, 0), (0, 5, true, false, 1)]) == (0, 0), "a pause between touches starts over")
        precondition(scroll([(0, 5, true, true, 0), (0, 5, true, true, 0.1)]) == (0, 0), "a new touch starts over")
        print("the wheel ignores light touches, locks to one direction, and moves in steady steps: ok")

        precondition(PlayerTime.snapshotName("Film.mkv", at: 83.9) == "Film 1.23.png" && PlayerTime.snapshotName("a.b.webm", at: 3725) == "a.b 1.02.05.png")
        print("a saved frame is named after the video and the time: ok")

        let delay = PlayerChrome.hideDelay
        let rule: [(Bool, Bool, Bool, Double, Bool, Bool)] = [
            (true, false, false, 0, true, true), (true, false, false, delay - 0.1, true, true), (true, false, false, delay, false, true), (true, false, true, delay, false, false),
            (false, false, false, 60, true, true), (false, false, true, 60, true, true), (true, true, true, 60, true, true), (true, false, true, .infinity, false, false),
        ]
        for (playing, over, full, idle, controls, cursor) in rule {
            let seen = PlayerChrome.visibility(playing: playing, overControls: over, fullScreen: full, idle: idle)
            precondition(seen == (controls, cursor), "playing \(playing), over \(over), full screen \(full), idle \(idle) → \(seen)")
        }
        precondition(delay == 2.5)
        precondition(PlayerChrome.visibility(playing: true, overControls: false, fullScreen: true, idle: .infinity, hides: false) == (true, true), "a song has no picture to hide the panel from")
        print("the panel stays on pause and under the pointer, hides after 2.5 s of playing, and takes the cursor with it only in full screen: ok")

        let total = 600.0
        precondition(PlayerThumbnail.bucket(0, duration: total) == 0 && PlayerThumbnail.bucket(total / 2, duration: total) == 50 && PlayerThumbnail.bucket(total, duration: total) == 99)
        precondition(PlayerThumbnail.bucket(-3, duration: total) == 0 && PlayerThumbnail.bucket(9999, duration: total) == 99 && PlayerThumbnail.bucket(.nan, duration: total) == 0)
        precondition(PlayerThumbnail.bucket(5, duration: 0) == 0 && PlayerThumbnail.bucket(5, duration: .nan) == 0)
        precondition(PlayerThumbnail.time(of: 0, duration: total) == 3 && PlayerThumbnail.time(of: 99, duration: total) == 597)
        precondition((0..<PlayerThumbnail.buckets).allSatisfy { PlayerThumbnail.bucket(PlayerThumbnail.time(of: $0, duration: total), duration: total) == $0 }, "a picture is taken inside its own slot")
        print("the position maps to one of 100 slots, and each picture is taken in the middle of its slot: ok")

        precondition(PlayerThumbnail.size(for: CGSize(width: 1920, height: 1080)) == CGSize(width: 160, height: 90))
        precondition(PlayerThumbnail.size(for: CGSize(width: 640, height: 480)) == CGSize(width: 120, height: 90))
        precondition(PlayerThumbnail.size(for: CGSize(width: 1080, height: 1920)) == CGSize(width: 50, height: 90))
        precondition(PlayerThumbnail.size(for: CGSize(width: 3840, height: 100)) == CGSize(width: 160, height: 4))
        precondition(PlayerThumbnail.size(for: .zero) == PlayerThumbnail.box)
        print("a picture fits into 160 × 90 and keeps the shape of the video: ok")

        let have: Set<Int> = [10, 40, 41]
        precondition(PlayerThumbnail.nearest(to: 41, ready: have.contains) == 41 && PlayerThumbnail.nearest(to: 45, ready: have.contains) == 41)
        precondition(PlayerThumbnail.nearest(to: 20, ready: have.contains) == 10 && PlayerThumbnail.nearest(to: 99, ready: have.contains) == 41 && PlayerThumbnail.nearest(to: 0, ready: have.contains) == 10)
        precondition(PlayerThumbnail.nearest(to: 25, ready: have.contains) == 10, "a tie takes the earlier picture")
        precondition(PlayerThumbnail.nearest(to: 5, ready: { _ in false }) == nil)
        print("with no exact picture ready the nearest one is shown, or none: ok")

        let extensions = PlayerFormats.extensions
        precondition(Set(extensions).count == extensions.count, "an extension is listed twice")
        precondition(PlayerFormats.plays(URL(fileURLWithPath: "/a/Film.MKV")) && !PlayerFormats.plays(URL(fileURLWithPath: "/a/notes.txt")))
        let plist = NSDictionary(contentsOfFile: "Helper/Player/Info.plist")!
        let documents = plist["CFBundleDocumentTypes"] as! [[String: Any]]
        precondition(documents.allSatisfy { $0["LSHandlerRank"] as? String == "Alternate" }, "the player must never ask to be the default app")
        let imported = plist["UTImportedTypeDeclarations"] as? [[String: Any]] ?? []
        precondition(plist["UTExportedTypeDeclarations"] == nil, "the player must not take over any file type")
        let importedIDs = imported.compactMap { $0["UTTypeIdentifier"] as? String }
        precondition(Set(importedIDs) == ["org.matroska.mkv", "org.webmproject.webm", "org.xiph.ogv"], "\(importedIDs)")
        for declaration in imported {
            let tags = declaration["UTTypeTagSpecification"] as? [String: Any] ?? [:]
            let ext = tags["public.filename-extension"] as? [String] ?? []
            precondition(declaration["UTTypeConformsTo"] as? [String] == ["public.movie"] && !ext.isEmpty && ext.allSatisfy(PlayerFormats.extensions.contains) && !(tags["public.mime-type"] as? [String] ?? []).isEmpty, "\(declaration)")
        }
        precondition(importedIDs.allSatisfy { documents.flatMap { $0["LSItemContentTypes"] as? [String] ?? [] }.contains($0) }, "an imported type the player does not open")
        let entitlements = NSDictionary(contentsOfFile: "Helper/Player/Player.entitlements")!
        precondition(Set(entitlements.allKeys as! [String]) == ["com.apple.security.app-sandbox", "com.apple.security.files.bookmarks.app-scope", "com.apple.security.files.user-selected.read-write"], "\(entitlements.allKeys)")
        let types = documents.flatMap { $0["LSItemContentTypes"] as? [String] ?? [] }
        let claimed = documents.flatMap { $0["CFBundleTypeExtensions"] as? [String] ?? [] }
        let system = ["avi": "public.avi", "ts": "public.mpeg-2-transport-stream", "m2ts": "public.avchd-mpeg-2-transport-stream", "mts": "public.avchd-mpeg-2-transport-stream",
                      "mpg": "public.mpeg", "mpeg": "public.mpeg", "mp4": "public.mpeg-4", "m4v": "com.apple.m4v-video", "mov": "com.apple.quicktime-movie",
                      "mp3": "public.mp3", "aac": "public.aac-audio", "m4a": "com.apple.m4a-audio", "wav": "com.microsoft.waveform-audio", "aiff": "public.aiff-audio", "aif": "public.aiff-audio", "caf": "com.apple.coreaudio-format"]
        for ext in extensions {
            precondition(claimed.contains(ext) || system[ext].map(types.contains) == true, ".\(ext) is in the Settings list but the player does not open it")
        }
        precondition(plist["LSMinimumSystemVersion"] as? String == "14.0")
        print("every listed format opens in the player, which asks to be only an alternate app and may only write where you choose: ok")

        let videoTypes = PlayerFormats.videoTypes
        precondition(videoTypes.count >= 10 && Set(videoTypes).count == videoTypes.count, "the video types are missing or repeated: \(videoTypes.count)")
        precondition(videoTypes.contains(.mpeg4Movie) && videoTypes.contains(.quickTimeMovie) && videoTypes.contains(.avi), "the usual video types are not in the list")
        let musicTypes = PlayerFormats.musicTypes
        precondition(musicTypes.count >= 8 && Set(musicTypes).count == musicTypes.count && musicTypes.contains(.mp3) && musicTypes.contains(.wav) && Set(musicTypes).isDisjoint(with: videoTypes), "the music types are missing, repeated or shared with video")
        checkPlaylist()
        await checkDefaultApps()
    }

    static func checkPlaylist() {
        func url(_ path: String) -> URL { URL(fileURLWithPath: path) }
        precondition(PlayerFormats.kind(of: url("/a/Song.FLAC")) == .music && PlayerFormats.kind(of: url("/a/Film.mkv")) == .video && PlayerFormats.kind(of: url("/a/notes.txt")) == nil && PlayerFormats.kind(of: url("/a/folder")) == nil)
        precondition(["mp3", "aac", "m4a", "flac", "alac", "wav", "aiff", "aif", "caf", "ogg", "oga", "opus", "wma", "ape", "dsf"].allSatisfy { PlayerFormats.kind(of: url("/a/x.\($0)")) == .music }, "a music format is not recognised")
        precondition(PlayerFormats.video.flatMap(\.extensions).allSatisfy { PlayerFormats.kind(of: url("/a/x.\($0)")) == .video }, "a video format is read as music")
        print("a file is a song or a video by its extension, whatever the letter case: ok")

        let folder = ["10 Ten.mp3", "2 Two.mp3", "02 Film.mkv", "cover.jpg", "1 One.flac", "Intro.mp3", "intro.MP3", "notes.txt"].map { url("/m/\($0)") }
        let order = PlaylistOrder.sorted(folder).map(\.lastPathComponent)
        precondition(order == ["1 One.flac", "02 Film.mkv", "2 Two.mp3", "10 Ten.mp3", "cover.jpg", "intro.MP3", "Intro.mp3", "notes.txt"], "\(order)")
        precondition(PlaylistOrder.sorted(folder) == PlaylistOrder.sorted(folder.reversed()), "the order must not depend on how the folder was listed")
        precondition(PlaylistOrder.first(among: folder) == url("/m/1 One.flac") && PlaylistOrder.first(among: [url("/m/a.txt")]) == nil && PlaylistOrder.first(among: []) == nil)
        print("a folder plays in Finder order: 2 before 10, the same however it was listed: ok")

        let two = url("/m/2 Two.mp3")
        precondition(PlaylistOrder.neighbour(of: two, kind: .music, among: folder, step: 1) == url("/m/10 Ten.mp3"))
        precondition(PlaylistOrder.neighbour(of: two, kind: .music, among: folder, step: -1) == url("/m/1 One.flac"), "a video between two songs must be skipped")
        precondition(PlaylistOrder.neighbour(of: url("/m/Film.mkv"), kind: .video, among: folder + [url("/m/Film.mkv")], step: -1) == url("/m/02 Film.mkv"))
        precondition(PlaylistOrder.neighbour(of: url("/m/Intro.mp3"), kind: .music, among: folder, step: 1) == nil, "the last file has no next one and must not wrap around")
        precondition(PlaylistOrder.neighbour(of: url("/m/1 One.flac"), kind: .music, among: folder, step: -1) == nil)
        precondition(PlaylistOrder.neighbour(of: url("/m/gone.mp3"), kind: .music, among: folder, step: 1) == nil && PlaylistOrder.neighbour(of: two, kind: .music, among: [], step: 1) == nil)
        precondition(PlaylistOrder.neighbour(of: url("/m/10 Ten.mp3"), kind: .music, among: folder, step: 5) == nil)
        let odd = url("/m/Odd.xyz")
        precondition(PlaylistOrder.neighbour(of: odd, kind: .music, among: folder + [odd], step: -1) == url("/m/Intro.mp3"), "the open file stays in its own list even if its type is unknown")
        print("next and previous skip the other kind, never wrap, and never crash on a missing file: ok")

        precondition(PlaylistFolders.covers(url("/Users/a/Music"), url("/Users/a/Music")) && PlaylistFolders.covers(url("/Users/a/Music"), url("/Users/a/Music/Album")))
        precondition(!PlaylistFolders.covers(url("/Users/a/Music"), url("/Users/a/Music2")) && !PlaylistFolders.covers(url("/Users/a/Music"), url("/Users/a")) && !PlaylistFolders.covers(url("/Users/a/Music"), url("/Users/b/Music")))
        precondition(PlaylistFolders.covers(url("/"), url("/Users/a")), "the whole disk covers every folder")
        print("an allowed folder covers itself and what is inside it, and nothing next to it: ok")

        precondition(PlayerTags.title("Тест — 音楽 🎵", file: url("/m/a.mp3")) == "Тест — 音楽 🎵" && PlayerTags.title(nil, file: url("/m/My Song.flac")) == "My Song" && PlayerTags.title("  \n ", file: url("/m/a.b.mp3")) == "a.b")
        precondition(PlayerTags.subtitle(artist: "Артист Ω", album: "Альбом №1") == "Артист Ω — Альбом №1" && PlayerTags.subtitle(artist: "A", album: nil) == "A" && PlayerTags.subtitle(artist: " ", album: "B") == "B" && PlayerTags.subtitle(artist: nil, album: "") == "")
        print("a song shows its tags, or its file name when the title is empty, and skips empty artist and album: ok")
    }

    static func checkDefaultApps() async {
        let folder = FileManager.default.temporaryDirectory.appending(path: "pika-default-apps-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: folder) }
        func app(_ name: String) -> URL {
            let url = folder.appending(path: "\(name).app")
            try? FileManager.default.createDirectory(at: url.appending(path: "Contents"), withIntermediateDirectories: true)
            NSDictionary(dictionary: ["CFBundleIdentifier": "test.\(name)", "CFBundleName": name]).write(to: url.appending(path: "Contents/Info.plist"), atomically: true)
            return url
        }
        let (ours, old, gone, next, fallback) = (app("Ours"), app("Old"), app("Gone"), app("Next"), app("Fallback"))
        let (a, b, c, d) = (UTType.avi, UTType.mpeg4Movie, UTType.quickTimeMovie, UTType.mpeg2TransportStream)

        let system = FakeSystem(installed: [ours, old, gone, next, fallback])
        system.candidates = [a.identifier: [old, ours], b.identifier: [gone, next, ours], c.identifier: [ours, next]]
        let defaults = UserDefaults(suiteName: "pika-default-apps-\(UUID().uuidString)")!
        let videos = DefaultApps(types: [a, b, c, d], target: ours, previousKey: "previous", system: system, defaults: defaults)
        precondition(!videos.isOn)

        await videos.set(true).value
        precondition(videos.isOn && [a, b, c, d].allSatisfy { system.handler(of: $0) == ours }, "every type should go to the player")
        precondition(defaults.dictionary(forKey: "previous") as? [String: String] == [a.identifier: "test.Old", b.identifier: "test.Gone"], "the old apps are not remembered, or the player itself was")
        print("turning on remembers each type's old app and gives every type to the player: ok")

        try? FileManager.default.removeItem(at: gone)
        system.installed.removeAll { $0 == gone }
        system.candidates[b.identifier]?.removeAll { $0 == gone }
        await videos.set(false).value
        precondition(system.handler(of: a) == old, "the remembered app is not back")
        precondition(system.handler(of: b) == next, "an app that is gone should give way to the next one that opens the type, not to the player")
        precondition(system.handler(of: c) == ours && system.handler(of: d) == ours, "a type the player already had, or nobody had, must stay as it was")
        precondition(!videos.isOn && defaults.object(forKey: "previous") == nil)
        print("turning off returns the old apps, the next one if an app is gone, and leaves types that had no other app: ok")

        system.candidates = [a.identifier: [old, ours]]
        system.failAfter = 0
        await videos.set(true).value
        precondition(system.handler(of: a) == old && !videos.isOn, "a refused change should stop quietly and show the real state")
        system.failAfter = nil
        await videos.set(true).value
        await videos.set(true).value
        await videos.set(false).value
        precondition(system.handler(of: a) == old, "turning on twice must not forget the old app")
        print("a refused change stops quietly, and turning on again keeps the old apps: ok")

        let e = UTType.mpeg
        let plain = DefaultApps(types: [a, d, e], target: ours, previousKey: "plain", fallback: "test.Fallback", system: system, defaults: defaults)
        await plain.set(true).value
        system.candidates[d.identifier] = [ours, fallback]
        await plain.set(false).value
        precondition(system.handler(of: a) == old && system.handler(of: d) == fallback, "a system app should take a type that had none and that it can open")
        precondition(system.handler(of: e) == ours, "a system app that can’t open the type must not take it")
        print("a system fallback takes only the types it can open and that had no other app: ok")

        system.candidates = [a.identifier: [old, ours], b.identifier: [next, ours], c.identifier: [next, ours]]
        let formats = DefaultApps(types: [a, b, c], target: ours, previousKey: "formats", system: system, defaults: defaults)
        await formats.set(true, for: [a]).value
        precondition(formats.isOn([a]) && !formats.isOn([b]) && !formats.isOn && formats.app(of: [a]) == ours && formats.app(of: [b]) == next, "one format should change alone")
        precondition(system.handler(of: b) == next && system.handler(of: c) == next, "the other formats must stay as they were")
        await formats.set(false, for: [a]).value
        precondition(system.handler(of: a) == old && defaults.object(forKey: "formats") == nil && formats.app(of: [a]) == old)
        print("one format changes and returns alone: ok")

        system.keep = [b.identifier]
        await formats.set(true).value
        precondition(system.handler(of: a) == ours && system.handler(of: b) == next && system.handler(of: c) == ours && !formats.busy, "Keep on one format must not stop the next ones")
        system.keep = [a.identifier]
        await formats.set(false).value
        precondition(system.handler(of: a) == ours && system.handler(of: c) == next, "Keep on turning off must not stop the next ones")
        precondition((defaults.dictionary(forKey: "formats") as? [String: String])?[a.identifier] == "test.Old", "a format that stayed with the player must keep its old app")
        system.keep = []
        await formats.set(false).value
        precondition(system.handler(of: a) == old && defaults.object(forKey: "formats") == nil)
        print("Keep moves on to the next format and keeps the old app for later: ok")

        system.silent = true
        await formats.set(true, for: [a, b]).value
        precondition(formats.isOn([a, b]), "a system that never answers but changes the app must not stall")
        print("no answer from the system, but the app changed: ok")
    }
}

final class FakeSystem: DefaultAppSystem {
    var installed: [URL]
    var candidates: [String: [URL]] = [:]
    var failAfter: Int?
    var keep: Set<String> = []
    var silent = false
    var assigns = 0

    init(installed: [URL]) {
        self.installed = installed
    }

    struct Refused: Error {}

    func handler(of type: UTType) -> URL? { candidates[type.identifier]?.first }
    func handlers(of type: UTType) -> [URL] { candidates[type.identifier] ?? [] }
    func app(withID id: String) -> URL? { installed.first { Bundle(url: $0)?.bundleIdentifier == id } }

    @MainActor func assign(_ app: URL, to type: UTType) async throws {
        assigns += 1
        if let failAfter, assigns > failAfter { throw Refused() }
        if keep.contains(type.identifier) { throw NSError(domain: NSCocoaErrorDomain, code: 256, userInfo: [NSUnderlyingErrorKey: NSError(domain: NSOSStatusErrorDomain, code: Int(userCanceledErr))]) }
        candidates[type.identifier] = [app] + (candidates[type.identifier] ?? []).filter { $0 != app }
        if silent { try await Task.sleep(for: .seconds(3600)) }
    }
}
