import CoreGraphics
import Foundation

@main
enum TestScroll {
    static func wheel(_ lines: Int32, _ horizontal: Int32 = 0, units: CGScrollEventUnit = .line) -> CGEvent {
        CGEvent(scrollWheelEvent2Source: nil, units: units, wheelCount: 2, wheel1: lines, wheel2: horizontal, wheel3: 0)!
    }

    static func fields(_ event: CGEvent) -> [Int64] {
        [
            event.getIntegerValueField(.scrollWheelEventDeltaAxis1),
            Int64(event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1)),
            event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1),
            event.getIntegerValueField(.scrollWheelEventDeltaAxis2),
            Int64(event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2)),
            event.getIntegerValueField(.scrollWheelEventPointDeltaAxis2),
        ]
    }

    static func main() {
        let three = WheelStep(lines: 3)
        precondition(three.step(1, 1) == 3)
        precondition(three.step(7, 7.4) == 3)
        precondition(three.step(-12, -12) == -3)
        precondition(three.step(0, 0.2) == 3)
        precondition(three.step(0, -0.2) == -3)
        precondition(three.step(0, 0) == 0)
        precondition(WheelStep(lines: 0).step(1, 1) == 1)
        precondition(WheelStep(lines: 50).step(-1, -1) == -10)

        let slow = wheel(1)
        precondition(three.rewrite(slow))
        precondition(fields(slow) == [3, 3, 30, 0, 0, 0])

        let fast = wheel(-9)
        precondition(three.rewrite(fast))
        precondition(fields(fast) == [-3, -3, -30, 0, 0, 0])

        let sideways = wheel(0, 4)
        precondition(WheelStep(lines: 5).rewrite(sideways))
        precondition(fields(sideways) == [0, 0, 0, 5, 5, 50])

        let trackpad = wheel(40, units: .pixel)
        let before = fields(trackpad)
        precondition(!three.rewrite(trackpad))
        precondition(fields(trackpad) == before)

        let device = "mac-a"
        let older = Date(timeIntervalSince1970: 1_000)
        let newer = Date(timeIntervalSince1970: 2_000)
        let remote = { (date: Date, from: String) in SettingsFile(settings: [:], modified: date, device: from) }
        precondition(SettingsFile.merge(local: older, remote: nil, device: device) == .upload)
        precondition(SettingsFile.merge(local: older, remote: remote(newer, "mac-b"), device: device) == .apply)
        precondition(SettingsFile.merge(local: newer, remote: remote(older, "mac-b"), device: device) == .upload)
        precondition(SettingsFile.merge(local: newer, remote: remote(newer, "mac-b"), device: device) == .none)
        precondition(SettingsFile.merge(local: newer, remote: remote(newer, device), device: device) == .none)
        precondition(SettingsFile.merge(local: .distantPast, remote: remote(newer, device), device: device) == .upload)
        precondition(SettingsFile.merge(local: .distantPast, remote: remote(newer, "mac-b"), device: device) == .apply)

        let stamp = Date(timeIntervalSince1970: 1_791_234_567.891)
        let file = SettingsFile(
            settings: [
                "wheel-lines": true, "wheel-lines-count": 4, "linear-pointer-speed": 1.4,
                "quit-on-close-excluded": ["com.apple.Safari"], "appearance": "dark",
                "keep-awake-lid-sleep-disabled": true, "linear-pointer-saved": ["1": ["a": 1]],
                "NSWindow Frame Settings": "0 0 10 10", "dock-hide": ["not", 1],
            ],
            modified: stamp,
            device: device
        )
        precondition(Set(file.settings.keys) == ["wheel-lines", "wheel-lines-count", "linear-pointer-speed", "quit-on-close-excluded", "appearance"])

        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tools-test-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("settings.json")
        try! file.data().write(to: url, options: .atomic)
        let loaded = SettingsFile(data: try! Data(contentsOf: url))!
        precondition(loaded.modified == stamp && loaded.device == device)
        precondition(SettingsFile.same(loaded.settings, file.settings))
        precondition(SettingsFile.merge(local: stamp, remote: loaded, device: device) == .none)
        precondition((loaded.settings["wheel-lines"] as? Bool) == true)
        precondition((loaded.settings["linear-pointer-speed"] as? Double) == 1.4)

        precondition(SettingsFile(data: Data("{\"app\":\"other\",\"settings\":{}}".utf8)) == nil)
        precondition(SettingsFile(data: Data("not json".utf8)) == nil)
        precondition(SettingsFile(data: Data(count: SettingsFile.maxSize + 1)) == nil)
        precondition(SettingsFile(data: Data("{\"app\":\"pika-tools\",\"settings\":{\"ctrl-keys\":false,\"key-repeat\":false,\"evil\":1}}".utf8))?.settings.keys.sorted() == ["key-repeat"])

        print("test-scroll: all passed")
    }
}
