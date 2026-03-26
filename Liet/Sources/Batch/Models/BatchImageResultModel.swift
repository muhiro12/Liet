import Foundation
import LietLibrary
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

    private var filenamePlanner: BatchImageFilenamePlanner = .init()
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
        let resolvedFilenames = filenamePlanner.resolvedFilenames(
            for: processedImages.map(filenamePlannerItem(for:))
        )

        return processedImages.map { image in
            let filename = resolvedFilenames[image.id] ?? image.outputFilename

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
        filenamePlanner.editableFilenameStem(
            for: filenamePlannerItem(for: image)
        )
    }

    func setEditableFilenameStem(
        _ filenameStem: String,
        for image: ProcessedBatchImage
    ) {
        filenamePlanner.setEditableFilenameStem(
            filenameStem,
            for: filenamePlannerItem(for: image)
        )
    }

    func resolvedFilename(
        for image: ProcessedBatchImage
    ) -> String {
        filenamePlanner.resolvedFilename(
            for: filenamePlannerItem(for: image),
            within: processedImages.map(filenamePlannerItem(for:))
        )
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

    func filenamePlannerItem(
        for image: ProcessedBatchImage
    ) -> BatchImageFilenamePlanner.Item {
        .init(
            id: image.id,
            defaultStem: image.defaultOutputStem,
            outputFormat: image.outputFormat
        )
    }
}
