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
        print("the window has no title bar strip, the picture covers it all: ok")

        let buttons = window.standardWindowButton(.closeButton)?.superview
        precondition(buttons != nil && content.subviews.contains(chrome.shade) && chrome.shade.hitTest(.zero) == nil, "the gradient is over the picture and lets clicks through")
        func settled(_ visible: Bool) -> Bool {
            chrome.setVisible(visible)
            RunLoop.current.run(until: Date().addingTimeInterval(0.8))
            let alpha: CGFloat = visible ? 1 : 0
            return buttons?.alphaValue == alpha && chrome.shade.alphaValue == alpha
        }
        precondition(settled(false), "the three buttons and their gradient hide together")
        precondition(settled(true), "the three buttons and their gradient come back together")
        print("the window buttons and the dark gradient under them follow the panel: ok")
    }
}
