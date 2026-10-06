import SwiftUI

@Observable
final class WheelTool: Tool {
    let id = "wheel-lines"
    let icon = "computermouse"
    var title: String { String(localized: "Scroll by lines") }
    let tab = SettingsTab.mouse

    private static let linesKey = "wheel-lines-count"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var lines: Int {
        didSet {
            UserDefaults.standard.set(lines, forKey: Self.linesKey)
            step = WheelStep(lines: lines)
        }
    }

    @ObservationIgnored fileprivate var step = WheelStep(lines: WheelStep.defaultLines)
    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        lines = Self.savedLines
        step = WheelStep(lines: lines)
    }

    private static var savedLines: Int {
        let value = UserDefaults.standard.object(forKey: linesKey) as? Int ?? WheelStep.defaultLines
        return min(max(value, WheelStep.range.lowerBound), WheelStep.range.upperBound)
    }

    var settingsView: AnyView {
        AnyView(WheelSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && lines == WheelStep.defaultLines }

    func reset() {
        isEnabled = false
        lines = WheelStep.defaultLines
        UserDefaults.standard.removeObject(forKey: Self.linesKey)
    }

    func load() {
        lines = Self.savedLines
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1) << CGEventType.scrollWheel.rawValue,
            callback: wheelCallback,
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
}

private func wheelCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<WheelTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .scrollWheel:
        _ = tool.step.rewrite(event)
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct WheelSettings: View {
    @Bindable var tool: WheelTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Every click of the wheel scrolls the same number of lines, however fast you spin it. Only for mice, not the trackpad."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            LabeledContent {
                ValueSlider(
                    title: String(localized: "Lines per wheel click"),
                    value: Binding(get: { Double(tool.lines) }, set: { tool.lines = Int($0) }),
                    range: Double(WheelStep.range.lowerBound)...Double(WheelStep.range.upperBound),
                    step: 1,
                    ticks: WheelStep.range.count
                )
            } label: {
                Text("Lines per wheel click")
                Text("Works while scrolling by lines is on")
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Lines per wheel click"))
        }
    }
}
