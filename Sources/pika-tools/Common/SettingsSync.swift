import AppKit
import UniformTypeIdentifiers

enum SettingsBackup {
    static var snapshot: [String: Any] {
        SettingsFile.filter(UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "") ?? [:])
    }

    static func apply(_ settings: [String: Any]) {
        let defaults = UserDefaults.standard
        for key in SettingsFile.keys {
            if let value = settings[key] {
                defaults.set(value, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
        ToolRegistry.shared.tools.forEach { $0.load() }
        KeepAwake.shared.load()
        let checks = defaults.object(forKey: "check-updates") as? Bool ?? true
        MainActor.assumeIsolated { Updater.shared.checksAutomatically = checks }
        Language.shared.load()
        Appearance.saved.apply()
        LoginItem.shared.restore()
    }

    static func export() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "pika-tools settings.json"
        run(panel) { url in
            let file = SettingsFile(settings: snapshot, modified: .now, device: SettingsSync.shared.device)
            do {
                try file.data().write(to: url, options: .atomic)
            } catch {
                SettingsSync.shared.alert = .init(title: String(localized: "The settings couldn’t be saved"), message: error.localizedDescription)
            }
        }
    }

    static func chooseImport() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        run(panel) { url in
            let data = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int).flatMap { size in
                size <= SettingsFile.maxSize ? try? Data(contentsOf: url) : nil
            }
            guard let data, let file = SettingsFile(data: data) else {
                SettingsSync.shared.alert = .init(
                    title: String(localized: "This file can’t be imported"),
                    message: String(localized: "It isn’t a pika-tools settings file, or it’s damaged.")
                )
                return
            }
            SettingsSync.shared.pendingImport = .init(name: url.lastPathComponent, file: file)
        }
    }

    private static func run(_ panel: NSSavePanel, _ done: @escaping (URL) -> Void) {
        let handler = { (response: NSApplication.ModalResponse) in
            if response == .OK, let url = panel.url { done(url) }
        }
        if let window = SettingsWindow.window {
            panel.beginSheetModal(for: window, completionHandler: handler)
        } else {
            handler(panel.runModal())
        }
    }
}

@Observable
final class SettingsSync {
    enum State: Equatable {
        case off, synced(Date), noDrive, noAccess, failed(String)
    }

    struct Alert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    struct Import: Identifiable {
        let id = UUID()
        let name: String
        let file: SettingsFile
    }

    static let shared = SettingsSync()
    static let drive = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs")
    static let folder = drive.appendingPathComponent("pika-tools")
    static let file = folder.appendingPathComponent("settings.json")

    private static let enabledKey = "settings-sync"
    private static let modifiedKey = "settings-sync-modified"
    private static let deviceKey = "settings-sync-device"

