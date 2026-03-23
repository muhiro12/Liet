import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class BatchImageHomeModel {
    enum AlertState: Equatable {
        case invalidLongEdgeSize
        case invalidShortEdgeSize
        case invalidExactSize
        case importSelectionFailed
        case processSelectionFailed
    }

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
    var activeAlert: AlertState?
    var importFailureCount: Int?
    var resultModel: BatchImageResultModel?

    private var importSessionID: UUID = .init()
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

    private var resizeValidationAlertState: AlertState {
        switch resizeModeSelection {
        case .longEdge:
            .invalidLongEdgeSize
        case .shortEdge:
            .invalidShortEdgeSize
        case .exactSize:
            .invalidExactSize
        }
    }

    func importPhotos(
        from items: [PhotosPickerItem]
    ) async {
        let sessionID: UUID = .init()
        importSessionID = sessionID
        invalidateProcessedResults()
        activeAlert = nil
        importFailureCount = nil

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
            importFailureCount = result.failureCount
        }

        if importedImages.isEmpty {
            activeAlert = .importSelectionFailed
            return
        }

        BatchImageTipSupport.donateImportSuccess()
    }

    func clearSelection() {
        importSessionID = .init()
        isImporting = false
        importedImages = []
        activeAlert = nil
        importFailureCount = nil
        invalidateProcessedResults()
    }

    func invalidateProcessedResults() {
        resultModel = nil
    }

    func processImages() {
        guard let settings else {
            activeAlert = resizeValidationAlertState
            return
        }

        activeAlert = nil
        isProcessing = true
        let outcome = BatchImageProcessor.process(
            images: importedImages,
            settings: settings
        )
        isProcessing = false

        guard !outcome.processedImages.isEmpty else {
            resultModel = nil
            activeAlert = .processSelectionFailed
            return
        }

        resultModel = .init(outcome: outcome)
        BatchImageTipSupport.donateProcessSuccess()
    }

    func replayTips() {
        BatchImageTipSupport.resetTips()
    }
}
