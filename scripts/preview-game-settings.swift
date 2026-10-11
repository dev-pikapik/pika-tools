import AppKit
import SwiftUI

@main
@MainActor
struct PreviewGameSettings {
    private static let delegate = PreviewDelegate()

    static func main() {
        guard Bundle.main.bundleIdentifier?.hasPrefix("com.pesotchi.pika-tools.preview.") == true else { return }
        let language = Bundle.main.object(forInfoDictionaryKey: "CFBundleDevelopmentRegion") as? String ?? "en"
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.set(true, forKey: "game-mode")
        UserDefaults.standard.set(true, forKey: "input-switch")
        UserDefaults.standard.set(true, forKey: "key-repeat")
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.delegate = delegate
        NSApp.appearance = NSAppearance(named: Bundle.main.object(forInfoDictionaryKey: "PreviewDark") as? Bool == false ? .aqua : .darkAqua)
        SettingsWindow.show(Bundle.main.object(forInfoDictionaryKey: "PreviewKeyboard") as? Bool == true ? .keyboard : .games)
        if let width = Bundle.main.object(forInfoDictionaryKey: "PreviewWidth") as? Double, let window = SettingsWindow.window {
            window.setContentSize(NSSize(width: width, height: window.contentRect(forFrameRect: window.frame).height))
        }
        NSApplication.shared.run()
    }
}

private final class PreviewDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
