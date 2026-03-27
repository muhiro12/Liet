import Foundation
import LietLibrary
import SwiftUI
import UniformTypeIdentifiers

struct ProcessedImageArchiveExportDocument: FileDocument {
    nonisolated static var readableContentTypes: [UTType] {
        [.zip]
    }

    let exportItems: [ProcessedImageExportItem]
    let filename: String

    init(
        exportItems: [ProcessedImageExportItem],
        filename: String
    ) {
        self.exportItems = exportItems
        self.filename = filename
    }

    init(
        configuration _: ReadConfiguration
    ) throws {
        throw CocoaError(.fileReadUnsupportedScheme)
    }

    func fileWrapper(
        configuration _: WriteConfiguration
    ) throws -> FileWrapper {
        do {
            let archiveEntries = try exportItems.map { exportItem in
                BatchImageArchiveBuilder.Entry(
                    filename: exportItem.filename,
                    data: try Data(
                        contentsOf: exportItem.fileURL
                    )
                )
            }
            let archiveData = try BatchImageArchiveBuilder().makeArchiveData(
                for: archiveEntries
            )
            let wrapper = FileWrapper(
                regularFileWithContents: archiveData
            )
            wrapper.preferredFilename = filename
            return wrapper
        } catch {
            throw BatchImageServiceError.failedToCreateArchive
        }
    }
}
