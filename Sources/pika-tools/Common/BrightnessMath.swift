import Foundation

enum BrightnessMath {
    static func pictureScale(_ level: Double) -> Double {
        0.2 + 0.8 * min(max(level, 0), 1)
    }

    static func step(_ level: Double, up: Bool, fine: Bool) -> Double {
        let size = fine ? 1.0 / 64 : 1.0 / 16
        return min(max(((level / size).rounded() + (up ? 1 : -1)) * size, 0), 1)
    }

    #if !APPSTORE
    static func restarted(_ before: [String], _ after: [String], wrote: [String: Date], now: Date = Date()) -> [String] {
        before.filter { !after.contains($0) && now.timeIntervalSince(wrote[$0] ?? .distantPast) < 10 }
    }

    enum Reply: Equatable {
        case value(current: Int, maximum: Int)
        case unsupported
    }

    static func writeBrightness(_ value: Int) -> [UInt8] {
        let body: [UInt8] = [0x84, 0x03, 0x10, UInt8(value >> 8 & 0xFF), UInt8(value & 0xFF)]
        return body + [body.reduce(0x6E ^ 0x51, ^)]
    }

    static let readBrightness: [UInt8] = [0x82, 0x01, 0x10, [0x82, 0x01, 0x10].reduce(0x6E ^ 0x51, ^)]

    static func reply(_ bytes: [UInt8]) -> Reply? {
        if let reply = parse(bytes) { return reply }
        let doubled = bytes.indices.dropFirst().filter { bytes[$0] == bytes[$0 - 1] }
        for i in doubled {
            var once = bytes
            once.remove(at: i)
            if let reply = parse(once) { return reply }
        }
        for i in doubled {
            for j in doubled where j < i {
                var twice = bytes
                twice.remove(at: i)
                twice.remove(at: j)
                if let reply = parse(twice) { return reply }
            }
        }
        return nil
    }

    private static func parse(_ bytes: [UInt8]) -> Reply? {
        guard bytes.count >= 11 else { return nil }
        for s in 0...(bytes.count - 11) where bytes[s] == 0x6E && bytes[s + 1] == 0x88 && bytes[s + 2] == 0x02 {
            let m = Array(bytes[s..<s + 11])
            guard m[0..<10].reduce(0x50, ^) == m[10] else { continue }
            if m[3] != 0 { return .unsupported }
            let maximum = Int(m[6]) << 8 | Int(m[7]), current = Int(m[8]) << 8 | Int(m[9])
            if m[4] == 0x10, maximum > 0, current <= maximum { return .value(current: current, maximum: maximum) }
        }
        return nil
    }

    static func identity(edid: [UInt8]) -> (vendor: UInt32, model: UInt32, serial: UInt32)? {
        guard edid.count >= 16, edid.starts(with: [0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00]) else { return nil }
        let vendor = UInt32(edid[8]) << 8 | UInt32(edid[9])
        let model = UInt32(edid[10]) | UInt32(edid[11]) << 8
        let serial = UInt32(edid[12]) | UInt32(edid[13]) << 8 | UInt32(edid[14]) << 16 | UInt32(edid[15]) << 24
        return (vendor, model, serial)
    }
    #endif
}
