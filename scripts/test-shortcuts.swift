import Foundation

@main
enum TestShortcuts {
    static func main() {
        precondition(Shortcut.text(character: 32, key: 49, modifiers: 0x80000) == "⌥Space")
        precondition(Shortcut.text(character: 32, key: 49, modifiers: 0x140000) == "⌃⌘Space")
        precondition(Shortcut.text(character: 65535, key: 48, modifiers: 0x100000) == "⌘Tab")
        precondition(Shortcut.text(character: 65535, key: 123, modifiers: 0x840000) == "⌃←")
        precondition(Shortcut.text(character: 65535, key: 124, modifiers: 0x860000) == "⌃⇧→")
        precondition(Shortcut.text(character: 100, key: 2, modifiers: 0x140000) == "⌃⌘D")
        precondition(Shortcut.text(character: 104, key: 4, modifiers: 0x800000) == "🌐H")
        precondition(Shortcut.text(character: 1092, key: 0, modifiers: 0x100000) == "⌘Ф")
        precondition(Shortcut.text(character: 65535, key: 65535, modifiers: 0) == nil)
        print("text: ok")

        let arrow = Shortcut(key: 123, modifiers: 0x840000)
        precondition(arrow == Shortcut(key: 123, modifiers: 0x40000) && arrow.modifiers == 0x40000)
        precondition(Shortcut(key: 4, modifiers: 0x800100) == Shortcut(key: 4, modifiers: 0x800000))
        precondition(Shortcut(stored: Shortcut.quit.stored) == .quit && Shortcut(stored: arrow.stored) == arrow)
        precondition(Shortcut(stored: nil) == nil && Shortcut(stored: 0) == nil && Shortcut(stored: "⌘Q") == nil)
        precondition(Shortcut.quit.isUsable && Shortcut(key: 120, modifiers: 0).isUsable)
        precondition(!Shortcut(key: 12, modifiers: 0).isUsable && !Shortcut(key: 12, modifiers: 0x20000).isUsable)
        print("shortcut: ok")

        let live: (enabled: Bool, parameters: [Int]?) = (true, [32, 49, 0x100000])
        precondition(Shortcut.system(nil, live: live) == .on(character: 32, Shortcut(key: 49, modifiers: 0x100000)))
        precondition(Shortcut.system(["enabled": false], live: live) == .off)
        precondition(Shortcut.system(["enabled": true, "value": ["parameters": [32, 49, 0x80000], "type": "standard"]], live: live)
            == .on(character: 32, Shortcut(key: 49, modifiers: 0x80000)))
        precondition(Shortcut.system(["enabled": true, "value": ["parameters": [65535, 65535, 0]]], live: live) == .off)
        precondition(Shortcut.system(["enabled": true], live: live) == .on(character: 32, Shortcut(key: 49, modifiers: 0x100000)))
        precondition(Shortcut.system(nil, live: (false, [32, 49, 0x100000])) == .off)
        precondition(Shortcut.system(nil, live: nil) == .unknown)
        precondition(Shortcut.system(["enabled": true], live: nil) == .unknown)
        print("system: ok")

        let finder: [String: Any] = ["\u{1B}Edit\u{1B}Вырезать": "@~x"]
        let global: [String: Any] = ["Вырезать": "@k", "Cut": ""]
        precondition(Shortcut.equivalent(for: "Вырезать", in: [finder, global]) == "@~x")
        precondition(Shortcut.equivalent(for: "Вырезать", in: [nil, global]) == "@k")
        precondition(Shortcut.equivalent(for: "Cut", in: [finder, global]) == "")
        precondition(Shortcut.equivalent(for: "Copy", in: [finder, global]) == nil)
        precondition(Shortcut.equivalent(for: "Edit", in: [finder]) == nil)
        print("menu titles: ok")

        let codes: [Character: UInt16] = ["x": 7, "k": 40, "q": 12]
        let code: (Character) -> UInt16? = { codes[$0] }
        precondition(Shortcut.menu("@~x", code: code)?.shortcut == Shortcut(key: 7, modifiers: 0x180000))
        precondition(Shortcut.menu("@X", code: code)?.shortcut == Shortcut(key: 7, modifiers: 0x120000))
        precondition(Shortcut.menu("^$k", code: code)?.shortcut == Shortcut(key: 40, modifiers: 0x60000))
        precondition(Shortcut.menu("@\u{F702}", code: code)?.shortcut == Shortcut(key: 123, modifiers: 0x100000))
        precondition(Shortcut.menu("@\u{F705}", code: code)?.shortcut == Shortcut(key: 120, modifiers: 0x100000))
        precondition(Shortcut.menu("@\u{8}", code: code)?.shortcut == Shortcut(key: 51, modifiers: 0x100000))
        precondition(Shortcut.menu("", code: code) == nil && Shortcut.menu("@", code: code) == nil && Shortcut.menu("@z", code: code) == nil)
        let cut = Shortcut.menu("@~x", code: code)!
        precondition(Shortcut.text(character: cut.character, key: cut.shortcut.key, modifiers: cut.shortcut.modifiers) == "⌥⌘X")
        let left = Shortcut.menu("@\u{F702}", code: code)!
        precondition(Shortcut.text(character: left.character, key: left.shortcut.key, modifiers: left.shortcut.modifiers) == "⌘←")
        print("menu keys: ok")

        let taken = [("Spotlight", Shortcut(key: 49, modifiers: 0x80000)), ("Quit", Shortcut.quit)].map { (message: $0.0, shortcut: $0.1) }
        precondition(Shortcut.conflict(Shortcut(key: 49, modifiers: 0x880000), in: taken) == "Spotlight")
        precondition(Shortcut.conflict(.quit, in: taken) == "Quit")
        precondition(Shortcut.conflict(.close, in: taken) == nil)
        print("conflicts: ok")
    }
}
