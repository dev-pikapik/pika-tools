import SwiftUI

struct RowLabel: View {
    let title: Text
    var subtitle: Text?

    init(_ title: Text, _ subtitle: Text? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            title
            if let subtitle {
                subtitle
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct CenteredLabeledContentStyle: LabeledContentStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 12) {
            configuration.label
                .opacity(isEnabled ? 1 : 0.5)
            Spacer(minLength: 0)
            configuration.content
        }
    }
}

struct CenteredSwitchStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 12) {
            configuration.label
                .opacity(isEnabled ? 1 : 0.5)
            Spacer(minLength: 0)
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

struct KeyCap: View {
    let symbol: String

    var body: some View {
        Text(verbatim: symbol)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .padding(.horizontal, 5)
            .frame(minWidth: 24, minHeight: 24)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
    }
}

struct KeyCaps: View {
    let keys: [String]
    var system = false

    var body: some View {
        if system {
            Button { NSWorkspace.shared.open(SystemShortcuts.settings) } label: { caps }
                .buttonStyle(CapsButtonStyle())
                .help(Text("Change in System Settings"))
                .accessibilityLabel(Text(verbatim: shown.map { $0.isEmpty ? String(localized: "Off") : $0 }.joined(separator: ", ")))
                .accessibilityHint(Text("Change in System Settings"))
        } else {
            caps.accessibilityHidden(true)
        }
    }

    private var shown: [String] {
        let live = keys.filter { !$0.isEmpty }
        return !keys.isEmpty && live.allSatisfy { $0 == "…" } ? [""] : live
    }

    private var caps: some View {
        HStack(spacing: 6) {
            ForEach(Array(shown.enumerated()), id: \.offset) { _, shortcut in
                if shortcut.isEmpty {
                    Text("Off").foregroundStyle(.secondary)
                } else if shortcut == "…" {
                    Text(verbatim: shortcut).foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 2) {
                        ForEach(Array(Self.caps(shortcut).enumerated()), id: \.offset) { KeyCap(symbol: $0.element) }
                    }
                }
            }
        }
        .fixedSize()
    }

    static func caps(_ shortcut: String) -> [String] {
        let modifiers = shortcut.prefix { "⌃⌥⇧⌘🌐".contains($0) }
        let key = shortcut.dropFirst(modifiers.count)
        return modifiers.map(String.init) + (key.isEmpty ? [] : [String(key)])
    }
}

struct KeyLabel: View {
    var keys: [String] = []
    var system = false
    let title: Text
    var subtitle: Text?

    var body: some View {
        HStack(spacing: 12) {
            if !keys.isEmpty { KeyCaps(keys: keys, system: system) }
            RowLabel(title, subtitle)
        }
    }
}
