import CoreAudio
import Foundation

struct PlayerOutput: Equatable {
    let uid: String
    let name: String

    static func all() -> [PlayerOutput] {
        let system = AudioObjectID(kAudioObjectSystemObject)
        var address = address(kAudioHardwarePropertyDevices)
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(system, &address, 0, nil, &size) == noErr else { return [] }
        var devices = [AudioObjectID](repeating: 0, count: Int(size) / MemoryLayout<AudioObjectID>.size)
        guard AudioObjectGetPropertyData(system, &address, 0, nil, &size, &devices) == noErr else { return [] }
        return devices.compactMap(output)
    }

    static func system() -> String? {
        var address = address(kAudioHardwarePropertyDefaultOutputDevice)
        var device = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &device) == noErr, device != kAudioObjectUnknown else { return nil }
        return string(device, kAudioDevicePropertyDeviceUID)
    }

    static func watch(_ changed: @escaping () -> Void) {
        for selector in [kAudioHardwarePropertyDevices, kAudioHardwarePropertyDefaultOutputDevice] {
            var address = address(selector)
            AudioObjectAddPropertyListenerBlock(AudioObjectID(kAudioObjectSystemObject), &address, .main) { _, _ in changed() }
        }
    }

    static func choice(_ chosen: String?, among outputs: [PlayerOutput]) -> String? {
        outputs.contains { $0.uid == chosen } ? chosen : nil
    }

    private static func address(_ selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
    }

    private static func output(_ device: AudioObjectID) -> PlayerOutput? {
        var streams = address(kAudioDevicePropertyStreams, scope: kAudioDevicePropertyScopeOutput)
        var size: UInt32 = 0
        var hidden: UInt32 = 0
        var hiddenSize = UInt32(MemoryLayout<UInt32>.size)
        var hiddenAddress = address(kAudioDevicePropertyIsHidden)
        guard AudioObjectGetPropertyDataSize(device, &streams, 0, nil, &size) == noErr, size > 0,
              AudioObjectGetPropertyData(device, &hiddenAddress, 0, nil, &hiddenSize, &hidden) != noErr || hidden == 0,
              let uid = string(device, kAudioDevicePropertyDeviceUID), let name = string(device, kAudioObjectPropertyName) else { return nil }
        return PlayerOutput(uid: uid, name: name)
    }

    private static func string(_ device: AudioObjectID, _ selector: AudioObjectPropertySelector) -> String? {
        var address = address(selector)
        var size = UInt32(MemoryLayout<CFString?>.size)
        var value: CFString?
        let status = withUnsafeMutablePointer(to: &value) { AudioObjectGetPropertyData(device, &address, 0, nil, &size, $0) }
        return status == noErr ? value as String? : nil
    }
}
