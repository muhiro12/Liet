import Foundation
import UniformTypeIdentifiers

struct ProcessedImageExportItem: Identifiable {
    let id: UUID
    let fileURL: URL
    let filename: String
    let contentType: UTType
}
