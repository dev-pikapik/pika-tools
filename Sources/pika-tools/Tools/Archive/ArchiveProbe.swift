import Foundation

extension Archive {
    enum Route: Equatable {
        case sevenZip, ditto
        case bsdtar(String)
    }

    struct Listing {
        var info = Info()
        var files = 0
        var inner: String?
        var route = Route.sevenZip
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
            guard !isJunk(path: path) else { return }
            listing.info.entries += 1
            listing.files += folder ? 0 : 1
            listing.info.expandedSize += size
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
            case "Size": size = Int64(value) ?? 0
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
        var listing: Listing
        if let zip = zipListing(first) {
            listing = zip
        } else {
            listing = try sevenZipListing(first, password: password, job: job, deep: deep)
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
        return tally.listing
    }

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
}
