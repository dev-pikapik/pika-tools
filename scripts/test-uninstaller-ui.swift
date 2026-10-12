import Foundation

@main
struct TestUninstallerUI {
    static func app(_ name: String) -> AppIdentity {
        AppIdentity(url: URL(fileURLWithPath: "/Applications/\(name).app"), bundleID: "org.test.\(name.lowercased())")
    }

    static func item(_ path: String, _ kind: LeftoverKind, on: Bool = true, admin: Bool = false, receipt: String? = nil) -> Leftover {
        var item = Leftover(url: URL(fileURLWithPath: path), kind: kind, reason: .byID("x"), preselected: on)
        item.needsAdmin = admin
        item.packageID = receipt
        return item
    }

    static func main() {
        let a = app("Alpha"), b = app("Beta"), c = app("Gamma"), d = app("Delta")
        let all = [a, b, c, d]
        let sizes: [String: Int64] = [a.id: 5, c.id: 9, d.id: 5]
        let now = Date()
        let dates: [String: Date] = [b.id: now, a.id: now - 86_400, d.id: now - 86_400]

        precondition(AppSort.name.ordered(all, size: { sizes[$0.id] }, used: { dates[$0.id] }) == all)
        precondition(AppSort.size.ordered(all, size: { sizes[$0.id] }, used: { dates[$0.id] }) == [c, a, d, b])
        precondition(AppSort.lastUsed.ordered(all, size: { sizes[$0.id] }, used: { dates[$0.id] }) == [b, a, d, c])
        precondition(AppSort.size.ordered(all, size: { _ in nil }, used: { _ in nil }) == all)

        let inTrash = "/Users/me/.Trash/Alpha.app"
        let found = [
            item("/Applications/Alpha.app", .app),
            item("/Users/me/Library/Application Support/Alpha", .appData),
            item("/Users/me/Library/Application Support/Alpha Vendor", .appData, on: false),
            item("/Users/me/Library/Caches/org.test.alpha", .caches),
            item("/Library/LaunchDaemons/org.test.alpha.plist", .background, admin: true),
            item("/var/db/receipts/org.test.alpha.pkg.plist", .install, admin: true, receipt: "org.test.alpha.pkg"),
        ]
        var plan = RemovalPlan(found)
        precondition(plan.groups.map(\.kind) == [.app, .appData, .caches, .background, .install])
        precondition(plan.chosen().count == 5)
        precondition(plan.state(of: .appData) == .mixed)
        precondition(plan.state(of: .caches) == .on)
        precondition(plan.needsAdmin() && plan.needsAdmin(reset: true))
        precondition(!RemovalPlan([found[0], found[3]]).needsAdmin())
        precondition(plan.chosen(reset: true).map(\.kind) == [.appData, .caches, .background])
        precondition(plan.bytes() == nil)

        var measured: [String: Int64] = [:]
        for (index, thing) in found.enumerated() where thing.packageID == nil { measured[thing.id] = Int64(100 * (index + 1)) }
        plan.setSizes(measured.filter { $0.key.hasSuffix("Alpha.app") })
        precondition(plan.bytes() == nil)
        plan.setSizes(measured)
        precondition(plan.bytes() == 100 + 200 + 400 + 500)
        precondition(plan.bytes(reset: true) == 200 + 400 + 500)
        precondition(plan.bytes(of: plan.groups[1]) == 200 + 300)

        plan.set(.appData, on: true)
        precondition(plan.state(of: .appData) == .on && plan.chosen().count == 6)
        plan.toggle(found[1])
        precondition(plan.state(of: .appData) == .mixed)
        plan.set(.appData, on: false)
        precondition(plan.state(of: .appData) == .off && plan.chosen().count == 4)

        let trashed = RemovalPlan([item(inTrash, .app), item("/Users/me/Library/Caches/org.test.alpha", .caches)])
        precondition(trashed.chosen().map(\.kind) == [.caches])
        precondition(trashed.isInert(trashed.items[0]) && !trashed.isInert(trashed.items[1]))
        precondition(!trashed.hasChoice(in: .app) && trashed.hasChoice(in: .caches))
        precondition(trashed.state(of: .app) == .off)
        var frozen = trashed
        frozen.toggle(frozen.items[0])
        frozen.set(.app, on: true)
        precondition(frozen.chosen().count == 1)

        precondition(RemovalPlan([]).chosen().isEmpty && RemovalPlan([]).bytes() == 0)
        precondition(plan.items[5].title == "org.test.alpha.pkg" && plan.items[1].title == "Alpha")

        var named = a
        named.version = "2.1"
        precondition(named.byline == "Version 2.1")
        named.organization = "Example Inc."
        precondition(named.byline == "Example Inc.")
        precondition(a.byline.isEmpty)

        precondition(named.details == "Version 2.1 · Example Inc." && a.details.isEmpty)
        var third = plan
        third.set(found[1], on: false)
        precondition(third.state(of: .appData) == .off && !third.isOn(found[1]))
        third.set(found[2], on: true)
        precondition(third.state(of: .appData) == .mixed && third.isOn(found[2]))
        var locked = trashed
        locked.set(locked.items[0], on: true)
        precondition(!locked.isOn(locked.items[0]))

        precondition(LeftoverKind.allCases.allSatisfy { !$0.title.isEmpty && !$0.symbol.isEmpty })
        precondition(UninstallerText.used(now - 3 * 86_400, now: now) != UninstallerText.used(now - 86_400, now: now))
        precondition(!UninstallerText.size(12_400_000_000).isEmpty)

        var kept = item("/Users/me/Library/Caches/Org.Test.Gone", .caches, on: false)
        kept.reason = .byID("Org.Test.Gone")
        let gone = OrphanGroup(id: "org.test.gone", name: "Gone", items: [kept], newest: now - 40 * 86_400)
        let twin = OrphanGroup(id: "gone", name: "Gone", items: [], newest: now)
        let left = AppIdentity(leftovers: gone)
        precondition(left.displayName == "Gone" && left.bundleID == "Org.Test.Gone")
        precondition(AppIdentity(leftovers: twin).id != left.id && AppIdentity(leftovers: twin).bundleID == "gone")
        precondition(left.dismissalKey == "org.test.gone" && AppIdentity(url: URL(fileURLWithPath: "/Applications/Plain.app"), bundleID: "").dismissalKey == "Plain")
        precondition(RemovalPlan(gone.items).chosen().isEmpty && RemovalPlan(gone.items).groups.map(\.kind) == [.caches])
        precondition(!UninstallerText.changed(now - 86_400, now: now).isEmpty)
        precondition(UninstallerText.changed(now + 3_600, now: now) == UninstallerText.changed(now, now: now))
        precondition(UninstallerText.removed(now - 86_400, now: now) != UninstallerText.changed(now - 86_400, now: now))
        print("uninstaller page: sorting, selection, totals, trashed apps, leftovers, wording: ok")
    }
}
