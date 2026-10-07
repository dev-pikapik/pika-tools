import AppKit
import FinderSync

final class CompressExtension: FIFinderSync {
    private static let smaller: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "gif", "pdf", "mov", "mp4", "m4v", "wav", "aiff", "aif", "caf"]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems,
              (FIFinderSyncController.default().selectedItemURLs() ?? []).contains(where: { Self.smaller.contains($0.pathExtension.lowercased()) })
        else { return nil }
        let menu = NSMenu()
        menu.addItem(withTitle: NSLocalizedString("Make a Smaller Copy", comment: ""), action: #selector(compress(_:)), keyEquivalent: "")
        return menu
    }

    @objc func compress(_ sender: AnyObject?) {
        let files = (FIFinderSyncController.default().selectedItemURLs() ?? []).filter { Self.smaller.contains($0.pathExtension.lowercased()) }
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "PikaToolsURLScheme") as? String else { return }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-._~")
        let paths = files.compactMap { $0.path.addingPercentEncoding(withAllowedCharacters: allowed) }
        guard !paths.isEmpty, let url = URL(string: "\(scheme)://compress?" + paths.map { "path=" + $0 }.joined(separator: "&"))
        else { return }
        NSWorkspace.shared.open(url)
    }
}
