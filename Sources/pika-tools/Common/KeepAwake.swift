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
    static let maxDuration = 365 * 86400
    private static let lidFlagKey = "keep-awake-lid-sleep-disabled"
    private static let legacyUnits = ["minutes": 60, "hours": 3600, "days": 86400, "weeks": 7 * 86400, "months": 30 * 86400]
    private static let sessionKey = "keep-awake-session"
    private static let sessionEndKey = "keep-awake-session-end"
    private static let bridgeKey = "keep-awake-bridge"

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
        return ["AppleClamshellState", "AppleClamshellCausesSleep"].contains(where: {
            IORegistryEntryCreateCFProperty(service, $0 as CFString, kCFAllocatorDefault, 0) != nil
        })
    }()

    private(set) var mode = Mode.off
    private(set) var endDate: Date?
    private(set) var now = Date.now
    private(set) var lidActive = false
    private(set) var lidError: String?

    private(set) var lastMode: Mode {
        didSet { UserDefaults.standard.set(lastMode.rawValue, forKey: "keep-awake-mode") }
    }

    var duration: Int {
        didSet {
            UserDefaults.standard.set(duration, forKey: "keep-awake-duration")
            if mode == .timed, duration != oldValue { set(.timed) }
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
        duration = Self.storedDuration()
        keepsDisplayOn = defaults.bool(forKey: "keep-awake-display")
        lidOption = defaults.bool(forKey: "keep-awake-lid")
        stopsOnLowBattery = defaults.object(forKey: "keep-awake-battery") as? Bool ?? true
    }

    func load() {
        let defaults = UserDefaults.standard
        lastMode = Mode(rawValue: defaults.string(forKey: "keep-awake-mode") ?? "") ?? .timed
        duration = Self.storedDuration()
        lidOption = defaults.bool(forKey: "keep-awake-lid")
        keepsDisplayOn = defaults.bool(forKey: "keep-awake-display")
        stopsOnLowBattery = defaults.object(forKey: "keep-awake-battery") as? Bool ?? true
    }

    private static func storedDuration() -> Int {
        let defaults = UserDefaults.standard
        if let unit = defaults.string(forKey: "keep-awake-duration-unit").flatMap({ legacyUnits[$0] }) {
            defaults.set(max(defaults.integer(forKey: "keep-awake-duration-value"), 1) * unit, forKey: "keep-awake-duration")
        }
        ["keep-awake-duration-unit", "keep-awake-duration-value"].forEach(defaults.removeObject)
        let seconds = (defaults.object(forKey: "keep-awake-duration") as? NSNumber)?.intValue ?? 3600
        return min(max(seconds, 1), maxDuration)
    }

    var isDefault: Bool {
        mode == .off && lastMode == .timed && duration == 3600
            && !keepsDisplayOn && !lidOption && stopsOnLowBattery
    }

    func reset() {
        set(.off)
        lastMode = .timed
        duration = 3600
        keepsDisplayOn = false
        worksWithLidClosed = false
        stopsOnLowBattery = true
    }

    var isOn: Bool {
        get { mode != .off }
        set { set(newValue ? lastMode : .off) }
    }

    var remaining: String? {
        guard mode == .timed else { return nil }
        let end = max(endDate ?? now, now)
        let left = Int(end.timeIntervalSince(now).rounded(.up))
        let days = left / 86400
        let clock = String(format: "%02d:%02d:%02d", left % 86400 / 3600, left % 3600 / 60, left % 60)
        return days > 0
            ? Duration.seconds(days * 86400).formatted(.units(allowed: [.days], width: .narrow)) + " " + clock
            : clock
    }

    var statusText: Text {
        switch mode {
        case .off: return Text("Your Mac sleeps as usual")
        case .indefinitely: return Text("Until you turn it off")
        case .timed:
            let end = max(endDate ?? now, now)
            return Text("\(Text(verbatim: remaining ?? "").monospacedDigit()) left, until \(Self.until(end))")
        }
    }

    static func until(_ end: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(end) {
            let formatter = DateFormatter()
            formatter.doesRelativeDateFormatting = true
            formatter.formattingContext = .middleOfSentence
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: end)
        }
        return calendar.isDateInToday(end)
            ? end.formatted(date: .omitted, time: .shortened)
            : end.formatted(.dateTime.month(.abbreviated).day().hour().minute())
    }

    func set(_ newMode: Mode) {
        mode = newMode
        if newMode != .off { lastMode = newMode }
        now = .now
        endDate = newMode == .timed ? now.addingTimeInterval(TimeInterval(duration)) : nil
        UserDefaults.standard.set(newMode == .off ? nil : newMode.rawValue, forKey: Self.sessionKey)
        UserDefaults.standard.set(endDate, forKey: Self.sessionEndKey)
        update()
    }

    func resume() {
        let defaults = UserDefaults.standard
        Self.stopBridge()
        guard let saved = Mode(rawValue: defaults.string(forKey: Self.sessionKey) ?? ""), saved != .off else { return }
        let end = defaults.object(forKey: Self.sessionEndKey) as? Date
        guard saved == .indefinitely || (end ?? .distantPast) > .now else { return set(.off) }
        mode = saved
        endDate = saved == .timed ? end : nil
        now = .now
        update()
    }

    func handOff() {
        guard mode != .off else { return }
        let bridge = Process()
        bridge.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        let seconds = min(120, max(1, Int(endDate?.timeIntervalSinceNow ?? 120)))
        bridge.arguments = [keepsDisplayOn ? "-di" : "-i", "-t", String(seconds)]
        guard (try? bridge.run()) != nil else { return }
        UserDefaults.standard.set(Int(bridge.processIdentifier), forKey: Self.bridgeKey)
    }

    static func turnOffDisplay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/pmset"), arguments: ["displaysleepnow"])
        }
    }

    private static func stopBridge() {
        let pid = pid_t(UserDefaults.standard.integer(forKey: bridgeKey))
        UserDefaults.standard.removeObject(forKey: bridgeKey)
        guard pid > 0 else { return }
        var name = [CChar](repeating: 0, count: 64)
        proc_name(pid, &name, UInt32(name.count))
        if String(cString: name) == "caffeinate" { kill(pid, SIGTERM) }
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
        let watched = FileManager.default.fileExists(atPath: lidFlag.path) && Self.sleepDisabled
        FileManager.default.createFile(atPath: lidFlag.path, contents: Data(String(ProcessInfo.processInfo.processIdentifier).utf8))
        if watched {
            lidActive = true
            UserDefaults.standard.set(true, forKey: Self.lidFlagKey)
            return
        }
        let flag = "'" + lidFlag.path.replacingOccurrences(of: "'", with: "'\\''") + "'"
        let command = "/usr/bin/pmset -a disablesleep 1 || exit 1; (g=0; while [ -e \(flag) ]; do if /bin/kill -0 \"$(/bin/cat \(flag))\"; then g=0; else g=$((g+2)); [ $g -ge 60 ] && break; fi; /bin/sleep 2; done; /usr/bin/pmset -a disablesleep 0; /bin/rm -f \(flag)) >/dev/null 2>&1 &"
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

    private static var shortcutsIcon: NSImage {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.shortcuts")
            .map { NSWorkspace.shared.icon(forFile: $0.path) } ?? NSImage()
    }

    private func until(_ now: Date) -> Text {
        Text("Until \(KeepAwake.until(now.addingTimeInterval(TimeInterval(keepAwake.duration))))")
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .keepAwake, text: String(localized: "Your Mac stays awake until you quit pika-tools"))
            Section {
                KeepAwakeArt()
                LabeledContent {
                    Picker("Keep your Mac awake", selection: Binding(get: { keepAwake.mode }, set: { keepAwake.set($0) })) {
                        Text("Off").tag(KeepAwake.Mode.off)
                        Text("For a while").tag(KeepAwake.Mode.timed)
                        Text("Indefinitely").tag(KeepAwake.Mode.indefinitely)
                    }
                    .labelsHidden()
                    .fixedSize()
                } label: {
                    RowLabel(Text("Keep your Mac awake"), keepAwake.statusText)
                }
                .settingAnchor(String(localized: "Keep your Mac awake"))
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Duration")
                        if keepAwake.mode == .off {
                            TimelineView(.everyMinute) { context in
                                until(context.date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    DurationPicker(seconds: $keepAwake.duration)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 4)
                .disabled(keepAwake.mode == .indefinitely)
                .settingAnchor(String(localized: "Duration"))
                VStack(alignment: .leading, spacing: 10) {
                    RowLabel(Text("Display"), keepAwake.keepsDisplayOn ? Text("No dimming, screen saver or lock screen") : Text("Turns off on its own timer, your Mac keeps working"))
                    Picker("Display", selection: $keepAwake.keepsDisplayOn) {
                        Text("Always on").tag(true)
                        Text("Turns off as usual").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 4)
                .settingAnchor(String(localized: "Display"))
                LabeledContent {
                    Button("Turn Off") { KeepAwake.turnOffDisplay() }
                } label: {
                    RowLabel(Text("Turn off the display now"), Text("Your Mac keeps working. To bring the display back, move the mouse or press a key."))
                }
                .settingAnchor(String(localized: "Turn off the display now"))
            }

            if keepAwake.hasLid {
                Section {
                    Toggle(isOn: $keepAwake.worksWithLidClosed) {
                        RowLabel(Text("Work with the lid closed"), Text("Mac stays awake with the lid closed"))
                    }
                    .help(Text("Mac won’t sleep when you close the lid. Keep it ventilated."))
                    .settingAnchor(String(localized: "Work with the lid closed"))
                    Toggle(isOn: $keepAwake.stopsOnLowBattery) {
                        RowLabel(Text("Stop when battery is below \(0.2.formatted(.percent))"), Text("Lets the Mac sleep before the battery runs out"))
                    }
                    .disabled(!keepAwake.worksWithLidClosed)
                    .settingAnchor(String(localized: "Stop when battery is below \(0.2.formatted(.percent))"))
                    if let error = keepAwake.lidError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                } footer: {
                    Text("macOS will ask for your administrator password.")
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
                LabeledContent {
                    Button("Open Shortcuts", systemImage: "arrow.up.forward.app") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Shortcuts.app"))
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(nsImage: Self.shortcutsIcon)
                            .resizable()
                            .frame(width: SettingsTab.iconSize + 4, height: SettingsTab.iconSize + 4)
                            .accessibilityHidden(true)
                        Text("Shortcuts")
                    }
                }
            } header: {
                Text("Buttons in Control Center and widgets")
            } footer: {
                Text("Add the Open URLs action in Shortcuts, with a link.")
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

private struct KeepAwakeArt: View {
    private let keepAwake = KeepAwake.shared

    var body: some View {
        KeepAwakeScene(
            on: keepAwake.mode != .off,
            bright: keepAwake.keepsDisplayOn,
            closed: keepAwake.hasLid && keepAwake.worksWithLidClosed,
            hasLid: keepAwake.hasLid,
            remaining: keepAwake.remaining
        )
    }
}

struct KeepAwakeScene: View {
    let on: Bool
    let bright: Bool
    let closed: Bool
    let hasLid: Bool
    let remaining: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Look: Equatable {
        let on: Bool
        let bright: Bool
        let closed: Bool
    }

    var body: some View {
        let glow = on ? (bright ? 1.0 : 0.6) : 0
        let monitor = closed || !hasLid
        IllustrationRow {
            ZStack(alignment: .bottom) {
                if hasLid {
                    ArtLaptop(lid: closed ? 1 : 0, glow: closed ? 0 : glow) { face }
                        .offset(x: closed ? -80 : 0)
                }
                ArtMonitor(glow: glow) { face }
                    .offset(x: hasLid ? 76 : 0)
                    .scaleEffect(monitor ? 1 : 0.85, anchor: .bottom)
                    .opacity(monitor ? 1 : 0)
            }
            .padding(.bottom, 22)
            .spring(Look(on: on, bright: bright, closed: closed), reduceMotion: reduceMotion)
        }
    }

    private var face: some View {
        ZStack {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.4))
                .opacity(on ? 0 : 1)
            Group {
                if let remaining {
                    Text(verbatim: remaining)
                } else {
                    Image(systemName: "infinity")
                }
            }
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2.5)
            .background(.black.opacity(0.35), in: Capsule())
            .opacity(on ? 1 : 0)
        }
    }
}

private struct ShortcutLink: View {
    let title: String
    let path: String
    @State private var copied = false

    private var link: String {
        let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
        let scheme = (types?.first?["CFBundleURLSchemes"] as? [String])?.first ?? "pika-tools"
        return "\(scheme)://\(path)"
    }

    var body: some View {
        LabeledContent {
            Button(copied ? LocalizedStringKey("Copied") : "Copy Link", systemImage: copied ? "checkmark" : "link") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(link, forType: .string)
                copied = true
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    copied = false
                }
            }
            .contentTransition(.symbolEffect(.replace))
            .animation(.snappy, value: copied)
        } label: {
            RowLabel(Text(title), Text(verbatim: link))
                .textSelection(.enabled)
        }
    }
}
