import Carbon
import SwiftUI

@Observable
final class SystemShortcuts {
    static let shared = SystemShortcuts()

    struct Place {
        let url: URL
        let hint: String?
        var title: String?
    }

    private(set) var hotKeys: NSDictionary = [:]
    private(set) var finderCut: Shortcut? = .cut
    @ObservationIgnored private var observers: [Any] = []

    var finderCutText: String { finderCut?.text ?? "" }

    private init() {
        refresh()
        let refresh: (Notification) -> Void = { [weak self] _ in self?.refresh() }
        observers = [NSApplication.didBecomeActiveNotification, NSWindow.didBecomeKeyNotification].map {
            NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main, using: refresh)
        } + [
            DistributedNotificationCenter.default().addObserver(
                forName: .init("com.apple.userkeyequivalentsdidchange"), object: nil, queue: .main, using: refresh
            ),
        ]
    }

    func refresh() {
        ["com.apple.symbolichotkeys", "com.apple.finder"].forEach { CFPreferencesAppSynchronize($0 as CFString) }
        let hotKeys = CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString, "com.apple.symbolichotkeys" as CFString) as? NSDictionary ?? [:]
        if hotKeys != self.hotKeys { self.hotKeys = hotKeys }
        let domains = ["com.apple.finder" as CFString, kCFPreferencesAnyApplication].map {
            CFPreferencesCopyValue("NSUserKeyEquivalents" as CFString, $0, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [String: Any]
        }
        let cut = Shortcut.equivalent(for: Self.cutTitle, in: domains).map { Shortcut.menu($0, code: Keyboard.code)?.shortcut } ?? .cut
        if cut != finderCut { finderCut = cut }
    }

    func shortcut(_ id: Int32) -> Shortcut.System {
        let paused = HotKeyTrace.ids(.standard) ?? []
        let live = SymbolicHotKeys.available
            ? (paused.contains(id) || SymbolicHotKeys.isEnabled(id), SymbolicHotKeys.value(id).map { [Int($0.character), Int($0.key), Int($0.modifiers)] })
            : nil
        return Shortcut.system(hotKeys[String(id)], live: live)
    }

    func text(_ id: Int32) -> String? {
        switch shortcut(id) {
        case let .on(character, shortcut): Shortcut.text(character: character, key: shortcut.key, modifiers: shortcut.modifiers) ?? shortcut.text
        case .off: ""
        case .unknown: nil
        }
    }

    func taken() -> [(message: String, shortcut: Shortcut)] {
        (0..<300).compactMap { id in
            guard case let .on(_, shortcut) = shortcut(Int32(id)) else { return nil }
            let message = Self.table.names[id].map { String(localized: "Already used for “\($0)”") } ?? String(localized: "Your Mac already uses this shortcut")
            return (message, shortcut)
        }
    }

    var pausable: [Int32] {
        (0..<300).map(Int32.init).filter { !GameRules.neverBlocked.contains($0) && SymbolicHotKeys.isEnabled($0) }
    }

    private static var cutTitle: String {
        let languages = CFPreferencesCopyAppValue("AppleLanguages" as CFString, "com.apple.finder" as CFString) as? [String]
        guard let finder = Bundle(path: "/System/Library/CoreServices/Finder.app"),
              let language = Bundle.preferredLocalizations(from: finder.localizations, forPreferences: languages).first,
              let path = finder.path(forResource: "MenuBar", ofType: "strings", inDirectory: nil, forLocalization: language),
              let title = NSDictionary(contentsOfFile: path)?["160.title"] as? String
        else { return "Cut" }
        return title
    }

    static func place(_ ids: [Int32]) -> Place {
        place(section: ids.lazy.compactMap { table.sections[Int($0)] }.first)
    }

    static func place(section: String?) -> Place {
        let title = section.flatMap { table.titles[$0] }
        if let url = Shortcut.settingsLink(section, anchors: table.anchors) {
            guard url.query == "Shortcuts" else { return Place(url: url, hint: nil) }
            return Place(url: url, hint: title.map { String(localized: "In System Settings, click “\($0)”.") }, title: title)
        }
        let button = table.button
        let hint = title.map { String(localized: "In System Settings, click “\(button)”, then “\($0)”.") }
        return Place(url: Shortcut.keyboardSettings, hint: hint ?? String(localized: "In System Settings, click “\(button)”."))
    }

    static func open(_ place: Place, failed: @escaping () -> Void) {
        NSWorkspace.shared.open(place.url)
        guard place.hint != nil else { return }
        if let title = place.title, AXIsProcessTrusted() {
            let sections = Set(table.titles.values)
            DispatchQueue.global(qos: .userInitiated).async {
                let done = select(title, sections: sections)
                DispatchQueue.main.async { if !done { failed() } }
            }
        } else if NSApp.isActive {
            var observer: Any?
            observer = NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { _ in
                observer.map(NotificationCenter.default.removeObserver)
                failed()
            }
        } else {
            failed()
        }
    }

    private static func select(_ title: String, sections: Set<String>) -> Bool {
        func value<T>(_ element: AXUIElement, _ name: String) -> T? {
            var value: CFTypeRef?
            return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value as? T : nil
        }
        func children(_ element: AXUIElement) -> [AXUIElement] { value(element, kAXChildrenAttribute) ?? [] }
        func tables(_ element: AXUIElement, _ depth: Int) -> [AXUIElement] {
            let role: String? = value(element, kAXRoleAttribute)
            if role == kAXOutlineRole || role == kAXTableRole { return [element] }
            return depth == 0 ? [] : children(element).flatMap { tables($0, depth - 1) }
        }
        func text(_ element: AXUIElement, _ depth: Int) -> String? {
            if value(element, kAXRoleAttribute) == kAXStaticTextRole, let text: String = value(element, kAXValueAttribute), !text.isEmpty { return text }
            return depth == 0 ? nil : children(element).lazy.compactMap { text($0, depth - 1) }.first
        }
        let deadline = Date() + 4
        var stable = 0
        while Date() < deadline {
            Thread.sleep(forTimeInterval: 0.15)
            guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.systempreferences").first else { continue }
            let windows: [AXUIElement] = value(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) ?? []
            let found = windows.flatMap(children).filter { value($0, kAXRoleAttribute) == kAXSheetRole }.flatMap { tables($0, 10) }
            let rows = found.map { (value($0, kAXRowsAttribute) ?? []) as [AXUIElement] }
            let titles = rows.map { $0.map { text($0, 4) ?? value($0, kAXDescriptionAttribute) ?? "" } }
            guard let match = Shortcut.sheetRow(titles, title: title, sections: sections) else {
                stable = 0
                continue
            }
            let table = found[match.table], row = rows[match.table][match.row]
            let selected: [AXUIElement] = value(table, kAXSelectedRowsAttribute) ?? []
            if value(row, kAXSelectedAttribute) == true || selected.contains(row) {
                stable += 1
                if stable == 3 { return true }
                continue
            }
            stable = 0
            if AXUIElementSetAttributeValue(row, kAXSelectedAttribute as CFString, kCFBooleanTrue) != .success,
               AXUIElementSetAttributeValue(table, kAXSelectedRowsAttribute as CFString, [row] as CFArray) != .success {
                AXUIElementPerformAction(row, kAXPressAction as CFString)
            }
        }
        return false
    }

    private static let table: (names: [Int: String], sections: [Int: String], titles: [String: String], button: String, anchors: Set<String>) = {
        let button = "Keyboard Shortcuts…"
        guard let bundle = Bundle(path: "/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex") else { return ([:], [:], [:], button, []) }
        func strings(_ name: String) -> [String: String] {
            let table = bundle.url(forResource: name, withExtension: "loctable").flatMap { NSDictionary(contentsOf: $0) as? [String: Any] } ?? [:]
            let language = Bundle.preferredLocalizations(from: Array(table.keys), forPreferences: CFPreferencesCopyAppValue("AppleLanguages" as CFString, "com.apple.systempreferences" as CFString) as? [String]).first ?? "en"
            return table[language] as? [String: String] ?? [:]
        }
        func list(_ name: String) -> [[String: Any]] {
            bundle.url(forResource: name, withExtension: "xml").flatMap { NSArray(contentsOf: $0) as? [[String: Any]] } ?? []
        }
        let localized = strings("DefaultShortcutsTable")
        func title(_ item: [String: Any]) -> String? {
            (item["name"] as? String).map { $0.replacingOccurrences(of: "DO_NOT_LOCALIZE: ", with: "") }.map { localized[$0] ?? $0 }
        }
        var names: [Int: String] = [:], sections: [Int: String] = [:], titles: [String: String] = [:]
        func walk(_ items: [[String: Any]], _ section: String) {
            for item in items {
                if let name = title(item) {
                    for key in ["sybmolichotkey", "slow_sybmolichotkey", "prefs_sybmolichotkey"] {
                        if let id = item[key] as? Int {
                            names[id] = name
                            sections[id] = section
                        }
                    }
                }
                walk(item["elements"] as? [[String: Any]] ?? [], section)
            }
        }
        for group in list("DefaultShortcutsTable") {
            let section = group["identifier"] as? String ?? ""
            titles[section] = title(group)
            walk([group], section)
        }
        for item in list("DefaultSpacesShortcuts") {
            if let id = item["sybmolichotkey"] as? Int { sections[id] = "expose" }
        }
        let anchors = bundle.url(forResource: "Keyboard", withExtension: "searchTerms").flatMap { NSDictionary(contentsOf: $0)?.allKeys as? [String] } ?? []
        return (names, sections, titles, strings("Localizable")[button] ?? button, Set(anchors))
    }()
}

