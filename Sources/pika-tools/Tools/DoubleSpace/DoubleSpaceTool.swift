import CoreGraphics
import SwiftUI

@Observable
final class DoubleSpaceTool: Tool {
    let id = "double-space"
    let icon = "space"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }
    var interval: Double {
        didSet {
            UserDefaults.standard.set(interval, forKey: Self.intervalKey)
        }
    }

    private static var intervalKey: String { "double-space-interval" }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var debouncer: SpaceDebouncer

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? true
        let saved = UserDefaults.standard.object(forKey: Self.intervalKey) as? Double ?? 0.12
        let clamped = min(max(saved, 0.05), 0.3)
        interval = clamped
        debouncer = SpaceDebouncer(windowNs: UInt64(clamped * 1_000_000_000))
    }

    var settingsView: AnyView {
        AnyView(DoubleSpaceSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: doubleSpaceCallback,
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

    fileprivate func intervalNs() -> UInt64 {
        UInt64(min(max(interval, 0.05), 0.3) * 1_000_000_000)
    }

    fileprivate func shouldPassSpace(nowNs: UInt64) -> Bool {
        debouncer.windowNs = intervalNs()
        return debouncer.shouldPass(nowNs: nowNs)
    }
}

private func doubleSpaceCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let refcon {
            let tool = Unmanaged<DoubleSpaceTool>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.async { tool.refresh() }
        }
        return Unmanaged.passUnretained(event)
    case .keyDown:
        guard let refcon else { return Unmanaged.passUnretained(event) }
        guard event.getIntegerValueField(.keyboardEventKeycode) == 49 else {
            return Unmanaged.passUnretained(event)
        }
        guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else {
            return Unmanaged.passUnretained(event)
        }
        let combo: CGEventFlags = [.maskControl, .maskCommand, .maskAlternate, .maskShift]
        guard event.flags.intersection(combo).isEmpty else {
            return Unmanaged.passUnretained(event)
        }
        let tool = Unmanaged<DoubleSpaceTool>.fromOpaque(refcon).takeUnretainedValue()
        let now = DispatchTime.now().uptimeNanoseconds
        guard tool.shouldPassSpace(nowNs: now) else { return nil }
        return Unmanaged.passUnretained(event)
    default:
        return Unmanaged.passUnretained(event)
    }
}

private struct DoubleSpaceSettings: View {
    @Bindable var tool: DoubleSpaceTool

    var body: some View {
        VStack(spacing: 0) {
            ToggleRow(
                icon: tool.icon,
                title: String(localized: "Double-space guard"),
                subtitle: String(localized: "A second space within the delay is ignored"),
                isOn: $tool.isEnabled
            )
            Divider()
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.15), in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Repeat delay")
                            .font(.body.weight(.medium))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 8)
                        Text("\(Int(tool.interval * 1000)) ms")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    Slider(value: $tool.interval, in: 0.05...0.3, step: 0.025)
                        .controlSize(.small)
                        .accessibilityLabel("Repeat delay")
                        .accessibilityValue("\(Int(tool.interval * 1000)) ms")
                }
            }
            .padding(10)
        }
    }
}
