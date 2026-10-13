import AppKit
import AVFoundation
import CoreAudio
import os

struct AppVolumeError: Error {
    let step: String
    let status: OSStatus
}

func appVolumeCheck(_ status: OSStatus, _ step: String) throws {
    if status != noErr { throw AppVolumeError(step: step, status: status) }
}

@available(macOS 14.2, *)
enum AppVolumeHAL {
    static let system = AudioObjectID(kAudioObjectSystemObject)

    static func address(_ selector: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
    }

    static func read<T>(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector, _ initial: T) -> T? {
        var address = address(selector)
        var size = UInt32(MemoryLayout<T>.size)
        var value = initial
        let status = withUnsafeMutablePointer(to: &value) { AudioObjectGetPropertyData(object, &address, 0, nil, &size, $0) }
        return status == noErr ? value : nil
    }

    static func string(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector) -> String? {
        var address = address(selector)
        var size = UInt32(MemoryLayout<CFString?>.size)
        var value: CFString?
        let status = withUnsafeMutablePointer(to: &value) { AudioObjectGetPropertyData(object, &address, 0, nil, &size, $0) }
        return status == noErr ? value as String? : nil
    }

    static func objects(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> [AudioObjectID] {
        var address = address(selector, scope)
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(object, &address, 0, nil, &size) == noErr else { return [] }
        var list = [AudioObjectID](repeating: 0, count: Int(size) / MemoryLayout<AudioObjectID>.size)
        guard AudioObjectGetPropertyData(object, &address, 0, nil, &size, &list) == noErr else { return [] }
        return Array(list.prefix(Int(size) / MemoryLayout<AudioObjectID>.size))
    }

    static func processObject(pid: pid_t) -> AudioObjectID? {
        var address = address(kAudioHardwarePropertyTranslatePIDToProcessObject)
        var pid = pid
        var object = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        let status = AudioObjectGetPropertyData(system, &address, UInt32(MemoryLayout<pid_t>.size), &pid, &size, &object)
        return status == noErr && object != kAudioObjectUnknown ? object : nil
    }

    static func isRunningOutput(_ process: AudioObjectID) -> Bool {
        (read(process, kAudioProcessPropertyIsRunningOutput, UInt32(0)) ?? 0) != 0
    }
}

@available(macOS 14.2, *)
struct AppVolumeOutput: Equatable {
    let device: AudioObjectID
    let uid: String
    let rate: Double

    init?(device: AudioObjectID) {
        guard device != kAudioObjectUnknown,
              (AppVolumeHAL.read(device, kAudioDevicePropertyDeviceIsAlive, UInt32(1)) ?? 1) != 0,
              let uid = AppVolumeHAL.string(device, kAudioDevicePropertyDeviceUID)
        else { return nil }
        self.device = device
        self.uid = uid
        rate = AppVolumeHAL.read(device, kAudioDevicePropertyNominalSampleRate, Float64(48000)) ?? 48000
    }

    static func current() -> AppVolumeOutput? {
        AppVolumeHAL.read(AppVolumeHAL.system, kAudioHardwarePropertyDefaultOutputDevice, AudioObjectID(kAudioObjectUnknown))
            .flatMap { AppVolumeOutput(device: $0) }
    }
}

@available(macOS 14.2, *)
final class AppVolumeChain {
    let output: AppVolumeOutput?
    let gain: AppVolumeGain
    private let ring: AppVolumeRing
    private let description: CATapDescription
    private let tap: AudioObjectID
    private let aggregate: AudioObjectID
    private let procID: AudioDeviceIOProcID
    private let unit: AUAudioUnit?
    private(set) var running = false

    private init(output: AppVolumeOutput?, gain: AppVolumeGain, ring: AppVolumeRing, description: CATapDescription, tap: AudioObjectID, aggregate: AudioObjectID, procID: AudioDeviceIOProcID, unit: AUAudioUnit?) {
        self.output = output
        self.gain = gain
        self.ring = ring
        self.description = description
        self.tap = tap
        self.aggregate = aggregate
        self.procID = procID
        self.unit = unit
    }

