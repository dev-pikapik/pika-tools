import AppKit

final class LayoutFixService: NSObject {
    static let shared = LayoutFixService()
    static var title: String { Bundle.main.localizedString(forKey: "Fix Wrong Keyboard Layout", value: nil, table: "ServicesMenu") }
    static var hint: String { String(localized: "Select the text, then choose “\(title)” in the Services menu: in the app menu or when you right-click the text.") }

    static func register() {
        NSApp.servicesProvider = shared
        NSUpdateDynamicServices()
    }

    @objc func fixLayout(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pasteboard.string(forType: .string), let fixed = KeyboardLayouts.variants(text).first?.text else { return }
        pasteboard.clearContents()
        pasteboard.setString(fixed, forType: .string)
    }
}
