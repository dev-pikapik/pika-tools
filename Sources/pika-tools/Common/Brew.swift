import Darwin

enum Brew {
    static func command(in ancestors: [[String]]) -> String? {
        for argv in ancestors {
            if let i = argv.firstIndex(where: { $0.hasSuffix("/brew.rb") }) {
                return argv[(i + 1)...].first { !$0.hasPrefix("-") }
            }
        }
        return nil
    }

    static func replacesApp(_ ancestors: [[String]]) -> Bool {
        ["install", "reinstall", "upgrade"].contains(command(in: ancestors) ?? "")
    }

    static func ancestors() -> [[String]] {
        var result: [[String]] = []
        var pid = getppid()
        while pid > 1 {
            result.append(arguments(of: pid))
            var info = kinfo_proc()
            var size = MemoryLayout<kinfo_proc>.stride
            var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
            guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, size > 0 else { break }
            pid = info.kp_eproc.e_ppid
        }
        return result
    }

    static func arguments(of pid: pid_t) -> [String] {
        var mib = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4 else { return [] }
        var bytes = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &bytes, &size, nil, 0) == 0, size > 4 else { return [] }
        let count = Int(bytes.withUnsafeBytes { $0.load(as: Int32.self) })
        return bytes[4..<size].split(separator: 0, omittingEmptySubsequences: false)
            .dropFirst().drop(while: \.isEmpty).prefix(count)
            .map { String(decoding: $0, as: UTF8.self) }
    }
}
