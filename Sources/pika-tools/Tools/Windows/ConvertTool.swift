import AppKit
import SwiftUI

final class ConvertTool: Tool {
    let id = "convert"
    let icon = "arrow.triangle.2.circlepath"
    var title: String { String(localized: "Convert in Finder") }
    let tab = SettingsTab.finder
    private let finder: FinderExtension

    init() {
        let fresh = UserDefaults.standard.object(forKey: "convert") == nil
        finder = FinderExtension(bundle: "Convert", key: "convert")
        if fresh, UserDefaults.standard.bool(forKey: "compress") { finder.isEnabled = true }
    }

    var isActive: Bool { finder.isActive }

    var isEnabled: Bool {
        get { finder.isEnabled }
        set { finder.isEnabled = newValue }
    }

    var settingsView: AnyView {
        AnyView(FinderExtensionSettings(
            tool: self,
            finder: finder,
            subtitle: Text("Right-click a file › Convert To"),
            hint: Text("Right-click a photo, video or song"),
            help: Text("Right-click a file in Finder and choose Convert To. Pictures, videos and music are saved in another format, like JPEG, MP4 or M4A. The original stays as it is.")
        ) { AnyView(ConvertArt(on: $0)) })
    }

    func refresh() { finder.refresh() }
    func load() { finder.load() }
}

struct ConvertArt: View {
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.3, 1.15, 0.15, 0.5, 0.85, 0.45, 0.9, 0.25, 0.15, 0.35, 2.0]
    private static let click = CGPoint(x: 112, y: 58)

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? 10 : tick % Self.durations.count
            let menu = (3...8).contains(step)
            let picked = (2...9).contains(step)
            let converted = on && step == 10
            let row = CGPoint(x: Self.click.x + 40, y: Self.click.y + 28)
            let jpeg = on ? CGPoint(x: Self.click.x + 128, y: Self.click.y + 28) : row
            Stage {
                ArtWindow(size: CGSize(width: 220, height: 100)) {
                    ZStack {
                        ArtPhotoFile(width: 40, label: "PNG", selected: picked, color: picked ? .primary : .secondary)
                            .position(x: 72, y: 42)
                        ArtPhotoFile(width: 40, label: "JPEG", color: .accentColor)
                            .opacity(converted ? 1 : 0)
                            .scaleEffect(converted ? 1 : 0.6)
                            .position(x: 148, y: 42)
                    }
                }
                .position(x: 150, y: 64)
                if menu {
                    ArtMenu(width: 110) {
                        ArtMenuRow(width: 34)
                        if on { ArtMenuRow(title: Text("Convert To"), active: step >= 5, submenu: true) } else { ArtMenuRow(width: 64) }
                        ArtMenuRow(width: 48)
                    }
                    .position(x: Self.click.x + 55, y: Self.click.y + 26)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if on, (5...8).contains(step) {
                    ArtMenu(width: 56) {
                        ArtMenuRow(title: Text(verbatim: "JPEG"), active: step >= 7)
                        ArtMenuRow(title: Text(verbatim: "HEIC"))
                        ArtMenuRow(title: Text(verbatim: "TIFF"))
                    }
                    .position(x: Self.click.x + 136, y: Self.click.y + 41)
                    .transition(.opacity)
                }
                if (2...3).contains(step) { ArtRipple().position(Self.click) }
                if (8...9).contains(step) { ArtRipple().position(jpeg) }
                ArtCursor(pressed: step == 2 || step == 8)
                    .cursor(at: [CGPoint(x: 236, y: 104), Self.click, Self.click, Self.click, row, row, jpeg, jpeg, jpeg, jpeg, jpeg][step])
                    .opacity(step == 10 ? 0 : 1)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
    }
}
