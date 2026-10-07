import SwiftUI

@Observable
final class ScrollDirectionTool: Tool {
    let id = "wheel-direction"
    let icon = "arrow.up.arrow.down"
    var title: String { String(localized: "Scroll direction for trackpad and mouse") }
    let tab = SettingsTab.mouse

    private static let trackpadKey = "wheel-direction-trackpad-natural"
    private static let mouseKey = "wheel-direction-natural"

    var isActive: Bool { isEnabled && ScrollTap.shared.isActive }

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    private(set) var systemNatural = true

    private var trackpadChoice: Bool? {
        didSet {
            UserDefaults.standard.set(trackpadChoice, forKey: Self.trackpadKey)
            update()
        }
    }

    private var mouseChoice: Bool? {
        didSet {
            UserDefaults.standard.set(mouseChoice, forKey: Self.mouseKey)
            update()
        }
    }

    var trackpadNatural: Bool {
        get { trackpadChoice ?? systemNatural }
        set { trackpadChoice = newValue }
    }

    var mouseNatural: Bool {
        get { mouseChoice ?? systemNatural }
        set { mouseChoice = newValue }
    }

    init() {
        let defaults = UserDefaults.standard
        isEnabled = defaults.bool(forKey: id)
        if isEnabled && defaults.object(forKey: Self.mouseKey) == nil {
            defaults.set(false, forKey: Self.mouseKey)
        }
        trackpadChoice = defaults.object(forKey: Self.trackpadKey) as? Bool
        mouseChoice = defaults.object(forKey: Self.mouseKey) as? Bool
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

    var isDefault: Bool { !isEnabled && trackpadNatural == systemNatural && mouseNatural == systemNatural }

    func reset() {
        isEnabled = false
        trackpadChoice = nil
        mouseChoice = nil
    }

    func load() {
        trackpadChoice = UserDefaults.standard.object(forKey: Self.trackpadKey) as? Bool
        mouseChoice = UserDefaults.standard.object(forKey: Self.mouseKey) as? Bool
        isEnabled = UserDefaults.standard.bool(forKey: id)
    }

    func refresh() {
        update()
        ScrollTap.shared.refresh()
    }

    private func update() {
        CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
        systemNatural = CFPreferencesCopyAppValue("com.apple.swipescrolldirection" as CFString, kCFPreferencesAnyApplication) as? Bool ?? true
        ScrollTap.shared.direction = isEnabled ? ScrollDirection(trackpadNatural: trackpadNatural, mouseNatural: mouseNatural, systemNatural: systemNatural) : nil
    }
}

private struct ScrollDirectionSettings: View {
    @Bindable var tool: ScrollDirectionTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings {
            ScrollDirectionArt(
                trackpadNatural: tool.isEnabled ? tool.trackpadNatural : tool.systemNatural,
                mouseNatural: tool.isEnabled ? tool.mouseNatural : tool.systemNatural
            )
        }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("One way for the trackpad, another for the mouse"),
            hint: Text("One way for the trackpad, another for the mouse"),
            help: Text("The trackpad and the mouse wheel each scroll the way you choose, whatever is set in System Settings. Handy with Universal Control: set the same on each Mac and scrolling feels the same everywhere."),
            isOn: $tool.isEnabled
        )
        if inSettings {
            Group {
                choice(
                    Text("Trackpad direction"),
                    String(localized: "Trackpad direction"),
                    $tool.trackpadNatural,
                    tool.trackpadNatural ? Text("Move two fingers up to go down the page") : Text("Move two fingers down to go down the page")
                )
                choice(
                    Text("Mouse wheel direction"),
                    String(localized: "Mouse wheel direction"),
                    $tool.mouseNatural,
                    tool.mouseNatural ? Text("Roll the wheel toward you to go up the page") : Text("Roll the wheel toward you to go down the page, like on Windows")
                )
            }
            .disabled(!tool.isEnabled)
        }
    }

    private func choice(_ title: Text, _ anchor: String, _ natural: Binding<Bool>, _ subtitle: Text) -> some View {
        LabeledContent {
            Picker(selection: natural) {
                Text("Natural").tag(true)
                Text("Classic").tag(false)
            } label: {
                title
            }
            .labelsHidden()
            .fixedSize()
        } label: {
            RowLabel(title, subtitle)
        }
        .settingAnchor(anchor)
    }
}

struct ScrollDirectionArt: View {
    let trackpadNatural: Bool
    let mouseNatural: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1, 0.9, 1.1]
    private static let pitch: CGFloat = 12
    private static let widths: [CGFloat] = [44, 30, 38]

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
        IllustrationRow {
            Stage {
                ArtTrackpad(touch: rolling, slide: step == 0 ? -9 : 9)
                    .position(x: 40, y: 64)
                page(natural: trackpadNatural, rolls: rolls, rolling: rolling, step: step)
                    .position(x: 114, y: 64)
                ArtMouse(wheel: rolling)
                    .scaleEffect(1.6)
                    .position(x: 189, y: 64)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.accentColor)
                    .opacity(rolling ? 1 : 0)
                    .offset(y: rolling ? 3 : -3)
                    .position(x: 189, y: 61)
                page(natural: mouseNatural, rolls: rolls, rolling: rolling, step: step)
                    .position(x: 252, y: 64)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.5), value: step)
        }
        .loop($tick, Self.durations)
    }

    private func page(natural: Bool, rolls: Int, rolling: Bool, step: Int) -> some View {
        ArtWindow(size: CGSize(width: 76, height: 104)) {
            VStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { index in
                    HStack(spacing: 5) {
                        Circle().fill(Color.accentColor.opacity(0.8)).frame(width: 5, height: 5)
                        Capsule().fill(Color.primary.opacity(0.16)).frame(width: Self.widths[index % 3], height: 4)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: Self.pitch)
                }
            }
            .modifier(Wrapped(offset: CGFloat(rolls) * Self.pitch * 3 * (natural ? -1 : 1)))
            .frame(height: 90, alignment: .top)
            .clipped()
            .overlay(alignment: (step == 0) != natural ? .topTrailing : .bottomTrailing) {
                Capsule()
                    .fill(Color.primary.opacity(0.35))
                    .frame(width: 3, height: 26)
                    .padding(.vertical, 10)
                    .padding(.trailing, 3)
                    .opacity(rolling ? 1 : 0)
            }
        }
    }
}
