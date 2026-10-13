import AppKit
import Carbon

struct Stroke: Hashable {
    let key: UInt16
    let modifiers: UInt32

    static let space = Stroke(key: 49, modifiers: 0)
    static let keys: [UInt16] = (0...50).filter { ![10, 36, 48, 49].contains($0) }.map { UInt16($0) } + [10, 93, 94]

    init(key: UInt16, modifiers: UInt32) {
        self.key = key
        self.modifiers = modifiers
    }

    init(key: UInt16, flags: CGEventFlags) {
        var modifiers: UInt32 = 0
        if flags.contains(.maskShift) { modifiers |= 2 }
        if flags.contains(.maskAlphaShift) { modifiers |= 4 }
        if flags.contains(.maskAlternate) { modifiers |= 8 }
        self.init(key: key, modifiers: modifiers)
    }
}

struct LayoutFix {
    let original: String
    let text: String
    let target: KeyboardLayout
}

final class KeyboardLayout {
    let id: String
    let language: String
    let source: TISInputSource
    private let data: Data
    private(set) lazy var dictionary = KeyboardLayouts.dictionary(for: language)
    private lazy var map = makeMap()

    init?(_ source: TISInputSource) {
        guard KeyboardLayouts.string(source, kTISPropertyInputSourceType) == kTISTypeKeyboardLayout as String,
              let id = KeyboardLayouts.string(source, kTISPropertyInputSourceID),
              let pointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { return nil }
        let data = Unmanaged<CFData>.fromOpaque(pointer).takeUnretainedValue() as Data
        guard !data.isEmpty else { return nil }
        self.id = id
        self.language = KeyboardLayouts.languages(source).first ?? ""
        self.source = source
        self.data = data
    }

    func translate(_ strokes: [Stroke]) -> (text: String, pending: Bool) {
        data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> (text: String, pending: Bool) in
            guard let layout = raw.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else { return ("", false) }
            var dead: UInt32 = 0
            var text = ""
            var chars = [UniChar](repeating: 0, count: 16)
            for stroke in strokes {
                var length = 0
                if UCKeyTranslate(layout, stroke.key, UInt16(kUCKeyActionDown), stroke.modifiers, UInt32(LMGetKbdType()), 0, &dead, chars.count, &length, &chars) == noErr {
                    text += String(utf16CodeUnits: chars, count: length)
                }
            }
            return (text, dead & 0xFFFF != 0)
        }
    }

    func strokes(_ character: Character, option: Bool = false) -> [Stroke]? {
        map[character].flatMap { option || !$0.contains { $0.modifiers & 8 != 0 } ? $0 : nil }
    }

    func canType(_ text: String) -> Bool {
        text.allSatisfy { map[$0] != nil }
    }

    private func makeMap() -> [Character: [Stroke]] {
        var map: [Character: [Stroke]] = [" ": [.space]]
        for layer: [UInt32] in [[0, 2], [8, 10]] {
            var deadKeys: [Stroke] = []
            for modifiers in layer {
                for key in Stroke.keys {
                    let stroke = Stroke(key: key, modifiers: modifiers)
                    let typed = translate([stroke])
                    if typed.pending {
                        deadKeys.append(stroke)
                    } else if typed.text.count == 1, let character = typed.text.first, map[character] == nil {
                        map[character] = [stroke]
                    }
                }
            }
            for dead in deadKeys {
                for modifiers: UInt32 in [0, 2] {
                    for key in Stroke.keys + [49] {
                        let strokes = [dead, Stroke(key: key, modifiers: modifiers)]
                        let typed = translate(strokes)
                        if !typed.pending, typed.text.count == 1, let character = typed.text.first, map[character] == nil {
                            map[character] = strokes
                        }
                    }
                }
            }
        }
        return map
    }
}

enum KeyboardLayouts {
    static var extraLanguages = Locale.preferredLanguages.map { String($0.prefix { $0 != "-" }) } + ["en"]
    private static var enabled: [KeyboardLayout]?
    private static var observer: NSObjectProtocol?
    private static var installed: [String: TISInputSource]?
    private static var byLanguage: [String: KeyboardLayout] = [:]
    private static var dictionaries: [String: String?] = [:]
    private static var lenient: Set<String> = []

