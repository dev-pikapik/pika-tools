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

    var isActive: Bool { isEnabled && ScrollTap.shared.isActive }

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

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        lines = Self.savedLines
        mode = Self.savedMode
        pixels = Self.savedPixels
        updateStep()
    }

    private func updateStep() {
        ScrollTap.shared.step = isEnabled ? WheelStep(mode: mode, lines: lines, pixels: pixels) : nil
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
        updateStep()
        ScrollTap.shared.refresh()
    }
}

@Observable
final class ScrollTap {
    static let shared = ScrollTap()

    private(set) var isActive = false
    @ObservationIgnored var step: WheelStep?
    @ObservationIgnored var direction: ScrollDirection?
    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    func refresh() {
        stop()
        if step != nil || direction != nil { start() }
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
    let scroll = Unmanaged<ScrollTap>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { scroll.refresh() }
    case .scrollWheel:
        scroll.direction?.rewrite(event)
        _ = scroll.step?.rewrite(event)
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

struct ScrollStepArt: View {
    let on: Bool
    let distance: CGFloat
    @State private var tick = 0
    @State private var position: CGFloat = 0
    @State private var clicking = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let scale: CGFloat = 0.6
    private static let pitch: CGFloat = 12
    private static let widths: [CGFloat] = [64, 46, 56]
    private static let uneven: [CGFloat] = [9, 31, 14, 4, 24]

    private struct Wrapped: ViewModifier, Animatable {
        var offset: CGFloat
        var animatableData: CGFloat {
            get { offset }
            set { offset = newValue }
        }

        func body(content: Content) -> some View {
            content.offset(y: -offset.truncatingRemainder(dividingBy: ScrollStepArt.pitch * 3))
        }
    }

    var body: some View {
        let step = min(distance * Self.scale, 112)
        IllustrationRow {
            Stage {
                ArtMouse(wheel: clicking)
                    .scaleEffect(2.3)
                    .position(x: 62, y: 64)
                ArtWindow(size: CGSize(width: 140, height: 108)) {
                    VStack(spacing: 0) {
                        ForEach(0..<14, id: \.self) { index in
                            HStack(spacing: 6) {
                                Circle().fill(Color.accentColor.opacity(0.8)).frame(width: 6, height: 6)
                                Capsule().fill(Color.primary.opacity(0.16)).frame(width: Self.widths[index % 3], height: 4)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: Self.pitch)
                        }
                    }
                    .modifier(Wrapped(offset: position))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .clipped()
                }
                .position(x: 212, y: 64)
                if on {
                    VStack(spacing: 0) {
                        Capsule().fill(Color.accentColor).frame(width: 7, height: 1.5)
                        Rectangle().fill(Color.accentColor).frame(width: 1.5, height: max(step - 3, 0))
                        Capsule().fill(Color.accentColor).frame(width: 7, height: 1.5)
                    }
                    .position(x: 128, y: 64)
                    .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: step)
                }
            }
        }
        .loop($tick, [1.6])
        .onChange(of: tick) { scroll() }
        .task(id: [distance, on ? 1 : 0]) {
            try? await Task.sleep(for: .seconds(0.2))
            if !Task.isCancelled { scroll() }
        }
        .task(id: clicking) {
            guard clicking else { return }
            try? await Task.sleep(for: .seconds(0.25))
            clicking = false
        }
    }

    private func scroll() {
        let length = on ? distance * Self.scale : Self.uneven[tick % Self.uneven.count]
        if reduceMotion {
            position += length
        } else {
            withAnimation(.easeOut(duration: 0.35)) { position += length }
            clicking = true
        }
    }
}

private struct WheelSettings: View {
    @Bindable var tool: WheelTool
    @Environment(\.inSettings) private var inSettings

    private var distance: CGFloat {
        CGFloat(tool.mode == .lines ? tool.lines * Int(WheelStep.pointsPerLine) : tool.pixels)
    }

    private var screenShare: Int {
        max(1, Int((Double(tool.pixels) / (NSScreen.main?.frame.height ?? 900) * 100).rounded()))
    }

    var body: some View {
        if inSettings { ScrollStepArt(on: tool.isEnabled, distance: distance) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Same distance per click, at any speed"),
            hint: Text("Same distance at any speed"),
            help: Text("Each wheel click scrolls the same distance, at any speed. Mouse only."),
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
                    RowLabel(Text("Scroll by"), Text("Lines for apps, pixels for games"))
                }
                .settingAnchor(String(localized: "Scroll by"))
                LabeledContent {
                    if tool.mode == .lines {
                        ValueSlider(
                            title: String(localized: "Distance per click"),
                            value: Binding(get: { Double(tool.lines) }, set: { tool.lines = Int($0) }),
                            range: Double(WheelStep.range.lowerBound)...Double(WheelStep.range.upperBound),
                            step: 1,
                            ticks: WheelStep.range.count,
                            mark: Double(WheelStep.defaultLines)
                        )
                    } else {
                        ValueSlider(
                            title: String(localized: "Distance per click"),
                            value: Binding(get: { Double(tool.pixels) }, set: { tool.pixels = Int($0) }),
                            range: Double(WheelStep.pixelStep)...Double(WheelStep.pixelRange.upperBound),
                            step: Double(WheelStep.pixelStep),
                            ticks: WheelStep.pixelRange.upperBound / WheelStep.pixelStep,
                            mark: Double(WheelStep.defaultPixels)
                        )
                    }
                } label: {
                    RowLabel(
                        Text("Distance per click"),
                        tool.mode == .lines ? Text("\(tool.lines) lines per click") : Text("\(tool.pixels) px, about \(screenShare)% of the screen height")
                    )
                }
                .help(Text("The dot marks the default"))
                .settingAnchor(String(localized: "Distance per click"))
            }
            .disabled(!tool.isEnabled)
        }
    }
}
