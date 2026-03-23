import Foundation
import Observation
import Photos

@MainActor
@Observable
final class BatchImageResultModel: Identifiable {
    enum SaveFeedback: Equatable {
        case exportedFiles(count: Int)
        case savedToPhotos(count: Int)
    }

    let id: UUID = .init()
    let processedImages: [ProcessedBatchImage]
    let failureCount: Int
    let jpegFallbackCount: Int
    let ignoredCompressionCount: Int

    private var customFilenameStems: [UUID: String] = [:]
    var isExportingFiles = false
    var isSavingToPhotos = false
    var saveFeedback: SaveFeedback?
    var activeError: (any Error)?

    init(
        outcome: BatchImageProcessor.Outcome
    ) {
        processedImages = outcome.processedImages
        failureCount = outcome.failureCount
        jpegFallbackCount = outcome.jpegFallbackCount
        ignoredCompressionCount = outcome.ignoredCompressionCount
    }
}

extension BatchImageResultModel {
    var exportItems: [ProcessedImageExportItem] {
        var usedFilenames: Set<String> = []

        return processedImages.map { image in
            let filename = resolvedFilename(
                for: image,
                existingFilenames: &usedFilenames
            )

            return .init(
                id: image.id,
                fileURL: image.outputURL,
                filename: filename,
                contentType: image.contentType
            )
        }
    }

    var exportDocuments: [ProcessedImageExportDocument] {
        exportItems.map { exportItem in
            .init(exportItem: exportItem)
        }
    }

    func beginFileExport() {
        saveFeedback = nil
        activeError = nil
        isExportingFiles = true
    }

    func handleFileExportCompletion(
        _ result: Result<[URL], any Error>
    ) {
        isExportingFiles = false

        switch result {
        case let .success(urls):
            saveFeedback = .exportedFiles(count: urls.count)

            guard !urls.isEmpty else {
                return
            }

            Task {
                BatchImageTipSupport.donateSaveToFilesSuccess()
            }
        case let .failure(error):
            activeError = error
        }
    }

    func handleFileExportCancellation() {
        isExportingFiles = false
    }

    func editableFilenameStem(
        for image: ProcessedBatchImage
    ) -> String {
        customFilenameStems[image.id] ?? image.defaultOutputStem
    }

    func setEditableFilenameStem(
        _ filenameStem: String,
        for image: ProcessedBatchImage
    ) {
        customFilenameStems[image.id] = normalizedFilenameStem(
            filenameStem,
            for: image
        )
    }

    func resolvedFilename(
        for image: ProcessedBatchImage
    ) -> String {
        var usedFilenames: Set<String> = []

        for currentImage in processedImages {
            let filename = resolvedFilename(
                for: currentImage,
                existingFilenames: &usedFilenames
            )

            if currentImage.id == image.id {
                return filename
            }
        }

        return image.outputFilename
    }

    func saveToPhotos() async {
        saveFeedback = nil
        activeError = nil
        isSavingToPhotos = true
        defer {
            isSavingToPhotos = false
        }

        do {
            try await PhotoLibrarySaveService.save(
                photoLibraryInputs
            )
            saveFeedback = .savedToPhotos(count: exportItems.count)
            BatchImageTipSupport.donateSaveToPhotosSuccess()
        } catch {
            activeError = error
        }
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}

private extension BatchImageResultModel {
    var photoLibraryInputs: [PhotoLibrarySaveService.AssetResourceInput] {
        exportItems.map { exportItem in
            .init(
                resourceType: .photo,
                fileURL: exportItem.fileURL,
                originalFilename: exportItem.filename
            )
        }
    }

    func resolvedFilename(
        for image: ProcessedBatchImage,
        existingFilenames: inout Set<String>
    ) -> String {
        let candidateStem = normalizedResolvedStem(for: image)
        let filename = ProcessedImageNaming.makeFilename(
            stem: candidateStem,
            outputFormat: image.outputFormat,
            existingFilenames: existingFilenames
        )
        existingFilenames.insert(filename)
        return filename
    }

    func normalizedResolvedStem(
        for image: ProcessedBatchImage
    ) -> String {
        let customStem = customFilenameStems[image.id]?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if customStem.isEmpty {
            return image.defaultOutputStem
        }

        return customStem
    }

    func normalizedFilenameStem(
        _ filenameStem: String,
        for image: ProcessedBatchImage
    ) -> String {
        let trimmedStem = filenameStem
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let filenameExtension = ".\(image.outputFilenameExtension)"

        if trimmedStem.lowercased().hasSuffix(filenameExtension.lowercased()) {
            return String(trimmedStem.dropLast(filenameExtension.count))
        }

        return trimmedStem
    }
}
