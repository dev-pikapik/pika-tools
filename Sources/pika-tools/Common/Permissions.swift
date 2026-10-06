import ApplicationServices
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class Permissions {
    static let shared = Permissions()

    private(set) var accessibility = AXIsProcessTrusted()
    private(set) var inputMonitoring = CGPreflightListenEventAccess()

    var allGranted: Bool { accessibility && inputMonitoring }

    @ObservationIgnored var onChange: (() -> Void)?
    @ObservationIgnored private var timer: Timer?

    private init() {}

    func request() {
        if !accessibility { resetStale("Accessibility") }
        if !inputMonitoring { resetStale("ListenEvent") }
        if !accessibility {
            let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
            AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
        }
        if !inputMonitoring {
            CGRequestListenEventAccess()
        }
        startPolling()
    }

    private func resetStale(_ service: String) {
        guard let id = Bundle.main.bundleIdentifier else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", service, id]
        try? process.run()
        process.waitUntilExit()
    }

    func refresh() {
        let ax = AXIsProcessTrusted()
        let input = CGPreflightListenEventAccess()
        guard ax != accessibility || input != inputMonitoring else { return }
        accessibility = ax
        inputMonitoring = input
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

struct PermissionsView: View {
    private let permissions = Permissions.shared
    private let sync = SettingsSync.shared

    var body: some View {
        Form {
            SettingsHeader(
                tab: .permissions,
                title: permissions.allGranted ? String(localized: "All set") : String(localized: "pika-tools needs two permissions"),
                text: permissions.allGranted
                    ? String(localized: "Both permissions are on and every tool is working.")
                    : String(localized: "Without them, macOS won’t let the app see or change clicks and keys. Open System Settings › Privacy & Security and turn on pika-tools in these two lists:")
            )
            Section {
                PermissionRow(
                    icon: "com.apple.graphic-icon.accessibility",
                    symbol: "accessibility",
                    title: String(localized: "Accessibility"),
                    subtitle: String(localized: "Lets the app change clicks and keys and manage windows"),
                    granted: permissions.accessibility
                ) { permissions.openSettings("Privacy_Accessibility") }
                PermissionRow(
                    icon: "com.apple.graphic-icon.input-monitoring",
                    symbol: "keyboard.badge.eye",
                    title: String(localized: "Input Monitoring"),
                    subtitle: String(localized: "Lets the app see clicks and keys"),
                    granted: permissions.inputMonitoring
                ) { permissions.openSettings("Privacy_ListenEvent") }
            } footer: {
                if !permissions.allGranted {
                    Text("pika-tools checks every 1.5 seconds, so there’s no need to restart anything. If it’s already in a list but doesn’t work, remove it with the − button and add it again.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if sync.isEnabled {
                Section {
                    PermissionRow(
                        icon: "",
                        symbol: "icloud.fill",
                        title: String(localized: "iCloud Drive"),
                        subtitle: String(localized: "Lets the app keep your settings in iCloud Drive to sync them"),
                        granted: sync.state != .noAccess
                    ) { sync.openSettings() }
                }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .animation(.snappy, value: permissions.allGranted)
        .onAppear {
            permissions.refresh()
            if !permissions.allGranted { permissions.startPolling() }
            if sync.state == .noAccess { sync.refresh() }
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let symbol: String
    let title: String
    let subtitle: String
    let granted: Bool
    let open: () -> Void

    var body: some View {
        LabeledContent {
            HStack(spacing: 8) {
                if !granted {
                    Button("Open", action: open)
                }
                Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(granted ? .green : .orange)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityLabel(granted ? String(localized: "Allowed") : String(localized: "Not allowed"))
            }
        } label: {
            HStack(spacing: 10) {
                PermissionIcon(type: icon, symbol: symbol)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .settingAnchor(title)
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
