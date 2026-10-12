import AppKit
import SwiftUI

@Observable
final class TrashWatchTool: Tool {
    static let shared = TrashWatchTool()

    let id = "uninstaller-trash-watch"
    let icon = "trash"
    var title: String { String(localized: "Offer to clean up when an app goes to the Trash") }
    var tab: SettingsTab { .uninstaller }
    var needs: [Permission] { [.fullDisk] }
    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var watcher: TrashWatcher?

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(TrashWatchSettings(tool: self))
    }

    func refresh() {
        watcher?.stop()
        watcher = nil
        if isEnabled, Permissions.shared.fileAccess {
            watcher = TrashWatcher { urls in MainActor.assumeIsolated { UninstallerModel.shared.offer(urls) } }
        }
        isActive = watcher != nil
    }
}

private final class TrashWatcher {
    private let folder = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
    private let found: ([URL]) -> Void
    private var source: DispatchSourceFileSystemObject?
    private var pending: DispatchWorkItem?
    private var seen: Set<String> = []

    init?(found: @escaping ([URL]) -> Void) {
        self.found = found
        let descriptor = open(folder.path, O_EVTONLY)
        guard descriptor >= 0 else { return nil }
        seen = Set(apps())
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: [.write, .rename, .delete], queue: .main)
        source.setEventHandler { [weak self] in
            self?.pending?.cancel()
            let work = DispatchWorkItem { self?.check() }
            self?.pending = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
        }
        source.setCancelHandler { close(descriptor) }
        source.resume()
        self.source = source
    }

    func stop() {
        pending?.cancel()
        pending = nil
        source?.cancel()
        source = nil
    }

    private func apps() -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).filter { $0.hasSuffix(".app") }
    }

    private func check() {
        let now = Set(apps())
        let fresh = now.subtracting(seen)
        seen = now
        if !fresh.isEmpty { found(fresh.sorted().map { folder.appendingPathComponent($0) }) }
    }
}

private struct TrashWatchSettings: View {
    @Bindable var tool: TrashWatchTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { TrashWatchArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Nothing is removed until you choose"),
            isOn: $tool.isEnabled
        )
    }
}
