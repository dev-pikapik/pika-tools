import AppKit
import SwiftUI

final class NewFileTool: Tool {
    let id = "new-file"
    let icon = "doc.badge.plus"
    var title: String { String(localized: "New File in Finder") }
    let tab = SettingsTab.finder
    private let finder = FinderExtension(bundle: "NewFile", key: "new-file")

    var isActive: Bool { finder.isActive }

    var isEnabled: Bool {
        get { finder.isEnabled }
        set { finder.isEnabled = newValue }
    }

    var settingsView: AnyView {
        AnyView(FinderExtensionSettings(
            tool: self,
            finder: finder,
            subtitle: Text("Right-click in a folder › New File"),
            hint: Text("Right-click in any folder"),
            help: Text("Right-click in Finder or on the Desktop › New File, then type a name. .txt by default.")
        ) { AnyView(NewFileArt(on: $0)) })
    }

    func refresh() { finder.refresh() }
    func load() { finder.load() }
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

struct NewFileArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.6, 1, 0.7, 1.8]
    private static let click = CGPoint(x: 128, y: 46)

    var body: some View {
        let step = reduceMotion ? 4 : tick % Self.durations.count
        let menu = (1...3).contains(step)
        let created = on && step >= 3
        IllustrationRow {
            Stage {
                ArtWindow(size: CGSize(width: 168, height: 100)) {
                    ArtFile(selected: on && step == 4, renaming: on && step == 3)
                        .opacity(created ? 1 : 0)
                        .scaleEffect(created ? 1 : 0.6)
                        .position(x: 38, y: 40)
                }
                .position(x: 150, y: 64)
                if menu {
                    ArtMenu {
                        ArtMenuRow(width: 30)
                        if on {
                            ArtMenuRow(title: Text("New File"), active: step >= 2)
                        } else {
                            ArtMenuRow(width: 44)
                        }
                        ArtMenuRow(width: 38)
                    }
                    .position(x: Self.click.x + 50, y: Self.click.y + 26)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if step == 1 {
                    ArtRipple().position(x: Self.click.x, y: Self.click.y)
                }
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 220, y: 100) : step == 1 ? Self.click : CGPoint(x: Self.click.x + 18, y: Self.click.y + 26))
                    .opacity(step == 4 ? 0 : 1)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
        .loop($tick, Self.durations)
    }
}
