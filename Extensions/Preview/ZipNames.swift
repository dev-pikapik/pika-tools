import Foundation

enum ZipNames {
    struct Entry {
        var name: String
        var size: UInt64
        var packed: UInt64
        var method: Int
        var isFolder: Bool
        var encrypted: Bool
    }

    struct Directory {
        var entries: [Entry]
        var split: Bool
        var codePage: String?
    }

    static func read(_ url: URL, languages: [String] = Locale.preferredLanguages) -> Directory? {
        guard let file = try? FileHandle(forReadingFrom: url), let length = try? file.seekToEnd(), length >= 22 else { return nil }
        defer { try? file.close() }
        func bytes(_ offset: UInt64, _ count: Int) -> [UInt8]? {
            guard (try? file.seek(toOffset: offset)) != nil, let data = try? file.read(upToCount: count), data.count == count else { return nil }
            return [UInt8](data)
        }
        let window = Int(min(length, 22 + 65535 + 20))
        guard let tail = bytes(length - UInt64(window), window) else { return nil }
        var eocd = window - 22
        while eocd >= 0, !(tail.u32(eocd) == 0x06054b50 && eocd + 22 + tail.u16(eocd + 20) <= window) { eocd -= 1 }
        guard eocd >= 0 else { return nil }
        var disk = tail.u16(eocd + 4)
        var directoryDisk = tail.u16(eocd + 6)
        var onDisk = tail.u16(eocd + 8)
        var total = tail.u16(eocd + 10)
        var size = tail.u32(eocd + 12)
        var offset = tail.u32(eocd + 16)
        if total == 0xFFFF || size == 0xFFFF_FFFF || offset == 0xFFFF_FFFF, eocd >= 20, tail.u32(eocd - 20) == 0x07064b50 {
            guard let record = bytes(tail.u64(eocd - 12), 56), record.u32(0) == 0x06064b50 else { return nil }
            disk = Int(record.u32(16))
            directoryDisk = Int(record.u32(20))
            onDisk = Int(record.u64(24))
            total = Int(record.u64(32))
            size = record.u64(40)
            offset = record.u64(48)
        }
        let split = disk != 0 || directoryDisk != disk || onDisk != total
        let end = length - UInt64(window) + UInt64(eocd)
        guard directoryDisk == disk, size <= 512 << 20 else { return nil }
        if total == 0 { return Directory(entries: [], split: split, codePage: nil) }
        var directory: [UInt8] = []
        for start in [offset, end &- size] where start < length {
            if let candidate = bytes(start, Int(size)), candidate.u32(0) == 0x02014b50 {
                directory = candidate
                break
            }
        }
        var entries: [Entry] = []
        var legacy: [(index: Int, name: [UInt8])] = []
        var at = 0
        while at + 46 <= directory.count, directory.u32(at) == 0x02014b50 {
            let flags = directory.u16(at + 8)
            var method = directory.u16(at + 10)
            var packed = directory.u32(at + 20)
            var expanded = directory.u32(at + 24)
            let nameLength = directory.u16(at + 28)
            let extraLength = directory.u16(at + 30)
            let commentLength = directory.u16(at + 32)
            let extraStart = at + 46 + nameLength
            guard extraStart + extraLength + commentLength <= directory.count else { return nil }
            let raw = Array(directory[(at + 46)..<extraStart])
            var unicode: [UInt8]?
            var field = extraStart
            while field + 4 <= extraStart + extraLength {
                let id = directory.u16(field)
                let length = directory.u16(field + 2)
                let body = field + 4
                guard body + length <= extraStart + extraLength else { break }
                switch id {
                case 0x0001:
                    var next = body
                    if expanded == 0xFFFF_FFFF, next + 8 <= body + length { expanded = directory.u64(next); next += 8 }
                    if packed == 0xFFFF_FFFF, next + 8 <= body + length { packed = directory.u64(next) }
                case 0x7075 where length > 5 && directory[body] == 1:
                    unicode = Array(directory[(body + 5)..<(body + length)])
                case 0x9901 where length >= 7:
                    method = directory.u16(body + 5)
                default:
                    break
                }
                field = body + length
            }
            var name = ""
            if let unicode {
                name = String(decoding: unicode, as: UTF8.self)
            } else if flags & 0x800 != 0 || raw.allSatisfy({ $0 < 0x80 }) || String(bytes: raw, encoding: .utf8) != nil {
                name = String(decoding: raw, as: UTF8.self)
            } else {
                legacy.append((entries.count, raw))
            }
            entries.append(Entry(name: name, size: UInt64(expanded), packed: UInt64(packed), method: method, isFolder: raw.last == 0x2F, encrypted: flags & 1 != 0))
            at = extraStart + extraLength + commentLength
        }
        guard entries.count == total else { return nil }
        guard !legacy.isEmpty else { return Directory(entries: entries, split: split, codePage: nil) }
        let page = detect(legacy.map(\.name), languages: languages)
        for item in legacy { entries[item.index].name = decode(item.name, codePage: page) }
        return Directory(entries: entries, split: split, codePage: page)
    }

