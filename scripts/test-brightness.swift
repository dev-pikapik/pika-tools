import Foundation

@main
enum TestBrightness {
    static func close(_ a: Double, _ b: Double) -> Bool { abs(a - b) < 1e-9 }

    static func main() {
        precondition(BrightnessMath.writeBrightness(50) == [0x84, 0x03, 0x10, 0x00, 0x32, 0x9A])
        precondition(BrightnessMath.writeBrightness(300) == [0x84, 0x03, 0x10, 0x01, 0x2C, 0x85])
        precondition(BrightnessMath.readBrightness == [0x82, 0x01, 0x10, 0xAC])

        let half: BrightnessMath.Reply = .value(current: 50, maximum: 100)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0xF2, 0x00, 0x00]) == half)
        precondition(BrightnessMath.reply([0x00, 0x6E, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0xF2]) == half)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0xF2, 0x00]) == half)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0x32, 0xF2]) == half)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x64, 0x00, 0x32, 0xF2]) == half)
        precondition(BrightnessMath.reply([0x6E, 0x6E, 0x88, 0x02, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0xF2]) == half)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x02, 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA5, 0x00, 0x00]) == .unsupported)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32, 0xF3, 0x00, 0x00]) == nil)
        precondition(BrightnessMath.reply([0x6E, 0x88, 0x02, 0x00, 0x10, 0x00, 0x00, 0x64, 0x00, 0x32]) == nil)
        precondition(BrightnessMath.reply([UInt8](repeating: 0, count: 13)) == nil)
        print("brightness packets, replies and stutter repair: ok")

        var edid: [UInt8] = [0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x4C, 0x2D, 0x0F, 0x73, 0x37, 0x37, 0x4E, 0x30]
        edid += [UInt8](repeating: 0, count: 112)
        let samsung = BrightnessMath.identity(edid: edid)
        precondition(samsung?.vendor == 19501 && samsung?.model == 29455 && samsung?.serial == 810432311)
        precondition(BrightnessMath.identity(edid: Array(edid.prefix(15))) == nil)
        precondition(BrightnessMath.identity(edid: [0x01] + edid.dropFirst()) == nil)
        print("monitor numbers from EDID: ok")

        precondition(close(BrightnessMath.pictureScale(0), 0.2) && close(BrightnessMath.pictureScale(1), 1))
        precondition(close(BrightnessMath.pictureScale(0.5), 0.6) && close(BrightnessMath.pictureScale(-1), 0.2) && close(BrightnessMath.pictureScale(2), 1))
        precondition(close(BrightnessMath.step(0.5, up: true, fine: false), 0.5625) && close(BrightnessMath.step(0.5, up: false, fine: true), 0.5 - 1.0 / 64))
        precondition(close(BrightnessMath.step(0.53, up: true, fine: false), 0.5625) && close(BrightnessMath.step(1, up: true, fine: false), 1) && close(BrightnessMath.step(0, up: false, fine: true), 0))
        print("picture dimming and brightness steps: ok")

        let now = Date()
        let wrote = ["a": now.addingTimeInterval(-3), "b": now.addingTimeInterval(-3), "c": now.addingTimeInterval(-30)]
        precondition(BrightnessMath.restarted(["a", "b", "c", "d"], ["b"], wrote: wrote, now: now) == ["a"])
        print("monitor gone right after a brightness command: ok")
    }
}
