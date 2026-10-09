import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppShelf: View {
    let hint: Text
    var empty: Text?
    let added: [String]
    let suggest: () -> [String]
    let toggle: (String) -> Void
    let other: () -> Void
    @State private var keys: [String] = []

    var body: some View {
        let center = NSWorkspace.shared.notificationCenter
        VStack(alignment: .leading, spacing: 8) {
            keys.isEmpty ? (empty ?? hint) : hint
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 2)], spacing: 2) {
                ForEach(keys, id: \.self) { key in
                    let app = AppLabel.info(key)
                    ShelfTile(name: app.name, icon: app.icon, added: added.contains(key)) { toggle(key) }
                }
                ShelfTile(name: String(localized: "Other…"), icon: NSWorkspace.shared.icon(forFile: "/Applications"), added: false, action: other)
            }
            .padding(6)
            .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .onAppear(perform: refresh)
        .onReceive(center.publisher(for: NSWorkspace.didLaunchApplicationNotification)) { _ in refresh() }
        .onReceive(center.publisher(for: NSWorkspace.didTerminateApplicationNotification)) { _ in refresh() }
        .onReceive(center.publisher(for: NSWorkspace.didActivateApplicationNotification)) { _ in refresh() }
    }

    private func refresh() {
        keys = suggest()
    }

    static func dock() -> [URL] {
        func tiles(_ key: String) -> [URL] {
            GameRules.dockFiles(CFPreferencesCopyAppValue(key as CFString, "com.apple.dock" as CFString) as? [Any])
        }
        let recents = CFPreferencesCopyAppValue("show-recents" as CFString, "com.apple.dock" as CFString) as? Bool ?? true
        return tiles("persistent-apps") + (recents ? tiles("recent-apps") : [])
    }

    static var running: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
    }

    static func isApp(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType?.conforms(to: .applicationBundle) == true
    }

    static func apps(on pasteboard: NSPasteboard) -> [URL] {
        let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []
        return urls.filter(isApp)
    }
}

private struct ShelfTile: View {
    let name: String
    let icon: NSImage
    let added: Bool
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .overlay(alignment: .bottomTrailing) {
                        if added {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 17, weight: .semibold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, Color.accentColor)
                                .offset(x: 3, y: 3)
                        }
                    }
                Text(verbatim: name)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(hovering ? 0.08 : 0), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(name)
        .accessibilityLabel(name)
        .accessibilityAddTraits(added ? .isSelected : [])
    }
}

private struct AppDropZone {
    let id: String
    let bounds: Anchor<CGRect>
    let add: ((URL) -> Void)?
}

private struct AppDropZones: PreferenceKey {
    static let defaultValue: [AppDropZone] = []

    static func reduce(value: inout [AppDropZone], nextValue: () -> [AppDropZone]) {
        value += nextValue()
    }
}

private struct AppDropTarget: Equatable {
    let id: String
    let frame: CGRect
    let add: ((URL) -> Void)?

    static func == (a: Self, b: Self) -> Bool {
        a.id == b.id && a.frame == b.frame
    }
}

struct AppDropPage: ViewModifier {
    @State private var targets: [AppDropTarget] = []
    @State private var target: String?

    func body(content: Content) -> some View {
        content
            .onDrop(of: [.fileURL], delegate: AppDropDelegate(targets: targets, target: $target))
            .overlayPreferenceValue(AppDropZones.self) { zones in
                GeometryReader { proxy in
                    let resolved = Self.resolve(zones, proxy)
                    let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
                    ZStack {
                        Color.clear
                            .onChange(of: resolved, initial: true) { targets = resolved }
                        if let rect = resolved.first(where: { $0.id == target })?.frame {
                            shape
                                .fill(Color.accentColor.opacity(0.08))
                                .overlay(shape.strokeBorder(Color.accentColor, lineWidth: 2))
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }
                    }
                }
                .allowsHitTesting(false)
            }
    }

    private static func resolve(_ zones: [AppDropZone], _ proxy: GeometryProxy) -> [AppDropTarget] {
        var targets: [AppDropTarget] = []
        for zone in zones {
            let rect = proxy[zone.bounds].insetBy(dx: -10, dy: -10)
            if let index = targets.firstIndex(where: { $0.id == zone.id }) {
                targets[index] = AppDropTarget(id: zone.id, frame: targets[index].frame.union(rect), add: zone.add)
            } else {
                targets.append(AppDropTarget(id: zone.id, frame: rect, add: zone.add))
            }
        }
        return targets
    }
}

private struct AppDropDelegate: DropDelegate {
    private static var dropped: Int?
    let targets: [AppDropTarget]
    @Binding var target: String?

    private func zone(_ info: DropInfo) -> AppDropTarget? {
        let zone = targets.first { $0.frame.contains(info.location) } ?? (targets.count == 1 ? targets.first : nil)
        return zone?.add == nil ? nil : zone
    }

    func validateDrop(info: DropInfo) -> Bool {
        let valid = !targets.isEmpty && !AppShelf.apps(on: NSPasteboard(name: .drag)).isEmpty
        if !valid { target = nil }
        return valid
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        target = NSPasteboard(name: .drag).changeCount == Self.dropped ? nil : zone(info)?.id
        return DropProposal(operation: target == nil ? .forbidden : .copy)
    }

    func dropExited(info: DropInfo) {
        target = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        target = nil
        Self.dropped = NSPasteboard(name: .drag).changeCount
        guard let add = zone(info)?.add else { return false }
        let apps = AppShelf.apps(on: NSPasteboard(name: .drag))
        apps.forEach(add)
        return !apps.isEmpty
    }
}

extension View {
    func appDropZone(_ id: String, isEnabled: Bool = true, add: @escaping (URL) -> Void) -> some View {
        anchorPreference(key: AppDropZones.self, value: .bounds) { [AppDropZone(id: id, bounds: $0, add: isEnabled ? add : nil)] }
    }
}
