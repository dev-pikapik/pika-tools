import AppKit
import Carbon.HIToolbox
import SwiftUI

private let alwaysExcluded = HomeEndTool.consoles + ["com.jetbrains.", "com.google.android.studio"]

private func replace(_ old: String, with new: String, _ proxy: CGEventTapProxy) {
    func post(_ key: Int, _ text: String?) {
        for down in [true, false] {
            guard let event = CGEvent.pikapikKey(key, down: down, flags: []) else { continue }
            if let text {
                let units = Array(text.utf16)
                event.keyboardSetUnicodeString(stringLength: units.count, unicodeString: units)
            }
            event.tapPostEvent(proxy)
        }
    }
    for _ in old.unicodeScalars { post(kVK_Delete, nil) }
    for character in new { post(0, String(character)) }
}

#if APPSTORE
// The sandbox can't read or replace the selected text in other apps, so the shortcut presses the hidden
// keys of the Services command (NSKeyEquivalent in Info.plist), and the app in front runs it on the selection.
@Observable
final class LayoutFixTool: Tool {
    let id = "layout-fix"
    let icon = "character.cursor.ibeam"
    var title: String { String(localized: "Retype words you typed in the wrong language") }

    static let standard = Shortcut(key: 49, modifiers: 0x60000)
    private static let autoKey = "layout-fix-auto"
    private static let shortcutKey = "layout-fix-shortcut"
    private static let excludedKey = "layout-fix-excluded"
    private static let ignoredKey = "layout-fix-ignored"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    // Off until the owner turns it on: the App Store build can't check the text field, so it retypes blindly.
    var fixesAsYouType: Bool {
        didSet {
            UserDefaults.standard.set(fixesAsYouType, forKey: Self.autoKey)
            refresh()
        }
    }

    var shortcut: Shortcut {
        didSet {
            if shortcut == Self.standard {
                UserDefaults.standard.removeObject(forKey: Self.shortcutKey)
            } else {
                UserDefaults.standard.set(shortcut.stored, forKey: Self.shortcutKey)
            }
        }
    }

    var excluded: [String] {
        didSet { UserDefaults.standard.set(excluded, forKey: Self.excludedKey) }
    }

    var ignored: [String] {
        didSet { UserDefaults.standard.set(ignored, forKey: Self.ignoredKey) }
    }

