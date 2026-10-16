import Foundation

enum PlayerChapters {
    static let tolerance = 0.05
    static let restart = 3.0

    static func current(_ starts: [Double], at time: Double) -> Int? {
        starts.lastIndex { $0 <= time + tolerance }
    }

    static func next(_ starts: [Double], after time: Double) -> Double? {
        starts.first { $0 > time + tolerance }
    }

    static func previous(_ starts: [Double], before time: Double) -> Double {
        guard let index = current(starts, at: time) else { return 0 }
        return time - starts[index] > restart ? starts[index] : index > 0 ? starts[index - 1] : 0
    }

    static func fractions(_ starts: [Double], duration: Double) -> [Double] {
        guard duration.isFinite, duration > 0 else { return [] }
        return starts.map { $0 / duration }.filter { $0 > 0 && $0 < 1 }
    }
}

struct PlayerLoop: Equatable {
    static let shortest = 0.5

    private(set) var start: Double?
    private(set) var end: Double?

    var isSet: Bool { end != nil }

    mutating func press(at time: Double) {
        switch (start, end) {
        case (nil, _):
            start = time
        case let (first?, nil):
            guard abs(time - first) >= Self.shortest else { return }
            (start, end) = (min(first, time), max(first, time))
        default:
            self = PlayerLoop()
        }
    }

    func wrap(at time: Double) -> Double? {
        guard let start, let end, time >= end else { return nil }
        return start
    }
}
