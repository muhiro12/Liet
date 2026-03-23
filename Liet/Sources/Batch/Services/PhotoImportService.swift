import CoreTransferable
import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

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

extension PhotoImportService {
    nonisolated static func originalFilename(
        from transferredFileURL: URL?
    ) -> String? {
        guard let transferredFileURL else {
            return nil
        }

        let filename = transferredFileURL.lastPathComponent
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return filename.isEmpty ? nil : filename
    }
}

private extension PhotoImportService {
    struct ImportedPhotoFile: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(
                importedContentType: .image,
                shouldAttemptToOpenInPlace: true
            ) { receivedFile in
                .init(fileURL: receivedFile.file)
            }
        }

        let fileURL: URL
    }

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
        if let importedPhotoFile = try? await item.loadTransferable(
            type: ImportedPhotoFile.self
        ) {
            return try importImage(
                from: importedPhotoFile,
                supportedTypeIdentifiers: item.supportedContentTypes.map(\.identifier),
                selectionIndex: selectionIndex,
                into: directoryURL
            )
        }

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

    nonisolated static func importImage(
        from importedPhotoFile: ImportedPhotoFile,
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL
    ) throws -> ImportedBatchImage {
        let imageSource = try ImageIOImageSupport.imageSource(
            url: importedPhotoFile.fileURL
        )
        let originalFormat = ImageIOImageSupport.detectedFormat(
            for: imageSource,
            supportedTypeIdentifiers: supportedTypeIdentifiers
        )
        let sourceURL = directoryURL.appendingPathComponent(
            importedFilename(
                for: originalFormat,
                selectionIndex: selectionIndex
            )
        )

        try FileManager.default.copyItem(
            at: importedPhotoFile.fileURL,
            to: sourceURL
        )

        return .init(
            sourceURL: sourceURL,
            originalFilename: originalFilename(
                from: importedPhotoFile.fileURL
            ),
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
