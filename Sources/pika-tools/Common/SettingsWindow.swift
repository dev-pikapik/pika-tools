import AppKit
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, keyboard, keepAwake, permissions, about

    var id: Self { self }

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .keyboard: String(localized: "Keyboard & Mouse")
        case .keepAwake: String(localized: "Keep Awake")
        case .permissions: String(localized: "Permissions")
        case .about: String(localized: "About")
        }
    }

    private var symbol: String {
        switch self {
        case .general: "gearshape.fill"
        case .keyboard: "keyboard.fill"
        case .keepAwake: "cup.and.saucer.fill"
        case .permissions: "hand.raised.fill"
        case .about: "info.circle.fill"
        }
    }

    private var color: Color {
        switch self {
        case .general, .about: .gray
        case .keyboard, .permissions: .blue
        case .keepAwake: .orange
        }
    }

    private var keywords: [String] {
        switch self {
        case .general:
            [String(localized: "Open at Login"), String(localized: "Appearance"), String(localized: "Language"),
             String(localized: "Updates"), String(localized: "Check for updates automatically")]
        case .keyboard:
            [String(localized: "Block Ctrl shortcuts"), String(localized: "Double-space guard"),
             String(localized: "Repeat delay"), String(localized: "Switch language with Option+Shift")]
        case .keepAwake:
            [String(localized: "Keep your Mac awake"), String(localized: "Keep the display on"),
             String(localized: "Work with the lid closed")]
        case .permissions:
            [String(localized: "Accessibility"), String(localized: "Input Monitoring")]
        case .about:
            ["GitHub", String(localized: "What’s New"), String(localized: "Report a Problem"), String(localized: "License (MIT)")]
        }
    }

    func matches(_ query: String) -> Bool {
        query.isEmpty || ([title] + keywords).contains { $0.localizedStandardContains(query) }
    }

    func icon(size: CGFloat) -> some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.55, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))
            .accessibilityHidden(true)
    }
}

enum SettingsWindow {
    @Observable
    final class Model {
        var selection: SettingsTab? = .general
        var search = ""
    }

    static let model = Model()
    private static var window: NSWindow?

    static func show(_ tab: SettingsTab? = nil) {
        if let tab {
            model.search = ""
            model.selection = tab
        }
        if window == nil { create() }
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    private static func create() {
        let host = NSHostingController(rootView: SettingsView())
        host.sizingOptions = []
        host.sceneBridgingOptions = [.toolbars, .title]
        host.view.frame.size = NSSize(width: 715, height: 560)
        let window = NSWindow(contentViewController: host)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unified
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 715, height: 560))
        window.contentMinSize = NSSize(width: 715, height: 400)
        window.contentMaxSize = NSSize(width: 715, height: 2000)
        window.center()
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
            NSApp.setActivationPolicy(.accessory)
        }
        self.window = window
    }

    static func restart() {
        let helper = Process()
        helper.executableURL = URL(fileURLWithPath: "/bin/bash")
        helper.arguments = ["-c", "while kill -0 \"$1\" 2>/dev/null; do sleep 0.2; done; open \"$2\" --args --settings",
                            "pika-restart", String(ProcessInfo.processInfo.processIdentifier), Bundle.main.bundleURL.path]
        try? helper.run()
        NSApp.terminate(nil)
    }
}

