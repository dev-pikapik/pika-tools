import Foundation

struct SubtitleCue: Equatable {
    var start: Double
    var end: Double
    var text: String
}

struct SubtitleSpan: Equatable {
    var text: String
    var italic: Bool
    var bold: Bool
}

struct SubtitleCues {
    private let cues: [SubtitleCue]
    private let longest: Double

    init(_ cues: [SubtitleCue]) {
        self.cues = cues.sorted { $0.start < $1.start }
        longest = cues.map { $0.end - $0.start }.max() ?? 0
    }

    var isEmpty: Bool { cues.isEmpty }

    func text(at time: Double, delay: Double = 0) -> String? {
        let moment = time - delay
        var low = 0, high = cues.count
        while low < high {
            let middle = (low + high) / 2
            if cues[middle].start <= moment { low = middle + 1 } else { high = middle }
        }
        var active: [String] = []
        var index = low - 1
        while index >= 0, cues[index].start >= moment - longest {
            if cues[index].end > moment { active.append(cues[index].text) }
            index -= 1
        }
        return active.isEmpty ? nil : active.reversed().joined(separator: "\n")
    }
}

enum SubtitleText {
    private static let (italicOn, italicOff, boldOn, boldOff) = (Character("\u{E000}"), Character("\u{E001}"), Character("\u{E002}"), Character("\u{E003}"))
    private static let entities = ["amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u{A0}", "lrm": "", "rlm": ""]
    private static let markup: Set<String> = ["i", "b", "u", "s", "em", "strong", "font", "c", "v", "lang", "ruby", "rt", "span", "br", "p", "a"]

