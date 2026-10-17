import AppKit

enum FinderMenu {
    static var shown: Bool {
        let own = Bundle.main.bundleIdentifier ?? ""
        let key = "." + (own.split(separator: ".").last ?? "")
        let running = NSWorkspace.shared.runningApplications.filter { !$0.isTerminated }
        let extensions = running.compactMap(\.bundleIdentifier).filter { $0.hasSuffix(key) && ($0.hasPrefix(MainCopyChoice.websiteID) || $0.hasPrefix("com.pikapik.")) }
        let hostIDs = Set(extensions.map(MainCopyChoice.hostID))
        let hosts = running.compactMap { app in
            app.bundleIdentifier.flatMap { hostIDs.contains($0) ? RunningCopy(pid: app.processIdentifier, bundleID: $0, launched: MainCopyChoice.started(app.processIdentifier) ?? .distantPast) : nil }
        }
        return MainCopyChoice.showsMenu(own, among: extensions, hosts: hosts)
    }
}
