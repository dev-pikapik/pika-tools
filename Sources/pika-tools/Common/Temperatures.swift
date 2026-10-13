import Foundation
import Observation

@Observable
final class Temperatures {
    static let shared = Temperatures()

    private(set) var state = ProcessInfo.processInfo.thermalState
    #if !APPSTORE
    private(set) var readings: [ThermalPart: Double] = [:]
    @ObservationIgnored private let queue = DispatchQueue(label: "temperatures", qos: .utility)
    @ObservationIgnored private var smc: SMC?
    @ObservationIgnored private var sensors: [ThermalPart: [String]]?
    #endif
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var watchers = 0

    var level: Int {
        switch state {
        case .nominal: 0
        case .fair: 1
        case .serious: 2
        default: 3
        }
    }

    var verdict: String { Self.verdict(level) }

    static func verdict(_ level: Int) -> String {
        [String(localized: "Normal temperature", defaultValue: "Normal"), String(localized: "Warm"), String(localized: "Hot"), String(localized: "Very hot")][min(max(level, 0), 3)]
    }

    var advice: String {
        switch state {
        case .nominal: String(localized: "Your Mac is running at full speed")
        case .fair: String(localized: "Your Mac is a little warm but still running at full speed")
        case .serious: String(localized: "Your Mac may slow down a little to cool off")
        default: String(localized: "Your Mac is slowing down to cool off. Closing heavy apps will help")
        }
    }

    func watch() {
        watchers += 1
        guard timer == nil else { return }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [self] _ in refresh() }
        timer?.tolerance = 0.5
    }

    func unwatch() {
        watchers = max(0, watchers - 1)
        guard watchers == 0 else { return }
        timer?.invalidate()
        timer = nil
    }

    private func refresh() {
        let current = ProcessInfo.processInfo.thermalState
        if state != current { state = current }
        #if !APPSTORE
        queue.async { [self] in
            let values = read()
            DispatchQueue.main.async { self.readings.merge(values) { $1 } }
        }
        #endif
    }

    #if !APPSTORE
    private func read() -> [ThermalPart: Double] {
        if sensors == nil {
            let smc = SMC()
            let keys = Set(smc?.keys().filter { $0.hasPrefix("T") } ?? [])
            sensors = ThermalSensors.pick(brand: ThermalSensors.brand, keys: keys)
                .mapValues { $0.filter { smc?.value($0) != nil } }
                .filter { !$0.value.isEmpty }
            self.smc = smc
        }
        guard let smc, let sensors else { return [:] }
        return sensors.compactMapValues { ThermalSensors.average(of: $0.compactMap(smc.value)) }
    }
    #endif
}

#if !APPSTORE
enum ThermalPart: CaseIterable, Identifiable {
    case processor, graphics, memory, storage, battery, wifi

    var id: Self { self }

    var title: String {
        switch self {
        case .processor: String(localized: "Processor")
        case .graphics: String(localized: "Graphics")
        case .memory: String(localized: "Memory")
        case .storage: String(localized: "Storage")
        case .battery: String(localized: "Battery")
        case .wifi: String(localized: "Wi-Fi")
        }
    }

    var symbol: String {
        switch self {
        case .processor: "cpu"
        case .graphics: "cube.transparent"
        case .memory: "memorychip"
        case .storage: "internaldrive"
        case .battery: "battery.75percent"
        case .wifi: "wifi"
        }
    }

    var limits: (warm: Double, hot: Double) {
        switch self {
        case .processor, .graphics: (80, 95)
        case .memory: (75, 90)
        case .storage: (60, 75)
        case .battery: (40, 45)
        case .wifi: (65, 85)
        }
    }

    func level(_ celsius: Double) -> Int {
        celsius >= limits.hot ? 2 : celsius >= limits.warm ? 1 : 0
    }

    func fraction(_ celsius: Double) -> Double {
        min(max((celsius - 20) / (limits.hot + 5 - 20), 0), 1)
    }
}

enum ThermalSensors {
    static let valid = 1.0...125.0

