import AppKit
import SwiftUI
import UniformTypeIdentifiers

actor BackgroundScanner {
    private var apps: (installed: [AppIdentity], system: [AppIdentity])?

    func scan(home: URL, own: URL, running: [(id: String?, url: URL?)], rescan: Bool) -> [BackgroundTask] {
        var roots = AppRoots.live
        roots.home = home
        if rescan || apps == nil { apps = (AppInventory.installed(roots), AppInventory.system(roots)) }
        let footprint = AppFootprint(roots: roots, installed: apps?.installed ?? [], system: apps?.system ?? [])
        return BackgroundTasks.collect(footprint, launchd: .read(), own: own, loginItems: BackgroundTasks.loginItems(), running: running)
    }

    #if !APPSTORE
    func toggle(_ task: BackgroundTask) -> Bool {
        task.state == .on ? BackgroundTasks.turnOff(task) : BackgroundTasks.turnOn(task)
    }
    #endif
}

@MainActor @Observable
final class BackgroundModel {
    static let shared = BackgroundModel()

    private(set) var tasks: [BackgroundTask] = []
    private(set) var loaded = false
    private(set) var busy: Set<String> = []
    #if APPSTORE
    let home = FolderAccess.home
    #else
    let home = FileManager.default.homeDirectoryForCurrentUser
    #endif
    @ObservationIgnored private let scanner = BackgroundScanner()
    @ObservationIgnored private var icons: [String: NSImage] = [:]
    @ObservationIgnored private var fill: Task<Void, Never>?

    private init() {}

    func refresh(rescan: Bool = false) {
        #if APPSTORE
        _ = FolderAccess.reopen()
        #endif
        let home = self.home, own = Bundle.main.bundleURL
        let running = NSWorkspace.shared.runningApplications.map { (id: $0.bundleIdentifier, url: $0.bundleURL) }
        let previous = fill
        previous?.cancel()
        fill = Task {
            await previous?.value
            let found = await scanner.scan(home: home, own: own, running: running, rescan: rescan)
            guard !Task.isCancelled else { return }
            if tasks != found { tasks = found }
            loaded = true
        }
    }

    func icon(_ url: URL) -> NSImage {
        if let icon = icons[url.path] { return icon }
        let file = url.resolvingSymlinksInPath()
        let icon = FileManager.default.isReadableFile(atPath: file.path) ? NSWorkspace.shared.icon(forFile: file.path) : NSWorkspace.shared.icon(for: .unixExecutable)
        icons[url.path] = icon
        return icon
    }

    #if !APPSTORE
    func toggle(_ task: BackgroundTask) {
        busy.insert(task.id)
        Task {
            let done = await scanner.toggle(task)
            if !done { NSSound.beep() }
            busy.remove(task.id)
            refresh()
        }
    }
    #endif
}

struct BackgroundPage: View {
    private let model = BackgroundModel.shared
    private let permissions = Permissions.shared

    var body: some View {
        Form {
            #if APPSTORE
            SettingsHeader(tab: .background, text: String(localized: "See everything that runs in the background and which app added it."))
            if !permissions.fileAccess {
                Section {
                    Text("Tasks in your home folder")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .needs([.folders])
                }
            }
            #else
            SettingsHeader(tab: .background, text: String(localized: "See everything that runs in the background and which app added it. Turn off what you don’t need and turn it back on anytime."))
            #endif
            if !model.loaded {
                Section {
                    ProgressView()
                        .controlSize(.small)
                        .frame(maxWidth: .infinity)
                }
            } else if model.tasks.isEmpty {
                Section {
                    Text("Nothing runs in the background")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            } else {
                group(.login, "Open at Login")
                group(.background, "In the Background")
                group(.leftover, "Left by deleted apps")
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        #if APPSTORE
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PermissionBar(permissions: [.folders], text: "To see the tasks in your home folder, allow access to it.")
        }
        #endif
        .environment(\.inSettings, true)
        .onAppear {
            permissions.refresh()
            model.refresh(rescan: true)
        }
        .onChange(of: permissions.fileAccess) { model.refresh(rescan: true) }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)) { _ in model.refresh() }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)) { _ in model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
            model.refresh()
        }
    }

    @ViewBuilder
    private func group(_ kind: BackgroundTask.Kind, _ title: LocalizedStringKey) -> some View {
        let tasks = model.tasks.filter { $0.kind == kind }
        if !tasks.isEmpty {
            Section(title) {
                ForEach(tasks) { TaskRow(task: $0) }
            }
        }
    }
}

private struct TaskRow: View {
    let task: BackgroundTask
    private let model = BackgroundModel.shared

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: model.icon(task.icon))
                .resizable()
                .frame(width: 28, height: 28)
                .opacity(task.state == .on ? 1 : 0.45)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .foregroundStyle(task.state == .on ? .primary : .secondary)
                        .lineLimit(1)
                    if task.running {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                            .help(Text("Running now"))
                            .accessibilityLabel(Text("Running now"))
                    }
                }
                if !byline.isEmpty {
                    Text(byline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Button(action: reveal) {
                    Text(path)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .buttonStyle(.plain)
                .help(Text("Show in Finder"))
            }
            Spacer(minLength: 8)
            action
        }
        .contextMenu {
            Button("Show in Finder", action: reveal)
        }
    }

    private var path: String {
        let home = model.home.path + "/"
        return task.file.path.hasPrefix(home) ? "~/" + task.file.path.dropFirst(home.count) : task.file.path
    }

    private var byline: String {
        let state: String? = switch task.state {
        case .on: task.timing.map(Self.text)
        case .off: String(localized: "Turned off")
        case .offInSettings: String(localized: "Turned off in System Settings")
        }
        let scope: String? = switch task.scope {
        case .mine: nil
        case .allUsers: String(localized: "For all users")
        case .wholeMac: String(localized: "For the whole Mac")
        }
        return [state, scope, task.developer].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private static func text(_ timing: BackgroundTask.Timing) -> String {
        switch timing {
        case .keepsRunning: String(localized: "Keeps running")
        case .schedule: String(localized: "Runs on a schedule")
        case .atLogin: String(localized: "Starts when you log in")
        case .atStartup: String(localized: "Starts with your Mac")
        case .onDemand: String(localized: "Runs when needed")
        }
    }

    private var canToggle: Bool {
        #if APPSTORE
        false
        #else
        !task.domain.isEmpty
        #endif
    }

    @ViewBuilder private var action: some View {
        if task.isOwn {
            EmptyView()
        } else if task.state == .offInSettings {
            Button("Turn On…", action: BackgroundTasks.openLoginItems)
                .help(Text("Opens Login Items in System Settings"))
        } else if canToggle {
            #if !APPSTORE
            Button(task.state == .off ? "Turn Back On" : "Turn Off") { model.toggle(task) }
                .disabled(model.busy.contains(task.id))
            #endif
        } else if task.state == .on {
            Button("Turn Off…", action: BackgroundTasks.openLoginItems)
                .help(Text("Opens Login Items in System Settings"))
        }
    }

    private func reveal() {
        NSWorkspace.shared.activateFileViewerSelecting([task.file])
    }
}
