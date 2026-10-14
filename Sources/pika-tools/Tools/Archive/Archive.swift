import Foundation

enum ArchiveError: Error, Equatable {
    case needsPassword
    case wrongPassword
    case unsupportedPassword
    case missingPart(String)
    case truncated
    case damaged(extracted: Int, total: Int, result: URL)
    case noSpace(needed: Int64, free: Int64)
    case huge(expanded: Int64, packed: Int64)
    case unsupported
    case cancelled
    case failed(String)
}

enum Archive {
    struct Info: Equatable {
        var entries = 0
        var expandedSize: Int64 = 0
        var packedSize: Int64 = 0
        var isEncrypted = false
        var names: [String] = []
        var isTruncated = false
        var isMultiPart = false
        var codePage: String?
    }

    enum Format: CaseIterable {
        case zip, sevenZip, tarGz, tarXz

        var fileExtension: String {
            switch self {
            case .zip: "zip"
            case .sevenZip: "7z"
            case .tarGz: "tar.gz"
            case .tarXz: "tar.xz"
            }
        }

        #if APPSTORE
        var supportsPassword: Bool { self == .zip }
        #else
        var supportsPassword: Bool { self == .zip || self == .sevenZip }
        #endif
    }

    final class Job: @unchecked Sendable {
        private let lock = NSLock()
        private var cancelled = false
        private var processes: [Process] = []

        init() {}

        var isCancelled: Bool { lock.withLock { cancelled } }

        func cancel() {
            let running: [Process] = lock.withLock {
                cancelled = true
                return processes.filter(\.isRunning)
            }
            running.forEach { $0.terminate() }
        }

        func attach(_ process: Process) -> Bool {
            lock.withLock {
                guard !cancelled else { return false }
                processes.append(process)
                return true
            }
        }

        func detach(_ process: Process) {
            lock.withLock { processes.removeAll { $0 === process } }
        }
    }

    static let extensions: Set<String> = [
        "zip", "zipx", "7z", "rar", "cab", "lzh", "lha", "arj", "zst", "tzst", "lzma", "tlz", "wim",
        "tar", "tgz", "gz", "tbz", "tbz2", "bz2", "txz", "xz", "z", "taz", "cpio", "cpgz",
    ]

    static let streamExtensions: Set<String> = [
        "gz", "xz", "bz2", "zst", "lzma", "z", "tgz", "txz", "tbz", "tbz2", "tzst", "tlz", "taz", "cpgz",
    ]

    static func isArchive(_ url: URL) -> Bool {
        let name = url.lastPathComponent
        if extensions.contains((name as NSString).pathExtension.lowercased()) { return true }
        guard let part = PartName(name) else { return false }
        guard part.kind == .numbered else { return true }
        return part.number == 1 || extensions.contains((part.stem as NSString).pathExtension.lowercased())
    }

    static func firstPart(_ url: URL) -> URL {
        guard let part = PartName(url.lastPathComponent) else { return url }
        return url.deletingLastPathComponent().appending(path: part.first)
    }

    static func streamExtension(_ url: URL) -> String {
        let name = url.lastPathComponent
        return ((PartName(name)?.stem ?? name) as NSString).pathExtension.lowercased()
    }

    static func streamName(_ url: URL) -> String {
        let name = PartName(url.lastPathComponent)?.stem ?? url.lastPathComponent
        let base = (name as NSString).deletingPathExtension
        switch streamExtension(url) {
        case "cpgz": return base + ".cpio"
        case "tgz", "txz", "tbz", "tbz2", "tzst", "tlz", "taz": return base + ".tar"
        default: return base
        }
    }

    static func distinct(_ urls: [URL]) -> [URL] {
        var seen = Set<String>()
        return urls.map(firstPart).filter { seen.insert($0.standardizedFileURL.path).inserted }
    }

    static func baseName(_ url: URL) -> String {
        let name = firstPart(url).lastPathComponent
        var base = PartName(name)?.stem ?? name
        if extensions.contains((base as NSString).pathExtension.lowercased()) { base = (base as NSString).deletingPathExtension }
        if base.lowercased().hasSuffix(".tar") { base = (base as NSString).deletingPathExtension }
        return base.isEmpty ? name : base
    }

