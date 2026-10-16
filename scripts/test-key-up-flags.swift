import AppKit
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
        let flags: CGEventFlags
        let pikapik: Bool
        let text: String?
        let proxy: Bool
        let tap: CGEventTapLocation
    }

    static var everySent: [Sent] = []

    static func down(_ key: Int, _ flags: CGEventFlags, text: String? = nil, proxy: Bool = false) -> Sent {
        Sent(type: .keyDown, key: key, flags: flags, pikapik: true, text: text, proxy: proxy, tap: .cgSessionEventTap)
    }

    static func up(_ key: Int, text: String? = nil, proxy: Bool = false) -> Sent {
        Sent(type: .keyUp, key: key, flags: held, pikapik: true, text: text, proxy: proxy, tap: .cgSessionEventTap)
    }

    static let held: CGEventFlags = .maskShift

    static func keyEvent(_ key: Int, down: Bool) -> CGEvent {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key), keyDown: down) else { preconditionFailure("no key event") }
        return event
    }

    static func text(_ event: CGEvent) -> String? {
        guard event.type == .keyDown || event.type == .keyUp else { return nil }
        var length = 0
        var units = [UniChar](repeating: 0, count: 8)
        event.keyboardGetUnicodeString(maxStringLength: 8, actualStringLength: &length, unicodeString: &units)
        return length > 0 ? String(utf16CodeUnits: units, count: length) : nil
    }

    static func typed(_ event: CGEvent, key: Int) -> String? {
        let written = text(event)
        return written == text(keyEvent(key, down: event.type == .keyDown)) ? nil : written
    }

    static func record(_ body: () -> Void) -> [Sent] {
        var sent: [Sent] = []
        CGEvent.pikapikSend = { event, proxy, tap in
            let key = Int(event.getIntegerValueField(.keyboardEventKeycode))
            sent.append(Sent(type: event.type, key: key, flags: event.flags, pikapik: event.isPikapik, text: typed(event, key: key), proxy: proxy != nil, tap: tap))
        }
        body()
        everySent += sent
        return sent
    }

    static func expect(_ got: [Sent], _ want: [Sent], _ what: String) {
        precondition(got == want, "\(what): sent \(got), expected \(want)")
    }

    static func main() {
        let systemBefore = CGEventSource.flagsState(.hidSystemState)
        let systemHeld = CGEvent.pikapikHeld()
        let systemAfter = CGEventSource.flagsState(.hidSystemState)
        precondition(systemHeld == systemBefore || systemHeld == systemAfter, "by default a key-up must carry the modifiers the user really holds: read \(systemHeld), system \(systemBefore)")
        print("by default a key-up reads the modifiers the user really holds from the system: ok")

        CGEvent.pikapikHeld = { held }

        let keys: [(Int, CGEventFlags)] = [(kVK_ANSI_X, .maskCommand), (kVK_F19, [.maskControl, .maskAlternate, .maskShift, .maskCommand]), (kVK_Home, [])]
        for (key, flags) in keys {
            guard let down = CGEvent.pikapikKey(key, down: true, flags: flags) else { preconditionFailure("no key-down event") }
            precondition(down.type == .keyDown && down.getIntegerValueField(.keyboardEventKeycode) == Int64(key))
            precondition(down.flags.intersection(flags) == flags)
            let downSource = down.getIntegerValueField(.eventSourceStateID)
            precondition(downSource != 0 && downSource != 1, "a key must come from a private event source, not the nil or system one")

            guard let up = CGEvent.pikapikKey(key, down: false, flags: flags) else { preconditionFailure("no key-up event") }
            precondition(up.type == .keyUp && up.getIntegerValueField(.keyboardEventKeycode) == Int64(key))
            let upSource = up.getIntegerValueField(.eventSourceStateID)
            precondition(upSource != 0 && upSource != 1, "a key must come from a private event source, not the nil or system one")
            precondition(up.flags == CGEvent.pikapikHeld(), "a key-up must carry exactly the flags held, not the press flags: pressed \(flags), held \(held), sent \(up.flags)")
        }
        print("a key-down carries the flags it was given and a key-up carries exactly the flags held: ok")
        print("a key comes from a private event source, not the nil or system one: ok")

        CGEvent.pikapikHeld = { [] }
        for (key, flags) in keys {
            guard let up = CGEvent.pikapikKey(key, down: false, flags: flags) else { preconditionFailure("no key-up event") }
            precondition(up.flags == [], "a key-up must carry no flags when none are held: pressed \(flags), sent \(up.flags)")
        }
        CGEvent.pikapikHeld = { held }
        print("a key-up carries no flags when the user holds none: ok")

        let proxy = OpaquePointer(bitPattern: 1)!

        guard let fresh = CGEvent(source: nil) else { preconditionFailure("no event") }
        precondition(!fresh.isPikapik)
        expect(record { fresh.postPikapik() }, [Sent(type: fresh.type, key: 0, flags: fresh.flags, pikapik: true, text: nil, proxy: false, tap: .cgSessionEventTap)], "postPikapik")
        precondition(fresh.isPikapik)
        expect(record { fresh.postPikapik(proxy, tap: .cghidEventTap) }, [Sent(type: fresh.type, key: 0, flags: fresh.flags, pikapik: true, text: nil, proxy: true, tap: .cghidEventTap)], "postPikapik with a proxy and a tap")
        print("postPikapik marks an unmarked event and hands it to the sender with its proxy and tap: ok")

        expect(record { CGEvent.tapPikapikKey(kVK_ANSI_X, flags: .maskCommand) }, [down(kVK_ANSI_X, .maskCommand), up(kVK_ANSI_X)], "tapPikapikKey")
        print("tapPikapikKey sends the key-down with its flags, then the key-up: ok")

        let homeEnd = HomeEndTool()
        guard let home = HomeEndTool.target(kVK_Home, [], app: "com.apple.TextEdit", excluded: []) else { preconditionFailure("Home must be replaced in a text editor") }
        precondition(home.flags.contains(.maskCommand), "Home must press its arrow with Command: \(home.flags)")
        expect(record { homeEnd.press(kVK_Home, home, proxy: proxy) }, [down(home.key, home.flags, proxy: true)], "Home and End key-down")
        precondition(homeEnd.held?.key == kVK_Home && homeEnd.held?.target == home.key, "Home and End must remember the key it holds down")
        print("Home and End answers the key-down with one key-down of its key with Command: ok")
        var result: Unmanaged<CGEvent>?
        expect(record { result = homeEndCallback(proxy: proxy, type: .keyUp, event: keyEvent(kVK_Home, down: false), refcon: Unmanaged.passUnretained(homeEnd).toOpaque()) }, [up(home.key, proxy: true)], "Home and End key-up")
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

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("pikapik-test-\(getpid())"))
        finderKeys.pasteboard = pasteboard
        var count = pasteboard.changeCount
        pasteboard.clearContents()
        pasteboard.setString("x", forType: .string)
        expect(record { finderKeys.watchCopy(since: count, attempts: 1); RunLoop.main.run(until: Date() + 0.4) }, [down(kVK_ANSI_X, .maskCommand), up(kVK_ANSI_X)], "Finder keys Command X after a copy")
        print("Finder keys sends Command X after Finder copied text: ok")
        count = pasteboard.changeCount
        pasteboard.clearContents()
        pasteboard.writeObjects([URL(fileURLWithPath: "/tmp") as NSURL])
        expect(record { finderKeys.watchCopy(since: count, attempts: 1); RunLoop.main.run(until: Date() + 0.4) }, [], "Finder keys after a copied file")
        print("Finder keys sends nothing after Finder copied a file: ok")
        pasteboard.releaseGlobally()

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

        expect(record { replace("ab", with: "c", proxy) }, [
            down(kVK_Delete, [], proxy: true), up(kVK_Delete, proxy: true), down(kVK_Delete, [], proxy: true), up(kVK_Delete, proxy: true),
            down(0, [], text: "c", proxy: true), up(0, text: "c", proxy: true),
        ], "Layout fix retype")
        print("Layout fix retype sends one Delete per typed letter, then the new letters, each released: ok")

        expect(record { BackForward.press(.maskCommand, forward: true) }, [down(kVK_ANSI_RightBracket, .maskCommand), up(kVK_ANSI_RightBracket)], "Forward")
        expect(record { BackForward.press([.maskCommand, .maskAlternate], forward: false) }, [down(kVK_ANSI_LeftBracket, [.maskCommand, .maskAlternate]), up(kVK_ANSI_LeftBracket)], "Back")
        print("Back and Forward sends the bracket key-down with its flags, then the key-up: ok")

        precondition(!everySent.isEmpty && everySent.allSatisfy(\.pikapik), "Every event the run sent must carry the pikapik tag: \(everySent.filter { !$0.pikapik })")
        print("every event sent in this run carries the pikapik tag (\(everySent.count) events): ok")

        let files = FileManager.default.enumerator(atPath: "Sources")?.compactMap { $0 as? String }.filter { $0.hasSuffix(".swift") } ?? []
        precondition(files.count > 50)
        let banned = ["CGEvent(keyboardEventSource", ".post(tap", "tapPostEvent(", "postToPid", "CGEventPost", "postToPSN"]
        let own = files.filter { file in file != "pika-tools/Common/EventTag.swift" && banned.contains { read("Sources/" + file).contains($0) } }
        precondition(own.isEmpty, "Only Common/EventTag.swift builds keyboard events and posts events, so every event is tagged and every key-up carries the real modifiers: \(own)")
        print("no file in Sources but Common/EventTag.swift builds a keyboard event or posts an event (\(files.count) files): ok")
    }
}
