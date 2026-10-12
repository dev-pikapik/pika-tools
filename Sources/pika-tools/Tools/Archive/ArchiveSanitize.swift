import Foundation

extension Archive {
    private static let quarantineKey = "com.apple.quarantine"

    static func quarantine(of url: URL) -> Data? {
        let size = getxattr(url.path, quarantineKey, nil, 0, 0, 0)
        guard size > 0 else { return nil }
        var value = Data(count: size)
        let read = value.withUnsafeMutableBytes { getxattr(url.path, quarantineKey, $0.baseAddress, size, 0, 0) }
        return read == size ? value : nil
    }

    static func mark(_ path: String, with value: Data) throws {
        let status = value.withUnsafeBytes { setxattr(path, quarantineKey, $0.baseAddress, value.count, 0, XATTR_NOFOLLOW) }
        guard status == 0 else { throw ArchiveError.failed("cannot mark " + (path as NSString).lastPathComponent) }
    }

    static func resolved(_ path: String) -> String? {
        guard let pointer = realpath(path, nil) else { return nil }
        defer { free(pointer) }
        return String(cString: pointer)
    }

    static func isInside(_ path: String, _ root: String) -> Bool {
        path == root || path.hasPrefix(root + "/")
    }

    static func staysInside(link path: String, root: String) -> Bool {
        guard let target = try? FileManager.default.destinationOfSymbolicLink(atPath: path), !target.isEmpty, !target.hasPrefix("/"),
              var current = resolved((path as NSString).deletingLastPathComponent), isInside(current, root) else { return false }
        for part in target.split(separator: "/") where part != "." {
            if part == ".." {
                current = (current as NSString).deletingLastPathComponent
            } else {
                current += "/" + part
                var info = stat()
                if lstat(current, &info) == 0 {
                    guard let real = resolved(current) else { return false }
                    current = real
                }
            }
            guard isInside(current, root) else { return false }
        }
        return true
    }

    static func discard(_ relative: String, in root: URL) {
        let parts = relative.split(separator: "/").filter { $0 != "." }.map(String.init)
        guard !relative.hasPrefix("/"), !parts.contains(".."), let leaf = parts.last,
              let base = resolved(root.path),
              let folder = resolved(([base] + parts.dropLast()).joined(separator: "/")), isInside(folder, base) else { return }
        unlink(folder + "/" + leaf)
    }

    static func sanitize(_ root: URL, marking value: Data?) throws -> (items: Int, files: Int) {
        guard let base = resolved(root.path) else { throw ArchiveError.failed("no output") }
        var items = 0
        var files = 0
        let top = survivors(in: base)
        try sweep(base, root: top.count == 1 ? base + "/" + top[0] : base, value: value, items: &items, files: &files)
        return (items, files)
    }

    static func entries(of folder: String) -> [String] {
        guard let stream = opendir(folder) else { return [] }
        defer { closedir(stream) }
        var names: [String] = []
        while let entry = readdir(stream) {
            let name = withUnsafePointer(to: entry.pointee.d_name) { $0.withMemoryRebound(to: CChar.self, capacity: Int(entry.pointee.d_namlen) + 1) { String(cString: $0) } }
            if name != ".", name != ".." { names.append(name) }
        }
        return names
    }

    private static func survivors(in folder: String) -> [String] {
        var kept: [String] = []
        for name in entries(of: folder) {
            if isJunk(path: name) {
                unlock(folder + "/" + name)
                try? FileManager.default.removeItem(atPath: folder + "/" + name)
            } else {
                kept.append(name)
            }
        }
        return kept
    }

    static func unlock(_ folder: String) {
        var info = stat()
        guard lstat(folder, &info) == 0, info.st_mode & S_IFMT == S_IFDIR else { return }
        chmod(folder, (info.st_mode & 0o777) | 0o700)
        for name in entries(of: folder) { unlock(folder + "/" + name) }
    }

    private static func sweep(_ folder: String, root: String, value: Data?, items: inout Int, files: inout Int) throws {
        for name in survivors(in: folder) {
            let path = folder + "/" + name
            var info = stat()
            guard lstat(path, &info) == 0 else { continue }
            let mode = info.st_mode & 0o777
            switch info.st_mode & S_IFMT {
            case S_IFDIR:
                chmod(path, mode | 0o700)
                try sweep(path, root: root, value: value, items: &items, files: &files)
            case S_IFREG:
                chmod(path, mode | 0o600)
                files += 1
            case S_IFLNK where staysInside(link: path, root: root):
                files += 1
            default:
                unlink(path)
                continue
            }
            items += 1
            if let value { try mark(path, with: value) }
        }
    }
}
