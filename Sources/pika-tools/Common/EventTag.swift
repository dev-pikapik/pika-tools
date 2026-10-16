import CoreGraphics

/// Marks the events pikapik sends or has already changed. Every pikapik tap lets them through,
/// so when the App Store and website copies run together, neither handles the other's keys again.
extension CGEvent {
    private static let pikapikTag: Int64 = 0x70696B61

    var isPikapik: Bool { getIntegerValueField(.eventSourceUserData) == Self.pikapikTag }

    func markPikapik() { setIntegerValueField(.eventSourceUserData, value: Self.pikapikTag) }

    static var pikapikHeld: () -> CGEventFlags = { CGEventSource.flagsState(.hidSystemState) }

    static func pikapikKey(_ key: Int, down: Bool, flags: CGEventFlags = []) -> CGEvent? {
        guard let event = CGEvent(keyboardEventSource: CGEventSource(stateID: .privateState), virtualKey: CGKeyCode(key), keyDown: down) else { return nil }
        event.flags = down ? flags : pikapikHeld()
        return event
    }

    static var pikapikSend: (CGEvent, CGEventTapProxy?, CGEventTapLocation) -> Void = { event, proxy, tap in
        if let proxy { event.tapPostEvent(proxy) } else { event.post(tap: tap) }
    }

    func postPikapik(_ proxy: CGEventTapProxy? = nil, tap: CGEventTapLocation = .cgSessionEventTap) {
        markPikapik()
        Self.pikapikSend(self, proxy, tap)
    }

    static func postPikapikKey(_ key: Int, down: Bool, flags: CGEventFlags = [], _ proxy: CGEventTapProxy? = nil) {
        pikapikKey(key, down: down, flags: flags)?.postPikapik(proxy)
    }

    static func tapPikapikKey(_ key: Int, flags: CGEventFlags) {
        for down in [true, false] { postPikapikKey(key, down: down, flags: flags) }
    }
}
