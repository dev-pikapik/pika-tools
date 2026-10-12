import Foundation
import Security
import CoreServices

enum LeftoverKind: Int, CaseIterable, Comparable {
    case app, appData, containers, caches, preferences, background, extensions, logs, install

    static func < (a: LeftoverKind, b: LeftoverKind) -> Bool { a.rawValue < b.rawValue }
}

enum LeftoverReason: Equatable {
    case bundle
    case byID(String)
    case byName
    case appGroup(String)
    case launchJob(String)
    case helper(String)
    case receipt(String)
    case cliLink
    case homebrew(String)
    case vendor
    case related
}

struct Leftover: Identifiable, Equatable {
    var url: URL
    var kind: LeftoverKind
    var reason: LeftoverReason
    var preselected: Bool
    var sharedWith: [String] = []
    var needsAdmin = false
    var device: Int32 = 0
    var inode: UInt64 = 0
    var isLink = false
    var jobLabel: String?
    var isDaemon = false
    var packageID: String?
    var size: Int64?

    var id: String { url.path }
}

struct OrphanGroup: Identifiable, Equatable {
    var id: String
    var name: String
    var items: [Leftover]
    var newest: Date
}

enum AppNames {
    static let generic: Set<String> = [
        "helper", "helpers", "updater", "update", "agent", "agents", "support", "data", "common", "shared", "app", "apps", "application",
        "applications", "plugin", "plugins", "extension", "extensions", "cache", "caches", "log", "logs", "backup", "backups", "service",
        "services", "daemon", "launcher", "installer", "uninstaller", "setup", "library", "settings", "preferences", "resources", "tools",
        "tool", "utilities", "utility", "desktop", "client", "server", "mac", "macos", "electron", "temp", "tmp", "default", "main", "core",
        "base", "assets", "storage", "database", "sync", "crash", "reports", "report", "framework", "frameworks", "metadata", "config",
    ]
    static let system: Set<String> = [
        "mobilesync", "addressbook", "clouddocs", "fileprovider", "knowledge", "icloud", "callhistorydb", "callhistorytransactions",
        "syncservices", "diskimages", "crashreporter", "dock", "icdd", "accountsd", "cloudkit", "animoji",
    ]
    static let genericVendors: Set<String> = ["apple", "github", "gitlab", "electron", "electronjs", "sparkleproject", "chromium", "squirrel"]
    static let ignoredNested = ["org.sparkle-project.", "com.github.electron", "com.github.squirrel"]
    static let separators: Set<Character> = [" ", "-", "_"]

    static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    static func squash(_ text: String) -> String {
        fold(text).filter { !separators.contains($0) }
    }

    static func isCJK(_ character: Character) -> Bool {
        character.unicodeScalars.contains { (0x2E80...0x9FFF).contains($0.value) || (0xAC00...0xD7AF).contains($0.value) }
    }

    static func usable(_ squashed: String, blocked: Set<String> = []) -> Bool {
        guard !squashed.isEmpty, !generic.contains(squashed), !system.contains(squashed), !blocked.contains(squashed) else { return false }
        return squashed.count >= 3 || (squashed.count == 2 && squashed.allSatisfy(isCJK))
    }

    static func nameKeys(_ names: [String], blocked: Set<String> = []) -> Set<String> {
        Set(names.map(squash).filter { usable($0, blocked: blocked) })
    }

    static func vendors(bundleID: String, organization: String) -> [String] {
        var found: [String] = []
        let parts = bundleID.split(separator: ".").map(String.init)
        if parts.count >= 3 { found.append(parts[1]) }
        let words = organization.split(whereSeparator: { $0 == " " || $0 == "," })
        if let first = words.first(where: { $0.lowercased() != "the" }) { found.append(String(first)) }
        var seen = Set<String>()
        return found.filter { vendor in
            let key = squash(vendor)
            return key.count >= 3 && !genericVendors.contains(key) && !generic.contains(key) && !system.contains(key)
                && key.allSatisfy { $0.isLetter || $0.isNumber } && seen.insert(key).inserted
        }
    }

    static func twoParts(_ id: String) -> String {
        id.lowercased().split(separator: ".").prefix(2).joined(separator: ".")
    }

    static func isIgnoredNested(_ id: String) -> Bool {
        let lower = id.lowercased()
        return ignoredNested.contains { lower.hasPrefix($0) }
    }

    static func dottedPrefixes(_ text: String) -> [String] {
        var found = [text]
        var end = text.endIndex
        while let dot = text[..<end].lastIndex(of: ".") {
            found.append(String(text[..<dot]))
            end = dot
        }
        return found
    }

    static func idForms(_ entry: String) -> [String] {
        var forms = [entry.lowercased()]
        var rest = entry
        if let team = rest.range(of: "^[A-Z0-9]{10}\\.", options: .regularExpression) {
            rest.removeSubrange(team)
            forms.append(rest.lowercased())
        }
        if rest.lowercased().hasPrefix("group.") { forms.append(String(rest.lowercased().dropFirst(6))) }
        return forms
    }

    static func nameBoundaries(_ entry: String) -> [String] {
        var found: [String] = []
        var squashed = ""
        for (index, character) in fold(entry).enumerated() {
            if index > 0, squashed.count >= 5, separators.contains(character) || character == "." || character.isNumber { found.append(squashed) }
            if !separators.contains(character) { squashed.append(character) }
        }
        return found
    }

    static func processName(_ entry: String) -> String? {
        let stamps = ["_[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}\\.plist$", "[-_][0-9]{4}(-[0-9]{2}){2}-[0-9]{6}([._].*)?$"]
        for stamp in stamps {
            if let range = entry.range(of: stamp, options: .regularExpression), range.lowerBound > entry.startIndex { return String(entry[..<range.lowerBound]) }
        }
        return nil
    }

    static func isApple(_ forms: [String]) -> Bool {
        forms.contains { $0.hasPrefix("com.apple.") || $0.hasPrefix("systemgroup.") }
    }

    static func isIDShaped(_ id: String) -> Bool {
        let parts = id.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count >= 3, let top = parts.first, top.count <= 3, top.first?.isLetter == true else { return false }
        return parts.allSatisfy { !$0.isEmpty && $0.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-" || $0 == "_") } }
    }

    static func orphanID(_ entry: String) -> String? {
        var name = entry
        for suffix in [".plist", ".savedState", ".binarycookies", ".sfl2", ".sfl3", ".sfl4", ".sfl"] where name.lowercased().hasSuffix(suffix.lowercased()) {
            name.removeLast(suffix.count)
            break
        }
        if let uuid = name.range(of: "\\.[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", options: .regularExpression) {
            name.removeSubrange(uuid)
        }
        if let team = name.range(of: "^[A-Z0-9]{10}\\.", options: .regularExpression) { name.removeSubrange(team) }
        if name.lowercased().hasPrefix("group.") { name.removeFirst(6) }
        return isIDShaped(name) ? name : nil
    }

    static func orphanTitle(_ id: String) -> String {
        let tails: Set<String> = ["app", "mac", "macos", "osx", "desktop", "client", "helper", "agent", "xos"]
        let parts = id.split(separator: ".").map(String.init)
        for part in parts.dropFirst().reversed() {
            var words = part.split { $0 == "-" || $0 == "_" }.map(String.init)
            while let last = words.last, tails.contains(last.lowercased()), words.count > 1 { words.removeLast() }
            if words.count == 1, tails.contains(words[0].lowercased()) { continue }
            let title = words.map { word in word.prefix(1).uppercased() + word.dropFirst() }.joined(separator: " ")
            return isClear(title) ? title : id
        }
        return id
    }

    private static func isClear(_ title: String) -> Bool {
        title.filter(\.isLetter).count >= 4 && title.filter(\.isNumber).count * 2 <= title.count && !generic.contains(squash(title))
    }
}

struct AppIdentity: Equatable, Identifiable {
    var url: URL
    var bundleID: String
    var names: [String] = []
    var executables: [String] = []
    var version = ""
    var nestedIDs: [String] = []
    var helperLabels: [String] = []
    var teamID = ""
    var groups: [String] = []
    var organization = ""
    var isAppStore = false