    static func make(process: AudioObjectID, name: String, output: AppVolumeOutput?, mute: CATapMuteBehavior, target: Float) throws -> AppVolumeChain {
        let description = CATapDescription(stereoMixdownOfProcesses: [process])
        description.name = name
        description.isPrivate = true
        description.muteBehavior = mute
        var tap = AudioObjectID(kAudioObjectUnknown)
        try appVolumeCheck(AudioHardwareCreateProcessTap(description, &tap), "tap")
        var aggregate = AudioObjectID(kAudioObjectUnknown)
        var procID: AudioDeviceIOProcID?
        do {
            guard let format = AppVolumeHAL.read(tap, kAudioTapPropertyFormat, AudioStreamBasicDescription()), format.mSampleRate > 0 else {
                throw AppVolumeError(step: "format", status: kAudioHardwareBadPropertySizeError)
            }
            let gain = AppVolumeGain(target: target, sampleRate: format.mSampleRate)
            let ring = AppVolumeRing()
            let composition: [String: Any] = [
                kAudioAggregateDeviceNameKey: name,
                kAudioAggregateDeviceUIDKey: UUID().uuidString,
                kAudioAggregateDeviceIsPrivateKey: true,
                kAudioAggregateDeviceTapAutoStartKey: true,
                kAudioAggregateDeviceTapListKey: [[kAudioSubTapUIDKey: description.uuid.uuidString, kAudioSubTapDriftCompensationKey: false]],
            ]
            try appVolumeCheck(AudioHardwareCreateAggregateDevice(composition as CFDictionary, &aggregate), "aggregate")
            let capture: AudioDeviceIOBlock = { _, input, _, _, _ in
                AppVolumeMath.capture(tap: input, ring: ring, state: gain)
            }
            try appVolumeCheck(AudioDeviceCreateIOProcIDWithBlock(&procID, aggregate, nil, capture), "ioproc")
            guard let procID else { throw AppVolumeError(step: "ioproc", status: kAudioHardwareUnspecifiedError) }
            let unit = try output.map { device in
                try playback(on: device, format: format) { _, _, frames, _, data in
                    AppVolumeMath.render(tap: ring.pull(frames: Int(frames)), output: data, state: gain)
                    return noErr
                }
            }
            return AppVolumeChain(output: output, gain: gain, ring: ring, description: description, tap: tap, aggregate: aggregate, procID: procID, unit: unit)
        } catch {
            if let procID { AudioDeviceDestroyIOProcID(aggregate, procID) }
            if aggregate != kAudioObjectUnknown { AudioHardwareDestroyAggregateDevice(aggregate) }
            AudioHardwareDestroyProcessTap(tap)
            throw error
        }
    }

    static func playback(on output: AppVolumeOutput, format: AudioStreamBasicDescription, provider: @escaping AURenderPullInputBlock) throws -> AUAudioUnit {
        var format = format
        guard let client = AVAudioFormat(streamDescription: &format) else {
            throw AppVolumeError(step: "format", status: OSStatus(kAudioUnitErr_FormatNotSupported))
        }
        let unit = try AUAudioUnit(componentDescription: AudioComponentDescription(
            componentType: kAudioUnitType_Output, componentSubType: kAudioUnitSubType_HALOutput,
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple), componentFlags: 0, componentFlagsMask: 0
        ))
        unit.isInputEnabled = false
        unit.isOutputEnabled = true
        try unit.setDeviceID(output.device)
        try unit.inputBusses[0].setFormat(client)
        unit.outputProvider = provider
        try unit.allocateRenderResources()
        return unit
    }

    func start() throws {
        guard !running else { return }
        ring.reset()
        try unit?.startHardware()
        let status = AudioDeviceStart(aggregate, procID)
        guard status == noErr else {
            unit?.stopHardware()
            throw AppVolumeError(step: "start", status: status)
        }
        running = true
    }

    func mute() throws {
        description.muteBehavior = .muted
        var address = AppVolumeHAL.address(kAudioTapPropertyDescription)
        let status = withUnsafePointer(to: description) {
            AudioObjectSetPropertyData(tap, &address, 0, nil, UInt32(MemoryLayout<CATapDescription>.size), $0)
        }
        try appVolumeCheck(status, "mute")
    }

