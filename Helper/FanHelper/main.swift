import Foundation

guard let device = SMC() else { exit(1) }

if CommandLine.arguments.contains("--read") {
    let lower = device.read("F0md") != nil
    print("FNum \(device.count)  mode key F0\(lower ? "md" : "Md")  Ftst \(device.hasUnlock ? "yes" : "no")")
    for fan in device.fans() {
        let target = device.read("F\(fan.id)Tg")
        print("F\(fan.id)  Ac \(fan.current)  Mn \(fan.minimum)  Mx \(fan.maximum)  manual \(fan.manual)  Tg type \(target?.type ?? "-")")
    }
    exit(0)
}

final class Service: NSObject, FanHelperProtocol, NSXPCListenerDelegate {
    private let lock = NSLock()
    private let updates = NSLock()
    private let smc: SMC
    private let requirement: String?
    private let candidate: String?
    private let own: String
    private var clients = 0

    init(smc: SMC, requirement: String?, candidate: String?, own: String) {
        self.smc = smc
        self.requirement = requirement
        self.candidate = candidate
        self.own = own
    }

    func resetAll() {
        lock.lock()
        defer { lock.unlock() }
        (0..<smc.count).forEach { smc.setAuto(fan: $0) }
    }

    func guardHeat() {
        lock.lock()
        defer { lock.unlock() }
        guard ProcessInfo.processInfo.thermalState.rawValue >= ProcessInfo.ThermalState.serious.rawValue,
              smc.fans().contains(where: \.manual)
        else { return }
        (0..<smc.count).forEach { smc.setAuto(fan: $0) }
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        guard let requirement else { return false }
        connection.setCodeSigningRequirement(requirement)
        connection.exportedInterface = NSXPCInterface(with: FanHelperProtocol.self)
        connection.exportedObject = self
        lock.lock()
        clients += 1
        lock.unlock()
        var gone = false
        let leave = { [self] in
            lock.lock()
            var last = false
            if !gone {
                gone = true
                clients -= 1
                last = clients == 0
            }
            lock.unlock()
            if last { finish() }
        }
        connection.invalidationHandler = leave
        connection.interruptionHandler = leave
        connection.resume()
        return true
    }

    func version(reply: @escaping (Int) -> Void) {
        reply(FanHelperInfo.version)
    }

    func setManual(fan: Int, rpm: Double, reply: @escaping (Bool) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        let cool = ProcessInfo.processInfo.thermalState.rawValue < ProcessInfo.ThermalState.serious.rawValue
        reply(cool && rpm.isFinite && smc.setManual(fan: fan, rpm: rpm))
    }

    func setAuto(fan: Int, reply: @escaping (Bool) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        smc.setAuto(fan: fan)
        reply(true)
    }

    func update(from path: String, reply: @escaping (Bool) -> Void) {
        updates.lock()
        defer { updates.unlock() }
        reply(candidate.map { FanHelperInfo.stage(CommandLine.arguments[0], from: path, requirement: $0) } ?? false)
    }

    func setService(label: String, on: Bool, reply: @escaping (Bool) -> Void) {
        guard label != own, let file = HelperServices.plist(for: label) else { return reply(false) }
        let target = "system/" + label
        guard Self.launchctl([on ? "enable" : "disable", target]) else { return reply(false) }
        guard on else {
            _ = Self.launchctl(["bootout", target])
            return reply(true)
        }
        reply(Self.launchctl(["bootstrap", "system", file]) || Self.launchctl(["print", target]))
    }

    private static func launchctl(_ arguments: [String]) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return false }
        process.waitUntilExit()
        return process.terminationStatus == 0
    }

    func finish() -> Never {
        resetAll()
        updates.lock()
        if let candidate { FanHelperInfo.commit(CommandLine.arguments[0], requirement: candidate) }
        exit(0)
    }
}

let label = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent
let appIdentifier = label.hasSuffix(FanHelperInfo.suffix) ? String(label.dropLast(FanHelperInfo.suffix.count)) : label
let service = Service(smc: device, requirement: FanHelperInfo.requirement(identifier: appIdentifier), candidate: FanHelperInfo.requirement(identifier: label), own: label)
service.resetAll()

let listener = NSXPCListener(machServiceName: label)
listener.delegate = service
listener.resume()

Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in service.guardHeat() }

var signals = [DispatchSourceSignal]()
for number in [SIGTERM, SIGINT] {
    signal(number, SIG_IGN)
    let source = DispatchSource.makeSignalSource(signal: number, queue: .main)
    source.setEventHandler { service.finish() }
    source.resume()
    signals.append(source)
}

RunLoop.main.run()