    var id: String { url.path }
    var displayName: String { url.deletingPathExtension().lastPathComponent }
    var vendors: [String] { AppNames.vendors(bundleID: bundleID, organization: organization) }

    private var usableNested: [String] {
        nestedIDs.filter { $0.contains(".") && !AppNames.isIgnoredNested($0) }
    }

    var strongIDs: [String] {
        let own = AppNames.twoParts(bundleID)
        return AppIdentity.unique(([bundleID] + usableNested.filter { AppNames.twoParts($0) == own }).filter { $0.contains(".") })
    }

    var looseIDs: [String] {
        let strong = Set(strongIDs.map { $0.lowercased() })
        return AppIdentity.unique(usableNested.filter { !strong.contains($0.lowercased()) })
    }

    var ids: [String] { strongIDs + looseIDs }

    static func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { !$0.isEmpty && seen.insert($0.lowercased()).inserted }
    }

    private static let nestedFolders = ["Library/LoginItems", "Library/SystemExtensions", "XPCServices", "PlugIns", "Helpers", "Frameworks"]
    private static let nestedExtensions: Set<String> = ["app", "appex", "xpc", "bundle", "plugin", "systemextension", "prefpane", "qlgenerator", "mdimporter"]

    private static func plist(_ url: URL) -> [String: Any] {
        NSDictionary(contentsOf: url) as? [String: Any] ?? [:]
    }

    private static func text(_ value: Any?) -> String {
        guard let string = (value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !string.contains("$(") else { return "" }
        return string
    }

    private static func nestedBundles(in app: URL) -> (bundles: [URL], labels: [String]) {
        let fm = FileManager.default
        let contents = app.appendingPathComponent("Contents")
        var bundles: [URL] = []
        for folder in nestedFolders {
            let dir = contents.appendingPathComponent(folder)
            for name in ((try? fm.contentsOfDirectory(atPath: dir.path)) ?? []).sorted() where !name.hasPrefix(".") {
                let url = dir.appendingPathComponent(name)
                let ext = url.pathExtension.lowercased()
                if folder == "Frameworks" ? ext == "app" : nestedExtensions.contains(ext) {
                    bundles.append(url)
                } else if folder == "Library/LoginItems", ext != "app" {
                    for inner in ((try? fm.contentsOfDirectory(atPath: url.path)) ?? []).sorted() where inner.lowercased().hasSuffix(".app") {
                        bundles.append(url.appendingPathComponent(inner))
                    }
                }
            }
        }
        let services = contents.appendingPathComponent("Library/LaunchServices")
        let labels = ((try? fm.contentsOfDirectory(atPath: services.path)) ?? []).filter { !$0.hasPrefix(".") && !$0.hasSuffix(".plist") }.sorted()
        return (Array(bundles.prefix(128)), labels)
    }

    private static func signature(of url: URL) -> (team: String, groups: [String], organization: String)? {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code else { return nil }
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(code, SecCSFlags(rawValue: kSecCSSigningInformation), &info) == errSecSuccess,
              let dict = info as? [String: Any] else { return nil }
        let entitlements = dict[kSecCodeInfoEntitlementsDict as String] as? [String: Any] ?? [:]
        var team = dict[kSecCodeInfoTeamIdentifier as String] as? String ?? ""
        if team.isEmpty, let identifier = (entitlements["com.apple.application-identifier"] ?? entitlements["application-identifier"]) as? String,
           let prefix = identifier.split(separator: ".").first, prefix.count == 10 {
            team = String(prefix)
        }
        var organization = ""
        if let certificates = dict[kSecCodeInfoCertificates as String] as? [SecCertificate], let leaf = certificates.first,
           let summary = SecCertificateCopySubjectSummary(leaf) as String?, let colon = summary.range(of: ": ") {
            organization = String(summary[colon.upperBound...])
            if let paren = organization.range(of: " (", options: .backwards) { organization = String(organization[..<paren.lowerBound]) }
        }
        return (team, entitlements["com.apple.security.application-groups"] as? [String] ?? [], organization)
    }

    static func read(at url: URL, signed: Bool = true) -> AppIdentity? {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        guard url.pathExtension.lowercased() == "app", fm.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else { return nil }
        let info = plist(url.appendingPathComponent("Contents/Info.plist"))
        var app = AppIdentity(url: url, bundleID: text(info["CFBundleIdentifier"]))
        app.version = text(info["CFBundleShortVersionString"])
        let executable = text(info["CFBundleExecutable"])
        app.names = unique([url.deletingPathExtension().lastPathComponent, text(info["CFBundleDisplayName"]), text(info["CFBundleName"]), executable])
        var executables = [executable]
        var labels = Array((info["SMPrivilegedExecutables"] as? [String: Any] ?? [:]).keys)
        var nestedIDs: [String] = []
        let nested = nestedBundles(in: url)
        for bundle in nested.bundles {
            let inner = plist(bundle.appendingPathComponent("Contents/Info.plist"))
            nestedIDs.append(text(inner["CFBundleIdentifier"]))
            executables.append(text(inner["CFBundleExecutable"]))
            labels += Array((inner["SMPrivilegedExecutables"] as? [String: Any] ?? [:]).keys)
        }
        app.executables = unique(executables)
        app.nestedIDs = unique(nestedIDs).filter { !AppNames.isIgnoredNested($0) }
        app.helperLabels = unique(labels + nested.labels).sorted()
        app.isAppStore = fm.fileExists(atPath: url.appendingPathComponent("Contents/_MASReceipt").path)
        if signed, let main = signature(of: url) {
            app.teamID = main.team
            app.organization = main.organization
            app.groups = unique(main.groups + nested.bundles.flatMap { signature(of: $0)?.groups ?? [] })
        }
        return app
    }
}

struct AppRoots {
    var home: URL
    var root: URL
    var userCache: URL?
    var userTemp: URL?
    var caskrooms: [URL]
    var pkgutil: ([String]) -> String?
    var isKnownApp: (String) -> Bool

    func atRoot(_ path: String) -> URL { root.appendingPathComponent(path) }

    static var live: AppRoots {
        AppRoots(
            home: FileManager.default.homeDirectoryForCurrentUser,
            root: URL(fileURLWithPath: "/"),
            userCache: darwinDirectory(_CS_DARWIN_USER_CACHE_DIR),
            userTemp: darwinDirectory(_CS_DARWIN_USER_TEMP_DIR),
            caskrooms: ["/opt/homebrew/Caskroom", "/usr/local/Caskroom"].map { URL(fileURLWithPath: $0) },
            pkgutil: runPkgutil,
            isKnownApp: launchServicesKnows)
    }

    static func darwinDirectory(_ name: Int32) -> URL? {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard confstr(name, &buffer, buffer.count) > 0 else { return nil }
        return URL(fileURLWithPath: String(cString: buffer))
    }

    static func launchServicesKnows(_ bundleID: String) -> Bool {
        guard let urls = LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?.takeRetainedValue() as? [URL] else { return false }
        return urls.contains { !AppInventory.isInTrash($0) && FileManager.default.fileExists(atPath: $0.path) }
    }

    static func runPkgutil(_ arguments: [String]) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/pkgutil")
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        let finished = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in finished.signal() }
        guard (try? process.run()) != nil else { return nil }
        let reader = DispatchGroup()
        var data = Data()
        reader.enter()
        DispatchQueue.global().async {
            data = pipe.fileHandleForReading.readDataToEndOfFile()
            reader.leave()
        }
        guard reader.wait(timeout: .now() + 10) == .success, finished.wait(timeout: .now() + 10) == .success else {
            process.terminate()
            return nil
        }
        return process.terminationStatus == 0 ? String(decoding: data, as: UTF8.self) : nil
    }
}

enum AppInventory {
    static func isInTrash(_ url: URL) -> Bool {
        url.pathComponents.contains { $0 == ".Trash" || $0 == ".Trashes" }
    }

