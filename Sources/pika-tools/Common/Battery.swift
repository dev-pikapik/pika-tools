import Foundation
import IOKit.ps
import IOKit.pwr_mgt
import Observation

struct BatteryState: Equatable {
    enum Phase { case charging, full, onHold, draining, onBattery }

    var charge: Int
    var phase: Phase
    var minutes: Int?
    var watts: Double?
    var cycles: Int?
    var adapter: String?
    var adapterWatts: Int?

    init?(source: [String: Any], registry: [String: Any], adapter details: [String: Any]?) {
        guard source[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
              let current = source[kIOPSCurrentCapacityKey] as? Int else { return nil }
        let maximum = source[kIOPSMaxCapacityKey] as? Int ?? 100
        charge = maximum > 0 ? min(100, Int((Double(current) * 100 / Double(maximum)).rounded())) : current
        let plugged = source[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
        let amperage = registry[kIOPMPSAmperageKey] as? Int ?? 0
        phase = !plugged ? .onBattery
            : source[kIOPSIsChargingKey] as? Bool == true ? .charging
            : amperage < -100 ? .draining
            : source[kIOPSIsChargedKey] as? Bool == true || charge >= 100 ? .full
            : .onHold
        let time = source[phase == .charging ? kIOPSTimeToFullChargeKey : kIOPSTimeToEmptyKey] as? Int ?? 0
        minutes = [.charging, .onBattery].contains(phase) && (1..<65535).contains(time) ? time : nil
        if let voltage = registry[kIOPMPSVoltageKey] as? Int, phase == .charging && amperage > 0 || phase == .onBattery && amperage < 0 {
            watts = Double(voltage) * Double(abs(amperage)) / 1_000_000
        }
        cycles = registry[kIOPMPSCycleCountKey] as? Int
        if plugged, let details {
            adapterWatts = details[kIOPSPowerAdapterWattsKey] as? Int
            adapter = (details[kIOPSNameKey] as? String)?.trimmingCharacters(in: .whitespaces)
            if adapter?.isEmpty == true { adapter = nil }
        }
    }
}

struct BatteryHealth: Equatable {
    var capacity: Int?
    var normal: Bool?

    #if APPSTORE
    init?(source: [String: Any], registry: [String: Any]) {
        if let pack = (source["BatteryPacks"] as? [[String: Any]])?.first?["BatteryHealth"] as? [String: Any] {
            let state = pack["Battery Service State"] as? Int
            if let percent = pack["Maximum Capacity Percent"] as? Int, percent >= 0, state != 8 { capacity = min(100, percent) }
            normal = state.map { $0 == 0 }
        } else {
            if let full = registry["NominalChargeCapacity"] as? Int ?? registry["AppleRawMaxCapacity"] as? Int,
               let design = registry[kIOPMPSDesignCapacityKey] as? Int, full > 0, design > 0 {
                capacity = min(100, Int((Double(full) * 100 / Double(design)).rounded(.up)))
            }
            switch source[kIOPSBatteryHealthKey] as? String {
            case "Good": normal = true
            case "Fair", "Poor": normal = false
            default: normal = nil
            }
            if source[kIOPSBatteryHealthConditionKey] != nil || registry["PermanentFailureStatus"] as? Int ?? 0 != 0 { normal = false }
        }
        if capacity == nil && normal == nil { return nil }
    }
    #else
    init?(profile data: Data) {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let items = root["SPPowerDataType"] as? [[String: Any]],
              let info = items.lazy.compactMap({ $0["sppower_battery_health_info"] as? [String: Any] }).first else { return nil }
        let digits = (info["sppower_battery_health_maximum_capacity"] as? String)?.compactMap(\.wholeNumberValue) ?? []
        capacity = digits.isEmpty ? nil : digits.reduce(0) { $0 * 10 + $1 }
        switch info["sppower_battery_health"] as? String {
        case "Good": normal = true
        case "Fair", "Poor", "Check Battery": normal = false
        default: normal = nil
        }
        if capacity == nil && normal == nil { return nil }
    }
    #endif
}

@Observable
final class Battery {
    static let shared = Battery()
    static let isPresent = read() != nil
    static let ratedCycles = 1000

    private(set) var state: BatteryState?
    private(set) var health: BatteryHealth?
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var watchers = 0

    func watch() {
        watchers += 1
        guard timer == nil else { return }
        refresh()
        checkHealth()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in refresh() }
    }

    func unwatch() {
        watchers = max(0, watchers - 1)
        guard watchers == 0 else { return }
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        let next = Self.read()
        if next != state { state = next }
    }

    private func checkHealth() {
        #if APPSTORE
        guard let source = Self.source(),
              let health = BatteryHealth(source: source, registry: Self.registry([kIOPMPSDesignCapacityKey, "NominalChargeCapacity", "AppleRawMaxCapacity", "PermanentFailureStatus"])) else { return }
        if health != self.health { self.health = health }
        #else
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
            process.arguments = ["SPPowerDataType", "-json"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            guard (try? process.run()) != nil else { return }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard let health = BatteryHealth(profile: data) else { return }
            DispatchQueue.main.async { if health != self.health { self.health = health } }
        }
        #endif
    }

    static func read() -> BatteryState? {
        source().flatMap { BatteryState(source: $0, registry: registry(), adapter: IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any]) }
    }

    static func temperature() -> Double? {
        celsius(root: registry([kIOPMPSBatteryTemperatureKey]), pack: registry(["BatteryData"], of: "AppleSmartBatteryPack"))
    }

    static func celsius(root: [String: Any], pack: [String: Any]) -> Double? {
        let hundredths = root[kIOPMPSBatteryTemperatureKey] as? Int ?? (pack["BatteryData"] as? [String: Any])?[kIOPMPSBatteryTemperatureKey] as? Int
        return hundredths.map { Double($0) / 100 }.flatMap { (1.0...125.0).contains($0) ? $0 : nil }
    }

    private static func source() -> [String: Any]? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else { return nil }
        for item in list {
            guard let source = IOPSGetPowerSourceDescription(info, item)?.takeUnretainedValue() as? [String: Any],
                  source[kIOPSTypeKey] as? String == kIOPSInternalBatteryType else { continue }
            return source
        }
        return nil
    }

    private static func registry(_ keys: [String] = [kIOPMPSCycleCountKey, kIOPMPSVoltageKey, kIOPMPSAmperageKey], of name: String = "AppleSmartBattery") -> [String: Any] {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(name))
        guard service != 0 else { return [:] }
        defer { IOObjectRelease(service) }
        var values: [String: Any] = [:]
        for key in keys {
            values[key] = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
        }
        return values
    }
}