    static var all: [KeyboardLayout] {
        get {
            if let enabled { return enabled }
            observer = observer ?? DistributedNotificationCenter.default().addObserver(forName: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String), object: nil, queue: .main) { _ in
                KeyboardLayouts.enabled = nil
            }
            let list = sources([kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any, kTISPropertyInputSourceIsSelectCapable: true, kTISPropertyInputSourceIsEnabled: true], installed: false).compactMap { KeyboardLayout($0) }
            enabled = list
            return list
        }
        set { enabled = newValue }
    }

    static var current: KeyboardLayout? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(), let id = string(source, kTISPropertyInputSourceID) else { return nil }
        return all.first { $0.id == id } ?? KeyboardLayout(source)
    }

    static func layout(id: String) -> KeyboardLayout? {
        sources([kTISPropertyInputSourceID: id], installed: true).lazy.compactMap { KeyboardLayout($0) }.first
    }

    static func layout(language: String) -> KeyboardLayout? {
        if let layout = all.first(where: { $0.language == language }) ?? byLanguage[language] { return layout }
        if installed == nil {
            var found: [String: TISInputSource] = [:]
            for source in sources([kTISPropertyInputSourceType: kTISTypeKeyboardLayout as Any], installed: true) {
                if let language = languages(source).first, found[language] == nil { found[language] = source }
            }
            installed = found
        }
        guard let source = installed?[language], let layout = KeyboardLayout(source) else { return nil }
        byLanguage[language] = layout
        return layout
    }

    static func dictionary(for language: String) -> String? {
        if let cached = dictionaries[language] { return cached }
        let available = NSSpellChecker.shared.availableLanguages
        let base = String(language.prefix { $0 != "-" && $0 != "_" })
        let found = [language, language.replacingOccurrences(of: "-", with: "_"), base].first { available.contains($0) } ?? available.first { $0.hasPrefix(base + "_") }
        dictionaries.updateValue(found, forKey: language)
        if let found, let probe = layout(language: language)?.translate([0, 1, 2, 3, 5, 4, 38, 40, 37, 6, 7, 8, 9, 11, 45, 46].map { Stroke(key: $0, modifiers: 0) }).text.filter(\.isLetter), probe.count >= 4, spelled(probe, found) {
            lenient.insert(found)
        }
        return found
    }

    static func isWord(_ word: String, _ dictionary: String) -> Bool {
        let lower = word.lowercased()
        if word.count == 1 || lenient.contains(dictionary) {
            return lower.split(separator: "-").allSatisfy { completions(String($0), dictionary).contains(String($0)) }
        }
        return [lower, lower.capitalized].contains { spelled($0, dictionary) }
    }

    private static func spelled(_ word: String, _ dictionary: String) -> Bool {
        NSSpellChecker.shared.checkSpelling(of: word, startingAt: 0, language: dictionary, wrap: false, inSpellDocumentWithTag: 0, wordCount: nil).location == NSNotFound
    }

    static func core(_ text: String) -> String? {
        let core = text.trimmingCharacters(in: CharacterSet.letters.inverted)
        return core.isEmpty ? nil : core
    }

    static func isPlain(_ core: String) -> Bool {
        core.unicodeScalars.allSatisfy { CharacterSet.letters.contains($0) || "-'’".unicodeScalars.contains($0) }
    }

    static func isKnown(_ text: String) -> Bool {
        guard let word = core(text) else { return true }
        guard isPlain(word) else { return false }
        guard let names = dictionaries(word) else { return true }
        return names.contains { isWord(word, $0) }
    }

    private static func isLikely(_ typed: String, _ converted: String, in target: KeyboardLayout) -> Bool {
        guard let word = core(converted), let name = target.dictionary else { return false }
        let common = isCommon(word, name)
        if word.contains(where: { "'’".contains($0) }), !common { return false }
        let score = typo(typed)
        guard lenient.contains(name) else { return score == 0 || (score == 1 && common) }
        let unusual = !startsWords(typed, 3)
        return (score == 0 && (common || unusual)) || (score == 1 && common && unusual)
    }

    private static func typo(_ text: String) -> Int {
        guard let word = core(text), let names = dictionaries(word) else { return 0 }
        let range = NSRange(location: 0, length: (word as NSString).length)
        var found = 0
        for name in names {
            for guess in NSSpellChecker.shared.guesses(forWordRange: range, in: word, language: name, inSpellDocumentWithTag: 0) ?? [] where !guess.contains(" ") && isNear(guess.lowercased(), word.lowercased()) {
                if isCommon(guess, name) { return 2 }
                found = 1
            }
        }
        return found
    }

    private static func isCommon(_ word: String, _ dictionary: String) -> Bool {
        let lower = word.lowercased()
        return completions(String(lower.prefix(2)), dictionary).contains(lower)
    }

    private static func startsWords(_ text: String, _ length: Int) -> Bool {
        guard let word = core(text), let names = dictionaries(word) else { return true }
        let prefix = String(word.lowercased().prefix(length))
        return names.contains { !completions(prefix, $0).isEmpty }
    }

    private static func completions(_ prefix: String, _ dictionary: String) -> [String] {
        let range = NSRange(location: 0, length: (prefix as NSString).length)
        return (NSSpellChecker.shared.completions(forPartialWordRange: range, in: prefix, language: dictionary, inSpellDocumentWithTag: 0) ?? []).map { $0.lowercased() }
    }

    private static func dictionaries(_ word: String) -> [String]? {
        var seen = Set<String>()
        var names: [String] = []
        for layout in all where layout.canType(word) && seen.insert(layout.language).inserted {
            guard let name = layout.dictionary else { return nil }
            names.append(name)
        }
        for language in extraLanguages where !seen.contains(language) {
            guard let name = dictionary(for: language), (layout(language: language) ?? layout(language: "en"))?.canType(word) == true else { continue }
            seen.insert(language)
            names.append(name)
        }
        return names
    }

    private static func isNear(_ a: String, _ b: String) -> Bool {
        let a = Array(a), b = Array(b)
        guard abs(a.count - b.count) <= 1 else { return false }
        var i = 0
        while i < min(a.count, b.count), a[i] == b[i] { i += 1 }
        guard i < a.count, i < b.count else { return true }
        if a.count == b.count, i + 1 < a.count, a[i] == b[i + 1], a[i + 1] == b[i], a[(i + 2)...] == b[(i + 2)...] { return true }
        return a[(i + 1)...] == b[(i + 1)...] || a[(i + 1)...] == b[i...] || a[i...] == b[(i + 1)...]
    }

    static func targets(after source: KeyboardLayout) -> [KeyboardLayout] {
        let list = all
        guard let index = list.firstIndex(where: { $0.id == source.id }) else { return list }
        return Array(list[(index + 1)...] + list[..<index])
    }

    static func fix(_ strokes: [Stroke], from source: KeyboardLayout, forced: Bool = false, ignored: Set<String> = []) -> LayoutFix? {
        var strokes = strokes
        var suffix = ""
        while forced, strokes.last == .space {
            strokes.removeLast()
            suffix += " "
        }
        var words = strokes.split(separator: .space, omittingEmptySubsequences: false).map { Array($0) }
        guard let last = words.popLast(), !last.isEmpty else { return nil }
        let typed = source.translate(last)
        guard !typed.pending, isSimple(typed.text) else { return nil }
        if !forced {
            guard let word = core(typed.text), !ignored.contains(word.lowercased()), !isKnown(typed.text) else { return nil }
        }
        var found: (target: KeyboardLayout, text: String)?
        var fallback: (target: KeyboardLayout, text: String)?
        for target in targets(after: source) {
            let converted = target.translate(last)
            guard !converted.pending, converted.text != typed.text else { continue }
            if fallback == nil { fallback = (target, converted.text) }
            guard forced || (target.language != source.language && (core(converted.text)?.count ?? 0) >= 4) else { continue }
            if replaces(typed.text, converted.text, in: target, forced: forced), forced || isLikely(typed.text, converted.text, in: target) {
                found = (target, converted.text)
                break
            }
        }
        guard let choice = found ?? (forced ? fallback : nil) else { return nil }
        var pairs = [(typed.text, choice.text)]
        for word in words.reversed() {
            let t = source.translate(word), c = choice.target.translate(word)
            guard !t.pending, !c.pending, isSimple(t.text) else { break }
            guard t.text == c.text || (!isKnown(t.text) && !ignored.contains(core(t.text)?.lowercased() ?? "") && replaces(t.text, c.text, in: choice.target, forced: forced)) else { break }
            pairs.insert((t.text, c.text), at: 0)
        }
        while pairs.count > 1, pairs[0].0 == pairs[0].1 { pairs.removeFirst() }
        return LayoutFix(original: pairs.map { $0.0 }.joined(separator: " ") + suffix, text: pairs.map { $0.1 }.joined(separator: " ") + suffix, target: choice.target)
    }

    static func convert(_ text: String, from source: KeyboardLayout, to target: KeyboardLayout) -> String {
        var result = ""
        var run: [Stroke] = []
        for character in text {
            if let strokes = source.strokes(character) {
                run += strokes
            } else {
                result += target.translate(run).text
                run = []
                result.append(character)
            }
        }
        return result + target.translate(run).text
    }

    static func variants(_ text: String) -> [(text: String, layout: KeyboardLayout)] {
        var seen: Set<String> = [text]
        var found: [(text: String, layout: KeyboardLayout, score: Int)] = []
        for source in all where text.contains(where: { $0.isLetter && source.strokes($0) != nil }) {
            for target in targets(after: source) {
                let converted = convert(text, from: source, to: target)
                guard seen.insert(converted).inserted else { continue }
                let score = converted.split(whereSeparator: { $0.isWhitespace }).filter { piece in
                    guard let word = core(String(piece)), isPlain(word), let name = target.dictionary else { return false }
                    return isWord(word, name)
                }.count
                found.append((converted, target, score))
            }
        }
        return found.enumerated().sorted { ($0.element.score, $1.offset) > ($1.element.score, $0.offset) }.map { ($0.element.text, $0.element.layout) }
    }

    static func prepare() {
        for layout in all + extraLanguages.compactMap({ layout(language: $0) }) {
            _ = layout.canType(" ")
            if let dictionary = layout.dictionary {
                _ = isWord("a", dictionary)
                _ = isWord("ab", dictionary)
            }
        }
    }

    static func string(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    static func languages(_ source: TISInputSource) -> [String] {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) else { return [] }
        return Unmanaged<CFArray>.fromOpaque(pointer).takeUnretainedValue() as? [String] ?? []
    }

    private static func replaces(_ typed: String, _ converted: String, in target: KeyboardLayout, forced: Bool) -> Bool {
        guard let word = core(converted), isPlain(word), let name = target.dictionary, isWord(word, name) else { return false }
        return forced || (letters(typed).isDisjoint(with: letters(converted)) && isShaped(typed, converted))
    }

    private static func isShaped(_ typed: String, _ converted: String) -> Bool {
        guard let word = core(converted)?.filter(\.isLetter), !(typed.first?.isLetter == true && converted.first?.isLetter == false) else { return false }
        let rest = String(word.dropFirst())
        return word == word.uppercased() || rest == rest.lowercased()
    }

    private static func letters(_ text: String) -> Set<Character> {
        Set(text.lowercased().filter { $0.isLetter })
    }

    private static func isSimple(_ text: String) -> Bool {
        text.unicodeScalars.count == text.count
    }

    private static func sources(_ filter: [CFString: Any], installed: Bool) -> [TISInputSource] {
        TISCreateInputSourceList(filter as CFDictionary, installed)?.takeRetainedValue() as? [TISInputSource] ?? []
    }
}
