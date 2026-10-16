import AppKit
import CryptoKit
import Foundation
import UniformTypeIdentifiers

enum PlayerKind {
    case music, video
}

enum PlayerFormats {
    static let video: [(name: String, extensions: [String])] = [
        ("MKV", ["mkv"]), ("WebM", ["webm"]), ("AVI", ["avi"]), ("WMV", ["wmv", "asf"]), ("FLV", ["flv"]), ("OGV", ["ogv"]),
        ("MPEG-TS", ["ts", "m2ts", "mts"]), ("MPEG", ["mpg", "mpeg"]), ("MXF", ["mxf"]), ("MP4", ["mp4", "m4v"]), ("MOV", ["mov"]),
    ]

    static let music: [(name: String, extensions: [String])] = [
        ("MP3", ["mp3"]), ("AAC", ["aac"]), ("M4A", ["m4a"]), ("FLAC", ["flac"]), ("ALAC", ["alac"]), ("WAV", ["wav"]), ("AIFF", ["aiff", "aif"]),
        ("CAF", ["caf"]), ("OGG", ["ogg", "oga"]), ("Opus", ["opus"]), ("WMA", ["wma"]), ("APE", ["ape"]), ("DSF", ["dsf"]),
    ]

    static var extensions: [String] { (video + music).flatMap(\.extensions) }

    static var videoTypes: [UTType] { types(of: video.flatMap(\.extensions)) }

    static var musicTypes: [UTType] { types(of: music.flatMap(\.extensions)) }

    static func types(of extensions: [String]) -> [UTType] {
        var seen = Set<UTType>()
        return extensions.compactMap { UTType(filenameExtension: $0) }.filter { !$0.isDynamic && seen.insert($0).inserted }
    }

    static func kind(of url: URL) -> PlayerKind? {
        let ext = url.pathExtension.lowercased()
        return video.contains { $0.extensions.contains(ext) } ? .video : music.contains { $0.extensions.contains(ext) } ? .music : nil
    }

    static func plays(_ url: URL) -> Bool {
        kind(of: url) != nil
    }
}

enum PlaylistOrder {
    static func sorted(_ files: [URL]) -> [URL] {
        files.sorted {
            let order = $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent)
            return order == .orderedSame ? $0.path < $1.path : order == .orderedAscending
        }
    }

    static func neighbour(of current: URL, kind: PlayerKind, among files: [URL], step: Int) -> URL? {
        let here = current.standardizedFileURL
        let list = sorted(files.filter { $0.standardizedFileURL == here || PlayerFormats.kind(of: $0) == kind })
        guard let index = list.firstIndex(where: { $0.standardizedFileURL == here }), list.indices.contains(index + step) else { return nil }
        return list[index + step]
    }

    static func first(among files: [URL]) -> URL? {
        sorted(files.filter(PlayerFormats.plays)).first
    }
}

enum PlaylistFolders {
    static func covers(_ granted: URL, _ folder: URL) -> Bool {
        let (allowed, wanted) = (granted.resolvingSymlinksInPath().pathComponents, folder.resolvingSymlinksInPath().pathComponents)
        return wanted.count >= allowed.count && Array(wanted.prefix(allowed.count)) == allowed
    }
}

enum PlayerTags {
    static func title(_ tag: String?, file: URL) -> String {
        clean(tag) ?? file.deletingPathExtension().lastPathComponent
    }

    static func subtitle(artist: String?, album: String?) -> String {
        [artist, album].compactMap(clean).joined(separator: " — ")
    }

    static func clean(_ text: String?) -> String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        return text
    }
}

enum PlayerAction: Equatable {
    case playPause, back, forward, skipBack, skipForward, longBack, longForward, frameBack, frameForward, start, end, startOver
    case slower, faster, normalSpeed, louder, quieter, mute, fullScreen, leaveFullScreen, snapshot, floatOnTop, next, previous
    case nextSubtitle, nextAudio, subtitleEarlier, subtitleLater, subtitleLarger, subtitleSmaller
    case nextChapter, previousChapter, loop, pictureInPicture

    static let skip = 5.0
    static let longSkip = 10.0
    static let volumeStep: Float = 0.1

    private static let (left, right, up, down) = ("\u{F702}", "\u{F703}", "\u{F700}", "\u{F701}")
    private static let (pageUp, pageDown) = ("\u{F72C}", "\u{F72D}")

    static let bindings: [(action: PlayerAction, key: String, modifiers: NSEvent.ModifierFlags)] = [
        (.playPause, " ", []), (.playPause, "k", []),
        (.back, left, []), (.forward, right, []),
        (.skipBack, left, .shift), (.skipForward, right, .shift),
        (.longBack, "j", []), (.longForward, "l", []),
        (.frameBack, ",", []), (.frameForward, ".", []),
        (.start, left, .option), (.end, right, .option),
        (.slower, left, .command), (.faster, right, .command),
        (.slower, "[", []), (.faster, "]", []), (.normalSpeed, "\u{7F}", []),
        (.louder, up, []), (.quieter, down, []), (.mute, "m", []),
        (.fullScreen, "f", []), (.fullScreen, "f", .command), (.fullScreen, "f", [.command, .control]), (.leaveFullScreen, "\u{1B}", []),
        (.snapshot, "s", []), (.floatOnTop, "t", []),
        (.next, "n", []), (.next, ">", .shift), (.previous, "p", []), (.previous, "<", .shift),
        (.nextSubtitle, "v", []), (.nextAudio, "3", .shift), (.subtitleEarlier, "z", []), (.subtitleLater, "x", []),
        (.subtitleLarger, "f", .shift), (.subtitleSmaller, "g", .shift),
        (.nextChapter, pageDown, []), (.previousChapter, pageUp, []), (.loop, "a", []), (.pictureInPicture, "p", [.command, .option]),
    ]

