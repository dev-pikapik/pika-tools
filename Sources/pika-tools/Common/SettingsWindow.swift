import AppKit
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, keyboard, windows, keepAwake, permissions, about

    var id: Self { self }

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .keyboard: String(localized: "Keyboard & Mouse")
        case .windows: String(localized: "Windows & Apps")
        case .keepAwake: String(localized: "Keep Awake")
        case .permissions: String(localized: "Permissions")
        case .about: String(localized: "About")
        }
    }

    private var symbol: String {
        switch self {
        case .general: "gearshape.fill"
        case .keyboard: "keyboard.fill"
        case .windows: "macwindow.on.rectangle"
        case .keepAwake: "cup.and.saucer.fill"
        case .permissions: "hand.raised.fill"
        case .about: "info.circle.fill"
        }
    }

    private var color: Color {
        switch self {
        case .general, .about: .gray
        case .keyboard, .permissions: .blue
        case .windows: .indigo
        case .keepAwake: .orange
        }
    }

    static var iconSize: CGFloat {
        switch UserDefaults.standard.integer(forKey: "NSTableViewDefaultSizeMode") {
        case 1: 18
        case 3: 24
        default: 20
        }
    }

    func icon(size: CGFloat = iconSize) -> some View {
        SectionIcon(symbol: symbol, color: color, size: size)
    }
}

struct SettingsItem: Identifiable {
    let tab: SettingsTab
    let title: String
    var synonyms = ""

    var id: String { title }

    static var all: [SettingsItem] {
        [
            SettingsItem(tab: .general, title: String(localized: "Open at Login"), synonyms: "launch, startup, autostart, login items"),
            SettingsItem(tab: .general, title: String(localized: "Appearance"), synonyms: "theme, dark mode, light mode, colors"),
            SettingsItem(tab: .general, title: String(localized: "Language"), synonyms: "localization, translation"),
            SettingsItem(tab: .keyboard, title: String(localized: "Block ⌃ Control shortcuts"), synonyms: "ctrl, control key, shortcuts, right-click, context menu"),
            SettingsItem(tab: .keyboard, title: String(localized: "Protect ⌘Q and ⌘W"), synonyms: "quit, close, command, accidental, shortcut"),
            SettingsItem(tab: .keyboard, title: String(localized: "Switch language with ⌥⇧"), synonyms: "keyboard layout, input source, option, shift, alt"),
            SettingsItem(tab: .windows, title: String(localized: "Quit when the last window closes"), synonyms: "close button, red button, terminate, exit"),
            SettingsItem(tab: .windows, title: String(localized: "Never quit these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .windows, title: String(localized: "Hide with a click in the Dock"), synonyms: "Dock, minimize, hide, Windows, taskbar"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Keep your Mac awake"), synonyms: "sleep, caffeine, insomnia"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Duration"), synonyms: "time, timer, hours, minutes"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Keep the display on"), synonyms: "screen, monitor, dim, screen saver"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Work with the lid closed"), synonyms: "clamshell, laptop, MacBook, external display"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Stop when battery is below \(0.2.formatted(.percent))"), synonyms: "battery, power, charge"),
            SettingsItem(tab: .permissions, title: String(localized: "Accessibility"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "Input Monitoring"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .about, title: String(localized: "Check for updates automatically"), synonyms: "update, new version, software update"),
            SettingsItem(tab: .about, title: String(localized: "What’s New"), synonyms: "changelog, release notes, version"),
            SettingsItem(tab: .about, title: String(localized: "Report a Problem"), synonyms: "bug, issue, feedback, support"),
            SettingsItem(tab: .about, title: String(localized: "License (MIT)"), synonyms: "open source, legal"),
            SettingsItem(tab: .about, title: "GitHub", synonyms: "open source, legal"),
        ]
    }

    func matches(_ query: String) -> Bool {
        let words = synonyms + ", " + Bundle.main.localizedString(forKey: synonyms, value: nil, table: nil)
        return [title, words].contains { $0.localizedStandardContains(query) }
    }
}