    static func isRealDirectory(_ url: URL) -> Bool {
        var info = stat()
        return lstat(url.path, &info) == 0 && info.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR)
    }

    static func parallelMap<T, R>(_ items: [T], _ transform: (T) -> R?) -> [R] {
        var results = [R?](repeating: nil, count: items.count)
        results.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: items.count) { buffer[$0] = transform(items[$0]) }
        }
        return results.compactMap { $0 }
    }

    private static func bundles(in dir: URL, deep: Bool) -> [(url: URL, direct: Bool)] {
        let fm = FileManager.default
        var found: [(URL, Bool)] = []
        for name in ((try? fm.contentsOfDirectory(atPath: dir.path)) ?? []).sorted() where !name.hasPrefix(".") {
            let child = dir.appendingPathComponent(name)
            if name.lowercased().hasSuffix(".app") {
                found.append((child, true))
            } else if deep, isRealDirectory(child) {
                for inner in ((try? fm.contentsOfDirectory(atPath: child.path)) ?? []).sorted() where inner.lowercased().hasSuffix(".app") && !inner.hasPrefix(".") {
                    found.append((child.appendingPathComponent(inner), false))
                }
            }
        }
        return found
    }

    static func installed(_ roots: AppRoots) -> [AppIdentity] {
        let systemPrefix = roots.root.resolvingSymlinksInPath().appendingPathComponent("System").path + "/"
        let candidates = [roots.atRoot("Applications"), roots.home.appendingPathComponent("Applications")].flatMap { bundles(in: $0, deep: true) }
        let found: [(AppIdentity, String)] = parallelMap(candidates) { candidate in
            let real = candidate.url.resolvingSymlinksInPath()
            guard !(real.path + "/").hasPrefix(systemPrefix), !isInTrash(real) else { return nil }
            var info = stat()
            guard lstat(real.path, &info) == 0, info.st_flags & UInt32(SF_RESTRICTED) == 0, let app = AppIdentity.read(at: candidate.url) else { return nil }
            let id = app.bundleID.lowercased()
            if id.hasPrefix("com.pesotchi.pika-tools") || (id.hasPrefix("com.apple.") && !candidate.direct) { return nil }
            return (app, real.path)
        }
        var seen = Set<String>()
        return found.filter { seen.insert($0.1).inserted }.map { $0.0 }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    static func system(_ roots: AppRoots) -> [AppIdentity] {
        let folders = ["System/Applications", "System/Applications/Utilities", "System/Library/CoreServices", "System/Library/CoreServices/Applications",
                       "System/Cryptexes/App/System/Applications", "Applications", "Applications/Utilities"]
        let urls = folders.flatMap { bundles(in: roots.atRoot($0), deep: false).map { $0.url } }
        var seen = Set<String>()
        let apps: [AppIdentity] = parallelMap(urls) { AppIdentity.read(at: $0, signed: false) }
        return apps.filter { app in
            let inApplications = app.url.path.hasPrefix(roots.atRoot("Applications").path + "/")
            return (!inApplications || app.bundleID.lowercased().hasPrefix("com.apple.")) && seen.insert(app.url.resolvingSymlinksInPath().path).inserted
        }
    }

    static func trashed(_ roots: AppRoots) -> [AppIdentity] {
        parallelMap(bundles(in: roots.home.appendingPathComponent(".Trash"), deep: false).map { $0.url }) { AppIdentity.read(at: $0) }
    }
}

private struct Mode: OptionSet {
    let rawValue: Int
    static let id = Mode(rawValue: 1)
    static let name = Mode(rawValue: 2)
    static let vendor = Mode(rawValue: 4)
    static let group = Mode(rawValue: 8)
    static let executable = Mode(rawValue: 16)
    static let embedded = Mode(rawValue: 32)
    static let helper = Mode(rawValue: 64)
    static let soft = Mode(rawValue: 128)
    static let container = Mode(rawValue: 256)
    static let vendorChild = Mode(rawValue: 512)
    static let job = Mode(rawValue: 1024)
}

private struct Place {
    enum Base { case home, root, userCache, userTemp }
    var base: Base
    var path: String
    var kind: LeftoverKind
    var mode: Mode

    init(_ base: Base, _ path: String, _ kind: LeftoverKind, _ mode: Mode) {
        self.base = base
        self.path = path
        self.kind = kind
        self.mode = mode
    }
}

private struct Claim {
    var tier: Int
    var spec: Int
    var reason: LeftoverReason
    var loose = false

    var rank: Int { tier * 100_000 + spec }
}

private struct Job {
    var url: URL
    var label: String
    var associated: [String]
    var program: String?
    var isDaemon: Bool
}

private struct Cask {
    var token: String
    var dir: URL
    var appNames: [String] = []
    var quitIDs: [String] = []
    var zap: [String] = []
    var staged: [String] = []
}

private struct OwnerIndex {
    struct IDHit {
        var app: Int
        var id: String
        var loose: Bool
    }

    var apps: [AppIdentity]
    var byID: [String: [IDHit]] = [:]
    var byGroup: [String: [Int]] = [:]
    var byName: [String: [Int]] = [:]
    var byVendorless: [String: [Int]] = [:]
    var byVendor: [String: [Int]] = [:]
    var byTeam: [String: [Int]] = [:]
    var byExecutable: [String: [Int]] = [:]
    var byHelper: [String: [(app: Int, label: String)]] = [:]
    var appPaths: [(path: String, app: Int)] = []
    var allIDs: Set<String> = []
    var idPrefixes: Set<String> = []
    var vendorPrefixes: Set<String> = []

    init(_ apps: [AppIdentity], blocked: Set<String>) {
        self.apps = apps
        for (position, app) in apps.enumerated() {
            for id in app.strongIDs { byID[id.lowercased(), default: []].append(IDHit(app: position, id: id, loose: false)) }
            for id in app.looseIDs { byID[id.lowercased(), default: []].append(IDHit(app: position, id: id, loose: true)) }
            for id in app.ids.map({ $0.lowercased() }) {
                allIDs.insert(id)
                idPrefixes.formUnion(AppNames.dottedPrefixes(id))
                vendorPrefixes.insert(AppNames.twoParts(id))
            }
            for group in app.groups { byGroup[group.lowercased(), default: []].append(position) }
            let names = app.names.map(AppNames.squash)
            for key in Set(names) where AppNames.usable(key, blocked: blocked) { byName[key, default: []].append(position) }
            let vendors = app.vendors.map(AppNames.squash)
            for vendor in vendors {
                byVendor[vendor, default: []].append(position)
                for name in names where name.hasPrefix(vendor) && name.count - vendor.count >= 3 {
                    let rest = String(name.dropFirst(vendor.count))
                    if AppNames.usable(rest, blocked: blocked) { byVendorless[rest, default: []].append(position) }
                }
            }
            if !app.teamID.isEmpty { byTeam[app.teamID, default: []].append(position) }
            for executable in app.executables where AppNames.usable(AppNames.squash(executable), blocked: blocked) {
                byExecutable[executable.lowercased(), default: []].append(position)
            }
            for label in app.helperLabels { byHelper[label.lowercased(), default: []].append((position, label)) }
            appPaths.append((app.url.standardizedFileURL.path, position))
        }
    }

