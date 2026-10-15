import Foundation

@main
struct TestMenuItems {
    static func blocks(_ text: String) -> [String] {
        let chars = Array(text)
        guard let start = try? NSRegularExpression(pattern: #"(?<![A-Za-z])Menu\s*[({]"#) else { return [] }
        var found: [String] = []
        for match in start.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            var i = match.range.location + match.range.length - 1
            if chars[i] == "(" {
                var paren = 0
                while i < chars.count {
                    if chars[i] == "(" { paren += 1 } else if chars[i] == ")" { paren -= 1 }
                    i += 1
                    if paren == 0 { break }
                }
                while i < chars.count, chars[i] != "{", chars[i] != "\n" { i += 1 }
                guard i < chars.count, chars[i] == "{" else { continue }
            }
            let begin = i
            var depth = 0
            while i < chars.count {
                if chars[i] == "{" { depth += 1 } else if chars[i] == "}" { depth -= 1 }
                i += 1
                if depth == 0 {
                    let rest = String(chars[i..<min(i + 12, chars.count)]).trimmingCharacters(in: .whitespaces)
                    if rest.hasPrefix("label") { while i < chars.count, chars[i] != "{" { i += 1 } } else { break }
                }
            }
            found.append(String(chars[begin..<min(i, chars.count)]))
        }
        return found
    }

    static func unstyled(_ block: String) -> Bool {
        block.components(separatedBy: "Toggle(").count > block.components(separatedBy: ".toggleStyle(.automatic)").count
    }

    static func main() {
        let sample = """
        Menu("A") { Toggle("x", isOn: b) }
        Menu { Button("y") {} } label: { Text("z") }
        Menu("B") { ForEach(l) { Toggle("x", isOn: b).toggleStyle(.automatic) } }
        Menu("C") { Picker("p", selection: s) { Text("q").tag(1) } }
        """
        precondition(blocks(sample).map(unstyled) == [true, false, false, false])
        print("a Toggle inside a Menu is spotted unless it keeps the automatic style: ok")

        let files = FileManager.default.enumerator(atPath: "Sources")?.compactMap { $0 as? String }.filter { $0.hasSuffix(".swift") } ?? []
        precondition(files.count > 50)
        var bad: [String] = []
        for file in files {
            guard let text = try? String(contentsOfFile: "Sources/" + file, encoding: .utf8) else { continue }
            if blocks(text).contains(where: unstyled) { bad.append(file) }
        }
        precondition(bad.isEmpty, "A Toggle inside a Menu needs .toggleStyle(.automatic); under the settings switch style it draws three rows and does nothing: \(bad)")
        print("every Toggle in a Menu in Sources keeps the automatic style (\(files.count) files): ok")
    }
}
