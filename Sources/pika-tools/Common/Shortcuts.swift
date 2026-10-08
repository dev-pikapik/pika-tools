import Foundation

struct Shortcut: Hashable {
    let key: UInt16
    let modifiers: UInt64

    init(key: UInt16, modifiers: UInt64) {
        self.key = key
        self.modifiers = modifiers & (Self.names[key] == nil ? 0x9E0000 : 0x1E0000)
    }

    init?(stored: Any?) {
        guard let value = stored as? Int, value > 0 else { return nil }
        self.init(key: UInt16(truncatingIfNeeded: value >> 32), modifiers: UInt64(truncatingIfNeeded: value) & 0xFFFF_FFFF)
    }

    var stored: Int { Int(key) << 32 | Int(modifiers) }

    var isUsable: Bool { modifiers & 0x1C0000 != 0 || Self.functionKeys.contains(key) }

    static let quit = Shortcut(key: 12, modifiers: 0x120000)
    static let close = Shortcut(key: 13, modifiers: 0x120000)
    static let cut = Shortcut(key: 7, modifiers: 0x100000)

    private static let functionKeys: [UInt16] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 105, 107, 113, 106, 64, 79, 80, 90]

    private static let names: [UInt16: String] = [
        49: String(localized: "Space"), 48: "Tab", 53: "Esc", 36: "↩", 76: "⌤", 51: "⌫", 117: "⌦", 123: "←", 124: "→", 125: "↓", 126: "↑",
        115: "↖", 119: "↘", 116: "⇞", 121: "⇟",
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6", 98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
        105: "F13", 107: "F14", 113: "F15", 106: "F16", 64: "F17", 79: "F18", 80: "F19", 90: "F20",
        160: "F3", 131: "F4", 176: "🎤", 177: "🔍",
    ]

    static func text(character: UInt16, key: UInt16, modifiers: UInt64) -> String? {
        let printable = character > 32 && character != 127 && character < 0xF700 ? Unicode.Scalar(character).map { String($0).uppercased() } : nil
        guard let name = names[key] ?? printable else { return nil }
        let flags: [(UInt64, String)] = [(0x40000, "⌃"), (0x80000, "⌥"), (0x20000, "⇧"), (0x100000, "⌘")]
        let fn = names[key] == nil && modifiers & 0x800000 != 0 ? "🌐" : ""
        return fn + flags.filter { modifiers & $0.0 != 0 }.map(\.1).joined() + name
    }

    enum System: Equatable {
        case on(character: UInt16, Shortcut)
        case off
        case unknown
    }

    static func system(_ entry: Any?, live: (enabled: Bool, parameters: [Int]?)?) -> System {
        let entry = entry as? [String: Any]
        guard let enabled = entry?["enabled"] as? Bool ?? live?.enabled else { return .unknown }
        guard enabled else { return .off }
        guard let parameters = (entry?["value"] as? [String: Any])?["parameters"] as? [Int] ?? live?.parameters else { return .unknown }
        guard parameters.count == 3, (0..<0xFFFF).contains(parameters[1]), (0...0xFFFF).contains(parameters[0]), parameters[2] >= 0 else { return .off }
        return .on(character: UInt16(parameters[0]), Shortcut(key: UInt16(parameters[1]), modifiers: UInt64(parameters[2])))
    }

    static func equivalent(for title: String, in domains: [[String: Any]?]) -> String? {
        for domain in domains {
            guard let domain else { continue }
            if let value = domain[title] as? String { return value }
            if let value = domain.first(where: { $0.key.hasPrefix("\u{1B}") && $0.key.split(separator: "\u{1B}").last == Substring(title) })?.value as? String {
                return value
            }
        }
        return nil
    }

    static func menu(_ equivalent: String, code: (Character) -> UInt16?) -> (character: UInt16, shortcut: Shortcut)? {
        let flags: [Character: UInt64] = ["@": 0x100000, "~": 0x80000, "$": 0x20000, "^": 0x40000]
        let modifiers = equivalent.prefix { flags[$0] != nil }
        let rest = equivalent.dropFirst(modifiers.count)
        guard rest.count == 1, let character = rest.first else { return nil }
        var mask = modifiers.reduce(UInt64(0)) { $0 | flags[$1]! }
        let special: [Character: UInt16] = [
            " ": 49, "\t": 48, "\u{1B}": 53, "\r": 36, "\u{8}": 51, "\u{7F}": 51, "\u{F728}": 117,
            "\u{F700}": 126, "\u{F701}": 125, "\u{F702}": 123, "\u{F703}": 124, "\u{F729}": 115, "\u{F72B}": 119, "\u{F72C}": 116, "\u{F72D}": 121,
        ]
        let scalar = character.unicodeScalars.first!.value
        let key: UInt16
        if let found = special[character] {
            key = found
        } else if (0xF704..<0xF718).contains(scalar) {
            key = functionKeys[Int(scalar - 0xF704)]
        } else {
            if character.isUppercase { mask |= 0x20000 }
            guard let found = code(Character(character.lowercased())) else { return nil }
            key = found
        }
        return (UInt16(truncatingIfNeeded: Character(character.lowercased()).unicodeScalars.first!.value), Shortcut(key: key, modifiers: mask))
    }

    static let keyboardSettings = URL(string: "x-apple.systempreferences:com.apple.Keyboard-Settings.extension")!

    static func settingsLink(_ section: String?, anchors: Set<String>) -> URL? {
        guard let anchor = ["spotlight": "Spotlight", "services": "Services", "universalaccess": "Accessibility"][section ?? ""],
              anchors.contains(anchor)
        else { return nil }
        return URL(string: keyboardSettings.absoluteString + "?" + anchor)
    }

    static func conflict(_ shortcut: Shortcut, in taken: [(message: String, shortcut: Shortcut)]) -> String? {
        taken.first { $0.shortcut == shortcut }?.message
    }
}
