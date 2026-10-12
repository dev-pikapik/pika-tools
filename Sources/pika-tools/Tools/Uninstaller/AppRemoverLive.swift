import AppKit

extension AppRemover {
    static func live(footprint: AppFootprint, confirmQuit: @escaping ([String]) async -> Bool, confirmForceQuit: @escaping ([String]) async -> Bool) -> AppRemover {
        let folder = Bundle.main.bundleIdentifier?.hasSuffix(".dev") == true ? "pika-tools-dev" : "pika-tools"
        let store = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/\(folder)/Uninstaller")
        return AppRemover(footprint: footprint, hooks: .live(confirmQuit: confirmQuit, confirmForceQuit: confirmForceQuit), store: store)
    }
}

extension AppRemover.Step {
    func perform(for url: URL) {
        switch self {
        case .openAutomation: Permissions.shared.openSettings("Privacy_Automation")
        case .openAppManagement: Permissions.shared.openSettings("Privacy_AppBundles")
        case .showInFinder: NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

extension AppRemover.Hooks {
    static func live(confirmQuit: @escaping ([String]) async -> Bool, confirmForceQuit: @escaping ([String]) async -> Bool) -> AppRemover.Hooks {
        AppRemover.Hooks(
            running: running,
            confirmQuit: confirmQuit,
            confirmForceQuit: confirmForceQuit,
            launchctl: launchctl,
            admin: { script, prompt in
                await onBackground {
                    outcome(KeepAwake.runScript("do shell script \(KeepAwake.scriptQuoted(script)) with prompt \(KeepAwake.scriptQuoted(prompt)) with administrator privileges").error)
                }
            },
            finder: { url in
                await onBackground {
                    let result = KeepAwake.runScript("""
                    with timeout of 600 seconds
                        tell application "Finder"
                            set trashed to delete (POSIX file \(KeepAwake.scriptQuoted(url.path)) as alias)
                            return POSIX path of (trashed as alias)
                        end tell
                    end timeout
                    """)
                    return outcome(result.error, path: result.text)
                }
            },
            forget: LeftoverModel.forget
        )
    }

    private static func running(_ app: AppIdentity) -> [AppRemover.Running] {
        let ids = Set(([app.bundleID] + app.nestedIDs).map { $0.lowercased() })
        let bundle = app.url.resolvingSymlinksInPath().path + "/"
        return NSWorkspace.shared.runningApplications.filter { other in
            guard !other.isTerminated, other != NSRunningApplication.current else { return false }
            let inside = other.bundleURL.map { ($0.resolvingSymlinksInPath().path + "/").hasPrefix(bundle) } ?? false
            return inside || other.bundleIdentifier.map { ids.contains($0.lowercased()) } == true
        }.map { other in
            AppRemover.Running(
                name: other.localizedName ?? app.displayName,
                isRunning: { !other.isTerminated },
                terminate: { _ = other.terminate() },
                forceTerminate: { _ = other.forceTerminate() })
        }
    }

    private static func launchctl(_ arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return -1 }
        process.waitUntilExit()
        return process.terminationStatus
    }

    private static func outcome(_ error: Int, path: String? = nil) -> AppRemover.Outcome {
        switch error {
        case 0: .done(path)
        case -128: .cancelled
        case -1743: .denied
        default: .failed
        }
    }

    private static func onBackground<T>(_ work: @escaping () -> T) async -> T {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { continuation.resume(returning: work()) }
        }
    }
}