    static func clean(_ raw: String, ass: Bool = false) -> String {
        let source = Array(raw.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n"))
        var out = ""
        var drawing = false
        var index = 0
        func append(_ piece: some StringProtocol) {
            if !drawing { out += piece }
        }
        while index < source.count {
            let char = source[index]
            switch char {
            case "{":
                guard let close = find("}", in: source, from: index, within: 400) else {
                    append("{")
                    break
                }
                for part in String(source[(index + 1)..<close]).split(separator: "\\", omittingEmptySubsequences: true) {
                    let tag = String(part).trimmingCharacters(in: .whitespaces)
                    switch tag {
                    case "i1": append(String(italicOn))
                    case "i0": append(String(italicOff))
                    case "b0": append(String(boldOff))
                    case "b1", "b700": append(String(boldOn))
                    default:
                        if tag.hasPrefix("p"), let level = Int(tag.dropFirst()) { drawing = level > 0 }
                        if tag.hasPrefix("b"), let weight = Int(tag.dropFirst()), weight >= 600 { append(String(boldOn)) }
                    }
                }
                index = close
            case "<":
                guard let close = find(">", in: source, from: index, within: 200), let kind = tagKind(String(source[(index + 1)..<close])) else {
                    append("<")
                    break
                }
                switch kind {
                case "i": append(String(italicOn))
                case "/i": append(String(italicOff))
                case "b": append(String(boldOn))
                case "/b": append(String(boldOff))
                case "br": append("\n")
                default: break
                }
                index = close
            case "\\" where ass && index + 1 < source.count && "Nnh".contains(source[index + 1]):
                append(source[index + 1] == "N" ? "\n" : source[index + 1] == "n" ? " " : "\u{A0}")
                index += 1
            case "&":
                if let close = find(";", in: source, from: index, within: 10), let text = entity(String(source[(index + 1)..<close])) {
                    append(text)
                    index = close
                } else {
                    append("&")
                }
            case italicOn, italicOff, boldOn, boldOff:
                break
            default:
                append(String(char))
            }
            index += 1
        }
        return out.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    static func plain(_ text: String) -> String {
        text.filter { !"\u{E000}\u{E001}\u{E002}\u{E003}".contains($0) }
    }

    static func spans(_ text: String) -> [SubtitleSpan] {
        var result: [SubtitleSpan] = []
        var (italic, bold) = (false, false)
        var current = ""
        func flush() {
            if !current.isEmpty { result.append(SubtitleSpan(text: current, italic: italic, bold: bold)) }
            current = ""
        }
        for char in text {
            switch char {
            case italicOn: flush(); italic = true
            case italicOff: flush(); italic = false
            case boldOn: flush(); bold = true
            case boldOff: flush(); bold = false
            default: current.append(char)
            }
        }
        flush()
        return result
    }

    private static func find(_ target: Character, in source: [Character], from start: Int, within limit: Int) -> Int? {
        var index = start + 1
        while index < source.count, index <= start + limit {
            if source[index] == target { return index }
            index += 1
        }
        return nil
    }

    private static func tagKind(_ body: String) -> String? {
        if !body.isEmpty, body.allSatisfy({ $0.isNumber || ":.".contains($0) }) { return "" }
        let closing = body.hasPrefix("/")
        let name = String(body.dropFirst(closing ? 1 : 0).prefix { $0.isLetter }).lowercased()
        guard markup.contains(name) else { return nil }
        return (closing ? "/" : "") + name
    }

    private static func entity(_ name: String) -> String? {
        if let known = entities[name] { return known }
        guard name.hasPrefix("#") else { return nil }
        let digits = name.dropFirst()
        let value = digits.hasPrefix("x") || digits.hasPrefix("X") ? UInt32(digits.dropFirst(), radix: 16) : UInt32(digits)
        return value.flatMap(Unicode.Scalar.init).map { String(Character($0)) }
    }
}

enum SubtitleParser {
    static let sizeLimit = 16 << 20

    static func decode(_ data: Data) -> String? {
        guard data.count <= sizeLimit else { return nil }
        let bytes = [UInt8](data.prefix(4))
        if bytes.starts(with: [0xEF, 0xBB, 0xBF]) { return String(decoding: data.dropFirst(3), as: UTF8.self) }
        if bytes.starts(with: [0xFF, 0xFE]) { return String(data: data.dropFirst(2), encoding: .utf16LittleEndian) }
        if bytes.starts(with: [0xFE, 0xFF]) { return String(data: data.dropFirst(2), encoding: .utf16BigEndian) }
        if bytes.count >= 4 {
            if bytes[1] == 0, bytes[3] == 0, bytes[0] != 0 { return String(data: data, encoding: .utf16LittleEndian) }
            if bytes[0] == 0, bytes[2] == 0, bytes[1] != 0 { return String(data: data, encoding: .utf16BigEndian) }
        }
        if let text = String(data: data, encoding: .utf8) { return text }
        var converted: NSString?
        var lossy = ObjCBool(false)
        let encoding = NSString.stringEncoding(for: data, encodingOptions: [.allowLossyKey: false], convertedString: &converted, usedLossyConversion: &lossy)
        if encoding != 0, let converted { return converted as String }
        return String(data: data, encoding: .windowsCP1252) ?? String(data: data, encoding: .isoLatin1)
    }

    static func parse(_ data: Data) -> [SubtitleCue] {
        decode(data).map(parse) ?? []
    }

    static func parse(_ text: String) -> [SubtitleCue] {
        let text = text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n").split(separator: "\n", omittingEmptySubsequences: false)
        let isASS = lines.contains { $0.hasPrefix("[Script Info]") || $0.hasPrefix("[Events]") || $0.hasPrefix("Dialogue:") }
        return isASS ? assCues(lines) : timedCues(lines)
    }

    static func time(_ token: String) -> Double? {
        let parts = token.trimmingCharacters(in: .whitespaces).split(separator: ":", omittingEmptySubsequences: false)
        guard (2...3).contains(parts.count) else { return nil }
        var seconds = 0.0
        for (position, part) in parts.enumerated() {
            let clean = part.replacingOccurrences(of: ",", with: ".")
            guard !clean.isEmpty, clean.count <= 12, clean.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }), clean.filter({ $0 == "." }).count <= 1,
                  position == parts.count - 1 || !clean.contains("."), let value = Double(clean) else { return nil }
            seconds = seconds * 60 + value
        }
        return seconds.isFinite && seconds < 360_000 ? seconds : nil
    }

