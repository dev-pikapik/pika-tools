import CoreGraphics
import SwiftUI

/// Фильтр двойного пробела для игр, где прыжок на пробеле жмут часто.
///
/// Пропускает первое нажатие пробела, а повторное быстрее паузы глотает —
/// оно не доходит ни до игры, ни до системы (подстановка «двойной
/// пробел → точка», подсказки ввода и прочие реакции не срабатывают,
/// игра не пролагивает).
///
/// Что сознательно НЕ трогается, чтобы не сломать управление:
/// - отпускание пробела (`keyUp`) — всегда проходит, залипших прыжков нет;
/// - автоповтор удерживаемого пробела — проходит, держать прыжок можно;
/// - пробел с модификаторами (Ctrl+пробел для бега+прыжка, Shift+пробел
///   и т.п.) — всегда проходит, отвечает за них свой инструмент.
@Observable
final class DoubleSpaceTool: Tool {
    let id = "double-space"
    let name = "DoubleSpace"
    let icon = "timer"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    /// Пауза в секундах: повторный пробел быстрее неё глотается.
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
        // Нужен только keyDown: keyUp и flagsChanged пропускаем всегда.
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
        // Только пробел (keycode 49), всё остальное не наше.
        guard event.getIntegerValueField(.keyboardEventKeycode) == 49 else {
            return Unmanaged.passUnretained(event)
        }
        // Автоповтор удерживаемого пробела — не двойное нажатие, пропускаем.
        guard event.getIntegerValueField(.keyboardEventAutorepeat) == 0 else {
            return Unmanaged.passUnretained(event)
        }
        // Пробел с модификаторами (бег+прыжок на Ctrl и т.п.) — пропускаем.
        let combo: CGEventFlags = [.maskControl, .maskCommand, .maskAlternate, .maskShift]
        guard event.flags.intersection(combo).isEmpty else {
            return Unmanaged.passUnretained(event)
        }
        let tool = Unmanaged<DoubleSpaceTool>.fromOpaque(refcon).takeUnretainedValue()
        let now = DispatchTime.now().uptimeNanoseconds
        guard tool.shouldPassSpace(nowNs: now) else { return nil } // глотаем повтор
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
                title: "Фильтр двойного пробела",
                subtitle: "Первый пробел — прыжок, повтор быстрее задержки глотается",
                isOn: $tool.isEnabled
            )
            Divider()
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.15), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Задержка повтора")
                            .font(.body.weight(.medium))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 8)
                        Text("\(Int(tool.interval * 1000)) мс")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    Slider(value: $tool.interval, in: 0.05...0.3, step: 0.025)
                        .controlSize(.small)
                    Text("Пробел, нажатый быстрее задержки, игнорируется везде")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(10)
        }
    }
}
