import Foundation

@main
enum TestFanHelper {
    static let dir = FileManager.default.temporaryDirectory.appendingPathComponent("test-fan-helper-\(UUID().uuidString)").path

    static func run(_ tool: String, _ arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments
        process.standardError = FileHandle.nullDevice
        try! process.run()
        process.waitUntilExit()
        precondition(process.terminationStatus == 0, "\(tool) \(arguments)")
    }

    static func make(_ name: String, build: Int?, code: Int = 0, identifier: String = "test.fans", identity: String = ProcessInfo.processInfo.environment["SIGN_IDENTITY"] ?? "pikapik Dev") -> String {
        let path = dir + "/" + name
        let source = path + ".c"
        try! "int main(void) { return \(code); }\n".write(toFile: source, atomically: true, encoding: .utf8)
        var flags = [source, "-o", path]
        if let build {
            let plist = try! PropertyListSerialization.data(fromPropertyList: ["CFBundleVersion": String(build)], format: .xml, options: 0)
            FileManager.default.createFile(atPath: path + ".plist", contents: plist)
            flags.append("-Wl,-sectcreate,__TEXT,__info_plist," + path + ".plist")
        }
        run("/usr/bin/cc", flags)
        run("/usr/bin/codesign", ["-f", "-s", identity, "--identifier", identifier, path])
        return path
    }

    static func main() {
        guard let requirement = FanHelperInfo.requirement(identifier: "test.fans") else {
            fatalError("sign this test with the certificate named in SIGN_IDENTITY, pikapik Dev by default")
        }
        try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: dir) }

        let installed = dir + "/installed"
        try! FileManager.default.copyItem(atPath: make("v10", build: 10), toPath: installed)
        precondition(FanHelperInfo.build(installed) == 10)
        precondition(FanHelperInfo.build(installed, requirement: requirement) == 10)

        let garbage = dir + "/garbage"
        try! "not a program".write(toFile: garbage, atomically: true, encoding: .utf8)
        let rejected = [
            "older": make("v9", build: 9),
            "no build number": make("none", build: nil),
            "other identifier": make("other", build: 12, identifier: "test.other"),
            "ad-hoc signature": make("adhoc", build: 12, identity: "-"),
            "not a program": garbage,
            "missing file": dir + "/missing",
        ]
        for (name, path) in rejected {
            let before = FileManager.default.contents(atPath: installed)
            precondition(!FanHelperInfo.stage(installed, from: path, requirement: requirement), name)
            precondition(!FileManager.default.fileExists(atPath: installed + ".new"), name)
            try? FileManager.default.copyItem(atPath: path, toPath: installed + ".new")
            precondition(!FanHelperInfo.commit(installed, requirement: requirement), name)
            precondition(FileManager.default.contents(atPath: installed) == before, name)
            precondition(!FileManager.default.fileExists(atPath: installed + ".new"), name)
            print("rejects \(name): ok")
        }

        for (name, path) in [("newer", make("v11", build: 11)), ("same build", make("v11b", build: 11, code: 1))] {
            let before = FileManager.default.contents(atPath: installed)
            precondition(FanHelperInfo.stage(installed, from: path, requirement: requirement), name)
            precondition(FileManager.default.contents(atPath: installed) == before, "\(name): changed before commit")
            precondition(FileManager.default.contentsEqual(atPath: installed + ".new", andPath: path), "\(name): staged copy")
            precondition(FanHelperInfo.commit(installed, requirement: requirement), name)
            precondition(FileManager.default.contentsEqual(atPath: installed, andPath: path), name)
            precondition(!FileManager.default.fileExists(atPath: installed + ".new"), name)
            let mode = (try! FileManager.default.attributesOfItem(atPath: installed))[.posixPermissions] as! Int
            precondition(mode == 0o755, "\(name): mode \(String(mode, radix: 8))")
            print("accepts \(name): ok")
        }
        precondition(!FanHelperInfo.stage(installed, from: dir + "/v10", requirement: requirement), "back to 10")
        precondition(!FanHelperInfo.commit(installed, requirement: requirement), "nothing staged")
        print("rejects going back after an update: ok")
    }
}
