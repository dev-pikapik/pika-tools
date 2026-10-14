import ApplicationServices
import SwiftUI
import UniformTypeIdentifiers

enum Permission: CaseIterable {
    case accessibility, inputMonitoring, screenRecording, systemAudio
    #if !APPSTORE
    case fans
    #endif
    case finder
    #if APPSTORE
    case folders
    #else
    case iCloud, fullDisk
    #endif

    private var info: (icon: String, symbol: String, title: String, subtitle: String) {
        switch self {
        case .accessibility:
            #if APPSTORE
            ("com.apple.graphic-icon.accessibility", "accessibility",
             Self.accessibilityTitle, String(localized: "Lets the app change clicks and keys"))
            #else
            ("com.apple.graphic-icon.accessibility", "accessibility",
             Self.accessibilityTitle, String(localized: "Lets the app change clicks and keys and manage windows"))
            #endif
        case .inputMonitoring:
            ("com.apple.graphic-icon.input-monitoring", "keyboard.badge.eye",
             String(localized: "Input Monitoring"), String(localized: "Lets the app see clicks and keys"))
        case .screenRecording:
            ("com.apple.graphic-icon.screen-recording", "rectangle.dashed.badge.record",
             String(localized: "Screen Recording"),
             FrameRateMeter.hasTrace ? String(localized: "Needed for some games") : String(localized: "Needed to count frames"))
        case .systemAudio:
            ("", "waveform", String(localized: "System Audio Recording"), String(localized: "To change each app’s volume"))
        #if !APPSTORE
        case .fans:
            ("", "fan", String(localized: "Fan control"), String(localized: "Lets the app choose how fast your fans spin"))
        #endif
        case .finder:
            ("", "puzzlepiece.extension",
             String(localized: "Finder Extensions"), String(localized: "Lets the app add items to the right-click menu in Finder"))
        #if APPSTORE
        case .folders:
            ("", "folder.fill", String(localized: "Folders"), String(localized: "Lets the app save new files next to yours and see your background tasks"))
        #else
        case .iCloud:
            ("", "icloud.fill",
             String(localized: "iCloud Drive"), String(localized: "Lets the app keep your settings in iCloud Drive to sync them"))
        case .fullDisk:
            ("com.apple.graphic-icon.privacy", "hand.raised.fill",
             String(localized: "Full Disk Access"), String(localized: "Lets the app find permissions left by deleted apps"))
        #endif
        }
    }

