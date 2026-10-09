import AppKit
import FinderSync

enum Folders {
    private static var sent = Date.distantPast

    static func watch() {
        resend()
        _ = observers
    }

    private static let observers: Void = {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { note in
            guard let volume = note.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL else { return }
            FIFinderSyncController.default().directoryURLs.insert(volume)
        }
        center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { note in
            guard (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier == "com.apple.finder" else { return }
            resendIfLost()
        }
        center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in resendIfLost() }
    }()

    private static func resend() {
        sent = .now
        let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: .skipHiddenVolumes) ?? []
        let controller = FIFinderSyncController.default()
        controller.directoryURLs = []
        controller.directoryURLs = Set(volumes + [URL(fileURLWithPath: "/")])
    }

    private static func resendIfLost() {
        guard sent.timeIntervalSinceNow < -60 else { return }
        let map = UserDefaults.standard.dictionary(forKey: "com.apple.finder.SyncExtensions")?["dirMap"] as? [String: [String]]
        if FIFinderSyncController.default().directoryURLs.isEmpty || map?[Bundle.main.bundleIdentifier ?? ""]?.isEmpty ?? true { resend() }
    }
}
