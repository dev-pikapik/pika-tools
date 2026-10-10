import AppKit

struct KeyboardListener: Identifiable {
    let id: pid_t
    let name: String
    let changesKeys: Bool

    static func load() -> [KeyboardListener] {
        var count: UInt32 = 0
        guard CGGetEventTapList(0, nil, &count) == .success, count > 0 else { return [] }
        var taps = [CGEventTapInformation](repeating: .init(), count: Int(count))
        guard CGGetEventTapList(count, &taps, &count) == .success else { return [] }
        let keyboard = [CGEventType.keyDown, .keyUp, .flagsChanged].reduce(CGEventMask(0)) { $0 | 1 << $1.rawValue }
        let active = taps.prefix(min(Int(count), taps.count)).filter { $0.enabled && $0.tappingProcess != getpid() && $0.eventsOfInterest & keyboard != 0 }
        return Dictionary(grouping: active, by: \.tappingProcess).map { pid, taps in
            let name = NSRunningApplication(processIdentifier: pid)?.localizedName ?? String(localized: "Process \(String(pid))")
            return KeyboardListener(id: pid, name: name, changesKeys: taps.contains { $0.options != .listenOnly })
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