enum Keyboard {
    static func character(_ key: UInt16) -> UInt16 {
        characters([key])[0]
    }

    static func code(_ character: Character) -> UInt16? {
        let keys = (0..<128).map(UInt16.init)
        let target = character.lowercased()
        return zip(keys, characters(keys)).first { Unicode.Scalar($0.1).map { String($0).lowercased() } == target }?.0
    }

    private static func characters(_ keys: [UInt16]) -> [UInt16] {
        guard let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
              let pointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        else { return keys.map { _ in 0xFFFF } }
        let data = Unmanaged<CFData>.fromOpaque(pointer).takeUnretainedValue() as Data
        return data.withUnsafeBytes { bytes in
            let layout = bytes.bindMemory(to: UCKeyboardLayout.self).baseAddress!
            return keys.map { key in
                var dead: UInt32 = 0
                var length = 0
                var output = [UniChar](repeating: 0, count: 4)
                let status = UCKeyTranslate(
                    layout, key, UInt16(kUCKeyActionDisplay), 0, UInt32(LMGetKbdType()),
                    OptionBits(kUCKeyTranslateNoDeadKeysBit), &dead, output.count, &length, &output
                )
                return status == noErr && length > 0 ? output[0] : 0xFFFF
            }
        }
    }
}

extension Shortcut {
    var text: String {
        Shortcut.text(character: Keyboard.character(key), key: key, modifiers: modifiers) ?? "?"
    }
}