    static func movText(_ data: Data) -> String? {
        let bytes = [UInt8](data)
        guard bytes.count >= 2 else { return nil }
        let length = min(Int(bytes[0]) << 8 | Int(bytes[1]), bytes.count - 2)
        guard length > 0 else { return nil }
        let body = Data(bytes[2..<(2 + length)])
        let text = body.starts(with: [0xFE, 0xFF]) ? String(data: body.dropFirst(2), encoding: .utf16BigEndian)
            : body.starts(with: [0xFF, 0xFE]) ? String(data: body.dropFirst(2), encoding: .utf16LittleEndian)
            : String(decoding: body, as: UTF8.self)
        return text.map { SubtitleText.clean($0) }.flatMap { $0.isEmpty ? nil : $0 }
    }

    static func webVTTBox(_ data: Data) -> String? {
        let bytes = [UInt8](data)
        var lines: [String] = []
        func boxes(_ range: Range<Int>, _ visit: (String, Range<Int>) -> Void) {
            var position = range.lowerBound
            while position + 8 <= range.upperBound {
                let size = Int(bytes[position]) << 24 | Int(bytes[position + 1]) << 16 | Int(bytes[position + 2]) << 8 | Int(bytes[position + 3])
                guard size >= 8, position + size <= range.upperBound else { return }
                visit(String(decoding: bytes[(position + 4)..<(position + 8)], as: UTF8.self), (position + 8)..<(position + size))
                position += size
            }
        }
        boxes(0..<bytes.count) { kind, body in
            guard kind == "vttc" else { return }
            boxes(body) { inner, text in
                if inner == "payl" { lines.append(String(decoding: bytes[text], as: UTF8.self)) }
            }
        }
        let text = SubtitleText.clean(lines.joined(separator: "\n"))
        return text.isEmpty ? nil : text
    }

    static func ass(packet text: String) -> String? {
        let fields = text.split(separator: ",", maxSplits: 8, omittingEmptySubsequences: false)
        guard fields.count == 9 else { return nil }
        let cleaned = SubtitleText.clean(String(fields[8]), ass: true)
        return cleaned.isEmpty ? nil : cleaned
    }

    private static func timedCues(_ lines: [Substring]) -> [SubtitleCue] {
        var cues: [SubtitleCue] = []
        var current: (start: Double, end: Double, lines: [String])?
        func finish() {
            guard let open = current else { return }
            current = nil
            let text = SubtitleText.clean(open.lines.joined(separator: "\n"))
            if !text.isEmpty { cues.append(SubtitleCue(start: open.start, end: open.end, text: text)) }
        }
        for line in lines {
            if line.contains("-->") {
                if var open = current, let last = open.lines.last, !last.isEmpty, last.allSatisfy(\.isNumber) {
                    open.lines.removeLast()
                    current = open
                }
                finish()
                let sides = line.components(separatedBy: "-->")
                if sides.count == 2, let start = time(sides[0]), let end = time(String(sides[1].split(separator: " ", omittingEmptySubsequences: true).first ?? "")), end > start {
                    current = (start, end, [])
                }
            } else if line.allSatisfy(\.isWhitespace) {
                finish()
            } else if current != nil {
                current?.lines.append(String(line))
            }
        }
        finish()
        return cues
    }

