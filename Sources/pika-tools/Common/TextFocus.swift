import AppKit
import ApplicationServices

enum TextFocus {
    case none, unknown, typing(AXUIElement), other(AXUIElement)

    #if !APPSTORE
    private static let lock = NSLock()
    private static var owners: Set<ObjectIdentifier> = []
    private static var observer: NSObjectProtocol?
    private static var woken: Set<pid_t> = []
    private static var enabled: [Switched] = [] { didSet { Switched.save(enabled, journalKey) } }
    private static let journalKey = "chromium-accessibility-original"

    struct Switched: Codable, Equatable {
        let bundleID: String
        let pid: pid_t
        let attribute: String
        let before: Bool

        static func putBack(_ entries: [Switched], bundleID: (pid_t) -> String?) -> [Switched] {
            entries.filter { bundleID($0.pid) == $0.bundleID }
        }

        static func load(_ key: String) -> [Switched] {
            UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode([Switched].self, from: $0) } ?? []
        }

        static func save(_ entries: [Switched], _ key: String) {
            UserDefaults.standard.set(entries.isEmpty ? nil : try? JSONEncoder().encode(entries), forKey: key)
        }
    }

    static func putBackAfterCrash() {
        let saved = Switched.load(journalKey)
        let stale = Switched.putBack(saved, bundleID: { NSRunningApplication(processIdentifier: $0)?.bundleIdentifier })
        for entry in stale { setAccessibility(entry.attribute, entry.before, entry.pid) }
        lock.lock()
        Switched.save(enabled, journalKey)
        lock.unlock()
    }

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
        woken = []
        lock.unlock()
        NSWorkspace.shared.notificationCenter.removeObserver(token)
        for entry in restore where NSRunningApplication(processIdentifier: entry.pid)?.isTerminated == false {
            setAccessibility(entry.attribute, entry.before, entry.pid)
        }
        lock.lock()
        enabled.removeAll { restore.contains($0) }
        lock.unlock()
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
        if isOn(pid, attribute) { return .success }
        guard let bundleID = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier else { return .failure }
        let entry = Switched(bundleID: bundleID, pid: pid, attribute: attribute, before: false)
        lock.lock()
        let watching = observer != nil
        if watching { enabled.append(entry) }
        lock.unlock()
        guard watching else { return .success }
        let error = setAccessibility(attribute, true, pid)
        lock.lock()
        if error != .success { enabled.removeAll { $0 == entry } }
        let dropped = error == .success && !enabled.contains(entry)
        lock.unlock()
        if dropped { setAccessibility(attribute, false, pid) }
        return error
    }

    private static func isOn(_ pid: pid_t, _ attribute: String) -> Bool {
        let (value, error) = Self.value(AXUIElementCreateApplication(pid), attribute)
        return error == .success && value as? Bool == true
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