    func claims(_ entry: String, name: String? = nil, extraIDs: [String] = [], mode: Mode) -> [Int: Claim] {
        var found: [Int: Claim] = [:]
        func put(_ app: Int, _ claim: Claim) {
            if let existing = found[app], existing.rank >= claim.rank { return }
            found[app] = claim
        }
        if mode.contains(.id) {
            for form in ([entry] + extraIDs).flatMap(AppNames.idForms) {
                for prefix in AppNames.dottedPrefixes(form) {
                    for hit in byID[prefix] ?? [] { put(hit.app, Claim(tier: 3, spec: prefix.count, reason: .byID(hit.id), loose: hit.loose)) }
                }
            }
        }
        if mode.contains(.group) {
            let key = entry.lowercased()
            for app in byGroup[key] ?? [] { put(app, Claim(tier: 3, spec: key.count, reason: .appGroup(entry))) }
            if let team = entry.range(of: "^[A-Z0-9]{10}(?=\\.)", options: .regularExpression) {
                for app in byTeam[String(entry[team])] ?? [] { put(app, Claim(tier: 1, spec: 10, reason: .related)) }
            }
        }
        if mode.contains(.name) || mode.contains(.vendorChild) {
            let key = AppNames.squash(name ?? entry)
            if mode.contains(.name) {
                for app in byName[key] ?? [] { put(app, Claim(tier: mode.contains(.soft) ? 1 : 2, spec: key.count, reason: .byName)) }
                for prefix in AppNames.nameBoundaries(name ?? entry) {
                    for app in byName[prefix] ?? [] { put(app, Claim(tier: 1, spec: prefix.count, reason: .related)) }
                }
            }
            if mode.contains(.vendorChild) {
                for app in byVendorless[key] ?? [] { put(app, Claim(tier: 2, spec: key.count, reason: .vendor)) }
            }
        }
        if mode.contains(.executable), let process = AppNames.processName(entry)?.lowercased() {
            for app in byExecutable[process] ?? [] { put(app, Claim(tier: 3, spec: process.count, reason: .byName)) }
        }
        if mode.contains(.helper) {
            for hit in byHelper[entry.lowercased()] ?? [] { put(hit.app, Claim(tier: 3, spec: entry.count, reason: .helper(hit.label))) }
        }
        return found
    }

    func jobClaims(_ job: Job) -> [Int: Claim] {
        var found: [Int: Claim] = [:]
        func put(_ app: Int, _ claim: Claim) {
            if let existing = found[app], existing.rank >= claim.rank { return }
            found[app] = claim
        }
        let label = job.label.lowercased()
        for prefix in AppNames.dottedPrefixes(label) {
            for hit in byID[prefix] ?? [] { put(hit.app, Claim(tier: 3, spec: prefix.count, reason: .launchJob(job.label), loose: hit.loose)) }
        }
        for id in job.associated {
            for hit in byID[id.lowercased()] ?? [] { put(hit.app, Claim(tier: 3, spec: id.count, reason: .launchJob(job.label), loose: hit.loose)) }
        }
        for hit in byHelper[label] ?? [] { put(hit.app, Claim(tier: 3, spec: label.count, reason: .helper(hit.label))) }
        if let program = job.program {
            for entry in appPaths where program.hasPrefix(entry.path + "/") { put(entry.app, Claim(tier: 3, spec: 99_000, reason: .launchJob(job.label))) }
            if program.contains("/PrivilegedHelperTools/") {
                for hit in byHelper[URL(fileURLWithPath: program).lastPathComponent.lowercased()] ?? [] {
                    put(hit.app, Claim(tier: 3, spec: 98_000, reason: .helper(hit.label)))
                }
            }
        }
        return found
    }

    func knowsVendor(_ id: String) -> Bool {
        guard let word = id.split(separator: ".").dropFirst().first.map({ AppNames.squash(String($0)) }), AppNames.usable(word) else { return false }
        return byVendor[word] != nil || byName[word] != nil
    }

    func sharers(ofVendor vendor: String, team: String, excluding url: URL) -> [AppIdentity] {
        var positions = Set(byVendor[vendor] ?? [])
        if !team.isEmpty { positions.formUnion(byTeam[team] ?? []) }
        return positions.sorted().map { apps[$0] }.filter { $0.url != url }
    }
}

final class AppFootprint {
    let roots: AppRoots
    let installed: [AppIdentity]
    let system: [AppIdentity]
    fileprivate let blocked: Set<String>
    fileprivate let index: OwnerIndex
    fileprivate var listings: [String: [String]] = [:]
    fileprivate var bundleIDs: [String: String] = [:]
    fileprivate var containerIDs: [String: String] = [:]
    fileprivate lazy var places: [Place] = makePlaces()
    fileprivate lazy var kindByDirectory: [String: LeftoverKind] = Dictionary(
        places.map { (directory($0).standardizedFileURL.path, $0.kind) }, uniquingKeysWith: { first, _ in first })
    fileprivate lazy var protectedPaths: Set<String> = makeProtectedPaths()
    fileprivate lazy var neverPrefixes: [String] = makeNeverPrefixes()
    fileprivate lazy var jobs: [Job] = loadJobs()
    fileprivate lazy var casks: [Cask] = loadCasks()
    fileprivate lazy var thirdPartyPackages: [String] = (roots.pkgutil(["--pkgs"]) ?? "").split(separator: "\n").map(String.init)
        .filter { !$0.lowercased().hasPrefix("com.apple.") }

    init(roots: AppRoots, installed: [AppIdentity], system: [AppIdentity] = []) {
        self.roots = roots
        self.installed = installed
        let known = Set(installed.map { $0.url.path })
        let outside = system.filter { !known.contains($0.url.path) }
        self.system = outside
        blocked = Set(outside.flatMap { $0.names.map(AppNames.squash) })
        index = OwnerIndex(installed + outside, blocked: blocked)
    }

    fileprivate static let userPlaces: [Place] = [
        Place(.home, "Library/Application Support", .appData, [.id, .name, .vendor]),
        Place(.home, "Library/Application Support/CrashReporter", .logs, [.executable]),
        Place(.home, "Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments", .preferences, [.id]),
        Place(.home, "Library/Caches", .caches, [.id, .name, .vendor]),
        Place(.home, "Library/Preferences", .preferences, [.id]),
        Place(.home, "Library/Preferences/ByHost", .preferences, [.id]),
        Place(.home, "Library/SyncedPreferences", .preferences, [.id]),
        Place(.home, "Library/Containers", .containers, [.id, .container]),
        Place(.home, "Library/Group Containers", .containers, [.id, .group]),
        Place(.home, "Library/Application Scripts", .containers, [.id, .group]),
        Place(.home, "Library/Saved Application State", .preferences, [.id]),
        Place(.home, "Library/HTTPStorages", .caches, [.id]),
        Place(.home, "Library/WebKit", .caches, [.id]),
        Place(.home, "Library/Cookies", .caches, [.id]),
        Place(.home, "Library/Logs", .logs, [.id, .name, .vendor]),
        Place(.home, "Library/Logs/DiagnosticReports", .logs, [.executable]),
        Place(.home, "Library/LaunchAgents", .background, [.job]),
        Place(.home, "Library/Developer", .appData, [.name, .soft]),
    ]

    fileprivate static let extensionFolders = [
        "Library/Internet Plug-Ins", "Library/PreferencePanes", "Library/Services", "Library/QuickLook", "Library/Spotlight",
        "Library/Screen Savers", "Library/Input Methods", "Library/ColorPickers",
    ]

    fileprivate static let localPlaces: [Place] = [
        Place(.root, "Library/Application Support", .appData, [.id, .name, .vendor]),
        Place(.root, "Library/Caches", .caches, [.id, .name, .vendor]),
        Place(.root, "Library/Preferences", .preferences, [.id]),
        Place(.root, "Library/Logs/DiagnosticReports", .logs, [.executable]),
        Place(.root, "Library/LaunchAgents", .background, [.job]),
        Place(.root, "Library/LaunchDaemons", .background, [.job]),
        Place(.root, "Library/PrivilegedHelperTools", .background, [.id, .helper]),
        Place(.root, "Library/Extensions", .extensions, [.embedded, .name, .soft]),
        Place(.root, "Library/Frameworks", .extensions, [.embedded, .name, .soft]),
        Place(.root, "Users/Shared", .appData, [.id, .name, .soft]),
    ]

    fileprivate func directory(_ place: Place) -> URL {
        switch place.base {
        case .home: return roots.home.appendingPathComponent(place.path)
        case .root: return roots.atRoot(place.path)
        case .userCache: return roots.userCache ?? roots.atRoot("var/empty/cache")
        case .userTemp: return roots.userTemp ?? roots.atRoot("var/empty/temp")
        }
    }

