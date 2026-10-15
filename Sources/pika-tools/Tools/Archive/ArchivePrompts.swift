import AppKit
import SwiftUI
import UniformTypeIdentifiers

final class ArchivePanel: NSPanel {
    private var onClose: (() -> Void)?
    private var closed = false

    init<Content: View>(_ controller: NSHostingController<Content>, activating: Bool, onClose: (() -> Void)? = nil) {
        self.onClose = onClose
        super.init(contentRect: .zero, styleMask: activating ? [.titled, .closable] : [.titled, .closable, .nonactivatingPanel], backing: .buffered, defer: false)
        contentViewController = controller
        setContentSize(controller.view.fittingSize)
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        level = .floating
        center()
        // A window that can't close, minimize or zoom shows no buttons at all, so a panel nobody closes keeps a grey red button.
        if onClose == nil { standardWindowButton(.closeButton)?.isEnabled = false }
    }

    // The red button calls close() itself, not performClose(_:). However the panel closes, it answers its prompt once, the way Cancel does, so whoever waits for it always gets a reply.
    override func close() {
        guard !closed else { return }
        closed = true
        super.close()
        onClose?()
    }

    /// Closes the panel for a prompt that already has its answer.
    func dismiss() {
        onClose = nil
        close()
    }
}

extension View {
    func archiveChrome(width: CGFloat) -> some View {
        padding(EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24))
            .frame(width: width)
    }
}

extension Archive.Format {
    var type: UTType {
        switch self {
        case .zip: .zip
        case .sevenZip: UTType("org.7-zip.7-zip-archive") ?? .archive
        case .tarGz: UTType("org.gnu.gnu-zip-tar-archive") ?? .archive
        case .tarXz: UTType("org.tukaani.tar-xz-archive") ?? .archive
        }
    }

    var caption: String {
        switch self {
        case .zip: String(localized: "Opens on any computer")
        case .sevenZip: String(localized: "The smallest size")
        case .tarGz: String(localized: "For servers and developers")
        case .tarXz: String(localized: "Smaller, for servers and developers")
        }
    }
}

enum ArchiveSplit: Int64, CaseIterable, Identifiable {
    case none = 0
    case email = 15_728_640
    case medium = 104_857_600
    case large = 1_073_741_824
    case usb = 4_293_918_720

    var id: Int64 { rawValue }

    var title: String {
        switch self {
        case .none: String(localized: "Don’t split")
        case .email: String(localized: "15 MB, for email")
        case .medium: String(localized: "100 MB")
        case .large: String(localized: "1 GB")
        case .usb: String(localized: "4 GB, for USB drives")
        }
    }
}

struct ArchiveCreateRequest: Sendable {
    let items: [URL]
    let name: String
    let format: Archive.Format
    let password: String?
    let split: Int64?
}

@MainActor
@Observable
final class ArchiveCreateModel {
    let items: [URL]
    var name: String
    var format: Archive.Format
    var split: ArchiveSplit
    var passwordOn = false
    var password = ""
    var confirm = ""

