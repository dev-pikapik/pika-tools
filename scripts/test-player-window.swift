import AppKit

final class Press: NSObject, @unchecked Sendable {
    var count = 0
    @objc func press(_ sender: Any?) { count += 1 }
}

final class Stand: NSWindow {
    var shown = false
    var sheeted: NSWindow?
    override var isVisible: Bool { shown }
    override var sheetParent: NSWindow? { sheeted }
}

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

        let frameView = window.contentView!.superview!
        let close = window.standardWindowButton(.closeButton)!
        let press = Press()
        close.target = press
        close.action = #selector(Press.press(_:))
        func takesMouse() -> Bool { frameView.hitTest(centre(.closeButton)) === close }
        precondition(settled(true) && takesMouse(), "shown buttons take the mouse")
        precondition(settled(false) && !takesMouse(), "hidden buttons ignore the mouse")
        precondition(settled(true), "the buttons are back")
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        precondition(chrome.setVisible(false, video: true, voiceOver: true), "the buttons fade out")
        RunLoop.current.run(until: Date().addingTimeInterval(1))
        precondition(!takesMouse() && frameView.hitTest(centre(.closeButton)) === content, "with VoiceOver the transparent buttons ignore the mouse, a click on them lands on the picture")
        let spoken = window.accessibilityCloseButton() as? NSCell
        precondition(spoken?.isAccessibilityElement() == true && spoken?.accessibilityRole() == .button && (window.accessibilityChildren() ?? []).contains { $0 as AnyObject === spoken }, "with VoiceOver the transparent buttons stay in the accessibility tree")
        _ = spoken?.accessibilityPerformPress()
        precondition(press.count == 1, "and VoiceOver can press them")
        precondition(settled(true) && takesMouse(), "the shown buttons take the mouse again")
        print("hidden buttons ignore the mouse, with VoiceOver they stay pressable by accessibility: ok")

        var asked: NSPoint?
        precondition(WindowChrome.pointerOver(window, windowNumberAt: { asked = $0; return window.windowNumber }) && asked == NSEvent.mouseLocation, "our window on top under the pointer counts")
        precondition(!WindowChrome.pointerOver(window, windowNumberAt: { _ in window.windowNumber + 1 }), "another window on top of ours does not")
        let dev = "com.pesotchi.pika-tools.dev.player", release = "com.pesotchi.pika-tools.player", flag = ["-PikaForceVoiceOver"]
        precondition(WindowChrome.voiceOver(arguments: flag, bundleID: dev, system: false) && !WindowChrome.voiceOver(arguments: [], bundleID: dev, system: false), "the dev build takes the argument")
        precondition(!WindowChrome.voiceOver(arguments: flag, bundleID: release, system: false) && !WindowChrome.voiceOver(arguments: flag, bundleID: nil, system: false), "the release build ignores it")
        precondition(WindowChrome.voiceOver(arguments: [], bundleID: release, system: true), "the real VoiceOver always counts")
        print("the pointer check sees foreign windows, the VoiceOver argument works in the dev build only: ok")

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

        let other = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.titled], backing: .buffered, defer: false)
        let zoom = window.standardWindowButton(.zoomButton)!
        let spot = centre(.zoomButton)
        let origin = zoom.convert(zoom.bounds, to: nil).origin
        other.contentView?.addSubview(zoom)
        zoom.setFrameOrigin(origin)
        precondition(zoom.window === other && zoom.convert(zoom.bounds, to: nil).contains(spot), "the button now lives in another window, as in full screen")
        precondition(!WindowChrome.overButtons(spot, in: window) && WindowChrome.overButtons(centre(.closeButton), in: window), "a button of another window does not count, the others do")
        print("a button in a system window is not ours: ok")

        func stand(_ level: NSWindow.Level = .normal) -> Stand {
            let made = Stand(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [.titled], backing: .buffered, defer: false)
            made.level = level
            made.shown = true
            return made
        }
        precondition(!WindowChrome.opened(over: window), "nothing of ours is open over a quiet window")
        let popover = stand()
        popover.parent = window
        precondition(WindowChrome.opened(over: window), "a shown child window of the player, like a popover, counts as open")
        popover.shown = false
        precondition(!WindowChrome.opened(over: window), "a hidden one does not")
        let sheet = stand()
        sheet.sheeted = window
        precondition(WindowChrome.opened(over: window), "a shown sheet of the player counts as open")
        sheet.shown = false
        let menu = stand(.popUpMenu)
        precondition(WindowChrome.opened(over: window), "a shown pop-up menu counts as open")
        menu.shown = false
        let peer = stand()
        precondition(!WindowChrome.opened(over: window), "a second player window of ours is another window and does not count")
        peer.shown = false
        let corner = stand()
        corner.parent = window
        window.standardWindowButton(.closeButton).map { corner.contentView?.addSubview($0) }
        precondition(!WindowChrome.opened(over: window), "the window of the buttons in full screen does not count, or the panel would never hide there")
        popover.shown = true
        precondition(WindowChrome.opened(over: window), "a popover next to it still does")
        popover.shown = false
        corner.shown = false
        print("an open popover, sheet or menu counts as open over the player, a second player window and the full-screen buttons do not: ok")

        let panelView = NSView(frame: NSRect(x: 100, y: 20, width: 400, height: 56))
        content.addSubview(panelView)
        let onPanel = NSPoint(x: 200, y: 40), onPicture = NSPoint(x: 200, y: 200)
        let own = { (_: NSPoint) in window.windowNumber }, foreign = { (_: NSPoint) in window.windowNumber + 1 }
        precondition(WindowChrome.overControls(window, at: onPanel, panel: panelView, windowNumberAt: own), "the pointer on the panel keeps the controls")
        precondition(!WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: own), "the pointer on the picture does not")
        precondition(!WindowChrome.overControls(window, at: onPanel, panel: panelView, windowNumberAt: foreign), "the pointer on the panel but under another window does not")
        sheet.shown = true
        precondition(WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: foreign), "an open sheet keeps the controls wherever the pointer is and whichever window is under it")
        sheet.shown = false
        precondition(!WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: foreign), "and lets go when it is closed")
        print("the controls stay while the pointer is on them or something of ours is open, and follow the pointer after: ok")

        let sooner = Press(), later = Press()
        RunLoop.current.add(Timer(timeInterval: 0.05, repeats: false) { _ in later.count += 1 }, forMode: .default)
        RunLoop.current.add(Timer(timeInterval: 0.05, repeats: false) { _ in sooner.count += 1 }, forMode: .eventTracking)
        let end = Date().addingTimeInterval(0.3)
        while Date() < end { _ = RunLoop.current.run(mode: .eventTracking, before: end) }
        precondition(sooner.count == 1 && later.count == 0, "a timer of the default mode, like the hide timer, waits while the run loop is in the tracking mode of a menu")
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        precondition(later.count == 1, "and fires when the menu is closed")
        precondition(!NSApp.windows.contains { $0.isVisible }, "the test shows nothing on screen")
        print("the hide timer waits out a menu and the test shows no window: ok")
    }
}
