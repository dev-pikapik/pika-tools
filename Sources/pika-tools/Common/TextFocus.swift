import AppKit
import ApplicationServices

enum TextFocus {
    case none, unknown, typing(AXUIElement), other(AXUIElement)

    #if !APPSTORE
    private static let lock = NSLock()
    private static var woken: Set<pid_t> = []
    private static let observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { note in
        if let pid = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.processIdentifier { wake(pid) }
    }

    static func watch() {
        _ = observer
        if let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier { wake(pid) }
    }

    private static func wake(_ pid: pid_t) {
        lock.lock()
        let isNew = woken.insert(pid).inserted
        lock.unlock()
        guard isNew, isChromium(pid) else { return }
        DispatchQueue.global(qos: .utility).async {
            let app = AXUIElementCreateApplication(pid)
            AXUIElementSetMessagingTimeout(app, 0.15)
            for _ in 0..<10 {
                var error = AXUIElementSetAttributeValue(app, "AXManualAccessibility" as CFString, kCFBooleanTrue)
                if error != .success { error = AXUIElementSetAttributeValue(app, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue) }
                if error != .cannotComplete { return }
                Thread.sleep(forTimeInterval: 1)
            }
            lock.lock()
            woken.remove(pid)
            lock.unlock()
        }
    }

    private static func isChromium(_ pid: pid_t) -> Bool {
        guard let frameworks = NSRunningApplication(processIdentifier: pid)?.bundleURL?.appendingPathComponent("Contents/Frameworks").path else { return false }
        return ((try? FileManager.default.contentsOfDirectory(atPath: frameworks)) ?? []).contains { $0.hasSuffix(" Framework.framework") }
    }
    #endif

    init(_ pid: pid_t) {
        #if !APPSTORE
        Self.wake(pid)
        #endif
        let (focused, error) = Self.value(AXUIElementCreateApplication(pid), kAXFocusedUIElementAttribute)
        if error == .noValue {
            self = .none
            return
        }
        guard error == .success, let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else {
            self = .unknown
            return
        }
        let element = focused as! AXUIElement

        let (role, roleError) = Self.value(element, kAXRoleAttribute)
        guard roleError == .success, let role = role as? String else {
            self = .unknown
            return
        }
        let subrole = Self.value(element, kAXSubroleAttribute).0 as? String
        let typing = [kAXTextFieldRole, kAXTextAreaRole, kAXComboBoxRole].contains(role) || subrole == kAXSearchFieldSubrole
        self = typing ? .typing(element) : .other(element)
    }

    static func value(_ element: AXUIElement, _ attribute: String) -> (CFTypeRef?, AXError) {
        AXUIElementSetMessagingTimeout(element, 0.15)
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return (value, error)
    }
}
