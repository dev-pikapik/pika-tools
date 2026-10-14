import Foundation

extension Archive {
    enum Route: Equatable {
        case sevenZip, ditto
        case bsdtar(String)
        #if APPSTORE
        case stream(URL)
        #endif
    }

    struct Listing {
        var info = Info()
        var files = 0
        var inner: String?
        #if APPSTORE
        var route = Route.bsdtar("")
        #else
        var route = Route.sevenZip
        #endif
    }

    struct Diagnosis {
        var password = false
        var missing: String?
        var truncated = false
        var space = false
        var notArchive = false
        var bad: [String] = []
        var ignored: [String] = []
        var other: String?

        init(_ messages: [String], stream: Bool = false) {
            for line in messages {
                let split = line.range(of: " : ")
                let whole = line.lowercased()
                let text = (split.map { String(line[..<$0.lowerBound]) } ?? line).lowercased()
                let path = split.map { String(line[$0.upperBound...]) }
                if text.contains("wrong password") || whole.hasSuffix("wrong password?") {
                    password = true
                } else if text.contains("missing volume") {
                    missing = (path ?? line).components(separatedBy: "/").last
                } else if text.contains("dangerous link path") {
                    if let path { ignored.append(path.components(separatedBy: " : ")[0]) }
                } else if text.contains("unexpected end of archive") {
                    truncated = true
                } else if text.contains("unexpected end of data") {
                    truncated = true
                    if let path { bad.append(path) }
                } else if whole.contains("no space left") {
                    space = true
                } else if ["is not archive", "cannot open the file as", "can't open as archive"].contains(where: whole.contains) {
                    notArchive = true
                } else if text.contains("crc failed") || text.contains("data error") || text.contains("unsupported method") {
                    if stream, text.contains("data error") { truncated = true }
                    if let path { bad.append(path) }
                } else if text.hasPrefix("error") || text.hasPrefix("system error") {
                    other = other ?? line
                }
            }
        }
    }

    struct Tally {
        var listing = Listing()
        private var seen = Set<String>()

        mutating func add(_ path: String, folder: Bool, size: Int64, encrypted: Bool) {
            listing.info.expandedSize += min(size, .max - listing.info.expandedSize)
            guard !isJunk(path: path) else { return }
            listing.info.entries += 1
            listing.files += folder ? 0 : 1
            if encrypted { listing.info.isEncrypted = true }
            guard let top = path.split(separator: "/").first(where: { $0 != "." }), listing.info.names.count < 1000, seen.insert(String(top)).inserted else { return }
            listing.info.names.append(String(top))
        }
    }

    final class Records: @unchecked Sendable {
        private(set) var tally = Tally()
        private(set) var lastPath: String?
        private let fallback: String?
        private var started = false
        private var path: String?
        private var folder = false
        private var size: Int64 = 0
        private var encrypted = false

        init(fallback: String? = nil) {
            self.fallback = fallback
        }

        func feed(_ line: String) {
            if line.isEmpty { return commit() }
            guard let range = line.range(of: " = ") else { return }
            started = true
            let value = String(line[range.upperBound...])
            switch line[..<range.lowerBound] {
            case "Path": path = path ?? value
            case "Folder": folder = value == "+"
            case "Size": size = UInt64(value).map { Int64(clamping: $0) } ?? 0
            case "Encrypted": encrypted = value == "+"
            default: break
            }
        }

        func commit() {
            if let path = path ?? (started ? fallback : nil) {
                tally.add(path, folder: folder, size: size, encrypted: encrypted)
                lastPath = path
            }
            started = false
            path = nil
            folder = false
            size = 0
            encrypted = false
        }
    }

    static func probe(_ url: URL, password: String? = nil, job: Job = Job()) throws -> Info {
        try inspect(url, password: try checked(password), job: job, deep: true).info
    }

    static func checked(_ password: String?) throws -> String? {
        guard let password, !password.isEmpty else { return nil }
        guard !password.contains(where: \.isNewline) else { throw ArchiveError.wrongPassword }
        return password
    }

    static func credentials(_ password: String?) -> (arguments: [String], input: Data?) {
        guard let password else { return (["-pX"], nil) }
        return ([], Data((password + "\n").utf8))
    }

    static func isJunk(path: String) -> Bool {
        let parts = path.split(separator: "/")
        return parts.contains("__MACOSX") || parts.last.map { $0 == ".DS_Store" || $0.hasPrefix("._") } == true
    }

