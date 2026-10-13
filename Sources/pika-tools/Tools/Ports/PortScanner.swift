import Darwin
import Foundation

struct PortListener: Identifiable, Equatable {
    let port: UInt16
    let pid: pid_t
    var tcp = false
    var udp = false
    var hosts: Set<String> = []

    var id: String { "\(port)-\(pid)" }
    var onlyThisMac: Bool { !hosts.isEmpty && hosts.allSatisfy(PortScanner.isLoopback) }
}

struct PortOwner: Equatable {
    let pid: pid_t
    let uid: uid_t
    let parent: pid_t
    let started: Double
    let name: String
    let path: String?
    let command: [String]
    let folder: String?

    var isMine: Bool { uid == getuid() }
    var isApple: Bool { pid == 1 || path.map { path in PortScanner.applePaths.contains { path.hasPrefix($0) } } ?? false }
}

enum PortScanner {
    static let applePaths = ["/System/", "/usr/libexec/", "/usr/sbin/", "/sbin/", "/Library/Apple/"]
    static let ephemeral: UInt16 = 49152

    static func listeners() -> [PortListener] {
        var found: [String: PortListener] = [:]
        func add(_ port: UInt16, _ pid: pid_t, tcp: Bool, host: String) {
            var entry = found["\(port)-\(pid)"] ?? PortListener(port: port, pid: pid)
            if tcp { entry.tcp = true } else { entry.udp = true }
            entry.hosts.insert(host)
            found[entry.id] = entry
        }
        for pid in pids() {
            for socket in sockets(of: pid) { add(socket.port, pid, tcp: socket.tcp, host: socket.host) }
        }
        if netstatWorks {
            var extra = 0
            for (tcp, proto) in [(true, "tcp"), (false, "udp")] {
                let rows = parse(netstat(proto), tcp: tcp)
                extra += rows.count
                for row in rows { add(row.port, row.pid, tcp: tcp, host: row.host) }
            }
            if !found.isEmpty, extra == 0 { netstatWorks = false }
        }
        return found.values.sorted { ($0.port, $0.pid) < ($1.port, $1.pid) }
    }

    static func ports(of pid: pid_t) -> Set<UInt16> {
        Set(sockets(of: pid).map(\.port))
    }

    static func isBusy(_ port: UInt16) -> Bool? {
        var results: [Int32] = []
        for tcp in [true, false] {
            for host in ["0.0.0.0", "127.0.0.1", "::", "::1"] { results.append(bindResult(port, host: host, tcp: tcp)) }
        }
        if results.contains(EADDRINUSE) { return true }
        return results.allSatisfy { $0 == 0 } ? false : nil
    }

    private static var netstatWorks = true

