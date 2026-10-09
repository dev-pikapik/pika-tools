import AppKit

@Observable
final class Background: NSObject {
    static let shared = Background()
    static let key = "keep-running"
    private static let explainedKey = "keep-running-explained"

    var iconShown = true
    @ObservationIgnored var quitting = false
    @ObservationIgnored private var alert: NSAlert?

    private override init() {}

    static var isOn: Bool { UserDefaults.standard.object(forKey: key) as? Bool ?? true }

    static var isOutsideQuit: Bool {
        guard let event = NSAppleEventManager.shared().currentAppleEvent,
              event.eventClass == AEEventClass(kCoreEventClass), event.eventID == AEEventID(kAEQuitApplication)
        else { return false }
        if event.attributeDescriptor(forKeyword: AEKeyword(kAEQuitReason)) != nil { return true }
        let sender = event.attributeDescriptor(forKeyword: AEKeyword(keySenderPIDAttr)).flatMap {
            NSRunningApplication(processIdentifier: $0.int32Value)?.bundleIdentifier
        }
        return sender != "com.apple.dock"
    }

    static func quit() {
        shared.quitting = true
        NSApp.terminate(nil)
    }

    static func quitCompletely() {
        KeepAwake.shared.set(.off)
        quit()
    }

    func hide() {
        NSApp.windows.filter { $0.isVisible && $0.styleMask.contains(.closable) && !($0 is NSPanel) }.forEach { $0.close() }
        iconShown = false
        NSApp.setActivationPolicy(.accessory)
        guard !UserDefaults.standard.bool(forKey: Self.explainedKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.explainedKey)
        DispatchQueue.main.async(execute: explain)
    }

    private func explain() {
        let alert = NSAlert()
        alert.messageText = String(localized: "pikapik keeps working in the background")
        alert.informativeText = String(localized: "Shortcuts, Keep Awake and the pet stay on. Open pikapik again to bring back its menu bar icon. To quit completely, hold Option when you choose Quit.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.addButton(withTitle: String(localized: "Quit Completely"))
        zip(alert.buttons, [#selector(dismiss), #selector(quitFromAlert)]).forEach { $0.target = self; $0.action = $1 }
        alert.layout()
        alert.window.center()
        alert.window.level = .floating
        self.alert = alert
        NSApp.activate()
        alert.window.makeKeyAndOrderFront(nil)
    }

    @objc private func dismiss() {
        alert?.window.close()
        alert = nil
    }

    @objc private func quitFromAlert() { Self.quitCompletely() }
}
