import CommonCrypto
import Foundation
import Security

@objc protocol FanHelperProtocol {
    func version(reply: @escaping (Int) -> Void)
    func setManual(fan: Int, rpm: Double, reply: @escaping (Bool) -> Void)
    func setAuto(fan: Int, reply: @escaping (Bool) -> Void)
    func update(from path: String, reply: @escaping (Bool) -> Void)
    func setService(label: String, on: Bool, reply: @escaping (Bool) -> Void)
}

enum HelperServices {
    static let folder = "/Library/LaunchDaemons"
    static let sharing = [
        "com.openssh.sshd": "/System/Library/LaunchDaemons/ssh.plist",
        "com.apple.screensharing": "/System/Library/LaunchDaemons/com.apple.screensharing.plist",
    ]
    private static let reserved = ["com.apple.", "com.pesotchi.pika-tools", "com.pikapik.tools"]
    private static let characters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")

    static func allows(_ label: String) -> Bool {
        let lower = label.lowercased()
        return (1...128).contains(label.utf8.count) && label.unicodeScalars.allSatisfy(characters.contains) && !reserved.contains(where: lower.hasPrefix)
    }

    static func plist(for label: String, in folder: String = folder) -> String? {
        if let path = sharing[label] { return path }
        guard allows(label), let names = try? FileManager.default.contentsOfDirectory(atPath: folder) else { return nil }
        return names.sorted().filter { $0.hasSuffix(".plist") }.map { folder + "/" + $0 }.first { path in
            (try? FileManager.default.attributesOfItem(atPath: path))?[.type] as? FileAttributeType == .typeRegular
                && NSDictionary(contentsOfFile: path)?["Label"] as? String == label
        }
    }
}

enum FanHelperInfo {
    static let version = 3
    static let selfUpdating = 2
    static let suffix = ".fans"
    static let appIdentifier = "com.pesotchi.pika-tools"

    static func requirement(identifier: String) -> String? {
        var code: SecCode?
        var staticCode: SecStaticCode?
        var info: CFDictionary?
        guard SecCodeCopySelf([], &code) == errSecSuccess, let code,
              SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode,
              SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &info) == errSecSuccess,
              let info = info as? [String: Any]
        else { return nil }
        if let team = info[kSecCodeInfoTeamIdentifier as String] as? String {
            return "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(team)\""
        }
        guard let leaf = (info[kSecCodeInfoCertificates as String] as? [SecCertificate])?.first else { return nil }
        let data = SecCertificateCopyData(leaf) as Data
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = data.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        let hash = digest.map { String(format: "%02X", $0) }.joined()
        return "identifier \"\(identifier)\" and certificate leaf = H\"\(hash)\""
    }

    static func build(_ path: String, requirement: String? = nil) -> Int? {
        var code: SecStaticCode?
        var info: CFDictionary?
        guard SecStaticCodeCreateWithPath(URL(fileURLWithPath: path) as CFURL, [], &code) == errSecSuccess, let code else { return nil }
        if let requirement {
            var compiled: SecRequirement?
            guard SecRequirementCreateWithString(requirement as CFString, [], &compiled) == errSecSuccess, let compiled,
                  SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate), compiled) == errSecSuccess
            else { return nil }
        }
        guard SecCodeCopySigningInformation(code, [], &info) == errSecSuccess,
              let plist = (info as? [String: Any])?[kSecCodeInfoPList as String] as? [String: Any],
              let build = plist["CFBundleVersion"] as? String
        else { return nil }
        return Int(build)
    }

    static func stage(_ target: String, from source: String, requirement: String) -> Bool {
        let staged = target + ".new"
        unlink(staged)
        guard let data = FileManager.default.contents(atPath: source),
              FileManager.default.createFile(atPath: staged, contents: data, attributes: [.posixPermissions: 0o755]),
              let candidate = build(staged, requirement: requirement), candidate >= build(target) ?? 0
        else {
            unlink(staged)
            return false
        }
        return true
    }

    @discardableResult
    static func commit(_ target: String, requirement: String) -> Bool {
        let staged = target + ".new"
        guard let candidate = build(staged, requirement: requirement), candidate >= build(target) ?? 0,
              rename(staged, target) == 0
        else {
            unlink(staged)
            return false
        }
        return true
    }
}
