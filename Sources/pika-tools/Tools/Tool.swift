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
    var needs: [Permission] { [.accessibility] }
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
        list.append(HomeEndTool())
        list.append(LayoutFixTool())
        #if !APPSTORE
        list.append(PointerTool())
        #endif
        list.append(WheelTool())
        list.append(ScrollDirectionTool())
        list.append(SideButtonsTool())
        list.append(HideAppTool())
        #if !APPSTORE
        list.append(MiddleClickTool())
        list.append(WindowZoomTool())
        #endif
        list.append(CommandKeysTool())
        #if !APPSTORE
        list.append(QuitOnCloseTool())
        list.append(DockHideTool())
        list.append(DockDisplayTool())
        #endif
        list.append(NewFileTool())
        list.append(CompressTool())
        list.append(ConvertTool())
        #if APPSTORE
        if Bundle.main.builtInPlugInsURL.map({ FileManager.default.fileExists(atPath: $0.appending(path: "Archive.appex").path) }) == true {
            list.append(ArchiveTool())
        }
        #else
        list.append(ArchiveTool())
        #endif
        // Without Accessibility the App Store build can't tell renaming from browsing: a click or a menu can start a rename.
        #if !APPSTORE
        list.append(FinderOpenTool())
        #endif
        list.append(FinderCutTool())
        #if !APPSTORE
        list.append(FinderDeleteTool())
        #endif
        list.append(DesktopIconsTool())
        #if !APPSTORE
        list.append(HiddenFilesTool())
        list.append(AnimationsTool.shared)
        #endif
        list.append(BrightnessKeysTool.shared)
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

    var needsPermission: Bool {
        tools.contains { $0.isEnabled && $0.needs.contains { !$0.isGranted } }
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
        guard MainCopy.shared.role != .waiting else { return }
        tools.forEach { $0.refresh() }
    }
}
