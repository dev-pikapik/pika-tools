#if APPSTORE
import Foundation

enum SpeedMeasure {
    private static let host = "https://speed.cloudflare.com/"
    private static let warmUp = 1.5, duration = 6.0

    static func run(_ report: @MainActor (SpeedTest.Phase, (download: Double, upload: Double)) -> Void) async throws -> SpeedResult {
        let probe = Probe()
        defer { probe.session.invalidateAndCancel() }
        let ping = try await probe.idle()
        await report(.starting, (0, 0))

        let download = Load(upload: false)
        let down = try await measure(download, probe) { await report(.download, ($0, 0)) }
        let upload = Load(upload: true)
        let up = try await measure(upload, probe) { await report(.upload, (down.speed, $0)) }

        let loaded = (down.latency + up.latency).sorted()
        let latency = loaded.isEmpty ? ping : loaded[loaded.count / 2]
        return SpeedResult(download: down.speed, upload: up.speed, rpm: 60_000 / max(latency, 1), ping: ping, date: .now)
    }

    private static func measure(_ load: Load, _ probe: Probe, live: (Double) async -> Void) async throws -> (speed: Double, latency: [Double]) {
        defer { load.stop() }
        load.start()
        var latency: [Double] = []
        var window: [(Date, Int)] = []
        var mark: (Date, Int)?
        let begin = Date()
        let side = Task { () -> [Double] in
            var found: [Double] = []
            while !Task.isCancelled {
                if let ms = try? await probe.ping() { found.append(ms) }
            }
            return found
        }
        defer { side.cancel() }
        while Date().timeIntervalSince(begin) < warmUp + duration {
            try await Task.sleep(for: .milliseconds(250))
            let now = (Date(), load.bytes)
            window.append(now)
            window.removeAll { now.0.timeIntervalSince($0.0) > 1.2 }
            if let first = window.first, now.0 > first.0 { await live(rate(from: first, to: now)) }
            if mark == nil, now.0.timeIntervalSince(begin) >= warmUp { mark = now }
        }
        guard let mark, load.failures < 4 else { throw URLError(.cannotConnectToHost) }
        let end = (Date(), load.bytes)
        side.cancel()
        latency = await side.value
        let speed = rate(from: mark, to: end)
        guard speed > 0 else { throw URLError(.cannotConnectToHost) }
        await live(speed)
        return (speed, latency)
    }

    private static func rate(from: (Date, Int), to: (Date, Int)) -> Double {
        Double(to.1 - from.1) * 8 / 1_000_000 / max(to.0.timeIntervalSince(from.0), 0.001)
    }

    private final class Probe {
        let session = URLSession(configuration: .ephemeral)

        func ping() async throws -> Double {
            let clock = ContinuousClock()
            let start = clock.now
            let (_, response) = try await session.data(from: URL(string: host + "__down?bytes=0")!)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            let time = start.duration(to: clock.now).components
            return Double(time.seconds) * 1000 + Double(time.attoseconds) / 1e15
        }

        func idle() async throws -> Double {
            _ = try await ping()
            var best = Double.infinity
            for _ in 0..<8 { best = min(best, try await ping()) }
            return best
        }
    }

    private final class Load: NSObject, URLSessionDataDelegate {
        private let upload: Bool
        private let lock = NSLock()
        private var total = 0, failed = 0, active = true
        private lazy var session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        private static let payload = Data(count: 8_000_000)

        init(upload: Bool) {
            self.upload = upload
        }

        var bytes: Int { lock.withLock { total } }
        var failures: Int { lock.withLock { failed } }

        func start() {
            (0..<4).forEach { _ in launch() }
        }

        func stop() {
            lock.withLock { active = false }
            session.invalidateAndCancel()
        }

        private func launch() {
            if upload {
                var request = URLRequest(url: URL(string: host + "__up")!)
                request.httpMethod = "POST"
                session.uploadTask(with: request, from: Self.payload).resume()
            } else {
                session.dataTask(with: URL(string: host + "__down?bytes=50000000")!).resume()
            }
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            lock.withLock { total += data.count }
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
            lock.withLock { total += Int(bytesSent) }
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            let again = lock.withLock { () -> Bool in
                if error != nil { failed += 1 }
                return active && failed < 4
            }
            if again { launch() }
        }
    }
}
#endif