    // The Services menu works without a permission; the shortcut row asks for Accessibility itself.
    var needs: [Permission] { [] }
    var isDefault: Bool { !isEnabled && !fixesAsYouType && shortcut == Self.standard && excluded.isEmpty && ignored.isEmpty }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var held: Int64?
    @ObservationIgnored fileprivate var holding = false
    @ObservationIgnored private var typed: [Stroke] = []
    @ObservationIgnored private var layout: KeyboardLayout?
    @ObservationIgnored private var pid: pid_t = 0
    @ObservationIgnored private var last: (fix: LayoutFix, source: KeyboardLayout)?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        fixesAsYouType = UserDefaults.standard.object(forKey: Self.autoKey) as? Bool ?? false
        shortcut = Shortcut(stored: UserDefaults.standard.object(forKey: Self.shortcutKey)) ?? Self.standard
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        ignored = UserDefaults.standard.stringArray(forKey: Self.ignoredKey) ?? []
    }

    func load() {
        fixesAsYouType = UserDefaults.standard.object(forKey: Self.autoKey) as? Bool ?? false
        shortcut = Shortcut(stored: UserDefaults.standard.object(forKey: Self.shortcutKey)) ?? Self.standard
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        ignored = UserDefaults.standard.stringArray(forKey: Self.ignoredKey) ?? []
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func reset() {
        isEnabled = false
        fixesAsYouType = false
        shortcut = Self.standard
        excluded = []
        ignored = []
    }

    var settingsView: AnyView { AnyView(LayoutFixServiceSettings(tool: self)) }

    func refresh() {
        stop()
        if isEnabled || fixesAsYouType, MainCopy.canAct, AXIsProcessTrusted() { start() }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: layoutFixCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }
        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        isActive = true
        if fixesAsYouType { DispatchQueue.main.async { KeyboardLayouts.prepare() } }
    }

    private func stop() {
        if held != nil {
            held = nil
            CGEvent.postPikapikKey(kVK_F19, down: false, nil)
        }
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        isActive = false
        clear()
    }

    fileprivate func clear() {
        typed = []
        last = nil
    }

    // ponytail: no Accessibility check on the field (the sandbox has none for other apps), so text is replaced
    // blindly. Wrong in a browser address bar with inline autocomplete (Backspace first removes the selected
    // suggestion), in design apps where Backspace deletes a selected object, and after a click into the middle
    // of a word. Held back by KeyboardLayouts.fix (4+ letters, unknown in the source language), the buffer
    // cleared on every mouse down, and the feature being off by default.
    fileprivate func handle(_ event: CGEvent, _ proxy: CGEventTapProxy) -> Bool {
        guard fixesAsYouType, !GameModeTool.shared.isPlaying, !IsSecureEventInputEnabled(),
              let app = NSWorkspace.shared.frontmostApplication, allows(app),
              KeyboardLayouts.all.count > 1, let current = KeyboardLayouts.current else {
            clear()
            return false
        }
        if app.processIdentifier != pid {
            pid = app.processIdentifier
            clear()
        }
        if current.id != layout?.id {
            clear()
            layout = current
        }
        let code = UInt16(truncatingIfNeeded: event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        if Int(code) == kVK_Space, !flags.isDisjoint(with: [.maskControl, .maskCommand]) { return false }
        if !flags.isDisjoint(with: [.maskCommand, .maskControl]) {
            clear()
            return false
        }
        if Stroke.keys.contains(code) {
            last = nil
            typed.append(Stroke(key: code, flags: flags))
            if typed.count > 100 {
                if let space = typed.firstIndex(of: .space) { typed.removeSubrange(...space) } else { clear() }
            }
            return false
        }
        switch Int(code) {
        case kVK_Space where flags.contains(.maskAlternate):
            clear()
            return false
        case kVK_Space:
            return finish(event, proxy, current, space: true)
        case kVK_Return, kVK_ANSI_KeypadEnter:
            return finish(event, proxy, current, space: false)
        case kVK_Delete where !flags.contains(.maskAlternate):
            last = nil
            if !typed.isEmpty { typed.removeLast() }
            return false
        default:
            clear()
            return false
        }
    }

    private func finish(_ event: CGEvent, _ proxy: CGEventTapProxy, _ current: KeyboardLayout, space: Bool) -> Bool {
        // Backspace deletes a character, replace() counts scalars: only plain text can be retyped without looking.
        if let fix = KeyboardLayouts.fix(typed, from: current, ignored: Set(ignored)),
           [fix.original, fix.text].allSatisfy({ $0.unicodeScalars.count == $0.count }) {
            replace(fix.original, with: fix.text, proxy)
            let key = event.copy()
            key?.markPikapik()
            key?.tapPostEvent(proxy)
            select(fix.target)
            clear()
            if space { last = (fix, current) }
            return true
        }
        if space {
            last = nil
            typed.append(.space)
        } else {
            clear()
        }
        return false
    }

    fileprivate func undo(_ proxy: CGEventTapProxy) -> Bool {
        guard let last, !IsSecureEventInputEnabled(),
              NSWorkspace.shared.frontmostApplication?.processIdentifier == pid else { return false }
        replace(last.fix.text + " ", with: last.fix.original + " ", proxy)
        select(last.source)
        if let word = KeyboardLayouts.core(String(last.fix.original.split(separator: " ").last ?? ""))?.lowercased() { ignore(word) }
        clear()
        return true
    }

    private func ignore(_ word: String) {
        guard !ignored.contains(word) else { return }
        ignored = Array((ignored + [word]).suffix(200))
    }

    private func select(_ target: KeyboardLayout) {
        TISSelectInputSource(target.source)
        layout = target
    }

    private func allows(_ app: NSRunningApplication) -> Bool {
        guard let id = app.bundleIdentifier, app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return false }
        return !excluded.contains(id) && !alwaysExcluded.contains { id.hasPrefix($0) }
    }
}

