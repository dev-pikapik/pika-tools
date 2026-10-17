import Foundation

@main
struct TestFinderMenu {
    static func main() {
        let website = "com.pesotchi.pika-tools", store = "com.pikapik.tools", dev = "com.pesotchi.pika-tools.dev"
        let rehearsal = "com.pikapik.tools.rehearsal", e2e = "com.pikapik.e2e.menu.a"

        func host(_ id: String, _ minute: Double, pid: Int32 = 100) -> RunningCopy {
            RunningCopy(pid: pid, bundleID: id, launched: Date(timeIntervalSince1970: 1_000_000 + minute * 60))
        }
        func shown(_ copies: [String], _ hosts: [RunningCopy]) -> [String] {
            let extensions = copies.map { $0 + ".new-file" }
            return extensions.filter { MainCopyChoice.showsMenu($0, among: extensions, hosts: hosts) }.map(MainCopyChoice.hostID)
        }

        precondition(shown([website, rehearsal], [host(website, 1)]) == [website], "a test copy next to the installed copy")
        precondition(shown([website, dev, rehearsal], [host(website, 1), host(dev, 5, pid: 200), host(rehearsal, 9, pid: 300)]) == [website], "dev and test copies next to the installed copy")
        precondition(shown([website, store], [host(website, 1), host(store, 2, pid: 200)]) == [store], "the copy that started last")
        precondition(shown([website, store], [host(store, 1, pid: 200), host(website, 2)]) == [website], "the copy that started last")
        precondition(shown([website, dev], [host(dev, 5, pid: 200)]) == [dev], "the main copy quit")
        precondition(shown([website, store, dev], [host(dev, 5, pid: 200)]) == [dev], "the main copy quit")
        precondition(shown([dev, rehearsal], [host(dev, 1), host(rehearsal, 2, pid: 200)]) == [rehearsal], "two test copies")
        precondition(shown([website, dev, rehearsal], []) == [website], "no copy runs")
        precondition(shown([website, store], [host(website, 1), host(website, 3, pid: 200), host(store, 2, pid: 300)]) == [website], "two copies of one app")
        precondition(MainCopyChoice.showsMenu(dev + ".new-file", among: [website + ".new-file"], hosts: [host(website, 1)]), "an extension that does not see itself")

        let copies = [website, store, dev, rehearsal, e2e]
        for set in 1..<(1 << copies.count) {
            let installed = copies.indices.filter { set & 1 << $0 != 0 }.map { copies[$0] }
            for running in 0..<(1 << installed.count) {
                for order in [1.0, -1.0, 0.0] {
                    let hosts = installed.indices.filter { running & 1 << $0 != 0 }.map { host(installed[$0], order * Double($0), pid: Int32(100 + $0)) }
                    precondition(shown(installed, hosts).count == 1, "\(installed), running \(hosts.map(\.bundleID))")
                }
            }
        }
        print("finder menu: ok")
    }
}
