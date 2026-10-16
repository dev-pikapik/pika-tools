import AppKit
import Carbon.HIToolbox

enum BackForward {
    private enum Fallback {
        case swipe, keys(CGEventFlags), native
    }

    private static let queue = DispatchQueue(label: "pikapik.back-forward", qos: .userInteractive)
    private static let swipeApps = ["com.apple.", "com.binarynights.ForkLift", "org.mozilla.firefox", "com.operasoftware.Opera"]
    private static let commandBracket = ["com.apple.Music", "com.apple.AppStore", "com.apple.systempreferences", "com.apple.iBooksX", "com.apple.TV", "com.apple.Preview", "com.apple.AddressBook"]
    private static let optionCommandBracket = ["com.apple.Notes", "com.apple.freeform"]

    static func prepare() {
        #if !APPSTORE
        queue.async { AXSearch.prepare() }
        #endif
    }

    static func target(at point: CGPoint) -> NSRunningApplication? {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
        for window in windows {
            guard window[kCGWindowLayer as String] as? Int == 0,
                  let bounds = (window[kCGWindowBounds as String] as? NSDictionary).flatMap({ CGRect(dictionaryRepresentation: $0 as CFDictionary) }),
                  bounds.contains(point),
                  let pid = window[kCGWindowOwnerPID as String] as? pid_t else { continue }
            return NSRunningApplication(processIdentifier: pid)
        }
        return NSWorkspace.shared.frontmostApplication
    }

    static func takes(_ app: NSRunningApplication) -> Bool {
        guard app.processIdentifier != getpid() else { return false }
        #if APPSTORE
        if case .native = fallback(for: app) { return false }
        #endif
        return true
    }

    static func go(forward: Bool, at point: CGPoint, in app: NSRunningApplication) {
        let pid = app.processIdentifier
        let fallback = fallback(for: app)
        queue.async {
            #if !APPSTORE
            if AXSearch.press(pid: pid, forward: forward) { return }
            #endif
            switch fallback {
            case .swipe: swipe(forward: forward)
            case .keys(let flags): press(flags, forward: forward)
            case .native: click(forward: forward, at: point)
            }
        }
    }

    private static func fallback(for app: NSRunningApplication) -> Fallback {
        let id = app.bundleIdentifier ?? ""
        if optionCommandBracket.contains(id) { return .keys([.maskCommand, .maskAlternate]) }
        if commandBracket.contains(id) { return .keys(.maskCommand) }
        if swipeApps.contains(where: id.hasPrefix) { return .swipe }
        return .native
    }

    private static func swipe(forward: Bool) {
        for phase: Int64 in [1, 4] {
            guard let event = CGEvent(source: nil), let type = CGEventType(rawValue: UInt32(NSEvent.EventType.gesture.rawValue)) else { return }
            event.type = type
            event.setIntegerValueField(CGEventField(rawValue: 110)!, value: 16)
            event.setIntegerValueField(CGEventField(rawValue: 132)!, value: phase)
            event.setIntegerValueField(CGEventField(rawValue: 115)!, value: forward ? 8 : 4)
            event.markPikapik()
            event.post(tap: .cgSessionEventTap)
        }
    }

    static func press(_ flags: CGEventFlags, forward: Bool) {
        let key = forward ? kVK_ANSI_RightBracket : kVK_ANSI_LeftBracket
        CGEvent.tapPikapikKey(key, flags: flags)
    }

    private static func click(forward: Bool, at point: CGPoint) {
        for type in [CGEventType.otherMouseDown, .otherMouseUp] {
            guard let event = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: point, mouseButton: .center) else { return }
            event.setIntegerValueField(.mouseEventButtonNumber, value: forward ? 4 : 3)
            event.setIntegerValueField(.mouseEventClickState, value: 1)
            event.markPikapik()
            event.post(tap: .cgSessionEventTap)
        }
    }
}