private func layoutFixCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<LayoutFixTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .leftMouseDown, .rightMouseDown, .otherMouseDown:
        tool.clear()
    case .keyDown, .keyUp:
        // A second copy of the app may be running: its own retyped keys must not be fixed again.
        guard !event.isPikapik else {
            tool.clear()
            break
        }
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        if type == .keyUp {
            if tool.held == code {
                tool.held = nil
                CGEvent.postPikapikKey(kVK_F19, down: false, proxy)
                return nil
            }
            break
        }
        if !GameModeTool.shared.isPlaying,
           Shortcut(key: UInt16(truncatingIfNeeded: code), modifiers: event.flags.rawValue) == tool.shortcut {
            if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 {
                if tool.holding { return nil }
                break
            }
            // Undoing a fix works whenever fixing as you type is on, with or without the Services shortcut.
            tool.holding = true
            if tool.undo(proxy) { return nil }
            if tool.isEnabled {
                tool.held = code
                CGEvent.postPikapikKey(kVK_F19, down: true, flags: [.maskControl, .maskAlternate, .maskShift, .maskCommand], proxy)
                return nil
            }
            tool.holding = false
        }
        if tool.handle(event, proxy) { return nil }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct LayoutFixServiceSettings: View {
    @Bindable var tool: LayoutFixTool
    @Environment(\.inSettings) private var inSettings
    @State private var hovering = false

    var body: some View {
        if inSettings {
            LayoutFixArt(on: true, service: tool.fixesAsYouType ? nil : LayoutFixService.title)
            RowLabel(Text(tool.title), Text(LayoutFixService.hint))
                .settingAnchor(tool.title)
            Toggle(isOn: $tool.isEnabled) {
                Group {
                    if tool.isEnabled {
                        ShortcutLabel(
                            shortcut: $tool.shortcut,
                            standard: LayoutFixTool.standard,
                            title: Text("Fix the selected text"),
                            subtitle: Text("Select the text, then press these keys"),
                            others: []
                        )
                    } else {
                        KeyLabel(keys: [tool.shortcut.text], title: Text("Fix the selected text"), subtitle: Text("Select the text, then press these keys"))
                    }
                }
                .settingAnchor(String(localized: "Fix the selected text"))
            }
            .needs([.accessibility])
            Toggle(isOn: $tool.fixesAsYouType) {
                KeyLabel(keys: [String(localized: "Space")], title: Text("Fix words as you type"), subtitle: Text("When you press Space or Return"))
            }
            .settingAnchor(String(localized: "Fix words as you type"))
            .help(Text("Press \(tool.shortcut.text) right after a fix to undo it. That word won’t be fixed again."))
            .needs([.accessibility])
            if tool.fixesAsYouType {
                LayoutFixNotes(tool: tool)
                AppExclusions(title: String(localized: "Don’t fix text in these apps"), apps: $tool.excluded, isEnabled: tool.fixesAsYouType)
            }
        } else {
            Button { SettingsWindow.show(.keyboard) } label: {
                HStack(spacing: 10) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tool.isActive ? Color.white : Color.secondary)
                        .frame(width: 28, height: 28)
                        .background(tool.isActive ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(tool.title).font(.body).lineLimit(2)
                        Group {
                            if tool.fixesAsYouType, tool.isActive {
                                Text("Fixed when you press Space")
                            } else if tool.isActive {
                                Text("Press \(tool.shortcut.text) to fix")
                            } else {
                                Text("In the Services menu")
                            }
                        }
                        .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    }
                    Spacer(minLength: 0)
                    if tool.isActive, tool.isEnabled { KeyCaps(keys: [tool.shortcut.text]) }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if hovering { RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.fill.quaternary) }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering = $0 }
        }
    }
}
#else
@Observable
final class LayoutFixTool: Tool {
    let id = "layout-fix"
    let icon = "character.cursor.ibeam"
    var title: String { String(localized: "Retype words you typed in the wrong language") }

