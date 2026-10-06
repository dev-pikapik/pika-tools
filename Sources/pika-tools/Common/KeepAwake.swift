import AppKit
import IOKit.ps
import IOKit.pwr_mgt
import SwiftUI

@Observable
final class KeepAwake {
    enum Mode: String {
        case off, timed, indefinitely
    }

    enum Unit: String, CaseIterable {
        case minutes, hours, days, weeks, months

        var component: Calendar.Component {
            switch self {
            case .minutes: .minute
            case .hours: .hour
            case .days: .day
            case .weeks: .weekOfMonth
            case .months: .month
            }
        }

        var limit: Int {
            switch self {
            case .minutes, .hours: 999
            case .days: 365
            case .weeks: 52
            case .months: 12
            }
        }

        func name(for value: Int) -> String {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.allowedUnits = switch self {
            case .minutes: .minute
            case .hours: .hour
            case .days: .day
            case .weeks: .weekOfMonth
            case .months: .month
            }
            var components = DateComponents()
            components.setValue(value, for: component)
            let text = formatter.string(from: components) ?? rawValue
            return text.replacingOccurrences(of: value.formatted(), with: "").trimmingCharacters(in: .whitespaces)
        }
    }

    static let shared = KeepAwake()
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
    private(set) var now = Date.now
    private(set) var lidActive = false
    private(set) var lidError: String?

    private(set) var lastMode: Mode {
        didSet { UserDefaults.standard.set(lastMode.rawValue, forKey: "keep-awake-mode") }
    }

    var durationValue: Int {
        didSet {
            UserDefaults.standard.set(durationValue, forKey: "keep-awake-duration-value")
            if mode == .timed { set(.timed) }
        }
    }

    var durationUnit: Unit {
        didSet {
            UserDefaults.standard.set(durationUnit.rawValue, forKey: "keep-awake-duration-unit")
            if durationValue > durationUnit.limit {
                durationValue = durationUnit.limit
            } else if mode == .timed {
                set(.timed)
            }
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
        if let unit = Unit(rawValue: defaults.string(forKey: "keep-awake-duration-unit") ?? "") {
            durationUnit = unit
            durationValue = min(max(defaults.integer(forKey: "keep-awake-duration-value"), 1), unit.limit)
        } else {
            let seconds = Int(defaults.object(forKey: "keep-awake-duration") as? TimeInterval ?? 3600)
            durationUnit = seconds % 3600 == 0 ? .hours : .minutes
            durationValue = min(max(seconds / (seconds % 3600 == 0 ? 3600 : 60), 1), 999)
        }
        keepsDisplayOn = defaults.bool(forKey: "keep-awake-display")
        lidOption = defaults.bool(forKey: "keep-awake-lid")
        stopsOnLowBattery = defaults.object(forKey: "keep-awake-battery") as? Bool ?? true
    }

    func load() {
        let defaults = UserDefaults.standard
        lastMode = Mode(rawValue: defaults.string(forKey: "keep-awake-mode") ?? "") ?? .timed
        durationUnit = Unit(rawValue: defaults.string(forKey: "keep-awake-duration-unit") ?? "") ?? .hours
        durationValue = min(max(defaults.object(forKey: "keep-awake-duration-value") as? Int ?? 1, 1), durationUnit.limit)
        lidOption = defaults.bool(forKey: "keep-awake-lid")
        keepsDisplayOn = defaults.bool(forKey: "keep-awake-display")
        stopsOnLowBattery = defaults.object(forKey: "keep-awake-battery") as? Bool ?? true
    }

    var isDefault: Bool {
        mode == .off && lastMode == .timed && durationUnit == .hours && durationValue == 1
            && !keepsDisplayOn && !lidOption && stopsOnLowBattery
    }

    func reset() {
        set(.off)
        lastMode = .timed
        durationUnit = .hours
        durationValue = 1
        keepsDisplayOn = false
        worksWithLidClosed = false
        stopsOnLowBattery = true
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
            let end = max(endDate ?? now, now)
            let left = Int(end.timeIntervalSince(now).rounded(.up))
            let days = left / 86400
            let clock = String(format: "%02d:%02d:%02d", left % 86400 / 3600, left % 3600 / 60, left % 60)
            let remaining = days > 0
                ? Duration.seconds(days * 86400).formatted(.units(allowed: [.days], width: .narrow)) + " " + clock
                : clock
            let until = Calendar.current.isDateInToday(end)
                ? end.formatted(date: .omitted, time: .shortened)
                : end.formatted(.dateTime.month(.abbreviated).day().hour().minute())
            return Text("\(Text(verbatim: remaining).monospacedDigit()) left, until \(until)")
        }
    }

