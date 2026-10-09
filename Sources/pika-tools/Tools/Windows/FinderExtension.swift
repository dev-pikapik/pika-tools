import FinderSync
import SwiftUI

@Observable
final class FinderExtension {
    private(set) var isActive = false
    private(set) var needsSettings = false

    private let bundle: String
    private let key: String
    private let id: String

    init(bundle: String, key: String) {
        self.bundle = bundle
        self.key = key
        id = (Bundle.main.bundleIdentifier ?? "com.pesotchi.pika-tools") + "." + key
        refresh()
    }

    var isEnabled: Bool {
        get { isActive }
        set {
            if newValue, let plugIns = Bundle.main.builtInPlugInsURL {
                Self.pluginkit("-a", plugIns.appending(path: bundle + ".appex").path)
            }
            Self.pluginkit("-e", newValue ? "use" : "ignore", "-i", id)
            refresh()
            needsSettings = newValue && !isActive
        }
    }

    func refresh() {
        isActive = Self.pluginkit("-m", "-i", id).hasPrefix("+")
        if isActive {
            needsSettings = false
            ignoreOtherCopies()
        }
        if UserDefaults.standard.object(forKey: key) as? Bool != isActive {
            UserDefaults.standard.set(isActive, forKey: key)
        }
    }

    func load() {
        let saved = UserDefaults.standard.bool(forKey: key)
        if saved != isActive { isEnabled = saved }
    }

    private func ignoreOtherCopies() {
        guard !id.contains(".dev.") else { return }
        for line in Self.pluginkit("-m", "-p", "com.apple.FinderSync").split(separator: "\n") where line.hasPrefix("+") {
            let other = line.split(whereSeparator: \.isWhitespace).last?.prefix { $0 != "(" } ?? ""
            if other.hasPrefix("com.pesotchi.pika-tools"), other.hasSuffix("." + key), other != id {
                Self.pluginkit("-e", "ignore", "-i", String(other))
            }
        }
    }

    static func register() {
        plugIns.forEach { pluginkit("-a", $0.bundlePath) }
    }

    fileprivate static var plugIns: [Bundle] {
        guard let folder = Bundle.main.builtInPlugInsURL,
              let items = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        else { return [] }
        return items.filter { $0.pathExtension == "appex" }.compactMap(Bundle.init(url:))
    }

    @discardableResult
    private static func pluginkit(_ arguments: String...) -> String {
        run("/usr/bin/pluginkit", arguments)
    }

    fileprivate static func run(_ tool: String, _ arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return "" }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@Observable
final class FinderRestart {
    static let shared = FinderRestart()
    private(set) var isNeeded = false

    func check() {
        DispatchQueue.global(qos: .utility).async {
            guard let finder = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first,
                  Self.isStale(finder.processIdentifier)
            else { return }
            let safe = Self.isSafe(finder)
            DispatchQueue.main.async { safe ? self.restart() : (self.isNeeded = true) }
        }
    }

    func restart() {
        isNeeded = false
        AnimationsTool.shared.restartFinder()
    }

    private static func isStale(_ finder: pid_t) -> Bool {
        FinderExtension.plugIns.compactMap(\.bundleIdentifier).contains { id in
            FinderExtension.run("/bin/launchctl", ["print", "pid/\(finder)/\(id)"])
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .first { $0.hasPrefix("program = ") }
                .map { !FileManager.default.fileExists(atPath: String($0.dropFirst("program = ".count))) } ?? false
        }
    }

    private static func isSafe(_ finder: NSRunningApplication) -> Bool {
        guard !finder.isActive, !finder.isHidden else { return false }
        let windows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] ?? []
        let open = windows.contains {
            $0[kCGWindowOwnerPID as String] as? pid_t == finder.processIdentifier
                && $0[kCGWindowLayer as String] as? Int == 0
                && (($0[kCGWindowBounds as String] as? NSDictionary).flatMap { CGRect(dictionaryRepresentation: $0) }?.height ?? 0) > 64
        }
        guard !open, let before = diskIO(finder.processIdentifier) else { return false }
        Thread.sleep(forTimeInterval: 2)
        guard let after = diskIO(finder.processIdentifier) else { return false }
        return after - before < 1_000_000
    }

    private static func diskIO(_ pid: pid_t) -> UInt64? {
        var info = rusage_info_v4()
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) { proc_pid_rusage(pid, RUSAGE_INFO_V4, $0) }
        }
        return result == 0 ? info.ri_diskio_bytesread + info.ri_diskio_byteswritten : nil
    }
}

struct FinderRestartBar: View {
    private let restart = FinderRestart.shared

    var body: some View {
        if restart.isNeeded {
            HStack(spacing: 12) {
                Image(systemName: "arrow.clockwise")
                    .accessibilityHidden(true)
                Text("Restart Finder once to bring back the right-click items")
                Spacer(minLength: 0)
                Button("Restart Finder") { restart.restart() }
                    .help(Text("Finder closes its windows and opens again. Wait until files finish copying."))
            }
            .noticeBar()
        }
    }
}

struct FinderExtensionSettings: View {
    let tool: any Tool
    @Bindable var finder: FinderExtension
    let subtitle: Text
    let hint: Text
    let help: Text
    var art: ((Bool) -> AnyView)?
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings, let art { art(finder.isEnabled) }
        ToggleRow(icon: tool.icon, title: tool.title, subtitle: subtitle, hint: hint, help: help, isOn: $finder.isEnabled)
        if finder.needsSettings {
            if inSettings {
                LabeledContent("Turn it on in System Settings") {
                    Button("Open Finder Extensions…", systemImage: "puzzlepiece.extension") { FIFinderSyncController.showExtensionManagementInterface() }
                }
            } else {
                Button("Open Finder Extensions…", systemImage: "puzzlepiece.extension") { FIFinderSyncController.showExtensionManagementInterface() }
                    .padding([.horizontal, .bottom], 10)
            }
        }
    }
}
