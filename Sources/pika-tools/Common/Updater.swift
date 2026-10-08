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
    nonisolated static let appName = "pikapik.app"
    nonisolated static let oldAppName = "pika-tools.app"

    let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    private(set) var state = State.idle
    var checksAutomatically = UserDefaults.standard.object(forKey: "check-updates") as? Bool ?? true {
        didSet { UserDefaults.standard.set(checksAutomatically, forKey: "check-updates") }
    }

    @ObservationIgnored private var assetURL: URL?
    @ObservationIgnored private var timer: Timer?

    private init() {}

    func start() {
        if checksAutomatically { Task { await check() } }
        timer = Timer.scheduledTimer(withTimeInterval: 6 * 3600, repeats: true) { _ in
            Task { @MainActor in
                if Updater.shared.checksAutomatically { await Updater.shared.check() }
            }
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
            assetURL = release.assets.first { $0.name == "pikapik.zip" }?.browser_download_url
            if assetURL != nil, version.compare(current, options: .numeric) == .orderedDescending {
                state = .available(version)
            } else {
                state = .upToDate
            }
        } catch {
            state = .failed(String(localized: "Couldn’t check for updates"))
        }
    }

    func install() async {
        guard let assetURL else { return }
        let appURL = Bundle.main.bundleURL
        let target = Self.destination(of: appURL, brewManaged: Self.isBrewManaged())
        guard FileManager.default.isWritableFile(atPath: appURL.deletingLastPathComponent().path) else {
            state = .failed(String(localized: "Can’t write to the app’s folder. Update with brew or install.sh"))
            return
        }
        state = .installing
        do {
            let (zip, _) = try await URLSession.shared.download(from: assetURL)
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tools-update-\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try run("/usr/bin/ditto", ["-x", "-k", zip.path, dir.path])
            let newApp = dir.appendingPathComponent(Self.appName)
            guard Bundle(url: newApp)?.bundleIdentifier == Bundle.main.bundleIdentifier else {
                throw CocoaError(.fileReadCorruptFile)
            }
            try run("/usr/bin/codesign", ["--verify", "--deep", "--strict", newApp.path])

            let script = """
            while kill -0 "$1" 2>/dev/null; do sleep 0.2; done
            rm -rf "$3" && ditto "$2" "$3" && { [ "$4" = "$3" ] || rm -rf "$4"; }
            xattr -dr com.apple.quarantine "$3"
            rm -rf "$(dirname "$2")"
            open "$3"
            """
            let helper = Process()
            helper.executableURL = URL(fileURLWithPath: "/bin/bash")
            helper.arguments = ["-c", script, "pika-update",
                                String(ProcessInfo.processInfo.processIdentifier),
                                newApp.path, target.path, appURL.path]
            try helper.run()
            if target != appURL { LoginItem.shared.apply(false) }
            NSApp.terminate(nil)
        } catch {
            state = .failed(String(localized: "Download failed. Try again later"))
        }
    }

    nonisolated static func destination(of app: URL, brewManaged: Bool) -> URL {
        guard !brewManaged, app.lastPathComponent == oldAppName else { return app }
        return app.deletingLastPathComponent().appendingPathComponent(appName)
    }

    nonisolated static func isBrewManaged(prefixes: [String] = ["/opt/homebrew", "/usr/local"]) -> Bool {
        prefixes.contains { prefix in
            ["pikapik", "pika-tools"].contains { FileManager.default.fileExists(atPath: "\(prefix)/Caskroom/\($0)") }
        }
    }

    nonisolated static func moveToNewName() -> Bool {
        let app = Bundle.main.bundleURL
        let target = destination(of: app, brewManaged: isBrewManaged())
        guard target != app, !CommandLine.arguments.contains("--keep-name"), !FileManager.default.fileExists(atPath: target.path),
              FileManager.default.isWritableFile(atPath: app.deletingLastPathComponent().path)
        else { return false }
        let helper = Process()
        helper.executableURL = URL(fileURLWithPath: "/bin/bash")
        helper.arguments = ["-c", """
            while kill -0 "$1" 2>/dev/null; do sleep 0.2; done
            mv "$2" "$3" && open "$3" || open "$2" --args --keep-name
            """, "pika-move", String(ProcessInfo.processInfo.processIdentifier), app.path, target.path]
        guard (try? helper.run()) != nil else { return false }
        LoginItem.shared.apply(false)
        return true
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

extension Updater.State {
    var title: String? {
        switch self {
        case .checking: String(localized: "checking…")
        case .installing: String(localized: "installing update…")
        case .upToDate: String(localized: "up to date")
        case .available: String(localized: "update available")
        case .failed(let message): message
        case .idle: nil
        }
    }
}