#if !APPSTORE
private enum AXSearch {
    private static var found: [pid_t: [Bool: AXUIElement]] = [:]
    private static let symbols: [Bool: Set<String>] = [
        false: ["chevron.backward", "chevron.left", "arrow.backward", "arrow.left"],
        true: ["chevron.forward", "chevron.right", "arrow.forward", "arrow.right"],
    ]
    private static let names: [Bool: Set<String>] = {
        var result: [Bool: Set<String>] = [:]
        for forward in [false, true] {
            let key = forward ? "Forward" : "Back"
            var titles: Set<String> = [key, "Go \(key)"]
            for language in Bundle.main.localizations {
                guard let path = Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
                      let title = NSDictionary(contentsOfFile: path)?[key] as? String else { continue }
                titles.insert(title)
            }
            result[forward] = Set(titles.map(fold))
        }
        return result
    }()

    static func prepare() { _ = names }

    static func press(pid: pid_t, forward: Bool) -> Bool {
        guard let item = known(pid, forward) ?? search(AXUIElementCreateApplication(pid), pid, forward) else { return false }
        if value(item, kAXEnabledAttribute) as? Bool == false { return true }
        let result = AXUIElementPerformAction(item, kAXPressAction as CFString)
        return result == .success || result == .cannotComplete
    }

    private static func known(_ pid: pid_t, _ forward: Bool) -> AXUIElement? {
        guard let item = found[pid]?[forward] else { return nil }
        if value(item, kAXTitleAttribute) != nil { return item }
        found[pid] = nil
        return nil
    }

    private static func search(_ app: AXUIElement, _ pid: pid_t, _ forward: Bool) -> AXUIElement? {
        let deadline = Date().addingTimeInterval(0.8)
        let titles = names[forward] ?? []
        if let bar = element(app, kAXMenuBarAttribute) {
            for top in children(bar).dropFirst() {
                for menu in children(top) {
                    for item in children(menu).prefix(80) {
                        if Date() > deadline { return nil }
                        if let title = value(item, kAXTitleAttribute) as? String, titles.contains(fold(title)),
                           (value(item, kAXMenuItemCmdCharAttribute) as? String)?.first?.isLetter != true {
                            found[pid, default: [:]][forward] = item
                            return item
                        }
                    }
                }
            }
        }
        guard let window = element(app, kAXFocusedWindowAttribute) ?? element(app, kAXMainWindowAttribute) else { return nil }
        for bar in children(window) where value(bar, kAXRoleAttribute) as? String == kAXToolbarRole {
            if let button = button(in: bar, titles, symbols[forward] ?? [], depth: 3) { return button }
        }
        return nil
    }

    private static func button(in parent: AXUIElement, _ titles: Set<String>, _ symbols: Set<String>, depth: Int) -> AXUIElement? {
        for child in children(parent) {
            if value(child, kAXRoleAttribute) as? String == kAXButtonRole {
                let labels = [kAXDescriptionAttribute, kAXTitleAttribute].compactMap { value(child, $0) as? String }
                if labels.contains(where: { titles.contains(fold($0)) }) { return child }
                if let id = value(child, kAXIdentifierAttribute) as? String, symbols.contains(id) { return child }
            }
            if depth > 1, let match = button(in: child, titles, symbols, depth: depth - 1) { return match }
        }
        return nil
    }

    private static func fold(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func value(_ element: AXUIElement, _ attribute: String) -> CFTypeRef? {
        AXUIElementSetMessagingTimeout(element, 0.25)
        var value: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success ? value : nil
    }

    private static func element(_ parent: AXUIElement, _ attribute: String) -> AXUIElement? {
        guard let value = value(parent, attribute), CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
        return (value as! AXUIElement)
    }

    private static func children(_ parent: AXUIElement) -> [AXUIElement] {
        value(parent, kAXChildrenAttribute) as? [AXUIElement] ?? []
    }
}
#endif
