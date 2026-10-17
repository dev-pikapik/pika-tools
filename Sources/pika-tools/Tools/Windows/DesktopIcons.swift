#if !APPSTORE
import AppKit

struct DesktopIconsHost {
    let journal: UserDefaults
    let iconsHidden: () -> Bool
    let writeIcons: (Bool) -> Void
    let desktopMade: () -> Bool
    let makeDesktop: () -> Void

    static let system = DesktopIconsHost(
        journal: .standard,
        iconsHidden: {
            CFPreferencesAppSynchronize(windowManager)
            var valid: DarwinBoolean = false
            let value = CFPreferencesGetAppBooleanValue(iconsKey, windowManager, &valid)
            return valid.boolValue ? value : stageManager
        },
        writeIcons: {
            CFPreferencesSetAppValue(iconsKey, $0 as CFBoolean, windowManager)
            CFPreferencesAppSynchronize(windowManager)
            for app in NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.WindowManager") { kill(app.processIdentifier, SIGTERM) }
        },
        desktopMade: {
            guard let finder = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first else { return false }
            let list = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] ?? []
            return list.contains {
                $0[kCGWindowOwnerPID as String] as? pid_t == finder.processIdentifier
                    && $0[kCGWindowLayer as String] as? Int == Int(CGWindowLevelForKey(.desktopIconWindow))
            }
        },
        makeDesktop: {
            CFPreferencesSetAppValue("CreateDesktop" as CFString, nil, finder)
            CFPreferencesAppSynchronize(finder)
        }
    )

    private static let windowManager = "com.apple.WindowManager" as CFString
    private static let finder = "com.apple.finder" as CFString
    private static var stageManager: Bool { CFPreferencesGetAppBooleanValue("GloballyEnabled" as CFString, windowManager, nil) }
    private static var iconsKey: CFString { (stageManager ? "HideDesktop" : "StandardHideDesktopIcons") as CFString }
}

enum DesktopIcons {
    static func hidden(_ host: DesktopIconsHost) -> Bool {
        host.iconsHidden() || !host.desktopMade()
    }

    static func hide(_ host: DesktopIconsHost) {
        guard !hidden(host) else { return }
        OriginalValue.save(OriginalValue.Entry(before: false, ours: true), original, journal: host.journal)
        host.writeIcons(true)
    }

    static func show(_ host: DesktopIconsHost, restartFinder: () -> Void) {
        if host.iconsHidden() { host.writeIcons(false) }
        OriginalValue.save(nil, original, journal: host.journal)
        guard !host.desktopMade() else { return }
        host.makeDesktop()
        restartFinder()
    }

    static func putBack(_ host: DesktopIconsHost) {
        if OriginalValue.putBack(OriginalValue.load(original, journal: host.journal), current: host.iconsHidden()) == false { host.writeIcons(false) }
        OriginalValue.save(nil, original, journal: host.journal)
    }

    private static let original = "desktop-icons-original"
}
#endif
