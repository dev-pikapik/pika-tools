import ApplicationServices

enum TextFocus {
    case none, unknown, typing, other(AXUIElement)

    init(_ pid: pid_t) {
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
        self = typing ? .typing : .other(element)
    }

    static func value(_ element: AXUIElement, _ attribute: String) -> (CFTypeRef?, AXError) {
        AXUIElementSetMessagingTimeout(element, 0.15)
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        return (value, error)
    }
}
