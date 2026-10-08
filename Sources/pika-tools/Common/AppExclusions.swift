import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppExclusions: View {
    let title: String
    var keys: [String] = []
    @Binding var apps: [String]
    let isEnabled: Bool
    var skipped: Set<String> = []
    var empty = Text("No apps yet")
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            LabeledContent {
                Button("Add App…", systemImage: "plus", action: add)
            } label: {
                KeyLabel(keys: keys, title: Text(title), subtitle: apps.isEmpty ? empty : nil)
            }
            .disabled(!isEnabled)
            .settingAnchor(title)
            ForEach(apps, id: \.self) { id in
                AppRow(bundleID: id) { apps.removeAll { $0 == id } }
            }
        }
    }

    static func choose() -> [URL] {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = true
        panel.prompt = String(localized: "Add")
        NSApp.activate()
        return panel.runModal() == .OK ? panel.urls : []
    }

    private func add() {
        let ids = Self.choose().compactMap { Bundle(url: $0)?.bundleIdentifier }
        apps += ids.filter { !apps.contains($0) && !skipped.contains($0) }
    }
}

struct AppRow: View {
    let bundleID: String
    let remove: () -> Void

    var body: some View {
        LabeledContent {
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove")
        } label: {
            AppLabel(id: bundleID)
        }
    }
}

struct AppLabel: View {
    let id: String
    var subtitle: Text?

    var body: some View {
        let (name, icon) = id.hasPrefix("/") ? Self.game(id) : Self.app(id)
        HStack(spacing: 8) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: name)
                if let subtitle {
                    subtitle
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private static func app(_ id: String) -> (String, NSImage) {
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
        let running = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == id || $0.localizedName == id }
        return (
            url.map { FileManager.default.displayName(atPath: $0.path) }.map { $0.hasSuffix(".app") ? String($0.dropLast(4)) : $0 } ?? running?.localizedName ?? id,
            url.map { NSWorkspace.shared.icon(forFile: $0.path) } ?? running?.icon ?? NSImage()
        )
    }

    private static func game(_ path: String) -> (String, NSImage) {
        if let running = NSWorkspace.shared.runningApplications.first(where: { GameModeTool.key($0) == path }) {
            return (running.title, running.picture ?? NSWorkspace.shared.icon(forFile: path))
        }
        guard GameRules.minecraft(path) != nil else { return (URL(fileURLWithPath: path).lastPathComponent, NSWorkspace.shared.icon(forFile: path)) }
        return ("Minecraft", minecraftIcon ?? NSWorkspace.shared.icon(forFile: path))
    }

    static var minecraftIcon: NSImage? {
        GameRules.minecraftLaunchers.lazy.compactMap(NSWorkspace.shared.urlForApplication).first.map { NSWorkspace.shared.icon(forFile: $0.path) }
    }
}

extension NSRunningApplication {
    var title: String {
        dock("name") ?? (minecraft ? "Minecraft" : nil) ?? localizedName ?? executableURL?.lastPathComponent ?? ""
    }

    var picture: NSImage? {
        dock("icon").flatMap(NSImage.init(contentsOfFile:)) ?? (minecraft ? AppLabel.minecraftIcon : nil) ?? icon
    }

    private var minecraft: Bool {
        GameRules.isRuntime(bundleIdentifier) && GameRules.minecraft(executableURL?.path ?? "") != nil
    }

    private func dock(_ key: String) -> String? {
        guard GameRules.isRuntime(bundleIdentifier) else { return nil }
        var mib = [CTL_KERN, KERN_PROCARGS2, processIdentifier]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4 else { return nil }
        var bytes = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &bytes, &size, nil, 0) == 0 else { return nil }
        let count = Int(bytes.withUnsafeBytes { $0.load(as: Int32.self) })
        let prefix = "-Xdock:\(key)="
        return bytes[4..<size].split(separator: 0).dropFirst().prefix(count).lazy
            .map { String(decoding: $0, as: UTF8.self) }
            .first { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
            .flatMap { $0.isEmpty ? nil : $0 }
    }
}
