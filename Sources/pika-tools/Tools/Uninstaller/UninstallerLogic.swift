import Foundation

enum AppSort: CaseIterable {
    case name, size, lastUsed

    var title: String {
        switch self {
        case .name: String(localized: "Name")
        case .size: String(localized: "Size")
        case .lastUsed: String(localized: "Last used")
        }
    }

    func ordered(_ apps: [AppIdentity], size: (AppIdentity) -> Int64?, used: (AppIdentity) -> Date?) -> [AppIdentity] {
        switch self {
        case .name: apps
        case .size: Self.rank(apps, size)
        case .lastUsed: Self.rank(apps, used)
        }
    }

    private static func rank<Key: Comparable>(_ apps: [AppIdentity], _ key: (AppIdentity) -> Key?) -> [AppIdentity] {
        let keyed = apps.enumerated().map { (index: $0.offset, app: $0.element, key: key($0.element)) }
        return keyed.sorted { a, b in
            switch (a.key, b.key) {
            case let (x?, y?) where x != y: x > y
            case (.some, nil): true
            case (nil, .some): false
            default: a.index < b.index
            }
        }.map(\.app)
    }
}

struct RemovalPlan {
    enum Check { case on, off, mixed }

    struct Group: Identifiable {
        let kind: LeftoverKind
        let items: [Leftover]
        var id: Int { kind.rawValue }
    }

    private(set) var items: [Leftover]
    private(set) var selected: Set<String>
    private let inert: Set<String>

    init(_ found: [Leftover]) {
        items = found.map { item in
            var item = item
            if item.packageID != nil { item.size = 0 }
            return item
        }
        let locked = Set(found.filter { AppInventory.isInTrash($0.url) }.map(\.id))
        inert = locked
        selected = Set(found.filter { $0.preselected && !locked.contains($0.id) }.map(\.id))
    }

    var groups: [Group] {
        Dictionary(grouping: items, by: \.kind).sorted { $0.key < $1.key }.map { Group(kind: $0.key, items: $0.value) }
    }

    func isInert(_ item: Leftover) -> Bool { inert.contains(item.id) }
    func isOn(_ item: Leftover) -> Bool { selected.contains(item.id) }

    func state(of kind: LeftoverKind) -> Check {
        let live = items.filter { $0.kind == kind && !inert.contains($0.id) }
        let on = live.filter { selected.contains($0.id) }.count
        return on == 0 ? .off : on == live.count ? .on : .mixed
    }

    func hasChoice(in kind: LeftoverKind) -> Bool {
        items.contains { $0.kind == kind && !inert.contains($0.id) }
    }

    mutating func toggle(_ item: Leftover) {
        guard !inert.contains(item.id) else { return }
        if !selected.insert(item.id).inserted { selected.remove(item.id) }
    }

    mutating func set(_ item: Leftover, on: Bool) {
        guard !inert.contains(item.id) else { return }
        if on { selected.insert(item.id) } else { selected.remove(item.id) }
    }

    mutating func set(_ kind: LeftoverKind, on: Bool) {
        let ids = items.filter { $0.kind == kind && !inert.contains($0.id) }.map(\.id)
        if on { selected.formUnion(ids) } else { selected.subtract(ids) }
    }

    mutating func setAll(on: Bool) {
        LeftoverKind.allCases.forEach { set($0, on: on) }
    }

    var allOn: Bool {
        let live = items.filter { !inert.contains($0.id) }
        return !live.isEmpty && live.allSatisfy { selected.contains($0.id) }
    }

    mutating func setSizes(_ sizes: [String: Int64]) {
        for index in items.indices {
            if let size = sizes[items[index].id] { items[index].size = size }
        }
    }

    func chosen(reset: Bool = false) -> [Leftover] {
        items.filter { selected.contains($0.id) && !(reset && ($0.kind == .app || $0.kind == .install)) }
    }

    func bytes(reset: Bool = false) -> Int64? {
        Self.total(chosen(reset: reset))
    }

    func bytes(of group: Group) -> Int64? {
        Self.total(group.items.filter { !inert.contains($0.id) })
    }

    func needsAdmin(reset: Bool = false) -> Bool {
        chosen(reset: reset).contains(where: \.needsAdmin)
    }

    private static func total(_ list: [Leftover]) -> Int64? {
        var sum: Int64 = 0
        for item in list {
            guard let size = item.size else { return nil }
            sum += size
        }
        return sum
    }
}

extension LeftoverKind {
    var title: String {
        switch self {
        case .app: String(localized: "The app")
        case .appData: String(localized: "Saved data")
        case .containers: String(localized: "Private storage")
        case .caches: String(localized: "Temporary files")
        case .preferences: String(localized: "Settings")
        case .background: String(localized: "Background helpers")
        case .extensions: String(localized: "Add-ons")
        case .logs: String(localized: "Logs")
        case .install: String(localized: "Installer records")
        }
    }

    var symbol: String {
        switch self {
        case .app: "app.fill"
        case .appData: "folder.fill"
        case .containers: "archivebox.fill"
        case .caches: "tray.full.fill"
        case .preferences: "slider.horizontal.3"
        case .background: "gearshape.2.fill"
        case .extensions: "puzzlepiece.extension.fill"
        case .logs: "doc.text.fill"
        case .install: "shippingbox.fill"
        }
    }
}

extension LeftoverReason {
    var title: String {
        switch self {
        case .bundle: String(localized: "The app itself")
        case .byID: String(localized: "Belongs to the app")
        case .byName: String(localized: "Has the app’s name")
        case .appGroup: String(localized: "Shared with its helpers")
        case .launchJob: String(localized: "Runs in the background")
        case .helper: String(localized: "The app’s helper")
        case .receipt: String(localized: "From its installer")
        case .cliLink: String(localized: "Terminal command")
        case .homebrew: String(localized: "Installed with Homebrew")
        case .vendor: String(localized: "From the same developer")
        case .related: String(localized: "Might be related")
        }
    }
}

extension Leftover {
    var title: String { packageID ?? url.lastPathComponent }
}

extension AppIdentity {
    var byline: String {
        if !organization.isEmpty { return organization }
        return version.isEmpty ? "" : String(localized: "Version \(version)")
    }

    var details: String {
        [version.isEmpty ? nil : String(localized: "Version \(version)"), organization.isEmpty ? nil : organization].compactMap { $0 }.joined(separator: " · ")
    }

    init(leftovers group: OrphanGroup) {
        var id = group.id
        if case .byID(let found)? = group.items.first?.reason { id = found }
        self.init(url: URL(fileURLWithPath: "/Leftovers/\(group.id)/\(group.name).app"), bundleID: id)
    }

    var sourceID: String? {
        bundleID == displayName ? nil : bundleID
    }

    var dismissalKey: String {
        bundleID.isEmpty ? displayName : bundleID.lowercased()
    }
}

enum UninstallerText {
    private static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter
    }()

    private static let nothing: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = .useKB
        formatter.allowsNonnumericFormatting = false
        return formatter
    }()

    static func size(_ bytes: Int64) -> String {
        bytes == 0 ? nothing.string(fromByteCount: 0) : ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    static func used(_ date: Date, now: Date = Date()) -> String {
        relative.localizedString(for: date, relativeTo: now)
    }

    static func changed(_ date: Date, now: Date = Date()) -> String {
        String(localized: "Changed \(used(min(date, now), now: now))")
    }

    static func removed(_ date: Date, now: Date = Date()) -> String {
        String(localized: "Removed \(used(min(date, now), now: now))")
    }
}
