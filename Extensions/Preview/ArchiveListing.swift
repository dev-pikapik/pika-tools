import Foundation

private let formats = [archive_read_support_filter_gzip, archive_read_support_filter_bzip2, archive_read_support_filter_xz,
                       archive_read_support_filter_lzma, archive_read_support_filter_zstd, archive_read_support_filter_compress,
                       archive_read_support_format_zip, archive_read_support_format_7zip, archive_read_support_format_rar,
                       archive_read_support_format_rar5, archive_read_support_format_tar, archive_read_support_format_cpio,
                       archive_read_support_format_lha, archive_read_support_format_cab, archive_read_support_format_raw]

private final class Source {
    static let block = 1 << 17

    let fd: Int32
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: Source.block, alignment: 16)
    let deadline = DispatchTime.now().uptimeNanoseconds + UInt64(ArchiveListing.timeLimit * 1_000_000_000)
    var expired = false

    init(fd: Int32) { self.fd = fd }
    deinit { buffer.deallocate() }
}

private let readBlock: archive_read_callback = { _, data, out in
    let source = Unmanaged<Source>.fromOpaque(data!).takeUnretainedValue()
    guard DispatchTime.now().uptimeNanoseconds < source.deadline else {
        source.expired = true
        return -1
    }
    out!.pointee = UnsafeRawPointer(source.buffer)
    return read(source.fd, source.buffer, Source.block)
}

private let skipBlock: archive_skip_callback = { _, data, request in
    let source = Unmanaged<Source>.fromOpaque(data!).takeUnretainedValue()
    return lseek(source.fd, request, SEEK_CUR) < 0 ? 0 : request
}

private let seekBlock: archive_seek_callback = { _, data, offset, whence in
    let source = Unmanaged<Source>.fromOpaque(data!).takeUnretainedValue()
    let position = lseek(source.fd, offset, whence)
    return position < 0 ? -30 : position
}

struct ArchiveListing {
    struct Item {
        var path: String
        let size: Int64
        let isFolder: Bool
        let isExecutable: Bool
    }

    static let maxItems = 5000
    static let timeLimit = 1.5
    private static let rawFormat: Int32 = 0x90000
    private static let nameLimit = 1024

    var items: [Item] = []
    var isEncrypted = false
    var namesHidden = false
    var isDamaged = false
    var isCut = false

    static func read(_ url: URL) -> ArchiveListing? {
        let fd = open(url.path, O_RDONLY)
        guard fd >= 0 else { return nil }
        defer { close(fd) }
        let source = Unmanaged.passRetained(Source(fd: fd))
        defer { source.release() }
        guard let archive = archive_read_new() else { return nil }
        defer { _ = archive_read_free(archive) }
        for enable in formats { _ = enable(archive) }
        _ = archive_read_set_seek_callback(archive, seekBlock)
        guard archive_read_open2(archive, source.toOpaque(), nil, readBlock, skipBlock, nil) == 0 else { return nil }

        func bytes(_ pointer: UnsafePointer<CChar>?) -> [UInt8]? {
            guard let pointer else { return nil }
            return Array(UnsafeBufferPointer(start: UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: min(strlen(pointer), 1 << 16)))
        }

        var listing = ArchiveListing()
        var legacy: [(index: Int, name: [UInt8])] = []
        var entry: OpaquePointer?
        while true {
            let result = archive_read_next_header(archive, &entry)
            if result == 1 { break }
            guard result == 0 || result == -20, let entry else {
                if source.takeUnretainedValue().expired { listing.isCut = true } else { listing.isDamaged = true }
                break
            }
            var path = ""
            var legacyName: [UInt8]?
            if let name = bytes(archive_entry_pathname_utf8(entry)) {
                path = String(decoding: name, as: UTF8.self)
            } else if let name = bytes(archive_entry_pathname(entry)) {
                if let text = String(bytes: name, encoding: .utf8) { path = text } else { legacyName = Array(name.prefix(nameLimit)) }
            }
            if legacyName == nil, path.isEmpty || isJunk(path) { continue }
            if listing.items.count == maxItems {
                listing.isCut = true
                break
            }
            if let legacyName { legacy.append((listing.items.count, legacyName)) }
            let type = archive_entry_filetype(entry)
            listing.items.append(Item(
                path: String(path.prefix(nameLimit)),
                size: archive_entry_size_is_set(entry) != 0 ? min(max(archive_entry_size(entry), 0), 1 << 50) : 0,
                isFolder: type == 0o040000,
                isExecutable: type == 0o100000 && archive_entry_mode(entry) & 0o111 != 0
            ))
            if archive_entry_is_encrypted(entry) != 0 { listing.isEncrypted = true }
        }

        let format = archive_format(archive)
        guard format != 0, format != rawFormat || archive_filter_count(archive) > 1 else { return nil }
        if archive_read_has_encrypted_entries(archive) == 1 {
            listing.isEncrypted = true
            if listing.items.isEmpty {
                listing.namesHidden = true
                listing.isDamaged = false
            }
        }
        if format == rawFormat, listing.items.count == 1 {
            listing.items[0].path = url.deletingPathExtension().lastPathComponent
        }
        if !legacy.isEmpty {
            let page = ZipNames.detect(legacy.map(\.name))
            for item in legacy {
                listing.items[item.index].path = String(ZipNames.decode(item.name, codePage: page).prefix(nameLimit))
            }
        }
        return listing
    }

    private static func isJunk(_ path: String) -> Bool {
        let parts = path.split(separator: "/")
        return parts.contains("__MACOSX") || parts.last.map { $0 == ".DS_Store" || $0.hasPrefix("._") } == true
    }
}
