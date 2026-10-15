import AppKit

final class WindowShade: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

final class WindowChrome {
    static let shadeHeight: CGFloat = 72
    let shade = WindowShade()
    private weak var window: NSWindow?

    init(_ window: NSWindow, over content: NSView) {
        self.window = window
        Self.style(window)
        let gradient = CAGradientLayer()
        gradient.colors = [NSColor.black.withAlphaComponent(0.55).cgColor, NSColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        shade.layer = gradient
        shade.wantsLayer = true
        shade.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(shade)
        NSLayoutConstraint.activate([
            shade.topAnchor.constraint(equalTo: content.topAnchor),
            shade.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            shade.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            shade.heightAnchor.constraint(equalToConstant: Self.shadeHeight),
        ])
    }

    static func style(_ window: NSWindow) {
        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
    }

    static func stripAction(_ setting: String?) -> Selector? {
        switch setting {
        case "None": return nil
        case "Minimize": return #selector(NSWindow.performMiniaturize(_:))
        default: return #selector(NSWindow.performZoom(_:))
        }
    }

    static func stripDoubleClick(_ event: NSEvent, in window: NSWindow, setting: String? = UserDefaults.standard.string(forKey: "AppleActionOnDoubleClick")) -> Bool {
        guard event.clickCount == 2, !window.styleMask.contains(.fullScreen), event.locationInWindow.y > window.contentLayoutRect.height else { return false }
        if let action = stripAction(setting) { window.perform(action, with: nil) }
        return true
    }

    func setVisible(_ visible: Bool) {
        let system = window?.styleMask.contains(.fullScreen) == true
        window?.standardWindowButton(.closeButton)?.superview?.animator().alphaValue = visible || system ? 1 : 0
        shade.animator().alphaValue = visible && !system ? 1 : 0
    }
}
