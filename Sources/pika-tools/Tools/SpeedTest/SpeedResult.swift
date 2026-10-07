import Foundation

struct SpeedResult: Codable, Equatable {
    enum Failure: Error {
        case offline, failed
    }

    enum Level {
        case low, medium, high
    }

    enum Activity: CaseIterable {
        case video, calls, games, downloads
    }

    static let offlineCodes: Set<Int> = [-1009, -1020, -1005, -1004, -1003]
    static let bigDownload = 80_000.0

    var download: Double
    var upload: Double
    var rpm: Double
    var ping: Double
    var date: Date

    var responsiveness: Level {
        rpm < 300 ? .low : rpm < 1000 ? .medium : .high
    }

    var bigDownloadTime: TimeInterval {
        Self.bigDownload / max(download, 0.1)
    }

    func isGood(for activity: Activity) -> Bool {
        switch activity {
        case .video: download >= 25
        case .calls: download >= 4 && upload >= 3 && ping <= 150
        case .games: ping <= 80 && responsiveness != .low
        case .downloads: download >= 100
        }
    }

    static func parse(_ data: Data, date: Date = .now) -> Result<SpeedResult, Failure> {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return .failure(.failed) }
        if let code = json["error_code"] as? Int {
            return .failure(offlineCodes.contains(code) ? .offline : .failed)
        }
        guard let download = json["dl_throughput"] as? Double,
              let upload = json["ul_throughput"] as? Double,
              let ping = json["base_rtt"] as? Double
        else { return .failure(.failed) }
        let rpm = json["responsiveness"] as? Double
            ?? ["dl_responsiveness", "ul_responsiveness"].compactMap { json[$0] as? Double }.min()
            ?? 0
        return .success(SpeedResult(download: download / 1_000_000, upload: upload / 1_000_000, rpm: rpm, ping: ping, date: date))
    }

    static func progress(_ text: String) -> (download: Double, upload: Double)? {
        guard let match = text.matches(of: #/Downlink: ([\d.]+) Mbps.*?Uplink: ([\d.]+) Mbps/#).last,
              let download = Double(match.1),
              let upload = Double(match.2)
        else { return nil }
        return (download * 1.048576, upload * 1.048576)
    }
}
