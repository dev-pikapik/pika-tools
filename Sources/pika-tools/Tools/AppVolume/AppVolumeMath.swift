import CoreAudio
import Foundation
import os

struct AppVolumeOwner: Equatable, Sendable {
    let key: String
    let name: String
    let bundlePath: String?
}

struct AppVolumeRow: Equatable, Sendable {
    let owner: AppVolumeOwner
    let playing: Bool
}

final class AppVolumeGain: @unchecked Sendable {
    private let cells = UnsafeMutablePointer<Float>.allocate(capacity: 5)

    init(target: Float, sampleRate: Double) {
        cells.initialize(repeating: 0, count: 5)
        cells[0] = target
        cells[1] = target
        cells[4] = AppVolumeMath.smoothing(sampleRate: sampleRate)
    }

    deinit { cells.deallocate() }

    var target: Float {
        get { cells[0] }
        set { cells[0] = newValue }
    }

    var current: Float {
        get { cells[1] }
        set { cells[1] = newValue }
    }

    var smoothing: Float { cells[4] }

    func note(input: Float, output: Float) {
        cells[2] = max(cells[2], input)
        cells[3] = max(cells[3], output)
    }

    func takePeaks() -> (input: Float, output: Float) {
        let peaks = (cells[2], cells[3])
        cells[2] = 0
        cells[3] = 0
        return peaks
    }
}

final class AppVolumeRing: @unchecked Sendable {
    private struct Position {
        var head = 0
        var tail = 0
        var chunk = 0
        var filling = true
    }

    private let samples: UnsafeMutablePointer<Float>
    private let scratch: UnsafeMutablePointer<Float>
    private let list: UnsafeMutablePointer<AudioBufferList>
    private let capacity: Int
    private let ceiling: Int
    private let margin: Int
    private let position = OSAllocatedUnfairLock(initialState: Position())

    init(capacity: Int = 16384, ceiling: Int = 4096, margin: Int = 512) {
        precondition(capacity > 0 && capacity & (capacity - 1) == 0)
        self.capacity = capacity
        self.ceiling = ceiling
        self.margin = margin
        samples = .allocate(capacity: capacity * 2)
        samples.initialize(repeating: 0, count: capacity * 2)
        scratch = .allocate(capacity: capacity * 2)
        scratch.initialize(repeating: 0, count: capacity * 2)
        list = .allocate(capacity: 1)
        list.initialize(to: AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(mNumberChannels: 2, mDataByteSize: 0, mData: scratch)))
    }

    deinit {
        samples.deallocate()
        scratch.deallocate()
        list.deallocate()
    }

    func reset() {
        position.withLock { $0 = Position() }
    }

    func write(left: UnsafePointer<Float>, leftStep: Int, right: UnsafePointer<Float>, rightStep: Int, frames: Int) -> Float {
        let count = min(frames, capacity)
        let start = position.withLock { position -> Int in
            position.tail = max(position.tail, position.head + count - capacity)
            return position.head
        }
        var peak: Float = 0
        for frame in 0..<count {
            let first = left[frame * leftStep]
            let second = right[frame * rightStep]
            let slot = ((start + frame) * 2) & (capacity * 2 - 1)
            samples[slot] = first
            samples[slot + 1] = second
            peak = max(peak, abs(first), abs(second))
        }
        position.withLock {
            $0.head = start + count
            $0.chunk = count
        }
        return peak
    }

    func pull(frames: Int) -> UnsafePointer<AudioBufferList> {
        let (start, count) = position.withLock { position -> (Int, Int) in
            var available = position.head - position.tail
            let target = position.chunk + frames + margin
            if position.filling {
                guard available >= target else { return (0, 0) }
                position.filling = false
            }
            if available > max(ceiling, 2 * target + position.chunk) {
                position.tail = position.head - target
                available = target
            }
            let count = min(frames, available)
            let start = position.tail
            position.tail += count
            position.filling = count < frames
            return (start, count)
        }
        for index in 0..<count * 2 { scratch[index] = samples[(start * 2 + index) & (capacity * 2 - 1)] }
        list.pointee.mBuffers.mDataByteSize = UInt32(count * 8)
        return UnsafePointer(list)
    }
}

enum AppVolumeMath {
    typealias RunningApp = (bundleID: String, name: String, bundlePath: String)

    static func gain(slider: Double, muted: Bool) -> Float {
        let level = min(max(slider, 0), 1)
        return muted ? 0 : Float(level * level)
    }

    static func level(slider: Double) -> Double? {
        slider < 0.95 ? max(slider, 0) : nil
    }

    static func smoothing(sampleRate: Double) -> Float {
        Float(1 - exp(-1 / (0.03 * max(sampleRate, 1))))
    }

    typealias Stereo = (left: UnsafeMutablePointer<Float>, right: UnsafeMutablePointer<Float>, leftStep: Int, rightStep: Int, frames: Int)

