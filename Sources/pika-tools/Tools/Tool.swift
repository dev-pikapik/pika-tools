import AppKit
import SwiftUI

protocol Tool: AnyObject {
    var id: String { get }
    var icon: String { get }
    var title: String { get }
    var isEnabled: Bool { get set }
    var isActive: Bool { get }
    var settingsView: AnyView { get }
    var tab: SettingsTab { get }
    var isDefault: Bool { get }
    func refresh()
    func reset()
    func load()
}

extension Tool {
    var tab: SettingsTab { .keyboard }
    var isDefault: Bool { !isEnabled }
    func reset() { isEnabled = false }
    func load() { isEnabled = UserDefaults.standard.bool(forKey: id) }
}

enum ToolStatus {
    case active, off, needsAccess, playing

    var title: String {
        switch self {
        case .active: String(localized: "Active")
        case .off: String(localized: "Off")
        case .needsAccess: String(localized: "Needs Access")
        case .playing: String(localized: "Game Mode")
        }
    }

    var icon: String {
        switch self {
        case .active: "cursorarrow.click.2"
        case .off: "cursorarrow.slash"
        case .needsAccess: "exclamationmark.triangle"
        case .playing: "gamecontroller"
        }
    }

    var color: Color {
        switch self {
        case .active: .green
        case .off: .secondary
        case .needsAccess: .orange
        case .playing: .green
        }
    }
}

#if !PIKA_PRIVATE
let privateTools: [any Tool] = []
#endif

@Observable
final class ToolRegistry {
    static let shared = ToolRegistry()

    let tools: [any Tool] = [
        CtrlKeysTool(),
        InputSwitchTool(),
        KeyRepeatTool(),
        HomeEndTool(),
        PointerTool(),
        WheelTool(),
        ScrollDirectionTool(),
        SideButtonsTool(),
        WindowZoomTool(),
        CommandKeysTool(),
        QuitOnCloseTool(),
        DockHideTool(),
        NewFileTool(),
        CompressTool(),
        ConvertTool(),
        FinderOpenTool(),
        FinderCutTool(),
        FinderDeleteTool(),
        GameModeTool.shared,
    ] + privateTools

    var status: ToolStatus {
        if GameModeTool.shared.isPlaying { return .playing }
        guard tools.contains(where: \.isEnabled) else { return .off }
        return tools.contains(where: \.isActive) ? .active : .needsAccess
    }

    private init() {
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { _ in
                ToolRegistry.shared.refresh()
            }
        }
    }

    func refresh() {
        tools.forEach { $0.refresh() }
    }
}
