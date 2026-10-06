import SwiftUI

@Observable
final class KeyRepeatTool: Tool {
    let id = "key-repeat"
    let icon = "repeat"
    var title: String { String(localized: "Repeat a held key") }

    var isActive: Bool { isEnabled }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            UserDefaults.standard.set(isEnabled, forKey: id)
            Self.write(isEnabled ? false as CFBoolean : nil)
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(KeyRepeatSettings(tool: self))
    }

    func refresh() {
        if isEnabled { Self.write(false as CFBoolean) }
    }

    private static func write(_ value: CFPropertyList?) {
        let key = "ApplePressAndHoldEnabled" as CFString
        CFPreferencesSetValue(key, value, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    }
}

private struct KeyRepeatSettings: View {
    @Bindable var tool: KeyRepeatTool

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Hold a key to type it again and again, like on Windows, instead of the accent menu. Open apps pick this up after a restart."),
            isOn: $tool.isEnabled
        )
    }
}
