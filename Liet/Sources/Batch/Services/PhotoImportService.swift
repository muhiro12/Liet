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

    nonisolated static func importImage(
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL,
        loadTransferredFileURL: () async throws -> URL?,
        loadData: () async throws -> Data?
    ) async throws -> ImportedBatchImage {
        do {
            if let transferredFileURL = try await loadTransferredFileURL() {
                do {
                    return try importImage(
                        from: transferredFileURL,
                        supportedTypeIdentifiers: supportedTypeIdentifiers,
                        selectionIndex: selectionIndex,
                        into: directoryURL
                    )
                } catch {
                    logTransferredFileFallback(
                        selectionIndex: selectionIndex,
                        error: error
                    )
                }
            }
        } catch {
            logTransferredFileFallback(
                selectionIndex: selectionIndex,
                phase: .loadTransferredFile,
                error: error
            )
        }

        return try await importImage(
            supportedTypeIdentifiers: supportedTypeIdentifiers,
            selectionIndex: selectionIndex,
            into: directoryURL,
            loadData: loadData
        )
    }
}

extension PhotoImportService {
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
        try await importImage(
            supportedTypeIdentifiers: item.supportedContentTypes.map(\.identifier),
            selectionIndex: selectionIndex,
            into: directoryURL,
            loadTransferredFileURL: {
                try await item.loadTransferable(
                    type: ImportedPhotoFile.self
                )?.fileURL
            },
            loadData: {
                try await item.loadTransferable(type: Data.self)
            }
        )
    }

    nonisolated static func importImage(
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL,
        loadData: () async throws -> Data?
    ) async throws -> ImportedBatchImage {
        guard let data = try await loadData() else {
            throw BatchImageServiceError.failedToLoadImageData
        }

        return try importImage(
            from: data,
            supportedTypeIdentifiers: supportedTypeIdentifiers,
            selectionIndex: selectionIndex,
            into: directoryURL
        )
    }

    nonisolated static func importImage(
        from data: Data,
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL
    ) throws -> ImportedBatchImage {
        let imageSource = try ImageIOImageSupport.imageSource(data: data)
        let originalFormat = ImageIOImageSupport.detectedFormat(
            for: imageSource,
            supportedTypeIdentifiers: supportedTypeIdentifiers
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
