import AppKit
import SwiftUI

@Observable
final class SpeedTest {
    enum Phase {
        case starting, download, upload
    }

    static let shared = SpeedTest()
    private static let key = "speed-test-result"

    private(set) var result: SpeedResult?
    private(set) var phase: Phase?
    private(set) var failure: SpeedResult.Failure?
    private(set) var live: (download: Double, upload: Double) = (0, 0)

    @ObservationIgnored private var process: Process?
    @ObservationIgnored private var output: FileHandle?
    @ObservationIgnored private let file = FileManager.default.temporaryDirectory.appendingPathComponent("pika-tools-speed-test.json")

    var isRunning: Bool { phase != nil }

    private init() {
        result = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(SpeedResult.self, from: $0) }
    }

    func start() {
        guard process == nil else { return }
        try? FileManager.default.removeItem(at: file)
        failure = nil
        var primary: Int32 = 0
        var secondary: Int32 = 0
        guard openpty(&primary, &secondary, nil, nil, nil) == 0 else {
            failure = .failed
            return
        }
        let output = FileHandle(fileDescriptor: primary, closeOnDealloc: true)
        let terminal = FileHandle(fileDescriptor: secondary, closeOnDealloc: false)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/networkQuality")
        process.arguments = ["-s", "-c" + file.path]
        process.standardOutput = terminal
        process.standardError = terminal
        process.terminationHandler = { process in
            DispatchQueue.main.async { SpeedTest.shared.finish(process) }
        }
        output.readabilityHandler = { handle in
            var buffer = [UInt8](repeating: 0, count: 4096)
            let count = read(handle.fileDescriptor, &buffer, buffer.count)
            guard count > 0 else {
                handle.readabilityHandler = nil
                return
            }
            guard let speeds = SpeedResult.progress(String(decoding: buffer.prefix(count), as: UTF8.self)) else { return }
            DispatchQueue.main.async { SpeedTest.shared.update(process, speeds) }
        }
        do {
            try process.run()
        } catch {
            output.readabilityHandler = nil
            close(secondary)
            failure = .failed
            return
        }
        close(secondary)
        self.process = process
        self.output = output
        live = (0, 0)
        phase = .starting
    }

    func cancel() {
        guard let process else { return }
        stop()
        process.terminate()
    }

    func handle(_ url: URL) {
        guard url.host == "speed-test" else { return }
        SettingsWindow.show(.speedTest)
        start()
    }

    private func stop() {
        process = nil
        output?.readabilityHandler = nil
        output = nil
        phase = nil
    }

    private func update(_ process: Process, _ speeds: (download: Double, upload: Double)) {
        guard self.process === process else { return }
        live = speeds
        phase = speeds.upload > 0 ? .upload : speeds.download > 0 ? .download : .starting
    }

    private func finish(_ process: Process) {
        guard self.process === process else { return }
        stop()
        let data = (try? Data(contentsOf: file)) ?? Data()
        try? FileManager.default.removeItem(at: file)
        switch SpeedResult.parse(data) {
        case .success(let result):
            self.result = result
            UserDefaults.standard.set(try? JSONEncoder().encode(result), forKey: Self.key)
        case .failure(let failure):
            self.failure = failure
        }
    }
}

extension SpeedTest {
    static func format(_ speed: Double) -> String {
        speed.formatted(.number.precision(.fractionLength(speed < 10 ? 1 : 0)))
    }

    static func checked(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.formattingContext = .middleOfSentence
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var phaseText: Text {
        switch phase {
        case .download: Text("Checking download…")
        case .upload: Text("Checking upload…")
        default: Text("Getting ready…")
        }
    }

    var failureTitle: Text {
        failure == .offline ? Text("No internet connection") : Text("The check didn’t finish")
    }

    var failureHint: Text {
        failure == .offline ? Text("Check Wi-Fi or the cable, then try again.") : Text("Try again in a minute.")
    }
}

struct SpeedTestSettings: View {
    private let test = SpeedTest.shared

    private var download: Double? {
        guard test.isRunning else { return test.result?.download }
        return test.phase == .starting ? nil : test.live.download
    }

    private var upload: Double? {
        guard test.isRunning else { return test.result?.upload }
        return test.phase == .upload ? test.live.upload : nil
    }

