import AppKit
import ApplicationServices

enum TextFocus {
    case none, unknown, typing(AXUIElement), other(AXUIElement)

    #if !APPSTORE
    private static let lock = NSLock()
    private static var owners: Set<ObjectIdentifier> = []
    private static var observer: NSObjectProtocol?
    private static var woken: Set<pid_t> = []
    private static var enabled: [(pid: pid_t, attribute: String)] = []

    static func watch(_ owner: AnyObject) {
        lock.lock()
        owners.insert(ObjectIdentifier(owner))
        if observer == nil {
            observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { note in
                if let pid = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.processIdentifier { wake(pid) }
            }
        }
        lock.unlock()
        if let pid = NSWorkspace.shared.frontmostApplication?.processIdentifier { wake(pid) }
    }

    static func unwatch(_ owner: AnyObject? = nil) {
        lock.lock()
        if let owner { owners.remove(ObjectIdentifier(owner)) } else { owners.removeAll() }
        guard owners.isEmpty, let token = observer else { return lock.unlock() }
        observer = nil
        let restore = enabled
        enabled = []
        woken = []
        lock.unlock()
        NSWorkspace.shared.notificationCenter.removeObserver(token)
        for (pid, attribute) in restore where NSRunningApplication(processIdentifier: pid)?.isTerminated == false {
            setAccessibility(attribute, false, pid)
        }
    }

    private static func wake(_ pid: pid_t) {
        lock.lock()
        let isNew = observer != nil && woken.insert(pid).inserted
        lock.unlock()
        guard isNew, isChromium(pid) else { return }
        DispatchQueue.global(qos: .utility).async {
            for _ in 0..<10 {
                var error = enable("AXManualAccessibility", pid)
                if error != .success { error = enable("AXEnhancedUserInterface", pid) }
                if error != .cannotComplete { return }
                Thread.sleep(forTimeInterval: 1)
            }
            lock.lock()
            woken.remove(pid)
            lock.unlock()
        }
    }

    private static func enable(_ attribute: String, _ pid: pid_t) -> AXError {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.15)
        var current: CFTypeRef?
        if AXUIElementCopyAttributeValue(app, attribute as CFString, &current) == .success, current as? Bool == true { return .success }
        let error = setAccessibility(attribute, true, pid)
        guard error == .success else { return error }
        lock.lock()
        let watching = observer != nil
        if watching { enabled.append((pid, attribute)) }
        lock.unlock()
        if !watching { setAccessibility(attribute, false, pid) }
        return error
    }

    @discardableResult
    private static func setAccessibility(_ attribute: String, _ on: Bool, _ pid: pid_t) -> AXError {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.15)
        return AXUIElementSetAttributeValue(app, attribute as CFString, on ? kCFBooleanTrue : kCFBooleanFalse)
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
