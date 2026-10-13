import AVFoundation
import CoreAudio
import os

@available(macOS 14.2, *)
final class AudioCaptureProbe: @unchecked Sendable {
    static let shared = AudioCaptureProbe()

    private let queue = DispatchQueue(label: "pikapik.audio-capture-probe", qos: .userInitiated)
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "pikapik", category: "app-volume")
    private var lastRun = Date.distantPast
    private var lastSilence = Date.distantPast
    private var retryUntil = Date.distantPast
    private var retrying = false

    private init() {}

    func check() {
        let permissions = Permissions.shared
        guard permissions.systemAudioAsked, AppVolumeTool.shared.isEnabled, !permissions.systemAudio || SettingsWindow.window?.isVisible == true else { return }
        queue.async { [self] in
            guard Date().timeIntervalSince(lastRun) >= 3 else { return }
            attempt(openingSettings: nil)
        }
    }

    func checkSilence() {
        guard Permissions.shared.systemAudioAsked, AppVolumeTool.shared.isEnabled else { return }
        queue.async { [self] in
            guard Date().timeIntervalSince(lastSilence) >= 60 else { return }
            lastSilence = Date()
            attempt(openingSettings: nil)
        }
    }

    func allow(opening settings: (() -> Void)?) {
        queue.async { [self] in
            retryUntil = Date().addingTimeInterval(120)
            attempt(openingSettings: settings)
        }
    }

    private func attempt(openingSettings settings: (() -> Void)?) {
        lastRun = Date()
        let granted = run()
        log.debug("probe granted=\(granted.map(String.init) ?? "unknown")")
        DispatchQueue.main.async {
            if let granted { Permissions.shared.setSystemAudio(granted) }
            if granted == false { settings?() }
        }
        guard granted != true, Date() < retryUntil, !retrying else { return }
        retrying = true
        queue.asyncAfter(deadline: .now() + 1.5) { [self] in
            retrying = false
            attempt(openingSettings: nil)
        }
    }

    static func tone(on output: AppVolumeOutput) -> AUAudioUnit? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: output.rate, channels: 2),
              let unit = try? AppVolumeChain.playback(on: output, format: format.streamDescription.pointee, provider: { _, _, frames, _, list in
                  for buffer in UnsafeMutableAudioBufferListPointer(list) {
                      guard let data = buffer.mData?.assumingMemoryBound(to: Float.self) else { continue }
                      for frame in 0..<Int(frames) { data[frame] = frame & 8 == 0 ? 1e-5 : -1e-5 }
                  }
                  return noErr
              })
        else { return nil }
        do { try unit.startHardware() } catch {
            unit.deallocateRenderResources()
            return nil
        }
        return unit
    }

    private func run() -> Bool? {
        guard let output = AppVolumeOutput.current(), let tone = Self.tone(on: output) else { return nil }
        defer {
            tone.stopHardware()
            tone.deallocateRenderResources()
        }

        var process = AppVolumeHAL.processObject(pid: getpid())
        for _ in 0..<10 where process == nil {
            Thread.sleep(forTimeInterval: 0.03)
            process = AppVolumeHAL.processObject(pid: getpid())
        }
        guard let process else { return nil }

        let chain: AppVolumeChain
        do {
            chain = try AppVolumeChain.make(process: process, name: "pikapik probe", output: nil, mute: .unmuted, target: 0)
        } catch {
            log.debug("probe chain failed \(String(describing: error))")
            return nil
        }
        defer { chain.destroy() }
        do { try chain.start() } catch { return nil }

        for _ in 0..<12 {
            Thread.sleep(forTimeInterval: 0.05)
            if chain.gain.takePeaks().input > 0 { return true }
        }
        return false
    }
}
