import QuickLookUI
import UniformTypeIdentifiers

final class ArchivePreview: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        guard let html = ArchivePage.html(for: request.fileURL) else { throw CocoaError(.fileReadCorruptFile) }
        let reply = QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 560, height: 640)) { reply in
            reply.stringEncoding = .utf8
            return Data(html.utf8)
        }
        return reply
    }
}
