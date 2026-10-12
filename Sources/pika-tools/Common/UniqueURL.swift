import Foundation

extension FileManager {
    func uniqueURL(for name: String, in folder: URL, directory: Bool = false, parts: Int = 0) -> URL {
        var base = name
        var ext = ""
        if !directory {
            base = (name as NSString).deletingPathExtension
            ext = (name as NSString).pathExtension
            if base.lowercased().hasSuffix(".tar") {
                base = (base as NSString).deletingPathExtension
                ext = "tar." + ext
            }
        }
        func taken(_ url: URL) -> Bool {
            fileExists(atPath: url.path) || stride(from: 1, through: parts, by: 1).contains { fileExists(atPath: url.path + String(format: ".%03d", $0)) }
        }
        var url = folder.appending(path: name)
        var number = 2
        while taken(url) {
            url = folder.appending(path: ext.isEmpty ? "\(base) \(number)" : "\(base) \(number).\(ext)")
            number += 1
        }
        return url
    }
}
