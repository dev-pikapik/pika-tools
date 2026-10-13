import AppKit
import SwiftUI
#if !APPSTORE
import notify
#endif

#if APPSTORE
final class DesktopIconsTool: Tool {
    let id = "desktop-icons"
    let icon = "menubar.dock.rectangle"
    var title: String { String(localized: "Hide desktop icons") }
    let tab = SettingsTab.finder
    let needs: [Permission] = []
    let isActive = false
    var isEnabled: Bool { get { false } set {} }
    var settingsView: AnyView { AnyView(DesktopIconsLink(tool: self)) }
    func refresh() {}

    static func openSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension")!)
    }
}
#else
@Observable
final class DesktopIconsTool: Tool {
    let id = "desktop-icons"
    let icon = "menubar.dock.rectangle"
    var title: String { String(localized: "Hide desktop icons") }
    let tab = SettingsTab.finder
    let needs: [Permission] = []
    let isActive = false
    var isEnabled: Bool { get { false } set {} }
    private(set) var hidden = DesktopIconsTool.read()

    var isOn: Bool {
        get { hidden }
        set {
            CFPreferencesSetAppValue(Self.key, newValue as CFBoolean, Self.domain)
            CFPreferencesAppSynchronize(Self.domain)
            notify_post("com.apple.ec.WindowManager.preferences")
            hidden = newValue
        }
    }

    var settingsView: AnyView { AnyView(DesktopIconsSettings(tool: self)) }
    func refresh() { hidden = Self.read() }

    private static let domain = "com.apple.WindowManager" as CFString
    private static var stageManager: Bool { CFPreferencesGetAppBooleanValue("GloballyEnabled" as CFString, domain, nil) }
    private static var key: CFString { (stageManager ? "HideDesktop" : "StandardHideDesktopIcons") as CFString }

    private static func read() -> Bool {
        CFPreferencesAppSynchronize(domain)
        var valid: DarwinBoolean = false
        let value = CFPreferencesGetAppBooleanValue(key, domain, &valid)
        return valid.boolValue ? value : stageManager
    }
}

@Observable
final class HiddenFilesTool: Tool {
    let id = "hidden-files"
    let icon = "eye"
    var title: String { String(localized: "Show hidden files") }
    let tab = SettingsTab.finder
    let needs: [Permission] = []
    let isActive = false
    var isEnabled: Bool { get { false } set {} }
    private(set) var shown = HiddenFilesTool.read()

    var isOn: Bool {
        get { shown }
        set {
            CFPreferencesSetAppValue(Self.key, newValue as CFBoolean, Self.domain)
            CFPreferencesAppSynchronize(Self.domain)
            shown = newValue
        }
    }

    var settingsView: AnyView { AnyView(HiddenFilesSettings(tool: self)) }
    func refresh() { shown = Self.read() }

    private static let domain = "com.apple.finder" as CFString
    private static let key = "AppleShowAllFiles" as CFString

    private static func read() -> Bool {
        CFPreferencesAppSynchronize(domain)
        return CFPreferencesGetAppBooleanValue(key, domain, nil)
    }
}

private struct DesktopIconsSettings: View {
    @Bindable var tool: DesktopIconsTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { DesktopIconsArt() }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("For calls, recordings and screenshots. The files stay where they are"),
            hint: Text("The files stay where they are"),
            help: Text("Hides the files and folders on the desktop, the same as the Show items setting in System Settings › Desktop & Dock. They stay in the Desktop folder in Finder."),
            isOn: $tool.isOn
        )
        .whileShown(in: { inSettings ? $0 === SettingsWindow.window : StatusMenu.isPanel($0) }) { if $0 { tool.refresh() } }
    }
}

private struct HiddenFilesSettings: View {
    @Bindable var tool: HiddenFilesTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { HiddenFilesArt() }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Files that macOS hides appear dimmed, like with ⇧⌘. in Finder"),
            hint: Text("They appear dimmed in Finder"),
            help: Text("Hidden files and folders, like Library, appear dimmed in Finder and on the desktop, the same as pressing ⇧⌘. in Finder."),
            isOn: $tool.isOn
        )
        .whileShown(in: { inSettings ? $0 === SettingsWindow.window : StatusMenu.isPanel($0) }) { if $0 { tool.refresh() } }
    }
}
#endif

#if APPSTORE
private struct DesktopIconsLink: View {
    let tool: DesktopIconsTool
    @Environment(\.inSettings) private var inSettings
    @State private var hovering = false

    private var help: Text {
        Text("Opens Desktop & Dock in System Settings. Turn off On Desktop next to Show items to hide the icons, and turn it back on to bring them back. The files stay in the Desktop folder.")
    }

    var body: some View {
        if inSettings {
            DesktopIconsArt()
            LabeledContent {
                Button("Open") { DesktopIconsTool.openSettings() }
            } label: {
                RowLabel(Text(tool.title), Text("System Settings › Desktop & Dock › Show items › On Desktop"))
            }
            .settingAnchor(tool.title)
            .help(help)
        } else {
            Button {
                NSApp.keyWindow?.close()
                DesktopIconsTool.openSettings()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.secondary.opacity(0.15), in: Circle())
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(tool.title)
                            .font(.body)
                            .lineLimit(2)
                        Text("Opens Desktop & Dock in System Settings")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if hovering {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.fill.quaternary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
            .help(help)
        }
    }
}

struct HiddenFilesHint: View {
    var body: some View {
        HiddenFilesArt()
        KeyLabel(keys: ["⇧⌘."], title: Text("Show hidden files"), subtitle: Text("Press these keys in Finder, and again to hide them"))
            .settingAnchor(String(localized: "Show hidden files"))
    }
}
#endif

struct DesktopIconsArt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.6, 2.2]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let hidden = reduceMotion || tick % 2 == 1
            Stage {
                ArtMonitor(glow: 0.8) {
                    VStack(spacing: 3) {
                        ForEach(0..<2, id: \.self) { row in
                            HStack(spacing: 3) {
                                ForEach(0..<2, id: \.self) { column in icon(row * 2 + column, hidden: hidden) }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 8)
                    .padding(.trailing, 5)
                }
                .scaleEffect(1.3)
            }
        }
    }

    private func icon(_ index: Int, hidden: Bool) -> some View {
        VStack(spacing: 2) {
            if index == 0 || index == 3 {
                Image(systemName: "folder.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.45, green: 0.73, blue: 1))
                    .frame(width: 14, height: 11)
            } else {
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(.white)
                    .frame(width: 9, height: 11)
            }
            Capsule().fill(.white.opacity(0.85)).frame(width: 12, height: 2)
        }
        .frame(width: 16, height: 16)
        .opacity(hidden ? 0 : 1)
        .scaleEffect(hidden ? 0.6 : 1)
        .animation(reduceMotion ? nil : .smooth(duration: 0.4).delay(Double(index) * 0.07), value: hidden)
    }
}

struct HiddenFilesArt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.4, 0.4, 2.0, 0.4]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 2 : tick % Self.durations.count
            Stage {
                ArtWindow(size: CGSize(width: 222, height: 86)) {
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { index in
                            if index % 2 == 0 {
                                ArtFile()
                            } else if step >= 2 {
                                ArtFile()
                                    .opacity(0.45)
                                    .transition(.scale(scale: 0.4).combined(with: .opacity))
                            }
                        }
                    }
                }
                .position(x: 126, y: 64)
                ArtKey(down: step % 2 == 1, width: 46) { Text(verbatim: "⇧⌘.") }
                    .position(x: 266, y: 64)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.4), value: step)
        }
    }
}
