import AppKit
import SwiftUI

struct AppRowLabel<Trailing: View>: View {
    let icon: NSImage
    let name: String
    var running = false
    let byline: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(name)
                        .lineLimit(1)
                    if running {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                            .help(Text("Open now"))
                            .accessibilityLabel(Text("Open now"))
                    }
                }
                if !byline.isEmpty {
                    Text(byline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .contentShape(Rectangle())
    }
}

struct SizeColumn: View {
    let size: Int64?
    let caption: String
    var width: CGFloat = 110

    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(size.map(UninstallerText.size) ?? "")
                .monospacedDigit()
                .frame(height: 17, alignment: .trailing)
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(height: 14, alignment: .trailing)
        }
        .frame(width: width, alignment: .trailing)
    }
}

struct RowChevron: View {
    var body: some View {
        Image(systemName: "chevron.forward")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
}

struct TrashedSection: View {
    private let model = UninstallerModel.shared

    var body: some View {
        if !model.trashed.isEmpty {
            Section("In the Trash") {
                ForEach(model.trashed) { item in
                    Button { model.open(item.app) } label: {
                        AppRowLabel(icon: model.icon(of: item.app), name: item.app.displayName, byline: item.app.byline) {
                            SizeColumn(size: item.size, caption: String(localized: "\(item.items.count) items"))
                            RowChevron()
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 40)
                }
            }
        }
    }
}

struct LeftoversSection: View {
    private let model = UninstallerModel.shared

    var body: some View {
        if !model.orphans.isEmpty {
            Section("Leftovers of removed apps") {
                ForEach(model.orphans) { item in
                    Button { model.open(leftovers: item) } label: {
                        AppRowLabel(icon: model.icon(of: item.app), name: item.app.displayName, byline: item.changed.map { UninstallerText.changed($0) } ?? "") {
                            SizeColumn(size: item.size, caption: String(localized: "\(item.items.count) items"))
                            RowChevron()
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 40)
                }
            }
        }
    }
}

struct RemovedSection: View {
    private let model = UninstallerModel.shared

    var body: some View {
        if !model.removed.isEmpty {
            Section("Recently removed") {
                ForEach(model.removed) { removal in
                    RemovedRow(removal: removal)
                }
            }
        }
    }
}

private struct RemovedRow: View {
    let removal: Removal
    private let model = UninstallerModel.shared

    var body: some View {
        let record = removal.record
        VStack(alignment: .leading, spacing: 10) {
            AppRowLabel(icon: icon, name: record.appName, byline: UninstallerText.removed(record.date)) {
                switch removal.state {
                case .idle:
                    SizeColumn(size: record.bytes, caption: String(localized: "\(record.moves.count) items"), width: 72)
                    Button("Put Back") { model.putBack(record) }
                        .controlSize(.small)
                case .working:
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Putting back…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                case .done(let result):
                    Label {
                        Text(result.restored > 0 ? String(localized: "Put back \(result.restored) items") : String(localized: "Nothing was put back"))
                            .font(.callout)
                            .multilineTextAlignment(.trailing)
                    } icon: {
                        Image(systemName: result.restored > 0 ? "checkmark.circle.fill" : "info.circle")
                            .foregroundStyle(result.restored > 0 ? Color.green : Color.secondary)
                    }
                    .frame(maxWidth: 190, alignment: .trailing)
                }
            }
            .frame(minHeight: 40)
            if case .done(let result) = removal.state, !result.stayed.isEmpty {
                StayedList(stays: result.stayed)
            }
        }
        .padding(.vertical, 2)
    }

    private var icon: NSImage {
        let bundle = removal.record.moves.first { $0.original.hasSuffix(".app") }
        return model.icon(of: AppIdentity(url: URL(fileURLWithPath: bundle?.trash ?? "/Removed/\(removal.record.appName).app"), bundleID: ""))
    }
}
