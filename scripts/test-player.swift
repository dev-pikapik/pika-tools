import AppKit
import Foundation

@main
enum TestPlayer {
    static func main() {
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
            (up, .option, nil), (left, [.shift, .option], nil), ("f", .option, nil), ("a", [], nil), ("", [], nil),
        ]
        for (key, modifiers, action) in keys {
            precondition(PlayerAction(key: key, modifiers: modifiers) == action, "key \(key.unicodeScalars.map { String($0.value, radix: 16) }) \(modifiers.rawValue)")
        }
        precondition(PlayerAction(key: left, modifiers: [.shift, .function, .numericPad]) == .skipBack, "arrow keys always carry the function flag")
        let bound = Set(PlayerAction.bindings.map(\.action))
        for action in [PlayerAction.playPause, .back, .forward, .skipBack, .skipForward, .longBack, .longForward, .frameBack, .frameForward, .start, .end, .slower, .faster, .normalSpeed, .louder, .quieter, .mute, .fullScreen, .leaveFullScreen, .snapshot, .floatOnTop] {
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
        precondition(Set(entitlements.allKeys as! [String]) == ["com.apple.security.app-sandbox", "com.apple.security.files.user-selected.read-write"], "\(entitlements.allKeys)")
        let types = documents.flatMap { $0["LSItemContentTypes"] as? [String] ?? [] }
        let claimed = documents.flatMap { $0["CFBundleTypeExtensions"] as? [String] ?? [] }
        let system = ["avi": "public.avi", "ts": "public.mpeg-2-transport-stream", "m2ts": "public.avchd-mpeg-2-transport-stream", "mts": "public.avchd-mpeg-2-transport-stream",
                      "mpg": "public.mpeg", "mpeg": "public.mpeg", "mp4": "public.mpeg-4", "m4v": "com.apple.m4v-video", "mov": "com.apple.quicktime-movie"]
        for ext in extensions {
            precondition(claimed.contains(ext) || system[ext].map(types.contains) == true, ".\(ext) is in the Settings list but the player does not open it")
        }
        precondition(plist["LSMinimumSystemVersion"] as? String == "14.0")
        print("every listed format opens in the player, which never takes over as the default app and may only write where you choose: ok")
    }
}