    private static let positions: [UInt16: String] = [1: "s", 3: "f", 5: "g", 6: "z", 7: "x", 9: "v", 17: "t", 20: "3", 30: "]", 33: "[", 35: "p", 37: "l", 38: "j", 40: "k", 43: ",", 45: "n", 46: "m", 47: "."]

    init?(key: String, modifiers: NSEvent.ModifierFlags = [], keyCode: UInt16? = nil) {
        let held = modifiers.intersection([.command, .control, .option, .shift])
        func action(_ key: String) -> PlayerAction? { Self.bindings.first { $0.key == key && $0.modifiers == held }?.action }
        guard let found = action(key.lowercased()) ?? keyCode.flatMap({ Self.positions[$0] }).flatMap(action) else { return nil }
        self = found
    }

    func resolved(playing: Bool) -> PlayerAction {
        switch self {
        case .back: playing ? .skipBack : .frameBack
        case .forward: playing ? .skipForward : .frameForward
        default: self
        }
    }
}

enum PlayerSpeed {
    static let all: [Float] = [0.5, 0.75, 1, 1.25, 1.5, 2]

    static func stepped(_ speed: Float, _ direction: Int) -> Float {
        direction > 0 ? all.first { $0 > speed + 0.001 } ?? all[all.count - 1] : all.last { $0 < speed - 0.001 } ?? all[0]
    }
}

struct PlayerWheel {
    static let deadZone = 8.0
    static let notch = 20.0
    static let pause = 0.4
    static let volumePerPoint: Float = 0.005
    static let secondsPerPoint = 0.25

    private var pending = (x: 0.0, y: 0.0)
    private var open = false
    private var last = -Double.infinity

    mutating func add(right: Double, up: Double, precise: Bool, began: Bool, at time: Double) -> (volume: Float, seconds: Double) {
        if began || time - last > Self.pause { self = PlayerWheel() }
        last = time
        let scale = precise ? 1 : Self.notch
        if abs(up) >= abs(right) { pending = (0, pending.y + up * scale) } else { pending = (pending.x + right * scale, 0) }
        guard open || max(abs(pending.x), abs(pending.y)) >= Self.deadZone else { return (0, 0) }
        open = true
        defer { pending = (0, 0) }
        return (Float(pending.y) * Self.volumePerPoint, pending.x * Self.secondsPerPoint)
    }
}

enum PlayerResume {
    static let limit = 200
    static let watched = 60.0
    static let remaining = 30.0

    static func key(path: String, size: Int64, modified: Date) -> String {
        SHA256.hash(data: Data("\(path)|\(size)|\(Int64(modified.timeIntervalSince1970))".utf8)).prefix(16).map { String(format: "%02x", $0) }.joined()
    }

    static func worthKeeping(_ position: Double, of duration: Double) -> Bool {
        position > watched && duration - position > remaining
    }

    static func updated(_ saved: [String: [Double]], key: String, position: Double, duration: Double, at now: Double) -> [String: [Double]] {
        var saved = saved
        guard worthKeeping(position, of: duration) else {
            saved[key] = nil
            return saved
        }
        saved[key] = [position, now]
        while saved.count > limit, let oldest = saved.min(by: { $0.value[1] < $1.value[1] })?.key { saved[oldest] = nil }
        return saved
    }
}

enum PlayerTime {
    static func text(_ seconds: Double) -> String {
        let total = seconds.isFinite ? max(0, Int(seconds.rounded(.down))) : 0
        let (hours, minutes, rest) = (total / 3600, total / 60 % 60, total % 60)
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, rest) : String(format: "%d:%02d", minutes, rest)
    }

    static func clamp(_ target: Double, duration: Double) -> Double {
        guard target.isFinite else { return 0 }
        return max(0, duration.isFinite && duration > 0 ? min(target, duration) : target)
    }

    static func volume(_ volume: Float, by step: Float) -> Float {
        max(0, min(1, ((volume + step) * 10).rounded() / 10))
    }

    static func snapshotName(_ file: String, at seconds: Double) -> String {
        "\((file as NSString).deletingPathExtension) \(text(seconds).replacingOccurrences(of: ":", with: ".")).png"
    }
}

enum PlayerChrome {
    static let hideDelay = 2.5

    static func visibility(playing: Bool, overControls: Bool, fullScreen: Bool, idle: Double, hides: Bool = true) -> (controls: Bool, cursor: Bool) {
        let controls = !hides || !playing || overControls || idle < hideDelay
        return (controls, controls || !fullScreen)
    }
}

enum PlayerThumbnail {
    static let buckets = 100
    static let box = CGSize(width: 160, height: 90)

    static func bucket(_ seconds: Double, duration: Double) -> Int {
        guard seconds.isFinite, duration.isFinite, duration > 0 else { return 0 }
        return max(0, min(buckets - 1, Int(seconds / duration * Double(buckets))))
    }

    static func time(of bucket: Int, duration: Double) -> Double {
        (Double(bucket) + 0.5) * duration / Double(buckets)
    }

    static func size(for video: CGSize) -> CGSize {
        guard video.width > 0, video.height > 0 else { return box }
        let scale = min(box.width / video.width, box.height / video.height)
        return CGSize(width: max(2, (video.width * scale / 2).rounded() * 2), height: max(2, (video.height * scale / 2).rounded() * 2))
    }

    static func nearest(to bucket: Int, ready: (Int) -> Bool) -> Int? {
        for distance in 0..<buckets {
            for candidate in [bucket - distance, bucket + distance] where (0..<buckets).contains(candidate) && ready(candidate) { return candidate }
        }
        return nil
    }
}