    static let standard = Shortcut(key: 49, modifiers: 0x60000)
    private static let autoKey = "layout-fix-auto"
    private static let shortcutKey = "layout-fix-shortcut"
    private static let excludedKey = "layout-fix-excluded"
    private static let ignoredKey = "layout-fix-ignored"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var fixesAsYouType: Bool {
        didSet { UserDefaults.standard.set(fixesAsYouType, forKey: Self.autoKey) }
    }

    var shortcut: Shortcut {
        didSet {
            if shortcut == Self.standard {
                UserDefaults.standard.removeObject(forKey: Self.shortcutKey)
            } else {
                UserDefaults.standard.set(shortcut.stored, forKey: Self.shortcutKey)
            }
        }
    }

    var excluded: [String] {
        didSet { UserDefaults.standard.set(excluded, forKey: Self.excludedKey) }
    }

    var ignored: [String] {
        didSet { UserDefaults.standard.set(ignored, forKey: Self.ignoredKey) }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var typed: [Stroke] = []
    @ObservationIgnored private var layout: KeyboardLayout?
    @ObservationIgnored private var pid: pid_t = 0
    @ObservationIgnored private var holding = false
    @ObservationIgnored private var switched: (strokes: [Stroke], layout: KeyboardLayout)?
    @ObservationIgnored private var last: (fix: LayoutFix, source: KeyboardLayout)?
    @ObservationIgnored private var cycle: (options: [(text: String, layout: KeyboardLayout?)], index: Int, word: String?)?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        fixesAsYouType = UserDefaults.standard.object(forKey: Self.autoKey) as? Bool ?? true
        shortcut = Shortcut(stored: UserDefaults.standard.object(forKey: Self.shortcutKey)) ?? Self.standard
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        ignored = UserDefaults.standard.stringArray(forKey: Self.ignoredKey) ?? []
    }

    func load() {
        fixesAsYouType = UserDefaults.standard.object(forKey: Self.autoKey) as? Bool ?? true
        shortcut = Shortcut(stored: UserDefaults.standard.object(forKey: Self.shortcutKey)) ?? Self.standard
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        ignored = UserDefaults.standard.stringArray(forKey: Self.ignoredKey) ?? []
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var isDefault: Bool { !isEnabled && fixesAsYouType && shortcut == Self.standard && excluded.isEmpty && ignored.isEmpty }

    func reset() {
        isEnabled = false
        fixesAsYouType = true
        shortcut = Self.standard
        excluded = []
        ignored = []
    }

    var settingsView: AnyView { AnyView(LayoutFixSettings(tool: self)) }

    func refresh() {
        stop()
        if isEnabled, MainCopy.canAct { start() }
        if !isActive { TextFocus.unwatch(self) }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: layoutFixCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }
        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        isActive = true
        DispatchQueue.main.async { KeyboardLayouts.prepare() }
        TextFocus.watch(self)
    }

