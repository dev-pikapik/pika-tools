import AppKit
import IOKit.ps
import IOKit.pwr_mgt
import SwiftUI

@Observable
final class KeepAwake {
    enum Mode: String {
        case off, timed, indefinitely
    }

    static let shared = KeepAwake()
    static let durations: [TimeInterval] = [900, 1800, 3600, 7200, 18000, 28800]
    private static let lidFlagKey = "keep-awake-lid-sleep-disabled"

    let hasLid: Bool = {
        if let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef],
           sources.contains(where: {
               (IOPSGetPowerSourceDescription(info, $0)?.takeUnretainedValue() as? [String: Any])?[kIOPSTypeKey] as? String == kIOPSInternalBatteryType
           }) {
            return true
        }
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        defer { IOObjectRelease(service) }
        if ["AppleClamshellState", "AppleClamshellCausesSleep"].contains(where: {
            IORegistryEntryCreateCFProperty(service, $0 as CFString, kCFAllocatorDefault, 0) != nil
        }) {
            return true
        }
        var displays = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetOnlineDisplayList(16, &displays, &count)
        return displays.prefix(Int(count)).contains { CGDisplayIsBuiltin($0) != 0 }
    }()

    private(set) var mode = Mode.off
    private(set) var endDate: Date?
    private(set) var lidActive = false
    private(set) var lidError: String?

    private(set) var lastMode: Mode {
        didSet { UserDefaults.standard.set(lastMode.rawValue, forKey: "keep-awake-mode") }
    }

    var duration: TimeInterval {
        didSet {
            UserDefaults.standard.set(duration, forKey: "keep-awake-duration")
            if mode == .timed { set(.timed) }
        }
    }

    var keepsDisplayOn: Bool {
        didSet {
            UserDefaults.standard.set(keepsDisplayOn, forKey: "keep-awake-display")
            update()
        }
    }

    var worksWithLidClosed: Bool {
        get { lidOption }
        set {
            lidOption = newValue
            UserDefaults.standard.set(newValue, forKey: "keep-awake-lid")
            lidError = nil
            update()
        }
    }

    var stopsOnLowBattery: Bool {
        didSet { UserDefaults.standard.set(stopsOnLowBattery, forKey: "keep-awake-battery") }
    }

    private var lidOption: Bool

    @ObservationIgnored private var assertions: [IOPMAssertionID] = []
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private let lidFlag = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tools-keep-awake")

    private init() {
        let defaults = UserDefaults.standard
        lastMode = Mode(rawValue: defaults.string(forKey: "keep-awake-mode") ?? "") ?? .timed
        duration = defaults.object(forKey: "keep-awake-duration") as? TimeInterval ?? 3600
        keepsDisplayOn = defaults.bool(forKey: "keep-awake-display")
        lidOption = defaults.bool(forKey: "keep-awake-lid")
        stopsOnLowBattery = defaults.object(forKey: "keep-awake-battery") as? Bool ?? true
    }

    var isOn: Bool {
        get { mode != .off }
        set { set(newValue ? lastMode : .off) }
    }

    var statusText: Text {
        switch mode {
        case .off: return Text("Your Mac sleeps as usual")
        case .indefinitely: return Text("Until you turn it off")
        case .timed:
            let end = max(endDate ?? .now, .now)
            return Text("\(Text(timerInterval: Date.now...end, countsDown: true).monospacedDigit()) left, until \(end.formatted(date: .omitted, time: .shortened))")
        }
    }

    static func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    func set(_ newMode: Mode) {
        mode = newMode
        if newMode != .off { lastMode = newMode }
        endDate = newMode == .timed ? Date().addingTimeInterval(duration) : nil
        update()
    }

    private func update() {
        assertions.forEach { IOPMAssertionRelease($0) }
        assertions = []
        timer?.invalidate()
        timer = nil
        guard mode != .off else { return setLid(false) }

        hold(kIOPMAssertionTypePreventUserIdleSystemSleep)
        if keepsDisplayOn { hold(kIOPMAssertionTypePreventUserIdleDisplaySleep) }
        setLid(hasLid && lidOption)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            KeepAwake.shared.tick()
        }
    }

    private func tick() {
        if let endDate, endDate <= .now {
            set(.off)
        } else if lidActive, stopsOnLowBattery, let level = batteryLevel, level < 20 {
            set(.off)
        }
    }

    private func hold(_ type: String) {
        var id = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(type as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), "pika-tools Keep Awake" as CFString, &id)
        if result == kIOReturnSuccess { assertions.append(id) }
    }

    private func setLid(_ on: Bool) {
        guard on != lidActive else { return }
        guard on else {
            try? FileManager.default.removeItem(at: lidFlag)
            lidActive = false
            UserDefaults.standard.set(false, forKey: Self.lidFlagKey)
            return
        }
        FileManager.default.createFile(atPath: lidFlag.path, contents: nil)
        let flag = "'" + lidFlag.path.replacingOccurrences(of: "'", with: "'\\''") + "'"
        let pid = ProcessInfo.processInfo.processIdentifier
        let command = "/usr/bin/pmset -a disablesleep 1 || exit 1; (while /bin/kill -0 \(pid) && [ -e \(flag) ]; do /bin/sleep 2; done; /usr/bin/pmset -a disablesleep 0) >/dev/null 2>&1 &"
        if Self.runAsAdmin(command, prompt: String(localized: "pika-tools wants to keep your Mac awake with the lid closed.")) {
            lidActive = true
            UserDefaults.standard.set(true, forKey: Self.lidFlagKey)
        } else {
            try? FileManager.default.removeItem(at: lidFlag)
            lidOption = false
            UserDefaults.standard.set(false, forKey: "keep-awake-lid")
            lidError = String(localized: "Not turned on: no administrator password")
        }
    }

    func restoreLidSleepIfNeeded() {
        guard UserDefaults.standard.bool(forKey: Self.lidFlagKey) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            guard !self.lidActive else { return }
            if Self.sleepDisabled {
                _ = Self.runAsAdmin("/usr/bin/pmset -a disablesleep 0", prompt: String(localized: "pika-tools wants to let your Mac sleep with the lid closed again."))
            }
            UserDefaults.standard.set(false, forKey: Self.lidFlagKey)
        }
    }

    private static var sleepDisabled: Bool {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g"]
        process.standardOutput = pipe
        guard (try? process.run()) != nil else { return false }
        let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        process.waitUntilExit()
        return output.split(separator: "\n").contains {
            $0.contains("SleepDisabled") && $0.split(whereSeparator: \.isWhitespace).last == "1"
        }
    }

    private static func runAsAdmin(_ command: String, prompt: String) -> Bool {
        let quote = { (text: String) in
            "\"" + text.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
        }
        var error: NSDictionary?
        NSAppleScript(source: "do shell script \(quote(command)) with prompt \(quote(prompt)) with administrator privileges")?
            .executeAndReturnError(&error)
        return error == nil
    }

    private var batteryLevel: Int? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef]
        else { return nil }
        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
                  description[kIOPSPowerSourceStateKey] as? String == kIOPSBatteryPowerValue,
                  let current = description[kIOPSCurrentCapacityKey] as? Int,
                  let max = description[kIOPSMaxCapacityKey] as? Int, max > 0
            else { continue }
            return current * 100 / max
        }
        return nil
    }
}

