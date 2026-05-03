import Foundation

enum OutputFormat: String, CaseIterable, Identifiable {
    case richText = "Rich Text"
    case html = "HTML"
    case plainText = "Plain Text"

    var id: String { rawValue }
}
