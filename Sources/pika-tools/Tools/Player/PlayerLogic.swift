import Foundation

enum PlayerFormats {
    static let all: [(name: String, extensions: [String])] = [
        ("MKV", ["mkv"]), ("WebM", ["webm"]), ("AVI", ["avi"]), ("WMV", ["wmv", "asf"]), ("FLV", ["flv"]), ("OGV", ["ogv"]),
        ("MPEG-TS", ["ts", "m2ts", "mts"]), ("MPEG", ["mpg", "mpeg"]), ("MXF", ["mxf"]), ("MP4", ["mp4", "m4v"]), ("MOV", ["mov"]),
    ]

    static var extensions: [String] { all.flatMap(\.extensions) }

    static func plays(_ url: URL) -> Bool {
        extensions.contains(url.pathExtension.lowercased())
    }
}

enum PlayerAction: Equatable {
    case playPause, back, forward, louder, quieter, fullScreen, leaveFullScreen

    static let skip = 5.0
    static let volumeStep: Float = 0.1

    init?(key: String) {
        switch key {
        case " ": self = .playPause
        case "\u{F702}": self = .back
        case "\u{F703}": self = .forward
        case "\u{F700}": self = .louder
        case "\u{F701}": self = .quieter
        case "f", "F": self = .fullScreen
        case "\u{1B}": self = .leaveFullScreen
        default: return nil
        }
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
}
