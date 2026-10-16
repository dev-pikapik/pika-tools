import AppKit

@main
enum TestPlayerWindow {
    @MainActor static func main() {
        _ = NSApplication.shared
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        let content = NSView()
        window.contentView = content
        window.title = "Film.mkv"
        let chrome = WindowChrome(window, over: content)

        precondition(window.styleMask.contains(.fullSizeContentView), "the picture runs under the title bar")
        precondition(window.styleMask.contains(.titled), "corners, shadow and ⌘W still come from a titled window")
        precondition(window.titlebarAppearsTransparent && window.titleVisibility == .hidden, "no grey bar and no visible title")
        precondition(window.title == "Film.mkv", "the title stays for the Window menu and VoiceOver")
        precondition(window.contentView?.frame.size == window.frame.size, "the video covers the whole window")
        precondition(window.frameRect(forContentRect: NSRect(x: 0, y: 0, width: 1280, height: 720)).size == CGSize(width: 1280, height: 720), "the window is exactly as big as the picture")
        let strip = window.frame.height - window.contentLayoutRect.height
        precondition(strip > 0 && strip < 60, "the system strip is a thin band at the very top: \(strip)")
        precondition(window.contentView?.frame.maxY == window.frame.height, "the video starts at the top edge, under that band")
        print("the window has no title bar strip, the picture covers it all: ok")

        precondition(chrome.shade.alphaValue == 0, "a fresh window has no dark shade, so a first song never fades one out over its cover")
        let buttons = window.standardWindowButton(.closeButton)?.superview
        precondition(buttons != nil && content.subviews.contains(chrome.shade) && chrome.shade.hitTest(.zero) == nil, "the gradient is over the picture and lets clicks through")
        NSAnimationContext.current.duration = 0
        func settled(_ visible: Bool, video: Bool = true) -> Bool {
            chrome.setVisible(visible, video: video, voiceOver: false)
            let end = Date().addingTimeInterval(2)
            while buttons?.isHidden != !visible && Date() < end { RunLoop.current.run(until: Date().addingTimeInterval(0.02)) }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            let alpha: CGFloat = visible ? 1 : 0
            return buttons?.alphaValue == alpha && chrome.shade.alphaValue == (video ? alpha : 0) && buttons?.isHidden == !visible
        }
        precondition(settled(false), "the three buttons and their gradient hide together, and hidden buttons ignore the mouse")
        precondition(settled(true), "the three buttons and their gradient come back together")
        precondition(settled(true, video: false), "a song gets the buttons but no dark shade")
        precondition(settled(false, video: false), "the buttons of a song hide too")
        precondition(settled(true), "and come back")
        precondition(!chrome.setVisible(true, video: true, voiceOver: false), "the same state again starts no animation, a mouse move does not restart the fade")
        precondition(chrome.setVisible(false, video: true, voiceOver: false) && !chrome.setVisible(false, video: true, voiceOver: false), "only a change animates")
        precondition(settled(false), "the buttons are hidden")
        precondition(settled(true), "the buttons are back")
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        precondition(chrome.setVisible(false, video: true, voiceOver: true), "hiding with VoiceOver still animates")
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        precondition(buttons?.alphaValue == 0 && buttons?.isHidden == false, "with VoiceOver the hidden buttons stay in the accessibility tree")
        precondition(settled(true), "and come back")
        precondition(WindowChrome.stripAction(nil) == #selector(NSWindow.performZoom(_:)) && WindowChrome.stripAction("Maximize") == #selector(NSWindow.performZoom(_:)), "an unset or Maximize setting zooms")
        precondition(WindowChrome.stripAction("Minimize") == #selector(NSWindow.performMiniaturize(_:)) && WindowChrome.stripAction("None") == nil, "Minimize minimizes and None does nothing")
        precondition(WindowChrome.trackingOptions.contains(.activeAlways) && !WindowChrome.trackingOptions.contains(.activeInKeyWindow) && WindowChrome.trackingOptions.contains(.mouseMoved), "pointing at a window that is not the active one is seen too")
        func centre(_ type: NSWindow.ButtonType) -> NSPoint {
            let button = window.standardWindowButton(type)!
            let frame = button.convert(button.bounds, to: nil)
            return NSPoint(x: frame.midX, y: frame.midY)
        }
        precondition([NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].allSatisfy { WindowChrome.overButtons(centre($0), in: window) }, "a pointer on any of the three buttons counts as over the controls")
        precondition(!WindowChrome.overButtons(NSPoint(x: 300, y: 180), in: window) && !WindowChrome.overButtons(NSPoint(x: 300, y: centre(.closeButton).y), in: window), "a pointer on the picture does not")
        print("the window buttons and the dark gradient under them follow the panel: ok")

        func click(_ y: CGFloat, _ count: Int) -> NSEvent {
            NSEvent.mouseEvent(with: .leftMouseDown, location: NSPoint(x: 100, y: y), modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: count, pressure: 1)!
        }
        let top = window.contentLayoutRect.height + 5
        precondition(WindowChrome.stripDoubleClick(click(top, 2), in: window, setting: "None"), "a double-click in the top strip is the system's, not full screen")
        precondition(!WindowChrome.stripDoubleClick(click(top, 1), in: window, setting: "None"), "one click in the strip does nothing special")
        precondition(!WindowChrome.stripDoubleClick(click(100, 2), in: window, setting: "None"), "a double-click on the picture is still full screen")
        print("the top strip double-click follows the system setting: ok")

        let panel = NSView(frame: NSRect(x: 100, y: 20, width: 400, height: 56))
        precondition(!WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 40), panel: panel), "a drag that starts on the panel does not move the window")
        precondition(WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 200), panel: panel), "a drag that starts on the picture moves the window")
        panel.isHidden = true
        precondition(WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 40), panel: panel) && WindowChrome.dragsWindow(at: .zero, panel: nil), "a hidden or missing panel never blocks the drag")
        print("the window moves only when the drag starts on the picture: ok")
    }
}
