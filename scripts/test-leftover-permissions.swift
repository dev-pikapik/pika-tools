import Foundation
import SQLite3

@main
enum TestLeftoverPermissions {
    static let schema = """
        CREATE TABLE access (service TEXT NOT NULL, client TEXT NOT NULL, client_type INTEGER NOT NULL, auth_value INTEGER NOT NULL, \
        auth_reason INTEGER NOT NULL, auth_version INTEGER NOT NULL, csreq BLOB, policy_id INTEGER, indirect_object_identifier_type INTEGER, \
        indirect_object_identifier TEXT NOT NULL DEFAULT 'UNUSED', indirect_object_code_identity BLOB, flags INTEGER, \
        last_modified INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER)), pid INTEGER, pid_version INTEGER, \
        boot_uuid TEXT NOT NULL DEFAULT 'UNUSED', last_reminded INTEGER NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER)), \
        one_time_reprompt_eligible INTEGER, reminder_count INTEGER NOT NULL DEFAULT 0, \
        PRIMARY KEY (service, client, client_type, indirect_object_identifier))
        """

    static let rows: [(String, String, Int, Int)] = [
        ("kTCCServiceAccessibility", "com.example.gone", 0, 100),
        ("kTCCServicePostEvent", "com.example.gone", 0, 300),
        ("kTCCServiceCamera", "com.example.gone", 0, 200),
        ("kTCCServiceSomethingNew", "com.example.gone", 0, 50),
        ("kTCCServiceScreenCapture", "com.example.here", 0, 100),
        ("kTCCServiceAccessibility", "com.apple.Terminal", 0, 100),
        ("kTCCServiceListenEvent", "/usr/local/bin/gone-tool", 1, 400),
        ("kTCCServiceListenEvent", "/usr/bin/ssh", 1, 100),
        ("kTCCServiceAccessibility", "/Applications/Old.app/Contents/MacOS/old", 1, 100),
        ("kTCCServiceScreenCapture", "com.example.trashed", 0, 100),
        ("kTCCServiceAccessibility", "com.example.unplugged", 0, 100),
        ("kTCCServiceAccessibility", "/Volumes/Backup/tool", 1, 100),
        ("kTCCServiceAccessibility", "/Volumes/Data/tool", 1, 100),
        ("kTCCServiceAccessibility", "com.example.daemon", 0, 100),
        ("kTCCServiceSystemPolicyDesktopFolder", "com.lwouis.alt-tab-macos", 0, 100),
        ("kTCCServiceSystemPolicyDownloadsFolder", "com.lwouis.alt-tab-macos", 0, 100),
    ]

    static func fixture() -> String {
        let path = NSTemporaryDirectory() + "leftover-permissions-\(getpid()).db"
        try? FileManager.default.removeItem(atPath: path)
        var db: OpaquePointer?
        precondition(sqlite3_open(path, &db) == SQLITE_OK)
        precondition(sqlite3_exec(db, schema, nil, nil, nil) == SQLITE_OK)
        for (service, client, type, modified) in rows {
            let sql = "INSERT INTO access (service, client, client_type, auth_value, auth_reason, auth_version, last_modified) VALUES ('\(service)', '\(client)', \(type), 2, 3, 1, \(modified))"
            precondition(sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK)
        }
        sqlite3_close(db)
        return path
    }

