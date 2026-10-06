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

struct ScrollArt: View {
    let smooth: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let pitch: CGFloat = 14
    private static let widths: [CGFloat] = [52, 38, 46]

    private struct Wrapped: ViewModifier, Animatable {
        var offset: CGFloat
        var animatableData: CGFloat {
            get { offset }
            set { offset = newValue }
        }

        func body(content: Content) -> some View {
            content.offset(y: -offset.truncatingRemainder(dividingBy: ScrollArt.pitch * 3))
        }
    }

    var body: some View {
        let offset = reduceMotion ? (smooth ? Self.pitch / 2 : 0) : CGFloat(tick) * Self.pitch
        VStack(spacing: 0) {
            ForEach(0..<10, id: \.self) { index in
                HStack(spacing: 6) {
                    Circle().fill(Color.accentColor.opacity(0.8)).frame(width: 7, height: 7)
                    Capsule().fill(Color.primary.opacity(0.16)).frame(width: Self.widths[index % 3], height: 5)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 9)
                .frame(height: Self.pitch)
            }
        }
        .modifier(Wrapped(offset: offset))
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipped()
        .animation(reduceMotion ? nil : smooth ? .linear(duration: 0.7) : .snappy(duration: 0.18), value: tick)
        .loop($tick, [0.7])
    }
}

private struct WheelSettings: View {
    @Bindable var tool: WheelTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Each wheel click scrolls the same distance, at any speed. Mouse only."),
            hint: Text("Same distance at any speed"),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Group {
                LabeledContent {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach([WheelStep.Mode.lines, .pixels], id: \.self) { mode in
                            ChoiceTile(
                                title: mode == .lines ? String(localized: "Lines") : String(localized: "Pixels"),
                                selected: tool.mode == mode,
                                size: CGSize(width: 96, height: 60),
                                action: { tool.mode = mode }
                            ) {
                                ScrollArt(smooth: mode == .pixels)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .accessibilityElement(children: .contain)
                } label: {
                    RowLabel(Text("Scroll by"), Text("Lines suit most apps. Pixels suit games."))
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
                        RowLabel(Text("Lines per wheel click"), Text("Works while the switch above is on"))
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
                        RowLabel(Text("Pixels per wheel click"), Text("Works while the switch above is on"))
                    }
                    .settingAnchor(String(localized: "Pixels per wheel click"))
                }
            }
            .disabled(!tool.isEnabled)
        }
    }
}