    init(items: [URL]) {
        let defaults = UserDefaults.standard
        self.items = items
        format = Archive.Format.allCases.first { $0.fileExtension == defaults.string(forKey: "archive-format") } ?? .zip
        split = ArchiveSplit(rawValue: Int64(defaults.integer(forKey: "archive-split"))) ?? .none
        if items.count == 1, let item = items.first {
            let isFolder = (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
            name = isFolder ? item.lastPathComponent : item.deletingPathExtension().lastPathComponent
        } else {
            name = String(localized: "Archive")
        }
    }

    var cleanName: String {
        let typed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let suffix = "." + format.fileExtension
        return typed.lowercased().hasSuffix(suffix) ? String(typed.dropLast(suffix.count)) : typed
    }

    var isNameValid: Bool { NewFile.isValid(cleanName) }
    var isPasswordValid: Bool { !(format == .zip && !password.allSatisfy(\.isASCII)) }
    var usesPassword: Bool { passwordOn && format.supportsPassword }
    var passwordsDiffer: Bool { !confirm.isEmpty && confirm != password && !password.hasPrefix(confirm) }
    var passwordsMatch: Bool { !password.isEmpty && confirm == password }
    var canCreate: Bool { isNameValid && (!usesPassword || (passwordsMatch && isPasswordValid)) }

    var caption: String {
        format == .zip && usesPassword ? String(localized: "Some computers need an extra app to open it") : format.caption
    }

    var passwordNote: String? {
        guard format.supportsPassword else {
            #if APPSTORE
            if format == .sevenZip { return String(localized: "Only ZIP can have a password") }
            #endif
            return String(localized: "TAR archives can’t have a password")
        }
        return format == .zip ? String(localized: "File names stay visible") : String(localized: "File names are hidden too")
    }

    var request: ArchiveCreateRequest? {
        guard canCreate else { return nil }
        return ArchiveCreateRequest(items: items, name: cleanName, format: format, password: usesPassword ? password : nil, split: split == .none ? nil : split.rawValue)
    }
}

struct ArchiveHero: View {
    let icon: NSImage
    var identity = ""
    let locked: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Image(nsImage: icon)
                .resizable()
                .id(identity)
                .transition(.opacity)
        }
        .frame(width: 64, height: 64)
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: identity)
        .overlay(alignment: .bottomTrailing) {
            if locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.accentColor))
                    .background(Circle().fill(Color(nsColor: .windowBackgroundColor)).padding(-2))
                    .offset(x: 4, y: 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: locked)
        .accessibilityHidden(true)
    }
}

private struct ArchiveOptionRow<Control: View>: View {
    let tint: Color
    let symbol: String
    let title: LocalizedStringKey
    var note: String?
    @ViewBuilder let control: Control

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(tint, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .lineLimit(2)
                    .accessibilityHidden(true)
                if let note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            control
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }
}

/// SwiftUI's segmented Picker keeps its natural width on macOS 26+, so the format row wraps the AppKit control to span the card.
private struct ArchiveFormatPicker: NSViewRepresentable {
    @Binding var selection: Archive.Format

    func makeNSView(context: Context) -> NSSegmentedControl {
        let control = NSSegmentedControl(labels: Archive.Format.allCases.map { $0.fileExtension.uppercased() }, trackingMode: .selectOne, target: context.coordinator, action: #selector(Coordinator.pick))
        control.segmentDistribution = .fillEqually
        control.setAccessibilityLabel(String(localized: "Format"))
        return control
    }

    func updateNSView(_ control: NSSegmentedControl, context: Context) {
        context.coordinator.selection = $selection
        control.selectedSegment = Archive.Format.allCases.firstIndex(of: selection) ?? 0
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView control: NSSegmentedControl, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? control.intrinsicContentSize.width, height: control.intrinsicContentSize.height)
    }

    func makeCoordinator() -> Coordinator { Coordinator(selection: $selection) }

    @MainActor
    final class Coordinator: NSObject {
        var selection: Binding<Archive.Format>
        init(selection: Binding<Archive.Format>) { self.selection = selection }
        @objc func pick(_ sender: NSSegmentedControl) { selection.wrappedValue = Archive.Format.allCases[sender.selectedSegment] }
    }
}

struct ArchiveCreateView: View {
    @Bindable var model: ArchiveCreateModel
    let finish: (ArchiveCreateRequest?) -> Void
    @FocusState private var focused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            ArchiveHero(icon: NSWorkspace.shared.icon(for: model.format.type), identity: model.format.fileExtension, locked: model.usesPassword)
            HStack(spacing: 6) {
                TextField("Name", text: $model.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(model.isNameValid ? Color.primary : Color.red)
                    .focused($focused)
                    .help(model.isNameValid ? "" : String(localized: "Type a name without “/” or “:”."))
                Text(verbatim: "." + model.format.fileExtension)
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
            .controlSize(.large)
            VStack(spacing: 6) {
                ArchiveFormatPicker(selection: $model.format)
                    .controlSize(.large)
                Text(model.caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            options
            HStack(spacing: 12) {
                Button { finish(nil) } label: { Text("Cancel").frame(maxWidth: .infinity) }
                    .glassButtons()
                    .keyboardShortcut(.cancelAction)
                Button { finish(model.request) } label: { Text("Create").frame(maxWidth: .infinity) }
                    .glassProminentButtons()
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canCreate)
            }
            .controlSize(.large)
        }
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: model.usesPassword)
        .archiveChrome(width: 420)
        .task { focused = true }
    }

