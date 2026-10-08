import Foundation
import SQLite3

struct PermissionGrant: Equatable {
    let service: String
    let client: String
    let isPath: Bool
    let modified: Date
}

struct PermissionKind: Equatable {
    let name: String
    let symbol: String
    let pane: String
}

struct LeftoverApp: Identifiable, Equatable {
    let client: String
    let isPath: Bool
    let kinds: [PermissionKind]
    let modified: Date

    var id: String { client }
    var name: String { LeftoverPermissions.name(client, isPath: isPath) }
}

enum LeftoverPermissions {
    enum Place { case installed, offline, gone }

    struct Lookup {
        var apps: (String) -> [String]
        var exists: (String) -> Bool
        var mounted: (String) -> Bool
        var home = NSHomeDirectory()
    }

    static let systemDatabase = "/Library/Application Support/com.apple.TCC/TCC.db"
    static var userDatabase: String { NSHomeDirectory() + "/Library/Application Support/com.apple.TCC/TCC.db" }

    static func read(_ path: String) -> [PermissionGrant]? {
        var db: OpaquePointer?
        defer { sqlite3_close(db) }
        guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { return nil }
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        let query = "SELECT service, client, client_type, last_modified FROM access"
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return nil }
        var grants: [PermissionGrant] = []
        var step = sqlite3_step(statement)
        while step == SQLITE_ROW {
            if let service = sqlite3_column_text(statement, 0), let client = sqlite3_column_text(statement, 1) {
                grants.append(PermissionGrant(
                    service: String(cString: service),
                    client: String(cString: client),
                    isPath: sqlite3_column_int(statement, 2) == 1,
                    modified: Date(timeIntervalSince1970: Double(sqlite3_column_int64(statement, 3)))
                ))
            }
            step = sqlite3_step(statement)
        }
        return step == SQLITE_DONE ? grants : nil
    }

    static func leftovers(_ grants: [PermissionGrant], _ lookup: Lookup) -> [LeftoverApp] {
        let clients = Dictionary(grouping: grants.filter { !isSystem($0.client, isPath: $0.isPath) }) { $0.client }
        return clients.values.compactMap { grants -> LeftoverApp? in
            let first = grants[0]
            guard place(first.client, isPath: first.isPath, lookup) == .gone else { return nil }
            var kinds: [PermissionKind] = []
            for service in Set(grants.map(\.service)).sorted(by: { order($0) < order($1) }) where !kinds.contains(kind(service)) {
                kinds.append(kind(service))
            }
            return LeftoverApp(client: first.client, isPath: first.isPath, kinds: kinds, modified: grants.map(\.modified).max()!)
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    static func isSystem(_ client: String, isPath: Bool) -> Bool {
        guard isPath else { return client.hasPrefix("com.apple.") }
        if client.hasPrefix("/usr/local/") { return false }
        return ["/System/", "/usr/", "/bin/", "/sbin/", "/Library/Apple/", "/private/var/", "/Applications/Xcode"].contains { client.hasPrefix($0) }
    }

    static func place(_ client: String, isPath: Bool, _ lookup: Lookup) -> Place {
        func offline(_ path: String) -> Bool { volume(path).map { !lookup.mounted($0) } ?? false }
        if isPath {
            if lookup.exists(client) { return .installed }
            return offline(client) ? .offline : .gone
        }
        let paths = lookup.apps(client)
        if paths.contains(where: { lookup.exists($0) && !inTrash($0) }) { return .installed }
        let helpers = ["/Library/PrivilegedHelperTools/\(client)", "/Library/LaunchDaemons/\(client).plist", "/Library/LaunchAgents/\(client).plist", "\(lookup.home)/Library/LaunchAgents/\(client).plist"]
        if helpers.contains(where: lookup.exists) { return .installed }
        return paths.contains(where: offline) ? .offline : .gone
    }

    static func volume(_ path: String) -> String? {
        let parts = path.split(separator: "/")
        guard parts.count >= 2, parts[0] == "Volumes" else { return nil }
        return "/Volumes/\(parts[1])"
    }

    static func inTrash(_ path: String) -> Bool {
        path.contains("/.Trash/") || path.contains("/.Trashes/")
    }

    static func name(_ client: String, isPath: Bool) -> String {
        if isPath {
            let parts = client.split(separator: "/")
            let app = parts.last { $0.hasSuffix(".app") }
            return String(app?.dropLast(4) ?? parts.last ?? Substring(client))
        }
        var parts = client.split(separator: ".").map(String.init).filter { !["mac", "macos", "osx"].contains($0.lowercased()) }
        guard var last = parts.popLast() else { return client }
        for suffix in ["-macos", "-mac", "-mas", "-osx"] where last.lowercased().hasSuffix(suffix) && last.count > suffix.count {
            last.removeLast(suffix.count)
        }
        if ["app", "browser", "chat", "client", "desktop", "main", "settings"].contains(last.lowercased()), parts.count > 1 {
            last = parts[parts.count - 1] + " " + last
        }
        return last
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    private static let services: [(ids: [String], name: () -> String, symbol: String, pane: String)] = [
        (["Accessibility", "PostEvent"], { String(localized: "Accessibility") }, "accessibility", "Privacy_Accessibility"),
        (["ScreenCapture", "AudioCapture"], { String(localized: "Screen Recording") }, "rectangle.dashed.badge.record", "Privacy_ScreenCapture"),
        (["ListenEvent"], { String(localized: "Input Monitoring") }, "keyboard.badge.eye", "Privacy_ListenEvent"),
        (["SystemPolicyAllFiles", "EndpointSecurityClient"], { String(localized: "Full Disk Access") }, "internaldrive", "Privacy_AllFiles"),
        (["Camera"], { String(localized: "Camera") }, "camera", "Privacy_Camera"),
        (["Microphone"], { String(localized: "Microphone") }, "mic", "Privacy_Microphone"),
        (["AppleEvents"], { String(localized: "Automation") }, "gearshape.2", "Privacy_Automation"),
        (
            ["SystemPolicyDesktopFolder", "SystemPolicyDocumentsFolder", "SystemPolicyDownloadsFolder", "SystemPolicyNetworkVolumes", "SystemPolicyRemovableVolumes", "SystemPolicySysAdminFiles", "FileProviderDomain", "FileProviderPresence"],
            { String(localized: "Files and Folders") }, "folder", "Privacy_FilesAndFolders"
        ),
        (["SystemPolicyAppBundles"], { String(localized: "App Management") }, "app.badge.checkmark", "Privacy_AppBundles"),
        (["DeveloperTool"], { String(localized: "Developer Tools") }, "hammer", "Privacy_DevTools"),
        (["AddressBook"], { String(localized: "Contacts") }, "person.crop.circle", "Privacy_Contacts"),
        (["Calendar"], { String(localized: "Calendars") }, "calendar", "Privacy_Calendars"),
        (["Photos", "PhotosAdd"], { String(localized: "Photos") }, "photo", "Privacy_Photos"),
        (["BluetoothAlways"], { String(localized: "Bluetooth") }, "dot.radiowaves.left.and.right", "Privacy_Bluetooth"),
        (["Ubiquity"], { String(localized: "iCloud Drive") }, "icloud", "Privacy"),
    ]

    private static func order(_ service: String) -> Int {
        services.firstIndex { $0.ids.contains(service.replacingOccurrences(of: "kTCCService", with: "")) } ?? services.count
    }

    static func kind(_ service: String) -> PermissionKind {
        let index = order(service)
        guard index < services.count else { return PermissionKind(name: String(localized: "Other"), symbol: "lock", pane: "Privacy") }
        let item = services[index]
        return PermissionKind(name: item.name(), symbol: item.symbol, pane: item.pane)
    }
}
