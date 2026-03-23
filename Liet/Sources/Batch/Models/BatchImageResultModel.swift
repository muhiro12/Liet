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

    var titleText: String {
        if processedImages.count == 1 {
            return "1 image ready"
        }

        return "\(processedImages.count) images ready"
    }

    var detailMessages: [String] {
        var messages: [String] = []

        if failureCount > 0 {
            if failureCount == 1 {
                messages.append("1 image couldn't be processed.")
            } else {
                messages.append("\(failureCount) images couldn't be processed.")
            }
        }

        if jpegFallbackCount > 0 {
            if jpegFallbackCount == 1 {
                messages.append("1 image was exported as JPEG because the original format couldn't be preserved.")
            } else {
                messages.append("\(jpegFallbackCount) images were exported as JPEG because the original format couldn't be preserved.")
            }
        }

        if ignoredCompressionCount > 0 {
            if ignoredCompressionCount == 1 {
                messages.append("PNG ignores the compression quality setting.")
            } else {
                messages.append("PNG images ignore the compression quality setting.")
            }
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
            if urls.count == 1 {
                saveMessage = "Exported 1 image to Files."
            } else {
                saveMessage = "Exported \(urls.count) images to Files."
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
            if processedImages.count == 1 {
                saveMessage = "Saved 1 image to Photos."
            } else {
                saveMessage = "Saved \(processedImages.count) images to Photos."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
