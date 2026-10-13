import ApplicationServices
import Carbon
import Foundation
import os

enum Log {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "pikapik", category: "app")

    static func note(_ text: String) {
        logger.notice("\(text, privacy: .public)")
    }

    static func launch() {
        var native: Unmanaged<CFArray>?
        let status = CopySymbolicHotKeys(&native)
        let shortcuts = native?.takeRetainedValue() as? [Any]
        note("macOS \(ProcessInfo.processInfo.operatingSystemVersionString), accessibility \(AXIsProcessTrusted()), input monitoring \(CGPreflightListenEventAccess()), system shortcuts \(status) \(shortcuts?.count ?? -1)")
    }
}
