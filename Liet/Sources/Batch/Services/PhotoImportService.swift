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

        let importDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "LietImported-\(UUID().uuidString)",
                isDirectory: true
            )

        do {
            try FileManager.default.createDirectory(
                at: importDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            return .init(
                importedImages: [],
                failureCount: items.count
            )
        }

        var importedImages: [ImportedBatchImage] = []
        var failureCount = 0

        for (index, item) in items.enumerated() {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    throw BatchImageServiceError.failedToLoadImageData
                }

                let imageSource = try ImageIOImageSupport.imageSource(data: data)
                let originalFormat = ImageIOImageSupport.detectedFormat(
                    for: imageSource,
                    supportedTypeIdentifiers: item.supportedContentTypes.map(\.identifier)
                )
                let filename = "import-\(String(format: "%03d", index + 1)).\(originalFormat.preferredOutputFormat.filenameExtension)"
                let sourceURL = importDirectory.appendingPathComponent(filename)
                try data.write(
                    to: sourceURL,
                    options: .atomic
                )

                let pixelSize = try ImageIOImageSupport.pixelSize(from: imageSource)
                let previewImage = try ImageIOImageSupport.previewImage(from: sourceURL)
                importedImages.append(
                    .init(
                        sourceURL: sourceURL,
                        originalFilename: nil,
                        originalFormat: originalFormat,
                        pixelSize: pixelSize,
                        previewImage: previewImage,
                        selectionIndex: index + 1
                    )
                )
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
