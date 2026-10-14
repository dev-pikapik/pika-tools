import Foundation

@main
enum TestPrivacyAsks {
    static func bundle(_ root: URL, _ path: String, _ info: [String: Any]?) {
        let contents = root.appendingPathComponent(path).appendingPathComponent("Contents")
        try! FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        if let info { precondition((info as NSDictionary).write(to: contents.appendingPathComponent("Info.plist"), atomically: true)) }
    }

    static func main() {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("privacy-asks-\(getpid())")
        try? FileManager.default.removeItem(at: root)
        defer { try? FileManager.default.removeItem(at: root) }
        let text = "Why"
        bundle(root, "Cam.app", ["NSCameraUsageDescription": text])
        bundle(root, "Sub/Mic.app", ["NSMicrophoneUsageDescription": text, "NSAppleEventsUsageDescription": text])
        bundle(root, "Plain.app", ["CFBundleName": "Plain"])
        bundle(root, ".Hidden.app", ["NSCameraUsageDescription": text])
        bundle(root, "Sub/Deep/Too.app", ["NSCameraUsageDescription": text])
        bundle(root, "Bad.app", ["NSCameraUsageDescription": 1])
        bundle(root, "Empty.app", nil)
        bundle(root, "App10.app", ["NSBluetoothAlwaysUsageDescription": text])
        bundle(root, "App2.app", ["NSBluetoothAlwaysUsageDescription": text])
        try! FileManager.default.createSymbolicLink(at: root.appendingPathComponent("Link.app"), withDestinationURL: root.appendingPathComponent("Cam.app"))

        let found = PrivacyAsks.scan([root])
        let names = found.map(\.name)
        precondition(names.count == 4, "\(names)")
        precondition(names.filter { $0 == "Cam" || $0 == "Link" }.count == 1, "\(names)")
        precondition(names.contains("Mic") && names.contains("App2") && names.contains("App10"), "\(names)")
        precondition(!names.contains { ["Plain", ".Hidden", "Hidden", "Too", "Bad", "Empty"].contains($0) }, "\(names)")
        precondition(found.first { $0.name == "Mic" }!.keys == ["NSMicrophoneUsageDescription", "NSAppleEventsUsageDescription"])

        precondition(PrivacyAsks.apps("Privacy_Camera", in: found)?.count == 1)
        precondition(PrivacyAsks.apps("Privacy_Accessibility", in: found) == nil)
        precondition(PrivacyAsks.apps("Privacy_Automation", in: found)?.map(\.name) == ["Mic"])
        precondition(PrivacyAsks.apps("Privacy_Microphone", in: found)?.map(\.name) == ["Mic"])
        precondition(PrivacyAsks.apps("Privacy_Bluetooth", in: found)?.map(\.name) == ["App2", "App10"], "\(PrivacyAsks.apps("Privacy_Bluetooth", in: found)?.map(\.name) ?? [])")
        precondition(PrivacyAsks.apps("Privacy_FilesAndFolders", in: found)?.isEmpty == true)
        print("privacy-asks: ok")
    }
}
