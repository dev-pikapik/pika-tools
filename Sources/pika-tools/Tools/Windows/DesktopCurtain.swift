#if APPSTORE
import AppKit

/// The sandbox can't change the Show items setting, so the App Store build hides the desktop icons with a curtain:
/// one window per screen just above the icons, showing the wallpaper. Clicks go through it to the desktop.
final class DesktopCurtain {
    var isOn = false { didSet { update() } }
    private var windows: [NSWindow] = []
    private var drawn: [String] = []

    init() {
        let workspace = NSWorkspace.shared.notificationCenter
        // Screens come and go, each Space has its own wallpaper, and a new wallpaper is picked in another app.
        for (center, name) in [
            (NotificationCenter.default, NSApplication.didChangeScreenParametersNotification),
            (workspace, NSWorkspace.activeSpaceDidChangeNotification),
            (workspace, NSWorkspace.didActivateApplicationNotification),
        ] {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in self?.update() }
        }
    }

    private func update() {
        let screens = isOn ? NSScreen.screens : []
        let wallpapers = screens.map(Self.wallpaper)
        guard wallpapers != drawn else { return }
        let old = windows
        windows = screens.map(Self.curtain)
        old.forEach { $0.orderOut(nil) }
        drawn = wallpapers
    }

    private static func wallpaper(_ screen: NSScreen) -> String {
        let workspace = NSWorkspace.shared
        return "\(screen.frame) \(screen.backingScaleFactor) \(workspace.desktopImageURL(for: screen)?.path ?? "") \(workspace.desktopImageOptions(for: screen) ?? [:])"
    }

    private static func curtain(_ screen: NSScreen) -> NSWindow {
        let workspace = NSWorkspace.shared
        let options = workspace.desktopImageOptions(for: screen) ?? [:]
        let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = true
        window.isReleasedWhenClosed = false
        window.isExcludedFromWindowsMenu = true
        window.animationBehavior = .none
        window.hasShadow = false
        window.backgroundColor = options[.fillColor] as? NSColor ?? .windowBackgroundColor
        // Moving (Aerial) wallpapers all report the default picture, so they get the plain color.
        // The real frame would need Screen Recording.
        if let url = workspace.desktopImageURL(for: screen), url.lastPathComponent != "DefaultDesktop.heic",
           let picture = picture(url, covering: CGSize(width: screen.frame.width * screen.backingScaleFactor, height: screen.frame.height * screen.backingScaleFactor)) {
            let view = NSView()
            view.wantsLayer = true
            view.layer?.contents = picture
            view.layer?.contentsScale = screen.backingScaleFactor
            view.layer?.contentsGravity = gravity(options)
            window.contentView = view
        }
        window.orderBack(nil) // below the pet, which lives at the same level
        return window
    }

    /// Decoded only as large as the screen needs: a 6K wallpaper at full size would hold 140 MB.
    private static func picture(_ url: URL, covering pixels: CGSize) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat else { return nil }
        let scale = min(1, max(pixels.width / width, pixels.height / height))
        return CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: (max(width, height) * scale).rounded(.up),
        ] as CFDictionary)
    }

    // ponytail: Tile isn't in desktopImageOptions, it shows as Fill.
    private static func gravity(_ options: [NSWorkspace.DesktopImageOptionKey: Any]) -> CALayerContentsGravity {
        switch (options[.imageScaling] as? UInt).flatMap(NSImageScaling.init) {
        case .scaleAxesIndependently: .resize
        case .scaleNone: .center
        default: options[.allowClipping] as? Bool == false ? .resizeAspect : .resizeAspectFill
        }
    }
}
#endif
