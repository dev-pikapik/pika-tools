import AppKit
import QuickLook
import SwiftUI

struct UninstallerSheet: View {
    let session: UninstallSession

    var body: some View {
        VStack(spacing: 0) {
            switch session.phase {
            case .scanning:
                SheetHero(session: session)
                Working(text: Text("Looking for its files…"))
            case .choosing:
                SheetHero(session: session)
                ChoiceView(session: session)
            case .removing:
                SheetHero(session: session)
                Working(text: Text("Moving to the Trash…"))
            case .restoring:
                SheetHero(session: session)
                Working(text: Text("Putting back…"))
            case .removed(let report):
                RemovedView(session: session, report: report)
            case .restored(let result):
                RestoredView(session: session, result: result)
            }
        }
        .frame(width: 600, height: 540)
        .interactiveDismissDisabled(session.isBusy)
        .alert(
            session.question.map { $0.force ? String(localized: "Force quit “\($0.name)”?") : String(localized: "Quit “\($0.name)”?") } ?? "",
            isPresented: Binding(get: { session.question != nil }, set: { if !$0 { session.answer(false) } }),
            presenting: session.question
        ) { question in
            if question.force {
                Button("Force Quit", role: .destructive) { session.answer(true) }
            } else {
                Button("Quit") { session.answer(true) }
            }
            Button("Cancel", role: .cancel) { session.answer(false) }
        } message: { question in
            if question.force {
                Text("The app didn’t close. Force quitting ends it right away, and anything unsaved is lost.")
            } else {
                Text("The app has to close first. If it has unsaved work, it will ask you what to do.")
            }
        }
        .onDisappear { session.work?.cancel() }
    }
}

private struct SheetHero: View {
    let session: UninstallSession
    private let model = UninstallerModel.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(nsImage: model.icon(at: session.app.url))
                    .resizable()
                    .frame(width: 64, height: 64)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(session.app.displayName)
                        .font(.title2.bold())
                        .lineLimit(1)
                    Text(session.app.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 12)
                if case .choosing = session.phase {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(session.plan.bytes().map(UninstallerText.size) ?? "")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .frame(height: 34, alignment: .trailing)
                        Text(String(localized: "\(session.plan.chosen().count) items"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            Divider()
        }
    }
}

private struct Working: View {
    let text: Text

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
            text
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct Pick {
    let isOn: Binding<Bool>
}

private struct ChoiceView: View {
    let session: UninstallSession
    @State private var focus: String?
    @State private var quick: URL?
    private let model = UninstallerModel.shared

    var body: some View {
        let plan = session.plan
        VStack(spacing: 0) {
            List(selection: $focus) {
                ForEach(plan.groups) { group in
                    Section {
                        ForEach(group.items) { item in
                            ItemRow(session: session, item: item) { quick = item.url }
                                .tag(item.id)
                        }
                    } header: {
                        GroupHeader(session: session, group: group)
                    }
                }
            }
            .listStyle(.inset)
            .onKeyPress(.space) {
                guard let item = plan.items.first(where: { $0.id == focus }), item.packageID == nil else { return .ignored }
                quick = item.url
                return .handled
            }
            .quickLookPreview($quick, in: plan.items.filter { $0.packageID == nil }.map(\.url))
            Divider()
            footer(plan)
        }
    }

