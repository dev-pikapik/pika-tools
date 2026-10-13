import Foundation
import IOKit

enum SMCCodec {
    static func fourCC(_ text: String) -> UInt32 {
        text.utf8.prefix(4).reduce(0) { $0 << 8 | UInt32($1) }
    }

    static func string(_ code: UInt32) -> String {
        String(decoding: (0..<4).map { UInt8(truncatingIfNeeded: code >> UInt32(24 - 8 * $0)) }, as: UTF8.self)
    }

    static func decode(type: String, bytes: [UInt8]) -> Double? {
        switch type {
        case "flt " where bytes.count >= 4:
            let value = Float(bitPattern: bytes[0..<4].reversed().reduce(0) { $0 << 8 | UInt32($1) })
            return value.isFinite ? Double(value) : nil
        case "fpe2" where bytes.count >= 2:
            return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1])) / 4
        case "ui8 " where !bytes.isEmpty:
            return Double(bytes[0])
        case "ui16" where bytes.count >= 2:
            return Double(UInt16(bytes[0]) << 8 | UInt16(bytes[1]))
        case "ui32" where bytes.count >= 4:
            return Double(bytes[0..<4].reduce(UInt32(0)) { $0 << 8 | UInt32($1) })
        case "sp78" where bytes.count >= 2:
            return Double(Int16(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1]))) / 256
        default:
            return nil
        }
    }

    static func encode(type: String, value: Double) -> [UInt8]? {
        guard value.isFinite, value >= 0 else { return nil }
        switch type {
        case "flt ":
            let bits = Float(value).bitPattern
            return (0..<4).map { UInt8(truncatingIfNeeded: bits >> UInt32(8 * $0)) }
        case "fpe2":
            let raw = UInt16(min(value * 4, 65535).rounded())
            return [UInt8(raw >> 8), UInt8(raw & 0xFF)]
        case "ui8 ":
            return value <= 255 ? [UInt8(value.rounded())] : nil
        default:
            return nil
        }
    }

    static func clamp(_ rpm: Double, min low: Double, max high: Double) -> Double {
        guard high >= low else { return low }
        return Swift.min(Swift.max(rpm, low), high)
    }
}

struct SMCFan: Equatable {
    let id: Int
    var current: Double
    var minimum: Double
    var maximum: Double
    var manual: Bool
}

final class SMC {
    private struct Version {
        var major: UInt8 = 0, minor: UInt8 = 0, build: UInt8 = 0, reserved: UInt8 = 0
        var release: UInt16 = 0
    }

    private struct Limit {
        var version: UInt16 = 0, length: UInt16 = 0
        var cpu: UInt32 = 0, gpu: UInt32 = 0, memory: UInt32 = 0
    }

    private struct Info {
        var size: UInt32 = 0, type: UInt32 = 0
        var attributes: UInt8 = 0
    }

    private typealias Bytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                               UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    private struct Call {
        var key: UInt32 = 0
        var version = Version()
        var limit = Limit()
        var info = Info()
        var padding: UInt16 = 0
        var result: UInt8 = 0, status: UInt8 = 0, command: UInt8 = 0
        var data: UInt32 = 0
        var bytes: Bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    static let callSize = MemoryLayout<Call>.size

    private enum Command {
        static let write: UInt8 = 6, read: UInt8 = 5, key: UInt8 = 8, info: UInt8 = 9
    }

    private var connection: io_connect_t = 0

    init?() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        guard IOServiceOpen(service, mach_task_self_, 0, &connection) == kIOReturnSuccess else { return nil }
    }

    deinit { IOServiceClose(connection) }

    private func call(_ input: Call) -> Call? {
        var input = input, output = Call()
        var size = Self.callSize
        let status = IOConnectCallStructMethod(connection, 2, &input, Self.callSize, &output, &size)
        return status == kIOReturnSuccess && output.result == 0 ? output : nil
    }

    private func info(_ key: String) -> Info? {
        var input = Call()
        input.key = SMCCodec.fourCC(key)
        input.command = Command.info
        return call(input)?.info
    }

    func read(_ key: String) -> (type: String, bytes: [UInt8])? {
        guard let info = info(key), info.size > 0, info.size <= 32 else { return nil }
        var input = Call()
        input.key = SMCCodec.fourCC(key)
        input.info.size = info.size
        input.command = Command.read
        guard let output = call(input) else { return nil }
        let bytes = withUnsafeBytes(of: output.bytes) { Array($0.prefix(Int(info.size))) }
        return (SMCCodec.string(info.type), bytes)
    }

    func value(_ key: String) -> Double? {
        read(key).flatMap { SMCCodec.decode(type: $0.type, bytes: $0.bytes) }
    }

    func keys() -> [String] {
        guard let count = value("#KEY") else { return [] }
        return (0..<Int(count)).compactMap { index in
            var input = Call()
            input.command = Command.key
            input.data = UInt32(index)
            return call(input).map { SMCCodec.string($0.key) }
        }
    }

    @discardableResult
    func write(_ key: String, _ value: Double) -> Bool {
        guard let info = info(key), info.size > 0, info.size <= 32,
              let encoded = SMCCodec.encode(type: SMCCodec.string(info.type), value: value),
              encoded.count == Int(info.size)
        else { return false }
        var input = Call()
        input.key = SMCCodec.fourCC(key)
        input.info.size = info.size
        input.command = Command.write
        withUnsafeMutableBytes(of: &input.bytes) { $0.copyBytes(from: encoded) }
        return call(input) != nil
    }

    var count: Int { Int(value("FNum") ?? 0) }

    var hasUnlock: Bool { info("Ftst") != nil }

    private var modeKey: (Int) -> String {
        let lower = (read("F0md")?.bytes.isEmpty == false)
        return { "F\($0)\(lower ? "md" : "Md")" }
    }

    func fans() -> [SMCFan] {
        let mode = modeKey
        return (0..<count).compactMap { id in
            guard let current = value("F\(id)Ac"), let low = value("F\(id)Mn"), let high = value("F\(id)Mx"), high > low else { return nil }
            return SMCFan(id: id, current: current, minimum: low, maximum: high, manual: value(mode(id)) == 1)
        }
    }

    func setManual(fan id: Int, rpm: Double) -> Bool {
        guard id >= 0, id < count, let low = value("F\(id)Mn"), let high = value("F\(id)Mx") else { return false }
        let mode = modeKey(id)
        if !write(mode, 1) {
            guard hasUnlock, write("Ftst", 1) else { return false }
            var unlocked = false
            for _ in 0..<20 where !unlocked {
                Thread.sleep(forTimeInterval: 0.5)
                unlocked = write(mode, 1)
            }
            guard unlocked else { write("Ftst", 0); return false }
        }
        guard write("F\(id)Tg", SMCCodec.clamp(rpm, min: low, max: high)) else { setAuto(fan: id); return false }
        return true
    }

    func setAuto(fan id: Int) {
        guard id >= 0, id < count else { return }
        write(modeKey(id), 0)
        write("F\(id)Tg", 0)
        if hasUnlock, !fans().contains(where: \.manual) { write("Ftst", 0) }
    }
}
