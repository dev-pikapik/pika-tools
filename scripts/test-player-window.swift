import AppKit
import os

final class Press: NSObject {
    var count = 0
    @objc func press(_ sender: Any?) { count += 1 }
}

final class Fires: Sendable {
    private let times = OSAllocatedUnfairLock(initialState: [Date]())
    var all: [Date] { times.withLock { $0 } }
    func add() { times.withLock { $0.append(Date()) } }
}

final class Stand: NSWindow {
    var shown = false
    var sheeted: NSWindow?
    var adopted: NSWindow?
    var onScreen: Bool { super.isVisible }
    override var isVisible: Bool { shown }
    override var parent: NSWindow? { get { adopted } set { adopted = newValue } }
    override var sheetParent: NSWindow? { sheeted }
}

@main
enum TestPlayerWindow {
    @MainActor static func main() {
        _ = NSApplication.shared
        func quiet(line: UInt = #line) {
            let drawn = (CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []).contains { ($0[kCGWindowOwnerPID as String] as? Int32) == getpid() }
            precondition(!drawn && !NSApp.windows.contains { ($0 as? Stand)?.onScreen ?? $0.isVisible }, "the test shows nothing on screen", line: line)
        }
        func stand(_ level: NSWindow.Level = .normal) -> Stand {
            let made = Stand(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [.titled], backing: .buffered, defer: false)
            made.level = level
            return made
        }
        func put(_ made: Stand, _ on: Bool, line: UInt = #line) {
            made.shown = on
            quiet(line: line)
        }
        func spin(_ mode: RunLoop.Mode, _ seconds: Double) {
            let end = Date().addingTimeInterval(seconds)
            while Date() < end { _ = RunLoop.current.run(mode: mode, before: end) }
        }
        func pass(_ text: String, line: UInt = #line) {
            quiet(line: line)
            print(text + ": ok")
        }

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
        pass("the window has no title bar strip, the picture covers it all")

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
        pass("the window buttons and the dark gradient under them follow the panel")

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
        pass("hidden buttons ignore the mouse, with VoiceOver they stay pressable by accessibility")

        var asked: NSPoint?
        precondition(WindowChrome.pointerOver(window, windowNumberAt: { asked = $0; return window.windowNumber }) && asked == NSEvent.mouseLocation, "our window on top under the pointer counts")
        precondition(!WindowChrome.pointerOver(window, windowNumberAt: { _ in window.windowNumber + 1 }), "another window on top of ours does not")
        let dev = "com.pesotchi.pika-tools.dev.player", release = "com.pesotchi.pika-tools.player", flag = ["-PikaForceVoiceOver"]
        precondition(WindowChrome.voiceOver(arguments: flag, bundleID: dev, system: false) && !WindowChrome.voiceOver(arguments: [], bundleID: dev, system: false), "the dev build takes the argument")
        precondition(!WindowChrome.voiceOver(arguments: flag, bundleID: release, system: false) && !WindowChrome.voiceOver(arguments: flag, bundleID: nil, system: false), "the release build ignores it")
        precondition(WindowChrome.voiceOver(arguments: [], bundleID: release, system: true), "the real VoiceOver always counts")
        pass("the pointer check sees foreign windows, the VoiceOver argument works in the dev build only")

        func click(_ y: CGFloat, _ count: Int) -> NSEvent {
            NSEvent.mouseEvent(with: .leftMouseDown, location: NSPoint(x: 100, y: y), modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: count, pressure: 1)!
        }
        let top = window.contentLayoutRect.height + 5
        precondition(WindowChrome.stripDoubleClick(click(top, 2), in: window, setting: "None"), "a double-click in the top strip is the system's, not full screen")
        precondition(!WindowChrome.stripDoubleClick(click(top, 1), in: window, setting: "None"), "one click in the strip does nothing special")
        precondition(!WindowChrome.stripDoubleClick(click(100, 2), in: window, setting: "None"), "a double-click on the picture is still full screen")
        pass("the top strip double-click follows the system setting")

        let panel = NSView(frame: NSRect(x: 100, y: 20, width: 400, height: 56))
        precondition(!WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 40), panel: panel), "a drag that starts on the panel does not move the window")
        precondition(WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 200), panel: panel), "a drag that starts on the picture moves the window")
        panel.isHidden = true
        precondition(WindowChrome.dragsWindow(at: NSPoint(x: 200, y: 40), panel: panel) && WindowChrome.dragsWindow(at: .zero, panel: nil), "a hidden or missing panel never blocks the drag")
        pass("the window moves only when the drag starts on the picture")

        let other = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.titled], backing: .buffered, defer: false)
        let zoom = window.standardWindowButton(.zoomButton)!
        let spot = centre(.zoomButton)
        let origin = zoom.convert(zoom.bounds, to: nil).origin
        other.contentView?.addSubview(zoom)
        zoom.setFrameOrigin(origin)
        precondition(zoom.window === other && zoom.convert(zoom.bounds, to: nil).contains(spot), "the button now lives in another window, as in full screen")
        precondition(!WindowChrome.overButtons(spot, in: window) && WindowChrome.overButtons(centre(.closeButton), in: window), "a button of another window does not count, the others do")
        pass("a button in a system window is not ours")

        precondition(!WindowChrome.opened(over: window), "nothing of ours is open over a quiet window")
        let child = stand(), sheet = stand(), menu = stand(.popUpMenu), peer = stand()
        precondition(!WindowChrome.opened(over: window), "a pop-up menu window that is not on screen is not an open menu")
        let button = window.standardWindowButton(.closeButton)!, bar = button.superview!
        child.parent = window
        child.contentView?.addSubview(button)
        precondition(button.window === child && child.level == .normal, "the stand is what the Mac does in full screen: a child window of the player at level 0 that holds the window buttons")
        put(child, true)
        precondition(!WindowChrome.opened(over: window), "the child window that holds the buttons in full screen is not open over the player: the panel would never hide there")
        put(child, false)
        bar.addSubview(button)
        precondition(button.window === window, "the buttons are back in the window")
        sheet.sheeted = window
        put(sheet, true)
        precondition(WindowChrome.opened(over: window), "a shown sheet of the player counts as open")
        put(sheet, false)
        precondition(!WindowChrome.opened(over: window), "a closed one does not")
        put(menu, true)
        precondition(WindowChrome.opened(over: window), "a shown pop-up menu counts as open")
        put(menu, false)
        for level in [NSWindow.Level.floating, .modalPanel, .mainMenu, .statusBar, .screenSaver] {
            let other = stand(level)
            put(other, true)
            precondition(!WindowChrome.opened(over: window), "a window at level \(level.rawValue), like a second player kept on top, is not a menu")
            put(other, false)
        }
        sheet.sheeted = peer
        put(sheet, true)
        put(peer, true)
        precondition(!WindowChrome.opened(over: window), "a second window and its sheet are not ours to wait for")
        put(sheet, false)
        put(peer, false)
        pass("an open sheet or menu counts as open over the player; a child window with the buttons, windows at other levels, a second player window and its sheet do not")

        let panelView = NSView(frame: NSRect(x: 100, y: 20, width: 400, height: 56))
        content.addSubview(panelView)
        let onPanel = NSPoint(x: 200, y: 40), onPicture = NSPoint(x: 200, y: 200)
        let own = { (_: NSPoint) in window.windowNumber }, foreign = { (_: NSPoint) in window.windowNumber + 1 }
        precondition(WindowChrome.overControls(window, at: onPanel, panel: panelView, windowNumberAt: own), "the pointer on the panel keeps the controls")
        precondition(!WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: own), "the pointer on the picture does not")
        precondition(!WindowChrome.overControls(window, at: onPanel, panel: panelView, windowNumberAt: foreign), "the pointer on the panel but under another window does not")
        sheet.sheeted = window
        put(sheet, true)
        precondition(WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: foreign), "an open sheet keeps the controls wherever the pointer is and whichever window is under it")
        put(sheet, false)
        precondition(!WindowChrome.overControls(window, at: onPicture, panel: panelView, windowNumberAt: foreign), "and lets go when it is closed")
        pass("the controls stay while the pointer is on them or something of ours is open, and follow the pointer after")

        let fires = Fires(), delay = 0.4
        chrome.hideAfterIdle(delay) { fires.add() }
        spin(.eventTracking, delay + 0.2)
        precondition(fires.all.isEmpty, "the hide timer waits while a menu is tracked")
        var closed = Date()
        NotificationCenter.default.post(name: NSMenu.didEndTrackingNotification, object: nil)
        spin(.default, delay + 0.5)
        precondition(fires.all.count == 1 && fires.all[0].timeIntervalSince(closed) > delay * 0.9, "when a menu closes the hide delay counts from that moment, the panel does not vanish at once")
        quiet()
        chrome.hideAfterIdle(delay) { fires.add() }
        spin(.default, delay / 2)
        closed = Date()
        NotificationCenter.default.post(name: NSWindow.didEndSheetNotification, object: window)
        spin(.default, delay + 0.5)
        precondition(fires.all.count == 2 && fires.all[1].timeIntervalSince(closed) > delay * 0.9, "when a sheet ends the hide delay counts from that moment")
        chrome.hideAfterIdle(delay) { fires.add() }
        spin(.default, delay * 0.75)
        closed = Date()
        NotificationCenter.default.post(name: NSWindow.didEndSheetNotification, object: peer)
        spin(.default, delay + 0.5)
        precondition(fires.all.count == 3 && fires.all[2].timeIntervalSince(closed) < delay * 0.9, "the end of a sheet of another window does not restart this window's timer")
        NotificationCenter.default.post(name: NSMenu.didEndTrackingNotification, object: nil)
        spin(.default, delay + 0.5)
        precondition(fires.all.count == 3, "a panel that is already hidden is not scheduled again by a closing menu")
        chrome.hideAfterIdle(delay) { fires.add() }
        chrome.cancelIdle()
        NotificationCenter.default.post(name: NSMenu.didEndTrackingNotification, object: nil)
        spin(.default, delay + 0.5)
        precondition(fires.all.count == 3, "a window that closed is not scheduled again either")
        weak var released: WindowChrome?
        autoreleasepool {
            let gone = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100), styleMask: [.titled], backing: .buffered, defer: false)
            let view = NSView()
            gone.contentView = view
            let temporary = WindowChrome(gone, over: view)
            temporary.hideAfterIdle(delay) { fires.add() }
            released = temporary
        }
        precondition(released == nil, "when its window goes away the chrome is freed even while its timer waits")
        quiet()
        pass("the hide delay starts over when a menu closes or a sheet ends, and a window that goes away is freed with its timer waiting")
    }
}