    static func detect(_ names: [[UInt8]], languages: [String] = Locale.preferredLanguages) -> String {
        let ukrainian = languages.contains { $0.lowercased().hasPrefix("uk") }
        let order = ranking(languages)
        var best = (name: "CP437", score: Int.min, rank: Int.max)
        for page in pages {
            guard let decoder = Decoder(page, ukrainian: ukrainian), let score = decoder.score(names.prefix(2000)) else { continue }
            let rank = order.firstIndex(of: page.name) ?? order.count
            if score > best.score || (score == best.score && rank < best.rank) { best = (page.name, score, rank) }
        }
        return best.name
    }

    static func decode(_ name: [UInt8], codePage: String) -> String {
        guard let page = pages.first(where: { $0.name == codePage }), let decoder = Decoder(page, ukrainian: false) else {
            return String(decoding: name, as: UTF8.self)
        }
        var result = String.UnicodeScalarView()
        var at = 0
        while at < name.count {
            if let unit = decoder.unit(name, at), let scalar = Unicode.Scalar(unit.scalar) {
                result.append(scalar)
                at += unit.length
            } else {
                result.append("\u{FFFD}")
                at += 1
            }
        }
        return String(result)
    }

    private enum Family { case cyrillic, latin, greek, hebrew, arabic, thai, japanese, simplified, traditional, korean }

    private enum Script { case latin, cyrillic, greek, hebrew, arabic, thai, kana, han, hangul, other }

    private struct Page {
        let name: String
        let family: Family
        let windows: UInt32
        var overrides: [UInt8: UInt32] = [:]
    }

    private static let pages: [Page] = [
        Page(name: "CP866", family: .cyrillic, windows: 866),
        Page(name: "CP1251", family: .cyrillic, windows: 1251),
        Page(name: "CP1125", family: .cyrillic, windows: 866, overrides: [0xF2: 0x490, 0xF3: 0x491, 0xF4: 0x404, 0xF5: 0x454, 0xF6: 0x406, 0xF7: 0x456, 0xF8: 0x407, 0xF9: 0x457]),
        Page(name: "CP850", family: .latin, windows: 850),
        Page(name: "CP437", family: .latin, windows: 437),
        Page(name: "CP1252", family: .latin, windows: 1252),
        Page(name: "CP852", family: .latin, windows: 852),
        Page(name: "CP1250", family: .latin, windows: 1250),
        Page(name: "CP857", family: .latin, windows: 857),
        Page(name: "CP1254", family: .latin, windows: 1254),
        Page(name: "CP1258", family: .latin, windows: 1258),
        Page(name: "CP737", family: .greek, windows: 737),
        Page(name: "CP1253", family: .greek, windows: 1253),
        Page(name: "CP862", family: .hebrew, windows: 862),
        Page(name: "CP1256", family: .arabic, windows: 1256),
        Page(name: "CP874", family: .thai, windows: 874),
        Page(name: "CP932", family: .japanese, windows: 932),
        Page(name: "GB18030", family: .simplified, windows: 936),
        Page(name: "CP950", family: .traditional, windows: 950),
        Page(name: "CP949", family: .korean, windows: 949),
    ]

