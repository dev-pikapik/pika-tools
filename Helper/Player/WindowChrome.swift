import AppKit

final class WindowShade: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

final class ButtonShield: NSView {
    weak var content: NSView?
    var active = false

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard active, frame.contains(point), let content, let host = content.superview else { return nil }
        return content.hitTest(host.convert(point, from: superview))
    }
}

final class WindowChrome {
    static let shadeHeight: CGFloat = 72
    let shade = WindowShade()
    private let shield = ButtonShield()
    private weak var window: NSWindow?
    private var state = (bar: true, shade: false)

    init(_ window: NSWindow, over content: NSView) {
        self.window = window
        shield.content = content
        Self.style(window)
        let gradient = CAGradientLayer()
        gradient.colors = [0.5, 0.3, 0.1, 0].map { NSColor.black.withAlphaComponent($0).cgColor }
        gradient.locations = [0, 0.4, 0.75, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
        shade.layer = gradient
        shade.wantsLayer = true
        shade.alphaValue = 0
        shade.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(shade)
        NSLayoutConstraint.activate([
            shade.topAnchor.constraint(equalTo: content.topAnchor),
            shade.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            shade.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            shade.heightAnchor.constraint(equalToConstant: Self.shadeHeight),
        ])
    }

    static let trackingOptions: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect]

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

    static func dragsWindow(at point: NSPoint, panel: NSView?) -> Bool {
        panel.map { $0.isHidden || !$0.frame.contains(point) } ?? true
    }

    static func overButtons(_ point: NSPoint, in window: NSWindow) -> Bool {
        [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].contains {
            window.standardWindowButton($0).map { $0.window === window && $0.convert($0.bounds, to: nil).insetBy(dx: -6, dy: -6).contains(point) } ?? false
        }
    }

    static func pointerOver(_ window: NSWindow, windowNumberAt: (NSPoint) -> Int = { NSWindow.windowNumber(at: $0, belowWindowWithWindowNumber: 0) }) -> Bool {
        windowNumberAt(NSEvent.mouseLocation) == window.windowNumber
    }

    static func voiceOver(arguments: [String] = CommandLine.arguments, bundleID: String? = Bundle.main.bundleIdentifier, system: Bool = NSWorkspace.shared.isVoiceOverEnabled) -> Bool {
        system || (bundleID == "com.pesotchi.pika-tools.dev.player" && arguments.contains("-PikaForceVoiceOver"))
    }

    @discardableResult
    func setVisible(_ visible: Bool, video: Bool, voiceOver: Bool = WindowChrome.voiceOver()) -> Bool {
        guard let bar = window?.standardWindowButton(.closeButton)?.superview, let container = bar.superview else { return false }
        let system = window?.styleMask.contains(.fullScreen) == true
        let next = (bar: visible || system, shade: visible && video && !system)
        guard next != state else { return false }
        state = next
        if next.bar { bar.isHidden = false }
        if shield.superview !== container { container.addSubview(shield) }
        shield.frame = [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].compactMap { window?.standardWindowButton($0).map { bar.convert($0.frame, to: container) } }.reduce(.null) { $0.union($1) }
        shield.active = voiceOver && !next.bar
        NSAnimationContext.runAnimationGroup({ _ in
            bar.animator().alphaValue = next.bar ? 1 : 0
            shade.animator().alphaValue = next.shade ? 1 : 0
        }, completionHandler: { [weak self] in
            if self?.state.bar == false, !voiceOver { bar.isHidden = true }
        })
        return true
    }
}