    private static var hasDeviceControl: Bool {
        ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 27, minorVersion: 0, patchVersion: 0))
    }

    static var accessibilityTitle: String {
        hasDeviceControl ? String(localized: "Device Control and Data Access") : String(localized: "Accessibility")
    }

    var guidePage: String? {
        switch self {
        case .accessibility: Self.hasDeviceControl ? "Device Control and Data Access" : "Accessibility"
        case .inputMonitoring: "Input Monitoring"
        case .screenRecording, .systemAudio: "Screen & System Audio Recording"
        default: nil
        }
    }

    var icon: String { info.icon }
    var symbol: String { info.symbol }
    var title: String { info.title }
    var subtitle: String { info.subtitle }

    private var pane: String {
        switch self {
        case .accessibility: "Privacy_Accessibility"
        case .inputMonitoring: "Privacy_ListenEvent"
        case .screenRecording: "Privacy_ScreenCapture"
        case .systemAudio: "Privacy_AudioCapture"
        default: "Privacy_AllFiles"
        }
    }

    var isShown: Bool {
        switch self {
        case .screenRecording:
            GameModeTool.shared.showsFrameRate && !Permissions.shared.screenRecording && (!FrameRateMeter.hasTrace || GameModeTool.shared.needsRecording)
        case .systemAudio:
            if #available(macOS 14.2, *) { AppVolumeTool.shared.isEnabled || Permissions.shared.systemAudioRequested } else { false }
        #if !APPSTORE
        case .fans: FanControl.shared.hasFans
        case .iCloud: SettingsSync.shared.isEnabled
        #endif
        case .finder: FinderExtension.all.contains { $0.isActive || $0.needsSettings }
        default: true
        }
    }

    var isGranted: Bool {
        let permissions = Permissions.shared
        return switch self {
        case .accessibility: permissions.accessibility
        case .inputMonitoring: permissions.inputMonitoring
        case .screenRecording: permissions.screenRecording
        case .systemAudio: permissions.systemAudio
        #if !APPSTORE
        case .fans: FanControl.shared.ready
        case .iCloud: SettingsSync.shared.state != .noAccess
        case .fullDisk: permissions.fileAccess
        #endif
        case .finder: !FinderExtension.all.contains(where: \.needsSettings)
        #if APPSTORE
        case .folders: permissions.fileAccess
        #endif
        }
    }

    var isBusy: Bool {
        #if APPSTORE
        false
        #else
        self == .fans && FanControl.shared.busy
        #endif
    }

    var error: String? {
        #if APPSTORE
        nil
        #else
        self == .fans ? FanControl.shared.error : nil
        #endif
    }

    var opensSettingsToAllow: Bool {
        #if APPSTORE
        self == .systemAudio ? Permissions.shared.systemAudioAsked : self != .folders
        #else
        self == .systemAudio ? Permissions.shared.systemAudioAsked : self != .fans
        #endif
    }

    var opensSettingsToTurnOff: Bool {
        #if APPSTORE
        self == .accessibility || self == .inputMonitoring || self == .screenRecording || self == .systemAudio || self == .finder
        #else
        false
        #endif
    }

    var restartsToTurnOff: Bool {
        #if APPSTORE
        false
        #else
        self == .accessibility || self == .inputMonitoring || self == .screenRecording || self == .systemAudio
        #endif
    }

    func allow() {
        let permissions = Permissions.shared
        switch self {
        case .accessibility, .inputMonitoring, .screenRecording:
            permissions.request([self])
            permissions.openSettings(pane)
        case .systemAudio:
            if #available(macOS 14.2, *) {
                let asked = permissions.systemAudioAsked
                permissions.systemAudioAsked = true
                AudioCaptureProbe.shared.allow(opening: asked ? { permissions.openSettings(pane) } : nil)
            }
        #if !APPSTORE
        case .fans: FanControl.shared.install()
        case .iCloud: SettingsSync.shared.openSettings()
        case .fullDisk: permissions.openSettings(pane)
        #endif
        case .finder: FinderExtension.allow()
        #if APPSTORE
        case .folders:
            FolderAccess.allow()
            permissions.refresh()
        #endif
        }
    }

    func turnOff() {
        let permissions = Permissions.shared
        switch self {
        case .accessibility, .inputMonitoring, .screenRecording:
            #if APPSTORE
            permissions.openSettings(pane)
            #else
            SettingsWindow.restart(opening: "--permissions", resetting: self == .accessibility ? "Accessibility" : self == .inputMonitoring ? "ListenEvent" : "ScreenCapture")
            #endif
        case .systemAudio:
            #if APPSTORE
            permissions.openSettings(pane)
            #else
            permissions.systemAudioAsked = false
            permissions.setSystemAudio(false)
            SettingsWindow.restart(opening: "--permissions", resetting: "AudioCapture")
            #endif
        #if !APPSTORE
        case .fans: FanControl.shared.uninstall()
        case .iCloud:
            SettingsSync.shared.isEnabled = false
            ["Ubiquity", "FileProviderDomain"].forEach(permissions.reset)
        case .fullDisk:
            permissions.reset("SystemPolicyAllFiles")
            permissions.refresh()
            if permissions.fileAccess { permissions.openSettings(pane) }
        #endif
        case .finder: FinderExtension.turnOff()
        #if APPSTORE
        case .folders:
            FolderAccess.forget()
            permissions.refresh()
        #endif
        }
    }
}

