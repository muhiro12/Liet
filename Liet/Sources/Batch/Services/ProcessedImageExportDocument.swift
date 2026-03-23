import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ProcessedImageExportDocument: FileDocument, Identifiable {
    nonisolated static var readableContentTypes: [UTType] {
        BatchImageProcessor.exportContentTypes
    }

    let id: UUID
    let fileURL: URL
    let filename: String
    let contentType: UTType

    init(
        id: UUID = .init(),
        fileURL: URL,
        filename: String,
        contentType: UTType
    ) {
        self.id = id
        self.fileURL = fileURL
        self.filename = filename
        self.contentType = contentType
    }

    init(
        configuration _: ReadConfiguration
    ) throws {
        throw CocoaError(.fileReadUnsupportedScheme)
    }

    func fileWrapper(
        configuration _: WriteConfiguration
    ) throws -> FileWrapper {
        let data = try Data(contentsOf: fileURL)
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = filename
        return wrapper
    }
}
