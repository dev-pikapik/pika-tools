import Foundation

@main
enum TestTemps {
    static func main() {
        precondition(SMCCodec.decode(type: "sp78", bytes: [0x2D, 0x80]) == 45.5)
        precondition(SMCCodec.decode(type: "sp78", bytes: [0xFF, 0x00]) == -1)
        precondition(SMCCodec.decode(type: "sp78", bytes: [0x2D]) == nil)
        precondition(SMCCodec.decode(type: "ui32", bytes: [0, 0, 1, 2]) == 258)
        precondition(SMCCodec.decode(type: "ui32", bytes: [1, 2]) == nil)

        precondition(ThermalSensors.family("Apple M4 Pro") == "M4")
        precondition(ThermalSensors.family("Apple M3") == "M3")
        precondition(ThermalSensors.family("Apple M9 Ultra") == nil)
        precondition(ThermalSensors.family("Intel(R) Core(TM) i7-8700B CPU @ 3.20GHz") == "Intel")
        precondition(ThermalSensors.family("") == nil)

        let mini: Set = ["Tp01", "Tp05", "Te05", "Tg0G", "Tg0H", "Tm0p", "Tm1p", "TH0a", "TW0P", "Ta0P", "TCMb", "Tz1j", "TPD0", "TVD0"]
        let m4 = ThermalSensors.pick(brand: "Apple M4", keys: mini)
        precondition(m4[.processor] == ["Tp01", "Tp05", "Te05"], "\(m4)")
        precondition(m4[.graphics] == ["Tg0G", "Tg0H"])
        precondition(m4[.memory] == ["Tm0p", "Tm1p"])
        precondition(m4[.storage] == ["TH0a"])
        precondition(m4[.wifi] == ["TW0P"])
        precondition(m4[.battery] == nil)
        precondition(m4.values.joined().allSatisfy(mini.contains))

        let m3 = ThermalSensors.pick(brand: "Apple M3 Max", keys: ["Tf04", "Tf14", "Tp01", "Tg0f", "TB0T", "TB1T"])
        precondition(m3[.processor] == ["Tf04"] && m3[.graphics] == ["Tf14"], "\(m3)")
        precondition(m3[.battery] == ["TB0T", "TB1T"])

        let unknown = ThermalSensors.pick(brand: "Apple M9", keys: ["Tp0A", "Te0B", "Tg0C", "Tf04", "Ta0P"])
        precondition(unknown[.processor] == ["Te0B", "Tp0A"] && unknown[.graphics] == ["Tg0C"], "\(unknown)")
        precondition(unknown.count == 2)

        let intel = ThermalSensors.pick(brand: "Intel(R) Core(TM) i5", keys: ["TC1C", "TC0P", "TCMb", "TG0P", "TM0P", "Tp01", "TB0T"])
        precondition(intel[.processor] == ["TC0P", "TC1C"] && intel[.graphics] == ["TG0P"], "\(intel)")
        precondition(intel[.memory] == ["TM0P"] && intel[.battery] == ["TB0T"])

        precondition(ThermalSensors.pick(brand: "", keys: []).isEmpty)

        precondition(ThermalSensors.average(of: [0, 45, 55, 130]) == 50)
        precondition(ThermalSensors.average(of: [0, -3, 200]) == nil)
        precondition(ThermalSensors.average(of: []) == nil)

        precondition(ThermalPart.processor.level(79.9) == 0 && ThermalPart.processor.level(80) == 1 && ThermalPart.processor.level(95) == 2)
        precondition(ThermalPart.battery.level(41) == 1 && ThermalPart.storage.level(45) == 0)
        precondition(ThermalPart.processor.fraction(10) == 0 && ThermalPart.processor.fraction(120) == 1)
        precondition(ThermalPart.allCases.allSatisfy { $0.limits.warm < $0.limits.hot })

        precondition(Temperatures.verdict(-1) == Temperatures.verdict(0) && Temperatures.verdict(9) == Temperatures.verdict(3))

        print("temperature sensors, families and levels: ok")
    }
}
