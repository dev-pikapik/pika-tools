import SwiftUI

@Observable
final class WheelTool: Tool {
    let id = "wheel-lines"
    let icon = "computermouse"
    var title: String { String(localized: "Scroll by lines") }
    let tab = SettingsTab.mouse

    private static let linesKey = "wheel-lines-count"
    private static let modeKey = "wheel-lines-mode"
    private static let pixelsKey = "wheel-lines-pixels"

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
            updateStep()
        }
    }

    var mode: WheelStep.Mode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.modeKey)
            updateStep()
        }
    }

    var pixels: Int {
        didSet {
            UserDefaults.standard.set(pixels, forKey: Self.pixelsKey)
            updateStep()
        }
    }

    @ObservationIgnored fileprivate var step = WheelStep(lines: WheelStep.defaultLines)
    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        lines = Self.savedLines
        mode = Self.savedMode
        pixels = Self.savedPixels
        updateStep()
    }

    private func updateStep() {
        step = WheelStep(mode: mode, lines: lines, pixels: pixels)
    }

    private static var savedLines: Int {
        let value = UserDefaults.standard.object(forKey: linesKey) as? Int ?? WheelStep.defaultLines
        return min(max(value, WheelStep.range.lowerBound), WheelStep.range.upperBound)
    }

    private static var savedMode: WheelStep.Mode {
        UserDefaults.standard.string(forKey: modeKey).flatMap(WheelStep.Mode.init) ?? .lines
    }

    private static var savedPixels: Int {
        let value = UserDefaults.standard.object(forKey: pixelsKey) as? Int ?? WheelStep.defaultPixels
        return min(max(value, WheelStep.pixelRange.lowerBound), WheelStep.pixelRange.upperBound)
    }

    var settingsView: AnyView {
        AnyView(WheelSettings(tool: self))
    }

    var isDefault: Bool {
        !isEnabled && lines == WheelStep.defaultLines && mode == .lines && pixels == WheelStep.defaultPixels
    }

    func reset() {
        isEnabled = false
        lines = WheelStep.defaultLines
        mode = .lines
        pixels = WheelStep.defaultPixels
        for key in [Self.linesKey, Self.modeKey, Self.pixelsKey] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func load() {
        lines = Self.savedLines
        mode = Self.savedMode
        pixels = Self.savedPixels
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
            subtitle: Text("Each wheel click scrolls the same distance, at any speed. Mouse only."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Group {
                Picker(selection: $tool.mode) {
                    Text("Lines").tag(WheelStep.Mode.lines)
                    Text("Pixels").tag(WheelStep.Mode.pixels)
                } label: {
                    Text("Scroll by")
                    Text("Lines suit most apps. Pixels suit games.")
                }
                .settingAnchor(String(localized: "Scroll by"))
                switch tool.mode {
                case .lines:
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
                    .settingAnchor(String(localized: "Lines per wheel click"))
                case .pixels:
                    LabeledContent {
                        ValueSlider(
                            title: String(localized: "Pixels per wheel click"),
                            value: Binding(get: { Double(tool.pixels) }, set: { tool.pixels = Int($0) }),
                            range: Double(WheelStep.pixelRange.lowerBound)...Double(WheelStep.pixelRange.upperBound),
                            step: 1,
                            ticks: 11
                        )
                    } label: {
                        Text("Pixels per wheel click")
                        Text("Works while scrolling by lines is on")
                    }
                    .settingAnchor(String(localized: "Pixels per wheel click"))
                }
            }
            .disabled(!tool.isEnabled)
        }
    }
}