private struct SettingsView: View {
    @Bindable private var model = SettingsWindow.model

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $model.selection) {
                if model.search.isEmpty {
                    Button { model.selection = .about } label: { appCard }
                        .buttonStyle(.plain)
                }
                Section { rows([.general, .keyboard, .keepAwake]) }
                Section { rows([.permissions, .about]) }
            }
            .listStyle(.sidebar)
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 215, ideal: 215, max: 215)
        } detail: {
            detail
                .navigationSplitViewColumnWidth(min: 450, ideal: 500)
                .navigationTitle((model.selection ?? .general).title)
        }
        .searchable(text: $model.search, placement: .sidebar)
        .frame(width: 715)
        .frame(minHeight: 400)
    }

    private func rows(_ tabs: [SettingsTab]) -> some View {
        ForEach(tabs.filter { $0.matches(model.search) }) { tab in
            Label { Text(tab.title) } icon: { tab.icon(size: 20) }
                .tag(tab)
        }
    }

    private var appCard: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: "pika-tools").font(.headline)
                Text("Version \(Updater.shared.current)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var detail: some View {
        switch model.selection ?? .general {
        case .general: GeneralSettings()
        case .keyboard: KeyboardSettings()
        case .keepAwake: KeepAwakeSettings()
        case .permissions: PermissionsView()
        case .about: AboutView()
        }
    }
}

struct SettingsHeader: View {
    let tab: SettingsTab
    var title: String?
    let text: String

