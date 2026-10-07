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

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(keys.enumerated()), id: \.offset) { KeyCap(symbol: $0.element) }
        }
        .frame(minWidth: 51, alignment: .leading)
        .accessibilityHidden(true)
    }
}

struct KeyLabel: View {
    var keys: [String] = []
    let title: Text
    var subtitle: Text?

    var body: some View {
        HStack(spacing: 12) {
            if !keys.isEmpty { KeyCaps(keys: keys) }
            RowLabel(title, subtitle)
        }
    }
}