    private static func bindResult(_ port: UInt16, host: String, tcp: Bool) -> Int32 {
        let v6 = host.contains(":")
        let fd = socket(v6 ? AF_INET6 : AF_INET, tcp ? SOCK_STREAM : SOCK_DGRAM, 0)
        guard fd >= 0 else { return errno }
        defer { close(fd) }
        var on: Int32 = 1
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, socklen_t(MemoryLayout<Int32>.size))
        let result: Int32
        if v6 {
            setsockopt(fd, IPPROTO_IPV6, IPV6_V6ONLY, &on, socklen_t(MemoryLayout<Int32>.size))
            var address = sockaddr_in6()
            address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            address.sin6_family = sa_family_t(AF_INET6)
            address.sin6_port = port.bigEndian
            inet_pton(AF_INET6, host, &address.sin6_addr)
            result = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in6>.size)) } }
        } else {
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = port.bigEndian
            inet_pton(AF_INET, host, &address.sin_addr)
            result = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        }
        return result == 0 ? 0 : errno
    }

    static func owner(_ pid: pid_t) -> PortOwner? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, size > 0, info.kp_proc.p_pid == pid else { return nil }
        let started = info.kp_proc.p_un.__p_starttime
        let comm = withUnsafeBytes(of: info.kp_proc.p_comm) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
        let path = self.path(pid)
        let mine = info.kp_eproc.e_ucred.cr_uid == getuid()
        return PortOwner(
            pid: pid,
            uid: info.kp_eproc.e_ucred.cr_uid,
            parent: info.kp_eproc.e_ppid,
            started: Double(started.tv_sec) + Double(started.tv_usec) / 1_000_000,
            name: path.map { ($0 as NSString).lastPathComponent } ?? comm,
            path: path,
            command: mine ? arguments(pid) : [],
            folder: mine ? folder(pid) : nil
        )
    }

    static func isLoopback(_ host: String) -> Bool {
        host.hasPrefix("127.") || host == "::1" || host.hasSuffix("%lo0")
    }

    static func networkAddresses() -> [String] {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0, let first = list else { return [] }
        defer { freeifaddrs(list) }
        var found: [(name: String, address: String)] = []
        for item in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let flags = Int32(item.pointee.ifa_flags)
            guard flags & IFF_UP != 0, flags & IFF_RUNNING != 0, flags & IFF_LOOPBACK == 0,
                  let address = item.pointee.ifa_addr, address.pointee.sa_family == UInt8(AF_INET) else { continue }
            var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            var ipv4 = address.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
            guard inet_ntop(AF_INET, &ipv4, &buffer, socklen_t(buffer.count)) != nil else { continue }
            let text = String(cString: buffer)
            guard !text.hasPrefix("169.254."), !found.contains(where: { $0.address == text }) else { continue }
            found.append((String(cString: item.pointee.ifa_name), text))
        }
        return found.sorted { ($0.name.hasPrefix("en") ? 0 : 1, $0.name) < ($1.name.hasPrefix("en") ? 0 : 1, $1.name) }.map(\.address)
    }

    static func parse(_ text: String, tcp: Bool) -> [(port: UInt16, pid: pid_t, host: String)] {
        text.split(separator: "\n").compactMap { line in
            let fields = line.split(separator: " ", omittingEmptySubsequences: true)
            guard fields.count > 6, fields[0].hasPrefix(tcp ? "tcp" : "udp") else { return nil }
            if tcp ? fields[5] != "LISTEN" : fields[4] != "*.*" { return nil }
            guard let dot = fields[3].lastIndex(of: "."), let port = UInt16(fields[3][fields[3].index(after: dot)...]), port != 0,
                  tcp || port < ephemeral else { return nil }
            for field in fields.dropFirst(5) {
                guard let colon = field.lastIndex(of: ":") else { continue }
                let digits = field[field.index(after: colon)...]
                guard let pid = pid_t(digits), pid > 0 else { continue }
                return (port, pid, String(fields[3][..<dot]))
            }
            return nil
        }
    }

    private static func pids() -> [pid_t] {
        let count = proc_listallpids(nil, 0)
        guard count > 0 else { return [] }
        var pids = [pid_t](repeating: 0, count: Int(count) + 64)
        let found = pids.withUnsafeMutableBytes { proc_listallpids($0.baseAddress, Int32($0.count)) }
        return Array(pids.prefix(Int(max(found, 0)))).filter { $0 > 0 }
    }

    private static func sockets(of pid: pid_t) -> [(port: UInt16, tcp: Bool, host: String)] {
        let estimate = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, nil, 0)
        guard estimate > 0 else { return [] }
        let stride = MemoryLayout<proc_fdinfo>.stride
        var fds = [proc_fdinfo](repeating: proc_fdinfo(), count: Int(estimate) / stride + 16)
        let used = fds.withUnsafeMutableBytes { proc_pidinfo(pid, PROC_PIDLISTFDS, 0, $0.baseAddress, Int32($0.count)) }
        guard used > 0 else { return [] }
        var result: [(port: UInt16, tcp: Bool, host: String)] = []
        for fd in fds.prefix(Int(used) / stride) where fd.proc_fdtype == UInt32(PROX_FDTYPE_SOCKET) {
            var info = socket_fdinfo()
            let size = Int32(MemoryLayout<socket_fdinfo>.stride)
            guard proc_pidfdinfo(pid, fd.proc_fd, PROC_PIDFDSOCKETINFO, &info, size) == size else { continue }
            let socket = info.psi
            guard socket.soi_family == AF_INET || socket.soi_family == AF_INET6 else { continue }
            let tcp = socket.soi_kind == Int32(SOCKINFO_TCP)
            if tcp {
                guard socket.soi_proto.pri_tcp.tcpsi_state == Int32(TSI_S_LISTEN) else { continue }
            } else {
                guard socket.soi_kind == Int32(SOCKINFO_IN), socket.soi_protocol == IPPROTO_UDP else { continue }
            }
            let address = tcp ? socket.soi_proto.pri_tcp.tcpsi_ini : socket.soi_proto.pri_in
            let port = UInt16(bigEndian: UInt16(truncatingIfNeeded: address.insi_lport))
            guard port != 0, tcp || (address.insi_fport == 0 && port < ephemeral) else { continue }
            result.append((port, tcp, host(address)))
        }
        return result
    }

    private static func host(_ info: in_sockinfo) -> String {
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        if info.insi_vflag & UInt8(INI_IPV6) != 0 {
            var address = info.insi_laddr.ina_6
            if withUnsafeBytes(of: &address, { $0.allSatisfy { $0 == 0 } }) { return "*" }
            inet_ntop(AF_INET6, &address, &buffer, socklen_t(buffer.count))
        } else {
            var address = info.insi_laddr.ina_46.i46a_addr4
            if address.s_addr == 0 { return "*" }
            inet_ntop(AF_INET, &address, &buffer, socklen_t(buffer.count))
        }
        return String(cString: buffer)
    }

    private static func netstat(_ proto: String) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        process.arguments = ["-anv", "-p", proto]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return "" }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(decoding: data, as: UTF8.self)
    }

    private static func path(_ pid: pid_t) -> String? {
        var buffer = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
        guard proc_pidpath(pid, &buffer, UInt32(buffer.count)) > 0 else { return nil }
        return String(cString: buffer)
    }

    private static func folder(_ pid: pid_t) -> String? {
        var info = proc_vnodepathinfo()
        let size = Int32(MemoryLayout<proc_vnodepathinfo>.stride)
        guard proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &info, size) == size else { return nil }
        let path = withUnsafeBytes(of: info.pvi_cdir.vip_path) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
        return path.isEmpty ? nil : path
    }

    private static func arguments(_ pid: pid_t) -> [String] {
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4 else { return [] }
        var buffer = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0, size > 4 else { return [] }
        let count = buffer.withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
        var index = 4
        while index < size, buffer[index] != 0 { index += 1 }
        while index < size, buffer[index] == 0 { index += 1 }
        var result: [String] = []
        while result.count < count, index < size {
            let start = index
            while index < size, buffer[index] != 0 { index += 1 }
            result.append(String(decoding: buffer[start..<index], as: UTF8.self))
            index += 1
        }
        return result
    }
}
