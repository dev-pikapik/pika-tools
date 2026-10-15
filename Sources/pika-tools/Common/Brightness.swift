import AppKit
#if !APPSTORE
import IOKit
#endif

@MainActor @Observable final class Brightness {
    static let shared = Brightness()

    struct Monitor: Identifiable {
        let id: CGDirectDisplayID
        let key: String
        let name: String
        var level: Double
        var hasControl: Bool
        var dimsPicture: Bool
        var reports: Bool

        var usesPicture: Bool { !hasControl || dimsPicture }
    }

    private struct Gamma {
        let base: [[CGGammaValue]]
        var written: [[CGGammaValue]]?
    }

    private(set) var monitors: [Monitor] = []
    @ObservationIgnored private var gamma: [CGDirectDisplayID: Gamma] = [:]
    @ObservationIgnored private var generation = 0
    #if !APPSTORE
    @ObservationIgnored private let link = MonitorLink()
    @ObservationIgnored private var controlled: Set<CGDirectDisplayID> = []
    @ObservationIgnored private var silent: Set<String> = []
    @ObservationIgnored private var misses: [String: Int] = [:]
    @ObservationIgnored private var touched: [CGDirectDisplayID: Date] = [:]
    @ObservationIgnored private var wrote: [String: Date] = [:]
    @ObservationIgnored private var polled = Date.distantPast
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var watchers = 0
    #endif

    private init() {}

