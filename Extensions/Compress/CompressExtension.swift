import AppKit
import FinderSync

final class CompressExtension: FIFinderSync {
    private static let smaller: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "pdf", "mov", "mp4", "m4v"]
    private static let images: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "gif", "bmp", "webp"]
    private static let videos: Set<String> = ["mov", "mp4", "m4v"]
    private static let sounds: Set<String> = ["wav", "aiff", "aif", "mp3", "m4a", "caf"]
    private static let formats: [(id: String, name: String, extensions: Set<String>)] = [
        ("jpeg", "JPEG", ["jpg", "jpeg"]), ("png", "PNG", ["png"]), ("heic", "HEIC", ["heic", "heif"]),
        ("tiff", "TIFF", ["tif", "tiff"]), ("pdf", "PDF", ["pdf"]), ("mp4", "MP4", ["mp4"]), ("mov", "MOV", ["mov"]),
        ("m4a", "M4A", ["m4a"]), ("wav", "WAV", ["wav"]), ("aiff", "AIFF", ["aiff", "aif"]),
    ]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems else { return nil }
        let files = FIFinderSyncController.default().selectedItemURLs() ?? []
        let menu = NSMenu()
        if files.contains(where: { Self.smaller.contains($0.pathExtension.lowercased()) }) {
            menu.addItem(withTitle: NSLocalizedString("Make a Smaller Copy", comment: ""), action: #selector(compress(_:)), keyEquivalent: "")
        }
        let targets = Self.targets(for: files)
        if !targets.isEmpty {
            let submenu = NSMenu()
            let video = files.contains { Self.videos.contains($0.pathExtension.lowercased()) }
            for index in targets {
                let format = Self.formats[index]
                let title = format.id == "m4a" && video ? NSLocalizedString("M4A (Audio Only)", comment: "") : format.name
                submenu.addItem(withTitle: title, action: #selector(convert(_:)), keyEquivalent: "").tag = index
            }
            menu.addItem(withTitle: NSLocalizedString("Convert To", comment: ""), action: nil, keyEquivalent: "").submenu = submenu
        }
        return menu.items.isEmpty ? nil : menu
    }

    @objc func compress(_ sender: AnyObject?) {
        let files = (FIFinderSyncController.default().selectedItemURLs() ?? []).filter { Self.smaller.contains($0.pathExtension.lowercased()) }
        open("compress", files: files)
    }

    @objc func convert(_ sender: AnyObject?) {
        guard let index = (sender as? NSMenuItem)?.tag, Self.formats.indices.contains(index) else { return }
        open("convert", query: "to=\(Self.formats[index].id)&", files: FIFinderSyncController.default().selectedItemURLs() ?? [])
    }

    private func open(_ action: String, query: String = "", files: [URL]) {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "PikaToolsURLScheme") as? String else { return }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-._~")
        let paths = files.compactMap { $0.path.addingPercentEncoding(withAllowedCharacters: allowed) }
        guard !paths.isEmpty, let url = URL(string: "\(scheme)://\(action)?\(query)" + paths.map { "path=" + $0 }.joined(separator: "&"))
        else { return }
        NSWorkspace.shared.open(url)
    }

    private static func targets(for files: [URL]) -> [Int] {
        let extensions = Set(files.map { $0.pathExtension.lowercased() })
        var allowed: Set<String>?
        for ext in extensions {
            let kind: Set<String> = images.contains(ext) ? ["jpeg", "png", "heic", "tiff", "pdf"]
                : videos.contains(ext) ? ["mp4", "mov", "m4a"]
                : sounds.contains(ext) ? ["m4a", "wav", "aiff"] : []
            allowed = allowed.map { $0.intersection(kind) } ?? kind
        }
        return formats.indices.filter { allowed?.contains(formats[$0].id) == true && !formats[$0].extensions.isSuperset(of: extensions) }
    }
}