@Observable
final class Permissions {
    static let shared = Permissions()

    private(set) var accessibility = AXIsProcessTrusted()
    private(set) var inputMonitoring = CGPreflightListenEventAccess()
    private(set) var fileAccess = Permissions.hasFileAccess
    private(set) var screenRecording = CGPreflightScreenCaptureAccess()
    private(set) var systemAudio = UserDefaults.standard.bool(forKey: "system-audio-granted") {
        didSet { UserDefaults.standard.set(systemAudio, forKey: "system-audio-granted") }
    }
    private(set) var systemAudioRequested = false
    var systemAudioAsked = UserDefaults.standard.bool(forKey: "system-audio-asked") {
        didSet { UserDefaults.standard.set(systemAudioAsked, forKey: "system-audio-asked") }
    }

    var allGranted: Bool { accessibility && inputMonitoring }

    @ObservationIgnored var onChange: (() -> Void)?
    @ObservationIgnored private var timer: Timer?

    private init() {}

    private static var hasFileAccess: Bool {
        #if APPSTORE
        FolderAccess.isGranted
        #else
        let descriptor = open(LeftoverPermissions.systemDatabase, O_RDONLY)
        defer { if descriptor >= 0 { close(descriptor) } }
        return descriptor >= 0
        #endif
    }

    func request(_ wanted: [Permission] = [.accessibility, .inputMonitoring]) {
        let ax = !accessibility && wanted.contains(.accessibility)
        let input = !inputMonitoring && wanted.contains(.inputMonitoring)
        #if !APPSTORE
        if ax { reset("Accessibility") }
        if input { reset("ListenEvent") }
        #endif
        if ax {
            let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
            AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
        }
        if input {
            CGRequestListenEventAccess()
        }
        if !screenRecording && wanted.contains(.screenRecording) {
            CGRequestScreenCaptureAccess()
        }
        if wanted.contains(.systemAudio) { systemAudioRequested = true }
        startPolling()
    }

    func ask(_ missing: [Permission]) {
        request(missing)
        SettingsWindow.show(.permissions)
        if let first = missing.first {
            SettingsWindow.model.open(SettingsItem(tab: .permissions, title: first.title))
        }
    }

    #if !APPSTORE
    func reset(_ service: String) {
        guard let id = Bundle.main.bundleIdentifier else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", service, id]
        try? process.run()
        process.waitUntilExit()
    }
    #endif

    func refresh() {
        let ax = AXIsProcessTrusted()
        let input = CGPreflightListenEventAccess()
        let files = Self.hasFileAccess
        let capture = CGPreflightScreenCaptureAccess()
        guard ax != accessibility || input != inputMonitoring || files != fileAccess || capture != screenRecording else { return }
        accessibility = ax
        inputMonitoring = input
        fileAccess = files
        screenRecording = capture
        onChange?()
    }

    func setSystemAudio(_ granted: Bool) {
        guard granted != systemAudio else { return }
        systemAudio = granted
        onChange?()
    }

    func checkSystemAudio() {
        if #available(macOS 14.2, *) { AudioCaptureProbe.shared.check() }
    }