    private func stop() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        tap = nil
        source = nil
        isActive = false
        clear()
    }

    fileprivate func clear() {
        typed = []
        switched = nil
        last = nil
        cycle = nil
    }

    fileprivate func handle(_ event: CGEvent, _ proxy: CGEventTapProxy) -> Bool {
        guard !GameModeTool.shared.isPlaying, !IsSecureEventInputEnabled(),
              let app = NSWorkspace.shared.frontmostApplication, let current = KeyboardLayouts.current else {
            clear()
            return false
        }
        if app.processIdentifier != pid {
            pid = app.processIdentifier
            clear()
        }
        if current.id != layout?.id {
            let stash = typed.contains(where: { $0 != .space }) ? layout.map { (strokes: typed, layout: $0) } : nil
            clear()
            switched = stash
            layout = current
        }
        let code = UInt16(truncatingIfNeeded: event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        if Shortcut(key: code, modifiers: flags.rawValue) == shortcut {
            if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 { return holding }
            guard allows(app), KeyboardLayouts.all.count > 1, let element = field() else {
                clear()
                holding = false
                return false
            }
            holding = convert(element, current, proxy)
            return holding
        }
        if Int(code) == kVK_Space, !flags.isDisjoint(with: [.maskControl, .maskCommand]) { return false }
        switched = nil
        if !flags.isDisjoint(with: [.maskCommand, .maskControl]) {
            clear()
            return false
        }
        if Stroke.keys.contains(code) {
            last = nil
            cycle = nil
            if typed.isEmpty {
                let pid = pid
                DispatchQueue.global(qos: .userInitiated).async {
                    if case .typing(let element) = TextFocus(pid) { _ = TextFocus.value(element, kAXSelectedTextRangeAttribute) }
                }
            }
            typed.append(Stroke(key: code, flags: flags))
            if typed.count > 100 {
                if let space = typed.firstIndex(of: .space) { typed.removeSubrange(...space) } else { clear() }
            }
            return false
        }
        switch Int(code) {
        case kVK_Space where flags.contains(.maskAlternate):
            clear()
            return false
        case kVK_Space:
            return finish(event, proxy, app, current, space: true)
        case kVK_Return, kVK_ANSI_KeypadEnter:
            return finish(event, proxy, app, current, space: false)
        case kVK_Delete where !flags.contains(.maskAlternate):
            last = nil
            cycle = nil
            if !typed.isEmpty { typed.removeLast() }
            return false
        default:
            clear()
            return false
        }
    }

    private func finish(_ event: CGEvent, _ proxy: CGEventTapProxy, _ app: NSRunningApplication, _ current: KeyboardLayout, space: Bool) -> Bool {
        if fixesAsYouType, allows(app), KeyboardLayouts.all.count > 1, autoFix(event, proxy, current, space: space) { return true }
        if space {
            last = nil
            cycle = nil
            typed.append(.space)
        } else {
            clear()
        }
        return false
    }

    private func autoFix(_ event: CGEvent, _ proxy: CGEventTapProxy, _ current: KeyboardLayout, space: Bool) -> Bool {
        guard let fix = KeyboardLayouts.fix(typed, from: current, ignored: Set(ignored)), let element = field(),
              Self.matches(element, fix.original, boundary: true) == true else { return false }
        replace(fix.original, with: fix.text, proxy)
        let key = event.copy()
        key?.markPikapik()
        key?.tapPostEvent(proxy)
        select(fix.target)
        clear()
        if space { last = (fix, current) }
        return true
    }

    private func convert(_ element: AXUIElement, _ current: KeyboardLayout, _ proxy: CGEventTapProxy) -> Bool {
        if let last, Self.fits(element, last.fix.text + " ") {
            let undo = last.fix.text + " "
            replace(undo, with: last.fix.original + " ", proxy)
            select(last.source)
            let word = KeyboardLayouts.core(String(last.fix.original.split(separator: " ").last ?? ""))?.lowercased()
            if let word { ignore(word) }
            clear()
            cycle = ([(last.fix.original + " ", last.source), (undo, last.fix.target)], 0, word)
            return true
        }
        if let cycle, Self.fits(element, cycle.options[cycle.index].text) {
            let old = cycle.options[cycle.index].text
            let index = (cycle.index + 1) % cycle.options.count
            replace(old, with: cycle.options[index].text, proxy)
            if let target = cycle.options[index].layout { select(target) }
            if let word = cycle.word {
                if index == 0 { ignore(word) } else { ignored.removeAll { $0 == word } }
            }
            self.cycle = (cycle.options, index, cycle.word)
            return true
        }
        if let selected = TextFocus.value(element, kAXSelectedTextAttribute).0 as? String, !selected.isEmpty {
            guard selected.unicodeScalars.count <= 300,
                  !selected.unicodeScalars.contains(where: { "\n\r\t\u{200D}\u{FE0F}".unicodeScalars.contains($0) || $0.properties.isEmojiPresentation }) else { return refuse() }
            let options: [(text: String, layout: KeyboardLayout?)] = KeyboardLayouts.variants(selected).map { ($0.text, nil) } + [(selected, nil)]
            guard options.count > 1 else { return refuse() }
            replace("", with: options[0].text, proxy)
            clear()
            cycle = (options, 0, nil)
            return true
        }
        let pending: (strokes: [Stroke], layout: KeyboardLayout)? = typed.isEmpty ? switched : (typed, current)
        guard let pending, let fix = KeyboardLayouts.fix(pending.strokes, from: pending.layout, forced: true),
              Self.matches(element, fix.original, boundary: false) != false else { return refuse() }
        var options: [(text: String, layout: KeyboardLayout?)] = [(fix.text, fix.target)]
        for target in KeyboardLayouts.targets(after: pending.layout) where target.id != fix.target.id {
            let text = KeyboardLayouts.convert(fix.original, from: pending.layout, to: target)
            if text != fix.original, !options.contains(where: { $0.text == text }) { options.append((text, target)) }
        }
        options.append((fix.original, pending.layout))
        replace(fix.original, with: fix.text, proxy)
        select(fix.target)
        clear()
        cycle = (options, 0, nil)
        return true
    }

    private func ignore(_ word: String) {
        guard !ignored.contains(word) else { return }
        ignored = Array((ignored + [word]).suffix(200))
    }

    private func refuse() -> Bool {
        NSSound.beep()
        clear()
        return true
    }

    private func field() -> AXUIElement? {
        guard case .typing(let element) = TextFocus(pid),
              TextFocus.value(element, kAXSubroleAttribute).0 as? String != kAXSecureTextFieldSubrole else { return nil }
        return element
    }

    private func select(_ target: KeyboardLayout) {
        TISSelectInputSource(target.source)
        layout = target
    }

    private func allows(_ app: NSRunningApplication) -> Bool {
        guard let id = app.bundleIdentifier, app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return false }
        return !excluded.contains(id) && !alwaysExcluded.contains { id.hasPrefix($0) }
    }

    private static func isPlain(_ text: String) -> Bool {
        text.unicodeScalars.count == text.count
    }

    private static func fits(_ element: AXUIElement, _ text: String) -> Bool {
        isPlain(text) && matches(element, text, boundary: false) != false
    }

    private static func matches(_ element: AXUIElement, _ expected: String, boundary: Bool) -> Bool? {
        for attempt in 0..<2 {
            guard let text = before(element, (expected as NSString).length + 1) else { return nil }
            if text.hasSuffix(expected), !boundary || !(text.dropLast(expected.count).last.map { $0.isLetter || $0.isNumber } ?? false) { return true }
            if attempt == 0 { usleep(30_000) }
        }
        return false
    }

    private static func before(_ element: AXUIElement, _ length: Int) -> String? {
        guard let value = TextFocus.value(element, kAXSelectedTextRangeAttribute).0, CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        var range = CFRange()
        guard AXValueGetValue(value as! AXValue, .cfRange, &range) else { return nil }
        guard range.length == 0 else { return "" }
        var wanted = CFRange(location: max(0, range.location - length), length: min(length, range.location))
        guard let parameter = AXValueCreate(.cfRange, &wanted) else { return nil }
        var text: CFTypeRef?
        guard AXUIElementCopyParameterizedAttributeValue(element, kAXStringForRangeParameterizedAttribute as CFString, parameter, &text) == .success else { return nil }
        return text as? String
    }
}

