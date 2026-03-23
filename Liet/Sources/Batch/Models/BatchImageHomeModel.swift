import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class BatchImageHomeModel {
    enum ResizeInputMode: String, CaseIterable, Identifiable {
        case longEdge
        case shortEdge
        case exactSize

        var id: Self {
            self
        }
    }

    private static let defaultShortEdgePixels = 1_080

    var importedImages: [ImportedBatchImage] = []
    var resizeModeSelection: ResizeInputMode = .longEdge {
        didSet {
            if resizeModeSelection != oldValue {
                invalidateProcessedResults()
            }
        }
    }
    var resizeLongEdgeText = "\(BatchResizeMode.defaultLongEdgePixels)" {
        didSet {
            if resizeLongEdgeText != oldValue {
                invalidateProcessedResults()
            }
        }
    }
    var resizeShortEdgeText = "\(BatchImageHomeModel.defaultShortEdgePixels)" {
        didSet {
            if resizeShortEdgeText != oldValue {
                invalidateProcessedResults()
            }
        }
    }
    var exactResizeStrategy: BatchExactResizeStrategy = .contain {
        didSet {
            if exactResizeStrategy != oldValue {
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

    private let localization: BatchImageLocalization
    private var importSessionID: UUID = .init()

    init(
        localization: BatchImageLocalization = .init()
    ) {
        self.localization = localization
    }
}

extension BatchImageHomeModel {
    var canProcess: Bool {
        settings != nil &&
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

    var resizeShortEdgePixels: Int? {
        guard let value = Int(resizeShortEdgeText),
              value > 0 else {
            return nil
        }

        return value
    }

    var isLongEdgeMode: Bool {
        resizeModeSelection == .longEdge
    }

    var isShortEdgeMode: Bool {
        resizeModeSelection == .shortEdge
    }

    var isExactSizeMode: Bool {
        resizeModeSelection == .exactSize
    }

    var selectedImageCountText: String {
        localization.selectedImageCount(importedImages.count)
    }

    var settings: BatchImageSettings? {
        let resizeMode: BatchResizeMode?

        switch resizeModeSelection {
        case .longEdge:
            guard let resizeLongEdgePixels else {
                return nil
            }

            resizeMode = .longEdgePixels(resizeLongEdgePixels)
        case .shortEdge:
            guard let resizeShortEdgePixels else {
                return nil
            }

            resizeMode = .shortEdgePixels(resizeShortEdgePixels)
        case .exactSize:
            guard let resizeLongEdgePixels,
                  let resizeShortEdgePixels else {
                return nil
            }

            resizeMode = .exactSize(
                longEdgePixels: resizeLongEdgePixels,
                shortEdgePixels: resizeShortEdgePixels,
                strategy: exactResizeStrategy
            )
        }

        guard let resizeMode else {
            return nil
        }

        return .init(
            resizeMode: resizeMode,
            compression: compression
        )
    }

    var resizeValidationMessage: String {
        switch resizeModeSelection {
        case .longEdge:
            localization.invalidLongEdgeSizeMessage()
        case .shortEdge:
            localization.invalidShortEdgeSizeMessage()
        case .exactSize:
            localization.invalidExactSizeMessage()
        }
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
            importMessage = localization.importFailureMessage(
                count: result.failureCount
            )
        }

        if importedImages.isEmpty {
            errorMessage = localization.importSelectionFailedMessage()
            return
        }

        BatchImageTipSupport.donateImportSuccess()
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
            errorMessage = resizeValidationMessage
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
            errorMessage = localization.processSelectionFailedMessage()
            return
        }

        resultModel = .init(
            outcome: outcome,
            localization: localization
        )
        BatchImageTipSupport.donateProcessSuccess()
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}
