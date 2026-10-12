import Foundation

private typealias Handle = OpaquePointer
private typealias ReadCallback = @convention(c) (Handle?, UnsafeMutableRawPointer?, UnsafeMutablePointer<UnsafeRawPointer?>?) -> Int
private typealias SkipCallback = @convention(c) (Handle?, UnsafeMutableRawPointer?, Int64) -> Int64
private typealias SeekCallback = @convention(c) (Handle?, UnsafeMutableRawPointer?, Int64, Int32) -> Int64

private struct Library {
    static let shared = Library()

    let new: @convention(c) () -> Handle?
    let free: @convention(c) (Handle) -> Int32
    let enable: [@convention(c) (Handle) -> Int32]
    let setSeek: @convention(c) (Handle, SeekCallback) -> Int32
    let open: @convention(c) (Handle, UnsafeMutableRawPointer?, UnsafeRawPointer?, ReadCallback, SkipCallback, UnsafeRawPointer?) -> Int32
    let nextHeader: @convention(c) (Handle, UnsafeMutablePointer<Handle?>) -> Int32
    let format: @convention(c) (Handle) -> Int32
    let filterCount: @convention(c) (Handle) -> Int32
    let hasEncrypted: @convention(c) (Handle) -> Int32
    let path: @convention(c) (Handle) -> UnsafePointer<CChar>?
    let pathUTF8: @convention(c) (Handle) -> UnsafePointer<CChar>?
    let size: @convention(c) (Handle) -> Int64
    let sizeIsSet: @convention(c) (Handle) -> Int32
    let fileType: @convention(c) (Handle) -> UInt32
    let mode: @convention(c) (Handle) -> UInt32
    let isEncrypted: @convention(c) (Handle) -> Int32

    private init?() {
        guard let library = dlopen("/usr/lib/libarchive.2.dylib", RTLD_NOW) else { return nil }
        func symbol<T>(_ name: String) -> T { unsafeBitCast(dlsym(library, name)!, to: T.self) }
        new = symbol("archive_read_new")
        free = symbol("archive_read_free")
        enable = ["filter_gzip", "filter_bzip2", "filter_xz", "filter_lzma", "filter_zstd", "filter_compress",
                  "format_zip", "format_7zip", "format_rar", "format_rar5", "format_tar", "format_cpio", "format_lha", "format_cab", "format_raw"]
            .map { symbol("archive_read_support_" + $0) }
        setSeek = symbol("archive_read_set_seek_callback")
        open = symbol("archive_read_open2")
        nextHeader = symbol("archive_read_next_header")
        format = symbol("archive_format")
        filterCount = symbol("archive_filter_count")
        hasEncrypted = symbol("archive_read_has_encrypted_entries")
        path = symbol("archive_entry_pathname")
        pathUTF8 = symbol("archive_entry_pathname_utf8")
        size = symbol("archive_entry_size")
        sizeIsSet = symbol("archive_entry_size_is_set")
        fileType = symbol("archive_entry_filetype")
        mode = symbol("archive_entry_mode")
        isEncrypted = symbol("archive_entry_is_encrypted")
    }
}

private final class Source {
    static let block = 1 << 17

    let fd: Int32
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: Source.block, alignment: 16)
    let deadline = DispatchTime.now().uptimeNanoseconds + UInt64(ArchiveListing.timeLimit * 1_000_000_000)
    var expired = false

    init(fd: Int32) { self.fd = fd }
    deinit { buffer.deallocate() }
}

private let readBlock: ReadCallback = { _, data, out in
    let source = Unmanaged<Source>.fromOpaque(data!).takeUnretainedValue()
    guard DispatchTime.now().uptimeNanoseconds < source.deadline else {
        source.expired = true
        return -1
    }
    out!.pointee = UnsafeRawPointer(source.buffer)
    return read(source.fd, source.buffer, Source.block)
}

private let skipBlock: SkipCallback = { _, data, request in
    let source = Unmanaged<Source>.fromOpaque(data!).takeUnretainedValue()
    return lseek(source.fd, request, SEEK_CUR) < 0 ? 0 : request
}

private let seekBlock: SeekCallback = { _, data, offset, whence in
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
        guard let lib = Library.shared else { return nil }
        let fd = open(url.path, O_RDONLY)
        guard fd >= 0 else { return nil }
        defer { close(fd) }
        let source = Unmanaged.passRetained(Source(fd: fd))
        defer { source.release() }
        guard let archive = lib.new() else { return nil }
        defer { _ = lib.free(archive) }
        for enable in lib.enable { _ = enable(archive) }
        _ = lib.setSeek(archive, seekBlock)
        guard lib.open(archive, source.toOpaque(), nil, readBlock, skipBlock, nil) == 0 else { return nil }

        func bytes(_ pointer: UnsafePointer<CChar>?) -> [UInt8]? {
            guard let pointer else { return nil }
            return Array(UnsafeBufferPointer(start: UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self), count: min(strlen(pointer), 1 << 16)))
        }

        var listing = ArchiveListing()
        var legacy: [(index: Int, name: [UInt8])] = []
        var entry: Handle?
        while true {
            let result = lib.nextHeader(archive, &entry)
            if result == 1 { break }
            guard result == 0 || result == -20, let entry else {
                if source.takeUnretainedValue().expired { listing.isCut = true } else { listing.isDamaged = true }
                break
            }
            var path = ""
            var legacyName: [UInt8]?
            if let name = bytes(lib.pathUTF8(entry)) {
                path = String(decoding: name, as: UTF8.self)
            } else if let name = bytes(lib.path(entry)) {
                if let text = String(bytes: name, encoding: .utf8) { path = text } else { legacyName = Array(name.prefix(nameLimit)) }
            }
            if legacyName == nil, path.isEmpty || isJunk(path) { continue }
            if listing.items.count == maxItems {
                listing.isCut = true
                break
            }
            if let legacyName { legacy.append((listing.items.count, legacyName)) }
            let type = lib.fileType(entry)
            listing.items.append(Item(
                path: String(path.prefix(nameLimit)),
                size: lib.sizeIsSet(entry) != 0 ? min(max(lib.size(entry), 0), 1 << 50) : 0,
                isFolder: type == 0o040000,
                isExecutable: type == 0o100000 && lib.mode(entry) & 0o111 != 0
            ))
            if lib.isEncrypted(entry) != 0 { listing.isEncrypted = true }
        }

        let format = lib.format(archive)
        guard format != 0, format != rawFormat || lib.filterCount(archive) > 1 else { return nil }
        if lib.hasEncrypted(archive) == 1 {
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
