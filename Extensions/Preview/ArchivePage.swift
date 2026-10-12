import Foundation

enum ArchivePage {
    private static let maxDepth = 16
    private static let hugeSize: Int64 = 1 << 30
    private static let hugeRatio: Int64 = 1000
    private static let scriptExtensions: Set<String> = ["command", "sh", "pkg", "scpt", "workflow"]

    private final class Node {
        let name: String
        let isFolder: Bool
        var size: Int64 = 0
        var children: [String: Node] = [:]

        init(_ name: String, isFolder: Bool) {
            self.name = name
            self.isFolder = isFolder
        }
    }

    static func html(for url: URL) -> String? {
        guard let listing = ArchiveListing.read(url) else { return nil }
        let name = url.lastPathComponent
        let isPart = name.range(of: #"\.(\d{3,}|z\d{2}|r\d{2}|part\d+\.rar)$"#, options: [.regularExpression, .caseInsensitive]) != nil
        let (root, count, expanded) = tree(listing.items)
        let isComplete = !(listing.isDamaged || listing.isCut)
        guard count > 0 || listing.namesHidden || isPart || isComplete else { return nil }

        let packed = Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        let isHuge = isComplete && expanded > hugeSize && expanded / max(packed, 1) > hugeRatio
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        let size = formatter.string(fromByteCount: expanded)

        var notes: [String] = []
        if listing.namesHidden { notes.append(String(localized: "Protected with a password")) }
        if isPart { notes.append(String(localized: "Part of a multi-part archive")) }
        if listing.isDamaged, !isPart { notes.append(String(localized: "Damaged. Showing what could be read.")) }
        if listing.isCut { notes.append(String(localized: "Only the first items are shown.")) }
        if isHuge { notes.append(String(localized: "It could fill up your disk.")) }
        if hasProgram(listing.items) { notes.append(String(localized: "Contains a program. Open it only if you trust where it came from.")) }

        var facts: [String] = []
        if count > 0 || notes.isEmpty { facts.append(String(localized: "\(count) items")) }
        if expanded > 0, isComplete { facts.append(String(localized: "Expands to \(size)")) }

        let language = Bundle.main.preferredLocalizations.first ?? "en"
        let direction = Locale.Language(identifier: language).characterDirection == .rightToLeft ? "rtl" : "ltr"
        let locked = listing.isEncrypted || listing.namesHidden
        let title = escape(clean(name))
        var page = "<!doctype html><html lang=\"\(escape(language))\" dir=\"\(direction)\"><head><meta charset=\"utf-8\"><meta name=\"color-scheme\" content=\"light dark\"><title>\(title)</title><style>\(style)</style></head><body>"
        page += "<header><h1><span class=\"t\">\(title)</span>"
        if locked { page += "<span class=\"k\" role=\"img\" aria-label=\"\(escape(String(localized: "Protected with a password")))\"></span>" }
        page += "</h1>"
        if !facts.isEmpty { page += "<p>\(escape(facts.joined(separator: " · ")))</p>" }
        page += "</header>"
        for note in notes { page += "<p class=\"note\">\(escape(note))</p>" }
        if !root.children.isEmpty { rows(root, depth: 0, openAll: count <= 60, formatter: formatter, into: &page) }
        return page + "</body></html>"
    }

    private static func tree(_ items: [ArchiveListing.Item]) -> (root: Node, count: Int, size: Int64) {
        let root = Node("", isFolder: true)
        var count = 0
        var total: Int64 = 0
        for item in items {
            var parts = item.path.split(separator: "/").map(String.init).filter { $0 != "." && $0 != ".." }
            if parts.count > maxDepth { parts = Array(parts[..<(maxDepth - 1)]) + [parts[(maxDepth - 1)...].joined(separator: "/")] }
            var node = root
            for (index, part) in parts.enumerated() {
                let child: Node
                if let found = node.children[part] {
                    child = found
                } else {
                    child = Node(part, isFolder: index < parts.count - 1 || item.isFolder)
                    node.children[part] = child
                    count += 1
                }
                if !item.isFolder { child.size += item.size }
                node = child
            }
            if !item.isFolder && !parts.isEmpty { total += item.size }
        }
        return (root, count, total)
    }

    private static func rows(_ node: Node, depth: Int, openAll: Bool, formatter: ByteCountFormatter, into page: inout String) {
        let children = node.children.values.sorted {
            $0.isFolder != $1.isFolder ? $0.isFolder : $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        page += "<ul>"
        for child in children {
            let label = "<span class=\"n\">\(escape(clean(child.name)))</span>"
            let size = child.size > 0 ? "<span class=\"s\">\(formatter.string(fromByteCount: child.size))</span>" : ""
            if child.children.isEmpty {
                page += "<li><div class=\"r \(child.isFolder ? "d" : "f")\">\(label)\(size)</div></li>"
            } else {
                page += "<li><details\(openAll || (depth == 0 && node.children.count == 1) ? " open" : "")><summary class=\"r d\">\(label)\(size)</summary>"
                rows(child, depth: depth + 1, openAll: openAll, formatter: formatter, into: &page)
                page += "</details></li>"
            }
        }
        page += "</ul>"
    }

    private static func hasProgram(_ items: [ArchiveListing.Item]) -> Bool {
        items.contains { item in
            let parts = item.path.split(separator: "/")
            if parts.prefix(2).contains(where: { $0.lowercased().hasSuffix(".app") }) { return true }
            guard parts.count <= 2, !item.isFolder, let last = parts.last else { return false }
            return item.isExecutable || scriptExtensions.contains((String(last) as NSString).pathExtension.lowercased())
        }
    }

    private static func clean(_ text: String) -> String {
        let scalars = text.unicodeScalars
        var result = String.UnicodeScalarView()
        result.append(contentsOf: scalars.prefix(255).map { isHidden($0) ? "\u{FFFD}" : $0 })
        return String(result) + (scalars.count > 255 ? "…" : "")
    }

    private static func isHidden(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.properties.generalCategory {
        case .control, .lineSeparator, .paragraphSeparator: true
        default: (0x202A...0x202E).contains(scalar.value) || (0x2066...0x2069).contains(scalar.value)
        }
    }

    private static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func mask(_ path: String, rule: String = "nonzero") -> String {
        let svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'><path fill-rule='\(rule)' d='\(path)'/></svg>"
        return "url(\"data:image/svg+xml,\(svg.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")\")"
    }

    private static let style = """
    :root{color-scheme:light dark;--dim:#6e6e73;--rule:rgba(0,0,0,.1);--tint:rgba(0,0,0,.05);--folder:#3d9bf0;--file:#9a9aa0;--accent:#e68a00;\
    --doc:\(mask("M4 1h5.5L13 4.5V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1z"));\
    --dir:\(mask("M1.5 3.5A1.5 1.5 0 0 1 3 2h3.1c.4 0 .8.16 1.06.44L8.2 3.5H13a1.5 1.5 0 0 1 1.5 1.5v7a1.5 1.5 0 0 1-1.5 1.5H3A1.5 1.5 0 0 1 1.5 12z"));\
    --lock:\(mask("M4.5 7V5a3.5 3.5 0 0 1 7 0v2h.5a1 1 0 0 1 1 1v5.5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V8a1 1 0 0 1 1-1zm1.5 0h4V5a2 2 0 0 0-4 0z", rule: "evenodd"))}
    @media(prefers-color-scheme:dark){:root{--dim:#a1a1a6;--rule:rgba(255,255,255,.14);--tint:rgba(255,255,255,.08);--folder:#5aa9ff;--file:#8e8e93;--accent:#ffb340}}
    body{margin:0;padding:22px 22px 28px;font:13px/1.45 -apple-system,system-ui,sans-serif;-webkit-font-smoothing:antialiased}
    header{padding:0 6px 14px;margin-bottom:8px;border-bottom:1px solid var(--rule)}
    h1{display:flex;align-items:center;gap:8px;margin:0;font-size:20px;line-height:1.3;font-weight:600}
    h1 .t{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
    .k{flex:none;width:16px;height:16px;background:var(--dim);-webkit-mask:var(--lock) center/contain no-repeat}
    header p{margin:2px 0 0;color:var(--dim)}
    .note{margin:10px 6px 0;padding:8px 12px;border-radius:8px;background:var(--tint);border-inline-start:3px solid var(--accent)}
    ul{margin:0;padding:0;list-style:none}
    ul ul{padding-inline-start:22px}
    .r{position:relative;display:flex;align-items:center;gap:12px;min-height:26px;padding:0 6px 0 20px;border-radius:6px}
    summary{list-style:none}
    summary::-webkit-details-marker{display:none}
    summary::before{content:"";position:absolute;inset-inline-start:6px;top:50%;width:5px;height:5px;margin-top:-4px;border:solid var(--dim);border-width:0 1.5px 1.5px 0;transform:rotate(-45deg)}
    [dir=rtl] summary::before{transform:rotate(135deg)}
    details[open]>summary::before{margin-top:-5px;transform:rotate(45deg)}
    .n{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
    .n::before{content:"";display:inline-block;width:16px;height:16px;margin-inline-end:8px;vertical-align:-3px;background:var(--file);-webkit-mask:var(--doc) center/contain no-repeat}
    .d .n::before{background:var(--folder);-webkit-mask-image:var(--dir)}
    .s{flex:none;color:var(--dim);font-variant-numeric:tabular-nums}
    """
}