    private static func ranking(_ languages: [String]) -> [String] {
        var order: [String] = []
        for language in languages {
            let lower = language.lowercased()
            let code = String(lower.prefix { $0 != "-" && $0 != "_" })
            switch code {
            case "ru", "be", "bg", "kk", "ky", "mk", "mn", "sr": order += ["CP866", "CP1251"]
            case "uk": order += ["CP866", "CP1251", "CP1125"]
            case "pl", "cs", "sk", "hu", "hr", "sl", "ro": order += ["CP852", "CP1250"]
            case "tr", "az": order += ["CP857", "CP1254"]
            case "el": order += ["CP737", "CP1253"]
            case "he": order += ["CP862"]
            case "ar", "fa", "ur": order += ["CP1256"]
            case "th": order += ["CP874"]
            case "vi": order += ["CP1258"]
            case "ja": order += ["CP932"]
            case "ko": order += ["CP949"]
            case "zh":
                let traditional = ["hant", "tw", "hk", "mo"].contains { lower.contains($0) }
                order += [traditional ? "CP950" : "GB18030"]
            default: order += ["CP850", "CP437", "CP1252"]
            }
        }
        order += ["CP850", "CP437", "CP1252", "GB18030", "CP932", "CP866", "CP1251", "CP949", "CP950"] + pages.map(\.name)
        var seen = Set<String>()
        return order.filter { seen.insert($0).inserted }
    }

    private static func script(_ c: UInt32) -> Script {
        switch c {
        case 0x41...0x24F, 0x1E00...0x1EFF: return .latin
        case 0x370...0x3FF, 0x1F00...0x1FFF: return .greek
        case 0x400...0x52F: return .cyrillic
        case 0x590...0x5FF: return .hebrew
        case 0x600...0x6FF, 0x750...0x77F: return .arabic
        case 0xE00...0xE7F: return .thai
        case 0x3040...0x30FF, 0x31F0...0x31FF, 0xFF66...0xFF9F: return .kana
        case 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF, 0x20000...0x2FFFF: return .han
        case 0x1100...0x11FF, 0x3130...0x318F, 0xAC00...0xD7A3: return .hangul
        default: return .other
        }
    }

    private static func isLetter(_ c: UInt32) -> Bool {
        Unicode.Scalar(c)?.properties.isAlphabetic ?? false
    }

    private static func isPunctuation(_ c: UInt32) -> Bool {
        switch c {
        case 0x3000...0x303F, 0xFF01...0xFF65, 0xFFE0...0xFFEF, 0x2010...0x2027, 0xB7: return true
        default: return false
        }
    }

    private final class Decoder {
        let page: Page
        let ukrainian: Bool
        let encoding: CFStringEncoding
        var single = [UInt32?](repeating: nil, count: 256)
        var pairs: [UInt16: UInt32] = [:]
        var multibyte: Bool { page.family == .japanese || page.family == .simplified || page.family == .traditional || page.family == .korean }

        init?(_ page: Page, ukrainian: Bool) {
            let encoding = CFStringConvertWindowsCodepageToEncoding(page.windows)
            guard encoding != kCFStringEncodingInvalidId else { return nil }
            self.page = page
            self.ukrainian = ukrainian
            self.encoding = encoding
            for byte in 0x80...0xFF { single[byte] = page.overrides[UInt8(byte)] ?? scalar([UInt8(byte)]) }
        }

        func scalar(_ bytes: [UInt8]) -> UInt32? {
            guard let string = CFStringCreateWithBytes(nil, bytes, bytes.count, encoding, false) as String?, string.unicodeScalars.count == 1 else { return nil }
            return string.unicodeScalars.first?.value
        }