struct KeepAwakeSettings: View {
    @Bindable private var keepAwake = KeepAwake.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .keepAwake, text: String(localized: "Your Mac won’t go to sleep on its own. Turns off when you quit pika-tools."))
            Section {
                Picker(selection: Binding(get: { keepAwake.mode }, set: { keepAwake.set($0) })) {
                    Text("Off").tag(KeepAwake.Mode.off)
                    Text("For a while").tag(KeepAwake.Mode.timed)
                    Text("Indefinitely").tag(KeepAwake.Mode.indefinitely)
                } label: {
                    Text("Keep your Mac awake")
                    keepAwake.statusText
                }
                .settingAnchor(String(localized: "Keep your Mac awake"))
                Picker("Duration", selection: $keepAwake.duration) {
                    ForEach(KeepAwake.durations, id: \.self) { Text(KeepAwake.format($0)).tag($0) }
                }
                .disabled(keepAwake.mode == .indefinitely)
                .settingAnchor(String(localized: "Duration"))
                Toggle(isOn: $keepAwake.keepsDisplayOn) {
                    Text("Keep the display on")
                    Text("Otherwise the screen dims and turns off as usual")
                }
                .settingAnchor(String(localized: "Keep the display on"))
            }

            Section {
                Toggle(isOn: $keepAwake.worksWithLidClosed) {
                    Text("Work with the lid closed")
                    keepAwake.hasLid ? Text("Mac won’t sleep when you close the lid. Keep it ventilated.") : Text("Only on Mac laptops")
                }
                .disabled(!keepAwake.hasLid)
                .settingAnchor(String(localized: "Work with the lid closed"))
                if keepAwake.hasLid {
                    Toggle(isOn: $keepAwake.stopsOnLowBattery) {
                        Text("Stop when battery is below \(0.2.formatted(.percent))")
                        Text("Lets the Mac sleep again before the battery runs out")
                    }
                    .disabled(!keepAwake.worksWithLidClosed)
                    .settingAnchor(String(localized: "Stop when battery is below \(0.2.formatted(.percent))"))
                }
                if let error = keepAwake.lidError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            } footer: {
                if keepAwake.hasLid {
                    Text("macOS asks for an administrator password, because only an administrator can change this.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
    }
}
