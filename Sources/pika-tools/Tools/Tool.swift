import AppKit
import SwiftUI

protocol Tool: AnyObject {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var isEnabled: Bool { get set }
    var isActive: Bool { get }
    var settingsView: AnyView { get }
    func refresh()
}

enum ToolStatus {
    case active, off, needsAccess

    var title: String {
        switch self {
        case .active: "Активно"
        case .off: "Выключено"
        case .needsAccess: "Нужен доступ"
        }
    }

    var icon: String {
        switch self {
        case .active: "cursorarrow.click.2"
        case .off: "cursorarrow.slash"
        case .needsAccess: "exclamationmark.triangle"
        }
    }

    var color: Color {
        switch self {
        case .active: .green
        case .off: .secondary
        case .needsAccess: .orange
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
        CtrlClickTool(),
        CtrlKeysTool(),
    ] + privateTools

    var status: ToolStatus {
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