    static func main() {
        let path = fixture()
        defer { try? FileManager.default.removeItem(atPath: path) }
        let grants = LeftoverPermissions.read(path)!
        precondition(grants.count == rows.count)
        precondition(grants.contains(PermissionGrant(service: "kTCCServiceListenEvent", client: "/usr/local/bin/gone-tool", isPath: true, modified: Date(timeIntervalSince1970: 400))))
        precondition(LeftoverPermissions.read(path + ".missing") == nil)
        let notDatabase = NSTemporaryDirectory() + "leftover-not-a-db-\(getpid())"
        try! "hello".write(toFile: notDatabase, atomically: true, encoding: .utf8)
        precondition(LeftoverPermissions.read(notDatabase) == nil)
        try? FileManager.default.removeItem(atPath: notDatabase)

        let apps: [String: [String]] = [
            "com.example.here": ["/Applications/Here.app"],
            "com.example.trashed": ["/Users/me/.Trash/Trashed.app"],
            "com.example.unplugged": ["/Volumes/Backup/Unplugged.app"],
        ]
        let files: Set = ["/Applications/Here.app", "/Users/me/.Trash/Trashed.app", "/usr/bin/ssh", "/Library/LaunchDaemons/com.example.daemon.plist"]
        let lookup = LeftoverPermissions.Lookup(
            apps: { apps[$0] ?? [] },
            exists: { files.contains($0) },
            mounted: { $0 == "/Volumes/Data" },
            home: "/Users/me"
        )
        let found = LeftoverPermissions.leftovers(grants, lookup)
        precondition(found.map(\.client) == [
            "com.lwouis.alt-tab-macos", "com.example.gone", "/usr/local/bin/gone-tool", "/Applications/Old.app/Contents/MacOS/old", "/Volumes/Data/tool", "com.example.trashed",
        ], "\(found.map(\.client))")
        let gone = found.first { $0.client == "com.example.gone" }!
        precondition(gone.kinds.map(\.name) == ["Accessibility", "Camera", "Other"], "\(gone.kinds.map(\.name))")
        precondition(gone.kinds[0].pane == "Privacy_Accessibility" && gone.kinds[1].symbol == "camera")
        precondition(gone.modified == Date(timeIntervalSince1970: 300))
        precondition(found.first { $0.client.hasPrefix("com.lwouis") }!.kinds.map(\.name) == ["Files and Folders"])
        precondition(found.allSatisfy { $0.isPath == $0.client.hasPrefix("/") })

        precondition(LeftoverPermissions.place("com.example.here", isPath: false, lookup) == .installed)
        precondition(LeftoverPermissions.place("com.example.unplugged", isPath: false, lookup) == .offline)
        precondition(LeftoverPermissions.place("/Volumes/Backup/tool", isPath: true, lookup) == .offline)
        precondition(LeftoverPermissions.place("/Volumes/Data/tool", isPath: true, lookup) == .gone)
        precondition(LeftoverPermissions.place("com.example.daemon", isPath: false, lookup) == .installed)
        precondition(LeftoverPermissions.place("com.example.trashed", isPath: false, lookup) == .gone)

        precondition(LeftoverPermissions.isSystem("com.apple.Safari", isPath: false))
        precondition(!LeftoverPermissions.isSystem("org.pqrs.Karabiner-Core-Service", isPath: false))
        precondition(LeftoverPermissions.isSystem("/usr/libexec/sshd-keygen-wrapper", isPath: true))
        precondition(!LeftoverPermissions.isSystem("/usr/local/bin/tool", isPath: true))
        precondition(!LeftoverPermissions.isSystem("/opt/homebrew/Cellar/node/24.19.0/bin/node", isPath: true))

        let names = [
            "com.lwouis.alt-tab-macos": "Alt Tab",
            "app.monitorcontrol.MonitorControl": "MonitorControl",
            "org.pqrs.Karabiner-Core-Service": "Karabiner Core Service",
            "com.openai.chat": "Openai Chat",
            "com.macpaw.CleanMyMac-mas": "CleanMyMac",
            "com.federicoterzi.espanso": "Espanso",
            "com.raycast.macos": "Raycast",
            "com.duckduckgo.macos.browser": "Duckduckgo Browser",
            "org.pqrs.Karabiner-Elements.Settings": "Karabiner Elements Settings",
            "com.browser": "Browser",
            "single": "Single",
        ]
        for (client, name) in names { precondition(LeftoverPermissions.name(client, isPath: false) == name, "\(client) → \(LeftoverPermissions.name(client, isPath: false))") }
        precondition(LeftoverPermissions.name("/Applications/Old.app/Contents/MacOS/old", isPath: true) == "Old")
        precondition(LeftoverPermissions.name("/opt/homebrew/bin/node", isPath: true) == "node")

        precondition(LeftoverPermissions.kind("kTCCServiceListenEvent").pane == "Privacy_ListenEvent")
        precondition(LeftoverPermissions.kind("kTCCServicePostEvent") == LeftoverPermissions.kind("kTCCServiceAccessibility"))
        print("leftover-permissions: ok")
    }
}
