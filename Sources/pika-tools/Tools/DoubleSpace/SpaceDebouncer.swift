struct SpaceDebouncer {
    var windowNs: UInt64
    private var lastDownNs: UInt64 = 0

    init(windowNs: UInt64) {
        self.windowNs = windowNs
    }

    mutating func shouldPass(nowNs: UInt64) -> Bool {
        defer { lastDownNs = nowNs }
        guard lastDownNs != 0 else { return true }
        return nowNs &- lastDownNs >= windowNs
    }
}
