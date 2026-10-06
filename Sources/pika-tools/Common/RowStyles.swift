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