private func layoutFixCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<LayoutFixTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .keyDown where !event.isPikapik:
        if tool.handle(event, proxy) { return nil }
    default:
        tool.clear()
    }
    return Unmanaged.passUnretained(event)
}

private struct LayoutFixSettings: View {
    @Bindable var tool: LayoutFixTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { LayoutFixArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("And the keyboard switches to the right language"),
            hint: tool.fixesAsYouType ? Text("Fixed when you press Space") : Text("Press \(tool.shortcut.text) to fix"),
            help: Text("Press \(tool.shortcut.text) right after a fix to undo it. That word won’t be fixed again."),
            keys: [tool.shortcut.text],
            isOn: $tool.isEnabled
        )
        if inSettings {
            Toggle(isOn: $tool.fixesAsYouType) {
                KeyLabel(keys: [String(localized: "Space")], title: Text("Fix words as you type"), subtitle: Text("When you press Space or Return"))
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Fix words as you type"))
            ShortcutLabel(
                shortcut: $tool.shortcut,
                standard: LayoutFixTool.standard,
                title: Text("Fix the last word or selected text"),
                subtitle: Text("Press again for other layouts. Right after a fix, it undoes it."),
                others: []
            )
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Fix the last word or selected text"))
            LayoutFixNotes(tool: tool)
        }
        AppExclusions(title: String(localized: "Don’t fix text in these apps"), apps: $tool.excluded, isEnabled: tool.isEnabled)
    }
}
#endif

