import AppKit
import ApplicationServices
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class QuitOnCloseTool: Tool {
    let id = "quit-on-close"
    let icon = "xmark.app"
    var title: String { String(localized: "Quit when the last window closes") }
    let tab = SettingsTab.windows

    private static let excludedKey = "quit-on-close-excluded"
    private static let alwaysExcluded: Set<String> = ["com.apple.finder", Bundle.main.bundleIdentifier ?? ""]

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var excluded: [String] {
        didSet { UserDefaults.standard.set(excluded, forKey: Self.excludedKey) }
    }

    @ObservationIgnored fileprivate var observers: [pid_t: AXObserver] = [:]
    @ObservationIgnored private var tokens: [NSObjectProtocol] = []

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
    }

    func load() {
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(QuitOnCloseSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && excluded.isEmpty }

    func reset() {
        isEnabled = false
        excluded = []
    }

    func refresh() {
        stop()
        guard isEnabled, AXIsProcessTrusted() else { return }
        let center = NSWorkspace.shared.notificationCenter
        tokens = [
            center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] note in
                guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self?.watch(app) }
            },
            center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { [weak self] note in
                guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
                self?.unwatch(app.processIdentifier)
            },
        ]
        NSWorkspace.shared.runningApplications.forEach(watch)
        isActive = true
    }

    private func stop() {
        tokens.forEach(NSWorkspace.shared.notificationCenter.removeObserver)
        tokens = []
        observers.keys.forEach(unwatch)
        isActive = false
    }

    private func watch(_ app: NSRunningApplication) {
        let pid = app.processIdentifier
        guard observers[pid] == nil, !app.isTerminated, app.activationPolicy == .regular,
              !Self.alwaysExcluded.contains(app.bundleIdentifier ?? "") else { return }
        var observer: AXObserver?
        guard AXObserverCreate(pid, quitOnCloseCallback, &observer) == .success, let observer else { return }
        let element = AXUIElementCreateApplication(pid)
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        AXObserverAddNotification(observer, element, kAXWindowCreatedNotification as CFString, refcon)
        AXObserverAddNotification(observer, element, kAXFocusedWindowChangedNotification as CFString, refcon)
        AXObserverAddNotification(observer, element, kAXMainWindowChangedNotification as CFString, refcon)
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .defaultMode)
        observers[pid] = observer
        Self.windows(of: element).forEach { track($0, observer: observer) }
    }

    private func unwatch(_ pid: pid_t) {
        guard let observer = observers.removeValue(forKey: pid) else { return }
        CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .defaultMode)
    }

    fileprivate func track(_ window: AXUIElement, observer: AXObserver) {
        guard Self.string(window, kAXSubroleAttribute) == kAXStandardWindowSubrole as String else { return }
        AXObserverAddNotification(observer, window, kAXUIElementDestroyedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
    }

    fileprivate func windowClosed(observer: AXObserver) {
        guard let pid = observers.first(where: { $0.value === observer })?.key else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.quitIfNoWindows(pid)
        }
    }

    private func quitIfNoWindows(_ pid: pid_t) {
        guard isEnabled, let app = NSRunningApplication(processIdentifier: pid), !app.isTerminated,
              !excluded.contains(app.bundleIdentifier ?? ""),
              !Self.hasWindows(pid)
        else { return }
        app.terminate()
    }

    private static func windows(of app: AXUIElement) -> [AXUIElement] {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &value) == .success else { return [] }
        return value as? [AXUIElement] ?? []
    }

    private static func string(_ element: AXUIElement, _ attribute: String) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else { return nil }
        return value as? String
    }

    private static func hasWindows(_ pid: pid_t) -> Bool {
        let list = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        let ids = list.compactMap { info -> Int? in
            guard info[kCGWindowOwnerPID as String] as? pid_t == pid,
                  info[kCGWindowLayer as String] as? Int == 0,
                  (info[kCGWindowAlpha as String] as? Double ?? 1) > 0,
                  let bounds = info[kCGWindowBounds as String] as? [String: CGFloat],
                  (bounds["Width"] ?? 0) >= 100, (bounds["Height"] ?? 0) >= 100
            else { return nil }
            return info[kCGWindowNumber as String] as? Int
        }
        return ids.contains { id in
            let spaces = CGSCopySpacesForWindows(CGSMainConnectionID(), 7, [id] as CFArray)?.takeRetainedValue() as? [Any]
            return !(spaces ?? []).isEmpty
        }
    }

    func exclude() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = true
        panel.prompt = String(localized: "Add")
        NSApp.activate()
        guard panel.runModal() == .OK else { return }
        let ids = panel.urls.compactMap { Bundle(url: $0)?.bundleIdentifier }
        excluded += ids.filter { !excluded.contains($0) && !Self.alwaysExcluded.contains($0) }
    }
}

@_silgen_name("CGSMainConnectionID") private func CGSMainConnectionID() -> Int32
@_silgen_name("CGSCopySpacesForWindows") private func CGSCopySpacesForWindows(_ cid: Int32, _ mask: Int32, _ windows: CFArray) -> Unmanaged<CFArray>?

private func quitOnCloseCallback(observer: AXObserver, element: AXUIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) {
    guard let refcon else { return }
    let tool = Unmanaged<QuitOnCloseTool>.fromOpaque(refcon).takeUnretainedValue()
    if notification as String == kAXWindowCreatedNotification {
        tool.track(element, observer: observer)
    } else {
        tool.windowClosed(observer: observer)
    }
}

private struct QuitOnCloseSettings: View {
    @Bindable var tool: QuitOnCloseTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Closing an app’s last window quits the app. Finder stays open."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            LabeledContent {
                Button("Add App…") { tool.exclude() }
            } label: {
                Text("Never quit these apps")
                if tool.excluded.isEmpty {
                    Text("No apps yet")
                }
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Never quit these apps"))
            ForEach(tool.excluded, id: \.self) { id in
                AppRow(bundleID: id) { tool.excluded.removeAll { $0 == id } }
            }
        }
    }
}

private struct AppRow: View {
    let bundleID: String
    let remove: () -> Void

    var body: some View {
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        LabeledContent {
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove")
        } label: {
            HStack(spacing: 8) {
                Image(nsImage: url.map { NSWorkspace.shared.icon(forFile: $0.path) } ?? NSImage())
                    .resizable()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                Text(verbatim: url.map { FileManager.default.displayName(atPath: $0.path) } ?? bundleID)
            }
        }
    }
}