    private func makePlaces() -> [Place] {
        var list = Self.userPlaces + Self.localPlaces
        let soft: Mode = [.embedded, .name, .soft]
        for folder in Self.extensionFolders {
            list.append(Place(.home, folder, .extensions, soft))
            if folder != "Library/Services", folder != "Library/ColorPickers" { list.append(Place(.root, folder, .extensions, soft)) }
        }
        for base in [Place.Base.home, .root] {
            let audio = Place(base, "Library/Audio/Plug-Ins", .extensions, soft)
            for name in listing(directory(audio)) where AppInventory.isRealDirectory(directory(audio).appendingPathComponent(name)) {
                list.append(Place(base, audio.path + "/" + name, .extensions, soft))
            }
        }
        if roots.userCache != nil { list.append(Place(.userCache, "", .caches, [.id])) }
        if roots.userTemp != nil { list.append(Place(.userTemp, "", .caches, [.id])) }
        return list
    }

    private func makeProtectedPaths() -> Set<String> {
        var paths: Set<String> = []
        var directories = places.map { directory($0) }
        directories += [roots.home.appendingPathComponent("Library/Audio/Plug-Ins"), roots.home, roots.root]
        directories += roots.caskrooms + AppFootprint.linkFolders(roots)
        for url in directories {
            var current = url.standardizedFileURL
            while paths.insert(current.path).inserted, current.path != "/" { current = current.deletingLastPathComponent() }
        }
        return paths
    }

    private func makeNeverPrefixes() -> [String] {
        let rootFolders = ["System", "usr", "bin", "sbin", "private/etc", "etc"].map { roots.atRoot($0).standardizedFileURL.path }
        let homeFolders = ["Library/Mobile Documents", "Documents", "Desktop", "Downloads", "Pictures", "Movies", "Music"]
            .map { roots.home.appendingPathComponent($0).standardizedFileURL.path }
        return rootFolders + homeFolders
    }

    fileprivate static func linkFolders(_ roots: AppRoots) -> [URL] {
        [roots.atRoot("usr/local/bin"), roots.atRoot("opt/homebrew/bin"), roots.home.appendingPathComponent(".local/bin"), roots.home.appendingPathComponent("bin")]
    }

    fileprivate func listing(_ dir: URL) -> [String] {
        if let cached = listings[dir.path] { return cached }
        var names: [String] = []
        if AppInventory.isRealDirectory(dir) {
            names = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []).filter { !$0.hasPrefix(".") }.sorted()
        }
        listings[dir.path] = names
        return names
    }

    func isProtected(_ url: URL, for app: AppIdentity, names: [String], allowLink: Bool = false) -> Bool {
        let path = url.standardizedFileURL.path
        if protectedPaths.contains(path) || url.pathComponents.contains("Keychains") { return true }
        let usrLocalBin = roots.atRoot("usr/local/bin").standardizedFileURL.path + "/"
        for prefix in neverPrefixes where path == prefix || path.hasPrefix(prefix + "/") {
            if allowLink, path.hasPrefix(usrLocalBin) { continue }
            return true
        }
        let forms = names.flatMap(AppNames.idForms)
        guard AppNames.isApple(forms) else { return false }
        let own = app.bundleID.lowercased()
        return !(own.hasPrefix("com.apple.") && forms.contains { $0 == own || $0.hasPrefix(own + ".") })
    }

    fileprivate func fileInfo(_ url: URL) -> (device: Int32, inode: UInt64, isLink: Bool, isDirectory: Bool)? {
        var info = stat()
        guard lstat(url.path, &info) == 0 else { return nil }
        let type = info.st_mode & mode_t(S_IFMT)
        return (info.st_dev, info.st_ino, type == mode_t(S_IFLNK), type == mode_t(S_IFDIR))
    }

    fileprivate func needsAdmin(_ url: URL, isLink: Bool, isDirectory: Bool) -> Bool {
        func blocked(_ path: String) -> Bool {
            guard access(path, W_OK) != 0 else { return false }
            var info = stat()
            return errno != EPERM || lstat(path, &info) != 0 || info.st_uid != getuid()
        }
        if blocked(url.deletingLastPathComponent().path) { return true }
        return !isLink && isDirectory && blocked(url.path)
    }

    fileprivate func embeddedID(_ url: URL) -> String? {
        if let cached = bundleIDs[url.path] { return cached.isEmpty ? nil : cached }
        var found = ""
        for path in ["Contents/Info.plist", "Resources/Info.plist", "Versions/Current/Resources/Info.plist", "Info.plist"] {
            if let info = NSDictionary(contentsOf: url.appendingPathComponent(path)) as? [String: Any], let id = info["CFBundleIdentifier"] as? String {
                found = id
                break
            }
        }
        bundleIDs[url.path] = found
        return found.isEmpty ? nil : found
    }

    fileprivate func containerID(_ url: URL) -> String? {
        if let cached = containerIDs[url.path] { return cached.isEmpty ? nil : cached }
        let info = NSDictionary(contentsOf: url.appendingPathComponent(".com.apple.containermanagerd.metadata.plist")) as? [String: Any]
        let found = info?["MCMMetadataIdentifier"] as? String ?? ""
        containerIDs[url.path] = found
        return found.isEmpty ? nil : found
    }

    fileprivate func isUUID(_ name: String) -> Bool {
        name.range(of: "^[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}$", options: .regularExpression) != nil
    }

    fileprivate func loadJobs() -> [Job] {
        let folders = [(roots.home.appendingPathComponent("Library/LaunchAgents"), false), (roots.atRoot("Library/LaunchAgents"), false), (roots.atRoot("Library/LaunchDaemons"), true)]
        var list: [Job] = []
        for (dir, daemon) in folders {
            for name in listing(dir) where name.hasSuffix(".plist") {
                let url = dir.appendingPathComponent(name)
                let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
                guard size < 1_000_000 else { continue }
                let info = NSDictionary(contentsOf: url) as? [String: Any] ?? [:]
                let associated = info["AssociatedBundleIdentifiers"] as? [String] ?? (info["AssociatedBundleIdentifiers"] as? String).map { [$0] } ?? []
                let program = info["Program"] as? String ?? (info["ProgramArguments"] as? [String])?.first
                list.append(Job(url: url, label: info["Label"] as? String ?? String(name.dropLast(6)), associated: associated, program: program, isDaemon: daemon))
            }
        }
        return list
    }

    private func artifactValues(_ value: Any?) -> [String] {
        if let text = value as? String { return [text] }
        return (value as? [Any])?.compactMap { $0 as? String } ?? []
    }

    fileprivate func loadCasks() -> [Cask] {
        let fm = FileManager.default
        var list: [Cask] = []
        for caskroom in roots.caskrooms {
            for token in listing(caskroom) {
                let dir = caskroom.appendingPathComponent(token)
                guard AppInventory.isRealDirectory(dir) else { continue }
                let meta = dir.appendingPathComponent(".metadata")
                var files = [meta.appendingPathComponent("INSTALL_RECEIPT.json")]
                for version in (try? fm.contentsOfDirectory(atPath: meta.path)) ?? [] {
                    for stamp in (try? fm.contentsOfDirectory(atPath: meta.appendingPathComponent(version).path)) ?? [] {
                        files.append(meta.appendingPathComponent("\(version)/\(stamp)/Casks/\(token).json"))
                    }
                }
                var cask = Cask(token: token, dir: dir)
                for file in files {
                    guard let data = try? Data(contentsOf: file), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
                    let artifacts = (json["uninstall_artifacts"] as? [[String: Any]] ?? []) + (json["artifacts"] as? [[String: Any]] ?? [])
                    for artifact in artifacts {
                        for entry in artifact["app"] as? [Any] ?? [] {
                            if let name = entry as? String { cask.appNames.append(URL(fileURLWithPath: name).lastPathComponent) }
                            if let target = (entry as? [String: Any])?["target"] as? String { cask.appNames.append(URL(fileURLWithPath: target).lastPathComponent) }
                        }
                        for step in artifact["uninstall"] as? [[String: Any]] ?? [] { cask.quitIDs += artifactValues(step["quit"]) }
                        for step in artifact["zap"] as? [[String: Any]] ?? [] {
                            for key in ["trash", "delete"] { cask.zap += artifactValues(step[key]) }
                        }
                    }
                }
                for version in listing(dir) where AppInventory.isRealDirectory(dir.appendingPathComponent(version)) {
                    for name in listing(dir.appendingPathComponent(version)) where name.lowercased().hasSuffix(".app") {
                        cask.staged.append(dir.appendingPathComponent(version).appendingPathComponent(name).path)
                    }
                }
                list.append(cask)
            }
        }
        return list
    }

    fileprivate func isInstalledElsewhere(_ app: AppIdentity) -> Bool {
        guard !app.bundleID.isEmpty else { return false }
        return installed.contains { $0.url != app.url && $0.bundleID.caseInsensitiveCompare(app.bundleID) == .orderedSame } || roots.isKnownApp(app.bundleID)
    }

    func trashed() -> [AppIdentity] {
        AppInventory.trashed(roots).filter { !isInstalledElsewhere($0) }
    }

    static func allocatedSize(of url: URL) -> Int64 {
        guard let path = strdup(url.path) else { return 0 }
        defer { free(path) }
        var paths: [UnsafeMutablePointer<CChar>?] = [path, nil]
        guard let stream = fts_open(&paths, FTS_PHYSICAL | FTS_NOCHDIR | FTS_XDEV, nil) else { return 0 }
        defer { fts_close(stream) }
        var total: Int64 = 0
        var linked = Set<UInt64>()
        while let entry = fts_read(stream) {
            let kind = Int32(entry.pointee.fts_info)
            guard [FTS_D, FTS_F, FTS_SL, FTS_SLNONE, FTS_DEFAULT, FTS_DNR].contains(kind), let info = entry.pointee.fts_statp?.pointee else { continue }
            if kind != FTS_D, kind != FTS_DNR, info.st_nlink > 1, !linked.insert(info.st_ino).inserted { continue }
            total += Int64(info.st_blocks) * 512
        }
        return total
    }
}

