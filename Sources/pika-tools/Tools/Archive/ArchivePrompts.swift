import AppKit
import SwiftUI
import UniformTypeIdentifiers

final class ArchivePanel: NSPanel {
    init(_ controller: NSViewController, activating: Bool) {
        super.init(contentRect: .zero, styleMask: activating ? [.titled] : [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        contentViewController = controller
        setContentSize(controller.view.fittingSize)
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        level = .floating
        center()
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
    var password = ""

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

    var hint: String? {
        guard format.supportsPassword, !password.isEmpty else { return nil }
        if !isPasswordValid { return String(localized: "Use English letters, numbers and symbols only") }
        return format == .zip ? String(localized: "Some computers need an extra app to open it") : String(localized: "File names are hidden too")
    }

    var request: ArchiveCreateRequest? {
        guard isNameValid, isPasswordValid else { return nil }
        let secret = format.supportsPassword && !password.isEmpty ? password : nil
        return ArchiveCreateRequest(items: items, name: cleanName, format: format, password: secret, split: split == .none ? nil : split.rawValue)
    }
}

struct ArchiveCreateView: View {
    @Bindable var model: ArchiveCreateModel
    let finish: (ArchiveCreateRequest?) -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                Image(nsImage: NSWorkspace.shared.icon(for: model.format.type))
                    .resizable()
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
                TextField("Name", text: $model.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(model.isNameValid ? Color.primary : Color.red)
                    .focused($focused)
                    .help(model.isNameValid ? "" : String(localized: "Type a name without “/” or “:”."))
                Text(verbatim: "." + model.format.fileExtension)
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
            VStack(spacing: 8) {
                Picker("Format", selection: $model.format) {
                    ForEach(Archive.Format.allCases, id: \.self) { Text(verbatim: $0.fileExtension.uppercased()).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Text(model.format.caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "lock")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                    ArchivePasswordField(prompt: "No password", text: $model.password)
                        .disabled(!model.format.supportsPassword)
                        .help(model.format.supportsPassword ? "" : String(localized: "TAR archives can’t have a password"))
                }
                Text(verbatim: model.hint ?? "")
                    .font(.caption)
                    .foregroundStyle(model.isPasswordValid ? Color.secondary : Color.orange)
                    .lineLimit(1)
                    .frame(height: 14)
                    .padding(.leading, 30)
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.split.3x1")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                    Picker("Split into parts", selection: $model.split) {
                        ForEach(ArchiveSplit.allCases) { Text($0.title).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                    Spacer()
                }
            }
            HStack {
                Spacer()
                Button("Cancel") { finish(nil) }
                    .keyboardShortcut(.cancelAction)
                Button("Create") { finish(model.request) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.request == nil)
            }
        }
        .padding(20)
        .frame(width: 440)
        .task { focused = true }
    }
}

struct ArchivePasswordField: View {
    let prompt: LocalizedStringKey
    @Binding var text: String
    var autofocus = false
    @State private var shown = false
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Group {
                if shown {
                    TextField(prompt, text: $text)
                } else {
                    SecureField(prompt, text: $text)
                }
            }
            .textFieldStyle(.roundedBorder)
            .focused($focused)
            Button {
                let wasFocused = focused
                shown.toggle()
                if wasFocused { DispatchQueue.main.async { focused = true } }
            } label: {
                Image(systemName: shown ? "eye.slash" : "eye")
                    .frame(width: 20)
            }
            .buttonStyle(.borderless)
            .help(shown ? Text("Hide password") : Text("Show password"))
            .accessibilityLabel(shown ? Text("Hide password") : Text("Show password"))
        }
        .task { if autofocus { focused = true } }
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
            let panel = ArchivePanel(controller, activating: true)
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
        panel?.close()
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

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(nsImage: model.icon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 8) {
                    Text("“\(model.name)” is protected")
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    ArchivePasswordField(prompt: "Password", text: $model.password, autofocus: true)
                        .modifier(ArchiveShake(shakes: CGFloat(model.shakes)))
                        .animation(reduceMotion ? nil : .linear(duration: 0.45), value: model.shakes)
                    Text("Wrong password")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .opacity(model.wrong ? 1 : 0)
                        .accessibilityHidden(!model.wrong)
                }
            }
            HStack(spacing: 10) {
                Spacer()
                if model.checking { ProgressView().controlSize(.small) }
                Button("Cancel", action: cancel)
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.checking)
                Button("Extract") { submit(model.password) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.password.isEmpty || model.checking)
            }
        }
        .padding(20)
        .frame(width: 440)
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
            panel = ArchivePanel(controller, activating: true)
        }
        NSApp.bringForward()
        panel?.makeKeyAndOrderFront(nil)
        return await withCheckedContinuation { answer = $0 }
    }

    func close() {
        model.password = ""
        model.checking = false
        panel?.close()
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
