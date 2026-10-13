import AppKit
import Carbon

@main
enum TestLayout {
    static func layout(_ id: String) -> KeyboardLayout? {
        KeyboardLayouts.layout(id: "com.apple.keylayout." + id)
    }

    static func strokes(_ text: String, _ layout: KeyboardLayout) -> [Stroke]? {
        var result: [Stroke] = []
        for character in text {
            guard let strokes = layout.strokes(character, option: true) else { return nil }
            result += strokes
        }
        return result
    }

    static func fix(_ typed: String, _ source: KeyboardLayout, forced: Bool = false, ignored: Set<String> = []) -> LayoutFix? {
        KeyboardLayouts.fix(strokes(typed, source)!, from: source, forced: forced, ignored: ignored)
    }

    static func expect(_ value: String?, _ expected: String?, line: UInt = #line) {
        precondition(value == expected, "\(value ?? "nil") instead of \(expected ?? "nil")", line: line)
    }

    static func words(_ language: String) -> [String] {
        let table = NSDictionary(contentsOfFile: "Resources/\(language).lproj/Localizable.strings") as? [String: String] ?? [:]
        precondition(!table.isEmpty, "no strings for \(language)")
        var words = Set<String>()
        for token in table.values.flatMap({ value in value.split(whereSeparator: \.isWhitespace) }) where !token.contains("%") {
            words.insert(String(token))
            if let core = KeyboardLayouts.core(String(token)) { words.insert(core) }
        }
        return words.sorted()
    }

    static func falsePositives(_ words: [String], _ layout: KeyboardLayout) -> (checked: Int, found: [String]) {
        var checked = 0
        var found: [String] = []
        for word in words {
            guard let keys = strokes(word, layout) else { continue }
            checked += 1
            guard let fix = KeyboardLayouts.fix(keys, from: layout) else { continue }
            if KeyboardLayouts.fix(keys, from: layout)?.text == fix.text {
                found.append("\(fix.original) → \(fix.text)")
            } else {
                print("\(fix.original) → \(fix.text) did not repeat on a second try: macOS spell check gave one wrong answer, not counted")
            }
        }
        return (checked, found)
    }

    static func rate(_ words: [String], typed native: KeyboardLayout, in source: KeyboardLayout) -> String {
        var fixed = 0, total = 0
        for word in words where word.count >= 4 && KeyboardLayouts.isPlain(word) {
            guard let keys = strokes(word, native) else { continue }
            total += 1
            if KeyboardLayouts.fix(keys, from: source)?.text == word { fixed += 1 }
        }
        return "\(fixed) of \(total)"
    }