private final class Run {
    let app: AppIdentity
    let owners: OwnerIndex
    let me: Int
    var found: [String: Leftover] = [:]

    init(app: AppIdentity, owners: OwnerIndex, me: Int) {
        self.app = app
        self.owners = owners
        self.me = me
    }

    func verdict(_ claims: [Int: Claim]) -> (claim: Claim, shared: [String])? {
        guard let mine = claims[me] else { return nil }
        var shared = Set<String>()
        for (other, claim) in claims where other != me {
            if claim.rank > mine.rank { return nil }
            if claim.rank == mine.rank { shared.insert(owners.apps[other].displayName) }
        }
        return (mine, shared.sorted())
    }

    func isForeign(_ claims: [Int: Claim]) -> Bool {
        claims.contains { $0.key != me && $0.value.tier >= 2 }
    }
}

extension AppFootprint {
    fileprivate static let orphanPaths: Set<String> = [
        "Library/Preferences", "Library/Preferences/ByHost", "Library/Containers", "Library/Group Containers", "Library/Saved Application State",
        "Library/Caches", "Library/HTTPStorages", "Library/WebKit", "Library/Application Support", "Library/Application Scripts", "Library/LaunchAgents",
    ]
    fileprivate static let orphanWalkLimit = 2000
    fileprivate static let orphanQuietPeriod: TimeInterval = 7 * 86_400

    convenience init(roots: AppRoots = .live) {
        self.init(roots: roots, installed: AppInventory.installed(roots), system: AppInventory.system(roots))
    }

    func isSystem(_ app: AppIdentity) -> Bool {
        let real = app.url.resolvingSymlinksInPath().path
        let prefix = roots.root.resolvingSymlinksInPath().appendingPathComponent("System").path + "/"
        return (real + "/").hasPrefix(prefix) || system.contains { $0.url.resolvingSymlinksInPath().path == real }
    }

    func scan(_ app: AppIdentity) -> [Leftover] {
        let run = makeRun(app)
        merge(makeLeftover(app.url, kind: .app, reason: .bundle, preselected: true), into: run)
        scanPlaces(run)
        scanJobs(run)
        scanLinks(run)
        scanCasks(run)
        scanReceipts(run)
        return run.found.values.sorted { ($0.kind, $0.url.path.lowercased()) < ($1.kind, $1.url.path.lowercased()) }
    }

    fileprivate func makeRun(_ app: AppIdentity) -> Run {
        if let position = index.apps.firstIndex(where: { $0.url == app.url }) { return Run(app: app, owners: index, me: position) }
        return Run(app: app, owners: OwnerIndex(index.apps + [app], blocked: blocked), me: index.apps.count)
    }

    fileprivate func makeLeftover(_ url: URL, kind: LeftoverKind, reason: LeftoverReason, preselected: Bool, shared: [String] = []) -> Leftover? {
        guard let info = fileInfo(url) else { return nil }
        var item = Leftover(url: url, kind: kind, reason: reason, preselected: preselected && shared.isEmpty, sharedWith: shared)
        item.device = info.device
        item.inode = info.inode
        item.isLink = info.isLink
        item.needsAdmin = needsAdmin(url, isLink: info.isLink, isDirectory: info.isDirectory)
        return item
    }

    fileprivate static func strength(_ reason: LeftoverReason) -> Int {
        switch reason {
        case .bundle: return 9
        case .byID, .appGroup, .launchJob, .helper, .receipt, .cliLink, .homebrew: return 8
        case .vendor: return 4
        case .byName: return 3
        case .related: return 1
        }
    }

    fileprivate func merge(_ item: Leftover?, into run: Run) {
        guard let item else { return }
        let key = item.url.standardizedFileURL.path
        guard let existing = run.found[key] else {
            run.found[key] = item
            return
        }
        let incomingWins = Self.strength(item.reason) > Self.strength(existing.reason)
        var winner = incomingWins ? item : existing
        let loser = incomingWins ? existing : item
        winner.jobLabel = winner.jobLabel ?? loser.jobLabel
        winner.isDaemon = winner.isDaemon || loser.isDaemon
        winner.packageID = winner.packageID ?? loser.packageID
        run.found[key] = winner
    }

    fileprivate func preselects(_ claim: Claim, _ app: AppIdentity) -> Bool {
        guard !claim.loose else { return false }
        return claim.tier == 3 || (claim.tier == 2 && !app.bundleID.isEmpty)
    }

    fileprivate func propose(_ run: Run, _ url: URL, kind: LeftoverKind, claims: [Int: Claim], names: [String]) {
        guard let (claim, shared) = run.verdict(claims), !isProtected(url, for: run.app, names: names) else { return }
        merge(makeLeftover(url, kind: kind, reason: claim.reason, preselected: preselects(claim, run.app), shared: shared), into: run)
    }

    fileprivate func matchName(_ url: URL) -> String {
        let ext = url.pathExtension
        guard !ext.isEmpty, ext.count <= 12, ext.allSatisfy(\.isLetter) else { return url.lastPathComponent }
        return url.deletingPathExtension().lastPathComponent
    }

    fileprivate func scanPlaces(_ run: Run) {
        let vendorKeys = Set(run.app.vendors.map(AppNames.squash))
        for place in places where !place.mode.contains(.job) {
            let dir = directory(place)
            for name in listing(dir) {
                let url = dir.appendingPathComponent(name)
                var mode = place.mode
                var extra: [String] = []
                var title = name
                if mode.contains(.container), isUUID(name) {
                    guard let id = containerID(url) else { continue }
                    extra = [id]
                } else if mode.contains(.embedded) {
                    title = matchName(url)
                    if let id = embeddedID(url) {
                        extra = [id]
                        mode.insert(.id)
                    }
                }
                let claims = run.owners.claims(name, name: title, extraIDs: extra, mode: mode)
                if claims.isEmpty {
                    if mode.contains(.vendor), vendorKeys.contains(AppNames.squash(name)) { scanVendorFolder(run, url, kind: place.kind) }
                    continue
                }
                propose(run, url, kind: place.kind, claims: claims, names: [name] + extra)
            }
        }
    }