    func startPolling() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            refresh()
            if allGranted {
                timer.invalidate()
                self.timer = nil
            }
        }
    }

    func openSettings(_ pane: String) {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(pane)")!
        NSWorkspace.shared.open(url)
    }

    #if APPSTORE
    static var privacyLists: [(title: String, icon: String, symbol: String, pane: String)] {
        [
            (Permission.accessibilityTitle, "com.apple.graphic-icon.accessibility", "accessibility", "Privacy_Accessibility"),
            (String(localized: "Screen Recording"), "com.apple.graphic-icon.screen-recording", "rectangle.dashed.badge.record", "Privacy_ScreenCapture"),
            (String(localized: "Input Monitoring"), "com.apple.graphic-icon.input-monitoring", "keyboard.badge.eye", "Privacy_ListenEvent"),
            (String(localized: "Full Disk Access"), "com.apple.graphic-icon.privacy", "hand.raised.fill", "Privacy_AllFiles"),
            (String(localized: "Automation"), "com.apple.graphic-icon.automation", "gearshape.2", "Privacy_Automation"),
            (String(localized: "App Management"), "", "app.badge.checkmark", "Privacy_AppBundles"),
            (String(localized: "Files and Folders"), "", "folder.fill", "Privacy_FilesAndFolders"),
            (String(localized: "Camera"), "com.apple.graphic-icon.video-camera", "camera", "Privacy_Camera"),
            (String(localized: "Microphone"), "com.apple.graphic-icon.microphone", "mic", "Privacy_Microphone"),
            (String(localized: "Developer Tools"), "com.apple.graphic-icon.developer-tools", "hammer", "Privacy_DevTools"),
            (String(localized: "Bluetooth"), "com.apple.graphic-icon.bluetooth", "dot.radiowaves.left.and.right", "Privacy_Bluetooth"),
        ]
    }
    #endif
}

private struct NeedsPermission: ViewModifier {
    let permissions: [Permission]

    func body(content: Content) -> some View {
        let missing = permissions.filter { !$0.isGranted }
        content
            .disabled(!missing.isEmpty)
            .opacity(missing.isEmpty ? 1 : 0.5)
            .overlay {
                if !missing.isEmpty {
                    Button { Permissions.shared.ask(missing) } label: {
                        Color.clear.contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(Text("Needs a permission. Click to allow it."))
                    .accessibilityLabel(Text("Needs a permission. Click to allow it."))
                }
            }
    }
}

extension View {
    func needs(_ permissions: [Permission]) -> some View {
        modifier(NeedsPermission(permissions: permissions))
    }
}

struct PermissionBar: View {
    let permissions: [Permission]
    var text: LocalizedStringKey = "Grey tools need a permission. Click one to allow it."

    var body: some View {
        let missing = Permission.allCases.filter { permissions.contains($0) && !$0.isGranted }
        if !missing.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .accessibilityHidden(true)
                Text(text)
                Spacer(minLength: 0)
                Button("Allow") { Permissions.shared.ask(missing) }
            }
            .noticeBar()
        }
    }
}

struct PermissionsView: View {
    private let permissions = Permissions.shared
    private let sync = SettingsSync.shared
    #if APPSTORE
    @State private var asks = PrivacyAsksModel()
    #endif

