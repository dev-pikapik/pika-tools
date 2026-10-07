import Foundation

@main
enum TestSpeedTest {
    static func parse(_ json: String) -> Result<SpeedResult, SpeedResult.Failure> {
        SpeedResult.parse(Data(json.utf8), date: Date(timeIntervalSince1970: 0))
    }

    static func result(_ json: String) -> SpeedResult {
        guard case .success(let result) = parse(json) else { preconditionFailure(json) }
        return result
    }

    static func failure(_ json: String) -> SpeedResult.Failure? {
        guard case .failure(let failure) = parse(json) else { return nil }
        return failure
    }

    static func speed(_ download: Double, _ upload: Double, rpm: Double = 1500, ping: Double = 20) -> SpeedResult {
        SpeedResult(download: download, upload: upload, rpm: rpm, ping: ping, date: .now)
    }

    static func main() {
        let sequential = result(#"{"base_rtt": 45.8, "dl_throughput": 368199200, "ul_throughput": 344240160, "dl_responsiveness": 335.2, "ul_responsiveness": 372.5, "il_tls_handshake": [107, 96]}"#)
        precondition(abs(sequential.download - 368.1992) < 0.001)
        precondition(abs(sequential.upload - 344.24016) < 0.001)
        precondition(sequential.ping == 45.8)
        precondition(sequential.rpm == 335.2)
        precondition(sequential.responsiveness == .medium)

        let parallel = result(#"{"base_rtt": 12, "dl_throughput": 50000000, "ul_throughput": 10000000, "responsiveness": 1800, "dl_responsiveness": 100}"#)
        precondition(parallel.rpm == 1800 && parallel.responsiveness == .high)
        precondition(parallel.download == 50 && parallel.upload == 10 && parallel.ping == 12)

        precondition(failure(#"{"error_code": -1009, "error_domain": "NSURLErrorDomain"}"#) == .offline)
        precondition(failure(#"{"error_code": -1003, "error_domain": "NSURLErrorDomain"}"#) == .offline)
        precondition(failure(#"{"error_code": -1100, "error_domain": "NSURLErrorDomain"}"#) == .failed)
        precondition(failure(#"{"base_rtt": 40, "dl_throughput": 1000}"#) == .failed)
        precondition(failure("") == .failed)
        precondition(failure("not json") == .failed)

        precondition(speed(1, 1, rpm: 299).responsiveness == .low)
        precondition(speed(1, 1, rpm: 300).responsiveness == .medium)
        precondition(speed(1, 1, rpm: 999).responsiveness == .medium)
        precondition(speed(1, 1, rpm: 1000).responsiveness == .high)

        precondition(speed(25, 1).isGood(for: .video))
        precondition(!speed(24.9, 100).isGood(for: .video))
        precondition(speed(4, 3).isGood(for: .calls))
        precondition(!speed(100, 2.9).isGood(for: .calls))
        precondition(!speed(3.9, 100).isGood(for: .calls))
        precondition(!speed(100, 100, ping: 151).isGood(for: .calls))
        precondition(speed(5, 1, rpm: 300, ping: 80).isGood(for: .games))
        precondition(!speed(500, 500, rpm: 299, ping: 10).isGood(for: .games))
        precondition(!speed(500, 500, rpm: 2000, ping: 81).isGood(for: .games))
        precondition(speed(100, 1).isGood(for: .downloads))
        precondition(!speed(99, 1000).isGood(for: .downloads))
        precondition(SpeedResult.Activity.allCases.allSatisfy { speed(1000, 1000).isGood(for: $0) })
        precondition(!SpeedResult.Activity.allCases.contains { speed(1, 1, rpm: 100, ping: 300).isGood(for: $0) })
        precondition(speed(100, 1).bigDownloadTime == 800)
        precondition(speed(0, 0).bigDownloadTime.isFinite)

        let start = SpeedResult.progress("\r\u{1b}[2K\rDownlink: 0.000 Mbps, 0 RPM - Uplink: 0.000 Mbps, 0 RPM")
        precondition(start?.download == 0 && start?.upload == 0)
        let down = SpeedResult.progress("\r\u{1b}[2K\rDownlink: 200.000 Mbps, 430 RPM - Uplink: 0.000 Mbps, 0 RPM\r\u{1b}[2K\rDownlink: 351.243 Mbps, 323 RPM - Uplink: 0.000 Mbps, 0 RPM")
        precondition(abs(down!.download - 368.3) < 0.1 && down!.upload == 0)
        let up = SpeedResult.progress("\r\u{1b}[2K\rDownlink: 351.243 Mbps, 323 RPM - Uplink: 20.227 Mbps, 678 RPM")
        precondition(abs(up!.upload - 21.2) < 0.1)
        precondition(SpeedResult.progress("\r\u{1b}[2K\rDownlink: 351.243 Mbps, 323 RPM - Upl") == nil)
        precondition(SpeedResult.progress("==== SUMMARY ====\r\nUplink capacity: 291.179 Mbps\r\nDownlink capacity: 351.243 Mbps\r\n") == nil)

        let stored = speed(368.2, 344.2, rpm: 335, ping: 45.8)
        precondition(try! JSONDecoder().decode(SpeedResult.self, from: JSONEncoder().encode(stored)) == stored)
        print("speed-test: ok")
    }
}
