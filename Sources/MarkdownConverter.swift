import Foundation
import AppKit
import Down

final class MarkdownConverter {
    private let styler: DownStyler

    init() {
        self.styler = DownStyler()
    }

    func toAttributedString(_ markdown: String) -> NSAttributedString {
        guard !markdown.isEmpty else { return NSAttributedString() }

        let down = Down(markdownString: markdown)
        do {
            return try down.toAttributedString(styler: styler)
        } catch {
            return NSAttributedString(string: markdown)
        }
    }
}
