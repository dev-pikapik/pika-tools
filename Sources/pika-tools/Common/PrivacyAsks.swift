import Foundation

struct AskingApp: Identifiable, Equatable {
    let url: URL
    let name: String
    let keys: Set<String>

    var id: String { url.path }
}

enum PrivacyAsks {
    static let keys: [String: [String]] = [
        "Privacy_Camera": ["NSCameraUsageDescription"],
        "Privacy_Microphone": ["NSMicrophoneUsageDescription"],
        "Privacy_Automation": ["NSAppleEventsUsageDescription"],
        "Privacy_FilesAndFolders": [
            "NSDesktopFolderUsageDescription", "NSDocumentsFolderUsageDescription", "NSDownloadsFolderUsageDescription",
            "NSRemovableVolumesUsageDescription", "NSNetworkVolumesUsageDescription",
        ],
        "Privacy_Bluetooth": ["NSBluetoothAlwaysUsageDescription", "NSBluetoothPeripheralUsageDescription"],
    ]

    static let folders = [URL(fileURLWithPath: "/Applications")]

    static func scan(_ folders: [URL] = folders) -> [AskingApp] {
        let files = FileManager.default
        let contents = { (url: URL) in (try? files.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? [] }
        let bundles = folders.flatMap(contents).flatMap { $0.pathExtension == "app" ? [$0] : contents($0).filter { $0.pathExtension == "app" } }
        let all = Set(keys.values.joined())
        var seen = Set<String>()
        return bundles.compactMap { url -> AskingApp? in
            guard let info = NSDictionary(contentsOf: url.appendingPathComponent("Contents/Info.plist")) as? [String: Any],
                  seen.insert(url.resolvingSymlinksInPath().path).inserted
            else { return nil }
            let found = all.filter { info[$0] is String }
            return found.isEmpty ? nil : AskingApp(url: url, name: url.deletingPathExtension().lastPathComponent, keys: found)
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    static func apps(_ pane: String, in apps: [AskingApp]) -> [AskingApp]? {
        guard let wanted = keys[pane] else { return nil }
        return apps.filter { !$0.keys.isDisjoint(with: wanted) }
    }
}