        func unit(_ name: [UInt8], _ at: Int) -> (length: Int, scalar: UInt32, lead: UInt8, trail: UInt8)? {
            let lead = name[at]
            if lead < 0x80 { return (1, UInt32(lead), lead, 0) }
            if let scalar = single[Int(lead)] { return (1, scalar, lead, 0) }
            guard multibyte, lead != 0x80, lead != 0xFF, at + 1 < name.count else { return nil }
            let trail = name[at + 1]
            let key = UInt16(lead) << 8 | UInt16(trail)
            if pairs[key] == nil { pairs[key] = scalar([lead, trail]) ?? 0 }
            guard let scalar = pairs[key], scalar != 0 else { return nil }
            return (2, scalar, lead, trail)
        }

        func score(_ names: ArraySlice<[UInt8]>) -> Int? {
            var total = 0
            for name in names {
                var scalars: [UInt32] = []
                var at = 0
                while at < name.count {
                    guard let piece = unit(name, at) else { return nil }
                    if piece.scalar >= 0x80 { total += weight(piece.scalar, piece.length, piece.lead, piece.trail) }
                    scalars.append(piece.scalar)
                    at += piece.length
                }
                var word = 0
                var accented = false
                var lower: UInt32?
                for c in scalars {
                    let kind = !isLetter(c) ? 0 : script(c) == .latin ? 1 : 2
                    if kind != 0, word != 0, kind != word { total -= 3 }
                    if kind == 1, c >= 0x80, accented { total -= 2 }
                    if let before = lower, Unicode.Scalar(c)?.properties.isUppercase == true, before >= 0x80 || c >= 0x80 { total -= 2 }
                    word = kind
                    accented = kind == 1 && c >= 0x80
                    lower = kind != 0 && Unicode.Scalar(c)?.properties.isLowercase == true ? c : nil
                }
            }
            return total
        }

        func weight(_ c: UInt32, _ length: Int, _ lead: UInt8, _ trail: UInt8) -> Int {
            let kind = ZipNames.script(c)
            switch page.family {
            case .cyrillic, .latin, .greek, .hebrew, .arabic, .thai:
                if !ZipNames.isLetter(c) {
                    return page.family == .latin && Unicode.Scalar(c)?.properties.generalCategory == .nonspacingMark ? 0 : -3
                }
                let home: Script
                switch page.family {
                case .cyrillic: home = .cyrillic
                case .latin: home = .latin
                case .greek: home = .greek
                case .hebrew: home = .hebrew
                case .arabic: home = .arabic
                default: home = .thai
                }
                guard kind == home else { return -1 }
                guard page.family == .cyrillic, !(0x410...0x44F ~= c || c == 0x401 || c == 0x451) else { return 2 }
                return ukrainian && [0x490, 0x491, 0x404, 0x454, 0x406, 0x456, 0x407, 0x457].contains(c) ? 2 : 1
            case .japanese:
                if length == 1 { return -1 }
                switch kind {
                case .kana: return 4
                case .han: return 0x88...0x98 ~= lead ? 4 : (0x99...0x9F ~= lead || 0xE0...0xEA ~= lead) ? 2 : 0
                default: return penalty(c)
                }
            case .simplified:
                if kind == .han { return 0xB0...0xF7 ~= lead && trail >= 0xA1 ? 4 : 2 }
                return penalty(c)
            case .traditional:
                if kind == .han { return 0xA4...0xC6 ~= lead ? 4 : 0xC9...0xF9 ~= lead ? 2 : 0 }
                return penalty(c)
            case .korean:
                if c >= 0xAC00 && c <= 0xD7A3 { return 0xB0...0xC8 ~= lead && trail >= 0xA1 ? 4 : 2 }
                if kind == .han { return 2 }
                if c >= 0x3131 && c <= 0x318E { return 0 }
                return penalty(c)
            }
        }

        func penalty(_ c: UInt32) -> Int {
            if ZipNames.isPunctuation(c) { return 0 }
            return ZipNames.isLetter(c) ? -1 : -3
        }
    }
}

private extension Array where Element == UInt8 {
    func u16(_ at: Int) -> Int { Int(self[at]) | Int(self[at + 1]) << 8 }
    func u32(_ at: Int) -> UInt64 { UInt64(u16(at)) | UInt64(u16(at + 2)) << 16 }
    func u64(_ at: Int) -> UInt64 { u32(at) | u32(at + 4) << 32 }
}
