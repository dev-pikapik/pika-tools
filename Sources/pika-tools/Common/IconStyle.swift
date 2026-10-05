import AppKit
import SwiftUI

@Observable
final class IconStyle: NSObject {
    enum Kind { case regular, clear, tinted }

    static let shared = IconStyle()
    private static let keys = ["AppleIconAppearanceTheme", "AppleIconAppearanceTintColor", "AppleIconAppearanceCustomTintColor"]

    private(set) var theme = ""
    private(set) var tint: Color?

    private override init() {
        super.init()
        read()
        Self.keys.forEach { UserDefaults.standard.addObserver(self, forKeyPath: $0, options: [], context: nil) }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async { self.read() }
    }

    private func read() {
        let defaults = UserDefaults.standard
        theme = defaults.string(forKey: Self.keys[0]) ?? "RegularLight"
        tint = switch defaults.string(forKey: Self.keys[1]) {
        case "Red": .red
        case "Orange": .orange
        case "Yellow": .yellow
        case "Green": .green
        case "Blue": .blue
        case "Purple": .purple
        case "Pink": .pink
        case "Graphite": .gray
        case "Other":
            (defaults.string(forKey: Self.keys[2])?.split(separator: " ").compactMap { Double($0) })
                .flatMap { $0.count == 4 ? Color(.sRGB, red: $0[0], green: $0[1], blue: $0[2], opacity: $0[3]) : nil }
        default: nil
        }
    }

    var kind: Kind {
        theme.hasPrefix("Clear") ? .clear : theme.hasPrefix("Tinted") ? .tinted : .regular
    }

    func isDark(_ scheme: ColorScheme) -> Bool {
        theme.hasSuffix("Dark") || (theme.hasSuffix("Automatic") && scheme == .dark)
    }
}

struct SectionIcon: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 24
    @Environment(\.colorScheme) private var scheme
    private let style = IconStyle.shared

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.235, style: .continuous)
        let dark = style.isDark(scheme)
        let tint = style.tint ?? .accentColor
        Image(systemName: symbol)
            .font(.system(size: size * 0.56, weight: .medium))
            .symbolRenderingMode(.monochrome)
            .imageScale(.medium)
            .foregroundStyle(glyph(dark: dark, tint: tint))
            .frame(width: size, height: size)
            .background {
                ZStack {
                    shape.fill(base(dark: dark))
                    shape.fill(fill(dark: dark, tint: tint))
                }
            }
            .overlay(shape.strokeBorder(dark ? Color.white.opacity(0.14) : Color.black.opacity(0.06), lineWidth: 0.5))
            .environment(\.colorScheme, dark ? .dark : .light)
            .drawingGroup()
            .accessibilityHidden(true)
    }

    private func base(dark: Bool) -> Color {
        switch style.kind {
        case .regular, .tinted: dark ? Color(white: 0.13) : .white
        case .clear: dark ? Color(white: 0.1).opacity(0.85) : Color.white.opacity(0.8)
        }
    }

    private func fill(dark: Bool, tint: Color) -> LinearGradient {
        let colors: [Color] = switch (style.kind, dark) {
        case (.regular, false): [color.opacity(0.82), color]
        case (.regular, true): [Color(white: 0.17), Color(white: 0.11)]
        case (.clear, false): [Color.white.opacity(0.6), Color(white: 0.85).opacity(0.5)]
        case (.clear, true): [Color.white.opacity(0.16), Color.white.opacity(0.07)]
        case (.tinted, false): [tint.opacity(0.14), tint.opacity(0.26)]
        case (.tinted, true): [tint.opacity(0.32), tint.opacity(0.18)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    private func glyph(dark: Bool, tint: Color) -> Color {
        switch (style.kind, dark) {
        case (.regular, false): .white
        case (.regular, true): color
        case (.clear, false): Color(white: 0.4)
        case (.clear, true): .white.opacity(0.92)
        case (.tinted, false): tint
        case (.tinted, true): tint
        }
    }
}
