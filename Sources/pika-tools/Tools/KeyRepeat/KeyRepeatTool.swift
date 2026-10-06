import SwiftUI

@Observable
final class KeyRepeatTool: Tool {
    let id = "key-repeat"
    let icon = "repeat"
    var title: String { String(localized: "Repeat a held key") }

    var isActive: Bool { isEnabled }

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            UserDefaults.standard.set(isEnabled, forKey: id)
            Self.write(isEnabled ? false as CFBoolean : nil)
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    var settingsView: AnyView {
        AnyView(KeyRepeatSettings(tool: self))
    }

    func refresh() {
        if isEnabled { Self.write(false as CFBoolean) }
    }

    private static func write(_ value: CFPropertyList?) {
        let key = "ApplePressAndHoldEnabled" as CFString
        CFPreferencesSetValue(key, value, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    }
}

struct KeyRepeatArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    private static let durations = [0.8, 0.6, 0.35, 0.35, 0.35, 0.35, 0.35, 1.4]
    private static let accents = ["à", "á", "â", "ä", "ã"]

    var body: some View {
        let step = reduceMotion ? 6 : tick % Self.durations.count
        let down = (1...6).contains(step)
        let typed = on ? String(repeating: "a", count: step == 7 ? 6 : step) : (step == 0 ? "" : step == 7 ? "â" : "a")
        let picked = max(step - 2, 0)
        IllustrationRow {
            Stage {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(down ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                    .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
                    .overlay {
                        Text(verbatim: "a")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(down ? Color.white : Color.primary)
                    }
                    .frame(width: 38, height: 38)
                    .shadow(color: .black.opacity(down ? 0.05 : 0.2), radius: down ? 0.5 : 2, y: down ? 0.5 : 2)
                    .scaleEffect(down ? 0.93 : 1)
                    .position(x: 62, y: 80)
                field(typed)
                    .position(x: 196, y: 84)
                if !on {
                    popup(picked: picked)
                        .scaleEffect(step >= 2 && step <= 6 ? 1 : 0.8, anchor: .bottomLeading)
                        .opacity(step >= 2 && step <= 6 ? 1 : 0)
                        .position(x: 177, y: 46)
                }
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: step)
        }
        .loop($tick, Self.durations)
    }

    private func field(_ text: String) -> some View {
        HStack(spacing: 1) {
            Text(verbatim: text)
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(.primary)
            Rectangle().fill(Color.accentColor).frame(width: 1.5, height: 19)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(width: 168, height: 32)
        .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(Color.primary.opacity(0.18), lineWidth: 0.5))
    }

    private func popup(picked: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.accents.enumerated()), id: \.offset) { index, letter in
                Text(verbatim: letter)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(index == picked ? Color.white : Color.primary)
                    .frame(width: 24, height: 26)
                    .background(index == picked ? Color.accentColor : .clear, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .padding(4)
        .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
    }
}

private struct KeyRepeatSettings: View {
    @Bindable var tool: KeyRepeatTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { KeyRepeatArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Holding a key repeats it instead of opening the accent menu. Restart open apps to apply."),
            hint: Text("Instead of the accent menu"),
            isOn: $tool.isEnabled
        )
    }
}
