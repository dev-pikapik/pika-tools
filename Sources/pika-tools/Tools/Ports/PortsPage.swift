import AppKit
import SwiftUI

struct PortsPage: View {
    @Bindable private var model = PortsModel.shared

    var body: some View {
        let shown = model.shown
        let mine = shown.filter { model.isOurs($0) }
        let others = shown.filter { !model.isOurs($0) }
        let searching = !model.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        Form {
            SettingsHeader(tab: .ports, text: String(localized: "Which programs have taken ports on this Mac"))
            Section {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.secondary).accessibilityHidden(true)
                    TextField(text: $model.query, prompt: Text("Port or program")) { Text("Port or program") }
                        .textFieldStyle(.plain)
                        .labelsHidden()
                    if !model.query.isEmpty {
                        Button { model.query = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Clear"))
                    }
                }
                .settingAnchor(String(localized: "Free a port"))
                if shown.isEmpty, let port = model.freePort {
                    Label {
                        Text("Port \(String(port)) is free")
                    } icon: {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                } else if model.loaded, shown.isEmpty, searching {
                    Text("No programs found").foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical, 8)
                }
            }
            if model.loaded, !mine.isEmpty || !searching {
                Section {
                    if mine.isEmpty {
                        Text("None of your programs has taken a port").foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical, 8)
                    }
                    ForEach(mine) { PortRow(program: $0, model: model) }
                } header: {
                    Text("Your programs")
                } footer: {
                    #if APPSTORE
                    Text("To free a port, quit the program that holds it: show the program and quit it there, or paste the command into Terminal.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    #endif
                }
            }
            if !others.isEmpty {
                Section {
                    ForEach(others) { PortRow(program: $0, model: model) }
                } header: {
                    Text("macOS and other users")
                }
            }
        }
        .formStyle(.grouped)
        .settingsPage()
        .whileShown { if $0 { model.watch() } else { model.unwatch() } }
        #if !APPSTORE
        .alert(
            model.question.map { $0.force ? String(localized: "Force quit “\($0.name)”?") : String(localized: "Quit “\($0.name)”?") } ?? "",
            isPresented: Binding(get: { model.question != nil }, set: { if !$0 { model.question = nil } }),
            presenting: model.question
        ) { question in
            if question.force {
                Button("Force Quit", role: .destructive) { model.confirm(question) }
            } else {
                Button("Quit") { model.confirm(question) }
            }
            Button("Cancel", role: .cancel) { model.question = nil }
        } message: { question in
            let note = switch (question.force, question.isApp) {
            case (false, true): String(localized: "The port is free once the app closes. If it has unsaved work, it will ask you what to do.")
            case (false, false): String(localized: "The program gets a moment to finish its work, then the port is free.")
            case (true, true): String(localized: "The app didn’t close. Force quitting ends it right away, and anything unsaved is lost.")
            case (true, false): String(localized: "The program didn’t close. Force quitting ends it right away, and anything unsaved is lost.")
            }
            Text(verbatim: "\(question.detail)\n\(note)")
        }
        #endif
    }
}

private struct PortRow: View {
    let program: PortProgram
    let model: PortsModel
    @State private var tip = false

    var body: some View {
        let look = model.look(program)
        let open = model.expanded.contains(program.id)
        VStack(alignment: .leading, spacing: 0) {
            AppRowLabel(icon: look.icon, name: look.name, byline: model.byline(program), minNameWidth: 100) {
                PortChips(listeners: program.listeners)
                control(look)
                Button(action: toggle) {
                    RowChevron().rotationEffect(.degrees(open ? 90 : 0))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(verbatim: look.name))
                .accessibilityValue(open ? Text("Expanded") : Text("Collapsed"))
            }
            .truncationMode(.middle)
            .frame(height: 40)
            .onTapGesture(perform: toggle)
            if open {
                PortDetails(program: program, model: model)
                    .padding(.leading, 38)
                    .padding(.bottom, 8)
            }
        }
        .contextMenu {
            if let window = look.window, let name = window.localizedName {
                Button("Show “\(name)”") { window.activate() }
            }
            if look.file ?? program.owner.path != nil {
                Button("Show in Finder") { model.reveal(program) }
            }
        }
    }

