import Foundation
import Observation

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
    var exportDocuments: [ProcessedImageExportDocument] {
        processedImages.map { image in
            .init(
                fileURL: image.outputURL,
                filename: image.outputFilename,
                contentType: image.contentType
            )
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

    func saveToPhotos() async {
        saveFeedback = nil
        activeError = nil
        isSavingToPhotos = true
        defer {
            isSavingToPhotos = false
        }

        do {
            try await PhotoLibrarySaveService.save(processedImages)
            saveFeedback = .savedToPhotos(count: processedImages.count)
            BatchImageTipSupport.donateSaveToPhotosSuccess()
        } catch {
            activeError = error
        }
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}
