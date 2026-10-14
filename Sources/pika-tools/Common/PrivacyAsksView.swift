import AppKit
import SwiftUI

@Observable
final class PrivacyAsksModel {
    private(set) var apps: [AskingApp]?

    func refresh() {
        DispatchQueue.global(qos: .userInitiated).async {
            let apps = PrivacyAsks.scan()
            DispatchQueue.main.async { self.apps = apps }
        }
    }
}

struct PrivacyListRow: View {
    let title: String
    let icon: String
    let symbol: String
    let pane: String
    let apps: [AskingApp]?

    var body: some View {
        let asking = apps.flatMap { PrivacyAsks.apps(pane, in: $0) }
        LabeledContent {
            HStack(spacing: 8) {
                if let asking, !asking.isEmpty {
                    AskingStack(title: title, apps: asking)
                }
                Button("Open", systemImage: "arrow.up.forward.app") { Permissions.shared.openSettings(pane) }
            }
            .fixedSize()
        } label: {
            HStack(spacing: 10) {
                PermissionIcon(type: icon, symbol: symbol)
                RowLabel(Text(title), subtitle(asking))
            }
        }
    }

    private func subtitle(_ asking: [AskingApp]?) -> Text? {
        guard PrivacyAsks.keys[pane] != nil else { return Text("Only System Settings shows who has it") }
        guard let asking else { return nil }
        return asking.isEmpty ? Text("No app can ask for it") : Text("Can ask for it: \(asking.count)")
    }
}

private struct AskingStack: View {
    let title: String
    let apps: [AskingApp]
    @State private var showing = false

    var body: some View {
        Button { showing.toggle() } label: {
            HStack(spacing: -6) {
                ForEach(apps.prefix(4)) { app in
                    Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                        .resizable()
                        .frame(width: 22, height: 22)
                }
                if apps.count > 4 {
                    Text(verbatim: "+\(apps.count - 4)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.leading, 10)
                }
            }
        }
        .buttonStyle(.plain)
        .help(Text("Can ask for it: \(apps.count)"))
        .accessibilityLabel(Text("Can ask for it: \(apps.count)"))
        .popover(isPresented: $showing, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                RowLabel(Text(verbatim: title).font(.headline), Text("These apps can ask for it. Only System Settings shows who has it."))
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(apps) { app in
                            Label {
                                Text(verbatim: app.name)
                            } icon: {
                                Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 320)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(width: 280)
        }
    }
}