enum SettingsWindow {
    @Observable
    final class Model {
        var selection: SettingsTab? = .general {
            didSet {
                guard !navigating, let oldValue, oldValue != selection else { return }
                back.append(oldValue)
                forward = []
            }
        }
        var search = ""
        var highlight: String?
        private(set) var back: [SettingsTab] = []
        private(set) var forward: [SettingsTab] = []
        @ObservationIgnored private var navigating = false

        func goBack() {
            guard let tab = back.popLast() else { return }
            selection.map { forward.append($0) }
            move(to: tab)
        }

        func goForward() {
            guard let tab = forward.popLast() else { return }
            selection.map { back.append($0) }
            move(to: tab)
        }

        private func move(to tab: SettingsTab) {
            navigating = true
            selection = tab
            navigating = false
        }

        func open(_ item: SettingsItem) {
            selection = item.tab
            highlight = nil
            highlight = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if self.highlight == item.id { self.highlight = nil }
            }
        }
    }

    static let model = Model()
    private(set) static var window: NSWindow?

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
        let width: CGFloat = 860
        let height = min(720, (NSScreen.main?.visibleFrame.height ?? 900) - 80)
        let host = NSHostingController(rootView: SettingsView())
        host.sizingOptions = []
        host.sceneBridgingOptions = [.toolbars, .title]
        let window = NSWindow(contentViewController: host)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unified
        window.collectionBehavior.insert(.fullScreenNone)
        window.isReleasedWhenClosed = false
        window.title = (model.selection ?? .general).title
        window.contentMinSize = NSSize(width: 700, height: 500)
        window.setContentSize(NSSize(width: width, height: height))
        window.center()
        window.setFrameAutosaveName("Settings")
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
        let tab = model.selection ?? .general
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $model.selection) {
                if model.search.isEmpty {
                    Section { rows([.general, .keyboard, .windows, .keepAwake]) }
                    Section { rows([.permissions, .about]) }
                } else {
                    results
                }
            }
            .listStyle(.sidebar)
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 320)
        } detail: {
            detail(tab)
                .navigationTitle(tab.title)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        ControlGroup {
                            Button { model.goBack() } label: { Label("Back", systemImage: "chevron.backward") }
                                .keyboardShortcut("[")
                                .disabled(model.back.isEmpty)
                            Button { model.goForward() } label: { Label("Forward", systemImage: "chevron.forward") }
                                .keyboardShortcut("]")
                                .disabled(model.forward.isEmpty)
                        }
                        .controlGroupStyle(.navigation)
                    }
                }
        }
        .searchable(text: $model.search, placement: .sidebar)
        .onChange(of: tab, initial: true) { SettingsWindow.window?.title = tab.title }
    }

    private func rows(_ tabs: [SettingsTab]) -> some View {
        ForEach(tabs) { tab in
            Label { Text(tab.title) } icon: { tab.icon() }
                .tag(tab)
        }
    }

    @ViewBuilder
    private var results: some View {
        let query = model.search.trimmingCharacters(in: .whitespaces)
        let items = SettingsItem.all.filter { $0.matches(query) }
        let tabs = SettingsTab.allCases.filter { tab in
            tab.title.localizedStandardContains(query) || items.contains { $0.tab == tab }
        }
        if tabs.isEmpty {
            Text("No Results")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
        ForEach(tabs) { tab in
            Label { Text(tab.title) } icon: { tab.icon() }
                .tag(tab)
            ForEach(items.filter { $0.tab == tab }) { item in
                Button { model.open(item) } label: {
                    Text(item.title)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.leading, SettingsTab.iconSize + 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func detail(_ tab: SettingsTab) -> some View {
        switch tab {
        case .general: GeneralSettings()
        case .keyboard: ToolsSettings(tab: .keyboard, text: String(localized: "Fixes for keys and clicks. Each one works on its own."))
        case .windows: ToolsSettings(tab: .windows, text: String(localized: "Fixes for windows and the Dock. Each one works on its own."))
        case .keepAwake: KeepAwakeSettings()
        case .permissions: PermissionsView()
        case .about: AboutView()
        }
    }
}

extension View {
    func settingAnchor(_ id: String) -> some View {
        modifier(SettingAnchor(id: id))
    }

    func settingsPage() -> some View {
        modifier(SettingsPage())
    }
}

private struct SettingAnchor: ViewModifier {
    let id: String
    private let model = SettingsWindow.model

    func body(content: Content) -> some View {
        content
            .id(id)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(model.highlight == id ? 0.25 : 0))
                    .padding(.horizontal, -8)
                    .padding(.vertical, -6)
                    .animation(.easeInOut(duration: 0.4), value: model.highlight)
            }
    }
}

private struct SettingsPage: ViewModifier {
    private let model = SettingsWindow.model

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onAppear { scroll(proxy) }
                .onChange(of: model.highlight) { scroll(proxy) }
        }
    }

    private func scroll(_ proxy: ScrollViewProxy) {
        guard let id = model.highlight else { return }
        DispatchQueue.main.async {
            withAnimation { proxy.scrollTo(id, anchor: .center) }
        }
    }
}

