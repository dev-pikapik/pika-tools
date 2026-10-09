import Carbon
import SwiftUI

@Observable
final class InputSwitchTool: Tool {
    let id = "input-switch"
    let icon = "globe"
    var title: String { String(localized: "Switch language") }

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored fileprivate var gesture = InputSwitchGesture()

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? false
    }

    var settingsView: AnyView {
        AnyView(InputSwitchSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.flagsChanged, .keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: inputSwitchCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        gesture = InputSwitchGesture()
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

    fileprivate static func select(_ direction: InputSwitchGesture.Direction) {
        let filter = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true,
            kTISPropertyInputSourceIsEnabled: true,
        ] as CFDictionary
        guard let all = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else { return }

        let types = [kTISTypeKeyboardLayout, kTISTypeKeyboardInputMode, kTISTypeKeyboardInputMethodWithoutModes]
            .map { $0! as String }
        let sources = all.filter { types.contains(string($0, kTISPropertyInputSourceType) ?? "") }
        guard sources.count > 1 else { return }

        let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue()
        let currentID = current.flatMap { string($0, kTISPropertyInputSourceID) }
        let target: Int
        if let index = sources.firstIndex(where: { string($0, kTISPropertyInputSourceID) == currentID }) {
            let step = direction == .next ? 1 : sources.count - 1
            target = (index + step) % sources.count
        } else {
            target = direction == .next ? 0 : sources.count - 1
        }
        TISSelectInputSource(sources[target])
    }

    static func string(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let value = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
    }
}

private func inputSwitchCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<InputSwitchTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .flagsChanged:
        if let direction = tool.gesture.flagsChanged(event.flags), !GameModeTool.shared.isPlaying {
            DispatchQueue.main.async { InputSwitchTool.select(direction) }
        }
    default:
        tool.gesture.interrupt()
    }
    return Unmanaged.passUnretained(event)
}

struct InputSwitchArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.5, 0.45, 1.5, 0.6]
    private static let languages = ["EN", "RU"]

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 3 : tick % Self.durations.count
            let round = tick / Self.durations.count
            let language = on ? (step >= 3 ? round + 1 : round) % 2 : 0
            let flash = on && step == 3
            Stage {
                menuBar(language: language, flash: flash)
                    .position(x: 150, y: 34)
                ArtKey(down: (1...3).contains(step), width: 46) { Text(verbatim: "⌥") }
                    .position(x: 112, y: 92)
                ArtKey(down: step == 2, width: 46) { Text(verbatim: "⇧") }
                    .position(x: 170, y: 92)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: language)
        }
    }

    private func menuBar(language: Int, flash: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        return HStack(spacing: 7) {
            Circle().fill(Color.primary.opacity(0.35)).frame(width: 7, height: 7)
            ForEach([20, 28, 22], id: \.self) { Capsule().fill(Color.primary.opacity(0.22)).frame(width: CGFloat($0), height: 3.5) }
            Spacer(minLength: 0)
            Capsule().fill(Color.primary.opacity(0.22)).frame(width: 14, height: 3.5)
            Capsule().fill(Color.primary.opacity(0.22)).frame(width: 14, height: 3.5)
            ZStack {
                ForEach(0..<2, id: \.self) { index in
                    Text(verbatim: Self.languages[index])
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .opacity(language == index ? 1 : 0)
                        .offset(y: language == index ? 0 : 6)
                }
            }
            .foregroundStyle(flash ? Color.white : Color.primary)
            .frame(width: 26, height: 16)
            .background(flash ? Color.accentColor : Color.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        }
        .padding(.horizontal, 8)
        .frame(width: 250, height: 26)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.85), in: shape)
        .overlay(shape.strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.5))
    }
}

private struct InputSwitchSettings: View {
    @Bindable var tool: InputSwitchTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { InputSwitchArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Hold the first key, tap the second"),
            hint: Text("Hold the first key, tap the second"),
            help: Text("Hold ⌥ and tap ⇧: next language. Hold ⇧ and tap ⌥: previous"),
            keys: ["⌥⇧"],
            isOn: $tool.isEnabled
        )
    }
}
