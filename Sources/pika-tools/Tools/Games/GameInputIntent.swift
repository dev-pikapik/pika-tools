import CoreGraphics

struct GameInputIntent {
    var held: Set<Int64> = []
    private var modifiers: UInt64 = 0
    private var started: UInt64?
    private var lastDuration: UInt64 = .max

    init(held: Set<Int64> = []) { self.held = held }

    mutating func changed(_ flags: CGEventFlags, at time: UInt64) {
        let next = flags.rawValue & 0x9E0000
        if modifiers == 0, next != 0 { started = time }
        if modifiers != 0, next == 0 {
            lastDuration = started.map { time >= $0 ? time - $0 : .max } ?? .max
            started = nil
        }
        modifiers = next
    }

    func allows(_ key: Int64?, flags: CGEventFlags, at time: UInt64) -> Bool {
        guard held.subtracting(key.map { [$0] } ?? []).isEmpty else { return false }
        if flags.rawValue & 0x9E0000 == 0 { return key == nil ? lastDuration <= 450_000_000 : true }
        guard let started, time >= started else { return false }
        return time - started <= 450_000_000
    }

    mutating func pressed(_ key: Int64, down: Bool) {
        if down { held.insert(key) } else { held.remove(key) }
    }
}
