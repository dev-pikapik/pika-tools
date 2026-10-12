import AppKit
import FinderSync

final class ArchiveExtension: FIFinderSync {
    override init() {
        super.init()
        Folders.watch()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems,
              let files = FIFinderSyncController.default().selectedItemURLs(), !files.isEmpty
        else { return nil }
        let menu = NSMenu()
        if files.allSatisfy(Archive.isArchive) {
            menu.addItem(withTitle: NSLocalizedString("Extract", comment: ""), action: #selector(extract(_:)), keyEquivalent: "")
        } else if Set(files.map { $0.deletingLastPathComponent().path }).count == 1 {
            menu.addItem(withTitle: NSLocalizedString("Create Archive…", comment: ""), action: #selector(create(_:)), keyEquivalent: "")
        } else {
            return nil
        }
        return menu
    }

    @objc func extract(_ sender: AnyObject?) { send("extract") }
    @objc func create(_ sender: AnyObject?) { send("create") }

    private func send(_ action: String) {
        guard let scheme = Bundle.main.object(forInfoDictionaryKey: "PikaToolsURLScheme") as? String else { return }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-._~")
        let paths = (FIFinderSyncController.default().selectedItemURLs() ?? []).compactMap { $0.path.addingPercentEncoding(withAllowedCharacters: allowed) }
        guard !paths.isEmpty, let url = URL(string: "\(scheme)://archive?action=\(action)&" + paths.map { "path=" + $0 }.joined(separator: "&"))
        else { return }
        NSWorkspace.shared.open(url)
    }
}
