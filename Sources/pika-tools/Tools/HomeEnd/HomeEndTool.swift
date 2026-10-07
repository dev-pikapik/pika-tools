import AppKit
import Carbon.HIToolbox
import SwiftUI

@Observable
final class HomeEndTool: Tool {
    let id = "home-end"
    let icon = "arrow.left.to.line"
    var title: String { String(localized: "Home and End go to the start and end of a line") }

    static let alwaysExcluded = [
        "com.apple.Terminal", "com.googlecode.iterm2", "com.mitchellh.ghostty", "dev.warp.", "net.kovidgoyal.kitty",
        "org.alacritty", "com.github.wez.wezterm", "co.zeit.hyper", "org.tabby", "com.raphaelamorim.rio",
        "com.parallels.", "com.vmware.fusion", "com.utmapp.", "org.virtualbox.",
        "com.microsoft.rdc.", "com.apple.ScreenSharing", "com.edovia.screens", "com.p5sys.jump.", "com.teamviewer.",
        "com.philandro.anydesk", "com.carriez.rustdesk", "tv.parsec.", "com.realvnc.", "com.citrix.",
        "com.microsoft.Word", "com.microsoft.Excel", "com.microsoft.Powerpoint", "org.libreoffice.",
        "com.jetbrains.", "com.google.android.studio",
    ]

    private static let excludedKey = "home-end-excluded"

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

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var held: (key: Int, target: Int, flags: CGEventFlags)?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
    }

    func load() {
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var isDefault: Bool { !isEnabled && excluded.isEmpty }

    func reset() {
        isEnabled = false
        excluded = []
    }

    var settingsView: AnyView {
        AnyView(HomeEndSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    static func target(_ key: Int, _ flags: CGEventFlags, app: String?, excluded: [String]) -> (key: Int, flags: CGEventFlags)? {
        let modifiers = flags.intersection([.maskShift, .maskControl, .maskAlternate, .maskCommand])
        guard key == kVK_Home || key == kVK_End,
              modifiers.isSubset(of: [.maskShift, .maskCommand]),
              let app,
              !excluded.contains(app),
              !alwaysExcluded.contains(where: { app.hasPrefix($0) })
        else { return nil }
        let arrows = modifiers.contains(.maskCommand) ? (kVK_UpArrow, kVK_DownArrow) : (kVK_LeftArrow, kVK_RightArrow)
        return (key == kVK_Home ? arrows.0 : arrows.1, modifiers.union([.maskCommand, .maskSecondaryFn, .maskNumericPad]))
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: homeEndCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        isActive = true
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
    }

    fileprivate func handle(_ event: CGEvent, up: Bool, proxy: CGEventTapProxy) -> Bool {
        let key = Int(event.getIntegerValueField(.keyboardEventKeycode))
        if up {
            guard let held, held.key == key else { return false }
            self.held = nil
            Self.send(held.target, held.flags, down: false, proxy)
            return true
        }
        if event.getIntegerValueField(.keyboardEventAutorepeat) != 0 { return key == held?.key }

        guard let app = NSWorkspace.shared.frontmostApplication,
              let target = Self.target(key, event.flags, app: app.bundleIdentifier, excluded: excluded),
              case .typing = TextFocus(app.processIdentifier)
        else { return false }
        held = (key, target.key, target.flags)
        Self.send(target.key, target.flags, down: true, proxy)
        return true
    }

    private static func send(_ key: Int, _ flags: CGEventFlags, down: Bool, _ proxy: CGEventTapProxy) {
        guard let event = CGEvent(keyboardEventSource: CGEventSource(stateID: .privateState), virtualKey: CGKeyCode(key), keyDown: down) else { return }
        event.flags = flags
        event.tapPostEvent(proxy)
    }
}

private func homeEndCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<HomeEndTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .keyDown, .keyUp:
        if tool.handle(event, up: type == .keyUp, proxy: proxy) { return nil }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct HomeEndArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.0, 0.9, 0.9, 1.4, 0.8]
    private static let words: [CGFloat] = [30, 20, 38, 26]
    private static let middle: CGFloat = 59
    private static let end: CGFloat = 132

    var body: some View {
        let step = reduceMotion ? 3 : tick % Self.durations.count
        let caret = !on ? Self.middle : step == 0 ? Self.middle : step == 2 ? 0 : Self.end
        let selected = on && step >= 3
        IllustrationRow {
            Stage {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.accentColor.opacity(0.28))
                        .frame(width: selected ? Self.end : 0, height: 18)
                    HStack(spacing: 6) {
                        ForEach(Self.words, id: \.self) { Capsule().fill(Color.primary.opacity(0.3)).frame(width: $0, height: 6) }
                    }
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 1.5, height: 20)
                        .offset(x: caret - 0.75)
                }
                .frame(width: Self.end, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 34)
                .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
                .position(x: 150, y: 42)
                ArtKey(down: step == 3, width: 38) { Text(verbatim: "⇧") }
                    .position(x: 88, y: 96)
                ArtKey(down: step == 2, width: 54) { Text(verbatim: "Home") }
                    .position(x: 142, y: 96)
                ArtKey(down: step == 1 || step == 3, width: 54) { Text(verbatim: "End") }
                    .position(x: 204, y: 96)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
        .loop($tick, Self.durations)
    }
}

private struct HomeEndSettings: View {
    @Bindable var tool: HomeEndTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { HomeEndArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("With ⇧ they select, with ⌘ they go to the start or end of the text"),
            hint: Text("In text, instead of scrolling the page"),
            help: Text("In text, Home moves the cursor to the start of the line and End to its end. With ⇧ they select up to there, with ⌘ they go to the start or end of the whole text. In terminals, virtual machines and remote desktop apps they work as before."),
            keys: ["↖", "↘"],
            isOn: $tool.isEnabled
        )
        AppExclusions(
            title: String(localized: "Home and End work as usual in these apps"),
            keys: ["↖", "↘"],
            apps: $tool.excluded,
            isEnabled: tool.isEnabled
        )
    }
}
