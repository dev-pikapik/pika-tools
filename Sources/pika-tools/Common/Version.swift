enum Version {
    static func parts(_ version: String) -> [Int] {
        version.drop { $0 == "v" || $0 == "V" || $0 == " " }.split(separator: ".").map { Int($0.prefix { $0.isNumber }) ?? 0 }
    }

    static func isNewer(_ remote: String, than current: String) -> Bool {
        var a = parts(remote), b = parts(current)
        let count = max(a.count, b.count)
        a += Array(repeating: 0, count: count - a.count)
        b += Array(repeating: 0, count: count - b.count)
        return b.lexicographicallyPrecedes(a)
    }
}
