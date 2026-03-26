import CoreTransferable
import Foundation
import LietLibrary
import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

enum PhotoImportService {
    typealias AssetResourceFilenameFetcher = (String) -> [BatchImageImportFilenameCandidate]
    typealias OriginalFilenameResolver = (String?) -> String?

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
    nonisolated static func resolvePhotoLibraryOriginalFilename(
        for itemIdentifier: String?,
        assetResourceFilenameFetcher: AssetResourceFilenameFetcher = assetResourceFilenameCandidates(for:)
    ) -> String? {
        guard let itemIdentifier else {
            return nil
        }

        let normalizedItemIdentifier = itemIdentifier
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedItemIdentifier.isEmpty else {
            return nil
        }

        let candidates = assetResourceFilenameFetcher(
            normalizedItemIdentifier
        )

        return BatchImageImportFilenamePolicy.preferredOriginalFilename(
            from: candidates
        )
    }

    nonisolated static func originalFilename(
        from transferredFileURL: URL?
    ) -> String? {
        BatchImageImportFilenamePolicy.originalFilename(
            fromTransferredFilename: transferredFileURL?.lastPathComponent
        )
    }

    nonisolated static func importImage(
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL,
        itemIdentifier: String? = nil,
        originalFilenameResolver: OriginalFilenameResolver = { itemIdentifier in
            resolvePhotoLibraryOriginalFilename(for: itemIdentifier)
        },
        loadTransferredFileURL: () async throws -> URL?,
        loadData: () async throws -> Data?
    ) async throws -> ImportedBatchImage {
        let resolvedOriginalFilename = originalFilenameResolver(
            itemIdentifier
        )

        do {
            if let transferredFileURL = try await loadTransferredFileURL() {
                do {
                    return try importImage(
                        from: transferredFileURL,
                        supportedTypeIdentifiers: supportedTypeIdentifiers,
                        selectionIndex: selectionIndex,
                        into: directoryURL,
                        resolvedOriginalFilename: resolvedOriginalFilename
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
            resolvedOriginalFilename: resolvedOriginalFilename,
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
            itemIdentifier: item.itemIdentifier,
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
        resolvedOriginalFilename: String? = nil,
        loadData: () async throws -> Data?
    ) async throws -> ImportedBatchImage {
        guard let data = try await loadData() else {
            throw BatchImageServiceError.failedToLoadImageData
        }

        return try importImage(
            from: data,
            supportedTypeIdentifiers: supportedTypeIdentifiers,
            selectionIndex: selectionIndex,
            into: directoryURL,
            resolvedOriginalFilename: resolvedOriginalFilename
        )
    }

    nonisolated static func importImage(
        from data: Data,
        supportedTypeIdentifiers: [String],
        selectionIndex: Int,
        into directoryURL: URL,
        resolvedOriginalFilename: String? = nil
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
            originalFilename: resolvedOriginalFilename,
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

    nonisolated static func assetResourceFilenameCandidates(
        for itemIdentifier: String
    ) -> [BatchImageImportFilenameCandidate] {
        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [itemIdentifier],
            options: nil
        )

        guard let asset = assets.firstObject else {
            return []
        }

        return PHAssetResource.assetResources(for: asset).map { resource in
            .init(
                resourceKind: importResourceKind(resource.type),
                originalFilename: resource.originalFilename
            )
        }
    }

    nonisolated static func importResourceKind(
        _ type: PHAssetResourceType
    ) -> BatchImageImportResourceKind {
        importResourceKinds[type] ?? .other
    }
}

private extension PhotoImportService {
    nonisolated static let importResourceKinds: [PHAssetResourceType: BatchImageImportResourceKind] = [
        .photo: .photo,
        .fullSizePhoto: .fullSizePhoto,
        .alternatePhoto: .alternatePhoto,
        .pairedVideo: .pairedVideo,
        .video: .video,
        .audio: .audio,
        .fullSizeVideo: .fullSizeVideo,
        .adjustmentData: .adjustmentData,
        .fullSizePairedVideo: .fullSizePairedVideo,
        .adjustmentBasePairedVideo: .adjustmentBasePairedVideo
    ]
}
