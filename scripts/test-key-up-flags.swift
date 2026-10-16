import Carbon.HIToolbox
import CoreGraphics
import Foundation

@main
struct TestKeyUpFlags {
    static func read(_ path: String) -> String {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { preconditionFailure("can't read \(path)") }
        return text
    }

    struct Sent: Equatable {
        let type: CGEventType
        let key: Int
        var flags: CGEventFlags?
        let pikapik: Bool
        let proxy: Bool
    }

    static func down(_ key: Int, _ flags: CGEventFlags, proxy: Bool = false) -> Sent {
        Sent(type: .keyDown, key: key, flags: flags, pikapik: true, proxy: proxy)
    }

    static func up(_ key: Int, proxy: Bool = false) -> Sent {
        Sent(type: .keyUp, key: key, flags: nil, pikapik: true, proxy: proxy)
    }

    static func keyEvent(_ key: Int, down: Bool) -> CGEvent {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: down) else { preconditionFailure("no key event") }
        return event
    }

    static func record(_ body: () -> Void) -> [Sent] {
        var sent: [Sent] = []
        CGEvent.pikapikSend = { event, proxy in
            sent.append(Sent(type: event.type, key: Int(event.getIntegerValueField(.keyboardEventKeycode)), flags: event.flags, pikapik: event.isPikapik, proxy: proxy != nil))
        }
        let before = CGEventSource.flagsState(.hidSystemState)
        body()
        let after = CGEventSource.flagsState(.hidSystemState)
        for index in sent.indices where sent[index].type == .keyUp && (sent[index].flags == before || sent[index].flags == after) { sent[index].flags = nil }
        return sent
    }

    static func expect(_ got: [Sent], _ want: [Sent], _ what: String) {
        precondition(got == want, "\(what): sent \(got), expected \(want)")
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
        }
        print("a key-down carries the flags it was given and a key-up carries the flags the user really holds: ok")
        print("a key comes from a private event source, not the nil or system one: ok")

        for (key, flags) in keys {
            for held: CGEventFlags in [[], .maskShift, [.maskShift, .maskAlternate]] {
                guard let up = CGEvent.pikapikKey(key, down: false, flags: flags, held: held) else { preconditionFailure("no key-up event") }
                precondition(up.flags == held, "a key-up must carry exactly the flags held, not the press flags or none: pressed \(flags), held \(held), sent \(up.flags)")
            }
        }
        print("a key-up carries exactly the flags passed as held, never the press flags or empty ones: ok")

        let proxy = OpaquePointer(bitPattern: 1)!

        expect(record { CGEvent.tapPikapikKey(kVK_ANSI_X, flags: .maskCommand) }, [down(kVK_ANSI_X, .maskCommand), up(kVK_ANSI_X)], "tapPikapikKey")
        print("tapPikapikKey sends the key-down with its flags, then the key-up: ok")

        let homeEnd = HomeEndTool()
        homeEnd.held = (kVK_Home, kVK_LeftArrow)
        var result: Unmanaged<CGEvent>?
        expect(record { result = homeEndCallback(proxy: proxy, type: .keyUp, event: keyEvent(kVK_Home, down: false), refcon: Unmanaged.passUnretained(homeEnd).toOpaque()) }, [up(kVK_LeftArrow, proxy: true)], "Home and End key-up")
        precondition(result == nil && homeEnd.held == nil, "Home and End must swallow the key-up it answers and let go of the key")
        print("Home and End answers the key-up with one key-up of its key and swallows it: ok")
        homeEnd.held = (kVK_End, kVK_RightArrow)
        expect(record { homeEnd.stop() }, [up(kVK_RightArrow)], "Home and End stop")
        expect(record { homeEnd.stop() }, [], "Home and End second stop")
        print("Home and End releases a held key once when it stops: ok")

        let commandKeys = CommandKeysTool()
        commandKeys.triggers = [.quit: Int64(kVK_ANSI_Q)]
        let quitDown = keyEvent(Int(Shortcut.quit.key), down: true)
        quitDown.flags = CGEventFlags(rawValue: Shortcut.quit.modifiers)
        expect(record { result = commandKeysCallback(proxy: proxy, type: .keyDown, event: quitDown, refcon: Unmanaged.passUnretained(commandKeys).toOpaque()) }, [down(kVK_ANSI_Q, .maskCommand, proxy: true)], "Command keys key-down")
        precondition(result == nil && commandKeys.held?.key == Int64(Shortcut.quit.key) && commandKeys.held?.target == Int64(kVK_ANSI_Q), "Command keys must swallow the trigger and remember it")
        print("Command keys answers its trigger with one key-down with Command and swallows it: ok")
        expect(record { result = commandKeysCallback(proxy: proxy, type: .keyUp, event: keyEvent(Int(Shortcut.quit.key), down: false), refcon: Unmanaged.passUnretained(commandKeys).toOpaque()) }, [up(kVK_ANSI_Q, proxy: true)], "Command keys key-up")
        precondition(result == nil && commandKeys.held == nil, "Command keys must swallow the key-up it answers and let go of the key")
        print("Command keys answers the key-up with one key-up of its key and swallows it: ok")
        commandKeys.held = (Int64(Shortcut.quit.key), Int64(kVK_ANSI_Q))
        expect(record { commandKeys.stop() }, [up(kVK_ANSI_Q)], "Command keys stop")
        expect(record { commandKeys.stop() }, [], "Command keys second stop")
        print("Command keys releases a held key once when it stops: ok")

        let finderKeys = FinderKeys.shared
        finderKeys.held = (kVK_F2, kVK_Return)
        expect(record { result = finderKeysCallback(proxy: proxy, type: .keyUp, event: keyEvent(kVK_F2, down: false), refcon: Unmanaged.passUnretained(finderKeys).toOpaque()) }, [up(kVK_Return, proxy: true)], "Finder keys key-up")
        precondition(result == nil && finderKeys.held == nil, "Finder keys must swallow the key-up it answers and let go of the key")
        print("Finder keys answers the key-up with one key-up of its key and swallows it: ok")
        finderKeys.held = (kVK_F2, kVK_Return)
        expect(record { finderKeys.stop() }, [up(kVK_Return)], "Finder keys stop")
        expect(record { finderKeys.stop() }, [], "Finder keys second stop")
        print("Finder keys releases a held key once when it stops: ok")

        #if APPSTORE
        let layoutFix = LayoutFixTool()
        layoutFix.held = Int64(kVK_Space)
        expect(record { result = layoutFixCallback(proxy: proxy, type: .keyUp, event: keyEvent(kVK_Space, down: false), refcon: Unmanaged.passUnretained(layoutFix).toOpaque()) }, [up(kVK_F19, proxy: true)], "Layout fix key-up")
        precondition(result == nil && layoutFix.held == nil, "Layout fix must swallow the key-up it answers and let go of the key")
        print("Layout fix answers the key-up with one key-up of F19 and swallows it: ok")
        layoutFix.held = Int64(kVK_Space)
        expect(record { layoutFix.stop() }, [up(kVK_F19)], "Layout fix stop")
        expect(record { layoutFix.stop() }, [], "Layout fix second stop")
        print("Layout fix releases a held F19 once when it stops: ok")
        #endif

        expect(record { BackForward.press(.maskCommand, forward: true) }, [down(kVK_ANSI_RightBracket, .maskCommand), up(kVK_ANSI_RightBracket)], "Forward")
        expect(record { BackForward.press([.maskCommand, .maskAlternate], forward: false) }, [down(kVK_ANSI_LeftBracket, [.maskCommand, .maskAlternate]), up(kVK_ANSI_LeftBracket)], "Back")
        print("Back and Forward sends the bracket key-down with its flags, then the key-up: ok")

        let files = FileManager.default.enumerator(atPath: "Sources")?.compactMap { $0 as? String }.filter { $0.hasSuffix(".swift") } ?? []
        precondition(files.count > 50)
        let own = files.filter { $0 != "pika-tools/Common/EventTag.swift" && read("Sources/" + $0).contains("CGEvent(keyboardEventSource") }
        precondition(own.isEmpty, "Only Common/EventTag.swift builds a keyboard event; a key built anywhere else skips the real modifier flags on its key-up: \(own)")
        print("no file in Sources but Common/EventTag.swift builds a keyboard event (\(files.count) files): ok")

        var posts = 0
        let unmarked = files.flatMap { file -> [String] in
            let lines = read("Sources/" + file).components(separatedBy: "\n")
            return lines.indices.filter { lines[$0].contains(".post(tap") || lines[$0].contains("tapPostEvent(") }.compactMap { i in
                posts += 1
                return lines[max(0, i - 6)...i].contains { $0.contains("markPikapik()") || $0.contains("pikapikKey(") } ? nil : "\(file):\(i + 1)"
            }
        }
        precondition(posts >= 9, "found only \(posts) places that post events")
        precondition(unmarked.isEmpty, "Every event pikapik posts must be marked as its own, or a second running copy handles it again: \(unmarked)")
        print("every event pikapik posts is marked as its own (\(posts) places): ok")
    }
}
