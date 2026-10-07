import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppExclusions: View {
    let title: String
    var keys: [String] = []
    @Binding var apps: [String]
    let isEnabled: Bool
    var skipped: Set<String> = []
    var addsRunning = false
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            LabeledContent {
                HStack {
                    if addsRunning {
                        Menu("Add a Running App…") {
                            ForEach(running, id: \.key) { app in
                                Button { apps.append(app.key) } label: { Text(verbatim: app.name) }
                            }
                        }
                        .fixedSize()
                    }
                    Button("Add App…", systemImage: "plus", action: add)
                }
            } label: {
                KeyLabel(keys: keys, title: Text(title), subtitle: apps.isEmpty ? Text("No apps yet") : nil)
            }
            .disabled(!isEnabled)
            .settingAnchor(title)
            ForEach(apps, id: \.self) { id in
                AppRow(bundleID: id) { apps.removeAll { $0 == id } }
            }
        }
    }

    private var running: [(key: String, name: String)] {
        var seen = Set(apps).union(skipped)
        return NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.processIdentifier != getpid() }
            .compactMap { app in (app.bundleIdentifier ?? app.localizedName).map { ($0, app.localizedName ?? $0) } }
            .filter { seen.insert($0.key).inserted }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func add() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = true
        panel.prompt = String(localized: "Add")
        NSApp.activate()
        guard panel.runModal() == .OK else { return }
        let ids = panel.urls.compactMap { Bundle(url: $0)?.bundleIdentifier }
        apps += ids.filter { !apps.contains($0) && !skipped.contains($0) }
    }
}

private struct AppRow: View {
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
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
        let running = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == id || $0.localizedName == id }
        HStack(spacing: 8) {
            Image(nsImage: url.map { NSWorkspace.shared.icon(forFile: $0.path) } ?? running?.icon ?? NSImage())
                .resizable()
                .frame(width: 20, height: 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: url.map { FileManager.default.displayName(atPath: $0.path) } ?? running?.localizedName ?? id)
                if let subtitle {
                    subtitle
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
