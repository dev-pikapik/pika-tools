import Carbon.HIToolbox
import CoreGraphics
import Foundation

@main
struct TestKeyUpFlags {
    static func read(_ path: String) -> String {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { preconditionFailure("can't read \(path)") }
        return text
    }

    static func main() {
        let keys: [(Int, CGEventFlags)] = [(kVK_ANSI_X, .maskCommand), (kVK_F19, [.maskControl, .maskAlternate, .maskShift, .maskCommand]), (kVK_Home, [])]
        for (key, flags) in keys {
            guard let down = CGEvent.pikapikKey(key, down: true, flags: flags) else { preconditionFailure("no key-down event") }
            precondition(down.type == .keyDown && down.getIntegerValueField(.keyboardEventKeycode) == Int64(key))
            precondition(down.flags.intersection(flags) == flags && down.isPikapik)
            let downSource = down.getIntegerValueField(.eventSourceStateID)
            precondition(downSource != 0 && downSource != 1, "a key must come from a private event source, not the nil or system one")

            let before = CGEventSource.flagsState(.hidSystemState)
            guard let up = CGEvent.pikapikKey(key, down: false, flags: flags) else { preconditionFailure("no key-up event") }
            let after = CGEventSource.flagsState(.hidSystemState)
            precondition(up.type == .keyUp && up.getIntegerValueField(.keyboardEventKeycode) == Int64(key) && up.isPikapik)
            let upSource = up.getIntegerValueField(.eventSourceStateID)
            precondition(upSource != 0 && upSource != 1, "a key must come from a private event source, not the nil or system one")
            precondition(up.flags == before || up.flags == after)
            if !before.contains(.maskCommand) && !after.contains(.maskCommand) { precondition(!up.flags.contains(.maskCommand)) }
        }
        print("a key-down carries the flags it was given and a key-up carries the flags the user really holds: ok")
        print("a key comes from a private event source, not the nil or system one: ok")

        let places = [
            ("Home and End", "Tools/HomeEnd/HomeEndTool.swift"),
            ("Finder keys", "Tools/Windows/FinderKeysTool.swift"),
            ("Command keys", "Tools/CommandKeys/CommandKeysTool.swift"),
            ("Layout fix", "Tools/LayoutFix/LayoutFixTool.swift"),
            ("Back and Forward", "Tools/Mouse/BackForward.swift"),
        ]
        for (name, file) in places {
            let text = read("Sources/pika-tools/" + file)
            precondition(text.contains("CGEvent.postPikapikKey(") && !text.contains("CGEvent(keyboardEventSource"), "\(name) must send its keys with CGEvent.postPikapikKey and never build its own: \(file)")
            print("\(name) sends its keys through CGEvent.postPikapikKey: ok")
        }

        let files = FileManager.default.enumerator(atPath: "Sources")?.compactMap { $0 as? String }.filter { $0.hasSuffix(".swift") } ?? []
        precondition(files.count > 50)
        let own = files.filter { $0 != "pika-tools/Common/EventTag.swift" && read("Sources/" + $0).contains("CGEvent(keyboardEventSource") }
        precondition(own.isEmpty, "Only Common/EventTag.swift builds a keyboard event; a key built anywhere else skips the real modifier flags on its key-up: \(own)")
        print("no file in Sources but Common/EventTag.swift builds a keyboard event (\(files.count) files): ok")
    }
}
