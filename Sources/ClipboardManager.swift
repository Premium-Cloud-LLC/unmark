import AppKit

final class ClipboardManager {
    func copy(attributed: NSAttributedString, format: OutputFormat) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let range = NSRange(location: 0, length: attributed.length)
        let plain = attributed.string

        switch format {
        case .richText:
            if let rtf = try? attributed.data(
                from: range,
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) {
                pasteboard.setData(rtf, forType: .rtf)
            }
            if let html = try? attributed.data(
                from: range,
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            ) {
                pasteboard.setData(html, forType: .html)
            }
            pasteboard.setString(plain, forType: .string)

        case .html:
            if let html = try? attributed.data(
                from: range,
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            ) {
                pasteboard.setData(html, forType: .html)
            }
            pasteboard.setString(plain, forType: .string)

        case .plainText:
            pasteboard.setString(plain, forType: .string)
        }
    }
}
