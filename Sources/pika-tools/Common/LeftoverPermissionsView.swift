import AppKit
import SwiftUI

extension LeftoverPermissions.Lookup {
    static var live: Self {
        let files = FileManager.default
        let volumes = Set((files.mountedVolumeURLs(includingResourceValuesForKeys: nil) ?? []).map(\.path))
        let root = "/Library/SystemExtensions"
        let extensions = ((try? files.contentsOfDirectory(atPath: root)) ?? []).flatMap { folder in
            ((try? files.contentsOfDirectory(atPath: "\(root)/\(folder)")) ?? []).map { "\(root)/\(folder)/\($0)" }
        }
        return Self(
            apps: { id in NSWorkspace.shared.urlsForApplications(withBundleIdentifier: id).map(\.path) + extensions.filter { $0.hasSuffix("/\(id).systemextension") } },
            exists: { files.fileExists(atPath: $0) },
            mounted: { volumes.contains($0) }
        )
    }
}

@Observable
final class LeftoverModel {
    enum State { case loading, noAccess, ready }

    private(set) var state = State.loading
    private(set) var apps: [LeftoverApp] = []
    private(set) var stuck: [LeftoverApp] = []
    private(set) var removing: Set<String> = []
    private(set) var userHidden = false

    @ObservationIgnored private let system: String
    @ObservationIgnored private let user: String

    private static let lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

    init(system: String = LeftoverPermissions.systemDatabase, user: String = LeftoverPermissions.userDatabase) {
        self.system = system
        self.user = user
    }

    var removable: [LeftoverApp] { apps.filter { !$0.isPath } }

    func refresh() {
        guard removing.isEmpty else { return }
        guard let grants = LeftoverPermissions.read(system) else {
            state = .noAccess
            apps = []
            return
        }
        let personal = LeftoverPermissions.read(user)
        userHidden = personal == nil
        apps = LeftoverPermissions.leftovers(grants + (personal ?? []), .live)
        stuck = stuck.filter { old in apps.contains { $0.id == old.id } }
        state = .ready
    }

    func remove(_ targets: [LeftoverApp]) {
        let ids = targets.filter { !$0.isPath }.map(\.client)
        guard !ids.isEmpty else { return }
        removing.formUnion(ids)
        stuck = []
        DispatchQueue.global(qos: .userInitiated).async {
            ids.forEach(Self.forget)
            DispatchQueue.main.async {
                self.removing.subtract(ids)
                self.refresh()
                self.stuck = self.apps.filter { ids.contains($0.client) }
            }
        }
    }

    private static func forget(_ id: String) {
        let files = FileManager.default
        let stub = files.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "pika-tools", isDirectory: true)
            .appendingPathComponent("Leftover.app", isDirectory: true)
        let executable = stub.appendingPathComponent("Contents/MacOS/Leftover")
        let info: NSDictionary = ["CFBundleIdentifier": id, "CFBundlePackageType": "APPL", "CFBundleExecutable": "Leftover"]
        func clear() {
            run(lsregister, "-u", stub.path)
            try? files.removeItem(at: stub)
        }
        clear()
        defer { clear() }
        guard !LeftoverPermissions.isSystem(id, isPath: false),
              LeftoverPermissions.place(id, isPath: false, .live) == .gone,
              (try? files.createDirectory(at: executable.deletingLastPathComponent(), withIntermediateDirectories: true)) != nil,
              (try? files.copyItem(atPath: "/usr/bin/true", toPath: executable.path)) != nil,
              (try? info.write(to: stub.appendingPathComponent("Contents/Info.plist"))) != nil
        else { return }
        run(lsregister, "-f", stub.path)
        run("/usr/bin/tccutil", "reset", "All", id)
    }

    private static func run(_ path: String, _ arguments: String...) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        guard (try? process.run()) != nil else { return }
        process.waitUntilExit()
    }
}

struct LeftoverPermissionsSection: View {
    @State var model = LeftoverModel()
    @State private var confirming: [LeftoverApp]?

