import Foundation

enum SettingsSearch {
    private static let aliases: [String: String] = {
        var values = ["control": "ctrl", "command": "cmd", "alt": "option", "opt": "option", "esc": "escape", "enter": "return", "spacebar": "space"]
        let space = Bundle.main.localizedString(forKey: "Space", value: nil, table: nil)
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
        values[space] = "space"
        return values
    }()
    private static let modifiers: Set<String> = ["ctrl", "cmd", "option", "shift", "fn"]

    private static func chordTerms(_ query: String) -> [String]? {
        let terms = normalized(query).split(separator: " ").map(String.init)
        guard terms.contains(where: modifiers.contains) else { return nil }
        let names: Set<String> = ["space", "return", "escape", "tab", "backspace", "delete", "left", "right", "up", "down", "home", "end", "pageup", "pagedown"]
        let context: Set<String> = ["game", "games", "gaming", normalized(Bundle.main.localizedString(forKey: "Games", value: nil, table: nil))]
        let keyTerms = terms.filter { !context.contains($0) }
        guard keyTerms.allSatisfy({ modifiers.contains($0) || names.contains($0) || $0.count == 1 || $0.hasPrefix("f") && Int($0.dropFirst()) != nil }) else { return nil }
        return keyTerms
    }

    static func normalized(_ text: String) -> String {
        var value = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
        for (symbol, name) in [("⌃", "ctrl"), ("⌘", "cmd"), ("⌥", "option"), ("⇧", "shift"), ("🌐", "fn"), ("←", "left"), ("→", "right"), ("↑", "up"), ("↓", "down"), ("↩", "return"), ("⌤", "return"), ("⌫", "backspace"), ("⌦", "delete"), ("↖", "home"), ("↘", "end"), ("⇞", "pageup"), ("⇟", "pagedown")] {
            value = value.replacingOccurrences(of: symbol, with: " \(name) ")
        }
        return value.split { !$0.isLetter && !$0.isNumber }
            .map { aliases[String($0)] ?? String($0) }.joined(separator: " ")
    }

    static func matchesKeys(_ query: String, keys: String) -> Bool {
        guard let keyTerms = chordTerms(query) else { return true }
        let assigned = Set(normalized(keys).split(separator: " ").map(String.init))
        return keyTerms.allSatisfy(assigned.contains)
    }

    static func matches(_ query: String, fields: [String]) -> Bool {
        let terms = normalized(query).split(separator: " ")
        guard !terms.isEmpty else { return false }
        let values = fields.map(normalized)
        let keyQuery = chordTerms(query) != nil
        return terms.allSatisfy { term in values.contains { keyQuery ? $0.split(separator: " ").contains(term) : $0.contains(term) } }
    }

    static func score(_ query: String, title: String, keys: String) -> Int {
        let value = normalized(query)
        if normalized(title) == value { return 100 }
        if !keys.isEmpty, Set(normalized(keys).split(separator: " ")) == Set(value.split(separator: " ")) { return 95 }
        if matches(query, fields: [title]) { return 80 }
        return 50
    }
}
