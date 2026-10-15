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

        let buttons = window.standardWindowButton(.closeButton)?.superview
        precondition(buttons != nil && content.subviews.contains(chrome.shade) && chrome.shade.hitTest(.zero) == nil, "the gradient is over the picture and lets clicks through")
        NSAnimationContext.current.duration = 0
        func settled(_ visible: Bool) -> Bool {
            chrome.setVisible(visible)
            let alpha: CGFloat = visible ? 1 : 0
            return buttons?.alphaValue == alpha && chrome.shade.alphaValue == alpha
        }
        precondition(settled(false), "the three buttons and their gradient hide together")
        precondition(settled(true), "the three buttons and their gradient come back together")
        precondition(WindowChrome.stripAction(nil) == #selector(NSWindow.performZoom(_:)) && WindowChrome.stripAction("Maximize") == #selector(NSWindow.performZoom(_:)), "an unset or Maximize setting zooms")
        precondition(WindowChrome.stripAction("Minimize") == #selector(NSWindow.performMiniaturize(_:)) && WindowChrome.stripAction("None") == nil, "Minimize minimizes and None does nothing")
        print("the window buttons and the dark gradient under them follow the panel: ok")

        func click(_ y: CGFloat, _ count: Int) -> NSEvent {
            NSEvent.mouseEvent(with: .leftMouseDown, location: NSPoint(x: 100, y: y), modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: count, pressure: 1)!
        }
        let top = window.contentLayoutRect.height + 5
        precondition(WindowChrome.stripDoubleClick(click(top, 2), in: window, setting: "None"), "a double-click in the top strip is the system's, not full screen")
        precondition(!WindowChrome.stripDoubleClick(click(top, 1), in: window, setting: "None"), "one click in the strip does nothing special")
        precondition(!WindowChrome.stripDoubleClick(click(100, 2), in: window, setting: "None"), "a double-click on the picture is still full screen")
        print("the top strip double-click follows the system setting: ok")
    }
}
