import AppKit
import SwiftUI

#if APPSTORE
@Observable
final class DesktopIconsTool: Tool {
    let id = "desktop-icons"
    let icon = "menubar.dock.rectangle"
    var title: String { String(localized: "Hide desktop icons") }
    let tab = SettingsTab.finder
    let needs: [Permission] = []
    var isActive: Bool { isEnabled }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private let curtain = DesktopCurtain()

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView { AnyView(DesktopIconsSettings(tool: self)) }
    func refresh() { curtain.isOn = isEnabled && MainCopy.canAct }
}
#else
private func relaunch(_ bundleID: String) {
    for app in NSRunningApplication.runningApplications(withBundleIdentifier: bundleID) { kill(app.processIdentifier, SIGTERM) }
}

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
            guard MainCopy.canAct else { return }
            OriginalValue.set(Self.journal, current: Self.read(), to: newValue, write: Self.write)
            hidden = newValue
        }
    }

    var settingsView: AnyView { AnyView(DesktopIconsSettings(tool: self)) }
    func refresh() { hidden = Self.read() }

    static func putBack() {
        if let value = OriginalValue.putBack(OriginalValue.load(journal), current: read()) { write(value) }
        OriginalValue.save(nil, journal)
    }

    private static func write(_ value: Bool) {
        CFPreferencesSetAppValue(key, value as CFBoolean, domain)
        CFPreferencesAppSynchronize(domain)
        relaunch("com.apple.WindowManager")
    }

    private static let journal = "desktop-icons-original"
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
    private var finderBusy = false
    private var finderShows: Bool?

    var waitingForFinder: Bool { finderBusy && finderShows != shown }

    var isOn: Bool {
        get { shown }
        set {
            guard MainCopy.canAct else { return }
            OriginalValue.set(Self.journal, current: Self.read(), to: newValue) {
                CFPreferencesSetAppValue(Self.key, $0 as CFBoolean, Self.domain)
                CFPreferencesAppSynchronize(Self.domain)
            }
            let idle = finderShows == nil
            if idle { finderShows = shown }
            shown = newValue
            if idle { restartFinder() }
        }
    }

    var settingsView: AnyView { AnyView(HiddenFilesSettings(tool: self)) }
    func refresh() { shown = Self.read() }

    static func putBack() {
        guard let value = OriginalValue.putBack(OriginalValue.load(journal), current: read()) else { return OriginalValue.save(nil, journal) }
        CFPreferencesSetAppValue(key, value as CFBoolean, domain)
        CFPreferencesAppSynchronize(domain)
        OriginalValue.save(nil, journal)
        guard let pid = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first?.processIdentifier,
              let before = activity(pid)
        else { return }
        Thread.sleep(forTimeInterval: 0.5)
        if let after = activity(pid), !busy(before, after) { kill(pid, SIGTERM) }
    }

    private static func busy(_ before: (cpu: Double, io: UInt64), _ after: (cpu: Double, io: UInt64)) -> Bool {
        after.cpu - before.cpu > 0.005 || after.io != before.io
    }

    private func restartFinder() {
        guard let pid = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first?.processIdentifier,
              let before = Self.activity(pid) else { return finish() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            guard let after = Self.activity(pid) else { return finish() }
            let busy = Self.busy(before, after)
            if busy != finderBusy { finderBusy = busy }
            if busy { return restartFinder() }
            if shown != finderShows { kill(pid, SIGTERM) }
            finish()
        }
    }

    private func finish() {
        finderShows = nil
        if finderBusy { finderBusy = false }
    }

    private static func activity(_ pid: pid_t) -> (cpu: Double, io: UInt64)? {
        var info = rusage_info_v4()
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) { proc_pid_rusage(pid, RUSAGE_INFO_V4, $0) }
        }
        guard result == 0 else { return nil }
        return (Double(info.ri_user_time + info.ri_system_time) * seconds, info.ri_diskio_bytesread + info.ri_diskio_byteswritten + info.ri_logical_writes)
    }

    private static let seconds: Double = {
        var base = mach_timebase_info_data_t()
        mach_timebase_info(&base)
        return Double(base.numer) / Double(base.denom) / 1e9
    }()

    private static let journal = "hidden-files-original"
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
            subtitle: tool.waitingForFinder ? Text("Waiting for Finder to finish copying") : Text("Finder restarts for a moment"),
            hint: tool.waitingForFinder ? Text("Waiting for Finder to finish copying") : Text("Finder restarts for a moment"),
            help: Text("Hidden files and folders, like Library, appear dimmed in Finder and on the desktop, the same as pressing ⇧⌘. in Finder. To apply the change, Finder restarts for a moment and reopens its windows and tabs. If Finder is copying or moving files, it waits until they are done."),
            keys: ["⇧⌘."],
            isOn: $tool.isOn
        )
        .whileShown(in: { inSettings ? $0 === SettingsWindow.window : StatusMenu.isPanel($0) }) { if $0 { tool.refresh() } }
    }
}
#endif

#if APPSTORE
private struct DesktopIconsSettings: View {
    @Bindable var tool: DesktopIconsTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { DesktopIconsArt() }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Covers the icons with your wallpaper. For calls, recordings and screenshots"),
            hint: Text("The files stay where they are"),
            help: Text("Covers the files and folders on the desktop with your wallpaper, on every display. Clicks still reach the desktop. If your wallpaper moves, a plain color covers them instead. The files stay in the Desktop folder in Finder."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            SystemSettingsRow(
                title: String(localized: "Or hide them in System Settings"),
                subtitle: Text("Turn off “On Desktop”"),
                url: URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension")!,
                guide: SettingsGuide(pane: .desktop, steps: [.checkbox("Show items", option: "On Desktop", on: false)])
            )
        }
    }
}

struct HiddenFilesHint: View {
    var body: some View {
        HiddenFilesArt()
        KeyLabel(keys: ["⇧⌘."], title: Text("Show hidden files"), subtitle: Text("Press in Finder to show or hide"))
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
