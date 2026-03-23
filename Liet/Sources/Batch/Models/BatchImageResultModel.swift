import Foundation
import Observation

@MainActor
@Observable
final class BatchImageResultModel: Identifiable {
    let id: UUID = .init()
    let processedImages: [ProcessedBatchImage]
    let failureCount: Int
    let jpegFallbackCount: Int
    let ignoredCompressionCount: Int

    var isExportingFiles = false
    var isSavingToPhotos = false
    var saveMessage: String?
    var errorMessage: String?

    private let localization: BatchImageLocalization

    init(
        outcome: BatchImageProcessor.Outcome,
        localization: BatchImageLocalization = .init()
    ) {
        processedImages = outcome.processedImages
        failureCount = outcome.failureCount
        jpegFallbackCount = outcome.jpegFallbackCount
        ignoredCompressionCount = outcome.ignoredCompressionCount
        self.localization = localization
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

    var titleText: String {
        localization.resultReadyTitle(count: processedImages.count)
    }

    var detailMessages: [String] {
        var messages: [String] = []

        if failureCount > 0 {
            messages.append(
                localization.resultFailureMessage(count: failureCount)
            )
        }

        if jpegFallbackCount > 0 {
            messages.append(
                localization.jpegFallbackMessage(count: jpegFallbackCount)
            )
        }

        if ignoredCompressionCount > 0 {
            messages.append(
                localization.pngCompressionMessage(
                    count: ignoredCompressionCount
                )
            )
        }

        return messages
    }

    func beginFileExport() {
        saveMessage = nil
        errorMessage = nil
        isExportingFiles = true
    }

    func handleFileExportCompletion(
        _ result: Result<[URL], any Error>
    ) {
        isExportingFiles = false

        switch result {
        case let .success(urls):
            saveMessage = localization.exportFilesSuccessMessage(
                count: urls.count
            )

            guard !urls.isEmpty else {
                return
            }

            Task {
                await BatchImageTipSupport.donateSaveToFilesSuccess()
            }
        case let .failure(error):
            errorMessage = error.localizedDescription
        }
    }

    func handleFileExportCancellation() {
        isExportingFiles = false
    }

    func saveToPhotos() async {
        saveMessage = nil
        errorMessage = nil
        isSavingToPhotos = true
        defer {
            isSavingToPhotos = false
        }

        do {
            try await PhotoLibrarySaveService.save(processedImages)
            saveMessage = localization.exportPhotosSuccessMessage(
                count: processedImages.count
            )
            await BatchImageTipSupport.donateSaveToPhotosSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}