    static func parts(of url: URL) -> (urls: [URL], missing: String?) {
        let first = firstPart(url)
        let folder = first.deletingLastPathComponent()
        let siblings = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        let expected = sequence(first.lastPathComponent, siblings)
        let present = Set(siblings.map { $0.lowercased() })
        let found = expected.filter { present.contains($0.lowercased()) }.map { folder.appending(path: $0) }
        guard expected.count > 1 else { return ([first], nil) }
        return (found, expected.first { !present.contains($0.lowercased()) })
    }

    private static func sequence(_ name: String, _ siblings: [String]) -> [String] {
        let lower = name.lowercased()
        if let part = PartName(name) {
            let matching = siblings.compactMap { PartName($0) }.filter { $0.matches(part) }
            let last = min(matching.map(\.number).max() ?? 1, matching.count + 1)
            return (1...max(last, 1)).map { part.name($0) }
        }
        let stem = (name as NSString).deletingPathExtension
        let upper = name == name.uppercased()
        let stemLower = stem.lowercased()
        func numbers(_ letter: String) -> [Int] {
            siblings.compactMap { sibling in
                let ext = (sibling as NSString).pathExtension
                guard (sibling as NSString).deletingPathExtension.lowercased() == stemLower, ext.count == 3, ext.lowercased().hasPrefix(letter) else { return nil }
                return Int(ext.dropFirst())
            }
        }
        if lower.hasSuffix(".rar") {
            let last = numbers("r").max()
            guard let last, last >= 0 else { return [name] }
            return [name] + (0...last).map { stem + (upper ? ".R" : ".r") + String(format: "%02d", $0) }
        }
        if lower.hasSuffix(".zip") {
            let last = numbers("z").max()
            guard let last, last > 0 else { return [name] }
            return (1...last).map { stem + (upper ? ".Z" : ".z") + String(format: "%02d", $0) } + [name]
        }
        return [name]
    }

    private struct PartName {
        enum Kind { case numbered, rar, oldRar, zip }

        let kind: Kind
        let stem: String
        let prefix: String
        let suffix: String
        let number: Int
        let width: Int

        init?(_ name: String) {
            let ext = (name as NSString).pathExtension
            let base = (name as NSString).deletingPathExtension
            let lower = ext.lowercased()
            func digits(_ text: some StringProtocol) -> Bool { !text.isEmpty && text.allSatisfy { $0 >= "0" && $0 <= "9" } }
            if ext.count >= 3, digits(ext), !base.isEmpty, let number = Int(ext) {
                self.init(.numbered, stem: base, prefix: base + ".", suffix: "", number: number, width: ext.count)
            } else if lower == "rar", let range = base.range(of: ".part", options: [.caseInsensitive, .backwards]), digits(base[range.upperBound...]), let number = Int(base[range.upperBound...]) {
                self.init(.rar, stem: String(base[..<range.lowerBound]), prefix: String(base[..<range.upperBound]), suffix: "." + ext, number: number, width: base[range.upperBound...].count)
            } else if ext.count == 3, lower.hasPrefix("r") || lower.hasPrefix("z"), digits(ext.dropFirst()), !base.isEmpty, let number = Int(ext.dropFirst()) {
                self.init(lower.hasPrefix("r") ? .oldRar : .zip, stem: base, prefix: base + "." + ext.prefix(1), suffix: "", number: number, width: 2)
            } else {
                return nil
            }
        }

        private init(_ kind: Kind, stem: String, prefix: String, suffix: String, number: Int, width: Int) {
            self.kind = kind
            self.stem = stem
            self.prefix = prefix
            self.suffix = suffix
            self.number = number
            self.width = width
        }

        var first: String {
            switch kind {
            case .numbered, .rar: name(1)
            case .oldRar: stem + (prefix.last == "R" ? ".RAR" : ".rar")
            case .zip: stem + (prefix.last == "Z" ? ".ZIP" : ".zip")
            }
        }

        func name(_ number: Int) -> String {
            prefix + String(format: "%0\(width)d", number) + suffix
        }

        func matches(_ other: PartName) -> Bool {
            kind == other.kind && width == other.width && prefix.lowercased() == other.prefix.lowercased() && suffix.lowercased() == other.suffix.lowercased()
        }
    }
}
