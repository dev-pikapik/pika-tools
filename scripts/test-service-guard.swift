import Foundation

@main
enum TestServiceGuard {
    static func main() {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("test-service-guard-\(UUID().uuidString)").path
        let folder = base + "/LaunchDaemons"
        let outside = base + "/outside"
        for path in [folder + "/sub", outside] { try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true) }
        defer { try? FileManager.default.removeItem(atPath: base) }

        func write(_ path: String, label: String) {
            let data = try! PropertyListSerialization.data(fromPropertyList: ["Label": label], format: .xml, options: 0)
            FileManager.default.createFile(atPath: path, contents: data)
        }

        for label in ["com.vendor.daemon", "org.example-x_1.helper", "com.pikapik.e2e.daemon", "A"] {
            precondition(HelperServices.allows(label), label)
        }
        let rejected = [
            "", String(repeating: "a", count: 129), "a/b", "../etc/passwd", "a b", "a;b", "a\nb", "com.vendor.daemon\n", "com.vendör.daemon", "$(id)",
            "com.apple.mdmclient", "COM.APPLE.x", "com.apple.", "com.pesotchi.pika-tools.fans", "com.pesotchi.pika-tools.dev.fans", "Com.Pikapik.Tools.helper",
        ]
        for label in rejected { precondition(!HelperServices.allows(label), "accepted \(label.debugDescription)") }

        write(folder + "/vendor.plist", label: "com.vendor.daemon")
        write(folder + "/renamed-file.plist", label: "com.vendor.other")
        write(folder + "/apple.plist", label: "com.apple.mdmclient")
        write(folder + "/own.plist", label: "com.pesotchi.pika-tools.fans")
        write(folder + "/sub/nested.plist", label: "com.vendor.nested")
        write(outside + "/target.plist", label: "com.vendor.linked")
        try! FileManager.default.createSymbolicLink(atPath: folder + "/link.plist", withDestinationPath: outside + "/target.plist")
        FileManager.default.createFile(atPath: folder + "/notes.txt", contents: Data("com.vendor.text".utf8))

        precondition(HelperServices.plist(for: "com.vendor.daemon", in: folder) == folder + "/vendor.plist")
        precondition(HelperServices.plist(for: "com.vendor.other", in: folder) == folder + "/renamed-file.plist")
        for label in ["com.vendor.missing", "com.vendor.nested", "com.vendor.linked", "com.vendor.text", "com.apple.mdmclient", "com.pesotchi.pika-tools.fans", "../outside/target", "vendor"] {
            precondition(HelperServices.plist(for: label, in: folder) == nil, "found \(label)")
        }
        precondition(HelperServices.plist(for: "com.vendor.daemon", in: base + "/missing") == nil)

        precondition(HelperServices.sharing.keys.sorted() == ["com.apple.screensharing", "com.openssh.sshd"])
        precondition(HelperServices.plist(for: "com.openssh.sshd", in: folder) == "/System/Library/LaunchDaemons/ssh.plist")
        precondition(HelperServices.plist(for: "com.apple.screensharing", in: folder) == "/System/Library/LaunchDaemons/com.apple.screensharing.plist")
        for label in ["com.apple.smbd", "com.apple.ftpd", "com.openssh.sshd/x", "com.openssh.sshd "] {
            precondition(HelperServices.plist(for: label, in: folder) == nil, "found \(label)")
        }
        precondition(HelperServices.sharing.values.allSatisfy { $0.hasPrefix("/System/Library/LaunchDaemons/") && !$0.contains("..") })

        print("service allow-list, label check and plist lookup: ok")
    }
}
