import SwiftUI

@Observable
final class ScrollDirectionTool: Tool {
    let id = "wheel-direction"
    let icon = "arrow.up.arrow.down"
    var title: String { String(localized: "Separate scroll direction for the mouse") }
    let tab = SettingsTab.mouse

    private static let naturalKey = "wheel-direction-natural"

    var isActive: Bool { isEnabled && ScrollTap.shared.isActive }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var natural: Bool {
        didSet {
            UserDefaults.standard.set(natural, forKey: Self.naturalKey)
            update()
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        natural = UserDefaults.standard.bool(forKey: Self.naturalKey)
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("SwipeScrollDirectionDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.update()
        }
    }

    var settingsView: AnyView {
        AnyView(ScrollDirectionSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && !natural }

    func reset() {
        isEnabled = false
        natural = false
    }

    func load() {
        natural = UserDefaults.standard.bool(forKey: Self.naturalKey)
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func refresh() {
        update()
        ScrollTap.shared.refresh()
    }

    private func update() {
        CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        let system = CFPreferencesCopyAppValue("com.apple.swipescrolldirection" as CFString, kCFPreferencesAnyApplication) as? Bool ?? true
        ScrollTap.shared.direction = isEnabled ? ScrollDirection(natural: natural, systemNatural: system) : nil
    }
}

private struct ScrollDirectionSettings: View {
    @Bindable var tool: ScrollDirectionTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Trackpad stays as it is"),
            hint: Text("Trackpad stays as it is"),
            help: Text("The mouse wheel scrolls the way you choose, and the trackpad keeps the direction set in System Settings. Handy with Universal Control."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Picker(selection: $tool.natural) {
                Text("Natural").tag(true)
                Text("Classic").tag(false)
            } label: {
                Text("Mouse wheel direction")
                Text(tool.natural ? "Roll the wheel toward you to go up the page, like on a trackpad" : "Roll the wheel toward you to go down the page, like on Windows")
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Mouse wheel direction"))
        }
    }
}
