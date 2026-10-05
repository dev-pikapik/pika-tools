import CoreGraphics
import SwiftUI

/// Игровой режим для Ctrl: сам Ctrl остаётся зажатым и виден игре,
/// а все сочетания вида Ctrl+<клавиша> перестают долетать до системы.
///
/// Как это работает:
/// - зажатие Ctrl — это отдельное событие `flagsChanged`, его не трогаем,
///   поэтому игра продолжает видеть «Ctrl держится»;
/// - нажатие/отпускание любой другой клавиши, пока держится Ctrl, —
///   это `keyDown`/`keyUp` с флагом `.maskControl`. У таких событий флаг
///   Ctrl снимается, и macOS больше не воспринимает их как системное
///   сочетание (смена языка по Ctrl+Space, Mission Control по Ctrl+стрелкам
///   и т.д.). Игра при этом всё равно знает, что Ctrl зажат, — по состоянию
///   модификатора, — и получает саму клавишу (бег + прыжок работают).
/// - если вместе с Ctrl зажат ещё и Cmd (Ctrl+Cmd+Space и т.п.), следом
///   снимается и Cmd: иначе после снятия Ctrl событие деградировало бы
///   до Cmd+Space и открыло бы Spotlight прямо посреди игры.
@Observable
final class CtrlKeysTool: Tool {
    let id = "ctrl-keys"
    let name = "Ctrl+Keys"
    let icon = "keyboard"

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? true
    }

    var settingsView: AnyView {
        AnyView(CtrlKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: ctrlKeysCallback,
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

private func ctrlKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let refcon {
            let tool = Unmanaged<CtrlKeysTool>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.async { tool.refresh() }
        }
    case .keyDown, .keyUp:
        if event.flags.contains(.maskControl) {
            event.flags.remove(.maskControl)
            // Ctrl+Cmd+<клавиша> без этого стал бы Cmd+<клавиша>
            // (например, Spotlight по Cmd+Space) — режем и Cmd тоже.
            if event.flags.contains(.maskCommand) {
                event.flags.remove(.maskCommand)
            }
        }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

private struct CtrlKeysSettings: View {
    @Bindable var tool: CtrlKeysTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: "Блокировать сочетания Ctrl",
            subtitle: "Ctrl зажат для игры, а Ctrl+Space, Ctrl+стрелки и другие сочетания выключены",
            isOn: $tool.isEnabled
        )
    }
}
