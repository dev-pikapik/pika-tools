import CoreAudio
import Foundation

@main
enum TestAppVolume {
    typealias Shape = (channels: Int, frames: Int)

    static func make(_ shapes: [Shape], _ value: (Int, Int, Int) -> Float = { _, _, _ in 0 }) -> UnsafeMutableAudioBufferListPointer {
        let list = AudioBufferList.allocate(maximumBuffers: shapes.count)
        for (index, shape) in shapes.enumerated() {
            guard shape.frames > 0 else {
                list[index] = AudioBuffer(mNumberChannels: UInt32(shape.channels), mDataByteSize: 0, mData: nil)
                continue
            }
            let data = UnsafeMutablePointer<Float>.allocate(capacity: shape.channels * shape.frames)
            for frame in 0..<shape.frames {
                for channel in 0..<shape.channels { data[frame * shape.channels + channel] = value(index, frame, channel) }
            }
            list[index] = AudioBuffer(mNumberChannels: UInt32(shape.channels), mDataByteSize: UInt32(shape.channels * shape.frames * 4), mData: data)
        }
        return list
    }

    static func at(_ list: UnsafeMutableAudioBufferListPointer, _ buffer: Int, _ frame: Int, _ channel: Int) -> Float {
        list[buffer].mData!.assumingMemoryBound(to: Float.self)[frame * Int(list[buffer].mNumberChannels) + channel]
    }

    static func run(_ tap: UnsafeMutableAudioBufferListPointer, _ out: UnsafeMutableAudioBufferListPointer, _ state: AppVolumeGain) {
        AppVolumeMath.render(tap: tap.unsafePointer, output: out.unsafeMutablePointer, state: state)
    }

    static func left(_ frame: Int) -> Float { Float(frame + 1) / 100 }
    static func right(_ frame: Int) -> Float { -Float(frame + 1) / 200 }

    static func put(_ ring: AppVolumeRing, from first: Int, count: Int) {
        let left = (0..<count).map { Float(first + $0 + 1) }
        let right = left.map { -$0 }
        left.withUnsafeBufferPointer { left in
            right.withUnsafeBufferPointer { right in
                _ = ring.write(left: left.baseAddress!, leftStep: 1, right: right.baseAddress!, rightStep: 1, frames: count)
            }
        }
    }

