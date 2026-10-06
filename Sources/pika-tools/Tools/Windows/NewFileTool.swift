import AppKit
import FinderSync
import SwiftUI

@Observable
final class NewFileTool: Tool {
    let id = "new-file"
    let icon = "doc.badge.plus"
    var title: String { String(localized: "New File in Finder") }
    let tab = SettingsTab.finder

    private(set) var isActive = false
    private(set) var needsSettings = false

    var isEnabled: Bool {
        get { isActive }
        set {
            if newValue, let plugIns = Bundle.main.builtInPlugInsURL {
                Self.pluginkit("-a", plugIns.appending(path: "NewFile.appex").path)
            }
            Self.pluginkit("-e", newValue ? "use" : "ignore", "-i", Self.extensionID)
            refresh()
            needsSettings = newValue && !isActive
        }
    }

    private static let extensionID = (Bundle.main.bundleIdentifier ?? "com.pesotchi.pika-tools") + ".new-file"

    init() {
        refresh()
    }

    var settingsView: AnyView {
        AnyView(NewFileSettings(tool: self))
    }

    func refresh() {
        isActive = Self.pluginkit("-m", "-i", Self.extensionID).hasPrefix("+")
        if isActive {
            needsSettings = false
            Self.ignoreOtherCopies()
        }
        if UserDefaults.standard.object(forKey: id) as? Bool != isActive {
            UserDefaults.standard.set(isActive, forKey: id)
        }
    }

    func load() {
        let saved = UserDefaults.standard.bool(forKey: id)
        if saved != isActive { isEnabled = saved }
    }

    func openExtensionSettings() {
        FIFinderSyncController.showExtensionManagementInterface()
    }

    private static func ignoreOtherCopies() {
        guard !extensionID.contains(".dev.") else { return }
        for line in pluginkit("-m", "-p", "com.apple.FinderSync").split(separator: "\n") where line.hasPrefix("+") {
            let id = line.split(whereSeparator: \.isWhitespace).last?.prefix { $0 != "(" } ?? ""
            if id.hasPrefix("com.pesotchi.pika-tools"), id.hasSuffix(".new-file"), id != extensionID {
                pluginkit("-e", "ignore", "-i", String(id))
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

enum NewFile {
    static func handle(_ url: URL) {
        guard url.host == "new-file",
              let path = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                  .queryItems?.first(where: { $0.name == "dir" })?.value,
              path.hasPrefix("/"),
              ToolRegistry.shared.tools.contains(where: { $0 is NewFileTool && $0.isActive })
        else { return }
        var isFolder: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isFolder), isFolder.boolValue else { return }
        DispatchQueue.main.async { ask(in: URL(fileURLWithPath: path, isDirectory: true)) }
    }

    private static func ask(in folder: URL) {
        let field = NameField(string: String(localized: "Untitled") + ".txt")
        field.frame.size.width = 260

        let alert = NSAlert()
        alert.messageText = String(localized: "New File")
        alert.informativeText = String(localized: "It will appear in “\(FileManager.default.displayName(atPath: folder.path))”.")
        alert.accessoryView = field
        alert.addButton(withTitle: String(localized: "Create"))
        alert.addButton(withTitle: String(localized: "Cancel"))
        alert.window.initialFirstResponder = field

        NSApp.activate()
        while true {
            guard alert.runModal() == .alertFirstButtonReturn else { return }
            let name = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if isValid(name) {
                create(name, in: folder)
                return
            }
            alert.informativeText = String(localized: "Type a name without “/” or “:”.")
        }
    }

    static func isValid(_ name: String) -> Bool {
        !name.isEmpty && name != "." && name != ".." && !name.contains("/") && !name.contains(":")
    }

    static func uniqueURL(for name: String, in folder: URL) -> URL {
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        var url = folder.appending(path: name)
        var number = 2
        while FileManager.default.fileExists(atPath: url.path) {
            url = folder.appending(path: ext.isEmpty ? "\(base) \(number)" : "\(base) \(number).\(ext)")
            number += 1
        }
        return url
    }

    private static func create(_ name: String, in folder: URL) {
        let url = uniqueURL(for: name, in: folder)
        do {
            try Data().write(to: url, options: .withoutOverwriting)
        } catch {
            NSAlert(error: error).runModal()
            return
        }
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        if folder.resolvingSymlinksInPath().path != desktop?.resolvingSymlinksInPath().path {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

private final class NameField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        guard super.becomeFirstResponder() else { return false }
        let base = (stringValue as NSString).deletingPathExtension as NSString
        currentEditor()?.selectedRange = NSRange(location: 0, length: base.length)
        return true
    }
}

private struct NewFileSettings: View {
    @Bindable var tool: NewFileTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Right-click in Finder or on the Desktop › New File, then type a name. .txt by default."),
            hint: Text("Right-click in any folder"),
            isOn: $tool.isEnabled
        )
        if tool.needsSettings {
            if inSettings {
                LabeledContent("Turn it on in System Settings") {
                    Button("Open Finder Extensions…", systemImage: "puzzlepiece.extension") { tool.openExtensionSettings() }
                }
            } else {
                Button("Open Finder Extensions…", systemImage: "puzzlepiece.extension") { tool.openExtensionSettings() }
                    .padding([.horizontal, .bottom], 10)
            }
        }
    }
}
