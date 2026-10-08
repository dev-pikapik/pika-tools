import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct GameList: View {
    @Bindable var tool: GameModeTool
    @State private var adding = false

    var body: some View {
        LabeledContent {
            if adding {
                Button("Done") { adding = false }
            } else {
                Button("Add a Game…") { adding = true }
            }
        } label: {
            RowLabel(Text("Your games"), tool.games.isEmpty ? Text("Add a game, and Game Mode turns on by itself while you play it") : nil)
        }
        .settingAnchor(String(localized: "Your games"))
        if adding { GameShelf(tool: tool) }
        ForEach(tool.games, id: \.self) { key in
            AppRow(bundleID: key) { tool.games.removeAll { $0 == key } }
        }
    }
}

private struct GameShelf: View {
    let tool: GameModeTool
    @State private var apps: [NSRunningApplication] = []

    var body: some View {
        let center = NSWorkspace.shared.notificationCenter
        let shown = apps.filter { !tool.games.contains(GameModeTool.key($0)) }
        VStack(alignment: .leading, spacing: 8) {
            if shown.isEmpty {
                Text("Open your game, and it shows up here")
            } else {
                Text("Click your game to add it, or drag it to the list")
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 2)], spacing: 2) {
                ForEach(shown, id: \.processIdentifier) { app in
                    let key = GameModeTool.key(app)
                    ShelfTile(name: app.title, icon: app.picture ?? NSImage()) { tool.confirm(key) }
                        .onDrag { NSItemProvider(object: key as NSString) }
                }
                ShelfTile(name: String(localized: "Other…"), icon: NSWorkspace.shared.icon(forFile: "/Applications")) {
                    AppExclusions.choose().forEach(tool.add)
                }
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
        var seen = Set<String>()
        apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && $0.bundleIdentifier?.hasPrefix("com.pesotchi.pika-tools") != true && $0.bundleIdentifier != "com.apple.finder"
                && seen.insert(GameModeTool.key($0)).inserted
        }
    }
}

private struct ShelfTile: View {
    let name: String
    let icon: NSImage
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 48, height: 48)
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
    }
}

private struct GameListBounds: PreferenceKey {
    static let defaultValue: [Anchor<CGRect>] = []

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value += nextValue()
    }
}

private struct GameDrop: ViewModifier {
    @State private var targeted = false

    func body(content: Content) -> some View {
        content
            .onDrop(of: [.fileURL, .plainText], isTargeted: $targeted, perform: drop)
            .overlayPreferenceValue(GameListBounds.self) { anchors in
                GeometryReader { proxy in
                    let rect = anchors.map { proxy[$0] }.reduce(CGRect.null) { $0.union($1) }.insetBy(dx: -10, dy: -10)
                    let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
                    if targeted, !rect.isNull {
                        shape
                            .fill(Color.accentColor.opacity(0.08))
                            .overlay(shape.strokeBorder(Color.accentColor, lineWidth: 2))
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                    }
                }
                .allowsHitTesting(false)
            }
    }

    private func drop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    guard let url else { return }
                    DispatchQueue.main.async { GameModeTool.shared.add(url) }
                }
            } else {
                _ = provider.loadObject(ofClass: String.self) { key, _ in
                    guard let key else { return }
                    DispatchQueue.main.async {
                        guard NSWorkspace.shared.runningApplications.contains(where: { GameModeTool.key($0) == key }) else { return }
                        GameModeTool.shared.confirm(key)
                    }
                }
            }
        }
        return true
    }
}

extension View {
    func gameList() -> some View {
        anchorPreference(key: GameListBounds.self, value: .bounds) { [$0] }
    }

    func gameDrop() -> some View {
        modifier(GameDrop())
    }
}