    fileprivate func scanVendorFolder(_ run: Run, _ url: URL, kind: LeftoverKind) {
        guard !isProtected(url, for: run.app, names: [url.lastPathComponent]) else { return }
        let alone = run.owners.sharers(ofVendor: AppNames.squash(url.lastPathComponent), team: run.app.teamID, excluding: run.app.url).isEmpty
        let children = listing(url).map { (name: $0, claims: run.owners.claims($0, mode: [.id, .name, .vendorChild])) }
        let ownsAll = alone && children.allSatisfy { child in
            guard let (claim, shared) = run.verdict(child.claims) else { return false }
            return shared.isEmpty && preselects(claim, run.app)
        }
        if ownsAll {
            merge(makeLeftover(url, kind: kind, reason: .vendor, preselected: true), into: run)
            return
        }
        for child in children {
            let claims = alone && child.claims.isEmpty ? [run.me: Claim(tier: 1, spec: 0, reason: .related)] : child.claims
            propose(run, url.appendingPathComponent(child.name), kind: kind, claims: claims, names: [child.name])
        }
    }

    fileprivate func scanJobs(_ run: Run) {
        let tools = roots.atRoot("Library/PrivilegedHelperTools").standardizedFileURL.path + "/"
        let owned = run.found.values.filter { $0.kind == .appData && $0.preselected && !$0.isLink }.map { $0.url.standardizedFileURL.path + "/" }
        for job in jobs {
            var claims = run.owners.jobClaims(job)
            for (app, claim) in run.owners.claims(job.url.lastPathComponent, mode: .id) where (claims[app]?.rank ?? 0) < claim.rank { claims[app] = claim }
            if claims[run.me] == nil, let program = job.program, owned.contains(where: { program.hasPrefix($0) }) {
                claims[run.me] = Claim(tier: 3, spec: 97_000, reason: .launchJob(job.label))
            }
            guard let (claim, shared) = run.verdict(claims), !isProtected(job.url, for: run.app, names: [job.url.lastPathComponent, job.label]) else { continue }
            let selected = preselects(claim, run.app)
            var item = makeLeftover(job.url, kind: .background, reason: claim.reason, preselected: selected, shared: shared)
            item?.jobLabel = job.label
            item?.isDaemon = job.isDaemon
            merge(item, into: run)
            var tool = [roots.atRoot("Library/PrivilegedHelperTools/" + job.label)]
            if let program = job.program, program.hasPrefix(tools) { tool.append(URL(fileURLWithPath: program)) }
            for url in tool where !isProtected(url, for: run.app, names: [url.lastPathComponent]) {
                merge(makeLeftover(url, kind: .background, reason: .helper(job.label), preselected: selected, shared: shared), into: run)
            }
        }
    }

    fileprivate func scanLinks(_ run: Run) {
        let bundle = run.app.url.resolvingSymlinksInPath().path + "/"
        for folder in Self.linkFolders(roots) {
            for name in listing(folder) {
                let url = folder.appendingPathComponent(name)
                guard let info = fileInfo(url), info.isLink, let target = try? FileManager.default.destinationOfSymbolicLink(atPath: url.path) else { continue }
                let destination = target.hasPrefix("/") ? URL(fileURLWithPath: target) : folder.appendingPathComponent(target)
                guard destination.resolvingSymlinksInPath().path.hasPrefix(bundle), !isProtected(url, for: run.app, names: [name], allowLink: true) else { continue }
                merge(makeLeftover(url, kind: .install, reason: .cliLink, preselected: true), into: run)
            }
        }
    }

    fileprivate func caskMatches(_ cask: Cask, _ app: AppIdentity) -> Bool {
        let file = app.url.lastPathComponent.lowercased()
        if cask.appNames.contains(where: { $0.lowercased() == file }) { return true }
        if !app.bundleID.isEmpty, cask.quitIDs.contains(where: { $0.caseInsensitiveCompare(app.bundleID) == .orderedSame }) { return true }
        let resolved = app.url.resolvingSymlinksInPath().path
        return cask.staged.contains { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path == resolved }
    }

    fileprivate func globbed(_ pattern: String) -> [String] {
        var results = glob_t()
        defer { globfree(&results) }
        guard glob(pattern, GLOB_NOSORT, nil, &results) == 0 else { return [] }
        return (0..<Int(results.gl_pathc)).compactMap { results.gl_pathv[$0].map { String(cString: $0) } }
    }

    fileprivate func zapPaths(_ cask: Cask) -> [URL] {
        let homeLibrary = roots.home.appendingPathComponent("Library").standardizedFileURL.path + "/"
        let rootLibrary = roots.atRoot("Library").standardizedFileURL.path + "/"
        var found: [URL] = []
        for raw in cask.zap {
            let expanded: String
            if raw.hasPrefix("~/") {
                expanded = roots.home.path + "/" + String(raw.dropFirst(2))
            } else if raw.hasPrefix("/Library/") {
                expanded = roots.atRoot(String(raw.dropFirst())).path
            } else {
                continue
            }
            var candidates = [expanded]
            if expanded.contains(where: { "*?[".contains($0) }) {
                guard expanded.hasPrefix(homeLibrary) else { continue }
                candidates = globbed(expanded)
            }
            for path in candidates {
                let url = URL(fileURLWithPath: path).standardizedFileURL
                if url.path.hasPrefix(homeLibrary) || url.path.hasPrefix(rootLibrary) { found.append(url) }
            }
        }
        return found
    }

    fileprivate func scanCasks(_ run: Run) {
        for cask in casks where caskMatches(cask, run.app) {
            let shared = run.owners.apps.filter { $0.url != run.app.url && caskMatches(cask, $0) }.map(\.displayName).sorted()
            merge(makeLeftover(cask.dir, kind: .install, reason: .homebrew(cask.token), preselected: true, shared: shared), into: run)
            for url in zapPaths(cask) {
                let name = url.lastPathComponent
                guard !run.isForeign(run.owners.claims(name, mode: [.id, .name])), !isProtected(url, for: run.app, names: [name]) else { continue }
                let kind = kindByDirectory[url.deletingLastPathComponent().standardizedFileURL.path] ?? .appData
                merge(makeLeftover(url, kind: kind, reason: .homebrew(cask.token), preselected: true, shared: shared), into: run)
            }
        }
    }

