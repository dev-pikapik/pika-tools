import Foundation

@main
enum TestBattery {
    static let battery: [String: Any] = ["Type": "InternalBattery", "Current Capacity": 85, "Max Capacity": 100, "Power Source State": "AC Power",
                                         "Is Charging": false, "Is Charged": false, "Time to Empty": 0, "Time to Full Charge": 0]

    static func state(_ changes: [String: Any], registry: [String: Any] = ["CycleCount": 68, "Voltage": 12590, "Amperage": 0],
                      adapter: [String: Any]? = ["Name": "70W USB-C Power Adapter ", "Watts": 68]) -> BatteryState {
        BatteryState(source: battery.merging(changes) { $1 }, registry: registry, adapter: adapter)!
    }

    static func main() {
        let hold = state([:])
        precondition(hold.phase == .onHold && hold.charge == 85 && hold.minutes == nil && hold.watts == nil)
        precondition(hold.cycles == 68 && hold.adapter == "70W USB-C Power Adapter" && hold.adapterWatts == 68)

        let charging = state(["Is Charging": true, "Time to Full Charge": 45], registry: ["Voltage": 12500, "Amperage": 3000])
        precondition(charging.phase == .charging && charging.minutes == 45 && charging.watts == 37.5)

        let estimating = state(["Is Charging": true, "Time to Full Charge": -1])
        precondition(estimating.phase == .charging && estimating.minutes == nil && estimating.watts == nil)

        let draining = state(["Time to Empty": 120], registry: ["Voltage": 12500, "Amperage": -800])
        precondition(draining.phase == .draining && draining.watts == nil && draining.minutes == nil)
        precondition(state(["Is Charged": true], registry: ["Voltage": 12500, "Amperage": -800]).phase == .draining)
        precondition(state([:], registry: ["Voltage": 12500, "Amperage": -20]).phase == .onHold)
        precondition(state(["Is Charged": true]).phase == .full)
        precondition(state(["Current Capacity": 100]).phase == .full)
        precondition(state(["Current Capacity": 2400, "Max Capacity": 4800]).charge == 50)

        let unplugged = state(["Power Source State": "Battery Power", "Time to Empty": 190], registry: ["Voltage": 12000, "Amperage": -600], adapter: nil)
        precondition(unplugged.phase == .onBattery && unplugged.minutes == 190 && unplugged.watts == 7.2 && unplugged.adapter == nil)
        precondition(state(["Power Source State": "Battery Power", "Time to Empty": 65535], adapter: nil).minutes == nil)

        precondition(BatteryState(source: ["Type": "UPS", "Current Capacity": 50], registry: [:], adapter: nil) == nil)

        #if APPSTORE
        func health(_ pack: [String: Any]? = nil, _ top: [String: Any] = [:], _ registry: [String: Any] = [:], data: [String: Any] = [:]) -> BatteryHealth? {
            var source = top
            if let pack { source["BatteryPacks"] = [["BatteryHealth": pack]] }
            return BatteryHealth(source: source, registry: registry, pack: ["BatteryData": data])
        }
        let good = health(["Maximum Capacity Percent": 87, "Battery Service State": 0])
        precondition(good?.capacity == 87 && good?.normal == true)
        let service = health(["Maximum Capacity Percent": 104, "Battery Service State": 1])
        precondition(service?.capacity == 100 && service?.normal == false)
        let hidden = health(["Maximum Capacity Percent": 90, "Battery Service State": 8], [:], ["NominalChargeCapacity": 4093, "DesignCapacity": 4382])
        precondition(hidden?.capacity == nil && hidden?.normal == false)
        let noState = health(["Maximum Capacity Percent": 87])
        precondition(noState?.capacity == 87 && noState?.normal == nil)
        let nominal = health(nil, [:], ["NominalChargeCapacity": 4093, "AppleRawMaxCapacity": 4046, "DesignCapacity": 4382, "PermanentFailureStatus": 0])
        precondition(nominal?.capacity == 94 && nominal?.normal == nil)
        precondition(health(nil, [:], ["AppleRawMaxCapacity": 4046, "DesignCapacity": 4382])?.capacity == 93)
        let failed = health(nil, [:], ["NominalChargeCapacity": 5000, "DesignCapacity": 4382, "PermanentFailureStatus": 1])
        precondition(failed?.capacity == 100 && failed?.normal == false)
        precondition(health(nil, ["BatteryHealth": "Good"])?.normal == true)
        precondition(health(nil, ["BatteryHealth": "Poor"])?.normal == false)
        precondition(health(nil, ["BatteryHealth": "Good", "BatteryHealthCondition": "Check Battery"])?.normal == false)
        precondition(health(nil, ["BatteryHealth": "Unknown"]) == nil)
        precondition(health(nil, [:], ["NominalChargeCapacity": 0, "DesignCapacity": 4382]) == nil)
        precondition(health() == nil)
        let macOS27: [String: Any] = ["NominalChargeCapacity": 6131, "AppleRawMaxCapacity": 5979, "DesignCapacity": 6249, "PermanentFailureStatus": 0]
        let packOnly = health(nil, [:], [:], data: macOS27)
        precondition(packOnly?.capacity == 99 && packOnly?.normal == nil)
        precondition(health(nil, [:], ["NominalChargeCapacity": 4093, "DesignCapacity": 4382], data: macOS27)?.capacity == 94)
        precondition(health(nil, [:], [:], data: ["NominalChargeCapacity": 6131, "DesignCapacity": 6249, "PermanentFailureStatus": 1])?.normal == false)
        precondition(health(["Maximum Capacity Percent": 87, "Battery Service State": 0], [:], [:], data: macOS27)?.capacity == 87)
        #else
        func health(_ condition: String, _ capacity: String = "100%") -> BatteryHealth? {
            let json = #"{"SPPowerDataType":[{"_name":"spbattery_information","sppower_battery_health_info":{"sppower_battery_cycle_count":68,"# +
                #""sppower_battery_health":"\#(condition)","sppower_battery_health_maximum_capacity":"\#(capacity)"}}]}"#
            return BatteryHealth(profile: Data(json.utf8))
        }
        precondition(health("Good")?.capacity == 100 && health("Good")?.normal == true)
        precondition(health("Fair", "79%")?.capacity == 79 && health("Fair")?.normal == false)
        precondition(health("Check Battery")?.normal == false)
        precondition(health("Something New", "٨٧٪")?.capacity == 87 && health("Something New")?.normal == nil)
        precondition(health("", "") == nil)
        precondition(BatteryHealth(profile: Data(#"{"SPPowerDataType":[]}"#.utf8)) == nil)
        #endif

        let pack: [String: Any] = ["BatteryData": ["Temperature": 3289, "VirtualTemperature": 3289]]
        precondition(Battery.celsius(root: [:], pack: pack) == 32.89)
        precondition(Battery.celsius(root: ["Temperature": 3050], pack: [:]) == 30.5)
        precondition(Battery.celsius(root: ["Temperature": 3050], pack: pack) == 30.5)
        precondition(Battery.celsius(root: ["Temperature": 0], pack: [:]) == nil)
        precondition(Battery.celsius(root: ["Temperature": 65535], pack: [:]) == nil)
        precondition(Battery.celsius(root: [:], pack: ["BatteryData": ["Voltage": 12466]]) == nil)
        precondition(Battery.celsius(root: [:], pack: [:]) == nil)

        print("battery checks passed")
    }
}