    static func inspect(_ url: URL, password: String?, job: Job, deep: Bool) throws -> Listing {
        let found = parts(of: url)
        if let missing = found.missing { throw ArchiveError.missingPart(missing) }
        let first = firstPart(url)
        guard FileManager.default.fileExists(atPath: first.path) else { throw ArchiveError.failed("not found") }
        #if APPSTORE
        guard found.urls.count == 1 else { throw ArchiveError.unsupported }
        #endif
        var listing: Listing
        if let zip = zipListing(first) {
            listing = zip
        } else {
            #if APPSTORE
            listing = try streamListing(first) ?? bsdtarListing(first, password: password, job: job)
            #else
            listing = try sevenZipListing(first, password: password, job: job, deep: deep)
            #endif
        }
        listing.info.packedSize = found.urls.reduce(0) { $0 + Int64((try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0) }
        // gzip keeps the size modulo 2^32 and deflate cannot beat 1032:1, so anything above that is garbage
        if ["gz", "tgz"].contains(streamExtension(first)), listing.info.expandedSize > listing.info.packedSize * 1032 {
            listing.info.expandedSize = 0
        }
        listing.info.isMultiPart = listing.info.isMultiPart || found.urls.count > 1
        return listing
    }

    private static func zipListing(_ first: URL) -> Listing? {
        guard ["zip", "zipx"].contains(first.pathExtension.lowercased()), let directory = ZipNames.read(first) else { return nil }
        var tally = Tally()
        for entry in directory.entries {
            tally.add(entry.name, folder: entry.isFolder, size: Int64(clamping: entry.size), encrypted: entry.encrypted)
        }
        tally.listing.info.isMultiPart = directory.split
        tally.listing.info.codePage = directory.codePage
        let names = directory.entries.map { $0.name.precomposedStringWithCanonicalMapping.lowercased() }
        let simple = !directory.split
            && !directory.entries.contains { $0.encrypted || ($0.method != 0 && $0.method != 8) || $0.name.contains("\\") }
            && Set(names).count == names.count
        if simple, let page = directory.codePage {
            tally.listing.route = .bsdtar(page)
        } else if simple, directory.entries.contains(where: { $0.name.hasPrefix("__MACOSX/") }) {
            tally.listing.route = .ditto
        }
        #if APPSTORE
        if tally.listing.route == .bsdtar(""), let page = directory.codePage { tally.listing.route = .bsdtar(page) }
        #endif
        return tally.listing
    }

    #if !APPSTORE
    private static func sevenZipListing(_ first: URL, password: String?, job: Job, deep: Bool) throws -> Listing {
        let tool = try sevenZip()
        let secret = credentials(password)
        let records = Records(fallback: streamExtensions.contains(streamExtension(first)) ? streamName(first) : nil)
        let messages = Messages()
        let stage = Stage(tool, ["l", "-slt", "-ba", "-sccUTF-8"] + secret.arguments + [first.path], input: secret.input)
        var statuses = try run([stage], job: job, listing: true, output: records.feed, errors: messages.add)
        records.commit()
        var listing = records.tally.listing
        var diagnosis = Diagnosis(messages.lines)
        let name = records.lastPath?.lowercased() ?? ""
        if listing.info.entries == 1, streamExtensions.contains(streamExtension(first)), name.hasSuffix(".tar") || name.hasSuffix(".cpio") {
            let inner = name.hasSuffix(".tar") ? "tar" : "cpio"
            listing.inner = inner
            if deep {
                let inside = Records()
                let more = Messages()
                let stages = [
                    Stage(tool, ["x", "-so", "-bso0", "-bsp0", "-sccUTF-8", first.path]),
                    Stage(tool, ["l", "-slt", "-ba", "-si", "-t" + inner, "-sccUTF-8"]),
                ]
                statuses = try run(stages, job: job, listing: true, output: inside.feed, errors: more.add)
                inside.commit()
                listing = inside.tally.listing
                listing.inner = inner
                diagnosis = Diagnosis(more.lines)
            }
        }
        if let missing = diagnosis.missing { throw ArchiveError.missingPart(missing) }
        if diagnosis.password { throw password == nil ? ArchiveError.needsPassword : ArchiveError.wrongPassword }
        if diagnosis.truncated || (listing.info.entries > 0 && statuses.contains(2)) { listing.info.isTruncated = true }
        if listing.info.entries == 0, !listing.info.isTruncated, statuses.contains(where: { $0 != 0 }) {
            if diagnosis.notArchive { throw ArchiveError.unsupported }
            throw ArchiveError.failed(diagnosis.other ?? "listing failed")
        }
        return listing
    }
    #endif

    #if APPSTORE
    // bsdtar prints "x name" for each file and "Enter passphrase:" for each password it asks for, and keeps asking after a wrong one
    static func toolLines(_ messages: Messages, _ prompts: Messages, tick: @escaping () -> Void) -> (String) -> Void {
        { line in
            let prompt = line.hasSuffix("passphrase:")
            if prompt { prompts.add(line) }
            if ["x ", "a ", "copying file "].contains(where: line.hasPrefix), !line.contains(": ") {
                tick()
            } else if !prompt, !line.hasPrefix("tar: Error exit delayed") {
                messages.add(line)
            }
        }
    }

    static func stopAtWrongPassword(_ prompts: Messages, password: String?, then watch: (() -> ArchiveError?)? = nil) -> () -> ArchiveError? {
        { prompts.lines.count > (password == nil ? 0 : 1) ? (password == nil ? .needsPassword : .wrongPassword) : watch?() }
    }

    final class Rows: @unchecked Sendable {
        private(set) var tally = Tally()

        func feed(_ line: String) {
            guard let mode = line.first, let date = line.range(of: #"\s\d+\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d+\s+(?:\d\d:\d\d|\d{4})\s"#, options: .regularExpression) else { return }
            var name = String(line[date.upperBound...])
            if mode == "l" || mode == "h", let cut = name.range(of: mode == "l" ? " -> " : " link to ") { name = String(name[..<cut.lowerBound]) }
            tally.add(name, folder: mode == "d", size: line[date].split(separator: " ").first.flatMap { Int64($0) } ?? 0, encrypted: false)
        }
    }

    private static func bsdtarListing(_ first: URL, password: String?, job: Job) throws -> Listing {
        let rows = Rows()
        let messages = Messages()
        let prompts = Messages()
        let stage = Stage(bsdtar, ["-t", "-v", "-f", first.path], input: credentials(password).input)
        let statuses = try run([stage], job: job, listing: true, output: rows.feed, errors: toolLines(messages, prompts) {}, watch: stopAtWrongPassword(prompts, password: password))
        var listing = rows.tally.listing
        let diagnosis = Diagnosis(tool: messages.lines)
        if diagnosis.truncated || (listing.info.entries > 0 && statuses != [0]) { listing.info.isTruncated = true }
        let empty = (try? first.resourceValues(forKeys: [.fileSizeKey]).fileSize) == 0
        if listing.info.entries == 0, statuses != [0] || empty {
            if isCutSevenZip(first) {
                listing.info.isTruncated = true
                return listing
            }
            throw diagnosis.notArchive || empty ? ArchiveError.unsupported : ArchiveError.failed(messages.lines.last ?? "listing failed")
        }
        return listing
    }

    // the 7z start header says where the file list ends: a shorter file was cut off
    private static func isCutSevenZip(_ url: URL) -> Bool {
        guard let file = try? FileHandle(forReadingFrom: url), let head = try? file.read(upToCount: 32), head.count == 32,
              head.starts(with: [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C]), let end = try? file.seekToEnd() else { return false }
        func number(_ at: Int) -> UInt64 { head[at..<(at + 8)].enumerated().reduce(0) { $0 | UInt64($1.element) << UInt64(8 * $1.offset) } }
        return end < 32 &+ number(12) &+ number(20)
    }

    // a single file squeezed by gzip or bzip2 is not a tar: bsdtar would take its text for a list of files
    private static func streamListing(_ first: URL) throws -> Listing? {
        let name = streamName(first)
        guard !name.lowercased().hasSuffix(".tar"), !name.lowercased().hasSuffix(".cpio"), let file = try? FileHandle(forReadingFrom: first), let magic = try? file.read(upToCount: 3) else { return nil }
        var size: Int64 = 0
        let tool: String
        switch streamExtension(first) {
        case "gz" where magic.starts(with: [0x1F, 0x8B]):
            tool = "/usr/bin/gzip"
            // gzip ends with the size of the original, modulo 2^32
            if let end = try? file.seekToEnd(), end > 4, (try? file.seek(toOffset: end - 4)) != nil, let tail = try? file.read(upToCount: 4), tail.count == 4 {
                size = tail.enumerated().reduce(Int64(0)) { $0 | Int64($1.element) << Int64(8 * $1.offset) }
            }
        case "bz2" where magic.starts(with: Array("BZh".utf8)):
            tool = "/usr/bin/bzip2"
        case "xz", "lzma", "zst", "z":
            throw ArchiveError.unsupported
        default:
            return nil
        }
        var tally = Tally()
        tally.add(name, folder: false, size: size, encrypted: false)
        tally.listing.route = .stream(URL(fileURLWithPath: tool))
        return tally.listing
    }
    #endif
}

#if APPSTORE
extension Archive.Diagnosis {
    init(tool messages: [String]) {
        for (original, line) in messages.map({ ($0, $0.lowercased()) }) {
            if original.hasPrefix("x "), let colon = original.range(of: ": "),
               ["bad crc", "decompression failed", "truncated", "truncating", "library error", "unknown error", "undefined error"].contains(where: line.contains) {
                bad.append(String(original[original.index(original.startIndex, offsetBy: 2)..<colon.lowerBound]))
            }
            if line.contains("incorrect passphrase") {
                password = true
            } else if ["truncated", "unexpected end of file", "ends unexpectedly"].contains(where: line.contains) {
                truncated = true
            } else if line.contains("no space left") || line.hasSuffix("write error") {
                space = true
            } else if ["unrecognized archive format", "unsupported", "not supported", "not in gzip format"].contains(where: line.contains) {
                notArchive = true
            }
        }
    }
}
#endif