    var body: some View {
        let others = Permission.allCases.filter { $0.isShown && $0 != .accessibility && $0 != .inputMonitoring }
        let allSet = others.allSatisfy(\.isGranted)
            ? String(localized: "Both permissions are on and every tool is working.")
            : String(localized: "Both permissions are on. Some tools also need a permission from the list below.")
        Form {
            #if APPSTORE
            SettingsHeader(
                tab: .permissions,
                title: permissions.allGranted ? String(localized: "All set") : String(localized: "Permissions for some tools"),
                text: permissions.allGranted
                    ? allSet
                    : String(localized: "Only some tools need these permissions. Everything else works without them.")
            )
            #else
            SettingsHeader(
                tab: .permissions,
                title: permissions.allGranted ? String(localized: "All set") : String(localized: "pikapik needs two permissions"),
                text: permissions.allGranted
                    ? allSet
                    : String(localized: "Without them, macOS won’t let the app see or change clicks and keys. Open System Settings › Privacy & Security and turn on pikapik in these two lists:")
            )
            #endif
            Section {
                if let page = Permission.allCases.first(where: { $0.guidePage != nil && $0.isShown && !$0.isGranted })?.guidePage {
                    SettingsGuide(pane: .privacy, steps: [.page(page), .app(on: true)])
                }
                PermissionRow(permission: .accessibility)
                PermissionRow(permission: .inputMonitoring)
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    if !permissions.allGranted {
                        Text("pikapik checks every 1.5 seconds, so there’s no need to restart anything. If it’s already in a list but doesn’t work, remove it with the − button and add it again.")
                    }
                    #if APPSTORE
                    if permissions.accessibility || permissions.inputMonitoring {
                        Text("macOS lets you turn these off only in System Settings. The button opens the right list, where you switch pikapik off.")
                    }
                    #endif
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }
            Section("For some features") {
                ForEach(others, id: \.self) { permission in
                    if permission == .finder, !permission.isGranted { SettingsGuide.finderExtensions }
                    PermissionRow(permission: permission)
                    if let error = permission.error {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            #if APPSTORE
            Section {
                ForEach(Permissions.privacyLists, id: \.pane) { list in
                    PrivacyListRow(title: list.title, icon: list.icon, symbol: list.symbol, pane: list.pane, apps: asks.apps)
                        .settingAnchor(list.pane)
                }
            } header: {
                NewTitle(title: "Other apps’ permissions", row: "apps-can-ask")
            } footer: {
                Text("Deleted apps keep their permissions: select one in the list and press − or turn it off.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .settingAnchor(String(localized: "Left by deleted apps"))
            .onAppear { asks.refresh() }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in asks.refresh() }
            #else
            LeftoverPermissionsSection()
            #endif
        }
        .formStyle(.grouped)
        .settingsPage()
        .animation(.snappy, value: permissions.allGranted)
        .animation(.snappy, value: others)
        .onAppear {
            permissions.refresh()
            FinderExtension.all.forEach { $0.refresh() }
            #if !APPSTORE
            if FanControl.shared.hasFans { FanControl.shared.probe() }
            #endif
            if !permissions.allGranted { permissions.startPolling() }
            if sync.state == .noAccess { sync.refresh() }
        }
    }
}

struct PermissionRow: View {
    let permission: Permission
    @State private var confirming = false

    @ViewBuilder
    private var label: some View {
        let content = HStack(spacing: 10) {
            PermissionIcon(type: permission.icon, symbol: permission.symbol)
            RowLabel(Text(permission.title), Text(permission.subtitle))
        }
        if permission == .systemAudio {
            content.help(Text("pikapik passes each app’s sound through itself to change its volume. Nothing is recorded or saved."))
        } else {
            content
        }
    }

    var body: some View {
        let granted = permission.isGranted
        LabeledContent {
            HStack(spacing: 8) {
                if permission.isBusy {
                    ProgressView()
                        .controlSize(.small)
                } else if granted {
                    PermissionButton(title: "Turn Off", opensSettings: permission.opensSettingsToTurnOff) {
                        if permission.restartsToTurnOff { confirming = true } else { permission.turnOff() }
                    }
                } else {
                    PermissionButton(title: "Allow", opensSettings: permission.opensSettingsToAllow, action: permission.allow)
                }
                Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(granted ? .green : .orange)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityLabel(granted ? String(localized: "Allowed") : String(localized: "Not allowed"))
            }
        } label: {
            label
        }
        .settingAnchor(permission.title)
        .confirmationDialog("Turn off \(permission.title)?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Turn Off", role: .destructive) { permission.turnOff() }
        } message: {
            Text("pikapik will restart, and the tools that need it will turn grey until you allow it again.")
        }
    }
}

private struct PermissionButton: View {
    let title: LocalizedStringKey
    let opensSettings: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if opensSettings {
                Label(title, systemImage: "arrow.up.forward.app")
            } else {
                Text(title)
            }
        }
    }
}

struct PermissionIcon: View {
    let type: String
    let symbol: String

    var body: some View {
        let size = SettingsTab.iconSize + 4
        if let type = UTType(type) {
            let _ = IconStyle.shared.theme
            Image(nsImage: NSWorkspace.shared.icon(for: type))
                .resizable()
                .frame(width: size, height: size)
                .padding(-2)
                .accessibilityHidden(true)
        } else {
            SectionIcon(symbol: symbol, color: .blue, size: SettingsTab.iconSize)
        }
    }
}
