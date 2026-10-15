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
        #if APPSTORE
        return BackgroundTasks.collect(footprint, launchd: .read(), own: own, loginItems: [], running: running)
        #else
        let logins = BackgroundTasks.loginItems()
        let launchd = Launchd.read()
        return BackgroundTasks.collect(footprint, launchd: launchd, own: own, loginItems: logins, turnedOff: BackgroundTasks.turnedOffLogins(live: logins),
                                       turnedOffServices: BackgroundTasks.turnedOffServices(launchd: launchd), running: running)
        #endif
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
    #if !APPSTORE
    private(set) var failed: Set<String> = []
    #endif
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
        failed.remove(task.id)
        let finish = { (ok: Bool) in
            if ok {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) { self.tasks[index].state = task.state == .on ? .off : .on }
            } else {
                self.failed.insert(task.id)
            }
            self.busy.remove(task.id)
            self.refresh()
        }
        if task.domain == "system" {
            setService(task.label, on: task.state != .on, done: finish)
        } else {
            Task { finish(await scanner.toggle(task)) }
        }
    }

    func setService(_ label: String, on: Bool, done: @escaping (Bool) -> Void) {
        FanControl.shared.setService(label, on: on) { ok in
            if ok { BackgroundTasks.rememberService(label, off: !on) }
            done(ok)
        }
    }
    #endif
}

struct BackgroundPage: View {
    private let model = BackgroundModel.shared
    private let permissions = Permissions.shared

    var body: some View {
        Form {
            SettingsHeader(tab: .background, text: String(localized: "See everything that runs in the background and which app added it"))
            #if APPSTORE
            if !permissions.fileAccess {
                Section {
                    Text("Tasks in your home folder")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .needs([.folders])
                }
            }
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
                if model.tasks.contains(where: \.opensLoginItems) {
                    Section { SettingsGuide.loginItems }
                }
                #if !APPSTORE
                group(.login, "Open at Login")
                #endif
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
        #else
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PermissionBar(permissions: model.tasks.contains { $0.domain == "system" } ? [.fans] : [], text: "To turn off tasks that run for the whole Mac, allow administrator access.")
        }
        #endif
        .environment(\.inSettings, true)
        .onAppear {
            permissions.refresh()
            #if !APPSTORE
            FanControl.shared.probe()
            #endif
            model.refresh(rescan: true)
        }
        .onChange(of: permissions.fileAccess) { model.refresh(rescan: true) }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)) { _ in model.refresh() }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)) { _ in model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
            #if !APPSTORE
            FanControl.shared.probe()
            #endif
            model.refresh()
        }
    }

    @ViewBuilder
    private func group(_ kind: BackgroundTask.Kind, _ title: LocalizedStringKey) -> some View {
        let tasks = model.tasks.filter { $0.kind == kind }
        if !tasks.isEmpty {
            Section(title) {
                ForEach(tasks) { task in
                    TaskRow(task: task, showsVersion: Set(tasks.filter { $0.title == task.title }.map(\.version)).count > 1)
                }
            }
        }
    }
}

private struct TaskRow: View {
    let task: BackgroundTask
    let showsVersion: Bool
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
                #if !APPSTORE
                if let note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(model.failed.contains(task.id) ? Color.red : Color.secondary)
                        .lineLimit(2)
                }
                #endif
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
        let version: String? = showsVersion && !task.version.isEmpty ? String(localized: "Version \(task.version)") : nil
        return [version, state, scope, task.developer].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
    }

    #if !APPSTORE
    private var note: String? {
        if model.failed.contains(task.id) {
            return task.state == .on ? String(localized: "Couldn’t turn this off. Try again or use System Settings.")
                : String(localized: "Couldn’t turn this back on. Try again or use System Settings.")
        }
        guard task.opensLoginItems, task.state == .on else { return nil }
        return task.scope == .wholeMac ? String(localized: "Needs administrator rights, so turn it off in System Settings")
            : String(localized: "The app added it itself, so turn it off in System Settings")
    }
    #endif

    private static func text(_ timing: BackgroundTask.Timing) -> String {
        switch timing {
        case .keepsRunning: String(localized: "Keeps running")
        case .schedule: String(localized: "Runs on a schedule")
        case .atLogin: String(localized: "Starts when you log in")
        case .atStartup: String(localized: "Starts with your Mac")
        case .onDemand: String(localized: "Runs when needed")
        }
    }

    @ViewBuilder private var action: some View {
        if task.isOwn {
            EmptyView()
        } else if task.state == .offInSettings {
            Button("Turn On…", action: BackgroundTasks.openLoginItems)
                .help(Text("Opens Login Items in System Settings"))
        } else if task.canToggle {
            #if !APPSTORE
            Button(task.state == .off ? "Turn Back On" : "Turn Off") { model.toggle(task) }
                .disabled(model.busy.contains(task.id))
                .needs(task.domain == "system" ? [.fans] : [])
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
