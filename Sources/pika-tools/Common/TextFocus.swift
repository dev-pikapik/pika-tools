import AppKit
import ApplicationServices

enum TextFocus {
    case none, unknown, typing(AXUIElement), other(AXUIElement)

    #if !APPSTORE
    private static let lock = NSLock()
    private static var owners: Set<ObjectIdentifier> = []
    private static var observer: NSObjectProtocol?
    private static var woken: Set<pid_t> = []
    private static var enabled: [Switched] = [] { didSet { Switched.save(stale + enabled, journalKey) } }
    private static var stale: [Switched] = [] { didSet { Switched.save(stale + enabled, journalKey) } }
    private static let running: (pid_t) -> String? = { NSRunningApplication(processIdentifier: $0)?.bundleIdentifier }
    static let puttingBack = DispatchGroup()
    static let journalKey = "chromium-accessibility-original"
    static var write: (String, Bool, pid_t) -> AXError = { attribute, on, pid in
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.15)
        return AXUIElementSetAttributeValue(app, attribute as CFString, on ? kCFBooleanTrue : kCFBooleanFalse)
    }

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

    static func putBackAfterCrash(bundleID: @escaping (pid_t) -> String? = running) {
        lock.lock()
        stale = Switched.putBack(Switched.load(journalKey), bundleID: bundleID)
        let todo = stale
        lock.unlock()
        writeBack(todo, bundleID)
    }

    private static func writeBack(_ todo: [Switched], _ bundleID: @escaping (pid_t) -> String?) {
        puttingBack.enter()
        DispatchQueue.global(qos: .utility).async {
            for entry in todo {
                for _ in 0..<10 {
                    guard bundleID(entry.pid) == entry.bundleID, write(entry.attribute, entry.before, entry.pid) == .cannotComplete else { break }
                    Thread.sleep(forTimeInterval: 1)
                }
                lock.lock()
                stale.removeAll { $0 == entry }
                lock.unlock()
            }
            puttingBack.leave()
        }
    }

    static func watch(_ owner: AnyObject, front: pid_t? = NSWorkspace.shared.frontmostApplication?.processIdentifier) {
        lock.lock()
        owners.insert(ObjectIdentifier(owner))
        if observer == nil {
            observer = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { note in
                if let pid = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.processIdentifier { wake(pid) }
            }
        }
        lock.unlock()
        if let front { wake(front) }
    }

    static func unwatch(_ owner: AnyObject? = nil, bundleID: @escaping (pid_t) -> String? = running) {
        lock.lock()
        if let owner { owners.remove(ObjectIdentifier(owner)) } else { owners.removeAll() }
        guard owners.isEmpty, let token = observer else { return lock.unlock() }
        observer = nil
        woken = []
        let todo = Switched.putBack(enabled, bundleID: bundleID)
        stale += todo
        enabled = []
        lock.unlock()
        NSWorkspace.shared.notificationCenter.removeObserver(token)
        writeBack(todo, bundleID)
    }

    private static func wake(_ pid: pid_t) {
        lock.lock()
        let isNew = observer != nil && woken.insert(pid).inserted
        lock.unlock()
        guard isNew, isChromium(pid), let bundleID = NSRunningApplication(processIdentifier: pid)?.bundleIdentifier else { return }
        DispatchQueue.global(qos: .utility).async {
            for _ in 0..<10 {
                var error = enable("AXManualAccessibility", pid, bundleID)
                if error != .success { error = enable("AXEnhancedUserInterface", pid, bundleID) }
                if error != .cannotComplete { return }
                Thread.sleep(forTimeInterval: 1)
            }
            lock.lock()
            woken.remove(pid)
            lock.unlock()
        }
    }

    static func enable(_ attribute: String, _ pid: pid_t, _ bundleID: String) -> AXError {
        puttingBack.wait()
        if isOn(pid, attribute) { return .success }
        let entry = Switched(bundleID: bundleID, pid: pid, attribute: attribute, before: false)
        lock.lock()
        let watching = observer != nil
        if watching { enabled.append(entry) }
        lock.unlock()
        guard watching else { return .success }
        let error = write(attribute, true, pid)
        lock.lock()
        if error != .success { enabled.removeAll { $0 == entry } }
        let dropped = error == .success && !enabled.contains(entry)
        lock.unlock()
        if dropped { _ = write(attribute, false, pid) }
        return error
    }

    private static func isOn(_ pid: pid_t, _ attribute: String) -> Bool {
        let (value, error) = Self.value(AXUIElementCreateApplication(pid), attribute)
        return error == .success && value as? Bool == true
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