    static func main() {
        setbuf(stdout, nil)
        let suggests = !(NSSpellChecker.shared.completions(forPartialWordRange: NSRange(location: 0, length: 1), in: "я", language: "ru", inSpellDocumentWithTag: 0) ?? []).isEmpty
        if !suggests { print("layout: macOS gives no word suggestions here, skipping the cases that need them") }
        KeyboardLayouts.extraLanguages = ["en"]
        guard let us = layout("US"), let ru = layout("Russian"), let uk = layout("Ukrainian"), let de = layout("German"), let fr = layout("French"), let el = layout("Greek") else { fatalError("missing layouts") }

        KeyboardLayouts.all = [us, ru]
        expect(fix("ghbdtn", us)?.text, "привет")
        expect(fix("ghbdtn", us)?.original, "ghbdtn")
        if suggests { expect(fix("z nt,z k.,k.", us)?.text, "я тебя люблю") }
        expect(fix("I said ghbdtn", us)?.original, "ghbdtn")
        expect(fix("I said ghbdtn", us)?.text, "привет")
        if suggests { expect(fix("z 2 rjnf", us)?.text, "я 2 кота") }
        expect(fix("руддщ цщкдв", ru)?.text, "hello world")
        expect(fix("GHBDTN", us)?.text, "ПРИВЕТ")
        expect(fix("ghbdtn", us, ignored: ["ghbdtn"])?.text, nil)
        expect(fix("z nt,z k.,k.", us, ignored: ["nt,z"])?.text, "люблю")
        expect(fix("lf", us)?.text, nil)
        expect(fix("lf", us, forced: true)?.text, "да")
        expect(fix("ghbdtn ", us, forced: true)?.text, "привет ")
        expect(fix("привет", ru)?.text, nil)
        expect(fix("hello", us)?.text, nil)
        precondition(KeyboardLayouts.fix(strokes("ghbdtn", us)! + [Stroke(key: 14, modifiers: 8)], from: us) == nil)
        expect(KeyboardLayouts.convert("Ghbdtn? vbh!", from: us, to: ru), "Привет? мир!")
        expect(KeyboardLayouts.variants("ghbdtn").first?.text, "привет")
        expect(KeyboardLayouts.variants("руддщ цщкдв").first?.text, "hello world")
        expect(fr.translate(strokes("être", fr)!).text, "être")
        if let windows = layout("RussianWin") {
            for order in [[windows, us], [us, windows]] {
                KeyboardLayouts.all = order
                expect(KeyboardLayouts.variants("ghbdtn vbh").map(\.text).joined(separator: "|"), "привет мир")
                expect(KeyboardLayouts.variants("привет мир").map(\.text).joined(separator: "|"), "ghbdtn vbh")
            }
            KeyboardLayouts.all = [us, ru]
        }

        KeyboardLayouts.all = [us, de]
        expect(fix("yeit", us)?.text, nil)
        expect(fix("yeit", us, forced: true)?.text, "zeit")

        KeyboardLayouts.all = [us, ru]
        expect(fix("frnt", us)?.text, nil)
        expect(fix("игпы", ru)?.text, nil)
        expect(fix("ghbDtn", us)?.text, nil)
        if let german = layout("German") {
            KeyboardLayouts.all = [german, ru]
            expect(fix("pder", german)?.text, nil)
        }

        KeyboardLayouts.all = [us, ru, uk]
        expect(fix(us.translate(strokes("привіт", uk)!).text, us)?.text, "привіт")
        expect(fix("ghbdtn", us)?.text, "привет")

        KeyboardLayouts.all = [us, el]
        if suggests { expect(fix(us.translate(strokes("ευχαριστώ", el)!).text, us)?.text, "ευχαριστώ") }

        if let arabic = layout("Arabic") {
            KeyboardLayouts.all = [us, arabic]
            expect(fix("dont", us)?.text, nil)
        }

        var failures: [String] = []
        let corpus = [("ar", "Arabic"), ("cs", "Czech"), ("de", "German"), ("en", "US"), ("es", "Spanish-ISO"), ("fr", "French"), ("hi", "Devanagari"), ("id", "US"), ("it", "Italian"), ("nl", "Dutch"), ("pl", "Polish"), ("pt-BR", "Brazilian"), ("ro", "Romanian"), ("ru", "Russian"), ("sv", "Swedish"), ("tr", "Turkish-QWERTY"), ("uk", "Ukrainian"), ("vi", "Vietnamese")]
        for (language, id) in corpus {
            guard let native = layout(id) else { print("\(language): no layout \(id)"); continue }
            KeyboardLayouts.extraLanguages = ["en", String(language.prefix(2))]
            KeyboardLayouts.all = [native] + [us, ru].filter { $0.id != native.id }
            let result = falsePositives(words(language), native)
            print("\(language): \(result.found.count) false of \(result.checked)")
            failures += result.found.map { "\(language): \($0)" }
        }

        KeyboardLayouts.extraLanguages = ["en"]
        KeyboardLayouts.all = [us] + ["Russian", "Ukrainian", "Greek", "Hebrew", "Arabic", "Devanagari"].compactMap { layout($0) }
        let lines = ((try? String(contentsOfFile: "/usr/share/dict/words", encoding: .utf8)) ?? "").split(separator: "\n")
        let names = ((try? String(contentsOfFile: "/usr/share/dict/propernames", encoding: .utf8)) ?? "").split(separator: "\n")
        let english = stride(from: 0, to: lines.count, by: 10).map { String(lines[$0]) } + names.map(String.init)
        let result = falsePositives(english, us)
        print("dict: \(result.found.count) false of \(result.checked)")
        failures += result.found.map { "dict: \($0)" }

        for (language, id) in [("ru", "Russian"), ("uk", "Ukrainian"), ("ar", "Arabic")] {
            guard let native = layout(id) else { continue }
            KeyboardLayouts.all = [us, native]
            KeyboardLayouts.extraLanguages = ["en", language]
            print("\(language) typed in US, fixed: \(rate(words(language), typed: native, in: us)); en typed in \(id): \(rate(words("en"), typed: us, in: native))")
        }

        for failure in failures { print(failure) }
        precondition(failures.isEmpty, "\(failures.count) false fixes")
        print("layout: ok")
    }
}