    private(set) var state = State.off
    var alert: Alert?
    var pendingImport: Import?

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            if isEnabled { modified = .distantPast }
            refresh()
        }
    }

    let device: String

    @ObservationIgnored private var modified: Date {
        get { Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: Self.modifiedKey)) }
        set { UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: Self.modifiedKey) }
    }
    @ObservationIgnored private var last: [String: Any] = [:]
    @ObservationIgnored private var applying = false
    @ObservationIgnored private var pending: DispatchWorkItem?
    @ObservationIgnored private var watcher: DispatchSourceFileSystemObject?

    private init() {
        let defaults = UserDefaults.standard
        if let device = defaults.string(forKey: Self.deviceKey) {
            self.device = device
        } else {
            device = UUID().uuidString
            defaults.set(device, forKey: Self.deviceKey)
        }
        isEnabled = defaults.bool(forKey: Self.enabledKey)
        last = SettingsBackup.snapshot
        let center = NotificationCenter.default
        center.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { _ in
            SettingsSync.shared.settingsChanged()
        }
        center.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            let sync = SettingsSync.shared
            switch sync.state {
            case .noDrive, .noAccess, .failed: sync.refresh()
            default: break
            }
        }
    }

    func confirmImport(_ item: Import) {
        pendingImport = nil
        apply(item.file.settings)
        settingsChanged()
    }

    func refresh() {
        stopWatching()
        last = SettingsBackup.snapshot
        guard isEnabled else { return state = .off }
        let manager = FileManager.default
        guard manager.fileExists(atPath: Self.drive.path) else { return state = .noDrive }
        do {
            try manager.createDirectory(at: Self.folder, withIntermediateDirectories: true)
            _ = try manager.contentsOfDirectory(atPath: Self.folder.path)
        } catch {
            return state = Self.isDenied(error) ? .noAccess : .failed(error.localizedDescription)
        }
        watch()
        sync()
    }

    private func settingsChanged() {
        guard !applying else { return }
        let current = SettingsBackup.snapshot
        guard !SettingsFile.same(current, last) else { return }
        last = current
        guard isEnabled else { return }
        modified = Self.stamp()
        guard case .synced = state else { return }
        pending?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.sync() }
        pending = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
    }

    private func sync() {
        guard isEnabled else { return }
        let remote = read()
        switch SettingsFile.merge(local: modified, remote: remote, device: device) {
        case .apply:
            guard let remote else { return }
            apply(remote.settings)
            last = SettingsBackup.snapshot
            modified = remote.modified
            state = .synced(.now)
        case .upload:
            if modified == .distantPast { modified = Self.stamp() }
            write(SettingsFile(settings: last, modified: modified, device: device))
        case .none:
            state = .synced(.now)
        }
    }

    private func apply(_ settings: [String: Any]) {
        applying = true
        SettingsBackup.apply(settings)
        applying = false
    }

    private func read() -> SettingsFile? {
        var result: SettingsFile?
        var error: NSError?
        NSFileCoordinator().coordinate(readingItemAt: Self.file, options: [], error: &error) { url in
            guard let size = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? Int,
                  size <= SettingsFile.maxSize,
                  let data = try? Data(contentsOf: url)
            else { return }
            result = SettingsFile(data: data)
        }
        return result
    }

    private func write(_ file: SettingsFile) {
        var failure: Error?
        var error: NSError?
        NSFileCoordinator().coordinate(writingItemAt: Self.file, options: .forReplacing, error: &error) { url in
            do {
                try file.data().write(to: url, options: .atomic)
            } catch {
                failure = error
            }
        }
        if let failure = failure ?? error {
            state = Self.isDenied(failure) ? .noAccess : .failed(failure.localizedDescription)
        } else {
            state = .synced(.now)
        }
    }

    private func watch() {
        let descriptor = open(Self.folder.path, O_EVTONLY)
        guard descriptor >= 0 else { return }
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: [.write, .rename, .delete], queue: .main)
        source.setEventHandler { [weak self] in
            self?.pending?.cancel()
            let work = DispatchWorkItem { self?.sync() }
            self?.pending = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
        }
        source.setCancelHandler { close(descriptor) }
        source.resume()
        watcher = source
    }

    private func stopWatching() {
        pending?.cancel()
        pending = nil
        watcher?.cancel()
        watcher = nil
    }

    private static func stamp() -> Date {
        Date(timeIntervalSince1970: (Date.now.timeIntervalSince1970 * 1000).rounded() / 1000)
    }

    private static func isDenied(_ error: Error) -> Bool {
        let error = error as NSError
        let posix = (error.userInfo[NSUnderlyingErrorKey] as? NSError).map { $0.domain == NSPOSIXErrorDomain ? $0.code : 0 } ?? 0
        return error.code == NSFileReadNoPermissionError || error.code == NSFileWriteNoPermissionError
            || posix == Int(EPERM) || posix == Int(EACCES)
    }

    func openSettings() {
        let pane = state == .noDrive ? "com.apple.preferences.AppleIDPrefPane" : "com.apple.preference.security?Privacy_FilesAndFolders"
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:\(pane)")!)
    }
}
