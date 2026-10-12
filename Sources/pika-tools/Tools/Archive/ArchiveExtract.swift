import Foundation

extension Archive {
    private static let hugeSize: Int64 = 1 << 30
    private static let hugeRatio: Int64 = 1000

    static func extract(_ url: URL, password: String? = nil, allowPartial: Bool = false, allowHuge: Bool = false, job: Job = Job(), progress: @escaping @Sendable (Double) -> Void = { _ in }) throws -> URL {
        let secret = try checked(password)
        let listing = try inspect(url, password: secret, job: job, deep: false)
        let info = listing.info
        let first = firstPart(url)
        if info.isEncrypted, secret == nil { throw ArchiveError.needsPassword }
        if info.isTruncated, !allowPartial { throw ArchiveError.truncated }
        if !allowHuge, isHuge(expanded: info.expandedSize, packed: info.packedSize) {
            throw ArchiveError.huge(expanded: info.expandedSize, packed: info.packedSize)
        }
        let (destination, temporary) = try workspace(near: first)
        defer {
            clear(temporary)
            try? FileManager.default.removeItem(at: temporary)
        }
        try checkSpace(info.expandedSize, in: destination)
        let meter = Meter(progress)
        let diagnosis = try unpack(first, listing: listing, password: secret, into: temporary, job: job, meter: meter)
        if diagnosis.password { throw secret == nil ? ArchiveError.needsPassword : ArchiveError.wrongPassword }
        if let missing = diagnosis.missing { throw ArchiveError.missingPart(missing) }
        if diagnosis.space { throw ArchiveError.noSpace(needed: info.expandedSize, free: freeSpace(of: destination) ?? 0) }
        if diagnosis.truncated, !allowPartial { throw ArchiveError.truncated }
        let unwanted = diagnosis.bad + diagnosis.ignored
        if !unwanted.isEmpty { unlock(temporary.path) }
        for path in unwanted { discard(path, in: temporary) }
        let value = parts(of: first).urls.lazy.compactMap(quarantine).first
        let kept = try sanitize(temporary, marking: value)
        guard kept.items > 0 else {
            throw diagnosis.notArchive && !diagnosis.truncated ? ArchiveError.unsupported : ArchiveError.failed(diagnosis.other ?? "nothing extracted")
        }
        let result = try place(temporary, archive: first, in: destination, marking: value)
        meter.finish()
        if info.isTruncated || diagnosis.truncated || !diagnosis.bad.isEmpty || diagnosis.other != nil {
            throw ArchiveError.damaged(extracted: kept.files, total: max(listing.files, kept.files + max(diagnosis.bad.count, 1)), result: result)
        }
        return result
    }

    static func isHuge(expanded: Int64, packed: Int64) -> Bool {
        expanded > hugeSize && expanded / max(packed, 1) > hugeRatio
    }

