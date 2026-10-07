import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ConvertFormats {
    static let all = ["jpeg", "png", "heic", "gif", "tiff", "pdf", "mp4", "mov", "m4a", "wav", "aiff"]
    static let videos: Set<String> = ["mov", "mp4", "m4v"]
    private static let sounds: Set<String> = ["wav", "aiff", "aif", "aifc", "mp3", "m4a", "aac", "caf", "flac"]
    private static let current = [
        "jpg": "jpeg", "jpeg": "jpeg", "jpe": "jpeg", "png": "png", "heic": "heic", "heif": "heic", "gif": "gif", "tif": "tiff", "tiff": "tiff",
        "mp4": "mp4", "mov": "mov", "m4a": "m4a", "wav": "wav", "aiff": "aiff", "aif": "aiff",
    ]
    private static let readable = Set(CGImageSourceCopyTypeIdentifiers() as? [String] ?? [])
    private static let images: [String] = {
        let writable = CGImageDestinationCopyTypeIdentifiers() as? [String] ?? []
        let types: [(String, UTType)] = [("jpeg", .jpeg), ("png", .png), ("heic", .heic), ("gif", .gif), ("tiff", .tiff)]
        return types.filter { writable.contains($0.1.identifier) }.map(\.0) + ["pdf"]
    }()

    static func targets(for url: URL) -> [String] {
        let ext = url.pathExtension.lowercased()
        if videos.contains(ext) { return ["mp4", "mov", "m4a"] }
        if sounds.contains(ext) { return ["m4a", "wav", "aiff"] }
        if let type = UTType(filenameExtension: ext), readable.contains(type.identifier) { return images }
        return []
    }

    static func format(of url: URL) -> String? {
        current[url.pathExtension.lowercased()]
    }

    static func targets(for files: [URL]) -> [String] {
        let kinds = files.map { (targets: targets(for: $0), format: format(of: $0)) }.filter { !$0.targets.isEmpty }
        guard let first = kinds.first else { return [] }
        return first.targets.filter { target in
            kinds.allSatisfy { $0.targets.contains(target) } && !kinds.allSatisfy { $0.format == target }
        }
    }
}
