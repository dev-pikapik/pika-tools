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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(permissions.allGranted ? "Всё готово" : "Дай pika-tools два разрешения")
                .font(.title3.weight(.semibold))

            Text(permissions.allGranted
                 ? "Доступы есть. Ctrl+клик работает как обычный клик, а Ctrl-сочетания не уходят в систему."
                 : "Без них macOS не пустит приложение к кликам и клавишам. Открой System Settings › Privacy & Security и включи pika-tools в двух списках:")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                PermissionRow(
                    title: "Accessibility",
                    subtitle: "Универсальный доступ — чтобы менять клики и клавиши",
                    granted: permissions.accessibility
                ) { permissions.openSettings("Privacy_Accessibility") }
                Divider().padding(.leading, 46)
                PermissionRow(
                    title: "Input Monitoring",
                    subtitle: "Мониторинг ввода — чтобы видеть клики и клавиши",
                    granted: permissions.inputMonitoring
                ) { permissions.openSettings("Privacy_ListenEvent") }
            }
            .glassCard()

            if !permissions.allGranted {
                Text("Проверяю сам каждые 1,5 секунды — перезапускать ничего не нужно. Если pika-tools уже стоит в списке, но не работает, удали его кнопкой «−» и добавь заново.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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
        HStack(spacing: 10) {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(granted ? .green : .orange)
                .frame(width: 28)
                .contentTransition(.symbolEffect(.replace))

            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.body.weight(.medium))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            if !granted {
                Button("Открыть", action: open).glassButtons()
            }
        }
        .padding(10)
    }
}

enum PermissionsWindow {
    private static var window: NSWindow?

    static func show() {
        if window == nil {
            let root = PermissionsView().padding(20).frame(width: 420)
            let window = NSWindow(contentViewController: NSHostingController(rootView: root))
            window.title = "pika-tools"
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            self.window = window
        }
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }
}