/// The words left as typed and the notice about a single keyboard layout, the same in both builds.
private struct LayoutFixNotes: View {
    let tool: LayoutFixTool

    var body: some View {
        if !tool.ignored.isEmpty {
            LabeledContent {
                Button("Clear") { tool.ignored = [] }
            } label: {
                RowLabel(Text("Words left as you typed them"), Text(verbatim: tool.ignored.joined(separator: ", ")))
            }
        }
        #if APPSTORE
        if KeyboardLayouts.all.count < 2 {
            HStack(spacing: 12) {
                Text("This works when you have two or more keyboard layouts")
                Spacer(minLength: 0)
                Button("Keyboard Settings…") { NSWorkspace.shared.open(Shortcut.keyboardSettings) }
            }
            .noticeBar()
        }
        #else
        AddLayoutNotice()
        #endif
    }
}

#if !APPSTORE
private struct AddLayoutNotice: View {
    @State private var added = 0
    @State private var failed = false

    var body: some View {
        if KeyboardLayouts.all.count < 2 {
            let choices = KeyboardLayouts.addable()
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Text("This works when you have two or more keyboard layouts")
                    Spacer(minLength: 0)
                    if choices.isEmpty || failed {
                        Button("Keyboard Settings…") { NSWorkspace.shared.open(Shortcut.keyboardSettings) }
                    }
                    if !choices.isEmpty {
                        Menu("Add a Layout") {
                            ForEach(choices, id: \.self) { source in
                                Button(KeyboardLayouts.string(source, kTISPropertyLocalizedName) ?? "") {
                                    failed = !KeyboardLayouts.enable(source)
                                    added += 1
                                }
                            }
                        }
                        .fixedSize()
                    }
                }
                if failed {
                    Text("Couldn’t add the layout. Use Keyboard Settings instead.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .noticeBar()
            .id(added)
        }
    }
}
#endif

struct LayoutFixArt: View {
    let on: Bool
    var service: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let typing = [1.4, 0.35, 1.6, 0.6]
    private static let menu = [1.2, 0.15, 0.5, 0.7, 0.45, 0.2, 2.0]
    private static let click = CGPoint(x: 56, y: 40)