    private var options: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        return VStack(spacing: 0) {
            ArchiveOptionRow(tint: .blue, symbol: "lock.fill", title: "Password", note: model.passwordNote) {
                Toggle("Password", isOn: Binding(get: { model.usesPassword }, set: { on in
                    model.passwordOn = on
                    if !on {
                        model.password = ""
                        model.confirm = ""
                    }
                }))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
                .disabled(!model.format.supportsPassword)
            }
            if model.usesPassword {
                VStack(alignment: .leading, spacing: 6) {
                    ArchivePasswordField(text: $model.password, confirm: $model.confirm, autofocus: true) {
                        if model.canCreate { finish(model.request) }
                    }
                    status
                }
                .padding(.leading, 46)
                .padding(.trailing, 12)
                .padding(.bottom, 9)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            #if !APPSTORE
            Divider().padding(.leading, 46)
            ArchiveOptionRow(tint: .purple, symbol: "rectangle.split.3x1.fill", title: "Split archive") {
                Picker("Split archive", selection: $model.split) {
                    ForEach(ArchiveSplit.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
            }
            #endif
        }
        .background(shape.fill(.quaternary.opacity(0.5)))
        .overlay(shape.strokeBorder(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 0.5))
    }

    private var status: some View {
        ZStack(alignment: .leading) {
            if !model.isPasswordValid {
                Text("Use English letters, numbers and symbols only")
                    .foregroundStyle(.orange)
            } else if model.passwordsDiffer {
                Label("Passwords don’t match", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            } else if model.passwordsMatch {
                Label("Passwords match", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .font(.caption)
        .lineLimit(1)
        .frame(maxWidth: .infinity, minHeight: 16, maxHeight: 16, alignment: .leading)
    }
}

struct ArchivePasswordField: View {
    @Binding var text: String
    var confirm: Binding<String>?
    var autofocus = false
    let submit: () -> Void
    @State private var shown = false
    @FocusState private var focus: Slot?

    private enum Slot { case first, second }

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                field("Password", $text, .first)
                if let confirm { field("Repeat password", confirm, .second) }
            }
            Button {
                let was = focus
                shown.toggle()
                if was != nil { DispatchQueue.main.async { focus = was } }
            } label: {
                Image(systemName: shown ? "eye.slash" : "eye")
                    .frame(width: 20)
            }
            .buttonStyle(.borderless)
            .help(shown ? Text("Hide password") : Text("Show password"))
            .accessibilityLabel(shown ? Text("Hide password") : Text("Show password"))
        }
        .controlSize(.large)
        .task { if autofocus { focus = .first } }
    }

    private func field(_ prompt: LocalizedStringKey, _ binding: Binding<String>, _ slot: Slot) -> some View {
        Group {
            if shown {
                TextField(prompt, text: binding)
            } else {
                SecureField(prompt, text: binding)
            }
        }
        .textFieldStyle(.roundedBorder)
        .focused($focus, equals: slot)
        .onSubmit { if slot == .first, confirm != nil { focus = .second } else { submit() } }
    }
}

@MainActor
final class ArchiveCreatePrompt {
    private var panel: ArchivePanel?
    private var answer: CheckedContinuation<ArchiveCreateRequest?, Never>?

    static func ask(for items: [URL]) async -> ArchiveCreateRequest? {
        await ArchiveCreatePrompt().show(items)
    }

    private func show(_ items: [URL]) async -> ArchiveCreateRequest? {
        let model = ArchiveCreateModel(items: items)
        return await withCheckedContinuation { continuation in
            answer = continuation
            let controller = NSHostingController(rootView: ArchiveCreateView(model: model) { [self] request in finish(request) })
            controller.sizingOptions = [.preferredContentSize]
            let panel = ArchivePanel(controller, activating: true) { [weak self] in self?.finish(nil) }
            panel.title = String(localized: "New Archive")
            self.panel = panel
            NSApp.bringForward()
            panel.makeKeyAndOrderFront(nil)
        }
    }

    private func finish(_ request: ArchiveCreateRequest?) {
        if let request {
            let defaults = UserDefaults.standard
            defaults.set(request.format.fileExtension, forKey: "archive-format")
            defaults.set(Int(request.split ?? 0), forKey: "archive-split")
        }
        panel?.dismiss()
        panel = nil
        answer?.resume(returning: request)
        answer = nil
    }
}

@MainActor
@Observable
final class ArchivePasswordModel {
    var name = ""
    var icon = NSImage()
    var password = ""
    var wrong = false
    var checking = false
    var shakes = 0
}

private struct ArchiveShake: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let progress = shakes - shakes.rounded(.down)
        return ProjectionTransform(CGAffineTransform(translationX: 9 * (1 - progress) * sin(progress * .pi * 6), y: 0))
    }
}

struct ArchivePasswordView: View {
    @Bindable var model: ArchivePasswordModel
    let submit: (String) -> Void
    let cancel: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var canSubmit: Bool { !model.password.isEmpty && !model.checking }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                ArchiveHero(icon: model.icon, locked: true)
                Text("“\(model.name)” is protected")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            VStack(spacing: 6) {
                ArchivePasswordField(text: $model.password, autofocus: true) {
                    if canSubmit { submit(model.password) }
                }
                .modifier(ArchiveShake(shakes: CGFloat(model.shakes)))
                .animation(reduceMotion ? nil : .linear(duration: 0.45), value: model.shakes)
                ZStack {
                    if model.checking {
                        ProgressView().controlSize(.small)
                    } else if model.wrong {
                        Label("Wrong password", systemImage: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 16, maxHeight: 16, alignment: .leading)
            }
            HStack(spacing: 12) {
                Button(action: cancel) { Text("Cancel").frame(maxWidth: .infinity) }
                    .glassButtons()
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.checking)
                Button { submit(model.password) } label: { Text("Extract").frame(maxWidth: .infinity) }
                    .glassProminentButtons()
                    .keyboardShortcut(.defaultAction)
                    .disabled(!canSubmit)
            }
            .controlSize(.large)
        }
        .archiveChrome(width: 380)
    }
}

