import Foundation

@main
struct TestSettingsSyncThread {
    static func main() {
        let key = "test-settings-sync-thread"
        defer { UserDefaults.standard.removeObject(forKey: key) }
        var heard: [Bool] = []
        SettingsFile.onSave { heard.append(Thread.isMainThread) }

        UserDefaults.standard.set(1, forKey: key)
        precondition(heard == [true], "\(heard)")
        print("a setting saved on the main thread is heard at once, on the main thread: ok")

        let saved = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            UserDefaults.standard.set(2, forKey: key)
            saved.signal()
        }
        precondition(saved.wait(timeout: .now() + 1) == .success, "a setting saved off the main thread must not wait for the main thread")
        RunLoop.main.run(until: Date() + 0.2)
        precondition(heard == [true, true], "\(heard)")
        print("a setting saved off the main thread does not wait for a busy main thread, and is heard later on the main thread: ok")

        var listeners: [String: Int] = [:]
        for case let path as String in FileManager.default.enumerator(atPath: "Sources")! where path.hasSuffix(".swift") {
            let text = try! String(contentsOfFile: "Sources/" + path, encoding: .utf8)
            let count = ["UserDefaults.didChangeNotification", "NSUserDefaultsDidChangeNotification"].reduce(0) { $0 + text.components(separatedBy: $1).count - 1 }
            if count > 0 { listeners[path] = count }
        }
        precondition(listeners == ["pika-tools/Common/SettingsFile.swift": 1], "only SettingsFile.onSave may listen for saved settings: \(listeners)")
        print("only SettingsFile.onSave listens for saved settings: ok")
    }
}