    fileprivate static func field(_ key: String, in text: String) -> String? {
        for line in text.split(separator: "\n") where line.hasPrefix(key + ":") {
            return line.dropFirst(key.count + 1).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private static func receiptPrefix(_ info: String) -> String {
        let location = (field("location", in: info) ?? "").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return location.isEmpty ? "" : location + "/"
    }

    fileprivate func receiptCandidates(for app: AppIdentity) -> [String] {
        let vendors = Set(app.ids.map(AppNames.twoParts))
        let names = app.names.map(AppNames.squash).filter { $0.count >= 5 && AppNames.usable($0) }
        let related = thirdPartyPackages.filter { package in
            vendors.contains(AppNames.twoParts(package)) || names.contains { AppNames.squash(package).contains($0) }
        }
        return Array(related.prefix(8))
    }

    fileprivate func scanReceipts(_ run: Run) {
        var loaded: [String: (info: String, files: String)] = [:]
        var found: [String] = []
        if let report = roots.pkgutil(["--file-info", run.app.url.path]) {
            found = AppIdentity.unique(report.split(separator: "\n").compactMap { line in
                line.hasPrefix("pkgid:") ? String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces) : nil
            })
        }
        if found.isEmpty {
            let appPath = run.app.url.standardizedFileURL.path
            for package in receiptCandidates(for: run.app) {
                let info = roots.pkgutil(["--pkg-info", package]) ?? ""
                let prefix = Self.receiptPrefix(info)
                guard let files = roots.pkgutil(["--files", package]), files.split(separator: "\n").contains(where: {
                    $0.hasSuffix(".app") && roots.atRoot(prefix + String($0)).standardizedFileURL.path == appPath
                }) else { continue }
                loaded[package] = (info, files)
                found.append(package)
            }
        }
        for package in found where !package.lowercased().hasPrefix("com.apple.") {
            let info = loaded[package]?.info ?? roots.pkgutil(["--pkg-info", package]) ?? ""
            guard (Self.field("volume", in: info) ?? "/") == "/", let files = loaded[package]?.files ?? roots.pkgutil(["--files", package]) else { continue }
            let prefix = Self.receiptPrefix(info)
            var otherApps = Set<String>()
            var items: [Leftover] = []
            for line in files.split(separator: "\n") {
                let url = roots.atRoot(prefix + String(line))
                if line.hasSuffix(".app"), let other = run.owners.appPaths.first(where: { $0.path == url.standardizedFileURL.path && $0.app != run.me }) {
                    otherApps.insert(run.owners.apps[other.app].displayName)
                }
                guard let kind = kindByDirectory[url.deletingLastPathComponent().standardizedFileURL.path] else { continue }
                let name = url.lastPathComponent
                guard !run.isForeign(run.owners.claims(name, mode: [.id, .name])), !isProtected(url, for: run.app, names: [name]) else { continue }
                if let item = makeLeftover(url, kind: kind, reason: .receipt(package), preselected: true) { items.append(item) }
            }
            let shared = otherApps.sorted()
            for var item in items {
                item.sharedWith = shared
                item.preselected = shared.isEmpty
                merge(item, into: run)
            }
            var receipt = Leftover(url: roots.atRoot("var/db/receipts/\(package).plist"), kind: .install, reason: .receipt(package), preselected: shared.isEmpty, sharedWith: shared, needsAdmin: true)
            receipt.packageID = package
            merge(receipt, into: run)
        }
    }

    fileprivate func newestChange(of urls: [URL]) -> Date? {
        var newest = 0.0
        var visited = 0
        for url in urls {
            guard let path = strdup(url.path) else { return nil }
            defer { free(path) }
            var paths: [UnsafeMutablePointer<CChar>?] = [path, nil]
            guard let stream = fts_open(&paths, FTS_PHYSICAL | FTS_NOCHDIR | FTS_XDEV, nil) else { return nil }
            defer { fts_close(stream) }
            while let entry = fts_read(stream) {
                let kind = Int32(entry.pointee.fts_info)
                if kind == FTS_DNR || kind == FTS_ERR || kind == FTS_NS { return nil }
                guard kind != FTS_DP, let info = entry.pointee.fts_statp?.pointee else { continue }
                newest = max(newest, Double(info.st_mtimespec.tv_sec) + Double(info.st_mtimespec.tv_nsec) / 1e9)
                visited += 1
                if visited >= Self.orphanWalkLimit { break }
            }
        }
        return Date(timeIntervalSince1970: newest)
    }

    fileprivate func aliveJobs() -> (ids: Set<String>, programs: [String]) {
        var ids = Set<String>()
        var programs: [String] = []
        for job in jobs {
            guard let program = job.program, program.hasPrefix("/"), FileManager.default.fileExists(atPath: program), !AppInventory.isInTrash(URL(fileURLWithPath: program)) else { continue }
            ids.insert(job.label.lowercased())
            ids.formUnion(job.associated.map { $0.lowercased() })
            programs.append(program)
        }
        return (ids, programs)
    }

    func orphans(now: Date = Date()) -> [OrphanGroup] {
        struct Member {
            var url: URL
            var kind: LeftoverKind
            var raw: String
        }
        var families: [String: (id: String, members: [Member])] = [:]
        for place in places where place.base == .home && Self.orphanPaths.contains(place.path) {
            let dir = directory(place)
            for name in listing(dir) {
                guard let id = AppNames.orphanID(name) else { continue }
                families[id.lowercased(), default: (id, [])].members.append(Member(url: dir.appendingPathComponent(name), kind: place.kind, raw: name))
            }
        }
        var merged: [String: (id: String, members: [Member])] = [:]
        for key in families.keys.sorted(by: { $0.count < $1.count }) {
            guard let family = families[key] else { continue }
            if let root = AppNames.dottedPrefixes(key).reversed().first(where: { merged[$0] != nil }) {
                merged[root]?.members += family.members
            } else {
                merged[key] = family
            }
        }
        let alive = aliveJobs()
        var result: [OrphanGroup] = []
        for (key, family) in merged {
            guard !AppNames.isApple(family.members.flatMap { AppNames.idForms($0.raw) } + [key]) else { continue }
            guard index.claims(key, mode: .id).isEmpty, !index.idPrefixes.contains(key), !index.vendorPrefixes.contains(AppNames.twoParts(key)), !index.knowsVendor(key) else { continue }
            guard !AppNames.dottedPrefixes(key).contains(where: alive.ids.contains), !alive.ids.contains(where: { $0.hasPrefix(key + ".") }) else { continue }
            guard !family.members.contains(where: { member in alive.programs.contains { $0.hasPrefix(member.url.path + "/") } }) else { continue }
            guard !roots.isKnownApp(family.id) else { continue }
            guard let newest = newestChange(of: family.members.map(\.url)), now.timeIntervalSince(newest) >= Self.orphanQuietPeriod else { continue }
            let items = family.members.compactMap { makeLeftover($0.url, kind: $0.kind, reason: .byID(family.id), preselected: false) }
                .sorted { ($0.kind, $0.url.path.lowercased()) < ($1.kind, $1.url.path.lowercased()) }
            if !items.isEmpty { result.append(OrphanGroup(id: key, name: AppNames.orphanTitle(family.id), items: items, newest: newest)) }
        }
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

enum AppSearch {
    private static let cyrillic = Array("йцукенгшщзфывапролдячсмить")
    private static let latin = Array("qwertyuiopasdfghjklzxcvbnm")
    private static let toLatin: [Character: Character] = Dictionary(uniqueKeysWithValues: zip(cyrillic, latin)).merging(["і": "s"]) { first, _ in first }
    private static let toRussian: [Character: Character] = Dictionary(uniqueKeysWithValues: zip(latin, cyrillic))
    private static let toUkrainian: [Character: Character] = toRussian.merging(["s": "і"]) { _, new in new }

    private static func variants(_ query: String) -> [String] {
        let lower = query.lowercased()
        var found = [lower]
        for table in [toLatin, toRussian, toUkrainian] {
            let converted = String(lower.map { table[$0] ?? $0 })
            if !found.contains(converted) { found.append(converted) }
        }
        return found
    }

    private static func isWordPrefix(_ terms: [Substring], of text: String) -> Bool {
        let words = text.split(separator: " ")
        return terms.allSatisfy { term in words.contains { $0.hasPrefix(term) } }
    }

    private static func initials(_ text: String) -> String {
        String(text.split(separator: " ").compactMap(\.first))
    }

    static func score(_ query: String, titles: [String], others: [String]) -> Int {
        let names = titles.map(SettingsSearch.normalized)
        let rest = others.map(SettingsSearch.normalized)
        var best = 0
        for (position, variant) in variants(query).enumerated() {
            let value = SettingsSearch.normalized(variant)
            guard !value.isEmpty else { continue }
            let terms = value.split(separator: " ")
            var points = 0
            if names.contains(value) {
                points = 100
            } else if names.contains(where: { $0.hasPrefix(value) }) {
                points = 90
            } else if names.contains(where: { isWordPrefix(terms, of: $0) }) {
                points = 80
            } else if terms.count == 1, value.count >= 2, names.contains(where: { initials($0).hasPrefix(value) }) {
                points = 70
            } else if rest.contains(where: { isWordPrefix(terms, of: $0) }) {
                points = 60
            } else if SettingsSearch.matches(variant, fields: titles + others) {
                points = 50
            }
            if points > 0 { best = max(best, points - (position == 0 ? 0 : 5)) }
        }
        return best
    }

    static func score(_ app: AppIdentity, query: String) -> Int {
        score(query, titles: [app.displayName] + app.names, others: app.vendors + [app.organization, app.bundleID])
    }

    static func matches(_ app: AppIdentity, query: String) -> Bool {
        score(app, query: query) > 0
    }

    static func filter(_ apps: [AppIdentity], query: String) -> [AppIdentity] {
        guard !SettingsSearch.normalized(query).isEmpty else { return apps }
        let scored = apps.map { (app: $0, points: score($0, query: query)) }.filter { $0.points > 0 }
        return scored.sorted {
            $0.points != $1.points ? $0.points > $1.points : $0.app.displayName.localizedCaseInsensitiveCompare($1.app.displayName) == .orderedAscending
        }.map(\.app)
    }
}
