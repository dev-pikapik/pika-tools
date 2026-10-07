import AppKit
import SwiftUI

@Observable
final class SideButtonsTool: Tool {
    let id = "side-buttons"
    let icon = "arrow.left.arrow.right"
    var title: String { String(localized: "Side buttons go back and forward") }
    let tab = SettingsTab.mouse

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var swapsButtons: Bool {
        didSet { UserDefaults.standard.set(swapsButtons, forKey: "side-buttons-swap") }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        swapsButtons = UserDefaults.standard.bool(forKey: "side-buttons-swap")
    }

    func load() {
        swapsButtons = UserDefaults.standard.bool(forKey: "side-buttons-swap")
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(SideButtonsSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && !swapsButtons }

    func reset() {
        isEnabled = false
        swapsButtons = false
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.otherMouseDown, .otherMouseUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: sideButtonsCallback,
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

    private static let swipeApps = ["com.apple.", "com.binarynights.ForkLift", "org.mozilla.firefox", "com.operasoftware.Opera"]

    fileprivate func handle(_ event: CGEvent, down: Bool) -> Bool {
        let button = event.getIntegerValueField(.mouseEventButtonNumber)
        let pid = pid_t(event.getIntegerValueField(.eventTargetUnixProcessID))
        let app = pid > 0 ? NSRunningApplication(processIdentifier: pid) : NSWorkspace.shared.frontmostApplication
        let id = app?.bundleIdentifier ?? ""
        let swaps = swapsButtons
        guard Self.swipeApps.contains(where: id.hasPrefix) else {
            if swaps { event.setIntegerValueField(.mouseEventButtonNumber, value: button == 3 ? 4 : 3) }
            return false
        }
        if down { Self.swipe(forward: (button == 4) != swaps) }
        return true
    }

    private static func swipe(forward: Bool) {
        for phase: Int64 in [1, 4] {
            guard let event = CGEvent(source: nil), let type = CGEventType(rawValue: UInt32(NSEvent.EventType.gesture.rawValue)) else { return }
            event.type = type
            event.setIntegerValueField(CGEventField(rawValue: 110)!, value: 16)
            event.setIntegerValueField(CGEventField(rawValue: 132)!, value: phase)
            event.setIntegerValueField(CGEventField(rawValue: 115)!, value: forward ? 8 : 4)
            event.post(tap: .cgSessionEventTap)
        }
    }
}

private func sideButtonsCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<SideButtonsTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .otherMouseDown, .otherMouseUp:
        let button = event.getIntegerValueField(.mouseEventButtonNumber)
        guard button == 3 || button == 4 else { break }
        if tool.handle(event, down: type == .otherMouseDown) { return nil }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct SideButtonsArt: View {
    let on: Bool
    let swapped: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.45, 0.8, 0.45, 0.45, 0.8, 0.45, 0.8]
    private static let actions = [0, 2, 0, 1, 1, 0, 2, 0]
    private static let pages = [1, 2, 2, 1, 0, 0, 1, 1]
    private static let colors: [Color] = [.teal, .accentColor, .pink]
    private static let pageWidth: CGFloat = 156

    var body: some View {
        let step = reduceMotion ? 1 : tick % Self.durations.count
        let action = Self.actions[step]
        let page = on ? Self.pages[step] : 1
        let forwardPressed = action == 2 && !swapped || action == 1 && swapped
        let backPressed = action == 1 && !swapped || action == 2 && swapped
        IllustrationRow {
            Stage {
                ArtMouse(sideButtons: true, back: backPressed, forward: forwardPressed)
                    .scaleEffect(2.1)
                    .position(x: 62, y: 66)
                number("5", pressed: forwardPressed).position(x: 22, y: 61)
                number("4", pressed: backPressed).position(x: 22, y: 81)
                ArtWindow(size: CGSize(width: Self.pageWidth, height: 98)) {
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Image(systemName: "chevron.left").foregroundStyle(on && action == 1 ? Color.accentColor : Color.secondary)
                            Image(systemName: "chevron.right").foregroundStyle(on && action == 2 ? Color.accentColor : Color.secondary)
                            Spacer(minLength: 0)
                        }
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 9)
                        .frame(height: 18)
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { self.pageView($0) }
                        }
                        .offset(x: CGFloat(1 - page) * Self.pageWidth)
                        .frame(width: Self.pageWidth, height: 64)
                        .clipped()
                    }
                }
                .position(x: 212, y: 64)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.35), value: step)
        }
        .loop($tick, Self.durations)
    }

    private func number(_ text: String, pressed: Bool) -> some View {
        Text(verbatim: text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(pressed ? Color.accentColor : Color.secondary)
    }

    private func pageView(_ index: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Self.colors[index].opacity(0.4))
                .frame(height: 22)
            ForEach([84, 62, 74], id: \.self) { Capsule().fill(Color.primary.opacity(0.14)).frame(width: CGFloat($0), height: 4) }
        }
        .padding(10)
        .frame(width: Self.pageWidth, height: 64, alignment: .topLeading)
    }
}

private struct SideButtonsSettings: View {
    @Bindable var tool: SideButtonsTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { SideButtonsArt(on: tool.isEnabled, swapped: tool.swapsButtons) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Like a trackpad swipe"),
            hint: Text("Like a trackpad swipe"),
            help: Text("Mouse buttons 4 and 5 go back and forward, like a trackpad swipe."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Toggle(isOn: $tool.swapsButtons) {
                RowLabel(Text("Swap the side buttons"), Text(tool.swapsButtons ? "Button 4 goes forward, button 5 goes back" : "Button 4 goes back, button 5 goes forward"))
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Swap the side buttons"))
        }
    }
}
