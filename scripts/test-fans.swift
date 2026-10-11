import Foundation

@main
enum TestFans {
    static func main() {
        precondition(SMC.callSize == 80, "SMC call struct is \(SMC.callSize) bytes")

        precondition(SMCCodec.fourCC("FNum") == 0x464E756D)
        precondition(SMCCodec.string(SMCCodec.fourCC("F0Ac")) == "F0Ac")

        let bytes = SMCCodec.encode(type: "flt ", value: 2500)!
        precondition(bytes == [0, 0x40, 0x1C, 0x45], "flt little-endian: \(bytes)")
        precondition(SMCCodec.decode(type: "flt ", bytes: bytes) == 2500)
        precondition(SMCCodec.decode(type: "flt ", bytes: [0, 0, 0xC0, 0x7F]) == nil)

        precondition(SMCCodec.encode(type: "fpe2", value: 1200) == [0x12, 0xC0])
        precondition(SMCCodec.decode(type: "fpe2", bytes: [0x12, 0xC0]) == 1200)
        precondition(SMCCodec.decode(type: "fpe2", bytes: [0x12, 0xC1]) == 1200.25)

        precondition(SMCCodec.decode(type: "ui8 ", bytes: [3]) == 3)
        precondition(SMCCodec.decode(type: "ui16", bytes: [1, 2]) == 258)
        precondition(SMCCodec.encode(type: "ui8 ", value: 256) == nil)
        precondition(SMCCodec.encode(type: "flt ", value: .nan) == nil)
        precondition(SMCCodec.encode(type: "flt ", value: -1) == nil)
        precondition(SMCCodec.decode(type: "hex_", bytes: [1]) == nil)

        precondition(SMCCodec.clamp(100, min: 1200, max: 6000) == 1200)
        precondition(SMCCodec.clamp(9000, min: 1200, max: 6000) == 6000)
        precondition(SMCCodec.clamp(3000, min: 1200, max: 6000) == 3000)
        precondition(SMCCodec.clamp(3000, min: 6000, max: 1200) == 6000)

        print("fan codec, clamping and SMC struct size: ok")
    }
}
