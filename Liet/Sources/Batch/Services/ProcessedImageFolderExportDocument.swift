import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ProcessedImageFolderExportDocument: FileDocument {
    nonisolated static var readableContentTypes: [UTType] {
        [.folder]
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
            var directoryFileWrappers: [String: FileWrapper] = [:]

            for exportItem in exportItems {
                let data = try Data(
                    contentsOf: exportItem.fileURL
                )
                let fileWrapper = FileWrapper(
                    regularFileWithContents: data
                )
                fileWrapper.preferredFilename = exportItem.filename
                directoryFileWrappers[exportItem.filename] = fileWrapper
            }

            let directoryWrapper = FileWrapper(
                directoryWithFileWrappers: directoryFileWrappers
            )
            directoryWrapper.preferredFilename = filename
            return directoryWrapper
        } catch {
            throw BatchImageServiceError.failedToCreateExportFolder
        }
    }
}
