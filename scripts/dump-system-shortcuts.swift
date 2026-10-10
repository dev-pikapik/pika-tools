import AppKit

@main
struct DumpSystemShortcuts {
    static func main() throws {
        let catalog = SystemShortcutCatalog.load()
        let rows: [[String: Any]] = catalog.map { entry in
            ["id": Int(entry.id), "name": entry.name, "section": entry.sectionName,
             "keys": entry.text ?? "", "keyCode": Int(entry.key), "modifiers": entry.modifiers,
             "enabled": entry.enabled, "backgroundSupported": entry.supportsBackground,
             "emergency": entry.emergency, "preview": entry.kind.rawValue]
        }
        let listeners: [[String: Any]] = KeyboardListener.load().map { ["process": Int($0.id), "name": $0.name, "changesKeys": $0.changesKeys] }
        let data = try JSONSerialization.data(withJSONObject: ["systemShortcuts": rows, "otherKeyboardListeners": listeners], options: [.prettyPrinted, .sortedKeys])
        try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .atomic)
        print("saved", catalog.count, "system shortcuts")
    }
}
