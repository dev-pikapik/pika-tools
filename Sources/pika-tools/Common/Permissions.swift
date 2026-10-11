import ApplicationServices
import SwiftUI
import UniformTypeIdentifiers

enum Permission: CaseIterable {
    case accessibility, inputMonitoring
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
            ("com.apple.graphic-icon.accessibility", "accessibility",
             String(localized: "Accessibility"), String(localized: "Lets the app change clicks and keys and manage windows"))
        case .inputMonitoring:
            ("com.apple.graphic-icon.input-monitoring", "keyboard.badge.eye",
             String(localized: "Input Monitoring"), String(localized: "Lets the app see clicks and keys"))
        #if !APPSTORE
        case .fans:
            ("", "fan", String(localized: "Fan control"), String(localized: "Lets the app choose how fast your fans spin"))
        #endif
        case .finder:
            ("", "puzzlepiece.extension",
             String(localized: "Finder Extensions"), String(localized: "Lets the app add items to the right-click menu in Finder"))
        #if APPSTORE
        case .folders:
            ("", "folder.fill", String(localized: "Folders"), String(localized: "Lets the app save new files next to yours"))
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

    var icon: String { info.icon }
    var symbol: String { info.symbol }
    var title: String { info.title }
    var subtitle: String { info.subtitle }

    private var pane: String {
        switch self {
        case .accessibility: "Privacy_Accessibility"
        case .inputMonitoring: "Privacy_ListenEvent"
        default: "Privacy_AllFiles"
        }
    }

    var isShown: Bool {
        switch self {
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
        self != .folders
        #else
        self != .fans
        #endif
    }

    var opensSettingsToTurnOff: Bool {
        #if APPSTORE
        self == .accessibility || self == .inputMonitoring || self == .finder
        #else
        false
        #endif
    }

    var restartsToTurnOff: Bool {
        #if APPSTORE
        false
        #else
        self == .accessibility || self == .inputMonitoring
        #endif
    }

    func allow() {
        let permissions = Permissions.shared
        switch self {
        case .accessibility, .inputMonitoring:
            permissions.request([self])
            permissions.openSettings(pane)
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
        case .accessibility, .inputMonitoring:
            #if APPSTORE
            permissions.openSettings(pane)
            #else
            SettingsWindow.restart(opening: "--permissions", resetting: self == .accessibility ? "Accessibility" : "ListenEvent")
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
        guard ax != accessibility || input != inputMonitoring || files != fileAccess else { return }
        accessibility = ax
        inputMonitoring = input
        fileAccess = files
        onChange?()
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

    var body: some View {
        let missing = Permission.allCases.filter { permissions.contains($0) && !$0.isGranted }
        if !missing.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .accessibilityHidden(true)
                Text("Grey tools need a permission. Click one to allow it.")
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

    var body: some View {
        let others = Permission.allCases.filter { $0.isShown && $0 != .accessibility && $0 != .inputMonitoring }
        Form {
            SettingsHeader(
                tab: .permissions,
                title: permissions.allGranted ? String(localized: "All set") : String(localized: "pikapik needs two permissions"),
                text: permissions.allGranted
                    ? String(localized: "Both permissions are on and every tool is working.")
                    : String(localized: "Without them, macOS won’t let the app see or change clicks and keys. Open System Settings › Privacy & Security and turn on pikapik in these two lists:")
            )
            Section {
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
                    PermissionRow(permission: permission)
                    if let error = permission.error {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            #if !APPSTORE
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
            HStack(spacing: 10) {
                PermissionIcon(type: permission.icon, symbol: permission.symbol)
                RowLabel(Text(permission.title), Text(permission.subtitle))
            }
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

private struct PermissionIcon: View {
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
