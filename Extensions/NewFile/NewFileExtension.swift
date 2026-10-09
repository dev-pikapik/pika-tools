import AppKit
import FinderSync

final class NewFileExtension: FIFinderSync {
    override init() {
        super.init()
        Folders.watch()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForContainer || menuKind == .contextualMenuForItems else { return nil }
        let menu = NSMenu()
        let item = menu.addItem(withTitle: NSLocalizedString("New File", comment: ""), action: #selector(newFile(_:)), keyEquivalent: "")
        item.tag = menuKind == .contextualMenuForItems ? 1 : 0
        return menu
    }

    @objc func newFile(_ sender: AnyObject?) {
        guard let folder = targetFolder(forItems: (sender as? NSMenuItem)?.tag == 1),
              let scheme = Bundle.main.object(forInfoDictionaryKey: "PikaToolsURLScheme") as? String
        else { return }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-._~")
        guard let dir = folder.path.addingPercentEncoding(withAllowedCharacters: allowed),
              let url = URL(string: "\(scheme)://new-file?dir=\(dir)")
        else { return }
        NSWorkspace.shared.open(url)
    }

    private func targetFolder(forItems: Bool) -> URL? {
        let controller = FIFinderSyncController.default()
        guard forItems, let item = controller.selectedItemURLs()?.first else { return controller.targetedURL() }
        let values = try? item.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey])
        let isFolder = values?.isDirectory ?? item.hasDirectoryPath
        return isFolder && values?.isPackage != true ? item : item.deletingLastPathComponent()
    }
}
