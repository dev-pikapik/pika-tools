import AppKit

@MainActor
@Observable
final class Updater {
    enum State: Equatable {
        case idle, checking, upToDate, installing
        case available(String)
        case failed(String)
    }

    static let shared = Updater()
    static let repo = "dev-pikapik/pika-tools"

    let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    private(set) var state = State.idle

    @ObservationIgnored private var assetURL: URL?
    @ObservationIgnored private var timer: Timer?

    private init() {}

    func start() {
        Task { await check() }
        timer = Timer.scheduledTimer(withTimeInterval: 6 * 3600, repeats: true) { _ in
            Task { @MainActor in await Updater.shared.check() }
        }
    }

    func check() async {
        guard state != .installing else { return }
        state = .checking
        do {
            let url = URL(string: "https://api.github.com/repos/\(Self.repo)/releases/latest")!
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            let (data, _) = try await URLSession.shared.data(for: request)
            let release = try JSONDecoder().decode(Release.self, from: data)
            let version = release.tag_name.hasPrefix("v") ? String(release.tag_name.dropFirst()) : release.tag_name
            assetURL = release.assets.first { $0.name == "pika-tools.zip" }?.browser_download_url
            if assetURL != nil, version.compare(current, options: .numeric) == .orderedDescending {
                state = .available(version)
            } else {
                state = .upToDate
            }
        } catch {
            state = .failed("Не получилось проверить обновления")
        }
    }

    func install() async {
        guard let assetURL else { return }
        let appURL = Bundle.main.bundleURL
        guard FileManager.default.isWritableFile(atPath: appURL.deletingLastPathComponent().path) else {
            state = .failed("Нет прав на папку с приложением — обнови через brew или install.sh")
            return
        }
        state = .installing
        do {
            let (zip, _) = try await URLSession.shared.download(from: assetURL)
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tools-update-\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try run("/usr/bin/ditto", ["-x", "-k", zip.path, dir.path])
            let newApp = dir.appendingPathComponent("pika-tools.app")
            guard Bundle(url: newApp)?.bundleIdentifier == Bundle.main.bundleIdentifier else {
                throw CocoaError(.fileReadCorruptFile)
            }
            try run("/usr/bin/codesign", ["--verify", "--deep", "--strict", newApp.path])

            let script = """
            while kill -0 "$1" 2>/dev/null; do sleep 0.2; done
            rm -rf "$3" && ditto "$2" "$3"
            xattr -dr com.apple.quarantine "$3"
            tccutil reset Accessibility "$4"
            tccutil reset ListenEvent "$4"
            rm -rf "$(dirname "$2")"
            open "$3"
            """
            let helper = Process()
            helper.executableURL = URL(fileURLWithPath: "/bin/bash")
            helper.arguments = ["-c", script, "pika-update",
                                String(ProcessInfo.processInfo.processIdentifier),
                                newApp.path, appURL.path, Bundle.main.bundleIdentifier ?? ""]
            try helper.run()
            NSApp.terminate(nil)
        } catch {
            state = .failed("Обновление не скачалось, попробуй позже")
        }
    }

    private func run(_ path: String, _ args: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { throw CocoaError(.fileReadCorruptFile) }
    }

    private struct Release: Decodable {
        struct Asset: Decodable {
            let name: String
            let browser_download_url: URL
        }
        let tag_name: String
        let assets: [Asset]
    }
}