    func stop() {
        guard running else { return }
        AudioDeviceStop(aggregate, procID)
        unit?.stopHardware()
        running = false
    }

    func destroy() {
        stop()
        unit?.deallocateRenderResources()
        AudioDeviceDestroyIOProcID(aggregate, procID)
        AudioHardwareDestroyAggregateDevice(aggregate)
        AudioHardwareDestroyProcessTap(tap)
    }
}

@available(macOS 14.2, *)
final class AppVolumeEngine: @unchecked Sendable {
    static let shared = AppVolumeEngine()

    private struct Listener {
        let object: AudioObjectID
        let address: AudioObjectPropertyAddress
        let block: AudioObjectPropertyListenerBlock
    }

    private final class Client {
        let object: AudioObjectID
        let pid: pid_t
        let owner: AppVolumeOwner
        var running: Bool
        var live: AppVolumeChain?
        var listeners: [Listener] = []
        var stop: DispatchWorkItem?
        var blockedUntil = Date.distantPast
        var silentTicks = 0

        init(object: AudioObjectID, pid: pid_t, owner: AppVolumeOwner, running: Bool) {
            self.object = object
            self.pid = pid
            self.owner = owner
            self.running = running
        }
    }

    private let queue = DispatchQueue(label: "pikapik.app-volume", qos: .userInitiated)
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "pikapik", category: "app-volume")
    private var active = false
    private var levels: [String: Double] = [:]
    private var muted: Set<String> = []
    private var clients: [AudioObjectID: Client] = [:]
    private var ignored: Set<AudioObjectID> = []
    private var lastPlayed: [String: Date] = [:]
    private var output: AppVolumeOutput?
    private var systemListeners: [Listener] = []
    private var deviceListeners: [Listener] = []
    private var wakeObserver: NSObjectProtocol?
    private var timer: DispatchSourceTimer?
    private var expiry: DispatchWorkItem?
    private var retry: DispatchWorkItem?

    private init() {}

    func configure(active: Bool, levels: [String: Double], muted: Set<String>) {
        queue.async { [self] in
            self.levels = levels
            self.muted = muted
            if active != self.active {
                self.active = active
                if active { start() } else { stop() }
            } else if active {
                reconcile()
                publish()
            }
        }
    }

    func shutdown() {
        let done = DispatchSemaphore(value: 0)
        queue.async { [self] in
            active = false
            stop()
            done.signal()
        }
        _ = done.wait(timeout: .now() + 1)
    }

    private func start() {
        log.debug("start")
        systemListeners = installSystemListeners()
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil) { [self] _ in
            queue.asyncAfter(deadline: .now() + 1) { [self] in wake() }
        }
        output = AppVolumeOutput.current()
        watchOutput()
        refreshProcesses()
    }

    private func stop() {
        log.debug("stop")
        systemListeners.forEach(remove)
        deviceListeners.forEach(remove)
        systemListeners = []
        deviceListeners = []
        if let wakeObserver { NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver) }
        wakeObserver = nil
        expiry?.cancel()
        retry?.cancel()
        clients.values.forEach(drop)
        clients = [:]
        ignored = []
        lastPlayed = [:]
        output = nil
        updateTimer()
        publish()
    }

    private func installSystemListeners() -> [Listener] {
        let system = AppVolumeHAL.system
        return [
            listen(system, kAudioHardwarePropertyProcessObjectList) { [self] in refreshProcesses() },
            listen(system, kAudioHardwarePropertyDefaultOutputDevice) { [self] in outputChanged() },
            listen(system, kAudioHardwarePropertyServiceRestarted) { [self] in serviceRestarted() },
        ]
    }

    private func listen(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal, _ handler: @escaping () -> Void) -> Listener {
        let block: AudioObjectPropertyListenerBlock = { _, _ in handler() }
        var address = AppVolumeHAL.address(selector, scope)
        AudioObjectAddPropertyListenerBlock(object, &address, queue, block)
        return Listener(object: object, address: address, block: block)
    }

    private func remove(_ listener: Listener) {
        var address = listener.address
        AudioObjectRemovePropertyListenerBlock(listener.object, &address, queue, listener.block)
    }

    private func watchOutput() {
        deviceListeners.forEach(remove)
        deviceListeners = []
        guard let output else { return }
        deviceListeners = [
            listen(output.device, kAudioDevicePropertyNominalSampleRate) { [self] in outputChanged() },
            listen(output.device, kAudioDevicePropertyDeviceIsAlive) { [self] in outputChanged() },
        ]
    }

    private func refreshProcesses() {
        guard active else { return }
        let objects = Set(AppVolumeHAL.objects(AppVolumeHAL.system, kAudioHardwarePropertyProcessObjectList))
        for (object, client) in clients where !objects.contains(object) {
            drop(client)
            clients[object] = nil
        }
        ignored.formIntersection(objects)
        let fresh = objects.filter { clients[$0] == nil && !ignored.contains($0) }
        if !fresh.isEmpty {
            let apps = Self.runningApps()
            fresh.forEach { add($0, apps) }
        }
        reconcile()
        publish()
    }

    private func add(_ object: AudioObjectID, _ apps: [AppVolumeMath.RunningApp]) {
        guard let pid = AppVolumeHAL.read(object, kAudioProcessPropertyPID, pid_t(0)), pid > 0, pid != getpid() else {
            ignored.insert(object)
            return
        }
        let path = Self.path(of: pid)
        let bundle = AppVolumeHAL.string(object, kAudioProcessPropertyBundleID).flatMap { $0.isEmpty ? nil : $0 }
        let name = NSRunningApplication(processIdentifier: pid)?.localizedName ?? path.map { ($0 as NSString).lastPathComponent } ?? Self.name(of: pid)
        guard let owner = AppVolumeMath.resolveOwner(processPath: path, processBundleID: bundle, processName: name, runningApps: apps, ancestorPaths: Self.ancestors(of: pid)) else {
            ignored.insert(object)
            return
        }
        let client = Client(object: object, pid: pid, owner: owner, running: AppVolumeHAL.isRunningOutput(object))
        if client.running { lastPlayed[owner.key] = Date() }
        client.listeners = [
            listen(object, kAudioProcessPropertyIsRunningOutput) { [self] in runningChanged(object) },
            listen(object, kAudioProcessPropertyIsRunning) { [self] in runningChanged(object) },
            listen(object, kAudioProcessPropertyDevices, kAudioObjectPropertyScopeOutput) { [self] in devicesChanged(object) },
        ]
        clients[object] = client
    }

    private func drop(_ client: Client) {
        client.listeners.forEach(remove)
        client.listeners = []
        client.stop?.cancel()
        client.stop = nil
        teardown(client)
    }

    private func teardown(_ client: Client) {
        guard let live = client.live else { return }
        client.live = nil
        client.silentTicks = 0
        live.destroy()
        log.debug("chain torn down pid=\(client.pid)")
    }

    private func targetGain(_ owner: AppVolumeOwner) -> Float {
        AppVolumeMath.gain(slider: levels[owner.key] ?? 1, muted: muted.contains(owner.key))
    }

    private func isAdjusted(_ owner: AppVolumeOwner) -> Bool {
        (levels[owner.key] ?? 1) != 1 || muted.contains(owner.key)
    }

    private func reconcile() {
        guard active, let output else {
            clients.values.forEach(teardown)
            updateTimer()
            return
        }
        for client in clients.values {
            if let live = client.live {
                live.gain.target = targetGain(client.owner)
            } else if isAdjusted(client.owner), Date() >= client.blockedUntil {
                do { client.live = try make(client, route(client, output), takeover: true) } catch { fail(client, error) }
            }
            if client.running { startIO(client) }
        }
        updateTimer()
    }

    private func route(_ client: Client, _ fallback: AppVolumeOutput) -> AppVolumeOutput {
        let used = AppVolumeHAL.objects(client.object, kAudioProcessPropertyDevices, kAudioObjectPropertyScopeOutput)
        return used.count == 1 ? AppVolumeOutput(device: used[0]) ?? fallback : fallback
    }

    private func build(_ client: Client, _ output: AppVolumeOutput, _ target: Float, _ mute: CATapMuteBehavior) throws -> AppVolumeChain {
        try AppVolumeChain.make(process: client.object, name: "pikapik \(client.pid)", output: output, mute: mute, target: target)
    }

    private func make(_ client: Client, _ output: AppVolumeOutput, takeover: Bool = false) throws -> AppVolumeChain {
        if takeover, client.running, let live = try seamless(client, output) { return live }
        let chain = try build(client, output, targetGain(client.owner), .muted)
        log.debug("chain created pid=\(client.pid) owner=\(client.owner.key) output=\(output.uid) rate=\(output.rate)")
        return chain
    }

    private func seamless(_ client: Client, _ output: AppVolumeOutput) throws -> AppVolumeChain? {
        let chain = try build(client, output, 0, .unmuted)
        do {
            try chain.start()
        } catch {
            chain.destroy()
            throw error
        }
        do {
            try chain.mute()
        } catch {
            log.debug("mute failed pid=\(client.pid) status=\((error as? AppVolumeError)?.status ?? 0)")
            chain.destroy()
            return nil
        }
        chain.gain.target = targetGain(client.owner)
        log.debug("chain taken over pid=\(client.pid) owner=\(client.owner.key) output=\(output.uid) rate=\(output.rate)")
        return chain
    }

    private func startIO(_ client: Client) {
        guard let live = client.live, !live.running else { return }
        live.gain.current = live.gain.target
        do {
            try live.start()
            log.debug("io started pid=\(client.pid)")
        } catch {
            fail(client, error)
        }
    }

    private func fail(_ client: Client, _ error: Error) {
        let failure = error as? AppVolumeError
        log.debug("chain failed pid=\(client.pid) step=\(failure?.step ?? "output") status=\(failure?.status ?? OSStatus((error as NSError).code))")
        teardown(client)
        client.blockedUntil = Date().addingTimeInterval(10)
        retry?.cancel()
        let work = DispatchWorkItem { [self] in reconcile() }
        retry = work
        queue.asyncAfter(deadline: .now() + 10.5, execute: work)
    }

    private func runningChanged(_ object: AudioObjectID) {
        guard active, let client = clients[object] else { return }
        let now = AppVolumeHAL.isRunningOutput(object)
        guard now != client.running else { return }
        client.running = now
        lastPlayed[client.owner.key] = Date()
        client.stop?.cancel()
        client.stop = nil
        if now {
            move(client)
            startIO(client)
        } else if client.live?.running == true {
            let work = DispatchWorkItem { [self, weak client] in
                guard let client, !client.running, let live = client.live else { return }
                live.stop()
                log.debug("io stopped pid=\(client.pid)")
            }
            client.stop = work
            queue.asyncAfter(deadline: .now() + 30, execute: work)
        }
        publish()
    }

    private func devicesChanged(_ object: AudioObjectID) {
        runningChanged(object)
        guard active, let client = clients[object] else { return }
        if client.live == nil { reconcile() } else { move(client) }
    }

    private func outputChanged() {
        guard active else { return }
        let current = AppVolumeOutput.current()
        guard current != output else { return }
        log.debug("output changed to \(current?.uid ?? "none")")
        output = current
        watchOutput()
        rebuild()
    }

    private func rebuild(force: Bool = false) {
        guard output != nil else { return reconcile() }
        clients.values.forEach { move($0, force: force) }
        reconcile()
    }

    private func move(_ client: Client, force: Bool = false) {
        guard let old = client.live, let output, force || client.running else { return }
        let next = route(client, output)
        guard force || next != old.output else { return }
        client.live = nil
        do {
            let new = try make(client, next)
            client.live = new
            if client.running { try new.start() }
            old.destroy()
        } catch {
            old.destroy()
            fail(client, error)
        }
    }

    private func wake() {
        guard active else { return }
        log.debug("wake")
        output = AppVolumeOutput.current()
        watchOutput()
        refreshProcesses()
        rebuild(force: true)
    }

    private func serviceRestarted() {
        guard active else { return }
        log.debug("service restarted")
        for client in clients.values {
            client.stop?.cancel()
            client.live = nil
            client.listeners = []
        }
        clients = [:]
        ignored = []
        deviceListeners = []
        systemListeners.forEach(remove)
        systemListeners = installSystemListeners()
        updateTimer()
        queue.asyncAfter(deadline: .now() + 1) { [self] in
            guard active else { return }
            output = AppVolumeOutput.current()
            watchOutput()
            refreshProcesses()
        }
    }

    private func updateTimer() {
        let needed = clients.values.contains { $0.live != nil }
        if needed, timer == nil {
            let source = DispatchSource.makeTimerSource(queue: queue)
            source.schedule(deadline: .now() + 1, repeating: 1, leeway: .milliseconds(100))
            source.setEventHandler { [self] in tick() }
            source.resume()
            timer = source
        } else if !needed, let timer {
            timer.cancel()
            self.timer = nil
        }
    }

    private func tick() {
        for client in Array(clients.values) where client.live != nil {
            runningChanged(client.object)
            guard let live = client.live, live.running else {
                client.silentTicks = 0
                continue
            }
            let peaks = live.gain.takePeaks()
            log.debug("pid=\(client.pid) in=\(peaks.input, format: .fixed(precision: 4)) out=\(peaks.output, format: .fixed(precision: 4)) gain=\(live.gain.current, format: .fixed(precision: 3))")
            client.silentTicks = client.running && peaks.input == 0 ? client.silentTicks + 1 : 0
            if client.silentTicks == 3 {
                client.silentTicks = 0
                DispatchQueue.main.async { AudioCaptureProbe.shared.checkSilence() }
            }
        }
    }

    private func publish() {
        var owners: [String: (owner: AppVolumeOwner, playing: Bool)] = [:]
        for client in clients.values {
            owners[client.owner.key] = (client.owner, (owners[client.owner.key]?.playing ?? false) || client.running)
        }
        let now = Date()
        var rows: [AppVolumeRow] = []
        var next: Date?
        for (key, entry) in owners {
            let until = lastPlayed[key]?.addingTimeInterval(30) ?? .distantPast
            let lingering = !entry.playing && until > now
            guard entry.playing || lingering || isAdjusted(entry.owner) else { continue }
            rows.append(AppVolumeRow(owner: entry.owner, playing: entry.playing))
            if lingering { next = min(next ?? until, until) }
        }
        rows.sort { $0.owner.name.localizedStandardCompare($1.owner.name) == .orderedAscending }
        expiry?.cancel()
        expiry = nil
        if let next {
            let work = DispatchWorkItem { [self] in publish() }
            expiry = work
            queue.asyncAfter(deadline: .now() + next.timeIntervalSince(now) + 0.1, execute: work)
        }
        DispatchQueue.main.async { MainActor.assumeIsolated { AppVolumeModel.shared.show(rows) } }
    }

    private static func runningApps() -> [AppVolumeMath.RunningApp] {
        NSWorkspace.shared.runningApplications.compactMap { app in
            guard app.activationPolicy == .regular, let id = app.bundleIdentifier, let name = app.localizedName, let path = app.bundleURL?.path else { return nil }
            return (id, name, path)
        }
    }

    private static func path(of pid: pid_t) -> String? {
        var buffer = [CChar](repeating: 0, count: 4096)
        if proc_pidpath(pid, &buffer, UInt32(buffer.count)) > 0 { return String(cString: buffer) }
        return NSRunningApplication(processIdentifier: pid)?.executableURL?.path
    }

    private static func parent(of pid: pid_t) -> pid_t? {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        guard sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0, size > 0 else { return nil }
        return info.kp_eproc.e_ppid
    }

    private static func ancestors(of pid: pid_t) -> [String] {
        var paths: [String] = []
        var current = pid
        for _ in 0..<8 {
            guard let next = parent(of: current), next > 1 else { break }
            if let path = path(of: next) { paths.append(path) }
            current = next
        }
        return paths
    }

    private static func name(of pid: pid_t) -> String? {
        var buffer = [CChar](repeating: 0, count: 256)
        return proc_name(pid, &buffer, UInt32(buffer.count)) > 0 ? String(cString: buffer) : nil
    }
}
