import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppExclusions: View {
    let title: String
    @Binding var apps: [String]
    let isEnabled: Bool
    var skipped: Set<String> = []
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            LabeledContent {
                Button("Add App…", action: add)
            } label: {
                Text(title)
                if apps.isEmpty {
                    Text("No apps yet")
                }
            }
            .disabled(!isEnabled)
            .settingAnchor(title)
            ForEach(apps, id: \.self) { id in
                AppRow(bundleID: id) { apps.removeAll { $0 == id } }
            }
        }
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
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        LabeledContent {
            Button(role: .destructive, action: remove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove")
        } label: {
            HStack(spacing: 8) {
                Image(nsImage: url.map { NSWorkspace.shared.icon(forFile: $0.path) } ?? NSImage())
                    .resizable()
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                Text(verbatim: url.map { FileManager.default.displayName(atPath: $0.path) } ?? bundleID)
            }
        }
    }
}
