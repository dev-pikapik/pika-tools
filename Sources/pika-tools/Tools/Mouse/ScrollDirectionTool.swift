import SwiftUI

@Observable
final class ScrollDirectionTool: Tool {
    let id = "wheel-direction"
    let icon = "arrow.up.arrow.down"
    var title: String { String(localized: "Separate scroll direction for the mouse") }
    let tab = SettingsTab.mouse

    private static let naturalKey = "wheel-direction-natural"

    var isActive: Bool { isEnabled && ScrollTap.shared.isActive }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    private(set) var systemNatural = true

    var natural: Bool {
        didSet {
            UserDefaults.standard.set(natural, forKey: Self.naturalKey)
            update()
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: id)
        natural = UserDefaults.standard.bool(forKey: Self.naturalKey)
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("SwipeScrollDirectionDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.update()
        }
    }

    var settingsView: AnyView {
        AnyView(ScrollDirectionSettings(tool: self))
    }

    var isDefault: Bool { !isEnabled && !natural }

    func reset() {
        isEnabled = false
        natural = false
    }

    func load() {
        natural = UserDefaults.standard.bool(forKey: Self.naturalKey)
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func refresh() {
        update()
        ScrollTap.shared.refresh()
    }

    private func update() {
        CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        let system = CFPreferencesCopyAppValue("com.apple.swipescrolldirection" as CFString, kCFPreferencesAnyApplication) as? Bool ?? true
        systemNatural = system
        ScrollTap.shared.direction = isEnabled ? ScrollDirection(natural: natural, systemNatural: system) : nil
    }
}

private struct ScrollDirectionSettings: View {
    @Bindable var tool: ScrollDirectionTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { ScrollDirectionArt(natural: tool.isEnabled ? tool.natural : tool.systemNatural) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("Trackpad stays as it is"),
            hint: Text("Trackpad stays as it is"),
            help: Text("The mouse wheel scrolls the way you choose, and the trackpad keeps the direction set in System Settings. Handy with Universal Control."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Picker(selection: $tool.natural) {
                Text("Natural").tag(true)
                Text("Classic").tag(false)
            } label: {
                Text("Mouse wheel direction")
                Text(tool.natural ? "Roll the wheel toward you to go up the page, like on a trackpad" : "Roll the wheel toward you to go down the page, like on Windows")
            }
            .disabled(!tool.isEnabled)
            .settingAnchor(String(localized: "Mouse wheel direction"))
        }
    }
}

struct ScrollDirectionArt: View {
    let natural: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1, 0.9, 1.1]
    private static let pitch: CGFloat = 12
    private static let widths: [CGFloat] = [64, 46, 56]

    private struct Wrapped: ViewModifier, Animatable {
        var offset: CGFloat
        var animatableData: CGFloat {
            get { offset }
            set { offset = newValue }
        }

        func body(content: Content) -> some View {
            let cycle = ScrollDirectionArt.pitch * 3
            let rest = offset.truncatingRemainder(dividingBy: cycle)
            content.offset(y: -(rest < 0 ? rest + cycle : rest))
        }
    }

    var body: some View {
        let step = reduceMotion ? 1 : tick % Self.durations.count
        let rolls = reduceMotion ? 0 : tick / Self.durations.count + (step == 0 ? 0 : 1)
        let rolling = step == 1
        let thumbTop = (step == 0) != natural
        IllustrationRow {
            Stage {
                ArtMouse(wheel: rolling)
                    .scaleEffect(2.3)
                    .position(x: 62, y: 64)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .opacity(rolling ? 1 : 0)
                    .offset(y: rolling ? 4 : -4)
                    .position(x: 62, y: 58)
                ArtWindow(size: CGSize(width: 140, height: 108)) {
                    VStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { index in
                            HStack(spacing: 6) {
                                Circle().fill(Color.accentColor.opacity(0.8)).frame(width: 6, height: 6)
                                Capsule().fill(Color.primary.opacity(0.16)).frame(width: Self.widths[index % 3], height: 4)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: Self.pitch)
                        }
                    }
                    .modifier(Wrapped(offset: CGFloat(rolls) * Self.pitch * 3 * (natural ? -1 : 1)))
                    .frame(height: 94, alignment: .top)
                    .clipped()
                    .overlay(alignment: thumbTop ? .topTrailing : .bottomTrailing) {
                        Capsule()
                            .fill(Color.primary.opacity(0.35))
                            .frame(width: 4, height: 30)
                            .padding(.vertical, 12)
                            .padding(.trailing, 3)
                            .opacity(rolling ? 1 : 0)
                    }
                }
                .position(x: 212, y: 64)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
        .loop($tick, Self.durations)
    }
}