enum ShortcutRecorder {
    private static var tap: CFMachPort?
    private static var source: CFRunLoopSource?
    private static var monitor: Any?
    private static var handler: ((UInt16, UInt64) -> Void)?
    private static let trace = HotKeyTrace()

    static func start(_ handler: @escaping (UInt16, UInt64) -> Void) {
        stop()
        self.handler = handler
        trace.disable(SystemShortcuts.shared.pausable)
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue)
        if let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask,
            callback: { _, type, event, _ in
                guard type == .keyDown || type == .keyUp else {
                    if type == .tapDisabledByTimeout, let tap = ShortcutRecorder.tap { CGEvent.tapEnable(tap: tap, enable: true) }
                    return Unmanaged.passUnretained(event)
                }
                if type == .keyDown, event.getIntegerValueField(.keyboardEventAutorepeat) == 0 {
                    let key = UInt16(truncatingIfNeeded: event.getIntegerValueField(.keyboardEventKeycode))
                    let flags = event.flags.rawValue
                    DispatchQueue.main.async { ShortcutRecorder.handler?(key, flags) }
                }
                return nil
            },
            userInfo: nil
        ) {
            let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            self.tap = tap
            self.source = source
        } else {
            monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
                if event.type == .keyDown, !event.isARepeat { ShortcutRecorder.handler?(event.keyCode, UInt64(event.modifierFlags.rawValue)) }
                return nil
            }
        }
    }

    static func stop() {
        guard handler != nil else { return }
        handler = nil
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        if let monitor { NSEvent.removeMonitor(monitor) }
        tap = nil
        source = nil
        monitor = nil
        trace.restore()
    }
}

