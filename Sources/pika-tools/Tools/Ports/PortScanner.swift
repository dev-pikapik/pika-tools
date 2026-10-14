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
    var isApple: Bool { pid <= 1 || path.map { path in PortScanner.applePaths.contains { path.hasPrefix($0) } } ?? false }
}

struct PortProgram: Identifiable, Equatable {
    let owner: PortOwner
    var listeners: [PortListener]
    var helpers: [pid_t] = []

    var id: pid_t { owner.pid }
    var ports: [UInt16] { listeners.map(\.port) }
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
        let all = pids()
        for pid in all {
            for socket in sockets(of: pid) { add(socket.port, pid, tcp: socket.tcp, host: socket.host) }
        }
        for tcp in [true, false] {
            for row in kernel(tcp: tcp) where all.isEmpty || row.uid != getuid() { add(row.port, row.pid, tcp: tcp, host: row.host) }
        }
        return found.values.sorted { ($0.port, $0.pid) < ($1.port, $1.pid) }
    }

    /// macOS 27 hides the sockets of macOS and other users from a signed app, so a port missing from
    /// `listeners()` may still be taken: only a test bind tells.
    /// ponytail: checks 127.0.0.1, which also hits wildcard listeners; one bound to a single LAN or IPv6 address slips through.
    static func isFree(_ port: UInt16) -> Bool {
        [SOCK_STREAM, SOCK_DGRAM].allSatisfy { type in
            let fd = socket(AF_INET, type, 0)
            guard fd >= 0 else { return false }
            defer { close(fd) }
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_port = port.bigEndian
            address.sin_addr.s_addr = inet_addr("127.0.0.1")
            return withUnsafePointer(to: address) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) == 0 }
            }
        }
    }

    static func programs(_ listeners: [PortListener], owners: [pid_t: PortOwner]) -> [PortProgram] {
        let held = Dictionary(grouping: listeners, by: \.pid).mapValues { Set($0.map(\.port)) }
        func root(_ pid: pid_t) -> pid_t {
            var pid = pid
            for _ in 0..<32 {
                guard let parent = owners[pid]?.parent, parent != pid, owners[parent] != nil,
                      !(held[pid] ?? []).isDisjoint(with: held[parent] ?? []) else { break }
                pid = parent
            }
            return pid
        }
        var result: [pid_t: PortProgram] = [:]
        for pid in held.keys.sorted() {
            let top = root(pid)
            guard let owner = owners[top] else { continue }
            var program = result[top] ?? PortProgram(owner: owner, listeners: [])
            if top != pid { program.helpers.append(pid) }
            for listener in listeners where listener.pid == pid {
                if let index = program.listeners.firstIndex(where: { $0.port == listener.port }) {
                    program.listeners[index].tcp = program.listeners[index].tcp || listener.tcp
                    program.listeners[index].udp = program.listeners[index].udp || listener.udp
                    program.listeners[index].hosts.formUnion(listener.hosts)
                } else {
                    program.listeners.append(PortListener(port: listener.port, pid: top, tcp: listener.tcp, udp: listener.udp, hosts: listener.hosts))
                }
            }
            program.listeners.sort { $0.port < $1.port }
            result[top] = program
        }
        return result.values.sorted { ($0.ports.first ?? 0, $0.id) < ($1.ports.first ?? 0, $1.id) }
    }

    static func ports(of pid: pid_t) -> Set<UInt16> {
        Set(sockets(of: pid).map(\.port))
    }

    static func kernel(tcp: Bool) -> [(port: UInt16, pid: pid_t, uid: uid_t, host: String)] {
        let name = tcp ? "net.inet.tcp.pcblist_n" : "net.inet.udp.pcblist_n"
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return [] }
        var bytes = [UInt8](repeating: 0, count: size + size / 4)
        size = bytes.count
        guard sysctlbyname(name, &bytes, &size, nil, 0) == 0, size >= 24 else { return [] }
        return bytes.withUnsafeBytes { raw in
            func u32(_ at: Int) -> UInt32 { raw.loadUnaligned(fromByteOffset: at, as: UInt32.self) }
            func u16(_ at: Int) -> UInt16 { UInt16(raw[at]) << 8 | UInt16(raw[at + 1]) }
            var rows: [(port: UInt16, pid: pid_t, uid: uid_t, host: String)] = []
            var inpcb: Int?
            var socket: Int?
            var offset = (Int(u32(0)) + 7) & ~7
            while offset + 8 <= size {
                let length = Int(u32(offset))
                guard length > 24, offset + length <= size else { break }
                switch u32(offset + 4) {
                case 0x1 where length >= 76: socket = offset
                case 0x10 where length >= 80: inpcb = offset
                default: break
                }
                if let i = inpcb, let s = socket {
                    inpcb = nil
                    socket = nil
                    let port = u16(i + 18)
                    let listening = tcp ? u32(s + 20) & UInt32(SO_ACCEPTCONN) != 0 : u16(i + 16) == 0 && port < ephemeral
                    if port != 0, listening {
                        let v6 = raw[i + 44] & 0x2 != 0
                        let address = Array(raw[(i + (v6 ? 64 : 76))..<(i + 80)])
                        rows.append((port, pid_t(bitPattern: u32(s + 68)), u32(s + 64), host(address)))
                    }
                }
                offset += (length + 7) & ~7
            }
            return rows
        }
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

    private static func host(_ address: [UInt8]) -> String {
        var address = address
        guard address.contains(where: { $0 != 0 }) else { return "*" }
        var scope = ""
        if address.count == 16, address[0] == 0xfe, address[1] & 0xc0 == 0x80, address[2] | address[3] != 0 {
            var name = [CChar](repeating: 0, count: Int(IF_NAMESIZE))
            if if_indextoname(UInt32(address[2]) << 8 | UInt32(address[3]), &name) != nil { scope = "%" + String(cString: name) }
            address[2] = 0
            address[3] = 0
        }
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        guard inet_ntop(address.count == 16 ? AF_INET6 : AF_INET, address, &buffer, socklen_t(buffer.count)) != nil else { return "*" }
        return String(cString: buffer) + scope
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
            let bytes = address.insi_vflag & UInt8(INI_IPV6) != 0
                ? withUnsafeBytes(of: address.insi_laddr.ina_6) { Array($0) }
                : withUnsafeBytes(of: address.insi_laddr.ina_46.i46a_addr4) { Array($0) }
            result.append((port, tcp, host(bytes)))
        }
        return result
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
