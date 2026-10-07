import Foundation

struct SettingsFile {
    enum Action: Equatable {
        case apply, upload, none
    }

    static let app = "pika-tools"
    static let maxSize = 2_000_000
    static let keys: Set<String> = [
        "appearance", "AppleLanguages", "open-at-login", "check-updates",
        "ctrl-keys", "ctrl-keys-excluded", "command-keys-quit", "command-keys-close", "input-switch", "key-repeat",
        "linear-pointer", "linear-pointer-speed", "wheel-lines", "wheel-lines-count", "wheel-lines-mode", "wheel-lines-pixels",
        "wheel-direction", "wheel-direction-natural",
        "side-buttons", "side-buttons-swap",
        "quit-on-close", "quit-on-close-excluded", "dock-hide", "window-zoom", "window-zoom-excluded", "new-file", "compress",
        "finder-open", "finder-cut",
        "keep-awake-mode", "keep-awake-duration",
        "keep-awake-display", "keep-awake-lid", "keep-awake-battery",
    ]

    var settings: [String: Any]
    var modified: Date
    var device: String

    init(settings: [String: Any], modified: Date, device: String) {
        self.settings = Self.filter(settings)
        self.modified = modified
        self.device = device
    }

    init?(data: Data) {
        guard data.count <= Self.maxSize,
              let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              root["app"] as? String == Self.app,
              let settings = root["settings"] as? [String: Any]
        else { return nil }
        self.settings = Self.filter(settings)
        modified = Date(timeIntervalSince1970: (root["modified"] as? NSNumber)?.doubleValue ?? 0)
        device = root["device"] as? String ?? ""
    }

    func data() throws -> Data {
        let root: [String: Any] = [
            "app": Self.app,
            "version": 1,
            "modified": modified.timeIntervalSince1970,
            "device": device,
            "settings": settings,
        ]
        return try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
    }

    static func filter(_ values: [String: Any]) -> [String: Any] {
        values.filter { keys.contains($0.key) && isValid($0.value) }
    }

    static func isValid(_ value: Any) -> Bool {
        if value is String || value is NSNumber { return true }
        guard let list = value as? [Any] else { return false }
        return list.allSatisfy { $0 is String }
    }

    static func merge(local: Date, remote: SettingsFile?, device: String) -> Action {
        guard let remote else { return .upload }
        if remote.modified == local { return .none }
        if remote.device == device { return .upload }
        return remote.modified > local ? .apply : .upload
    }

    static func same(_ a: [String: Any], _ b: [String: Any]) -> Bool {
        NSDictionary(dictionary: a).isEqual(to: b)
    }
}