    static let table: [String: [ThermalPart: [String]]] = [
        "M1": [
            .processor: ["Tp01", "Tp05", "Tp0D", "Tp0H", "Tp0L", "Tp0P", "Tp0X", "Tp0b", "Tp09", "Tp0T"],
            .graphics: ["Tg05", "Tg0D", "Tg0L", "Tg0T"],
        ],
        "M2": [
            .processor: ["Tp01", "Tp05", "Tp09", "Tp0D", "Tp0X", "Tp0b", "Tp0f", "Tp0j", "Tp1h", "Tp1t", "Tp1p", "Tp1l"],
            .graphics: ["Tg0f", "Tg0j"],
        ],
        "M3": [
            .processor: ["Tf04", "Tf09", "Tf0A", "Tf0B", "Tf0D", "Tf0E", "Tf44", "Tf49", "Tf4A", "Tf4B", "Tf4D", "Tf4E", "Te05", "Te0L", "Te0P", "Te0S"],
            .graphics: ["Tf14", "Tf18", "Tf19", "Tf1A", "Tf24", "Tf28", "Tf29", "Tf2A"],
        ],
        "M4": [
            .processor: ["Tp01", "Tp05", "Tp09", "Tp0D", "Tp0V", "Tp0Y", "Tp0b", "Tp0e", "Te05", "Te0S", "Te09", "Te0H"],
            .graphics: ["Tg0G", "Tg0H", "Tg0K", "Tg0L", "Tg0d", "Tg0e", "Tg0j", "Tg0k", "Tg1U", "Tg1k"],
        ],
        "M5": [
            .processor: ["Tp00", "Tp04", "Tp08", "Tp0C", "Tp0G", "Tp0K", "Tp0O", "Tp0R", "Tp0U", "Tp0X", "Tp0a", "Tp0d", "Tp0g", "Tp0j", "Tp0m", "Tp0p", "Tp0u", "Tp0y"],
            .graphics: ["Tg0U", "Tg0X", "Tg0d", "Tg0g", "Tg0j", "Tg1Y", "Tg1c", "Tg1g"],
        ],
        "Intel": [
            .processor: ["TC0D", "TC0E", "TC0F", "TC0P", "TCXC", "TC1C", "TC2C", "TC3C", "TC4C", "TC5C", "TC6C", "TC7C", "TC8C"],
            .graphics: ["TG0D", "TG0P", "TGDD", "TCGC"],
        ],
    ]

    static func prefixes(apple: Bool) -> [ThermalPart: [String]] {
        apple
            ? [.processor: ["Tp", "Te"], .graphics: ["Tg"], .memory: ["Tm"], .storage: ["TH"], .battery: ["TB"], .wifi: ["TW"]]
            : [.processor: ["TC"], .graphics: ["TG"], .memory: ["TM"], .storage: ["TH"], .battery: ["TB"], .wifi: ["TW"]]
    }

    static func family(_ brand: String) -> String? {
        if brand.contains("Intel") { return "Intel" }
        let words = brand.split(separator: " ").map(String.init)
        guard words.first == "Apple", words.count > 1, table[words[1]] != nil else { return nil }
        return words[1]
    }

    static func pick(brand: String, keys: Set<String>) -> [ThermalPart: [String]] {
        let family = family(brand)
        let known = family.flatMap { table[$0] } ?? [:]
        let prefixes = prefixes(apple: family != "Intel")
        var picked: [ThermalPart: [String]] = [:]
        for part in ThermalPart.allCases {
            let listed = (known[part] ?? []).filter(keys.contains)
            let found = listed.isEmpty ? keys.filter { key in prefixes[part, default: []].contains { key.hasPrefix($0) } }.sorted() : listed
            if !found.isEmpty { picked[part] = found }
        }
        return picked
    }

    static func average(of values: [Double]) -> Double? {
        let values = values.filter(valid.contains)
        return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }

    static var brand: String {
        var size = 0
        guard sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0) == 0, size > 0 else { return "" }
        var bytes = [UInt8](repeating: 0, count: size)
        guard sysctlbyname("machdep.cpu.brand_string", &bytes, &size, nil, 0) == 0 else { return "" }
        return String(decoding: bytes.prefix { $0 != 0 }, as: UTF8.self)
    }
}
#endif
