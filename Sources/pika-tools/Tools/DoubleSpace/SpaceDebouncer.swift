/// Чистая логика анти-даблспейса: решает, пропускать ли нажатие пробела.
///
/// Первое нажатие всегда проходит, повторное быстрее окна — нет.
/// Отсчёт идёт от последнего нажатия (а не от последнего пропущенного),
/// поэтому очередь быстрых нажатий схлопывается в одно.
struct SpaceDebouncer {
    /// Окно в наносекундах: повтор быстрее окна глотается.
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

    mutating func reset() { lastDownNs = 0 }
}
