import IOKit
import IOKit.hid
import SwiftUI

@Observable
final class PointerTool: Tool {
    let id = "linear-pointer"
    let icon = "cursorarrow.motionlines"
    var title: String { String(localized: "Turn off pointer acceleration") }
    let tab = SettingsTab.mouse

    static let speedRange = 0.2...3.0
    private static let speedKey = "linear-pointer-speed"
    private static let savedKey = "linear-pointer-saved"
    private static let linearKey = "HIDUseLinearScalingMouseAcceleration"
    private static let resolutionKey = "HIDPointerResolution"

    private static var systemSpeed: Double {
        let value = UserDefaults.standard.object(forKey: "com.apple.mouse.scaling") as? Double ?? 0.875
        return min(max(value, speedRange.lowerBound), speedRange.upperBound)
    }

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var speed: Double {
        didSet {
            UserDefaults.standard.set(speed, forKey: Self.speedKey)
            if isEnabled { apply() }
        }
    }

    @ObservationIgnored private let client = PointerTool.makeClient()
    @ObservationIgnored private var saved: [String: [String: Int]]
    @ObservationIgnored private var port: IONotificationPortRef?

    init() {
        let defaults = UserDefaults.standard
        isEnabled = defaults.bool(forKey: id)
        speed = Self.savedSpeed
        saved = defaults.dictionary(forKey: Self.savedKey) as? [String: [String: Int]] ?? [:]
    }

    private static var savedSpeed: Double {
        let value = UserDefaults.standard.object(forKey: speedKey) as? Double ?? systemSpeed
        return min(max(value, speedRange.lowerBound), speedRange.upperBound)
    }

    var settingsView: AnyView {
        AnyView(PointerSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && speed == Self.systemSpeed }

    func reset() {
        isEnabled = false
        speed = Self.systemSpeed
        UserDefaults.standard.removeObject(forKey: Self.speedKey)
    }

    func load() {
        speed = Self.savedSpeed
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func refresh() {
        isActive = isEnabled && client != nil
        if isEnabled {
            apply()
            watchDevices()
        } else {
            restore()
            stopWatching()
        }
    }

    func restore() {
        for service in mice() {
            guard let id = Self.registryID(service), let values = saved[id] else { continue }
            for (key, value) in values {
                IOHIDServiceClientSetProperty(service, key as CFString, value as CFNumber)
            }
        }
        saved = [:]
        UserDefaults.standard.removeObject(forKey: Self.savedKey)
    }

    private func apply() {
        for service in mice() {
            guard let id = Self.registryID(service) else { continue }
            let accelerationKey = Self.property(service, "HIDPointerAccelerationType") as? String ?? "HIDMouseAcceleration"
            if saved[id] == nil {
                var values: [String: Int] = [:]
                for key in [Self.linearKey, accelerationKey, Self.resolutionKey] {
                    values[key] = (Self.property(service, key) as? NSNumber)?.intValue
                }
                saved[id] = values
            }
            if Self.property(service, Self.linearKey) != nil {
                IOHIDServiceClientSetProperty(service, Self.linearKey as CFString, 1 as CFNumber)
                IOHIDServiceClientSetProperty(service, accelerationKey as CFString, Self.fixed(speed))
            } else {
                IOHIDServiceClientSetProperty(service, Self.resolutionKey as CFString, Self.fixed(min(max(400 / speed, 10), 1995)))
                IOHIDServiceClientSetProperty(service, accelerationKey as CFString, Self.fixed(-1))
            }
        }
        UserDefaults.standard.set(saved, forKey: Self.savedKey)
    }

    private func mice() -> [IOHIDServiceClient] {
        guard let client, let services = IOHIDEventSystemClientCopyServices(client) as? [IOHIDServiceClient] else { return [] }
        return services.filter {
            IOHIDServiceClientConformsTo($0, UInt32(kHIDPage_GenericDesktop), UInt32(kHIDUsage_GD_Mouse)) != 0
                && IOHIDServiceClientConformsTo($0, UInt32(kHIDPage_Digitizer), UInt32(kHIDUsage_Dig_TouchPad)) == 0
                && Self.property($0, "HIDPointerAccelerationType") as? String != "HIDTrackpadAcceleration"
        }
    }

    private func watchDevices() {
        guard port == nil, let port = IONotificationPortCreate(kIOMainPortDefault) else { return }
        self.port = port
        IONotificationPortSetDispatchQueue(port, .main)
        var iterator: io_iterator_t = 0
        let callback: IOServiceMatchingCallback = { refcon, iterator in
            while case let service = IOIteratorNext(iterator), service != 0 { IOObjectRelease(service) }
            guard let refcon else { return }
            let tool = Unmanaged<PointerTool>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { if tool.isEnabled { tool.apply() } }
        }
        IOServiceAddMatchingNotification(port, kIOFirstMatchNotification, IOServiceMatching(kIOHIDDeviceKey), callback, Unmanaged.passUnretained(self).toOpaque(), &iterator)
        while case let service = IOIteratorNext(iterator), service != 0 { IOObjectRelease(service) }
    }

    private func stopWatching() {
        port.map(IONotificationPortDestroy)
        port = nil
    }

    private static func makeClient() -> IOHIDEventSystemClient? {
        typealias Create = @convention(c) (CFAllocator?) -> Unmanaged<IOHIDEventSystemClient>?
        guard let symbol = dlsym(dlopen(nil, RTLD_NOW), "IOHIDEventSystemClientCreate") else { return nil }
        return unsafeBitCast(symbol, to: Create.self)(kCFAllocatorDefault)?.takeRetainedValue()
    }

    private static func property(_ service: IOHIDServiceClient, _ key: String) -> Any? {
        IOHIDServiceClientCopyProperty(service, key as CFString)
    }

    private static func registryID(_ service: IOHIDServiceClient) -> String? {
        (IOHIDServiceClientGetRegistryID(service) as? NSNumber)?.stringValue
    }

    private static func fixed(_ value: Double) -> CFNumber {
        Int32(value * 65536) as CFNumber
    }
}

private struct PointerSettings: View {
    @Bindable var tool: PointerTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("The pointer moves as far as your hand, at any speed. Mouse only."),
            hint: Text("Moves as far as your hand"),
            isOn: $tool.isEnabled
        )
        if inSettings {
            LabeledContent {
                ValueSlider(
                    title: String(localized: "Tracking speed"),
                    value: $tool.speed,
                    range: PointerTool.speedRange,
                    step: 0.1,
                    ticks: 15,
                    digits: 1
                )
            } label: {
                Text("Tracking speed")
                Text("Works while acceleration is off")
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Tracking speed"))
        }
    }
}
