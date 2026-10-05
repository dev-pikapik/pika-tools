import ApplicationServices
import SwiftUI

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
        if !CommandLine.arguments.contains("--no-reset") {
            if !accessibility { resetStale("Accessibility") }
            if !inputMonitoring { resetStale("ListenEvent") }
        }
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
                    title: String(localized: "Accessibility"),
                    subtitle: String(localized: "Lets the app change clicks and keys"),
                    granted: permissions.accessibility
                ) { permissions.openSettings("Privacy_Accessibility") }
                PermissionRow(
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
        }
        .formStyle(.grouped)
        .animation(.snappy, value: permissions.allGranted)
        .onAppear {
            permissions.refresh()
            if !permissions.allGranted { permissions.startPolling() }
        }
    }
}

private struct PermissionRow: View {
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
            Text(title)
            Text(subtitle)
        }
    }
}