    func start() {
        let workspace = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            workspace.addObserver(forName: name, object: nil, queue: .main) { _ in
                MainActor.assumeIsolated { Brightness.shared.refresh() }
            }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated { Brightness.shared.refresh() }
        }
        refresh()
    }

    func release() {
        generation += 1
        guard !gamma.isEmpty else { return }
        CGDisplayRestoreColorSyncSettings()
        gamma = [:]
    }

    func monitor(for id: CGDirectDisplayID) -> Monitor? {
        monitors.first { $0.id == id }
    }

    func set(_ level: Double, for id: CGDirectDisplayID) {
        guard MainCopy.canAct, let i = monitors.firstIndex(where: { $0.id == id }) else { return }
        monitors[i].level = min(max(level, 0), 1)
        UserDefaults.standard.set(monitors[i].level, forKey: Self.levelKey(monitors[i].key))
        #if !APPSTORE
        touched[id] = Date()
        #endif
        apply(monitors[i])
    }

    func step(_ id: CGDirectDisplayID, up: Bool, fine: Bool) -> Double? {
        guard MainCopy.canAct, let monitor = monitor(for: id) else { return nil }
        set(BrightnessMath.step(monitor.level, up: up, fine: fine), for: id)
        return self.monitor(for: id)?.level
    }

    func setDimsPicture(_ on: Bool, for id: CGDirectDisplayID) {
        guard MainCopy.canAct, let i = monitors.firstIndex(where: { $0.id == id }) else { return }
        monitors[i].dimsPicture = on
        UserDefaults.standard.set(on, forKey: Self.pictureKey(monitors[i].key))
        let monitor = monitors[i]
        if on {
            if monitor.level < 1 { dim(monitor) }
        } else {
            if gamma[id] != nil { repaint(force: true) }
            if UserDefaults.standard.object(forKey: Self.levelKey(monitor.key)) != nil { apply(monitor) }
        }
    }

    func watch() {
        #if !APPSTORE
        watchers += 1
        guard timer == nil else { return }
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            MainActor.assumeIsolated { Brightness.shared.poll() }
        }
        timer?.tolerance = 1
        #endif
    }

    func unwatch() {
        #if !APPSTORE
        watchers = max(0, watchers - 1)
        guard watchers == 0 else { return }
        timer?.invalidate()
        timer = nil
        #endif
    }

    private static func levelKey(_ key: String) -> String { "brightness-level-\(key)" }
    private static func pictureKey(_ key: String) -> String { "brightness-picture-\(key)" }

    func refresh() {
        generation += 1
        let current = generation
        #if !APPSTORE
        silent = []
        misses = [:]
        #endif
        connect(current, rewrite: false)
        for delay in [2.0, 6.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { self.connect(current, rewrite: true) }
        }
    }

    private func connect(_ current: Int, rewrite: Bool) {
        guard current == generation, MainCopy.canAct else { return }
        scan()
        #if APPSTORE
        repaint(force: false)
        #else
        link.scan(monitors.map(\.id)) { ids in
            guard current == self.generation else { return }
            if let ids { self.controlled = Set(ids) }
            self.scan()
            self.repaint(force: false)
            if rewrite { self.resend() }
        }
        #endif
    }

    private func scan() {
        let old = monitors
        monitors = NSScreen.screens.compactMap { screen in
            let id = screen.displayID
            guard CGDisplayIsBuiltin(id) == 0, !Self.adjustsItself(id) else { return nil }
            let key = "\(CGDisplayVendorNumber(id))-\(CGDisplayModelNumber(id))-\(CGDisplaySerialNumber(id))"
            let saved = UserDefaults.standard.object(forKey: Self.levelKey(key)) as? Double
            let picture = UserDefaults.standard.bool(forKey: Self.pictureKey(key))
            #if APPSTORE
            let control = false, reports = true
            #else
            let control = controlled.contains(id), reports = !silent.contains(key)
            #endif
            return Monitor(id: id, key: key, name: screen.localizedName, level: saved ?? old.first { $0.id == id }?.level ?? 1, hasControl: control, dimsPicture: picture, reports: reports)
        }
        #if !APPSTORE
        for key in BrightnessMath.restarted(old.map(\.key), monitors.map(\.key), wrote: wrote) {
            UserDefaults.standard.set(true, forKey: Self.pictureKey(key))
        }
        #endif
    }

    #if APPSTORE
    private static func adjustsItself(_ id: CGDirectDisplayID) -> Bool {
        CGDisplayVendorNumber(id) == 0x610
    }
    #else
    private static let canChangeBrightness: (@convention(c) (CGDirectDisplayID) -> Bool)? = {
        guard let library = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY),
              let symbol = dlsym(library, "DisplayServicesCanChangeBrightness") else { return nil }
        return unsafeBitCast(symbol, to: (@convention(c) (CGDirectDisplayID) -> Bool).self)
    }()

    private static func adjustsItself(_ id: CGDirectDisplayID) -> Bool {
        canChangeBrightness?(id) ?? (CGDisplayVendorNumber(id) == 0x610)
    }
    #endif

    private func apply(_ monitor: Monitor) {
        if monitor.usesPicture {
            if monitor.level < 1 {
                dim(monitor)
            } else if gamma[monitor.id] != nil {
                repaint(force: true)
            }
        } else {
            #if !APPSTORE
            wrote[monitor.key] = Date()
            link.write(monitor.level, to: monitor.id)
            #endif
        }
    }

    private func resend() {
        #if !APPSTORE
        for monitor in monitors where !monitor.usesPicture && UserDefaults.standard.object(forKey: Self.levelKey(monitor.key)) != nil {
            wrote[monitor.key] = Date()
            link.write(monitor.level, to: monitor.id)
        }
        #endif
    }

    private static func table(_ id: CGDirectDisplayID) -> [[CGGammaValue]]? {
        let capacity = CGDisplayGammaTableCapacity(id)
        guard capacity > 0 else { return nil }
        var red = [CGGammaValue](repeating: 0, count: Int(capacity)), green = red, blue = red
        var count: UInt32 = 0
        guard CGGetDisplayTransferByTable(id, capacity, &red, &green, &blue, &count) == .success, count > 0 else { return nil }
        let table = [red, green, blue].map { Array($0.prefix(Int(count))) }
        return table.joined().contains { $0 > 0 } ? table : nil
    }

    private func dim(_ monitor: Monitor) {
        guard let base = gamma[monitor.id]?.base ?? Self.table(monitor.id) else { return }
        let scale = CGGammaValue(BrightnessMath.pictureScale(monitor.level))
        let table = base.map { $0.map { $0 * scale } }
        guard CGSetDisplayTransferByTable(monitor.id, UInt32(table[0].count), table[0], table[1], table[2]) == .success else { return }
        gamma[monitor.id] = Gamma(base: base, written: Self.table(monitor.id))
    }

    private func repaint(force: Bool) {
        let dimmed = monitors.filter { $0.usesPicture && $0.level < 1 }
        if !force, Set(gamma.keys) == Set(dimmed.map(\.id)), dimmed.allSatisfy({ gamma[$0.id]?.written == Self.table($0.id) }) { return }
        if !gamma.isEmpty {
            CGDisplayRestoreColorSyncSettings()
            gamma = [:]
        }
        dimmed.forEach(dim)
    }

    #if !APPSTORE
    private func poll() {
        guard Date().timeIntervalSince(polled) >= 4.5 else { return }
        polled = Date()
        for monitor in monitors where !monitor.usesPicture && monitor.reports {
            link.read(monitor.id) { [id = monitor.id] reply in self.received(reply, for: id) }
        }
    }

    private func received(_ reply: BrightnessMath.Reply?, for id: CGDirectDisplayID) {
        guard let i = monitors.firstIndex(where: { $0.id == id }) else { return }
        switch reply {
        case .unsupported:
            silent.insert(monitors[i].key)
            monitors[i].reports = false
        case .value(let current, let maximum):
            misses[monitors[i].key] = 0
            let level = Double(current) / Double(maximum)
            guard Date().timeIntervalSince(touched[id] ?? .distantPast) > 2, abs(level - monitors[i].level) > 0.005 else { return }
            monitors[i].level = level
            let key = Self.levelKey(monitors[i].key)
            if UserDefaults.standard.object(forKey: key) != nil { UserDefaults.standard.set(level, forKey: key) }
        case nil:
            let key = monitors[i].key
            misses[key, default: 0] += 1
            guard misses[key, default: 0] >= 3 else { return }
            silent.insert(key)
            monitors[i].reports = false
        }
    }
    #endif
}

