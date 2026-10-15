import Darwin
import Foundation

@main
enum TestPorts {
    static func address(_ host: String, _ port: UInt16) -> sockaddr_storage {
        var storage = sockaddr_storage()
        withUnsafeMutableBytes(of: &storage) { raw in
            if host.contains(":") {
                var address = sockaddr_in6()
                address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
                address.sin6_family = sa_family_t(AF_INET6)
                address.sin6_port = port.bigEndian
                inet_pton(AF_INET6, host, &address.sin6_addr)
                withUnsafeBytes(of: address) { raw.copyMemory(from: $0) }
            } else {
                var address = sockaddr_in()
                address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                address.sin_family = sa_family_t(AF_INET)
                address.sin_port = port.bigEndian
                inet_pton(AF_INET, host, &address.sin_addr)
                withUnsafeBytes(of: address) { raw.copyMemory(from: $0) }
            }
        }
        return storage
    }

    static func port(of fd: Int32) -> UInt16 {
        var storage = sockaddr_storage()
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        _ = withUnsafeMutablePointer(to: &storage) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(fd, $0, &length) } }
        return withUnsafeBytes(of: storage) { UInt16($0[2]) << 8 | UInt16($0[3]) }
    }

    static func open(_ host: String, tcp: Bool, port: UInt16 = 0) -> (fd: Int32, port: UInt16)? {
        let fd = socket(host.contains(":") ? AF_INET6 : AF_INET, tcp ? SOCK_STREAM : SOCK_DGRAM, 0)
        let storage = address(host, port)
        let bound = withUnsafePointer(to: storage) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(storage.ss_len)) } }
        guard fd >= 0, bound == 0, !tcp || listen(fd, 4) == 0 else { return nil }
        return (fd, self.port(of: fd))
    }

    static func main() {
        let me = getpid()
        guard let v4 = open("127.0.0.1", tcp: true), let v6 = open("::1", tcp: true),
              let udp = (0..<100).lazy.compactMap({ _ in open("127.0.0.1", tcp: false, port: UInt16.random(in: 40000..<48000)) }).first
        else { fatalError("could not open test sockets") }

        let client = socket(AF_INET, SOCK_STREAM, 0)
        let target = address("127.0.0.1", v4.port)
        let connected = withUnsafePointer(to: target) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(client, $0, socklen_t(target.ss_len)) } }
        precondition(connected == 0, "connect: \(errno)")
        let clientPort = port(of: client)

        let tcpRows = PortScanner.kernel(tcp: true)
        let udpRows = PortScanner.kernel(tcp: false)
        precondition(!tcpRows.isEmpty, "the kernel list is empty: sign the test with a reverse-DNS identifier, see CONTRIBUTING.md")
        precondition(tcpRows.contains { $0.port == v4.port && $0.pid == me && $0.uid == getuid() && $0.host == "127.0.0.1" }, "IPv4 listener")
        precondition(tcpRows.contains { $0.port == v6.port && $0.pid == me && $0.host == "::1" }, "IPv6 listener")
        precondition(udpRows.contains { $0.port == udp.port && $0.pid == me && $0.host == "127.0.0.1" }, "UDP socket")
        precondition(!tcpRows.contains { $0.port == clientPort }, "a connection is not a listener")
        precondition(tcpRows.filter { $0.port == v4.port }.count == 1, "an accepted connection is not a listener")

        let mine = PortScanner.listeners().filter { $0.pid == me }
        precondition(mine.contains { $0.port == v4.port && $0.tcp && !$0.udp && $0.hosts == ["127.0.0.1"] && $0.onlyThisMac })
        precondition(mine.contains { $0.port == v6.port && $0.hosts == ["::1"] && $0.onlyThisMac })
        precondition(mine.contains { $0.port == udp.port && $0.udp && !$0.tcp })
        precondition(!mine.contains { $0.port == clientPort })
        precondition(PortScanner.ports(of: me).isSuperset(of: [v4.port, v6.port, udp.port]))

        let owner = PortScanner.owner(me)!
        precondition(owner.isMine && !owner.isApple && owner.parent == getppid() && owner.command.first?.isEmpty == false)
        precondition(owner.path?.hasSuffix("/" + owner.name) == true && owner.name == URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent)
        precondition(PortScanner.owner(1)?.isApple == true)

        for host in ["127.0.0.1", "127.0.1.1", "::1", "fe80::1%lo0"] { precondition(PortScanner.isLoopback(host), host) }
        for host in ["*", "0.0.0.0", "::", "192.168.1.5", "fe80::1%en0"] { precondition(!PortScanner.isLoopback(host), host) }

        func process(_ pid: pid_t, _ parent: pid_t) -> PortOwner {
            PortOwner(pid: pid, uid: getuid(), parent: parent, started: 0, name: "p\(pid)", path: nil, command: [], folder: nil)
        }
        let owners: [pid_t: PortOwner] = [100: process(100, 1), 101: process(101, 100), 102: process(102, 100), 200: process(200, 100), 300: process(300, 1)]
        let programs = PortScanner.programs([
            PortListener(port: 8000, pid: 101, tcp: true, hosts: ["*"]),
            PortListener(port: 8000, pid: 100, tcp: true, hosts: ["*"]),
            PortListener(port: 8000, pid: 102, tcp: true, hosts: ["::1"]),
            PortListener(port: 9000, pid: 200, tcp: true, hosts: ["127.0.0.1"]),
            PortListener(port: 5353, pid: 300, udp: true, hosts: ["*"]),
            PortListener(port: 5353, pid: 300, tcp: true, hosts: ["127.0.0.1"]),
            PortListener(port: 7000, pid: 999, tcp: true, hosts: ["*"]),
        ], owners: owners)
        precondition(programs.map(\.id) == [300, 100, 200], "\(programs.map(\.id))")
        precondition(programs[0].listeners.count == 1 && programs[0].listeners[0].tcp && programs[0].listeners[0].udp)
        precondition(programs[1].helpers == [101, 102] && programs[1].ports == [8000] && programs[1].listeners[0].hosts == ["*", "::1"])
        precondition(programs[2].helpers.isEmpty && programs[2].ports == [9000])

        precondition(!PortScanner.isFree(v4.port) && !PortScanner.isFree(udp.port), "a taken port reads as free")
        guard let spare = open("127.0.0.1", tcp: false) else { fatalError("could not open a spare socket") }
        close(spare.fd)
        precondition(PortScanner.isFree(spare.port), "a free port reads as taken")

        [v4.fd, v6.fd, udp.fd, client].forEach { close($0) }
        print("ports: kernel list, own sockets, owners and grouping ok")
    }
}
