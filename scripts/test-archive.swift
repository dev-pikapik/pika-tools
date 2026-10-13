import Foundation

final class Recorder: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [Double] = []

    var values: [Double] { lock.withLock { stored } }

    func add(_ value: Double) {
        lock.withLock { stored.append(value) }
    }
}

extension Data {
    mutating func put16(_ value: Int) {
        append(UInt8(value & 255))
        append(UInt8((value >> 8) & 255))
    }

    mutating func put32(_ value: UInt32) {
        for shift in stride(from: 0, to: 32, by: 8) { append(UInt8((value >> UInt32(shift)) & 255)) }
    }
}

@main
enum TestArchive {
    static let manager = FileManager.default
    static let root = manager.temporaryDirectory.appendingPathComponent("test-archive-\(UUID().uuidString)")
    static let quarantineKey = "com.apple.quarantine"

    static func main() {
        setvbuf(stdout, nil, _IOLBF, 0)
        useBundledTool()
        try! manager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: root) }
        let leftovers = ownItems()
        naming()
        limits()
        space()
        sanitizing()
        composition()
        oddNames()
        links()
        passwords()
        splitting()
        placing()
        damage()
        hostile()
        traversal()
        streams()
        finderZip()
        legacyNames()
        zipReader()
        watching()
        placedLinks()
        appleDouble()
        cancelling()
        rar()
        let left = ownItems().subtracting(leftovers)
        precondition(left.isEmpty, "temporary folders left behind: \(left.sorted())")
        print("archive: all ok")
    }

    static func useBundledTool() {
        guard ProcessInfo.processInfo.environment["PIKA_7ZZ"] == nil else { return }
        let bundled = manager.currentDirectoryPath + "/Vendor/7zip/7zz"
        precondition(manager.isExecutableFile(atPath: bundled), "run scripts/fetch-7zip.sh first, or set PIKA_7ZZ")
        setenv("PIKA_7ZZ", bundled, 1)
    }

    static func naming() {
        func url(_ name: String) -> URL { URL(fileURLWithPath: "/tmp/x/" + name) }
        for name in ["a.zip", "A.ZIP", "a.7z", "a.rar", "a.tar.gz", "a.tgz", "a.gz", "a.xz", "a.zip.001", "a.7z.003", "a.part2.rar", "a.r05", "a.z03", "a.001"] {
            precondition(Archive.isArchive(url(name)), name)
        }
        for name in ["a.txt", "a", "a.002", "a.docx", "a.pages", "photo.jpg"] {
            precondition(!Archive.isArchive(url(name)), name)
        }
        precondition(Archive.firstPart(url("a.zip.003")) == url("a.zip.001"))
        precondition(Archive.firstPart(url("a.part3.rar")) == url("a.part1.rar"))
        precondition(Archive.firstPart(url("a.r05")) == url("a.rar"))
        precondition(Archive.firstPart(url("a.z03")) == url("a.zip"))
        precondition(Archive.firstPart(url("a.7z")) == url("a.7z"))
        let selection = [url("a.zip.001"), url("a.zip.002"), url("a.zip.003"), url("b.zip"), url("a.zip.002")]
        precondition(Archive.distinct(selection) == [url("a.zip.001"), url("b.zip")])
        precondition(Archive.baseName(url("Photos.tar.gz")) == "Photos")
        precondition(Archive.baseName(url("Photos.zip.003")) == "Photos")
        precondition(Archive.baseName(url("Photos.part2.rar")) == "Photos")
        precondition(Archive.baseName(url("Photos.7z")) == "Photos")
        print("naming ok")
    }

    static func limits() {
        precondition(Archive.isHuge(expanded: 3 << 30, packed: 1 << 20))
        precondition(!Archive.isHuge(expanded: 3 << 30, packed: 1 << 30))
        precondition(!Archive.isHuge(expanded: 900 << 20, packed: 1 << 10))
        precondition(!Archive.isHuge(expanded: 0, packed: 0))
        precondition(Archive.freeSpace(of: root) != nil)
        try! Archive.checkSpace(1, in: root)
        let error = failure { try Archive.checkSpace(Int64.max, in: root) }
        guard case .noSpace(let needed, let free)? = error else { preconditionFailure("checkSpace gave \(String(describing: error))") }
        precondition(needed == Int64.max && free > 0)
        var lying = rawZip([(name: Array("big.bin".utf8), data: Array("x".utf8))])
        let central = lying.range(of: Data([0x50, 0x4B, 0x01, 0x02]))!.lowerBound
        lying.replaceSubrange((central + 24)..<(central + 28), with: Data([0x00, 0x5E, 0xD0, 0xB2]))
        let big = path(fresh("huge"), "big.zip")
        try! lying.write(to: big)
        expect(.huge(expanded: 3_000_000_000, packed: Int64(lying.count)), "zip claiming 3 GB from a few bytes") { _ = try Archive.extract(big) }
        precondition(!Archive.exceeds(1 << 30, expanded: 0) && Archive.exceeds((1 << 30) + 1, expanded: 0))
        precondition(!Archive.exceeds(3 << 30, expanded: 2 << 30) && Archive.exceeds((4 << 30) + 1, expanded: 2 << 30))
        precondition(!Archive.exceeds(.max, expanded: .max) && Archive.exceeds(.max, expanded: 1))
        let roomy: Int64 = 1 << 40
        precondition(Archive.overrun(written: 1 << 20, expanded: 1 << 20, packed: 1, free: roomy, allowHuge: false) == nil)
        precondition(Archive.overrun(written: 2 << 30, expanded: 10, packed: 5, free: roomy, allowHuge: false) == .huge(expanded: 2 << 30, packed: 5))
        precondition(Archive.overrun(written: 2 << 30, expanded: 10, packed: 5, free: roomy, allowHuge: true) == nil)
        precondition(Archive.overrun(written: 1 << 20, expanded: 8 << 20, packed: 5, free: Archive.reserve - 1, allowHuge: true) == .noSpace(needed: 8 << 20, free: Archive.reserve - 1))
        precondition(Archive.overrun(written: 8 << 20, expanded: 10, packed: 5, free: 0, allowHuge: false) == .noSpace(needed: 0, free: 0))
        precondition(Archive.overrun(written: 0, expanded: 0, packed: 0, free: Archive.reserve, allowHuge: false) == nil)
        print("limits ok")
    }

    static func space() {
        let work = fresh("space")
        let zeros = put(work, "zeros.bin", Data(count: 48 << 20))
        let notes = put(work, "notes.bin", random(100_000))
        let big = try! Archive.create(items: [zeros], name: "big", format: .zip)[0]
        let small = try! Archive.create(items: [notes], name: "small", format: .zip)[0]
        precondition(tool("/usr/bin/bzip2", ["-k", zeros.path]) == 0)
        guard let volume = disk("16m") else {
            print("space skipped (no disk image could be attached)")
            return
        }
        let stored = [big, small, work.appendingPathComponent("zeros.bin.bz2")].map { move([$0], into: volume)[0] }
        var lying = try! Data(contentsOf: stored[0])
        let central = lying.range(of: Data([0x50, 0x4B, 0x01, 0x02]), options: .backwards)!.lowerBound
        lying.replaceSubrange((central + 24)..<(central + 28), with: Data([10, 0, 0, 0]))
        try! lying.write(to: path(volume, "lying.zip"))

        var opened: URL?
        let fits = failure { opened = try Archive.extract(stored[1]) }
        if let opened { try? manager.removeItem(at: opened) }
        let before = Archive.freeSpace(of: volume) ?? 0
        let known = failure { _ = try Archive.extract(stored[0]) }
        let unknown = failure { _ = try Archive.extract(stored[2]) }
        let lied = failure { _ = try Archive.extract(path(volume, "lying.zip")) }
        let room = Archive.freeSpace(of: volume) ?? 0
        let snug = failure { try Archive.checkSpace(room - Archive.reserve - (64 << 10), in: volume) }
        let tight = failure { try Archive.checkSpace(room - Archive.reserve + (64 << 10), in: volume) }
        let filler = volume.appendingPathComponent("filler")
        try? manager.createDirectory(at: filler, withIntermediateDirectories: true)
        try? random(9 << 20).write(to: filler.appendingPathComponent("data.bin"))
        let full = failure { _ = try Archive.create(items: [filler], name: "Full", format: .zip) }
        try? manager.removeItem(at: filler)
        let after = Archive.freeSpace(of: volume) ?? 0
        let names = ((try? manager.contentsOfDirectory(atPath: volume.path)) ?? []).filter { !$0.hasPrefix(".") }.sorted()
        tool("/usr/bin/hdiutil", ["detach", "-force", volume.path])

        precondition(fits == nil && opened != nil, "a small archive on a small volume: \(String(describing: fits))")
        guard case .noSpace(let needed, let free)? = known else { preconditionFailure("known size: \(String(describing: known))") }
        precondition(needed == 48 << 20 && free > 0 && free < 16 << 20, "known size: \(needed) \(free)")
        guard case .noSpace(0, let left)? = unknown else { preconditionFailure("unknown size: \(String(describing: unknown))") }
        precondition(before - left < 256 << 10, "unknown size: \(left) free, \(before) before")
        guard case .noSpace(let wanted, _)? = full else { preconditionFailure("create: \(String(describing: full))") }
        precondition(wanted == 9 << 20)
        guard case .noSpace(0, _)? = lied else { preconditionFailure("a zip that claims 10 bytes: \(String(describing: lied))") }
        precondition(snug == nil, "the reserve was counted twice: \(String(describing: snug))")
        guard case .noSpace? = tight else { preconditionFailure("no reserve was kept: \(String(describing: tight))") }
        precondition(names == ["big.zip", "lying.zip", "small.zip", "zeros.bin.bz2"], "left on the volume: \(names)")
        precondition(before - after < 256 << 10, "the failed runs kept \(before - after) bytes")
        print("space ok")
    }

    static func sanitizing() {
        let folder = fresh("sanitize")
        let box = path(folder, "box")
        let outside = put(folder, "outside.txt")
        let script = put(box, "run.sh")
        chmod(script.path, 0o6755)
        chmod(put(box, "silent.txt").path, 0o000)
        put(box, "sticky/x.txt")
        chmod(path(box, "sticky").path, 0o1777)
        put(box, "locked/inner/y.txt")
        chmod(path(box, "locked/inner").path, 0o000)
        chmod(path(box, "locked").path, 0o000)
        link(box, "inside", "run.sh")
        link(box, "outwards", "../outside.txt")
        link(box, "absolute", "/etc/hosts")
        link(box, "sideways", "locked/../../outside.txt")
        link(box, "dirlink", "sticky")
        precondition(mkfifo(path(box, "pipe").path, 0o644) == 0)
        for junk in [".DS_Store", "._run.sh", "sticky/.DS_Store", "__MACOSX/inner/note", "__MACOSX/._x"] { put(box, junk) }
        chmod(path(box, "__MACOSX/inner").path, 0o000)
        chmod(path(box, "__MACOSX").path, 0o000)
        let value = Data("0083;5f3e1c2a;Safari;".utf8)
        let kept = try! Archive.sanitize(box, marking: value)
        precondition(tree(box) == ["dirlink -> sticky", "inside -> run.sh", "locked/", "locked/inner/", "locked/inner/y.txt", "run.sh", "silent.txt", "sticky/", "sticky/x.txt"], "\(tree(box))")
        precondition(kept.files == 6 && kept.items == 9, "\(kept)")
        for item in all(box.path) where item != box.path {
            var info = stat()
            precondition(lstat(item, &info) == 0)
            precondition(info.st_mode & 0o7000 == 0, "special bits left on \(item)")
            let mask: mode_t = info.st_mode & S_IFMT == S_IFLNK ? 0 : (info.st_mode & S_IFMT == S_IFDIR ? 0o700 : 0o600)
            precondition(info.st_mode & mask == mask, "owner cannot use \(item)")
            precondition(quarantine(item) == "0083;5f3e1c2a;Safari;", "no quarantine on \(item)")
        }
        precondition(manager.fileExists(atPath: outside.path))
        precondition(quarantine(outside.path) == nil)
        Archive.clear(box)
        precondition(tree(box).isEmpty)
        let pinned = put(folder, "pinned.txt")
        chflags(pinned.path, UInt32(UF_IMMUTABLE))
        expect(.failed("cannot mark pinned.txt"), "quarantine on a file that refuses it") { try Archive.mark(pinned.path, with: value) }
        chflags(pinned.path, 0)
        print("sanitize ok")
    }

    static func composition() {
        let folder = fresh("composition")
        let nfd = "Cafe\u{301}"
        let item = path(folder, nfd)
        put(item, "re\u{301}sume\u{301}.txt")
        put(item, "dossier/\u{1112}\u{1161}\u{11AB}.txt")
        for junk in [".DS_Store", "._x", "__MACOSX/y", "dossier/.DS_Store", "dossier/Icon\r", ".Spotlight-V100/z", ".localized"] { put(item, junk) }
        put(item, "onlyjunk/.DS_Store")
        let recorder = Recorder()
        let made = try! Archive.create(items: [item], name: "Out", format: .zip, progress: { recorder.add($0) })
        precondition(recorder.values.last == 1 && recorder.values == recorder.values.sorted(), "\(recorder.values)")
        precondition(made.map(\.lastPathComponent) == ["Out.zip"])
        let entries = zipEntries(made[0])
        precondition(entries.count == 2, "\(entries.map(\.name))")
        for entry in entries {
            precondition(isComposed(entry.name), "not NFC: \(entry.name)")
            precondition(entry.flags & 0x800 != 0, "no UTF-8 flag on \(entry.name)")
        }
        precondition(Set(entries.map(\.name)) == ["Caf\u{E9}/r\u{E9}sum\u{E9}.txt", "Caf\u{E9}/dossier/\u{D55C}.txt"], "\(entries.map(\.name))")
        let result = try! Archive.extract(made[0])
        precondition(result.lastPathComponent == "Caf\u{E9} 2", "\(result.lastPathComponent)")
        for name in manager.enumerator(atPath: result.path)!.allObjects as! [String] { precondition(isComposed(name), "not NFC: \(name)") }
        print("composition ok")
    }

    static func oddNames() {
        let folder = fresh("odd")
        let box = path(folder, "box")
        for name in [" lead.txt", "trail.txt ", "cr\rname.txt", "-dash.txt", "@at.txt", "star*.txt", "q?.txt", "[b].txt", "#h.txt", ";s.txt", "two  spaces.txt", "sub dir /in side.txt", "emoji \u{1F600}.txt"] { put(box, name) }
        put(box, "Icon\r")
        put(box, "sub dir /.localized")
        put(box, "empty/")
        let expected = tree(box).filter { $0 != "Icon\r" && !$0.hasSuffix(".localized") }
        for format in Archive.Format.allCases {
            let made = try! Archive.create(items: [box], name: "odd", format: format)
            let out = fresh("odd-out")
            let result = try! Archive.extract(move(made, into: out)[0])
            precondition(tree(result) == expected, "\(format): \(tree(result))")
        }
        print("odd names ok")
    }

    static func links() {
        let folder = fresh("links")
        let box = path(folder, "box")
        put(folder, "secret.bin", random(5_000_000))
        put(box, "a.txt")
        put(box, "sub/b.txt")
        link(box, "link", "a.txt")
        link(box, "dirlink", "sub")
        link(box, "escape", "../secret.bin")
        link(box, "absolute", "/etc/hosts")
        for format in [Archive.Format.zip, .sevenZip, .tarGz, .tarXz] {
            let made = try! Archive.create(items: [box], name: "links", format: format)
            let info = try! Archive.probe(made[0])
            precondition(info.expandedSize < 10_000, "\(format) followed a link: \(info.expandedSize)")
            let out = fresh("links-out")
            let result = try! Archive.extract(move(made, into: out)[0])
            precondition(tree(result) == ["a.txt", "dirlink -> sub", "link -> a.txt", "sub/", "sub/b.txt"], "\(format): \(tree(result))")
        }
        print("links ok")
    }

    static func passwords() {
        let folder = fresh("passwords")
        let box = path(folder, "box")
        put(box, "a.txt", Data("hello".utf8))
        let zip = try! Archive.create(items: [box], name: "Locked", format: .zip, password: "s3cret")[0]
        precondition(try! Archive.probe(zip).isEncrypted)
        expect(.needsPassword, "zip without a password") { _ = try Archive.extract(zip) }
        expect(.wrongPassword, "zip with a wrong password") { _ = try Archive.extract(zip, password: "nope") }
        let opened = try! Archive.extract(zip, password: "s3cret")
        precondition(try! Data(contentsOf: path(opened, "a.txt")) == Data("hello".utf8))
        let hidden = try! Archive.create(items: [box], name: "Hidden", format: .sevenZip, password: "p\u{E4}ss w\u{F6}rd")[0]
        expect(.needsPassword, "7z headers without a password") { _ = try Archive.probe(hidden) }
        expect(.wrongPassword, "7z headers with a wrong password") { _ = try Archive.probe(hidden, password: "nope") }
        expect(.needsPassword, "7z extract without a password") { _ = try Archive.extract(hidden) }
        precondition(try! Archive.probe(hidden, password: "p\u{E4}ss w\u{F6}rd").names == ["box"])
        let unlocked = try! Archive.extract(hidden, password: "p\u{E4}ss w\u{F6}rd")
        precondition(tree(unlocked) == ["a.txt"])
        expect(.unsupportedPassword, "tar with a password") { _ = try Archive.create(items: [box], name: "x", format: .tarGz, password: "p") }
        expect(.unsupportedPassword, "zip with a non-ASCII password") { _ = try Archive.create(items: [box], name: "x", format: .zip, password: "p\u{E4}ss") }
        expect(.unsupportedPassword, "password with a line break") { _ = try Archive.create(items: [box], name: "x", format: .sevenZip, password: "a\nb") }
        let plain = try! Archive.create(items: [box], name: "Plain", format: .zip, password: "")[0]
        precondition(!(try! Archive.probe(plain).isEncrypted))
        precondition(!manager.fileExists(atPath: path(folder, "x.zip").path) && !manager.fileExists(atPath: path(folder, "x.7z").path))
        print("passwords ok")
    }

    static func splitting() {
        let folder = fresh("split")
        let box = path(folder, "box")
        let a = random(150_000)
        let b = random(150_000)
        put(box, "a.bin", a)
        put(box, "b.bin", b)
        for format in [Archive.Format.zip, .sevenZip, .tarGz] {
            let parts = try! Archive.create(items: [box], name: "S", format: format, splitBytes: 100_000)
            precondition(parts.count >= 3, "\(format): \(parts.count) parts")
            precondition(parts.map(\.lastPathComponent) == (1...parts.count).map { "S.\(format.fileExtension)" + String(format: ".%03d", $0) })
            precondition(Archive.firstPart(parts[parts.count - 1]) == parts[0] && Archive.distinct(parts) == [parts[0]])
            precondition(parts.allSatisfy(Archive.isArchive))
            precondition(try! Archive.probe(parts[1]).isMultiPart)
            let out = fresh("split-out")
            let moved = move(parts, into: out)
            let result = try! Archive.extract(moved[2])
            precondition(tree(result) == ["a.bin", "b.bin"] && (try! Data(contentsOf: path(result, "b.bin"))) == b, "\(format): \(tree(result))")
            if format == .zip {
                try! manager.removeItem(at: moved[1])
                expect(.missingPart("S.zip.002"), "gap in a split set") { _ = try Archive.extract(moved[0]) }
                expect(.missingPart("S.zip.002"), "gap seen from the last part") { _ = try Archive.probe(moved[2]) }
            }
        }
        let single = try! Archive.create(items: [box], name: "One", format: .zip, splitBytes: 100_000_000)
        precondition(single.map(\.lastPathComponent) == ["One.zip"], "\(single)")
        let again = try! Archive.create(items: [box], name: "One", format: .zip, splitBytes: 100_000)
        precondition(again.map(\.lastPathComponent).first == "One 2.zip.001", "\(again)")
        precondition(try! Archive.create(items: [box], name: "S", format: .zip).map(\.lastPathComponent) == ["S.zip"])
        let beside = try! Archive.create(items: [box], name: "S", format: .zip, splitBytes: 100_000)
        precondition(beside.map(\.lastPathComponent).first == "S 2.zip.001", "\(beside)")
        let next = try! Archive.create(items: [box], name: "S", format: .zip)
        precondition(next.map(\.lastPathComponent) == ["S 3.zip"], "a plain name must not sit next to a part set: \(next)")
        precondition(failure { _ = try Archive.create(items: [box], name: "bad/name", format: .zip) } == .failed("bad name or split size"))
        for tiny: Int64 in [1, 1_024, 65_535] {
            precondition(failure { _ = try Archive.create(items: [box], name: "Tiny", format: .zip, splitBytes: tiny) } == .failed("bad name or split size"), "\(tiny)-byte parts")
        }
        precondition(try! Archive.create(items: [box], name: "Least", format: .zip, splitBytes: 65_536).count >= 4)
        let neighbours = fresh("split-neighbours")
        for name in ["a.zip.00000000001", "a.zip.00000000002", "a.zip.99999999999", "c.rar", "c.r-1"] { put(neighbours, name) }
        let begun = Date()
        let gap = Archive.parts(of: path(neighbours, "a.zip.00000000001"))
        precondition(gap.missing == "a.zip.00000000003" && gap.urls.count == 2 && Date().timeIntervalSince(begun) < 1, "\(String(describing: gap.missing)) after \(Date().timeIntervalSince(begun)) s")
        precondition(Archive.parts(of: path(neighbours, "c.rar")).missing == nil)
        print("split ok")
    }

    static func placing() {
        let source = fresh("placing-source")
        put(source, "Solo/a.txt")
        put(source, "Many/a.txt")
        put(source, "Many/b.txt")
        let solo = try! Archive.create(items: [path(source, "Solo")], name: "Solo", format: .zip)
        let many = try! Archive.create(items: [path(source, "Many/a.txt"), path(source, "Many/b.txt")], name: "Many", format: .zip)
        let folder = fresh("placing")
        let soloZip = move(solo, into: folder)[0]
        let manyZip = move(many, into: folder)[0]
        let original = try! Data(contentsOf: soloZip)
        let recorder = Recorder()
        let first = try! Archive.extract(soloZip, progress: { recorder.add($0) })
        precondition(same(first, path(folder, "Solo")) && tree(first) == ["a.txt"])
        let values = recorder.values
        precondition(values.last == 1 && values == values.sorted() && values.allSatisfy { $0 >= 0 && $0 <= 1 }, "\(values)")
        precondition(same(try! Archive.extract(soloZip), path(folder, "Solo 2")))
        link(folder, "Solo 3", "nowhere")
        precondition(same(try! Archive.extract(soloZip), path(folder, "Solo 4")) && (try? manager.destinationOfSymbolicLink(atPath: path(folder, "Solo 3").path)) == "nowhere", "a dangling link was taken for a free name")
        let folded = try! Archive.extract(manyZip)
        precondition(same(folded, path(folder, "Many")) && tree(folded) == ["a.txt", "b.txt"])
        precondition(same(try! Archive.extract(manyZip), path(folder, "Many 2")))
        precondition(try! Data(contentsOf: soloZip) == original, "the archive was changed")
        let one = put(source, "race/one.txt", Data("one".utf8))
        let two = put(source, "race/two.txt", Data("two".utf8))
        precondition(try! Archive.relocate(one, to: two) == false && (try! Data(contentsOf: two)) == Data("two".utf8) && manager.fileExists(atPath: one.path), "a move replaced an existing file")
        precondition(try! Archive.relocate(put(source, "race/dirA/"), to: put(source, "race/dirB/")) == false, "a move replaced an existing folder")
        precondition(try! Archive.relocate(one, to: path(source, "race/three.txt")) && !manager.fileExists(atPath: one.path))

        let marked = fresh("quarantine")
        let flagged = move([soloZip], into: marked)[0]
        let value = "0083;5f3e1c2a;Safari;"
        precondition(setxattr(flagged.path, quarantineKey, Array(value.utf8), value.utf8.count, 0, 0) == 0)
        let result = try! Archive.extract(flagged)
        for item in all(result.path) { precondition(quarantine(item) == value, "no quarantine on \(item)") }
        let clean = try! Archive.extract(move([manyZip], into: fresh("clean"))[0])
        for item in all(clean.path) { precondition(quarantine(item) == nil, "unexpected quarantine on \(item)") }
        let both = move(try! Archive.create(items: [path(source, "Many/a.txt"), path(source, "Many/b.txt")], name: "Both", format: .sevenZip), into: marked)[0]
        precondition(setxattr(both.path, quarantineKey, Array(value.utf8), value.utf8.count, 0, 0) == 0)
        for item in all(try! Archive.extract(both).path) { precondition(quarantine(item) == value, "no quarantine on \(item)") }
        print("placing ok")
    }

    static func damage() {
        let folder = fresh("damage")
        let box = path(folder, "box")
        for number in 1...5 { put(box, "f\(number).bin", random(40_000)) }
        let zip = move(try! Archive.create(items: [box], name: "Cut", format: .zip), into: fresh("cut"))[0]
        let size = Int(try! zip.resourceValues(forKeys: [.fileSizeKey]).fileSize!)
        precondition(truncate(zip.path, off_t(size * 55 / 100)) == 0)
        precondition(try! Archive.probe(zip).isTruncated)
        expect(.truncated, "cut zip") { _ = try Archive.extract(zip) }
        let partial = broken("cut zip with allowPartial") { _ = try Archive.extract(zip, allowPartial: true) }
        precondition(partial.extracted >= 1 && partial.total > partial.extracted, "\(partial)")
        let names = tree(partial.result)
        precondition(names.count == partial.extracted && names.allSatisfy { $0.hasPrefix("f") }, "\(names)")
        for name in names { precondition(try! Data(contentsOf: path(partial.result, name)) == Data(contentsOf: path(box, name)), "\(name) is not whole") }

        let small = path(folder, "small")
        for number in 1...3 { put(small, "g\(number).bin", random(20_000)) }
        let zipped = move(try! Archive.create(items: [small], name: "Bad", format: .zip), into: fresh("bad"))[0]
        var bytes = try! Data(contentsOf: zipped)
        bytes[bytes.count / 2] ^= 0xFF
        try! bytes.write(to: zipped)
        let flawed = broken("zip with a flipped byte") { _ = try Archive.extract(zipped) }
        precondition(flawed.extracted == 2 && flawed.total == 3, "\(flawed)")
        precondition(tree(flawed.result).count == 2)

        let big = path(folder, "gz")
        for number in 1...4 { put(big, "h\(number).bin", random(100_000)) }
        let gz = move(try! Archive.create(items: [big], name: "Cut", format: .tarGz), into: fresh("cutgz"))[0]
        precondition(truncate(gz.path, off_t(Int(try! gz.resourceValues(forKeys: [.fileSizeKey]).fileSize!) * 60 / 100)) == 0)
        precondition(try! Archive.probe(gz).isTruncated)
        expect(.truncated, "cut tar.gz") { _ = try Archive.extract(gz) }
        let some = broken("cut tar.gz with allowPartial") { _ = try Archive.extract(gz, allowPartial: true) }
        precondition(some.extracted >= 1 && some.extracted < 4, "\(some)")

        let sevenZip = move(try! Archive.create(items: [box], name: "Cut", format: .sevenZip), into: fresh("cut7z"))[0]
        precondition(truncate(sevenZip.path, off_t(Int(try! sevenZip.resourceValues(forKeys: [.fileSizeKey]).fileSize!) * 70 / 100)) == 0)
        expect(.truncated, "cut 7z") { _ = try Archive.extract(sevenZip) }

        let garbage = path(fresh("garbage"), "nothing.zip")
        try! random(500).write(to: garbage)
        expect(.unsupported, "random bytes named .zip") { _ = try Archive.probe(garbage) }
        let empty = path(fresh("empty"), "nothing.7z")
        try! Data().write(to: empty)
        expect(.unsupported, "empty .7z") { _ = try Archive.probe(empty) }
        print("damage ok")
    }

    static func hostile() {
        let source = fresh("hostile-source")
        let script = put(source, "run.sh")
        chmod(script.path, 0o6755)
        put(source, "dir/x.txt")
        chmod(path(source, "dir").path, 0o1777)
        let program = put(source, "group.sh")
        chmod(program.path, 0o2755)
        let out = fresh("hostile")
        precondition(tool("/usr/bin/tar", ["-cf", path(out, "suid.tar").path, "-C", source.path, "run.sh", "group.sh", "dir"]) == 0)
        let result = try! Archive.extract(path(out, "suid.tar"))
        precondition(Set(tree(result)) == ["run.sh", "group.sh", "dir/", "dir/x.txt"], "\(tree(result))")
        for item in all(result.path) where item != result.path {
            var info = stat()
            precondition(lstat(item, &info) == 0 && info.st_mode & 0o7000 == 0, "special bits on \(item)")
        }

        let evil = fresh("evil-source")
        put(evil, "a.txt")
        link(evil, "ok", "a.txt")
        link(evil, "up", "../../x")
        link(evil, "absolute", "/etc/passwd")
        link(evil, "deep", "sub/../../x")
        let tarFolder = fresh("evil")
        precondition(tool("/usr/bin/tar", ["-cf", path(tarFolder, "evil.tar").path, "-C", evil.path, "a.txt", "ok", "up", "absolute", "deep"]) == 0)
        let safe = try! Archive.extract(path(tarFolder, "evil.tar"))
        precondition(Set(tree(safe)) == ["a.txt", "ok -> a.txt"], "\(tree(safe))")
        precondition(same(safe, path(tarFolder, "evil")))

        let victim = fresh("victim")
        let trap = fresh("trap-source")
        put(trap, "pack/ok.txt")
        put(victim, "pwned.txt")
        link(trap, "pack/door", victim.path)
        let through = path(fresh("trap"), "through.tar")
        precondition(tool("/usr/bin/tar", ["-cf", through.path, "-C", trap.path, "pack/ok.txt", "pack/door"]) == 0)
        precondition(tool("/usr/bin/tar", ["-rf", through.path, "-C", trap.path, "pack/door/pwned.txt"]) == 0)
        try! manager.removeItem(at: path(victim, "pwned.txt"))
        _ = failure { _ = try Archive.extract(through) }
        precondition(tree(victim).isEmpty, "a file was written through a link: \(tree(victim))")
        print("hostile ok")
    }

    static func traversal() {
        let marker = "pika-escape-\(UUID().uuidString.prefix(8))"
        func entry(_ name: String) -> (name: [UInt8], data: [UInt8]) { (Array(name.utf8), Array("x".utf8)) }
        let russian = (name: try! legacyBytes("\u{41F}\u{440}\u{438}\u{432}\u{435}\u{442} \u{43C}\u{438}\u{440}.txt", encoding: dosRussian), data: Array("ok".utf8))
        let archives: [(file: String, route: String, entries: [(name: [UInt8], data: [UInt8])])] = [
            ("seven.zip", "sevenZip", [entry("../\(marker)-a.txt"), entry("/\(marker)-b.txt"), entry("ok.txt")]),
            ("ditto.zip", "ditto", [entry("__MACOSX/._ok.txt"), entry("../\(marker)-c.txt"), entry("/\(marker)-d.txt"), entry("ok.txt")]),
            ("legacy.zip", "bsdtar", [entry("../\(marker)-e.txt"), entry("/\(marker)-f.txt"), russian]),
        ]
        for archive in archives {
            let folder = fresh("traversal")
            let url = path(folder, archive.file)
            try! rawZip(archive.entries).write(to: url)
            let route = String(describing: try! Archive.inspect(url, password: nil, job: Archive.Job(), deep: false).route)
            precondition(route.hasPrefix(archive.route), "\(archive.file) took the \(route) route")
            let outcome = failure { _ = try Archive.extract(url) }
            for place in [itemRoot(), root.deletingLastPathComponent(), root, folder, URL(fileURLWithPath: "/")] {
                for letter in "abcdef" {
                    let escaped = place.path + "/\(marker)-\(letter).txt"
                    precondition(!manager.fileExists(atPath: escaped), "\(archive.file) wrote \(escaped)")
                }
            }
            precondition(outcome == nil, "\(archive.file): \(String(describing: outcome))")
            precondition(Set(try! manager.contentsOfDirectory(atPath: folder.path)) == [archive.file, String(archive.file.dropLast(4))], "\(tree(folder))")
        }
        print("traversal ok")
    }

    static func streams() {
        let folder = fresh("streams")
        let source = fresh("streams-source")
        put(source, "dir/a.txt", Data("a".utf8))
        put(source, "dir/sub/b.txt", Data("b".utf8))
        let expected = ["a.txt", "sub/", "sub/b.txt"]
        for (name, flags) in [("d.tar.gz", "-czf"), ("d.tgz", "-czf"), ("d.tar.bz2", "-cjf"), ("d.tbz2", "-cjf"), ("d.tar.xz", "-cJf"), ("d.tar", "-cf")] {
            precondition(tool("/usr/bin/tar", [flags, path(folder, name).path, "-C", source.path, "dir"]) == 0, name)
            let archive = path(folder, name)
            let info = try! Archive.probe(archive)
            precondition(info.names == ["dir"] && !info.isTruncated, "\(name): \(info)")
            let result = try! Archive.extract(archive)
            precondition(result.lastPathComponent.hasPrefix("dir") && tree(result) == expected, "\(name): \(tree(result))")
        }
        put(folder, "plain.txt", Data("plain\n".utf8))
        precondition(tool("/usr/bin/gzip", ["-k", "plain.txt"], in: folder) == 0)
        try! manager.removeItem(at: path(folder, "plain.txt"))
        precondition(try! Archive.probe(path(folder, "plain.txt.gz")).entries == 1)
        let single = try! Archive.extract(path(folder, "plain.txt.gz"))
        precondition(single.lastPathComponent == "plain.txt" && (try! Data(contentsOf: single)) == Data("plain\n".utf8))
        let mine = fresh("streams-made")
        put(mine, "box/a.txt")
        for format in [Archive.Format.tarGz, .tarXz] {
            let made = try! Archive.create(items: [path(mine, "box")], name: "mine", format: format)
            let check = try! Archive.probe(made[0])
            precondition(check.names == ["box"] && check.entries == 1, "\(format): \(check)")
            let result = try! Archive.extract(move(made, into: fresh("streams-out"))[0])
            precondition(tree(result) == ["a.txt"])
        }
        print("streams ok")
    }

    static func finderZip() {
        let folder = fresh("finder")
        let box = path(folder, "fx")
        let note = put(box, "a.txt")
        put(box, ".DS_Store")
        precondition(setxattr(note.path, "user.pika", Array("hi".utf8), 2, 0, 0) == 0)
        precondition(tool("/usr/bin/ditto", ["-c", "-k", "--sequesterRsrc", "--keepParent", "fx", "fx.zip"], in: folder) == 0)
        let zip = move([path(folder, "fx.zip")], into: fresh("finder-out"))[0]
        precondition(try! Archive.inspect(zip, password: nil, job: Archive.Job(), deep: false).route == .ditto)
        precondition(try! Archive.probe(zip).names == ["fx"])
        let result = try! Archive.extract(zip)
        precondition(tree(result) == ["a.txt"], "\(tree(result))")
        var value = [UInt8](repeating: 0, count: 8)
        let read = getxattr(path(result, "a.txt").path, "user.pika", &value, 8, 0, 0)
        precondition(read == 2 && value.prefix(2) == [104, 105], "the __MACOSX metadata was not applied")
        print("finder zip ok")
    }

    static func legacyNames() {
        let cases: [(String, String.Encoding, [String])] = [
            ("ru", dosRussian, ["\u{414}\u{43E}\u{43A}\u{443}\u{43C}\u{435}\u{43D}\u{442}\u{44B}/\u{41E}\u{442}\u{447}\u{451}\u{442} \u{437}\u{430} \u{433}\u{43E}\u{434}.txt", "\u{414}\u{43E}\u{43A}\u{443}\u{43C}\u{435}\u{43D}\u{442}\u{44B}/\u{41F}\u{440}\u{438}\u{432}\u{435}\u{442}, \u{43C}\u{438}\u{440}.txt", "\u{424}\u{43E}\u{442}\u{43E}/\u{41D}\u{43E}\u{432}\u{44B}\u{439} \u{433}\u{43E}\u{434}.txt"]),
            ("jp", .shiftJIS, ["\u{5199}\u{771F}/\u{65C5}\u{884C}\u{306E}\u{601D}\u{3044}\u{51FA}.txt", "\u{66F8}\u{985E}/\u{5831}\u{544A}\u{66F8}\u{306E}\u{4E0B}\u{66F8}\u{304D}.txt", "\u{30C6}\u{30B9}\u{30C8}\u{7528}\u{30D5}\u{30A1}\u{30A4}\u{30EB}.txt"]),
        ]
        for (label, encoding, names) in cases {
            let folder = fresh("legacy-\(label)")
            let entries = names.map { (name: try! legacyBytes($0, encoding: encoding), data: Array("data of \($0.count)".utf8)) }
            try! rawZip(entries).write(to: path(folder, "\(label).zip"))
            let info = try! Archive.probe(path(folder, "\(label).zip"))
            precondition(info.codePage != nil, "\(label): no code page found")
            for languages in [["en-US"], ["de-DE"], []] {
                precondition(ZipNames.detect(entries.map(\.name), languages: languages) == info.codePage, "\(label): the language list \(languages) changed the code page")
            }
            precondition(info.names.map { $0.precomposedStringWithCanonicalMapping }.sorted() == Set(names.map { String($0.split(separator: "/")[0]).precomposedStringWithCanonicalMapping }).sorted(), "\(label): \(info.names)")
            let result = try! Archive.extract(path(folder, "\(label).zip"))
            let found = Set(files(result).map { $0.precomposedStringWithCanonicalMapping })
            precondition(found == Set(names.map { $0.precomposedStringWithCanonicalMapping }), "\(label): \(found)")
        }
        print("legacy names ok")
    }

    static func zipReader() {
        let folder = fresh("zip-reader")
        let file = path(folder, "x.zip")
        func read(_ data: Data) -> ZipNames.Directory? {
            try! data.write(to: file)
            return ZipNames.read(file)
        }
        var tiny = Data([0x50, 0x4B, 3, 4]) + Data(count: 40)
        tiny.put32(0x0605_4b50)
        [0, 0, 1, 1].forEach { tiny.put16($0) }
        tiny.put32(2)
        tiny.put32(0)
        tiny.put16(0)
        precondition(tiny.count == 66 && read(tiny) == nil)
        precondition(read(zip64End(count: .max, size: 0, offset: 0, at: 0)) == nil)
        for bad in [tiny, zip64End(count: .max, size: 0, offset: 0, at: 0)] {
            try! bad.write(to: file)
            _ = failure { _ = try Archive.probe(file) }
        }

        let unicode = Array("\u{FC}n\u{EF}.txt".utf8)
        let rich = zip64([
            (name: Array("a.txt".utf8), extra: field(0x0001, le64(5_000) + le64(900)), method: 8),
            (name: try! legacyBytes("\u{41F}\u{440}\u{438}\u{432}\u{435}\u{442}.txt", encoding: dosRussian), extra: [], method: 8),
            (name: Array("uni.txt".utf8), extra: field(0x7075, [1, 0, 0, 0, 0] + unicode), method: 0),
            (name: Array("enc.bin".utf8), extra: field(0x9901, [2, 0, 0x41, 0x45, 3, 8, 0]), method: 99),
        ])
        let entries = read(rich)?.entries ?? []
        precondition(entries.count == 4 && entries[0].size == 5_000 && entries[0].packed == 900 && entries[2].name == "\u{FC}n\u{EF}.txt" && entries[3].method == 8, "\(entries)")
        let plain = rawZip([(name: Array("a.txt".utf8), data: Array("hello".utf8)), (name: Array("dir/".utf8), data: []), (name: Array("dir/b.txt".utf8), data: Array("bye".utf8))])
        precondition(read(plain)?.entries.count == 3)
        var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
        func next() -> Int {
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            return Int(truncatingIfNeeded: seed >> 1)
        }
        let edges: [UInt64] = [0, 1, 2, 3, 0x7F, 0x80, 0xFF, 0xFFFF, 0x7FFF_FFFF, 0xFFFF_FFFF, 0x7FFF_FFFF_FFFF_FFFF, .max]
        let started = Date()
        for round in 0..<3_000 {
            var bytes = [UInt8](round % 2 == 0 ? rich : plain)
            if round % 3 == 0 {
                bytes.removeLast(next() % bytes.count)
            } else {
                for _ in 0..<(1 + next() % 3) {
                    let at = next() % bytes.count
                    var value = edges[next() % edges.count]
                    for index in at..<min(at + [1, 2, 4, 8][next() % 4], bytes.count) {
                        bytes[index] = UInt8(truncatingIfNeeded: value)
                        value >>= 8
                    }
                }
            }
            _ = read(Data(bytes))
        }
        precondition(Date().timeIntervalSince(started) < 20, "reading 3000 damaged zips took \(Date().timeIntervalSince(started)) s")

        let twice = zip64([
            (name: Array("one.bin".utf8), extra: field(0x0001, le64(.max) + le64(1)), method: 8),
            (name: Array("two.bin".utf8), extra: field(0x0001, le64(.max) + le64(1)), method: 8),
        ])
        let sums = path(fresh("zip-sums"), "sums.zip")
        try! twice.write(to: sums)
        expect(.huge(expanded: .max, packed: Int64(twice.count)), "sizes adding up past Int64.max") { _ = try Archive.extract(sums) }
        let records = Archive.Records()
        ["Path = a", "Size = 18446744073709551615", "", "Path = b", "Size = 9223372036854775807", ""].forEach(records.feed)
        precondition(records.tally.listing.info.expandedSize == .max)

        let line = try! legacyBytes("\u{414}\u{43E}\u{43A}\u{443}\u{43C}\u{435}\u{43D}\u{442}\u{44B} \u{41E}\u{442}\u{447}\u{451}\u{442} \u{437}\u{430} \u{433}\u{43E}\u{434} ", encoding: dosRussian)
        let long = (0..<(60_000 / line.count)).flatMap { _ in line }
        let begun = Date()
        let page = ZipNames.detect(Array(repeating: long, count: 300))
        precondition(page == "CP866" && Date().timeIntervalSince(begun) < 2, "\(page) after \(Date().timeIntervalSince(begun)) s")
        print("zip reader ok")
    }

    static func watching() {
        let verdict = ArchiveError.noSpace(needed: 7, free: 3)
        let started = Date()
        let calls = Recorder()
        let sleeper = Archive.Stage(URL(fileURLWithPath: "/bin/sleep"), ["60"])
        precondition(failure { _ = try Archive.run([sleeper], job: Archive.Job(), watch: { calls.add(0); return verdict }) } == verdict, "the verdict was not thrown")
        precondition(Date().timeIntervalSince(started) < 10 && !calls.values.isEmpty, "the stopped process kept running")
        let quick = Archive.Stage(URL(fileURLWithPath: "/usr/bin/true"), [])
        precondition(failure { _ = try Archive.run([quick], job: Archive.Job(), watch: { verdict }) } == verdict, "no check after the process ended")
        precondition(try! Archive.run([quick], job: Archive.Job(), watch: { nil }) == [0])

        let folder = fresh("sizes")
        put(folder, "a.bin", Data(count: 100))
        put(folder, "dir/b.bin", Data(count: 50))
        put(folder, "dir/._c", Data(count: 7))
        link(folder, "alias", "a.bin")
        precondition(Archive.size(of: folder.path) == 157)
        precondition(Archive.watcher(over: folder, in: folder, info: Archive.Info(), allowHuge: false)() == nil)
        print("watch ok")
    }

    static func placedLinks() {
        let source = fresh("placed-links-source")
        put(source, "pack/a.txt")
        put(source, "pack/sub/b.txt")
        link(source, "pack/inside", "a.txt")
        link(source, "pack/sub/back", "../a.txt")
        for (name, target) in [("up", ".."), ("sibling", "../ghost.txt"), ("sub/deep", "../.."), ("sub/ghost", "../../ghost.txt")] { link(source, "pack/" + name, target) }
        let inside = ["a.txt", "inside -> a.txt", "sub/", "sub/b.txt", "sub/back -> ../a.txt"]
        let single = fresh("placed-links-single")
        try! manager.copyItem(at: path(source, "pack"), to: path(single, "pack"))
        _ = try! Archive.sanitize(single, marking: nil)
        precondition(tree(path(single, "pack")) == inside, "\(tree(path(single, "pack")))")
        let folded = fresh("placed-links-folded")
        try! manager.copyItem(at: path(source, "pack"), to: path(folded, "pack"))
        put(folded, "other.txt")
        _ = try! Archive.sanitize(folded, marking: nil)
        precondition(tree(path(folded, "pack")) == tree(path(source, "pack")), "\(tree(path(folded, "pack")))")

        precondition(tool("/usr/bin/tar", ["-cf", "pack.tar", "pack"], in: source) == 0)
        precondition(tool("/usr/bin/zip", ["-qry", "pack.zip", "pack"], in: source) == 0)
        precondition(setxattr(path(source, "pack/a.txt").path, "user.pika", Array("hi".utf8), 2, 0, 0) == 0)
        precondition(tool("/usr/bin/ditto", ["-c", "-k", "--sequesterRsrc", "--keepParent", "pack", "finder.zip"], in: source) == 0)
        for (made, name, route, expected) in [("pack.tar", "pack.tar", Archive.Route.sevenZip, Array(inside.dropLast())), ("pack.zip", "pack.zip", .sevenZip, Array(inside.dropLast())), ("finder.zip", "pack.zip", .ditto, inside)] {
            let folder = fresh("placed-links")
            let archive = path(folder, name)
            try! manager.copyItem(at: path(source, made), to: archive)
            precondition(try! Archive.inspect(archive, password: nil, job: Archive.Job(), deep: false).route == route, "\(made) took another route")
            let result = try! Archive.extract(archive)
            precondition(same(result, path(folder, "pack")) && tree(result) == expected, "\(made): \(tree(result))")
        }
        print("placed links ok")
    }

    static func appleDouble() {
        let source = fresh("apple-double-source")
        put(source, "pack/a.txt")
        put(source, "pack/._a.txt", Data("forged".utf8))
        chmod(put(source, "pack/._evil.command", Data("#!/bin/sh\n".utf8)).path, 0o755)
        put(source, "pack/sub/._x")
        put(source, "pack/sub/ok.txt")
        put(source, "pack/sub/.DS_Store")
        precondition(Archive.entries(of: path(source, "pack").path).sorted() == ["._a.txt", "._evil.command", "a.txt", "sub"])
        precondition(tool("/usr/bin/zip", ["-qr", "pack.zip", "pack"], in: source) == 0)
        let value = "0083;5f3e1c2a;Safari;"
        let volume = disk("16m")
        defer { if let volume { tool("/usr/bin/hdiutil", ["detach", "-force", volume.path]) } }
        if volume == nil { print("apple double: the exFAT part was skipped (no disk image could be attached)") }
        for place in [fresh("apple-double")] + (volume.map { [$0] } ?? []) {
            let archive = path(place, "pack.zip")
            try! manager.copyItem(at: path(source, "pack.zip"), to: archive)
            precondition(setxattr(archive.path, quarantineKey, Array(value.utf8), value.utf8.count, 0, 0) == 0)
            let result = try! Archive.extract(archive)
            let found = raw(result.path)
            let label = place == volume ? "exFAT" : "APFS"
            precondition(found.filter { !$0.hasPrefix("._") && !$0.contains("/._") } == ["a.txt", "sub", "sub/ok.txt"], "\(label): \(found)")
            precondition(!found.contains("._evil.command") && !found.contains("sub/._x") && !found.contains("sub/.DS_Store"), "\(label): \(found)")
            precondition((try? Data(contentsOf: path(result, "._a.txt"))) != Data("forged".utf8), "\(label): the shipped ._a.txt survived")
            if place != volume { precondition(found == ["a.txt", "sub", "sub/ok.txt"], "\(label): \(found)") }
            precondition((try? Data(contentsOf: path(result, "a.txt"))) == Data("x".utf8))
            for item in ["", "/a.txt", "/sub", "/sub/ok.txt"] { precondition(quarantine(result.path + item) == value, "\(label): no quarantine on \(item)") }
        }
        print("apple double ok")
    }

    static func cancelling() {
        let folder = fresh("cancel")
        let box = path(folder, "box")
        for number in 1...6 { put(box, "r\(number).bin", random(20_000_000)) }
        let before = Set(try! manager.contentsOfDirectory(atPath: folder.path))
        let finished = Archive.Job()
        finished.cancel()
        expect(.cancelled, "create with a stopped job") { _ = try Archive.create(items: [box], name: "C", format: .zip, job: finished) }
        let job = Archive.Job()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25) { job.cancel() }
        let started = Date()
        expect(.cancelled, "create stopped half way") { _ = try Archive.create(items: [box], name: "C", format: .tarXz, job: job, progress: { _ in job.cancel() }) }
        precondition(Date().timeIntervalSince(started) < 20, "stopping took too long")
        precondition(Set(try! manager.contentsOfDirectory(atPath: folder.path)) == before, "a stopped create left files behind")
        let zip = move(try! Archive.create(items: [box], name: "C", format: .zip), into: fresh("cancel-zip"))[0]
        expect(.cancelled, "extract with a stopped job") { _ = try Archive.extract(zip, job: finished) }
        let running = Archive.Job()
        let outcome = failure { _ = try Archive.extract(zip, job: running, progress: { _ in running.cancel() }) }
        precondition(outcome == nil || outcome == .cancelled, "\(String(describing: outcome))")
        if outcome == .cancelled {
            precondition(Set(try! manager.contentsOfDirectory(atPath: zip.deletingLastPathComponent().path)) == [zip.lastPathComponent], "a stopped extract left files behind")
        }
        print("cancel ok")
    }

    static func rar() {
        guard let samples = ProcessInfo.processInfo.environment["PIKA_RAR_SAMPLES"] else {
            print("rar skipped (set PIKA_RAR_SAMPLES to a folder of your own .rar files)")
            return
        }
        let folder = fresh("rar")
        let names = (try! manager.contentsOfDirectory(atPath: samples)).filter { !$0.hasPrefix(".") }.sorted()
        for name in names { try! manager.copyItem(atPath: samples + "/" + name, toPath: folder.path + "/" + name) }
        var opened = 0
        for first in Archive.distinct(names.map { path(folder, $0) }) where Archive.isArchive(first) {
            do {
                let info = try Archive.probe(first)
                precondition(info.entries > 0, "\(first.lastPathComponent) has no entries")
                _ = try Archive.extract(first, allowPartial: true)
                opened += 1
            } catch ArchiveError.needsPassword, ArchiveError.wrongPassword, ArchiveError.damaged {
                opened += 1
            } catch {
                preconditionFailure("\(first.lastPathComponent): \(error)")
            }
        }
        precondition(opened > 0, "no archives in \(samples)")
        print("rar ok (\(opened))")
    }

    static var dosRussian: String.Encoding {
        String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosRussian.rawValue)))
    }

    static func legacyBytes(_ text: String, encoding: String.Encoding) throws -> [UInt8] {
        guard let data = text.data(using: encoding) else { throw ArchiveError.failed("cannot encode \(text)") }
        return [UInt8](data)
    }

    static func rawZip(_ entries: [(name: [UInt8], data: [UInt8])]) -> Data {
        var body = Data()
        var directory = Data()
        for entry in entries {
            let crc = checksum(entry.data)
            let size = UInt32(entry.data.count)
            body.put32(0x0403_4b50)
            [20, 0, 0, 0, 0x21].forEach { body.put16($0) }
            body.put32(crc)
            body.put32(size)
            body.put32(size)
            body.put16(entry.name.count)
            body.put16(0)
            body.append(contentsOf: entry.name)
            body.append(contentsOf: entry.data)
            directory.put32(0x0201_4b50)
            [20, 20, 0, 0, 0, 0x21].forEach { directory.put16($0) }
            directory.put32(crc)
            directory.put32(size)
            directory.put32(size)
            directory.put16(entry.name.count)
            [0, 0, 0, 0].forEach { directory.put16($0) }
            directory.put32(0)
            directory.put32(UInt32(body.count - 30 - entry.name.count - entry.data.count))
            directory.append(contentsOf: entry.name)
        }
        var end = Data()
        end.put32(0x0605_4b50)
        [0, 0, entries.count, entries.count].forEach { end.put16($0) }
        end.put32(UInt32(directory.count))
        end.put32(UInt32(body.count))
        end.put16(0)
        return body + directory + end
    }

    static func field(_ id: Int, _ body: [UInt8]) -> [UInt8] {
        var head = Data()
        head.put16(id)
        head.put16(body.count)
        return [UInt8](head) + body
    }

    static func le64(_ value: UInt64) -> [UInt8] {
        (0..<8).map { UInt8(truncatingIfNeeded: value >> UInt64(8 * $0)) }
    }

    static func zip64End(count: UInt64, size: UInt64, offset: UInt64, at record: Int) -> Data {
        var data = Data()
        data.put32(0x0606_4b50)
        data.append(contentsOf: le64(44))
        [45, 45].forEach { data.put16($0) }
        data.put32(0)
        data.put32(0)
        for value in [count, count, size, offset] { data.append(contentsOf: le64(value)) }
        data.put32(0x0706_4b50)
        data.put32(0)
        data.append(contentsOf: le64(UInt64(record)))
        data.put32(1)
        data.put32(0x0605_4b50)
        [0, 0, 0xFFFF, 0xFFFF].forEach { data.put16($0) }
        data.put32(0xFFFF_FFFF)
        data.put32(0xFFFF_FFFF)
        data.put16(0)
        return data
    }

    static func zip64(_ entries: [(name: [UInt8], extra: [UInt8], method: Int)]) -> Data {
        var directory = Data()
        for entry in entries {
            directory.put32(0x0201_4b50)
            [45, 45, 0, entry.method, 0, 0x21].forEach { directory.put16($0) }
            directory.put32(0)
            directory.put32(0xFFFF_FFFF)
            directory.put32(0xFFFF_FFFF)
            directory.put16(entry.name.count)
            directory.put16(entry.extra.count)
            [0, 0, 0].forEach { directory.put16($0) }
            directory.put32(0)
            directory.put32(0)
            directory.append(contentsOf: entry.name + entry.extra)
        }
        return directory + zip64End(count: UInt64(entries.count), size: UInt64(directory.count), offset: 0, at: directory.count)
    }

    static func checksum(_ bytes: [UInt8]) -> UInt32 {
        var crc: UInt32 = 0xFFFF_FFFF
        for byte in bytes {
            crc ^= UInt32(byte)
            for _ in 0..<8 { crc = crc & 1 == 1 ? (crc >> 1) ^ 0xEDB8_8320 : crc >> 1 }
        }
        return ~crc
    }

    static func zipEntries(_ url: URL) -> [(name: String, flags: Int)] {
        let bytes = [UInt8](try! Data(contentsOf: url))
        func number(_ at: Int, _ width: Int) -> Int { (0..<width).reduce(0) { $0 | Int(bytes[at + $1]) << (8 * $1) } }
        var end = bytes.count - 22
        while end > 0, number(end, 4) != 0x0605_4b50 { end -= 1 }
        var at = number(end + 16, 4)
        var found: [(name: String, flags: Int)] = []
        for _ in 0..<number(end + 10, 2) {
            let length = number(at + 28, 2)
            found.append((String(decoding: bytes[(at + 46)..<(at + 46 + length)], as: UTF8.self), number(at + 8, 2)))
            at += 46 + length + number(at + 30, 2) + number(at + 32, 2)
        }
        return found
    }

    static func isComposed(_ text: String) -> Bool {
        text.utf8.elementsEqual(text.precomposedStringWithCanonicalMapping.utf8)
    }

    static func failure(_ body: () throws -> Void) -> ArchiveError? {
        do {
            try body()
            return nil
        } catch let error as ArchiveError {
            return error
        } catch {
            return .failed("\(error)")
        }
    }

    static func expect(_ expected: ArchiveError, _ label: String, _ body: () throws -> Void) {
        let got = failure(body)
        precondition(got == expected, "\(label): expected \(expected), got \(String(describing: got))")
    }

    static func broken(_ label: String, _ body: () throws -> Void) -> (extracted: Int, total: Int, result: URL) {
        guard case .damaged(let extracted, let total, let result)? = failure(body) else { preconditionFailure("\(label): expected a damaged result") }
        return (extracted, total, result)
    }

    static func fresh(_ label: String) -> URL {
        let url = root.appendingPathComponent("\(label)-\(UUID().uuidString.prefix(6))")
        try! manager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func path(_ folder: URL, _ relative: String) -> URL {
        URL(fileURLWithPath: folder.path + "/" + relative)
    }

    @discardableResult
    static func put(_ folder: URL, _ relative: String, _ data: Data = Data("x".utf8)) -> URL {
        let url = path(folder, relative)
        if relative.hasSuffix("/") {
            try! manager.createDirectory(at: url, withIntermediateDirectories: true)
        } else {
            try! manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try! data.write(to: url)
        }
        return url
    }

    static func link(_ folder: URL, _ name: String, _ target: String) {
        try! manager.createSymbolicLink(atPath: folder.path + "/" + name, withDestinationPath: target)
    }

    static func move(_ urls: [URL], into folder: URL) -> [URL] {
        urls.map {
            let target = path(folder, $0.lastPathComponent)
            try! manager.moveItem(at: $0, to: target)
            return target
        }
    }

    static func same(_ first: URL, _ second: URL) -> Bool {
        first.resolvingSymlinksInPath().path == second.resolvingSymlinksInPath().path
    }

    static func random(_ count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        arc4random_buf(&bytes, count)
        return Data(bytes)
    }

    @discardableResult
    static func tool(_ executable: String, _ arguments: [String], in folder: URL? = nil) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = folder
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try! process.run()
        process.waitUntilExit()
        return process.terminationStatus
    }

    static func tree(_ folder: URL, _ prefix: String = "") -> [String] {
        var found: [String] = []
        for name in try! manager.contentsOfDirectory(atPath: folder.path).sorted() {
            let item = folder.path + "/" + name
            var info = stat()
            precondition(lstat(item, &info) == 0, item)
            switch info.st_mode & S_IFMT {
            case S_IFDIR:
                found.append(prefix + name + "/")
                found += tree(URL(fileURLWithPath: item), prefix + name + "/")
            case S_IFLNK:
                found.append(prefix + name + " -> " + ((try? manager.destinationOfSymbolicLink(atPath: item)) ?? "?"))
            default:
                found.append(prefix + name)
            }
        }
        return found
    }

    static func files(_ folder: URL) -> [String] {
        tree(folder).filter { !$0.hasSuffix("/") }
    }

    static func raw(_ folder: String, _ prefix: String = "") -> [String] {
        var found: [String] = []
        for name in Archive.entries(of: folder).sorted() {
            var info = stat()
            precondition(lstat(folder + "/" + name, &info) == 0)
            found.append(prefix + name)
            if info.st_mode & S_IFMT == S_IFDIR { found += raw(folder + "/" + name, prefix + name + "/") }
        }
        return found
    }

    static func disk(_ size: String) -> URL? {
        let volume = fresh("tiny")
        let image = root.appendingPathComponent("tiny-\(UUID().uuidString.prefix(6)).dmg")
        guard tool("/usr/bin/hdiutil", ["create", "-size", size, "-fs", "ExFAT", "-volname", "PikaTiny", image.path]) == 0,
              tool("/usr/bin/hdiutil", ["attach", "-nobrowse", "-mountpoint", volume.path, image.path]) == 0 else { return nil }
        return volume
    }

    static func all(_ folder: String) -> [String] {
        var found = [folder]
        var info = stat()
        guard lstat(folder, &info) == 0, info.st_mode & S_IFMT == S_IFDIR else { return found }
        for name in try! manager.contentsOfDirectory(atPath: folder) { found += all(folder + "/" + name) }
        return found
    }

    static func quarantine(_ item: String) -> String? {
        let size = getxattr(item, quarantineKey, nil, 0, 0, XATTR_NOFOLLOW)
        guard size > 0 else { return nil }
        var buffer = [UInt8](repeating: 0, count: size)
        guard getxattr(item, quarantineKey, &buffer, size, 0, XATTR_NOFOLLOW) == size else { return nil }
        return String(decoding: buffer, as: UTF8.self)
    }

    static func itemRoot() -> URL {
        let probe = try! manager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: root, create: true)
        defer { try? manager.removeItem(at: probe) }
        return probe.deletingLastPathComponent()
    }

    static func ownItems() -> Set<String> {
        let prefix = "NSIRD_\(ProcessInfo.processInfo.processName)_"
        return Set(Archive.entries(of: itemRoot().path).filter { $0.hasPrefix(prefix) })
    }
}
