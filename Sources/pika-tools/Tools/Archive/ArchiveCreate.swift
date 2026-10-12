import Foundation

extension Archive {
    private static let skippedNames: Set<String> = [
        ".DS_Store", "__MACOSX", "Icon\r", ".Spotlight-V100", ".Trashes", ".fseventsd", ".TemporaryItems", ".localized",
    ]

    private struct Gathered {
        var listed: [String] = []
        var extras: [String] = []
        var bytes: Int64 = 0
    }

    static func create(items: [URL], name: String, format: Format, password: String? = nil, splitBytes: Int64? = nil, job: Job = Job(), progress: @escaping @Sendable (Double) -> Void = { _ in }) throws -> [URL] {
        guard let sample = items.first, Set(items.map { $0.deletingLastPathComponent().standardizedFileURL.path }).count == 1 else {
            throw ArchiveError.failed("items must share one folder")
        }
        guard !name.isEmpty, !name.contains("/"), (splitBytes ?? 65_536) >= 65_536 else { throw ArchiveError.failed("bad name or split size") }
        let secret = password.flatMap { $0.isEmpty ? nil : $0 }
        if let secret, !format.supportsPassword || secret.contains(where: \.isNewline) || (format == .zip && !secret.allSatisfy(\.isASCII)) {
            throw ArchiveError.unsupportedPassword
        }
        let (destination, temporary) = try workspace(near: sample)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let parent = sample.deletingLastPathComponent()
        var found = Gathered()
        for item in items { try gather(item.lastPathComponent, in: parent.path, into: &found, job: job) }
        guard !found.listed.isEmpty || !found.extras.isEmpty else { throw ArchiveError.failed("nothing to add") }

        var targets: [String] = []
        if !found.listed.isEmpty {
            let list = temporary.appending(path: "list.txt")
            guard FileManager.default.createFile(atPath: list.path, contents: Data(found.listed.joined(separator: "\n").utf8)) else {
                throw ArchiveError.failed("cannot write the file list")
            }
            targets.append("@" + list.path)
        }
        if !found.extras.isEmpty { targets += ["--"] + found.extras }

        let base = name + "." + format.fileExtension
        let output = temporary.appending(path: base).path
        let tool = try sevenZip()
        let common: [String] = ["-snl", "-spd", "-scsUTF-8", "-sccUTF-8", "-bso0"]
        let volumes: [String] = splitBytes.map { ["-v\($0)b"] } ?? []
        let stages: [Stage]
        switch format {
        case .zip, .sevenZip:
            var arguments: [String] = ["a"] + (format == .zip ? ["-tzip", "-mcu=on"] : ["-t7z"])
            if secret != nil { arguments += format == .zip ? ["-mem=AES256", "-p"] : ["-mhe=on", "-p"] }
            arguments += common + ["-bsp1"] + volumes
            arguments += [output] + targets
            stages = [Stage(tool, arguments, input: secret.map { Data(($0 + "\n" + $0 + "\n").utf8) }, directory: parent)]
        case .tarGz, .tarXz:
            var pack: [String] = ["a", "-ttar", "-so"] + common
            pack += ["-bsp2", temporary.appending(path: name + ".tar").path] + targets
            var compress: [String] = ["a", format == .tarGz ? "-tgzip" : "-txz", "-si", "-bso0", "-bsp0", "-sccUTF-8"]
            compress += volumes + [output]
            stages = [Stage(tool, pack, directory: parent), Stage(tool, compress)]
        }

        let meter = Meter(progress)
        let messages = Messages()
        let report: (String) -> Void = { line in
            if let value = percent(line) { meter.set(Double(value) / 100) } else { messages.add(line) }
        }
        let statuses = try run(stages, job: job, output: report, errors: report)
        let diagnosis = Diagnosis(messages.lines)
        if diagnosis.space { throw ArchiveError.noSpace(needed: found.bytes, free: freeSpace(of: destination) ?? 0) }
        guard statuses.allSatisfy({ $0 == 0 }) else { throw ArchiveError.failed(diagnosis.other ?? messages.lines.last ?? "stopped") }

        let names = (try? FileManager.default.contentsOfDirectory(atPath: temporary.path)) ?? []
        let count = splitBytes == nil ? 0 : names.filter { $0.hasPrefix(base + ".") }.count
        var suffixes = count == 0 ? [""] : (1...count).map { String(format: ".%03d", $0) }
        guard suffixes.allSatisfy({ names.contains(base + $0) }) else { throw ArchiveError.failed("nothing created") }
        if suffixes == [".001"] {
            guard try relocate(URL(fileURLWithPath: output + ".001"), to: URL(fileURLWithPath: output)) else { throw ArchiveError.failed("nothing created") }
            suffixes = [""]
        }
        let target = FileManager.default.uniqueURL(for: base, in: destination, parts: suffixes.count)
        var moved: [URL] = []
        do {
            for suffix in suffixes {
                let result = destination.appending(path: target.lastPathComponent + suffix)
                guard try relocate(temporary.appending(path: base + suffix), to: result) else { throw ArchiveError.failed("name taken") }
                moved.append(result)
            }
        } catch {
            moved.forEach { try? FileManager.default.removeItem(at: $0) }
            throw error
        }
        meter.finish()
        return moved
    }

    private static func gather(_ relative: String, in parent: String, into found: inout Gathered, job: Job) throws {
        guard !job.isCancelled else { throw ArchiveError.cancelled }
        let last = relative.split(separator: "/").last.map(String.init) ?? relative
        guard !skippedNames.contains(last), !last.hasPrefix("._") else { return }
        let path = parent + "/" + relative
        var info = stat()
        guard lstat(path, &info) == 0 else { throw ArchiveError.failed(String(cString: strerror(errno))) }
        switch info.st_mode & S_IFMT {
        case S_IFDIR:
            guard let names = try? FileManager.default.contentsOfDirectory(atPath: path) else { throw ArchiveError.failed("cannot read a folder") }
            if names.isEmpty {
                add(relative, in: parent, to: &found)
            } else {
                for name in names.sorted() { try gather(relative + "/" + name, in: parent, into: &found, job: job) }
            }
        case S_IFREG:
            found.bytes += Int64(info.st_size)
            add(relative, in: parent, to: &found)
        case S_IFLNK:
            add(relative, in: parent, to: &found)
        default:
            break
        }
    }

    private static func add(_ relative: String, in parent: String, to found: inout Gathered) {
        var stored = relative
        let composed = relative.precomposedStringWithCanonicalMapping
        // String == ignores canonical equivalence, so compare bytes; keep NFC only if it opens the very same file
        if !composed.utf8.elementsEqual(relative.utf8), sameFile(parent + "/" + composed, parent + "/" + relative) { stored = composed }
        if stored.contains(where: \.isNewline) || stored.first?.isWhitespace == true || stored.last?.isWhitespace == true {
            found.extras.append(stored)
        } else {
            found.listed.append(stored)
        }
    }

    private static func sameFile(_ first: String, _ second: String) -> Bool {
        var one = stat()
        var two = stat()
        return lstat(first, &one) == 0 && lstat(second, &two) == 0 && one.st_dev == two.st_dev && one.st_ino == two.st_ino
    }
}
