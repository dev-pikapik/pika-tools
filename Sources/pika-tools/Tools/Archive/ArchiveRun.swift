import Foundation

extension Archive {
    struct Stage {
        var executable: URL
        var arguments: [String]
        var input: Data?
        var directory: URL?
        var file: URL?

        init(_ executable: URL, _ arguments: [String], input: Data? = nil, directory: URL? = nil, file: URL? = nil) {
            self.executable = executable
            self.arguments = arguments
            self.input = input
            self.directory = directory
            self.file = file
        }
    }

    final class Lines: @unchecked Sendable {
        private var buffer: [UInt8] = []
        private let progress: Bool
        private let handler: (String) -> Void

        init(progress: Bool, _ handler: @escaping (String) -> Void) {
            self.progress = progress
            self.handler = handler
        }

        func feed(_ data: Data) {
            for byte in data {
                if byte == 10 || (progress && (byte == 13 || byte == 8)) {
                    handler(String(decoding: buffer, as: UTF8.self))
                    buffer.removeAll(keepingCapacity: true)
                } else {
                    buffer.append(byte)
                    #if APPSTORE
                    // bsdtar asks for a password without a line break, so each prompt is cut off as a line of its own
                    if byte == 58, buffer.suffix(17).elementsEqual("Enter passphrase:".utf8) {
                        handler(String(decoding: buffer, as: UTF8.self))
                        buffer.removeAll(keepingCapacity: true)
                    }
                    #endif
                }
            }
        }

        func finish() {
            guard !buffer.isEmpty else { return }
            handler(String(decoding: buffer, as: UTF8.self))
            buffer.removeAll()
        }
    }

    final class Meter: @unchecked Sendable {
        private let lock = NSLock()
        private let report: @Sendable (Double) -> Void
        private var last = -1
        private var count = 0

        init(_ report: @escaping @Sendable (Double) -> Void) {
            self.report = report
        }

        func set(_ fraction: Double) {
            let percent = Int(min(max(fraction, 0), 0.99) * 100)
            let changed = lock.withLock {
                guard percent > last else { return false }
                last = percent
                return true
            }
            if changed { report(Double(percent) / 100) }
        }

        func tick(of total: Int) {
            let done = lock.withLock {
                count += 1
                return count
            }
            set(Double(done) / Double(max(total, 1)))
        }

        func finish() {
            report(1)
        }
    }

    final class Messages: @unchecked Sendable {
        private let lock = NSLock()
        private var stored: [String] = []

        var lines: [String] { lock.withLock { stored } }

        func add(_ line: String) {
            let text = line.trimmingCharacters(in: .whitespaces)
            guard !text.isEmpty else { return }
            lock.withLock { if stored.count < 2000 { stored.append(text) } }
        }
    }

    static let ditto = URL(fileURLWithPath: "/usr/bin/ditto")
    static let bsdtar = URL(fileURLWithPath: "/usr/bin/tar")

    private static let ignoreBrokenPipes: Void = { _ = signal(SIGPIPE, SIG_IGN) }()

    #if !APPSTORE
    static func sevenZip() throws -> URL {
        if let url = Bundle.main.url(forAuxiliaryExecutable: "7zz") { return url }
        if let path = ProcessInfo.processInfo.environment["PIKA_7ZZ"] { return URL(fileURLWithPath: path) }
        throw ArchiveError.failed("7zz is missing")
    }
    #endif

    static func percent(_ line: String) -> Int? {
        let text = line.drop { $0 == " " }
        let digits = text.prefix { $0 >= "0" && $0 <= "9" }
        guard !digits.isEmpty, digits.count <= 3, text.dropFirst(digits.count).first == "%", let value = Int(digits), value <= 100 else { return nil }
        return value
    }

    static func run(_ stages: [Stage], job: Job, listing: Bool = false, output: ((String) -> Void)? = nil, errors: ((String) -> Void)? = nil, watch: (() -> ArchiveError?)? = nil) throws -> [Int32] {
        _ = ignoreBrokenPipes
        guard !job.isCancelled else { throw ArchiveError.cancelled }
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let links = stages.dropFirst().map { _ in Pipe() }
        let finished = DispatchSemaphore(value: 0)
        var processes: [Process] = []
        for (index, stage) in stages.enumerated() {
            let process = Process()
            process.executableURL = stage.executable
            process.arguments = stage.arguments
            process.currentDirectoryURL = stage.directory
            process.environment = ["LC_ALL": "en_US.UTF-8", "PATH": "/usr/bin:/bin"]
            let input = stage.input == nil ? nil : Pipe()
            if index > 0 {
                process.standardInput = links[index - 1]
            } else if let input {
                process.standardInput = input
            } else {
                process.standardInput = FileHandle.nullDevice
            }
            var sink: FileHandle?
            if index < links.count {
                process.standardOutput = links[index]
            } else if let file = stage.file {
                guard FileManager.default.createFile(atPath: file.path, contents: nil), let handle = try? FileHandle(forWritingTo: file) else {
                    processes.forEach { $0.terminate() }
                    throw ArchiveError.failed("cannot write \(file.lastPathComponent)")
                }
                sink = handle
                process.standardOutput = handle
            } else if output != nil {
                process.standardOutput = outputPipe
            } else {
                process.standardOutput = FileHandle.nullDevice
            }
            let errorEnd = FileHandle(fileDescriptor: dup(errorPipe.fileHandleForWriting.fileDescriptor), closeOnDealloc: false)
            process.standardError = errorEnd
            process.terminationHandler = { [job] process in
                job.detach(process)
                finished.signal()
            }
            do {
                try process.run()
            } catch {
                try? errorEnd.close()
                try? sink?.close()
                try? errorPipe.fileHandleForWriting.close()
                processes.forEach { $0.terminate() }
                throw ArchiveError.failed("cannot start \(stage.executable.lastPathComponent)")
            }
            try? errorEnd.close()
            try? sink?.close()
            processes.append(process)
            if !job.attach(process) { process.terminate() }
            if let data = stage.input, let input {
                try? input.fileHandleForWriting.write(contentsOf: data)
                try? input.fileHandleForWriting.close()
            }
        }
        try? errorPipe.fileHandleForWriting.close()
        let readers = DispatchGroup()
        func read(_ pipe: Pipe, progress: Bool, _ handler: ((String) -> Void)?) {
            let lines = Lines(progress: progress) { handler?($0) }
            readers.enter()
            DispatchQueue.global().async {
                // read(upToCount:) waits for the whole block or the end, so progress and a wrong password would show up late; availableData returns what has arrived
                while case let data = pipe.fileHandleForReading.availableData, !data.isEmpty { lines.feed(data) }
                lines.finish()
                readers.leave()
            }
        }
        read(errorPipe, progress: true, errors)
        if output != nil { read(outputPipe, progress: !listing, output) }
        var verdict: ArchiveError?
        var running = processes.count
        while running > 0 {
            if finished.wait(timeout: watch == nil ? .distantFuture : .now() + 0.1) == .success {
                running -= 1
            } else if verdict == nil, let found = watch?() {
                verdict = found
                processes.filter(\.isRunning).forEach { $0.terminate() }
            }
        }
        readers.wait()
        if job.isCancelled { throw ArchiveError.cancelled }
        if let verdict = verdict ?? watch?() { throw verdict }
        return processes.map(\.terminationStatus)
    }
}
