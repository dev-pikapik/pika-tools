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
    var needs: [Permission] { get }
    func refresh()
    func reset()
    func load()
}

extension Tool {
    var tab: SettingsTab { .keyboard }
    var isDefault: Bool { !isEnabled }
    var needs: [Permission] { [.accessibility, .inputMonitoring] }
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

    var symbol: String? {
        switch self {
        case .active, .off: nil
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

    let tools: [any Tool] = {
        var list: [any Tool] = []
        list.append(InputSwitchTool())
        #if !APPSTORE
        list.append(KeyRepeatTool())
        #endif
        #if !APPSTORE
        list.append(HomeEndTool())
        #endif
        list.append(LayoutFixTool())
        #if !APPSTORE
        list.append(PointerTool())
        #endif
        list.append(WheelTool())
        list.append(ScrollDirectionTool())
        list.append(SideButtonsTool())
        #if !APPSTORE
        list.append(WindowZoomTool())
        #endif
        list.append(CommandKeysTool())
        #if !APPSTORE
        list.append(QuitOnCloseTool())
        list.append(DockHideTool())
        #endif
        list.append(DockDisplayTool())
        list.append(NewFileTool())
        list.append(CompressTool())
        list.append(ConvertTool())
        #if !APPSTORE
        list.append(ArchiveTool())
        #endif
        #if !APPSTORE
        list.append(FinderOpenTool())
        list.append(FinderCutTool())
        list.append(FinderDeleteTool())
        #endif
        #if !APPSTORE
        list.append(AnimationsTool.shared)
        #endif
        list.append(GameModeTool.shared)
        list.append(PetTool.shared)
        if #available(macOS 14.2, *) {
            list.append(AppVolumeTool.shared)
        }
        #if !APPSTORE
        list.append(TrashWatchTool.shared)
        #endif
        return list + privateTools
    }()

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