    var body: some View {
        Form {
            SettingsHeader(tab: .speedTest, text: String(localized: "How fast your internet is right now"))
            Section {
                VStack(spacing: 18) {
                    HStack(spacing: 0) {
                        SpeedNumber(title: "Download", symbol: "arrow.down", value: download, active: test.phase == .download)
                        Divider().frame(height: 72)
                        SpeedNumber(title: "Upload", symbol: "arrow.up", value: upload, active: test.phase == .upload)
                    }
                    status
                        .frame(minHeight: 20)
                    if test.isRunning {
                        Button(action: test.cancel) { Text("Cancel").frame(minWidth: 140) }
                            .controlSize(.large)
                    } else {
                        Button(action: test.start) { Text("Check Speed").frame(minWidth: 140) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .settingAnchor(String(localized: "Check Speed"))
            } footer: {
                Text("Takes about half a minute. The check runs on Apple’s servers.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let result = test.result {
                Group {
                    Section {
                        LabeledContent {
                            Text(level(result.responsiveness))
                                .foregroundStyle(.secondary)
                        } label: {
                            RowLabel(Text("Responsiveness"), Text("How quickly things react while the internet is busy"))
                        }
                        LabeledContent {
                            Text("\(Int(result.ping.rounded())) ms")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        } label: {
                            RowLabel(Text("Ping"), Text("How long a signal takes to get there and back"))
                        }
                    }
                    Section {
                        ForEach(SpeedResult.Activity.allCases, id: \.self) { verdict($0, result) }
                    } header: {
                        Text("What it’s good for")
                    }
                    .settingAnchor(String(localized: "What it’s good for"))
                }
                .opacity(test.isRunning ? 0.4 : 1)
            }
            Section {
                ShortcutLink(title: String(localized: "Speed Test"), path: "speed-test")
            } header: {
                Text("Buttons in Control Center and widgets")
            } footer: {
                Text("Add the Open URLs action in Shortcuts, with a link.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .formStyle(.grouped)
        .settingsPage()
    }

    @ViewBuilder
    private var status: some View {
        if test.isRunning {
            HStack(spacing: 8) {
                ProgressView().controlSize(.small)
                test.phaseText
            }
            .foregroundStyle(.secondary)
        } else if test.failure != nil {
            VStack(spacing: 2) {
                Label { test.failureTitle } icon: { Image(systemName: "exclamationmark.triangle.fill") }
                    .foregroundStyle(.orange)
                test.failureHint
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        } else if let result = test.result {
            Text("Checked \(SpeedTest.checked(result.date))")
                .foregroundStyle(.secondary)
        }
    }

    private func level(_ level: SpeedResult.Level) -> LocalizedStringKey {
        switch level {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }

    private func verdict(_ activity: SpeedResult.Activity, _ result: SpeedResult) -> some View {
        let good = result.isGood(for: activity)
        let title: Text
        var note: Text?
        switch activity {
        case .video:
            title = Text("Movies and shows in 4K")
            if !good {
                note = result.download >= 5 ? Text("May pause to load. HD will play smoothly.") : Text("Even HD video may pause to load.")
            }
        case .calls:
            title = Text("Video calls")
            if !good { note = Text("The picture may freeze or get blurry.") }
        case .games:
            title = Text("Online games")
            if !good { note = Text("Fast-paced games may lag.") }
        case .downloads:
            title = Text("Big downloads")
            let time = Duration.seconds(result.bigDownloadTime)
                .formatted(.units(allowed: [.hours, .minutes], width: .wide, maximumUnitCount: 2, fractionalPart: .hide(rounded: .up)))
            note = Text("A 10 GB game takes about \(time)")
        }
        return Label {
            RowLabel(title, note)
        } icon: {
            Image(systemName: good ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(good ? .green : .orange)
                .accessibilityLabel(good ? Text("Yes") : Text("Not quite"))
        }
    }
}

private struct SpeedNumber: View {
    let title: LocalizedStringKey
    let symbol: String
    let value: Double?
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 2) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(active ? Color.accentColor : .secondary)
                .symbolEffect(.pulse, options: .repeating, isActive: active && !reduceMotion)
            Text(verbatim: value.map(SpeedTest.format) ?? "–")
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(value == nil ? .tertiary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(reduceMotion ? .identity : .numericText(value: value ?? 0))
                .animation(reduceMotion ? nil : .snappy, value: value)
            Text("Mbit/s")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct SpeedTestRow: View {
    private let test = SpeedTest.shared
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button { SettingsWindow.show(.speedTest) } label: {
                HStack(spacing: 10) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(test.isRunning ? Color.white : Color.secondary)
                        .frame(width: 28, height: 28)
                        .background(test.isRunning ? Color.accentColor : Color.secondary.opacity(0.15), in: Circle())
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Speed Test")
                            .font(.body)
                            .lineLimit(1)
                        summary
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(test.isRunning ? LocalizedStringKey("Cancel") : "Check") {
                test.isRunning ? test.cancel() : test.start()
            }
            .controlSize(.small)
            .glassButtons()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if hovering {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.fill.quaternary)
            }
        }
        .onHover { hovering = $0 }
    }

    @ViewBuilder
    private var summary: some View {
        if test.isRunning {
            test.phaseText
        } else if test.failure != nil {
            test.failureTitle
        } else if let result = test.result {
            HStack(spacing: 3) {
                Image(systemName: "arrow.down")
                Text(verbatim: SpeedTest.format(result.download))
                Image(systemName: "arrow.up")
                    .padding(.leading, 4)
                Text(verbatim: SpeedTest.format(result.upload))
                Text("Mbit/s")
            }
            .monospacedDigit()
        } else {
            Text("Not checked yet")
        }
    }
}
