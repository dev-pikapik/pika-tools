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

    @discardableResult
    private static func pluginkit(_ arguments: String...) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
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