    var body: some View {
        Section {
            LeftoversArt()
                .settingAnchor(String(localized: "Left by deleted apps"))
            switch model.state {
            case .loading:
                EmptyView()
            case .noAccess:
                PermissionRow(
                    icon: "com.apple.graphic-icon.privacy",
                    symbol: "hand.raised.fill",
                    title: String(localized: "Full Disk Access"),
                    subtitle: String(localized: "To find them, pikapik needs to read the list of permissions. It only looks and changes nothing until you press Remove."),
                    granted: false
                ) { Permissions.shared.openSettings("Privacy_AllFiles") }
            case .ready:
                if !model.stuck.isEmpty {
                    StuckRow(apps: model.stuck, retry: { model.remove(model.stuck) })
                }
                if model.apps.isEmpty {
                    LabeledContent {
                        EmptyView()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                                .accessibilityHidden(true)
                            RowLabel(Text("Nothing to clean up"), Text("Every permission belongs to an app that’s still on your Mac."))
                        }
                    }
                }
                ForEach(model.apps) { app in
                    LeftoverRow(app: app, removing: model.removing.contains(app.client)) { confirming = [app] }
                }
            }
        } header: {
            Text("Left by deleted apps")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Group {
                    Text("When you delete an app, macOS keeps the permissions you gave it, and System Settings can’t remove them. pikapik finds them and cleans them up.")
                    if model.state == .ready, model.userHidden, !model.removable.isEmpty {
                        Text("macOS keeps Camera, Microphone and a few other lists hidden, so they aren’t shown here. Remove clears them too.")
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                if model.removable.count > 1 {
                    HStack {
                        Spacer()
                        Button("Remove All…", systemImage: "trash") { confirming = model.removable }
                            .disabled(!model.removing.isEmpty)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .animation(.snappy, value: model.apps)
        .animation(.snappy, value: model.state)
        .confirmationDialog(
            confirming?.count == 1 ? String(localized: "Remove the permissions of “\(confirming?[0].name ?? "")”?") : String(localized: "Remove the permissions of all deleted apps?"),
            isPresented: Binding(get: { confirming != nil }, set: { if !$0 { confirming = nil } }),
            titleVisibility: .visible,
            presenting: confirming
        ) { apps in
            Button("Remove", role: .destructive) { model.remove(apps) }
        } message: { _ in
            Text("Deleted apps don’t need them anymore. If you install one again, it will simply ask for permission again.")
        }
        .onAppear { model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in model.refresh() }
    }
}

private struct LeftoverRow: View {
    let app: LeftoverApp
    let removing: Bool
    let remove: () -> Void

    var body: some View {
        LabeledContent {
            if removing {
                ProgressView().controlSize(.small)
            } else if app.isPath {
                Button("Open", systemImage: "arrow.up.forward.app") { Permissions.shared.openSettings(app.kinds.first?.pane ?? "Privacy") }
            } else {
                Button("Remove", action: remove)
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5) {
                    Text(verbatim: app.name)
                    PermissionChips(kinds: app.kinds)
                    Group {
                        Text(verbatim: app.client)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text("Last changed \(app.modified.formatted(date: .abbreviated, time: .omitted))")
                        if app.isPath {
                            Text("Only System Settings can remove this one. Select it in the list and press −.")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var icon: NSImage {
        if app.isPath { return NSWorkspace.shared.icon(for: .unixExecutable) }
        let copy = NSWorkspace.shared.urlsForApplications(withBundleIdentifier: app.client).first { FileManager.default.fileExists(atPath: $0.path) }
        return copy.map { NSWorkspace.shared.icon(forFile: $0.path) } ?? NSWorkspace.shared.icon(for: .applicationBundle)
    }
}

private struct StuckRow: View {
    let apps: [LeftoverApp]
    let retry: () -> Void

    var body: some View {
        LabeledContent {
            HStack(spacing: 8) {
                Button("Try Again", action: retry)
                Button("Open", systemImage: "arrow.up.forward.app") { Permissions.shared.openSettings(apps.first?.kinds.first?.pane ?? "Privacy") }
            }
            .fixedSize()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                RowLabel(
                    Text("Some permissions stayed"),
                    Text("macOS didn’t let pikapik remove the permissions of \(apps.map(\.name).formatted(.list(type: .and))). Try again, or remove them in System Settings.")
                )
            }
        }
    }
}

private struct PermissionChips: View {
    let kinds: [PermissionKind]

    var body: some View {
        ChipFlow {
            ForEach(kinds, id: \.name) { kind in
                Label(kind.name, systemImage: kind.symbol)
                    .font(.caption)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }
        }
    }
}

private struct ChipFlow: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let frames = place(subviews, width: proposal.width ?? .infinity)
        return CGSize(width: frames.map(\.maxX).max() ?? 0, height: frames.map(\.maxY).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, place(subviews, width: bounds.width)) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    private func place(_ subviews: Subviews, width: CGFloat) -> [CGRect] {
        var point = CGPoint.zero
        var line: CGFloat = 0
        return subviews.map { subview in
            let size = subview.sizeThatFits(.unspecified)
            if point.x > 0, point.x + size.width > width {
                point = CGPoint(x: 0, y: point.y + line + 4)
                line = 0
            }
            defer { point.x += size.width + 4 }
            line = max(line, size.height)
            return CGRect(origin: point, size: size)
        }
    }
}

struct LeftoversArt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let center = CGPoint(x: 150, y: 64)
    private static let chips: [(symbol: String, color: Color, at: CGPoint)] = [
        ("camera.fill", .blue, CGPoint(x: 84, y: 38)),
        ("mic.fill", .orange, CGPoint(x: 72, y: 88)),
        ("accessibility", .indigo, CGPoint(x: 216, y: 36)),
        ("rectangle.dashed.badge.record", .pink, CGPoint(x: 228, y: 86)),
    ]

    var body: some View {
        IllustrationRow(loop: [2.2, 1.6]) { tick in
            let clean = !reduceMotion && tick % 2 == 1
            let tile = RoundedRectangle(cornerRadius: 17, style: .continuous)
            Stage {
                tile
                    .strokeBorder(Color.secondary.opacity(clean ? 0.2 : 0.6), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .background(tile.fill(Color.primary.opacity(0.04)))
                    .frame(width: 72, height: 72)
                    .position(Self.center)
                ForEach(Self.chips.indices, id: \.self) { index in
                    let chip = Self.chips[index]
                    Image(systemName: chip.symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(chip.color.gradient, in: Circle())
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .scaleEffect(clean ? 0.2 : 1)
                        .opacity(clean ? 0 : 1)
                        .position(clean ? Self.center : chip.at)
                }
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white, Art.green)
                    .scaleEffect(clean ? 1 : 0.4)
                    .opacity(clean ? 1 : 0)
                    .position(Self.center)
            }
            .spring(clean, reduceMotion: reduceMotion)
        }
    }
}