    static func take(_ ring: AppVolumeRing, _ frames: Int) -> [Int] {
        let list = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: ring.pull(frames: frames)))
        let count = Int(list[0].mDataByteSize) / 8
        guard count > 0, let data = list[0].mData?.assumingMemoryBound(to: Float.self) else { return [] }
        precondition((0..<count).allSatisfy { data[$0 * 2 + 1] == -data[$0 * 2] })
        return (0..<count).map { Int(data[$0 * 2]) }
    }

    struct Trace {
        var first = 0
        var full = 0
        var short = 0
        var jumps = 0
        var worst = 0
    }

    static func simulate(capture: Int, playback: Int, phase: Double, writerPeriod: Double = 1, seconds: Double = 2) -> Trace {
        let ring = AppVolumeRing()
        var trace = Trace()
        var writer = 0.0
        var reader = phase
        var written = 0
        var last = 0
        var playing = false
        while min(writer, reader) < 48000 * seconds {
            if writer <= reader {
                put(ring, from: written, count: capture)
                written += capture
                writer += Double(capture) * writerPeriod
                continue
            }
            reader += Double(playback)
            let got = take(ring, playback)
            if let first = got.first {
                if trace.first == 0 {
                    trace.first = first
                    last = first - 1
                }
                if first != last + 1 { trace.jumps += 1 }
                last = got.last!
            }
            if got.count == playback {
                playing = true
                trace.full += 1
                trace.worst = max(trace.worst, written - last)
            } else if playing {
                playing = false
                trace.short += 1
            }
        }
        return trace
    }

    static func main() {
        precondition(AppVolumeMath.gain(slider: 1, muted: false) == 1)
        precondition(AppVolumeMath.gain(slider: 0.5, muted: false) == 0.25)
        precondition(AppVolumeMath.gain(slider: 0, muted: false) == 0)
        precondition(AppVolumeMath.gain(slider: 0.8, muted: true) == 0)
        precondition(AppVolumeMath.gain(slider: 3, muted: false) == 1 && AppVolumeMath.gain(slider: -1, muted: false) == 0)
        precondition(AppVolumeMath.level(slider: 0.5) == 0.5 && AppVolumeMath.level(slider: -1) == 0)
        precondition(AppVolumeMath.level(slider: 0.96) == nil && AppVolumeMath.level(slider: 1) == nil)

        let rate = AppVolumeMath.smoothing(sampleRate: 48000)
        precondition(rate > 0.00069 && rate < 0.00070, "\(rate)")
        precondition(AppVolumeMath.smoothing(sampleRate: 96000) < rate && AppVolumeMath.smoothing(sampleRate: 44100) > rate)

        let steady = AppVolumeGain(target: 0.25, sampleRate: 48000)
        let stereo = make([(2, 64)]) { _, frame, channel in channel == 0 ? left(frame) : right(frame) }
        var out = make([(2, 64)]) { _, _, _ in 9 }
        run(stereo, out, steady)
        for frame in 0..<64 {
            precondition(at(out, 0, frame, 0) == left(frame) * 0.25 && at(out, 0, frame, 1) == right(frame) * 0.25)
        }
        let peaks = steady.takePeaks()
        precondition(peaks.input == 0.64 && abs(peaks.output - 0.16) < 1e-6, "\(peaks)")
        precondition(steady.takePeaks() == (0, 0))

        let unity = AppVolumeGain(target: 1, sampleRate: 48000)
        run(stereo, out, unity)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == left($0) && at(out, 0, $0, 1) == right($0) })

        let silent = AppVolumeGain(target: 0, sampleRate: 48000)
        run(stereo, out, silent)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == 0 && at(out, 0, $0, 1) == 0 })

        let split = make([(1, 64), (1, 64)]) { buffer, frame, _ in buffer == 0 ? left(frame) : right(frame) }
        out = make([(2, 64)]) { _, _, _ in 9 }
        run(split, out, steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == left($0) * 0.25 && at(out, 0, $0, 1) == right($0) * 0.25 })

        let microphone = make([(1, 0), (1, 64), (1, 64)]) { buffer, frame, _ in buffer == 1 ? left(frame) : right(frame) }
        run(microphone, out, steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == left($0) * 0.25 && at(out, 0, $0, 1) == right($0) * 0.25 })

        let twoStreams = make([(2, 0), (2, 64)]) { _, frame, channel in channel == 0 ? left(frame) : right(frame) }
        run(twoStreams, out, steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == left($0) * 0.25 && at(out, 0, $0, 1) == right($0) * 0.25 })

        let single = make([(1, 64)]) { _, frame, _ in left(frame) }
        run(single, out, steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == left($0) * 0.25 && at(out, 0, $0, 1) == left($0) * 0.25 })

        let mono = make([(1, 64)]) { _, _, _ in 9 }
        run(stereo, mono, steady)
        precondition((0..<64).allSatisfy { abs(at(mono, 0, $0, 0) - (left($0) + right($0)) * 0.5 * 0.25) < 1e-7 })
        run(single, mono, steady)
        precondition((0..<64).allSatisfy { abs(at(mono, 0, $0, 0) - left($0) * 0.25) < 1e-7 })

        let wide = make([(4, 64), (2, 64)]) { _, _, _ in 9 }
        run(stereo, wide, steady)
        precondition((0..<64).allSatisfy {
            at(wide, 0, $0, 0) == left($0) * 0.25 && at(wide, 0, $0, 1) == right($0) * 0.25 && at(wide, 0, $0, 2) == 0 && at(wide, 0, $0, 3) == 0
                && at(wide, 1, $0, 0) == 0 && at(wide, 1, $0, 1) == 0
        })

        let planar = make([(1, 64), (1, 64), (1, 64)]) { _, _, _ in 9 }
        run(stereo, planar, steady)
        precondition((0..<64).allSatisfy {
            at(planar, 0, $0, 0) == left($0) * 0.25 && at(planar, 1, $0, 0) == right($0) * 0.25 && at(planar, 2, $0, 0) == 0
        })

        let nothing = make([(2, 0)])
        out = make([(2, 64)]) { _, _, _ in 9 }
        run(nothing, out, steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == 0 && at(out, 0, $0, 1) == 0 })

        let short = make([(2, 16)]) { _, frame, channel in channel == 0 ? left(frame) : right(frame) }
        run(short, out, steady)
        precondition((0..<16).allSatisfy { at(out, 0, $0, 0) == left($0) * 0.25 } && (16..<64).allSatisfy { at(out, 0, $0, 0) == 0 && at(out, 0, $0, 1) == 0 })
        let small = make([(2, 8)]) { _, _, _ in 9 }
        run(stereo, small, steady)
        precondition((0..<8).allSatisfy { at(small, 0, $0, 0) == left($0) * 0.25 })

        let ones = make([(2, 1440)]) { _, _, _ in 1 }
        out = make([(2, 1440)])
        let ramp = AppVolumeGain(target: 1, sampleRate: 48000)
        ramp.target = 0
        run(ones, out, ramp)
        precondition(at(out, 0, 0, 0) < 1 && at(out, 0, 0, 0) > 0.999)
        precondition((1..<1440).allSatisfy { at(out, 0, $0, 0) <= at(out, 0, $0 - 1, 0) && at(out, 0, $0, 0) == at(out, 0, $0, 1) })
        precondition(abs(ramp.current - exp(-1)) < 0.005 && abs(at(out, 0, 1439, 0) - ramp.current) < 1e-6, "\(ramp.current)")
        for _ in 0..<40 { run(ones, out, ramp) }
        precondition(ramp.current == 0 && at(out, 0, 1439, 0) == 0)
        ramp.target = 0.25
        for _ in 0..<40 { run(ones, out, ramp) }
        precondition(ramp.current == 0.25 && at(out, 0, 1439, 1) == 0.25)

        let ring = AppVolumeRing(capacity: 1024, ceiling: 512, margin: 64)
        put(ring, from: 0, count: 100)
        precondition(take(ring, 100).isEmpty)
        put(ring, from: 100, count: 100)
        precondition(take(ring, 100).isEmpty)
        put(ring, from: 200, count: 100)
        var next = 1
        for step in 0..<60 {
            precondition(take(ring, 100) == Array(next..<next + 100), "wrap \(step)")
            next += 100
            put(ring, from: 300 + step * 100, count: 100)
        }
        precondition(take(ring, 200) == Array(next..<next + 200))
        precondition(take(ring, 200) == Array(next + 200..<next + 300))
        precondition(take(ring, 200).isEmpty)
        put(ring, from: 6300, count: 100)
        precondition(take(ring, 100).isEmpty)
        put(ring, from: 6400, count: 100)
        precondition(take(ring, 100).isEmpty)
        put(ring, from: 6500, count: 100)
        precondition(take(ring, 100) == Array(6301..<6401))

        let late = AppVolumeRing(capacity: 1024, ceiling: 512, margin: 64)
        for index in 0..<10 { put(late, from: index * 100, count: 100) }
        precondition(take(late, 100) == Array(737..<837))
        put(late, from: 1000, count: 100)
        precondition(take(late, 100) == Array(837..<937))
        late.reset()
        precondition(take(late, 100).isEmpty)

        let flood = AppVolumeRing(capacity: 1024, ceiling: 512, margin: 64)
        for index in 0..<15 { put(flood, from: index * 100, count: 100) }
        precondition(take(flood, 100) == Array(1237..<1337))

        func captured(_ layout: UnsafeMutableAudioBufferListPointer, _ expectLeft: (Int) -> Float, _ expectRight: (Int) -> Float) {
            let ring = AppVolumeRing(capacity: 1024, ceiling: 512, margin: 0)
            let state = AppVolumeGain(target: 0.25, sampleRate: 48000)
            AppVolumeMath.capture(tap: layout.unsafePointer, ring: ring, state: state)
            AppVolumeMath.capture(tap: layout.unsafePointer, ring: ring, state: state)
            precondition(state.takePeaks().input == 0.64)
            let played = make([(2, 32)]) { _, _, _ in 9 }
            AppVolumeMath.render(tap: ring.pull(frames: 32), output: played.unsafeMutablePointer, state: state)
            precondition((0..<32).allSatisfy { at(played, 0, $0, 0) == expectLeft($0) * 0.25 && at(played, 0, $0, 1) == expectRight($0) * 0.25 })
        }
        captured(stereo, left, right)
        captured(split, left, right)
        captured(microphone, left, right)
        captured(twoStreams, left, right)
        captured(single, left, left)

        let empty = AppVolumeGain(target: 0, sampleRate: 48000)
        AppVolumeMath.capture(tap: nothing.unsafePointer, ring: AppVolumeRing(), state: empty)
        precondition(empty.takePeaks() == (0, 0))
        let idle = AppVolumeRing()
        out = make([(2, 64)]) { _, _, _ in 9 }
        AppVolumeMath.render(tap: idle.pull(frames: 64), output: out.unsafeMutablePointer, state: steady)
        precondition((0..<64).allSatisfy { at(out, 0, $0, 0) == 0 && at(out, 0, $0, 1) == 0 })

        for (capture, playback) in [(512, 512), (480, 512), (512, 480), (256, 1024), (1024, 256), (480, 480), (1156, 512)] {
            for phase in [0, 1, capture / 2, playback - 1].map(Double.init) {
                let trace = simulate(capture: capture, playback: playback, phase: phase)
                precondition(trace.short == 0 && trace.jumps == 0 && trace.first == 1 && trace.worst <= 4096 && trace.full >= 80, "\(capture) \(playback) \(phase) \(trace)")
            }
        }
        let fast = simulate(capture: 512, playback: 512, phase: 0, writerPeriod: 0.99, seconds: 20)
        precondition(fast.short == 0 && fast.jumps >= 2 && fast.worst <= 4096 && fast.full >= 1800, "\(fast)")
        let slow = simulate(capture: 512, playback: 512, phase: 0, writerPeriod: 1.01, seconds: 20)
        precondition(slow.short >= 2 && slow.jumps == 0 && slow.full >= 1700, "\(slow)")

        let apps: [AppVolumeMath.RunningApp] = [
            ("com.google.Chrome", "Google Chrome", "/Applications/Google Chrome.app"),
            ("com.google.Chrome.canary", "Google Chrome Canary", "/Applications/Google Chrome Canary.app"),
            ("com.spotify.client", "Spotify", "/Applications/Spotify.app"),
            ("com.apple.Safari", "Safari", "/Applications/Safari.app"),
            ("com.example.go", "Go", "/Applications/Go.app"),
            ("com.apple.Terminal", "Terminal", "/System/Applications/Utilities/Terminal.app"),
        ]
        func owner(_ path: String?, _ id: String?, _ name: String?, _ ancestors: [String] = []) -> AppVolumeOwner? {
            AppVolumeMath.resolveOwner(processPath: path, processBundleID: id, processName: name, runningApps: apps, ancestorPaths: ancestors)
        }
        let chrome = AppVolumeOwner(key: "com.google.Chrome", name: "Google Chrome", bundlePath: "/Applications/Google Chrome.app")
        let helper = "/Applications/Google Chrome.app/Contents/Frameworks/Google Chrome Framework.framework/Versions/1/Helpers/Google Chrome Helper.app/Contents/MacOS/Google Chrome Helper"
        precondition(AppVolumeMath.outermostApp(helper) == "/Applications/Google Chrome.app")
        precondition(AppVolumeMath.outermostApp("/usr/libexec/coreaudiod") == nil)
        precondition(owner(helper, "com.google.Chrome.helper", "Google Chrome Helper") == chrome)
        precondition(owner(helper, nil, nil) == chrome)
        precondition(owner("/Applications/Old Thing.app/Contents/MacOS/x", "com.old.thing", "x")
            == AppVolumeOwner(key: "/Applications/Old Thing.app", name: "Old Thing", bundlePath: "/Applications/Old Thing.app"))
        precondition(owner(nil, "com.google.Chrome.helper", "other") == chrome)
        precondition(owner(nil, "com.google.Chrome.canary.helper", nil)?.key == "com.google.Chrome.canary")
        precondition(owner(nil, "com.google.Chromeless", nil) == nil)
        precondition(owner("/usr/libexec/helper", nil, "Spotify Helper (Renderer)")?.key == "com.spotify.client")
        precondition(owner(nil, nil, "Google Chrome Canary Helper")?.key == "com.google.Chrome.canary")
        precondition(owner(nil, nil, "Google Chrome Helper")?.name == "Google Chrome")
        precondition(owner(nil, nil, "Gopher") == nil)
        precondition(owner("/usr/libexec/coreaudio-helper", "com.example.daemon", "daemon") == nil)
        precondition(owner(nil, nil, "daemon") == nil)
        precondition(owner("/System/Library/Frameworks/WebKit.framework/XPCServices/com.apple.WebKit.GPU.xpc/Contents/MacOS/com.apple.WebKit.GPU",
                           "com.apple.WebKit.GPU", "com.apple.WebKit.GPU") == nil)
        precondition(owner(nil, nil, nil) == nil)

        let terminal = "/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal"
        let shells = ["/bin/zsh", "/usr/bin/login"]
        precondition(owner("/usr/bin/afplay", nil, "afplay", shells + [terminal])?.name == "Terminal")
        precondition(owner("/usr/bin/afplay", nil, "afplay", shells + [terminal])?.key == "com.apple.Terminal")
        precondition(owner("/usr/bin/afplay", nil, "afplay", shells + ["/Applications/Old Thing.app/Contents/MacOS/x", terminal])
            == AppVolumeOwner(key: "/Applications/Old Thing.app", name: "Old Thing", bundlePath: "/Applications/Old Thing.app"))
        precondition(owner("/usr/bin/afplay", nil, "afplay", shells) == nil)
        precondition(owner("/usr/sbin/coreaudiod", nil, "coreaudiod") == nil)
        precondition(owner(nil, nil, "Safari Graphics and Media", [terminal])?.name == "Safari")
        precondition(owner(helper, nil, nil, [terminal]) == chrome)

        let files = FileManager.default
        let folder = files.temporaryDirectory.appendingPathComponent("pika-app-volume-\(getpid())")
        defer { try? files.removeItem(at: folder) }
        func bundle(_ name: String, _ id: String, in parent: String = "Apps") -> AppVolumeOwner {
            let path = folder.appendingPathComponent(parent).appendingPathComponent("\(name).app")
            try! files.createDirectory(at: path.appendingPathComponent("Contents"), withIntermediateDirectories: true)
            let info: NSDictionary = ["CFBundleIdentifier": id, "CFBundleName": name, "CFBundlePackageType": "APPL"]
            precondition(info.write(to: path.appendingPathComponent("Contents/Info.plist"), atomically: true))
            return AppVolumeOwner(key: id, name: name, bundlePath: path.path)
        }
        let player = bundle("Player", "com.example.player")
        let twin = bundle("Player", "com.example.player.beta", in: "Downloads")
        let agent = bundle("Agent", "com.example.agent")
        precondition(AppVolumeMath.canonical(player.bundlePath!) == "com.example.player")
        precondition(AppVolumeMath.canonical("/Applications/Missing.app") == "/Applications/Missing.app")
        precondition(AppVolumeMath.canonical("com.example.player") == "com.example.player")
        precondition(owner(player.bundlePath! + "/Contents/MacOS/x", nil, "x") == AppVolumeOwner(key: "com.example.player", name: "Player", bundlePath: player.bundlePath))

        let suite = "pikapik.test.app-volume"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }
        var memory = AppVolumeMemory(defaults)
        precondition(memory.keys.isEmpty && memory.level(player.key) == 1)
        memory.setLevel(0.4, for: player)
        memory.toggleMute(agent)
        memory.remember(twin)
        memory.save(to: defaults)
        var again = AppVolumeMemory(defaults)
        precondition(again == memory && again.level(player.key) == 0.4 && again.muted == [agent.key])
        precondition(again.keys == [player.key, agent.key, twin.key] && again.names[twin.key] == "Player")
        again.setLevel(0.97, for: player)
        precondition(again.levels[player.key] == nil && again.keys.contains(player.key))
        again.toggleMute(agent)
        precondition(again.muted.isEmpty)
        again.forget(player.key)
        again.forget(twin.key)
        again.save(to: defaults)
        again = AppVolumeMemory(defaults)
        precondition(again.keys == [agent.key] && again.level(player.key) == 1 && again.level(agent.key) == 1)
        again.forget(agent.key)
        again.save(to: defaults)
        precondition(AppVolumeMemory(defaults).keys.isEmpty)

        defaults.set([player.bundlePath!: 0.3, "/Applications/Missing.app": 0.5, "com.example.agent": 2.0, "com.example.up": 1.0], forKey: "app-volume-levels")
        defaults.set([agent.bundlePath!], forKey: "app-volume-muted")
        let old = AppVolumeMemory(defaults)
        precondition(old.levels == [player.key: 0.3, "/Applications/Missing.app": 0.5] && old.muted == [agent.key], "\(old)")
        precondition(old.keys == [player.key, agent.key, "/Applications/Missing.app"])

        let live = [AppVolumeRow(owner: player, playing: true), AppVolumeRow(owner: AppVolumeOwner(key: "z", name: "Zed", bundlePath: nil), playing: false)]
        let shown = AppVolumeMath.rows(live: live, remembered: [agent, player, AppVolumeOwner(key: "gone", name: "Bonus", bundlePath: nil)])
        precondition(shown.map(\.owner.key) == ["com.example.agent", "gone", "com.example.player", "z"], "\(shown)")
        precondition(shown.map(\.playing) == [false, false, true, false] && shown.allSatisfy { $0.place == nil })
        let pair = AppVolumeMath.rows(live: live, remembered: [twin, AppVolumeOwner(key: "gone", name: "Player", bundlePath: nil)])
        precondition(pair.map(\.title) == ["Player (Apps)", "Player (Downloads)", "Player (gone)", "Zed"], "\(pair)")
        precondition(pair.filter { $0.owner.name == "Player" }.count == 3)
        print("app-volume: ok")
    }
}
