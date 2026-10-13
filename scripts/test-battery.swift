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

        print("battery checks passed")
    }
}