struct SettingsHeader: View {
    let tab: SettingsTab
    var title: String?
    let text: String

    var body: some View {
        Section {
            VStack(spacing: 0) {
                tab.icon(size: 48)
                    .padding(.bottom, 12)
                Text(title ?? tab.title)
                    .font(.title.bold())
                    .padding(.bottom, 4)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .padding(.horizontal, 24)
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
    @AppStorage("appearance") private var appearance = Appearance.system
    @Bindable private var language = Language.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .general, text: String(localized: "How pika-tools starts and looks."))
            Section {
                Toggle(isOn: $loginItem.isOn) {
                    Text("Open at Login")
                    Text(loginItem.needsApproval
                         ? String(localized: "Allow it in System Settings › General › Login Items")
                         : String(localized: "Starts on its own when you log in"))
                }
                .settingAnchor(String(localized: "Open at Login"))
                LabeledContent("Appearance") {
                    AppearancePicker(selection: Binding(get: { appearance }, set: { appearance = $0; $0.apply() }))
                }
                .settingAnchor(String(localized: "Appearance"))
                Picker("Language", selection: $language.selected) {
                    Text("System").tag("")
                    Divider()
                    ForEach(Language.codes, id: \.self) { Text(verbatim: Language.name($0)).tag($0) }
                }
                .settingAnchor(String(localized: "Language"))
                if language.selected != language.atLaunch {
                    LabeledContent("Restart pika-tools to apply") {
                        Button("Restart") { SettingsWindow.restart() }
                    }
                    .foregroundStyle(.secondary)
                }
            }

        }
        .formStyle(.grouped)
        .settingsPage()
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

private struct ToolsSettings: View {
    let tab: SettingsTab
    let text: String

    var body: some View {
        Form {
            SettingsHeader(tab: tab, text: text)
            ForEach(ToolRegistry.shared.tools.filter { $0.tab == tab }, id: \.id) { tool in
                Section { tool.settingsView }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .environment(\.inSettings, true)
    }
}

private struct AboutView: View {
    @Bindable private var updater = Updater.shared
    private let info = Bundle.main.infoDictionary ?? [:]
    private var version: String {
        "\(info["CFBundleShortVersionString"] ?? "") (\(info["CFBundleVersion"] ?? ""))"
    }
    private var icon: NSImage {
        _ = IconStyle.shared.theme
        return NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 4) {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 96, height: 96)
                        .accessibilityHidden(true)
                    Text(verbatim: "pika-tools")
                        .font(.title.bold())
                    Text("Small fixes for the keyboard, mouse and sleep")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }

            Section("Updates") {
                Toggle("Check for updates automatically", isOn: $updater.checksAutomatically)
                    .settingAnchor(String(localized: "Check for updates automatically"))
                LabeledContent {
                    if case .available(let version) = updater.state {
                        Button("Update to \(version)") { Task { await updater.install() } }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button("Check Now") { Task { await updater.check() } }
                            .disabled(updater.state == .checking || updater.state == .installing)
                    }
                } label: {
                    Text("Version \(version)")
                        .textSelection(.enabled)
                    if let status = updater.state.title { Text(status) }
                }
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
        .settingsPage()
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
        .settingAnchor(title)
    }
}
