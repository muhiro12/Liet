import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class BatchImageHomeModel {
    var importedImages: [ImportedBatchImage] = []
    var resizeLongEdgeText = "\(BatchResizeMode.defaultLongEdgePixels)" {
        didSet {
            if resizeLongEdgeText != oldValue {
                invalidateProcessedResults()
            }
        }
    }
    var compression: BatchImageCompression = .medium {
        didSet {
            if compression != oldValue {
                invalidateProcessedResults()
            }
        }
    }
    var isImporting = false
    var isProcessing = false
    var errorMessage: String?
    var importMessage: String?
    var resultModel: BatchImageResultModel?

    private var importSessionID: UUID = .init()
}

extension BatchImageHomeModel {
    var canProcess: Bool {
        resizeLongEdgePixels != nil &&
            !importedImages.isEmpty &&
            !isImporting &&
            !isProcessing
    }

    var resizeLongEdgePixels: Int? {
        guard let value = Int(resizeLongEdgeText),
              value > 0 else {
            return nil
        }

        return value
    }

    var selectedImageCountText: String {
        if importedImages.count == 1 {
            return "1 image selected"
        }

        return "\(importedImages.count) images selected"
    }

    var settings: BatchImageSettings? {
        guard let resizeLongEdgePixels else {
            return nil
        }

        return .init(
            resizeMode: .longEdgePixels(resizeLongEdgePixels),
            compression: compression
        )
    }

    func importPhotos(
        from items: [PhotosPickerItem]
    ) async {
        let sessionID: UUID = .init()
        importSessionID = sessionID
        invalidateProcessedResults()
        errorMessage = nil
        importMessage = nil

        guard !items.isEmpty else {
            importedImages = []
            return
        }

        isImporting = true
        let result = await PhotoImportService.importImages(from: items)

        guard importSessionID == sessionID else {
            return
        }

        isImporting = false
        importedImages = result.importedImages

        if result.failureCount > 0 {
            importMessage = if result.failureCount == 1 {
                "1 image couldn't be loaded."
            } else {
                "\(result.failureCount) images couldn't be loaded."
            }
        }

        if importedImages.isEmpty {
            errorMessage = "Couldn't import the selected images."
            return
        }

        await BatchImageTipSupport.donateImportSuccess()
    }

    func clearSelection() {
        importSessionID = .init()
        isImporting = false
        importedImages = []
        errorMessage = nil
        importMessage = nil
        invalidateProcessedResults()
    }

    func invalidateProcessedResults() {
        resultModel = nil
    }

    func processImages() async {
        guard let settings else {
            errorMessage = "Enter a valid long-edge size."
            return
        }

        errorMessage = nil
        isProcessing = true
        let outcome = await BatchImageProcessor.process(
            images: importedImages,
            settings: settings
        )
        isProcessing = false

        guard !outcome.processedImages.isEmpty else {
            resultModel = nil
            errorMessage = "Couldn't process the selected images."
            return
        }

        resultModel = .init(outcome: outcome)
        await BatchImageTipSupport.donateProcessSuccess()
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}