    func set(_ newMode: Mode) {
        mode = newMode
        if newMode != .off { lastMode = newMode }
        now = .now
        endDate = newMode == .timed ? Calendar.current.date(byAdding: durationUnit.component, value: durationValue, to: now) : nil
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
        now = .now
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

    private var value: Binding<Int> {
        Binding(
            get: { keepAwake.durationValue },
            set: { keepAwake.durationValue = min(max($0, 1), keepAwake.durationUnit.limit) }
        )
    }

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
                LabeledContent {
                    HStack(spacing: 8) {
                        TextField("Duration", value: value, format: .number)
                            .labelsHidden()
                            .multilineTextAlignment(.trailing)
                            .frame(width: 56)
                        Stepper("Duration", value: value, in: 1...keepAwake.durationUnit.limit)
                            .labelsHidden()
                        Picker("Duration", selection: $keepAwake.durationUnit) {
                            ForEach(KeepAwake.Unit.allCases, id: \.self) { Text(verbatim: $0.name(for: keepAwake.durationValue)).tag($0) }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                } label: {
                    Text("Duration")
                    Text("From 1 minute to 12 months")
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
            Section {
                ShortcutLink(title: String(localized: "Keep Awake"), path: "keep-awake")
                ShortcutLink(title: String(localized: "Keep the display on"), path: "display")
                if keepAwake.hasLid {
                    ShortcutLink(title: String(localized: "Work with the lid closed"), path: "lid-closed")
                }
                LabeledContent(String(localized: "Shortcuts")) {
                    Button(String(localized: "Open Shortcuts")) {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Shortcuts.app"))
                    }
                }
            } header: {
                Text("Buttons in Control Center and widgets")
            } footer: {
                Text("In Shortcuts, make a shortcut with the Open URLs action and paste a link. Then add it to Control Center, the menu bar or a Shortcuts widget on the desktop. Each tap turns it on or off.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .settingAnchor(String(localized: "Buttons in Control Center and widgets"))
            RestoreDefaultsSection(
                message: String(localized: "Keep Awake will turn off, and the duration and options will go back to how they were."),
                isDefault: keepAwake.isDefault
            ) {
                keepAwake.reset()
            }
        }
        .formStyle(.grouped)
        .settingsPage()
    }
}

extension KeepAwake {
    func handle(_ url: URL) {
        let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first?.name
        func flag(_ current: Bool) -> Bool { value == "on" ? true : value == "off" ? false : !current }
        switch url.host {
        case "keep-awake":
            isOn = flag(isOn)
        case "lid-closed":
            let on = flag(isOn && worksWithLidClosed)
            worksWithLidClosed = on
            if on { isOn = true }
        case "display":
            let on = flag(isOn && keepsDisplayOn)
            keepsDisplayOn = on
            if on { isOn = true }
        default:
            break
        }
    }
}

private struct ShortcutLink: View {
    let title: String
    let path: String

    private var link: String {
        let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
        let scheme = (types?.first?["CFBundleURLSchemes"] as? [String])?.first ?? "pika-tools"
        return "\(scheme)://\(path)"
    }

    var body: some View {
        LabeledContent {
            Button(String(localized: "Copy Link")) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(link, forType: .string)
            }
        } label: {
            Text(title)
            Text(verbatim: link)
                .textSelection(.enabled)
        }
    }
}
