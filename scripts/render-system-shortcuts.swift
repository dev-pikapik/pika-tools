import AppKit
import SwiftUI

@main
@MainActor
struct RenderSystemShortcuts {
    static func main() {
        NSApplication.shared.setActivationPolicy(.accessory)
        let all = SystemShortcutCatalog.load()
        let entries = SystemShortcutKind.allCases.compactMap { kind in all.first { $0.kind == kind } }
        for dark in [false, true] {
            let content = VStack(alignment: .leading, spacing: 12) {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 7) {
                        Text(verbatim: "\(entry.name) · \(entry.text ?? "Off")").font(.system(size: 12, weight: .medium))
                        HStack(spacing: 20) {
                            frame(entry, on: false)
                            frame(entry, on: true)
                        }
                    }
                }
            }
            .padding(20)
            .frame(width: 440, alignment: .leading)
            .background(dark ? Color(white: 0.12) : Color.white)
            .environment(\.colorScheme, dark ? .dark : .light)
            let host = NSHostingView(rootView: content)
            let size = CGSize(width: 440, height: CGFloat(entries.count) * 150 + 40)
            let window = NSWindow(contentRect: CGRect(origin: CGPoint(x: -8000, y: -8000), size: size), styleMask: .borderless, backing: .buffered, defer: false)
            window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            window.contentView = host
            window.orderFrontRegardless()
            host.layoutSubtreeIfNeeded()
            let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds)!
            host.cacheDisplay(in: host.bounds, to: rep)
            let out = CommandLine.arguments[1] + "/system-shortcuts-\(dark ? "dark" : "light").png"
            try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
            window.orderOut(nil)
            print(out)
        }
        for dark in [false, true] {
            NSApp.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            SettingsWindow.model.selection = .games
            let host = NSHostingView(rootView: SettingsWindow.preview)
            let window = NSWindow(contentRect: CGRect(x: -8000, y: -8000, width: 860, height: 720), styleMask: .borderless, backing: .buffered, defer: false)
            window.contentView = host
            window.orderFrontRegardless()
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            host.layoutSubtreeIfNeeded()
            let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds)!
            host.cacheDisplay(in: host.bounds, to: rep)
            let out = CommandLine.arguments[1] + "/games-page-\(dark ? "dark" : "light").png"
            try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
            window.orderOut(nil)
            print(out)
        }
        print("preview kinds rendered:", entries.map { $0.kind.rawValue })
    }

    @ViewBuilder static func frame(_ entry: SystemGameShortcut, on: Bool) -> some View {
        if entry.kind == .existing, let rule = entry.previewRule {
            GameRuleFrame(rule: rule, keys: entry.text.map { [$0] } ?? [], story: .still(on: on))
        } else {
            SystemShortcutFrame(entry: entry, story: .still(on: on), background: on && entry.supportsBackground)
        }
    }
}
