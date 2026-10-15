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

        let keys: [(String, PlayerAction?)] = [(" ", .playPause), ("\u{F702}", .back), ("\u{F703}", .forward), ("\u{F700}", .louder), ("\u{F701}", .quieter),
                                               ("f", .fullScreen), ("F", .fullScreen), ("\u{1B}", .leaveFullScreen), ("a", nil), ("", nil)]
        for (key, action) in keys {
            precondition(PlayerAction(key: key) == action, "key \(key.unicodeScalars.map { String($0.value, radix: 16) })")
        }
        precondition(PlayerAction.skip == 5)
        print("Space, arrows, F and Esc do what the menus say: ok")

        let extensions = PlayerFormats.extensions
        precondition(Set(extensions).count == extensions.count, "an extension is listed twice")
        precondition(PlayerFormats.plays(URL(fileURLWithPath: "/a/Film.MKV")) && !PlayerFormats.plays(URL(fileURLWithPath: "/a/notes.txt")))
        let plist = NSDictionary(contentsOfFile: "Helper/Player/Info.plist")!
        let documents = plist["CFBundleDocumentTypes"] as! [[String: Any]]
        precondition(documents.allSatisfy { $0["LSHandlerRank"] as? String == "Alternate" }, "the player must never ask to be the default app")
        precondition(plist["UTImportedTypeDeclarations"] == nil && plist["UTExportedTypeDeclarations"] == nil, "the player must not change how macOS names file types")
        let types = documents.flatMap { $0["LSItemContentTypes"] as? [String] ?? [] }
        let claimed = documents.flatMap { $0["CFBundleTypeExtensions"] as? [String] ?? [] }
        let system = ["avi": "public.avi", "ts": "public.mpeg-2-transport-stream", "m2ts": "public.avchd-mpeg-2-transport-stream", "mts": "public.avchd-mpeg-2-transport-stream",
                      "mpg": "public.mpeg", "mpeg": "public.mpeg", "mp4": "public.mpeg-4", "m4v": "com.apple.m4v-video", "mov": "com.apple.quicktime-movie"]
        for ext in extensions {
            precondition(claimed.contains(ext) || system[ext].map(types.contains) == true, ".\(ext) is in the Settings list but the player does not open it")
        }
        precondition(plist["LSMinimumSystemVersion"] as? String == "14.0")
        print("every listed format opens in the player, which never takes over as the default app: ok")
    }
}