    private static let sample: (typed: String, word: String, from: String, to: String) = {
        let greetings = ["ru": "привет", "uk": "привіт", "bg": "здравей", "sr": "здраво", "mk": "здраво", "el": "γεια", "he": "שלום", "ar": "مرحبا", "fa": "سلام", "hi": "नमस्ते", "th": "สวัสดี", "ka": "გამარჯობა", "hy": "բարև"]
        let all = KeyboardLayouts.all
        for target in all {
            guard let word = greetings[String(target.language.prefix { $0 != "-" && $0 != "_" })], target.canType(word),
                  let source = all.first(where: { $0.language != target.language && $0.canType("a") }) else { continue }
            let typed = KeyboardLayouts.convert(word, from: target, to: source)
            if typed != word, !typed.contains(where: \.isWhitespace) { return (typed, word, LayoutFixArt.badge(source), LayoutFixArt.badge(target)) }
        }
        return ("ghbdtn", "привет", "EN", "RU")
    }()

    static func badge(_ layout: KeyboardLayout) -> String { String(layout.language.prefix(2)).uppercased() }

    var body: some View {
        if let service { menuScene(service) } else { typingScene }
    }

    private var typingScene: some View {
        IllustrationRow(loop: Self.typing) { tick in
            let step = reduceMotion ? 2 : tick % Self.typing.count
            let fixed = on && step >= 2
            Stage {
                field(fixed ? Self.sample.word : Self.sample.typed, badge: fixed ? Self.sample.to : Self.sample.from, flash: on && step == 2)
                    .position(x: 150, y: 40)
                ArtKey(down: step == 1, width: 120) { Text("Space") }
                    .position(x: 150, y: 96)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }

    private func menuScene(_ service: String) -> some View {
        IllustrationRow(loop: Self.menu) { tick in
            let step = reduceMotion ? 6 : tick % Self.menu.count
            let click = Self.click
            let row = CGPoint(x: click.x + 40, y: click.y + 26)
            let item = CGPoint(x: click.x + 150, y: click.y + 26)
            Stage {
                field(step == 6 ? Self.sample.word : Self.sample.typed, badge: nil, selected: step < 6)
                    .position(x: 100, y: 40)
                if (2...5).contains(step) {
                    ArtMenu(width: 90) {
                        ArtMenuRow(width: 34)
                        ArtMenuRow(title: Text("Services"), active: step >= 3, submenu: true)
                        ArtMenuRow(width: 48)
                    }
                    .position(x: click.x + 45, y: click.y + 26)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if (3...5).contains(step) {
                    ArtMenu(width: 150) {
                        ArtMenuRow(title: Text(verbatim: service), active: step >= 4)
                    }
                    .position(x: click.x + 163, y: click.y + 26)
                    .transition(.opacity)
                }
                if (1...2).contains(step) { ArtRipple().position(click) }
                if step == 5 { ArtRipple().position(item) }
                ArtCursor(pressed: step == 1 || step == 5)
                    .cursor(at: [CGPoint(x: 236, y: 104), click, click, row, item, item, item][step])
                    .opacity(step == 6 ? 0 : 1)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }

    private func field(_ text: String, badge: String?, flash: Bool = false, selected: Bool = false) -> some View {
        HStack(spacing: 0) {
            Text(verbatim: text)
                .font(.system(size: 13))
                .background(selected ? Color.accentColor.opacity(0.3) : .clear, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            if !selected {
                Rectangle().fill(Color.accentColor).frame(width: 1.5, height: 16)
            }
            Spacer(minLength: 0)
            if let badge {
                Text(verbatim: badge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(flash ? Color.white : Color.primary)
                    .frame(width: 26, height: 16)
                    .background(flash ? Color.accentColor : Color.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
        .padding(.horizontal, 10)
        .frame(width: 180, height: 34)
        .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).hairline(Color.primary.opacity(0.18)))
    }
}