struct CapsButtonStyle: ButtonStyle {
    var active = false

    func makeBody(configuration: Configuration) -> some View {
        Caps(configuration: configuration, active: active)
    }

    private struct Caps: View {
        let configuration: Configuration
        let active: Bool
        @State private var hovering = false

        var body: some View {
            configuration.label
                .padding(3)
                .background {
                    if hovering || active {
                        RoundedRectangle(cornerRadius: 9, style: .continuous).fill(.fill.tertiary)
                    }
                }
                .padding(-3)
                .opacity(configuration.isPressed ? 0.6 : 1)
                .contentShape(Rectangle())
                .onHover { hovering = $0 }
        }
    }
}

struct ShortcutLabel: View {
    @Binding var shortcut: Shortcut
    let standard: Shortcut
    let title: Text
    let subtitle: Text
    let others: [(message: String, shortcut: Shortcut)]
    @State private var recording = false
    @State private var pending: (shortcut: Shortcut, message: String)?

    var body: some View {
        HStack(spacing: 12) {
            Button { recording ? finish() : record() } label: {
                if recording {
                    Text("Type shortcut")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .frame(minHeight: 24)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(Color.accentColor, lineWidth: 1.5)
                        }
                } else {
                    KeyCaps(keys: [shortcut.text])
                }
            }
            .buttonStyle(CapsButtonStyle(active: recording))
            .help(Text("Click and press new keys. Esc cancels, ⌫ brings back the usual keys."))
            .accessibilityLabel(recording ? Text("Type shortcut") : Text(verbatim: shortcut.text))
            .accessibilityHint(Text("Click and press new keys. Esc cancels, ⌫ brings back the usual keys."))
            RowLabel(title, pending.map { Text($0.message) } ?? subtitle)
            if let pending {
                Spacer(minLength: 0)
                Group {
                    Button("Use Anyway") { use(pending.shortcut) }
                    Button("Cancel") { self.pending = nil }
                }
                .controlSize(.small)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in finish() }
        .onDisappear(perform: finish)
    }

    private func record() {
        let taken = others + SystemShortcuts.shared.taken()
        pending = nil
        recording = true
        ShortcutRecorder.start { key, flags in
            let new = Shortcut(key: key, modifiers: flags)
            if new.modifiers == 0, key == 53 { return finish() }
            if new.modifiers == 0, [51, 117].contains(key) { return use(standard) }
            guard new.isUsable, ![Shortcut(key: 12, modifiers: 0x100000), Shortcut(key: 13, modifiers: 0x100000)].contains(new) else {
                return NSSound.beep()
            }
            finish()
            guard new != shortcut else { return }
            if let message = new.modifiers == 0x100000 ? String(localized: "Apps already use this shortcut") : Shortcut.conflict(new, in: taken) {
                pending = (new, message)
            } else {
                shortcut = new
            }
        }
    }

    private func use(_ new: Shortcut) {
        finish()
        pending = nil
        shortcut = new
    }

    private func finish() {
        guard recording else { return }
        recording = false
        ShortcutRecorder.stop()
    }
}
