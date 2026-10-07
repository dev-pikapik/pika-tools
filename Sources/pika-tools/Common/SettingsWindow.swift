import AppKit
import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, keepAwake, keyboard, mouse, windows, dock, finder, games, permissions, about

    var id: Self { self }

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .keepAwake: String(localized: "Keep Awake")
        case .keyboard: String(localized: "Keyboard")
        case .mouse: String(localized: "Mouse")
        case .windows: String(localized: "Windows")
        case .dock: String(localized: "Dock")
        case .finder: String(localized: "Finder")
        case .games: String(localized: "Games")
        case .permissions: String(localized: "Permissions")
        case .about: String(localized: "About")
        }
    }

    private var symbol: String {
        switch self {
        case .general: "gearshape.fill"
        case .keepAwake: "cup.and.saucer.fill"
        case .keyboard: "keyboard.fill"
        case .mouse: "computermouse.fill"
        case .windows: "macwindow.on.rectangle"
        case .dock: "dock.rectangle"
        case .finder: "folder.fill"
        case .games: "gamecontroller.fill"
        case .permissions: "hand.raised.fill"
        case .about: "info.circle.fill"
        }
    }

    private var color: Color {
        switch self {
        case .general, .dock, .about: .gray
        case .keyboard, .mouse, .permissions: .blue
        case .windows: .indigo
        case .finder: .cyan
        case .games: .purple
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
            SettingsItem(tab: .general, title: String(localized: "Settings file"), synonyms: "backup, export, import, restore, JSON"),
            SettingsItem(tab: .general, title: String(localized: "Sync settings with iCloud"), synonyms: "iCloud Drive, another Mac, backup"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Keep your Mac awake"), synonyms: "sleep, caffeine, insomnia"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Duration"), synonyms: "time, timer, days, hours, minutes, seconds"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Keep the display on"), synonyms: "screen, monitor, dim, screen saver"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Work with the lid closed"), synonyms: "clamshell, laptop, MacBook, external display"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Buttons in Control Center and widgets"), synonyms: "widget, Control Center, Shortcuts, menu bar, button"),
            SettingsItem(tab: .keepAwake, title: String(localized: "Stop when battery is below \(0.2.formatted(.percent))"), synonyms: "battery, power, charge"),
            SettingsItem(tab: .keyboard, title: String(localized: "Block Control shortcuts"), synonyms: "ctrl, control key, shortcuts, right-click, context menu"),
            SettingsItem(tab: .keyboard, title: String(localized: "Works as usual in these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .keyboard, title: String(localized: "Switch language"), synonyms: "keyboard layout, input source, option, shift, alt"),
            SettingsItem(tab: .keyboard, title: String(localized: "Repeat a held key"), synonyms: "key repeat, hold, accent menu, games, typing"),
            SettingsItem(tab: .keyboard, title: String(localized: "Home and End go to the start and end of a line"), synonyms: "home, end, line, cursor, beginning, select, text, typing"),
            SettingsItem(tab: .keyboard, title: String(localized: "Home and End work as usual in these apps"), synonyms: "exceptions, exclude, list, terminal, virtual machine, remote desktop"),
            SettingsItem(tab: .mouse, title: String(localized: "Turn off pointer acceleration"), synonyms: "linear, LinearMouse, mouse acceleration, sensitivity"),
            SettingsItem(tab: .mouse, title: String(localized: "Tracking speed"), synonyms: "pointer speed, sensitivity, fast, slow"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll by lines"), synonyms: "wheel, scrolling speed, acceleration"),
            SettingsItem(tab: .mouse, title: String(localized: "Distance per click"), synonyms: "scrolling speed, wheel, notch"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll by"), synonyms: "pixels, lines, wheel, games, scrolling mode, notch"),
            SettingsItem(tab: .mouse, title: String(localized: "Scroll direction for trackpad and mouse"), synonyms: "natural scrolling, classic, reverse, invert, Universal Control, trackpad, mouse, Magic Mouse, wheel, direction"),
            SettingsItem(tab: .mouse, title: String(localized: "Trackpad direction"), synonyms: "natural, classic, reverse, invert, trackpad, two fingers, Magic Mouse, up, down"),
            SettingsItem(tab: .mouse, title: String(localized: "Mouse wheel direction"), synonyms: "natural, classic, reverse, invert, wheel, up, down"),
            SettingsItem(tab: .mouse, title: String(localized: "Side buttons go back and forward"), synonyms: "buttons 4 and 5, browser, navigation, thumb buttons"),
            SettingsItem(tab: .mouse, title: String(localized: "Swap the side buttons"), synonyms: "reverse, back, forward"),
            SettingsItem(tab: .windows, title: String(localized: "Green button enlarges the window"), synonyms: "zoom, maximize, full screen, green button, option click"),
            SettingsItem(tab: .windows, title: String(localized: "Green button works as usual in these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .windows, title: String(localized: "Protect quitting and closing"), synonyms: "quit, close, command, accidental, shortcut"),
            SettingsItem(tab: .windows, title: String(localized: "Quit when the last window closes"), synonyms: "close button, red button, terminate, exit"),
            SettingsItem(tab: .windows, title: String(localized: "Never quit these apps"), synonyms: "exceptions, exclude, list"),
            SettingsItem(tab: .dock, title: String(localized: "Hide with a click in the Dock"), synonyms: "Dock, minimize, hide, taskbar"),
            SettingsItem(tab: .finder, title: String(localized: "New File in Finder"), synonyms: "create, text file, txt, right-click, context menu, Desktop"),
            SettingsItem(tab: .finder, title: String(localized: "Smaller Copy in Finder"), synonyms: "compress, shrink, smaller, reduce size, optimize, image, photo, picture, video, audio, music, PNG, JPEG, JPG, HEIC, TIFF, PDF, GIF, MP4, MOV, M4A, WAV, AIFF, TinyPNG"),
            SettingsItem(tab: .finder, title: String(localized: "Convert in Finder"), synonyms: "convert, format, export, save as, image, photo, picture, video, audio, music, PNG, JPEG, JPG, HEIC, TIFF, PDF, GIF, MP4, MOV, M4A, WAV, AIFF"),
            SettingsItem(tab: .finder, title: String(localized: "Enter opens files in Finder"), synonyms: "return, enter, open, rename, F2, keyboard"),
            SettingsItem(tab: .finder, title: String(localized: "Cut files in Finder"), synonyms: "cut, paste, move, files, folders, command X"),
            SettingsItem(tab: .finder, title: String(localized: "Delete removes files in Finder"), synonyms: "delete, backspace, trash, remove, files, folders, keyboard"),
            SettingsItem(tab: .games, title: String(localized: "Game Mode"), synonyms: "game, games, gaming, play, Steam, full screen"),
            SettingsItem(tab: .games, title: String(localized: "Search and Siri"), synonyms: "Spotlight, Siri, fn, globe key, emoji, dictation"),
            SettingsItem(tab: .games, title: String(localized: "Other apps and desktops"), synonyms: "Command Tab, Mission Control, desktops, Spaces, swipe, hide, minimize"),
            SettingsItem(tab: .games, title: String(localized: "The game doesn’t close by accident")),
            SettingsItem(tab: .games, title: String(localized: "The pointer stays in the game"), synonyms: "mouse, cursor, Dock, menu bar, hot corners, edges, second display"),
            SettingsItem(tab: .games, title: String(localized: "The keyboard language doesn’t change"), synonyms: "input source, keyboard layout, Caps Lock"),
            SettingsItem(tab: .games, title: String(localized: "The screen stays on")),
            SettingsItem(tab: .games, title: String(localized: "Your games")),
            SettingsItem(tab: .permissions, title: String(localized: "Accessibility"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "Input Monitoring"), synonyms: "privacy, security, access"),
            SettingsItem(tab: .permissions, title: String(localized: "iCloud Drive"), synonyms: "privacy, security, access"),
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
        var confirmingReset = false
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

    static let minSize = NSSize(width: 660, height: 460)

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
        host.sizingOptions = [.minSize]
        host.sceneBridgingOptions = [.toolbars, .title]
        let window = NSWindow(contentViewController: host)
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.toolbarStyle = .unified
        window.collectionBehavior.insert(.fullScreenNone)
        window.isReleasedWhenClosed = false
        window.title = (model.selection ?? .general).title
        window.setContentSize(NSSize(width: width, height: height))
        window.center()
        window.setFrameAutosaveName("Settings")
        let saved = window.contentRect(forFrameRect: window.frame).size
        window.setContentSize(NSSize(width: max(saved.width, minSize.width), height: max(saved.height, minSize.height)))
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
    @State private var columns = NavigationSplitViewVisibility.all

    var body: some View {
        let tab = model.selection ?? .general
        NavigationSplitView(columnVisibility: $columns) {
            List(selection: $model.selection) {
                if model.search.isEmpty {
                    Section { rows([.general, .keepAwake, .keyboard, .mouse, .windows, .dock, .finder, .games]) }
                    Section { rows([.permissions, .about]) }
                } else {
                    results
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 320)
        } detail: {
            detail(tab)
                .navigationSplitViewColumnWidth(min: 440, ideal: 520)
                .navigationTitle(tab.title)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            withAnimation { columns = columns == .detailOnly ? .all : .detailOnly }
                        } label: { Label("Sidebar", systemImage: "sidebar.left") }
                        .help(Text("Sidebar"))
                    }
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
        .frame(minWidth: SettingsWindow.minSize.width, minHeight: SettingsWindow.minSize.height)
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
        case .keepAwake: KeepAwakeSettings()
        case .keyboard: ToolsSettings(tab: .keyboard, text: String(localized: "Fixes for the keyboard"))
        case .mouse: ToolsSettings(tab: .mouse, text: String(localized: "Fixes for the mouse"))
        case .windows:
            ToolsSettings(
                tab: .windows,
                text: String(localized: "Fixes for windows and quitting apps"),
                headings: ["window-zoom": "Size", "quit-on-close": "Closing and Quitting"]
            )
        case .dock: ToolsSettings(tab: .dock, text: String(localized: "A fix for the Dock."))
        case .finder: ToolsSettings(tab: .finder, text: String(localized: "Fixes for Finder"))
        case .games: ToolsSettings(tab: .games, text: String(localized: "Your Mac doesn’t pull you out of a game"))
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
                .labeledContentStyle(CenteredLabeledContentStyle())
                .toggleStyle(CenteredSwitchStyle())
                .labelStyle(.titleAndIcon)
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

struct RestoreDefaultsSection: View {
    let message: String
    let isDefault: Bool
    let reset: () -> Void
    @Bindable private var model = SettingsWindow.model

    var body: some View {
        Section {
        } footer: {
            HStack {
                Spacer()
                Button("Restore Defaults…", systemImage: "arrow.counterclockwise") { model.confirmingReset = true }
                    .disabled(isDefault)
            }
        }
        .alert("Restore default settings?", isPresented: $model.confirmingReset) {
            Button("Restore Defaults", action: reset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

struct SettingsHeader: View {
    let tab: SettingsTab
    var title: String?
    let text: String
    var appIcon: NSImage?

    var body: some View {
        Section {
            VStack(spacing: 0) {
                Group {
                    if let appIcon {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(-6)
                            .accessibilityHidden(true)
                    } else {
                        tab.icon(size: 48)
                    }
                }
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
    static let codes = ["en", "ru", "uk", "de", "fr", "es", "it", "pt-BR", "nl", "sv", "pl", "cs", "ro", "tr", "ja", "zh-Hans", "zh-Hant", "ko", "ar", "hi", "th", "vi", "id"]

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
        atLaunch = Self.saved
        selected = atLaunch
    }

    private static var saved: String {
        let domain = UserDefaults.standard.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        return (domain?["AppleLanguages"] as? [String])?.first ?? ""
    }

    func load() {
        selected = Self.saved
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
    @Bindable private var sync = SettingsSync.shared

    @ViewBuilder private var backupButtons: some View {
        Button("Import Settings…", systemImage: "square.and.arrow.down") { SettingsBackup.chooseImport() }
        Button("Export Settings…", systemImage: "square.and.arrow.up") { SettingsBackup.export() }
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .general, text: String(localized: "How pika-tools starts and looks."))
            Section {
                Toggle(isOn: $loginItem.isOn) {
                    RowLabel(Text("Open at Login"), Text(loginItem.needsApproval
                         ? String(localized: "Allow it in System Settings › General › Login Items")
                         : String(localized: "Starts on its own when you log in")))
                }
                .settingAnchor(String(localized: "Open at Login"))
                LabeledContent("Appearance") {
                    AppearancePicker(selection: Binding(get: { appearance }, set: { appearance = $0; $0.apply() }))
                        .fixedSize()
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
                        Button("Restart", systemImage: "arrow.clockwise") { SettingsWindow.restart() }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            Section("Backup") {
                VStack(alignment: .leading, spacing: 10) {
                    RowLabel(Text("Settings file"), Text("Save all settings to a file, or load them from one"))
                    ViewThatFits(in: .horizontal) {
                        HStack { backupButtons }
                        VStack(alignment: .leading) { backupButtons }
                    }
                }
                .padding(.vertical, 2)
                .settingAnchor(String(localized: "Settings file"))
                Toggle(isOn: $sync.isEnabled) {
                    RowLabel(Text("Sync settings with iCloud"), Text(syncStatus))
                }
                .settingAnchor(String(localized: "Sync settings with iCloud"))
                if sync.state == .noDrive || sync.state == .noAccess {
                    LabeledContent(sync.state == .noDrive
                                   ? String(localized: "Turn on iCloud Drive in System Settings")
                                   : String(localized: "Allow pika-tools to use iCloud Drive in System Settings")) {
                        Button("Open", systemImage: "arrow.up.forward.app") { sync.openSettings() }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            RestoreDefaultsSection(
                message: String(localized: "Appearance and Language will follow the system again, and iCloud sync will turn off. Open at Login and the settings saved in iCloud Drive stay as they are."),
                isDefault: appearance == .system && language.selected.isEmpty && !sync.isEnabled
            ) {
                sync.isEnabled = false
                appearance = .system
                Appearance.system.apply()
                language.selected = ""
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .onAppear { loginItem.refresh() }
        .alert(Text(verbatim: sync.alert?.title ?? ""), isPresented: Binding(get: { sync.alert != nil }, set: { if !$0 { sync.alert = nil } })) {
            Button("OK") {}
        } message: {
            Text(verbatim: sync.alert?.message ?? "")
        }
        .alert("Replace your settings?", isPresented: Binding(get: { sync.pendingImport != nil }, set: { if !$0 { sync.pendingImport = nil } }), presenting: sync.pendingImport) { item in
            Button("Replace") { sync.confirmImport(item) }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("All pika-tools settings will be replaced with the ones from “\(item.name)”.")
        }
    }

    private var syncStatus: String {
        switch sync.state {
        case .off: String(localized: "Same settings on all your Macs")
        case .synced(let date): String(localized: "Last synced at \(date.formatted(date: .omitted, time: .shortened))")
        case .noDrive: String(localized: "iCloud Drive is turned off on this Mac")
        case .noAccess: String(localized: "pika-tools isn’t allowed to open iCloud Drive")
        case .failed(let message): String(localized: "Can’t sync: \(message)")
        }
    }
}

private struct AppearancePicker: View {
    @Binding var selection: Appearance

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(Appearance.allCases, id: \.self) { item in
                ChoiceTile(title: item.title, selected: item == selection, action: { selection = item }) {
                    preview(item)
                }
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
    var headings: [String: LocalizedStringKey] = [:]

    var body: some View {
        Form {
            SettingsHeader(tab: tab, text: text)
            let tools = ToolRegistry.shared.tools.filter { $0.tab == tab }
            ForEach(tools, id: \.id) { tool in
                if let heading = headings[tool.id] {
                    Section(heading) { tool.settingsView }
                } else {
                    Section { tool.settingsView }
                }
            }
            RestoreDefaultsSection(
                message: String(localized: "These will turn off and go back to their default options: \(tools.map(\.title).formatted(.list(type: .and)))"),
                isDefault: tools.allSatisfy(\.isDefault)
            ) {
                tools.forEach { $0.reset() }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .environment(\.inSettings, true)
    }
}

private struct AboutView: View {
    private static let github = Bundle.main.url(forResource: "github", withExtension: "svg").flatMap { NSImage(contentsOf: $0) }

    @Bindable private var updater = Updater.shared
    private let info = Bundle.main.infoDictionary ?? [:]
    private var version: String {
        "\(info["CFBundleShortVersionString"] ?? "")"
    }
    private var icon: NSImage {
        _ = IconStyle.shared.theme
        return NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .about, title: "pika-tools", text: String(localized: "Small fixes for the keyboard, mouse and sleep"), appIcon: icon)

            Section("Updates") {
                Toggle("Check for updates automatically", isOn: $updater.checksAutomatically)
                    .settingAnchor(String(localized: "Check for updates automatically"))
                LabeledContent {
                    if case .available(let version) = updater.state {
                        Button("Update to \(version)", systemImage: "arrow.down.circle") { Task { await updater.install() } }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button("Check Now", systemImage: "arrow.triangle.2.circlepath") { Task { await updater.check() } }
                            .disabled(updater.state == .checking || updater.state == .installing)
                    }
                } label: {
                    RowLabel(Text("Version \(version)"), updater.state.title.map { Text($0) })
                        .textSelection(.enabled)
                }
            }

            Section {
                link("GitHub", "https://github.com/dev-pikapik/pika-tools", symbol: "chevron.left.forwardslash.chevron.right", color: .gray, template: Self.github)
                link(String(localized: "What’s New"), "https://github.com/dev-pikapik/pika-tools/blob/main/CHANGELOG.md", symbol: "newspaper.fill", color: .blue)
                link(String(localized: "Report a Problem"), "https://github.com/dev-pikapik/pika-tools/issues/new/choose", symbol: "ladybug.fill", color: .red)
                link(String(localized: "License (MIT)"), "https://github.com/dev-pikapik/pika-tools/blob/main/LICENSE", symbol: "doc.text.fill", color: .green)
            } footer: {
                Text(verbatim: info["NSHumanReadableCopyright"] as? String ?? "")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            RestoreDefaultsSection(
                message: String(localized: "pika-tools will check for updates automatically again."),
                isDefault: updater.checksAutomatically
            ) {
                updater.checksAutomatically = true
            }
        }
        .formStyle(.grouped)
        .settingsPage()
    }

    private func link(_ title: String, _ url: String, symbol: String, color: Color, template: NSImage? = nil) -> some View {
        Link(destination: URL(string: url)!) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.secondary)
            } label: {
                HStack(spacing: 10) {
                    SectionIcon(symbol: symbol, color: color, size: SettingsTab.iconSize, template: template)
                    Text(verbatim: title)
                        .foregroundStyle(.primary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingAnchor(title)
    }
}