    var body: some View {
        Section {
            VStack(spacing: 6) {
                tab.icon(size: 44)
                    .padding(.bottom, 4)
                Text(title ?? tab.title)
                    .font(.title3.weight(.semibold))
                Text(text)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

enum Appearance: String, CaseIterable {
    case system, light, dark

    static var saved: Appearance {
        Appearance(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "") ?? .system
    }

    var title: String {
        switch self {
        case .system: String(localized: "System")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
        }
    }

    func apply() {
        switch self {
        case .system: NSApp.appearance = nil
        case .light: NSApp.appearance = NSAppearance(named: .aqua)
        case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

@Observable
final class Language {
    static let shared = Language()
    static let codes = ["en", "ru", "uk", "de", "fr", "es", "it", "pt-BR", "ja", "zh-Hans", "ko"]

    let atLaunch: String
    var selected: String {
        didSet {
            if selected.isEmpty {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.set([selected], forKey: "AppleLanguages")
            }
        }
    }

    private init() {
        let domain = UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        atLaunch = (domain?["AppleLanguages"] as? [String])?.first ?? ""
        selected = atLaunch
    }

    static func name(_ code: String) -> String {
        let name = Locale(identifier: code).localizedString(forIdentifier: code) ?? code
        return name.prefix(1).uppercased() + name.dropFirst()
    }
}

private struct GeneralSettings: View {
    @Bindable private var loginItem = LoginItem.shared
    @Bindable private var updater = Updater.shared
    @AppStorage("appearance") private var appearance = Appearance.system
    @Bindable private var language = Language.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .general, text: String(localized: "How pika-tools starts, looks and updates."))
            Section {
                Toggle(isOn: $loginItem.isOn) {
                    Text("Open at Login")
                    Text(loginItem.needsApproval
                         ? String(localized: "Allow it in System Settings › General › Login Items")
                         : String(localized: "Starts on its own when you log in"))
                }
                LabeledContent("Appearance") {
                    AppearancePicker(selection: Binding(get: { appearance }, set: { appearance = $0; $0.apply() }))
                }
                Picker("Language", selection: $language.selected) {
                    Text("System").tag("")
                    Divider()
                    ForEach(Language.codes, id: \.self) { Text(verbatim: Language.name($0)).tag($0) }
                }
                if language.selected != language.atLaunch {
                    LabeledContent("Restart pika-tools to apply") {
                        Button("Restart") { SettingsWindow.restart() }
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Section("Updates") {
                Toggle("Check for updates automatically", isOn: $updater.checksAutomatically)
                LabeledContent {
                    if case .available(let version) = updater.state {
                        Button("Update to \(version)") { Task { await updater.install() } }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button("Check Now") { Task { await updater.check() } }
                            .disabled(updater.state == .checking || updater.state == .installing)
                    }
                } label: {
                    Text("Version \(updater.current)")
                    if let status = updater.state.title { Text(status) }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { loginItem.refresh() }
    }
}

private struct AppearancePicker: View {
    @Binding var selection: Appearance

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(Appearance.allCases, id: \.self) { item in
                let selected = item == selection
                Button { selection = item } label: {
                    VStack(spacing: 6) {
                        preview(item)
                            .frame(width: 67, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .strokeBorder(.separator, lineWidth: 0.5)
                            }
                            .overlay {
                                if selected {
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .strokeBorder(Color.accentColor, lineWidth: 3)
                                        .padding(-4)
                                }
                            }
                        Text(item.title)
                            .font(.caption)
                            .foregroundStyle(selected ? Color.accentColor : Color.primary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func preview(_ item: Appearance) -> some View {
        switch item {
        case .light: MiniWindow(dark: false)
        case .dark: MiniWindow(dark: true)
        case .system:
            MiniWindow(dark: false)
                .overlay { MiniWindow(dark: true).mask(Diagonal()) }
        }
    }
}

private struct MiniWindow: View {
    let dark: Bool

    var body: some View {
        let wallpaper = dark
            ? [Color(red: 0.16, green: 0.18, blue: 0.42), Color(red: 0.36, green: 0.20, blue: 0.48)]
            : [Color(red: 0.60, green: 0.78, blue: 0.97), Color(red: 0.88, green: 0.93, blue: 1.0)]
        let bar = Color(white: dark ? 0.36 : 0.82)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 1.5) {
                    ForEach([Color.red, .yellow, .green], id: \.self) { Circle().fill($0).frame(width: 3, height: 3) }
                }
                .padding(.bottom, 2)
                ForEach(0..<3, id: \.self) { _ in Capsule().fill(bar).frame(width: 12, height: 2) }
                Spacer(minLength: 0)
            }
            .padding(4)
            .frame(width: 22)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(white: dark ? 0.22 : 0.93))
            VStack(alignment: .leading, spacing: 4) {
                ForEach([30, 22, 30, 16], id: \.self) { Capsule().fill(bar).frame(width: CGFloat($0), height: 2) }
                Spacer(minLength: 0)
            }
            .padding(.top, 9)
            .padding(.leading, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(white: dark ? 0.13 : 1))
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 3))
        .padding(.leading, 9)
        .padding(.top, 8)
        .background(LinearGradient(colors: wallpaper, startPoint: .topLeading, endPoint: .bottomTrailing))
        .environment(\.colorScheme, dark ? .dark : .light)
        .accessibilityHidden(true)
    }
}

private struct Diagonal: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct KeyboardSettings: View {
    var body: some View {
        Form {
            SettingsHeader(tab: .keyboard, text: String(localized: "Fixes for keys and clicks. Each one works on its own."))
            ForEach(ToolRegistry.shared.tools, id: \.id) { tool in
                Section { tool.settingsView }
            }
        }
        .formStyle(.grouped)
        .environment(\.inSettings, true)
    }
}

private struct AboutView: View {
    private let info = Bundle.main.infoDictionary ?? [:]
    private var version: String {
        "\(info["CFBundleShortVersionString"] ?? "") (\(info["CFBundleVersion"] ?? ""))"
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 4) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .accessibilityHidden(true)
                    Text(verbatim: "pika-tools")
                        .font(.title2.weight(.semibold))
                    Text("Version \(version)")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                    Text("Small fixes for the keyboard, mouse and sleep")
                        .padding(.top, 6)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section {
                link("GitHub", "https://github.com/dev-pikapik/pika-tools")
                link(String(localized: "What’s New"), "https://github.com/dev-pikapik/pika-tools/blob/main/CHANGELOG.md")
                link(String(localized: "Report a Problem"), "https://github.com/dev-pikapik/pika-tools/issues/new/choose")
                link(String(localized: "License (MIT)"), "https://github.com/dev-pikapik/pika-tools/blob/main/LICENSE")
            } footer: {
                Text(verbatim: info["NSHumanReadableCopyright"] as? String ?? "")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .formStyle(.grouped)
    }

    private func link(_ title: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.secondary)
            } label: {
                Text(verbatim: title)
                    .foregroundStyle(.primary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
