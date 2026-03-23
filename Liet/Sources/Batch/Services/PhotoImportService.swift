import Foundation
import PhotosUI
import SwiftUI

enum PhotoImportService {
    struct Result {
        let importedImages: [ImportedBatchImage]
        let failureCount: Int
    }
}

extension PhotoImportService {
    nonisolated static func importImages(
        from items: [PhotosPickerItem]
    ) async -> Result {
        guard !items.isEmpty else {
            return .init(
                importedImages: [],
                failureCount: 0
            )
        }

        guard let importDirectory = makeImportDirectory() else {
            return .init(
                importedImages: [],
                failureCount: items.count
            )
        }

        var importedImages: [ImportedBatchImage] = []
        var failureCount = 0

        for (index, item) in items.enumerated() {
            do {
                let importedImage = try await importImage(
                    item,
                    selectionIndex: index + 1,
                    into: importDirectory
                )
                importedImages.append(importedImage)
            } catch {
                failureCount += 1
            }
        }

        return .init(
            importedImages: importedImages,
            failureCount: failureCount
        )
    }
}

private extension PhotoImportService {
    nonisolated static func makeImportDirectory() -> URL? {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "LietImported-\(UUID().uuidString)",
                isDirectory: true
            )

        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            return directoryURL
        } catch {
            return nil
        }
    }

    nonisolated static func importImage(
        _ item: PhotosPickerItem,
        selectionIndex: Int,
        into directoryURL: URL
    ) async throws -> ImportedBatchImage {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw BatchImageServiceError.failedToLoadImageData
        }

        let imageSource = try ImageIOImageSupport.imageSource(data: data)
        let originalFormat = ImageIOImageSupport.detectedFormat(
            for: imageSource,
            supportedTypeIdentifiers: item.supportedContentTypes.map(\.identifier)
        )
        let filename = importedFilename(
            for: originalFormat,
            selectionIndex: selectionIndex
        )
        let sourceURL = directoryURL.appendingPathComponent(filename)
        try data.write(
            to: sourceURL,
            options: .atomic
        )

        return .init(
            sourceURL: sourceURL,
            originalFilename: nil,
            originalFormat: originalFormat,
            pixelSize: try ImageIOImageSupport.pixelSize(from: imageSource),
            previewImage: try ImageIOImageSupport.previewImage(from: sourceURL),
            selectionIndex: selectionIndex
        )
    }

    nonisolated static func importedFilename(
        for format: ImageFileFormat,
        selectionIndex: Int
    ) -> String {
        let paddedIndex = String(
            format: "%03d",
            selectionIndex
        )
        let fileExtension = format.preferredOutputFormat.filenameExtension
        return "import-\(paddedIndex).\(fileExtension)"
    }
}