    static func freeSpace(of folder: URL) -> Int64? {
        guard let values = try? folder.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeAvailableCapacityForImportantUsageKey]) else { return nil }
        // the important-usage figure adds purgeable space on APFS but reads 0 on HFS+, FAT and exFAT volumes
        return max(values.volumeAvailableCapacityForImportantUsage ?? 0, Int64(values.volumeAvailableCapacity ?? 0))
    }

    static func checkSpace(_ needed: Int64, in folder: URL) throws {
        guard let free = freeSpace(of: folder), needed > free else { return }
        throw ArchiveError.noSpace(needed: needed, free: free)
    }

    static func workspace(near url: URL) throws -> (destination: URL, temporary: URL) {
        let manager = FileManager.default
        let beside = url.deletingLastPathComponent()
        let folders = (manager.isWritableFile(atPath: beside.path) ? [beside] : []) + manager.urls(for: .downloadsDirectory, in: .userDomainMask)
        for folder in folders {
            if let temporary = try? manager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: folder, create: true) {
                return (folder, temporary)
            }
        }
        throw ArchiveError.failed("no writable folder")
    }

    static func clear(_ folder: URL) {
        _ = try? sanitize(folder, marking: nil)
        for name in (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? [] {
            try? FileManager.default.removeItem(atPath: folder.path + "/" + name)
        }
    }

    private static func unpack(_ first: URL, listing: Listing, password: String?, into root: URL, job: Job, meter: Meter) throws -> Diagnosis {
        let files = listing.files
        let native: Stage? = switch listing.route {
        case .sevenZip: nil
        case .ditto: Stage(ditto, ["-x", "-k", "-V", "--noqtn", "--noacl", first.path, root.path])
        case .bsdtar(let page): Stage(bsdtar, ["-x", "-v", "-f", first.path, "-C", root.path, "--options", "zip:hdrcharset=" + page, "--no-mac-metadata", "--no-same-owner", "--no-same-permissions"])
        }
        if let native {
            let statuses = try run([native], job: job, errors: { line in
                if line.hasPrefix("copying file ") || line.hasPrefix("x ") { meter.tick(of: files) }
            })
            if statuses == [0] { return Diagnosis([]) }
            clear(root)
        }
        let tool = try sevenZip()
        let secret = credentials(password)
        let messages = Messages()
        let report: (String) -> Void = { line in
            if let value = percent(line) { meter.set(Double(value) / 100) } else { messages.add(line) }
        }
        let stages: [Stage]
        if let inner = listing.inner {
            stages = [
                Stage(tool, ["x", "-so", "-bso0", "-bsp2", "-sccUTF-8", first.path]),
                Stage(tool, ["x", "-si", "-t" + inner, "-aou", "-bso0", "-bsp0", "-sccUTF-8", "-o" + root.path]),
            ]
        } else {
            stages = [Stage(tool, ["x", "-aou", "-bso0", "-bsp1", "-sccUTF-8", "-o" + root.path] + secret.arguments + [first.path], input: secret.input)]
        }
        let statuses = try run(stages, job: job, output: report, errors: report)
        var diagnosis = Diagnosis(messages.lines, stream: listing.inner != nil || streamExtensions.contains(streamExtension(first)))
        if listing.inner != nil { diagnosis.bad.removeAll { listing.info.names.contains($0) } }
        if statuses.contains(where: { $0 > 2 }) { diagnosis.other = diagnosis.other ?? "stopped" }
        return diagnosis
    }

    private static func place(_ root: URL, archive: URL, in destination: URL, marking value: Data?) throws -> URL {
        let names = ((try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []).sorted()
        if names.count == 1 { return try move(root.appending(path: names[0]), into: destination) }
        let folder = try makeFolder(named: baseName(archive), in: destination)
        do {
            if let value { try mark(folder.path, with: value) }
            for name in names { _ = try move(root.appending(path: name), into: folder) }
        } catch {
            try? FileManager.default.removeItem(at: folder)
            throw error
        }
        return folder
    }

    private static func makeFolder(named name: String, in folder: URL) throws -> URL {
        var number = 1
        while number < 10_000 {
            let target = folder.appending(path: number == 1 ? name : "\(name) \(number)")
            if mkdir(target.path, 0o755) == 0 { return target }
            guard errno == EEXIST else { throw ArchiveError.failed(String(cString: strerror(errno))) }
            number += 1
        }
        throw ArchiveError.failed("no free name")
    }

    private static func move(_ source: URL, into folder: URL) throws -> URL {
        var info = stat()
        let directory = lstat(source.path, &info) == 0 && info.st_mode & S_IFMT == S_IFDIR
        for _ in 0..<10_000 {
            let target = FileManager.default.uniqueURL(for: source.lastPathComponent, in: folder, directory: directory)
            if try relocate(source, to: target) { return target }
        }
        throw ArchiveError.failed("no free name")
    }

    static func relocate(_ source: URL, to target: URL) throws -> Bool {
        if renamex_np(source.path, target.path, UInt32(RENAME_EXCL)) == 0 { return true }
        if errno == EEXIST { return false }
        guard errno == ENOTSUP || errno == EXDEV else { throw ArchiveError.failed(String(cString: strerror(errno))) }
        do {
            try FileManager.default.moveItem(at: source, to: target)
            return true
        } catch let error as CocoaError where error.code == .fileWriteFileExists {
            return false
        } catch {
            throw ArchiveError.failed(error.localizedDescription)
        }
    }
}