    @ViewBuilder private func control(_ look: PortLook) -> some View {
        let hints = model.hints(program)
        if model.freeing.contains(program.id) {
            ProgressView().controlSize(.small)
        } else if model.isOurs(program) {
            #if APPSTORE
            Form {
                Menu {
                    if let window = look.window, let name = window.localizedName {
                        Button("Show “\(name)”") { window.activate() }
                    }
                    if !look.isApp {
                        Button("Copy Command") { model.copyCommand(program) }
                    }
                    Button("Open Activity Monitor") { NSWorkspace.shared.open(PortsModel.activityMonitor) }
                } label: {
                    ZStack {
                        if model.copied == program.id {
                            Label("Copied", systemImage: "checkmark")
                        } else {
                            Text("Free Up")
                        }
                        Group {
                            Text("Free Up")
                            Label("Copied", systemImage: "checkmark")
                        }
                        .hidden()
                        .accessibilityHidden(true)
                    }
                }
                .menuStyle(.button)
                .buttonStyle(.bordered)
                .menuIndicator(.hidden)
            }
            .formStyle(.columns)
            .fixedSize()
            #else
            Button("Free Up") { model.free(program) }
            #endif
        } else if !hints.isEmpty {
            Button("Free Up") { tip = true }
                .popover(isPresented: $tip) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(hints, id: \.port) { hint in
                            Text("To free port \(String(hint.port)), turn off “\(hint.service)” in System Settings.")
                        }
                        Button("Change in System Settings") { NSWorkspace.shared.open(hints[0].pane) }
                            .buttonStyle(.link)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 260, alignment: .leading)
                    .padding(12)
                }
        } else {
            let note = program.owner.isApple
                ? Text("macOS needs this port, so it stays taken.")
                : Text("It belongs to another user or to the system, so pikapik doesn’t touch it. You can quit it in Activity Monitor.")
            Button { tip = true } label: {
                Image(systemName: "info.circle").foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help(note)
            .accessibilityLabel(note)
            .popover(isPresented: $tip) {
                VStack(alignment: .leading, spacing: 8) {
                    note
                    if !program.owner.isApple {
                        Button("Open Activity Monitor") { NSWorkspace.shared.open(PortsModel.activityMonitor) }
                            .buttonStyle(.link)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260, alignment: .leading)
                .padding(12)
            }
        }
    }

    private func toggle() {
        withAnimation(.snappy) {
            if model.expanded.remove(program.id) == nil { model.expanded.insert(program.id) }
        }
    }
}

private struct PortChips: View {
    let listeners: [PortListener]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            ForEach([3, 2, 1].filter { $0 <= listeners.count }, id: \.self) { shown in
                HStack(spacing: 4) {
                    ForEach(listeners.prefix(shown)) { listener in
                        HStack(spacing: 3) {
                            Text(verbatim: String(listener.port)).monospacedDigit()
                            if listener.udp, !listener.tcp {
                                Text(verbatim: "UDP").font(.caption2)
                            }
                            if !listener.onlyThisMac {
                                Image(systemName: "globe").font(.caption2)
                            }
                        }
                        .font(.callout)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                        .help(listener.onlyThisMac ? Text("Only this Mac can connect.") : Text("Other devices on your network can connect."))
                    }
                    if listeners.count > shown {
                        Text(verbatim: "+\(listeners.count - shown)").font(.callout).foregroundStyle(.secondary)
                    }
                }
                .fixedSize()
            }
        }
        .layoutPriority(1)
        .accessibilityElement(children: .combine)
    }
}

private struct PortDetails: View {
    let program: PortProgram
    let model: PortsModel

    var body: some View {
        let owner = program.owner
        let listeners = program.listeners
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 6) {
            GridRow {
                label("Addresses")
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(model.addresses(program), id: \.text) { address in
                        if let link = address.link {
                            Link(address.text, destination: link)
                        } else {
                            Text(verbatim: address.text).textSelection(.enabled)
                        }
                    }
                    if listeners.allSatisfy(\.onlyThisMac) {
                        Text("Only this Mac can connect.").foregroundStyle(.secondary)
                    } else if !listeners.contains(where: \.onlyThisMac) {
                        Text("Other devices on your network can connect.").foregroundStyle(.secondary)
                    }
                }
            }
            GridRow {
                label("Protocol")
                Text(verbatim: [listeners.contains(where: \.tcp) ? "TCP" : nil, listeners.contains(where: \.udp) ? "UDP" : nil].compactMap { $0 }.joined(separator: ", "))
            }
            if let path = owner.path {
                GridRow {
                    label("Program")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: PortsModel.tilde(path)).textSelection(.enabled)
                        Button("Show in Finder") { model.reveal(program) }.buttonStyle(.link)
                    }
                }
            }
            if !owner.command.isEmpty {
                GridRow {
                    label("Command")
                    Text(verbatim: owner.command.map { $0.isEmpty || $0.contains(" ") ? "\"\($0)\"" : $0 }.joined(separator: " "))
                        .textSelection(.enabled)
                        .lineLimit(8)
                }
            }
            if let folder = owner.folder, folder != "/" {
                GridRow {
                    label("Folder")
                    Text(verbatim: PortsModel.tilde(folder)).textSelection(.enabled)
                }
            }
            GridRow {
                label("Process ID")
                Text(verbatim: ([owner.pid] + program.helpers).map(String.init).joined(separator: ", ")).textSelection(.enabled)
            }
            if owner.started > 0 {
                GridRow {
                    label("Started")
                    Text(Date(timeIntervalSince1970: owner.started), format: .relative(presentation: .named))
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .font(.callout)
    }

    private func label(_ title: LocalizedStringKey) -> some View {
        Text(title).foregroundStyle(.secondary).gridColumnAlignment(.trailing)
    }
}