    private func footer(_ plan: RemovalPlan) -> some View {
        let size = plan.bytes()
        return VStack(alignment: .leading, spacing: 8) {
            if let notice = session.notice {
                Text(notice)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            if plan.needsAdmin() {
                Label("Your Mac will ask for your password once.", systemImage: "lock")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Button("Cancel") { model.close() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                if plan.hasChoice(in: .app) {
                    Button("Reset App") { model.remove(reset: true) }
                        .disabled(plan.chosen(reset: true).isEmpty)
                        .help(Text("Keeps the app and removes its data, settings and temporary files"))
                }
                Button {
                    model.remove(reset: false)
                } label: {
                    Text(size.map { String(localized: "Move to Trash · \(UninstallerText.size($0))") } ?? String(localized: "Move to Trash"))
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(plan.chosen().isEmpty)
            }
        }
        .padding(16)
    }
}

private struct GroupHeader: View {
    let session: UninstallSession
    let group: RemovalPlan.Group

    var body: some View {
        let plan = session.plan
        let picks = group.items.filter { !plan.isInert($0) }.map { item in
            Pick(isOn: Binding(get: { session.plan.isOn(item) }, set: { session.plan.set(item, on: $0) }))
        }
        HStack(spacing: 8) {
            if picks.isEmpty {
                Color.clear.frame(width: 16, height: 16)
            } else {
                Toggle(sources: picks, isOn: \.isOn) { Text(group.kind.title) }
                    .toggleStyle(.checkbox)
                    .labelsHidden()
            }
            Image(systemName: group.kind.symbol)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(group.kind.title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Text(plan.bytes(of: group).map(UninstallerText.size) ?? "")
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct ItemRow: View {
    let session: UninstallSession
    let item: Leftover
    let preview: () -> Void
    private let model = UninstallerModel.shared

    var body: some View {
        let isReceipt = item.packageID != nil
        HStack(spacing: 8) {
            check
            Group {
                if isReceipt {
                    Image(systemName: "shippingbox.fill")
                        .foregroundStyle(.secondary)
                } else {
                    Image(nsImage: model.icon(at: item.url))
                        .resizable()
                }
            }
            .frame(width: 20, height: 20)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if !item.sharedWith.isEmpty {
                    Text("Also used by \(ListFormatter.localizedString(byJoining: item.sharedWith))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            Text(item.reason.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(.quaternary, in: Capsule())
                .frame(width: 150, alignment: .trailing)
            Group {
                if item.needsAdmin {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .help(Text("Needs your password"))
                        .accessibilityLabel(Text("Needs your password"))
                }
            }
            .frame(width: 14)
            Text(isReceipt ? "" : item.size.map(UninstallerText.size) ?? "")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .trailing)
            Button(action: preview) {
                Image(systemName: "eye")
            }
            .buttonStyle(.borderless)
            .help(Text("Quick Look"))
            .accessibilityLabel(Text("Quick Look"))
            .opacity(isReceipt ? 0 : 1)
            .disabled(isReceipt)
        }
        .help(item.packageID ?? item.url.path)
        .contextMenu {
            if !isReceipt {
                Button("Quick Look", action: preview)
                Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([item.url]) }
                Button("Copy Path") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.url.path, forType: .string)
                }
            }
        }
    }

    @ViewBuilder private var check: some View {
        if session.plan.isInert(item) {
            Image(systemName: "trash")
                .foregroundStyle(.secondary)
                .frame(width: 16, height: 16)
                .help(Text("Already in the Trash"))
                .accessibilityLabel(Text("Already in the Trash"))
        } else {
            Toggle(isOn: Binding(get: { session.plan.isOn(item) }, set: { session.plan.set(item, on: $0) })) { Text(item.title) }
                .toggleStyle(.checkbox)
                .labelsHidden()
        }
    }
}

private struct RemovedView: View {
    let session: UninstallSession
    let report: AppRemover.Report
    private let model = UninstallerModel.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 10) {
                    if report.removed > 0 {
                        DrawnCheck()
                    } else {
                        Image(systemName: "info.circle")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                            .frame(width: 64, height: 64)
                    }
                    Text(report.removed > 0 ? String(localized: "Moved \(report.removed) items (\(UninstallerText.size(report.bytes))) to the Trash") : String(localized: "Nothing was moved"))
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(session.app.displayName)
                        .foregroundStyle(.secondary)
                    if !report.survivors.isEmpty {
                        survivors
                            .padding(.top, 14)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            Divider()
            HStack(spacing: 10) {
                Spacer()
                if report.record != nil {
                    Button("Put Back") { model.putBack() }
                }
                Button("Done") { model.close() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
    }

    private var survivors: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("These stayed where they are")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(report.survivors, id: \.url) { survivor in
                HStack(alignment: .top, spacing: 10) {
                    Image(nsImage: model.icon(at: survivor.url))
                        .resizable()
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(survivor.url.lastPathComponent)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(survivor.message)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    if let step = survivor.step {
                        Button(step.title) { step.perform(for: survivor.url) }
                    }
                }
                .help(survivor.url.path)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct RestoredView: View {
    let session: UninstallSession
    let result: AppRemover.Restoration
    private let model = UninstallerModel.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 10) {
                    if result.restored > 0 {
                        DrawnCheck()
                    } else {
                        Image(systemName: "info.circle")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                            .frame(width: 64, height: 64)
                    }
                    Text(result.restored > 0 ? String(localized: "Put back \(result.restored) items") : String(localized: "Nothing was put back"))
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(session.app.displayName)
                        .foregroundStyle(.secondary)
                    if !result.stayed.isEmpty {
                        stayed
                            .padding(.top, 14)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            Divider()
            HStack {
                Spacer()
                Button("Done") { model.close() }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
    }

    private var stayed: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("These stayed where they are")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(result.stayed, id: \.url) { stay in
                VStack(alignment: .leading, spacing: 2) {
                    Text(stay.url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(stay.message)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .help(stay.url.path)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct DrawnCheck: View {
    @State private var drawn = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: drawn ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            CheckStroke()
                .trim(from: 0, to: drawn ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.35).delay(0.4), value: drawn)
        }
        .frame(width: 64, height: 64)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: drawn)
        .onAppear { drawn = true }
        .accessibilityHidden(true)
    }
}

private struct CheckStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.44, y: rect.minY + rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.73, y: rect.minY + rect.height * 0.36))
        return path
    }
}