@MainActor
final class ArchivePasswordPrompt {
    private let model = ArchivePasswordModel()
    private var panel: ArchivePanel?
    private var answer: CheckedContinuation<String?, Never>?

    func ask(for url: URL, wrong: Bool) async -> String? {
        model.name = url.lastPathComponent
        model.icon = NSWorkspace.shared.icon(forFile: url.path)
        model.checking = false
        model.wrong = wrong
        if wrong {
            model.password = ""
            model.shakes += 1
        }
        if panel == nil {
            let controller = NSHostingController(rootView: ArchivePasswordView(model: model, submit: { [weak self] in self?.submit($0) }, cancel: { [weak self] in self?.close() }))
            controller.sizingOptions = [.preferredContentSize]
            panel = ArchivePanel(controller, activating: true) { [weak self] in self?.close() }
        }
        panel?.title = model.name
        NSApp.bringForward()
        panel?.makeKeyAndOrderFront(nil)
        return await withCheckedContinuation { answer = $0 }
    }

    func close() {
        model.password = ""
        model.checking = false
        panel?.dismiss()
        panel = nil
        answer?.resume(returning: nil)
        answer = nil
    }

    func dismissWhileChecking() {
        if model.checking { close() }
    }

    private func submit(_ password: String) {
        model.checking = true
        model.wrong = false
        answer?.resume(returning: password)
        answer = nil
    }
}
