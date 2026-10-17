import AppKit

@main
struct TestDesktopIcons {
    final class Mac {
        var icons = false
        var createDesktop = true
        var desktop = true
        var iconWrites = 0
        var finderRestarts = 0

        func restartFinder() {
            finderRestarts += 1
            desktop = createDesktop
        }

        func copy(_ journal: UserDefaults) -> DesktopIconsHost {
            DesktopIconsHost(
                journal: journal,
                iconsHidden: { self.icons },
                writeIcons: { self.icons = $0; self.iconWrites += 1 },
                desktopMade: { self.desktop },
                makeDesktop: { self.createDesktop = true }
            )
        }
    }

    static let key = "desktop-icons-original"
    static let hiddenByUs = OriginalValue.Entry(before: false, ours: true)
    static let hiddenBefore = OriginalValue.Entry(before: true, ours: false)

    static func main() {
        var suites: [String] = []
        func journal(_ name: String) -> UserDefaults {
            let suite = "test-desktop-icons-\(name)"
            suites.append(suite)
            UserDefaults.standard.removePersistentDomain(forName: suite)
            return UserDefaults(suiteName: suite)!
        }

        do {
            let mac = Mac()
            mac.createDesktop = false
            mac.desktop = false
            let copy = mac.copy(journal("owner"))
            precondition(DesktopIcons.hidden(copy), "with CreateDesktop off the switch must show the icons as hidden")
            DesktopIcons.show(copy) { mac.restartFinder() }
            precondition(mac.createDesktop && mac.desktop && !DesktopIcons.hidden(copy), "turning the switch off must bring the desktop back")
            precondition(mac.finderRestarts == 1 && mac.iconWrites == 0)
            mac.desktop = false
            precondition(DesktopIcons.hidden(copy))
            DesktopIcons.show(copy) { mac.restartFinder() }
            precondition(mac.desktop && mac.finderRestarts == 2)
        }
        print("a Finder without its desktop shows as hidden, and turning the switch off restarts Finder with the desktop: ok")

        do {
            let mac = Mac()
            let saved = journal("quit")
            let copy = mac.copy(saved)
            precondition(!DesktopIcons.hidden(copy))
            DesktopIcons.hide(copy)
            precondition(mac.icons && DesktopIcons.hidden(copy) && OriginalValue.load(key, journal: saved) == hiddenByUs)
            DesktopIcons.putBack(copy)
            precondition(!mac.icons && OriginalValue.load(key, journal: saved) == nil && mac.finderRestarts == 0)
        }
        print("turning the switch on hides the icons, and quitting brings them back: ok")

        do {
            let mac = Mac()
            mac.icons = true
            let copy = mac.copy(journal("settings"))
            precondition(DesktopIcons.hidden(copy))
            DesktopIcons.putBack(copy)
            precondition(mac.icons && mac.iconWrites == 0, "quitting must not touch icons hidden in System Settings")
            DesktopIcons.show(copy) { mac.restartFinder() }
            precondition(!mac.icons)
            DesktopIcons.putBack(copy)
            precondition(!mac.icons && mac.iconWrites == 1, "quitting must not hide the icons again")
        }
        print("icons hidden in System Settings stay hidden on quit, and once turned off they stay visible: ok")

        do {
            let mac = Mac()
            let saved = journal("old")
            let copy = mac.copy(saved)
            OriginalValue.save(hiddenBefore, key, journal: saved)
            DesktopIcons.putBack(copy)
            precondition(!mac.icons && OriginalValue.load(key, journal: saved) == nil, "an old journal must never hide the icons")
            OriginalValue.save(hiddenBefore, key, journal: saved)
            DesktopIcons.hide(copy)
            precondition(mac.icons && OriginalValue.load(key, journal: saved) == hiddenByUs)
            DesktopIcons.putBack(copy)
            precondition(!mac.icons, "icons hidden over an old journal must come back on quit")
        }
        print("a journal from an older version that remembers hidden icons never hides them again: ok")

        do {
            let mac = Mac()
            mac.icons = true
            let saved = journal("update")
            OriginalValue.save(hiddenByUs, key, journal: saved)
            DesktopIcons.putBack(mac.copy(saved))
            precondition(!mac.icons && OriginalValue.load(key, journal: saved) == nil)
        }
        print("icons that a copy hid and never put back come back at the next launch: ok")

        do {
            let mac = Mac()
            let website = journal("website"), dev = journal("dev")
            DesktopIcons.hide(mac.copy(website))
            DesktopIcons.show(mac.copy(dev)) { mac.restartFinder() }
            DesktopIcons.putBack(mac.copy(dev))
            DesktopIcons.putBack(mac.copy(website))
            precondition(!mac.icons, "two copies must quit with the icons visible")
            DesktopIcons.hide(mac.copy(dev))
            DesktopIcons.hide(mac.copy(website))
            precondition(OriginalValue.load(key, journal: website) == nil)
            DesktopIcons.putBack(mac.copy(website))
            precondition(mac.icons)
            DesktopIcons.putBack(mac.copy(dev))
            precondition(!mac.icons)
        }
        print("two copies: the copy that hid the icons brings them back, and the other one never hides them: ok")

        do {
            let mac = Mac()
            mac.createDesktop = false
            mac.desktop = false
            let saved = journal("still")
            DesktopIcons.hide(mac.copy(saved))
            precondition(!mac.icons && mac.iconWrites == 0 && OriginalValue.load(key, journal: saved) == nil)
            mac.createDesktop = true
            mac.desktop = true
            DesktopIcons.show(mac.copy(saved)) { mac.restartFinder() }
            precondition(mac.iconWrites == 0 && mac.finderRestarts == 0)
        }
        print("a switch that already matches the desktop writes nothing and restarts nothing: ok")

        suites.forEach(UserDefaults.standard.removePersistentDomain)
    }
}