    private static func assCues(_ lines: [Substring]) -> [SubtitleCue] {
        var fields = ["layer", "start", "end", "style", "name", "marginl", "marginr", "marginv", "effect", "text"]
        var inEvents = false
        var cues: [SubtitleCue] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("[") {
                inEvents = trimmed.lowercased() == "[events]"
            } else if trimmed.hasPrefix("Format:"), inEvents {
                fields = trimmed.dropFirst(7).split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            } else if trimmed.hasPrefix("Dialogue:") {
                guard let start = fields.firstIndex(of: "start"), let end = fields.firstIndex(of: "end"), let text = fields.firstIndex(of: "text") else { continue }
                let values = trimmed.dropFirst(9).split(separator: ",", maxSplits: fields.count - 1, omittingEmptySubsequences: false)
                guard values.count == fields.count, let from = time(String(values[start])), let to = time(String(values[end])), to > from else { continue }
                let cleaned = SubtitleText.clean(String(values[text]), ass: true)
                if !cleaned.isEmpty { cues.append(SubtitleCue(start: from, end: to, text: cleaned)) }
            }
        }
        return cues
    }
}

enum SubtitleStyle {
    static func clampedScale(_ scale: Double) -> Double { min(max((scale * 10).rounded() / 10, 0.5), 3) }

    static func fontSize(forHeight height: Double, scale: Double) -> Double { max(12, height * 0.045 * clampedScale(scale)) }
}

enum SubtitleFiles {
    static let extensions: Set<String> = ["srt", "vtt", "ass", "ssa"]

    static func matching(video: URL, among files: [URL]) -> [URL] {
        let base = video.deletingPathExtension().lastPathComponent.lowercased()
        return files.filter { file in
            guard extensions.contains(file.pathExtension.lowercased()) else { return false }
            let name = file.deletingPathExtension().lastPathComponent.lowercased()
            return name == base || name.hasPrefix(base + ".")
        }.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }
}

enum PlayerTracks {
    private static let bibliographic = ["fre": "fr", "ger": "de", "chi": "zh", "cze": "cs", "dut": "nl", "gre": "el", "rum": "ro", "slo": "sk", "per": "fa", "alb": "sq", "arm": "hy", "wel": "cy", "ice": "is", "mac": "mk"]

    static func language(_ code: String?) -> String? {
        guard let code = code?.trimmingCharacters(in: .whitespaces).lowercased(), !code.isEmpty, code != "und", code != "zxx" else { return nil }
        let base = code.split(whereSeparator: { "-_".contains($0) }).first.map(String.init) ?? code
        if let short = bibliographic[base] { return short }
        return base.count == 2 ? base : Locale.LanguageCode(base).identifier(.alpha2)
    }

    static func title(language code: String?, name: String?, number: Int, locale: Locale = .current) -> String {
        let spoken = language(code).flatMap { locale.localizedString(forLanguageCode: $0) }.map { $0.prefix(1).uppercased() + $0.dropFirst() }
        let name = name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        switch (spoken, name) {
        case let (spoken?, name?) where name.caseInsensitiveCompare(spoken) != .orderedSame: return "\(spoken) — \(name)"
        case let (spoken?, _): return spoken
        case let (_, name?): return name
        default: return String(localized: "Track \(number)")
        }
    }

    static func preferred(among languages: [String?], system: [String] = Locale.preferredLanguages) -> Int? {
        let wanted = system.compactMap { Locale.Language(identifier: $0).languageCode?.identifier }
        for code in wanted {
            if let index = languages.firstIndex(where: { language($0) == code }) { return index }
        }
        return nil
    }
}

enum PlayerChoices {
    static let limit = 200

    static func updated(_ saved: [String: [String]], key: String, audio: String, subtitle: String, at now: Double) -> [String: [String]] {
        var saved = saved
        saved[key] = [audio, subtitle, String(now)]
        while saved.count > limit, let oldest = saved.min(by: { (Double($0.value.last ?? "") ?? 0) < (Double($1.value.last ?? "") ?? 0) })?.key { saved[oldest] = nil }
        return saved
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