    static func stereo(_ tap: UnsafePointer<AudioBufferList>) -> Stereo? {
        let input = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: tap))
        var last = input.count - 1
        while last >= 0, input[last].mData == nil || input[last].mDataByteSize == 0 { last -= 1 }
        guard last >= 0 else { return nil }
        let buffer = input[last]
        let channels = max(Int(buffer.mNumberChannels), 1)
        let data = buffer.mData!.assumingMemoryBound(to: Float.self)
        var found: Stereo = (data, data, channels, 1, Int(buffer.mDataByteSize) / (MemoryLayout<Float>.size * channels))
        if channels > 1 {
            found.right = data + 1
            found.rightStep = channels
        } else if last > 0, let before = input[last - 1].mData, input[last - 1].mDataByteSize > 0, input[last - 1].mNumberChannels == 1 {
            found.left = before.assumingMemoryBound(to: Float.self)
            found.frames = min(found.frames, Int(input[last - 1].mDataByteSize) / MemoryLayout<Float>.size)
        }
        return found
    }

    static func capture(tap: UnsafePointer<AudioBufferList>, ring: AppVolumeRing, state: AppVolumeGain) {
        guard let found = stereo(tap) else { return }
        state.note(input: ring.write(left: found.left, leftStep: found.leftStep, right: found.right, rightStep: found.rightStep, frames: found.frames), output: 0)
    }

    static func render(tap: UnsafePointer<AudioBufferList>, output: UnsafeMutablePointer<AudioBufferList>, state: AppVolumeGain) {
        let buffers = UnsafeMutableAudioBufferListPointer(output)
        let found = stereo(tap)
        let left = found?.left
        let right = found?.right
        let leftStep = found?.leftStep ?? 1
        let rightStep = found?.rightStep ?? 1
        let frames = found?.frames ?? 0

        var inputPeak: Float = 0
        if let left, let right {
            for frame in 0..<frames { inputPeak = max(inputPeak, abs(left[frame * leftStep]), abs(right[frame * rightStep])) }
        }

        var total = 0
        for index in 0..<buffers.count where buffers[index].mData != nil { total += Int(buffers[index].mNumberChannels) }
        let mono = total == 1
        let start = state.current
        let target = state.target
        let rate = state.smoothing
        var finish = start
        var outputPeak: Float = 0
        var channel = 0
        for index in 0..<buffers.count {
            let buffer = buffers[index]
            guard let raw = buffer.mData else { continue }
            let step = max(Int(buffer.mNumberChannels), 1)
            let capacity = Int(buffer.mDataByteSize) / (MemoryLayout<Float>.size * step)
            let data = raw.assumingMemoryBound(to: Float.self)
            for offset in 0..<step {
                let out = data + offset
                var done = 0
                if let left, let right, mono || channel + offset < 2 {
                    done = min(frames, capacity)
                    let first = mono || channel + offset == 0
                    let result = fill(
                        out: out, outStep: step, count: done,
                        a: first ? left : right, aStep: first ? leftStep : rightStep,
                        b: mono ? right : nil, bStep: rightStep,
                        start: start, target: target, rate: rate
                    )
                    finish = result.gain
                    outputPeak = max(outputPeak, result.peak)
                }
                for frame in done..<capacity { out[frame * step] = 0 }
            }
            channel += step
        }
        state.current = finish
        state.note(input: inputPeak, output: outputPeak)
    }

    private static func fill(
        out: UnsafeMutablePointer<Float>, outStep: Int, count: Int,
        a: UnsafeMutablePointer<Float>, aStep: Int, b: UnsafeMutablePointer<Float>?, bStep: Int,
        start: Float, target: Float, rate: Float
    ) -> (gain: Float, peak: Float) {
        var gain = start
        var peak: Float = 0
        for frame in 0..<count {
            gain += (target - gain) * rate
            if abs(target - gain) < 1e-4 { gain = target }
            var sample = a[frame * aStep]
            if let b { sample = (sample + b[frame * bStep]) * 0.5 }
            let result = sample * gain
            out[frame * outStep] = result
            peak = max(peak, abs(result))
        }
        return (gain, peak)
    }

    static func outermostApp(_ path: String) -> String? {
        let parts = path.split(separator: "/")
        guard let end = parts.firstIndex(where: { $0.hasSuffix(".app") }) else { return nil }
        return "/" + parts[...end].joined(separator: "/")
    }

    static func resolveOwner(processPath: String?, processBundleID: String?, processName: String?, runningApps: [RunningApp], ancestorPaths: [String]) -> AppVolumeOwner? {
        func owner(_ app: RunningApp) -> AppVolumeOwner { AppVolumeOwner(key: app.bundleID, name: app.name, bundlePath: app.bundlePath) }
        func inside(_ path: String) -> AppVolumeOwner? {
            guard let app = outermostApp(path) else { return nil }
            if let running = runningApps.first(where: { $0.bundlePath == app }) { return owner(running) }
            let name = app.split(separator: "/").last.map { String($0.dropLast(4)) } ?? app
            return AppVolumeOwner(key: app, name: name, bundlePath: app)
        }
        if let path = processPath, let found = inside(path) { return found }
        if let id = processBundleID,
           let running = runningApps.filter({ id.hasPrefix($0.bundleID + ".") }).max(by: { $0.bundleID.count < $1.bundleID.count }) {
            return owner(running)
        }
        if let name = processName,
           let running = runningApps.filter({ $0.name.count >= 3 && name.contains($0.name) }).max(by: { $0.name.count < $1.name.count }) {
            return owner(running)
        }
        return ancestorPaths.lazy.compactMap(inside).first
    }
}