#if !APPSTORE
private final class MonitorLink: @unchecked Sendable {
    private typealias Create = @convention(c) (CFAllocator?, io_service_t) -> Unmanaged<CFTypeRef>?
    private typealias CopyEDID = @convention(c) (CFTypeRef, UnsafeMutablePointer<Unmanaged<CFData>?>) -> IOReturn
    private typealias I2C = @convention(c) (CFTypeRef, UInt32, UInt32, UnsafeMutableRawPointer, UInt32) -> IOReturn

    private let create: Create?
    private let copyEDID: CopyEDID?
    private let writeI2C: I2C?
    private let readI2C: I2C?
    private let queue = DispatchQueue(label: "brightness", qos: .userInitiated)
    private let lock = NSLock()
    private var pending: [CGDirectDisplayID: Double] = [:]
    private var draining = false
    private var services: [CGDirectDisplayID: CFTypeRef] = [:]
    private var maximum: [CGDirectDisplayID: Int] = [:]
    private var sent: [CGDirectDisplayID: Double] = [:]
    private var quiet = 0

    init() {
        let kit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY)
        create = dlsym(kit, "IOAVServiceCreateWithService").map { unsafeBitCast($0, to: Create.self) }
        copyEDID = dlsym(kit, "IOAVServiceCopyEDID").map { unsafeBitCast($0, to: CopyEDID.self) }
        writeI2C = dlsym(kit, "IOAVServiceWriteI2C").map { unsafeBitCast($0, to: I2C.self) }
        readI2C = dlsym(kit, "IOAVServiceReadI2C").map { unsafeBitCast($0, to: I2C.self) }
    }

    func scan(_ displays: [CGDirectDisplayID], done: @escaping @MainActor ([CGDirectDisplayID]?) -> Void) {
        queue.async {
            let found = self.find(displays)
            if let found { self.services = found }
            let ids = found.map { Array($0.keys) }
            DispatchQueue.main.async { done(ids) }
        }
    }

    func write(_ level: Double, to id: CGDirectDisplayID) {
        lock.lock()
        pending[id] = level
        let idle = !draining
        draining = true
        lock.unlock()
        if idle { queue.async { self.drain() } }
    }

    func read(_ id: CGDirectDisplayID, done: @escaping @MainActor (BrightnessMath.Reply?) -> Void) {
        queue.async {
            let reply = self.ask(id)
            if case .value(_, let top) = reply { self.maximum[id] = top }
            DispatchQueue.main.async { done(reply) }
        }
    }

    private func find(_ displays: [CGDirectDisplayID]) -> [CGDirectDisplayID: CFTypeRef]? {
        guard let create, let copyEDID else { return [:] }
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("DCPAVServiceProxy"), &iterator) == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }
        var found: [(service: CFTypeRef, identity: [UInt32])] = []
        while case let entry = IOIteratorNext(iterator), entry != 0 {
            defer { IOObjectRelease(entry) }
            guard IORegistryEntryCreateCFProperty(entry, "Location" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? String == "External",
                  let service = create(kCFAllocatorDefault, entry)?.takeRetainedValue() else { continue }
            var edid: Unmanaged<CFData>?
            let result = copyEDID(service, &edid)
            guard let data = edid?.takeRetainedValue() as Data?, result == kIOReturnSuccess,
                  let identity = BrightnessMath.identity(edid: [UInt8](data)) else { continue }
            found.append((service, [identity.vendor, identity.model, identity.serial]))
        }
        guard !found.isEmpty else { return nil }
        let identity = { (id: CGDirectDisplayID) in [CGDisplayVendorNumber(id), CGDisplayModelNumber(id), CGDisplaySerialNumber(id)] }
        var services: [CGDirectDisplayID: CFTypeRef] = [:]
        for id in displays where displays.filter({ identity($0) == identity(id) }).count == 1 {
            let matches = found.filter { $0.identity == identity(id) }
            if matches.count == 1 { services[id] = matches[0].service }
        }
        return services
    }

    private func drain() {
        while true {
            lock.lock()
            guard let next = pending.first else {
                draining = false
                lock.unlock()
                break
            }
            pending[next.key] = nil
            lock.unlock()
            send(next.value, to: next.key)
            sent[next.key] = next.value
            usleep(50_000)
        }
        quiet += 1
        let mark = quiet
        queue.asyncAfter(deadline: .now() + 0.3) {
            guard mark == self.quiet else { return }
            for (id, level) in self.sent { self.send(level, to: id) }
            self.sent = [:]
        }
    }

    private func send(_ level: Double, to id: CGDirectDisplayID) {
        guard let service = services[id], let writeI2C else { return }
        var packet = BrightnessMath.writeBrightness(Int((level * Double(maximum[id] ?? 100)).rounded()))
        _ = packet.withUnsafeMutableBytes { writeI2C(service, 0x37, 0x51, $0.baseAddress!, UInt32($0.count)) }
    }

    private func ask(_ id: CGDirectDisplayID) -> BrightnessMath.Reply? {
        guard let service = services[id], let writeI2C, let readI2C else { return nil }
        var request = BrightnessMath.readBrightness
        guard request.withUnsafeMutableBytes({ writeI2C(service, 0x37, 0x51, $0.baseAddress!, UInt32($0.count)) }) == kIOReturnSuccess else { return nil }
        usleep(80_000)
        var reply = [UInt8](repeating: 0, count: 13)
        guard reply.withUnsafeMutableBytes({ readI2C(service, 0x37, 0x51, $0.baseAddress!, UInt32($0.count)) }) == kIOReturnSuccess else { return nil }
        return BrightnessMath.reply(reply)
    }
}
#endif

extension NSScreen {
    var displayID: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }
}
