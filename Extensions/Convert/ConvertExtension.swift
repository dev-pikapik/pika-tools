import AppKit
import FinderSync

final class ConvertExtension: FIFinderSync {
    override init() {
        super.init()
        Folders.watch()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems else { return nil }
        let files = FIFinderSyncController.default().selectedItemURLs() ?? []
        let targets = ConvertFormats.targets(for: files)
        guard !targets.isEmpty else { return nil }
        let submenu = NSMenu()
        let video = files.contains { ConvertFormats.videos.contains($0.pathExtension.lowercased()) }
        for target in targets {
            let title = target == "m4a" && video ? NSLocalizedString("M4A (Audio Only)", comment: "") : target.uppercased()
            submenu.addItem(withTitle: title, action: #selector(convert(_:)), keyEquivalent: "").tag = ConvertFormats.all.firstIndex(of: target) ?? 0
        }
        let menu = NSMenu()
        menu.addItem(withTitle: NSLocalizedString("Convert To", comment: ""), action: nil, keyEquivalent: "").submenu = submenu
        return menu
    }

    @objc func convert(_ sender: AnyObject?) {
        guard let index = (sender as? NSMenuItem)?.tag, ConvertFormats.all.indices.contains(index),
              let scheme = Bundle.main.object(forInfoDictionaryKey: "PikaToolsURLScheme") as? String
        else { return }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-._~")
        let paths = (FIFinderSyncController.default().selectedItemURLs() ?? []).compactMap { $0.path.addingPercentEncoding(withAllowedCharacters: allowed) }
        guard !paths.isEmpty, let url = URL(string: "\(scheme)://convert?to=\(ConvertFormats.all[index])&" + paths.map { "path=" + $0 }.joined(separator: "&"))
        else { return }
        NSWorkspace.shared.open(url)
    }
}
