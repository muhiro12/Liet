import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class BatchImageHomeModel {
    private enum Metrics {
        static let minimumAspectRatio = 0.0001
    }

    enum AlertState: Equatable {
        case invalidResizeSize
        case importSelectionFailed
        case processSelectionFailed
    }

    var importedImages: [ImportedBatchImage] = []
    private(set) var resizeWidthText: String
    private(set) var resizeHeightText: String
    private(set) var keepsAspectRatio: Bool
    var exactResizeStrategy: BatchExactResizeStrategy = .stretch {
        didSet {
            if exactResizeStrategy != oldValue {
                didUpdateSettings()
            }
        }
    }
    var compression: BatchImageCompression = .off {
        didSet {
            if compression != oldValue {
                didUpdateSettings()
            }
        }
    }
    var isImporting = false
    var isProcessing = false
    var activeAlert: AlertState?
    var importFailureCount: Int?
    var resultModel: BatchImageResultModel?

    private let settingsStore: BatchImageSettingsStore
    private var lockedAspectRatio: Double
    private var importSessionID: UUID = .init()

    init(
        settingsStore: BatchImageSettingsStore = .live()
    ) {
        self.settingsStore = settingsStore
        let persistedSettings = settingsStore.load() ?? .default
        resizeWidthText = "\(persistedSettings.widthPixels)"
        resizeHeightText = "\(persistedSettings.heightPixels)"
        keepsAspectRatio = persistedSettings.keepsAspectRatio
        exactResizeStrategy = persistedSettings.exactResizeStrategy
        compression = persistedSettings.compression
        lockedAspectRatio = Double(persistedSettings.widthPixels) /
            Double(max(1, persistedSettings.heightPixels))
    }
}

extension BatchImageHomeModel {
    var canProcess: Bool {
        settings != nil &&
            !importedImages.isEmpty &&
            !isImporting &&
            !isProcessing
    }

    var resizeWidthPixels: Int? {
        guard let value = Int(resizeWidthText),
              value > 0 else {
            return nil
        }

        return value
    }

    var resizeHeightPixels: Int? {
        guard let value = Int(resizeHeightText),
              value > 0 else {
            return nil
        }

        return value
    }

    var showsExactResizeStrategy: Bool {
        !keepsAspectRatio
    }

    var showsCompressionSection: Bool {
        importedImages.contains { image in
            supportsLossyCompression(for: image)
        }
    }

    var showsMixedCompressionHint: Bool {
        showsCompressionSection &&
            importedImages.contains { image in
                image.originalFormat == .png
            }
    }

    var settings: BatchImageSettings? {
        guard let resizeWidthPixels,
              let resizeHeightPixels else {
            return nil
        }

        let resizeMode: BatchResizeMode = if keepsAspectRatio {
            .fitWithin(
                widthPixels: resizeWidthPixels,
                heightPixels: resizeHeightPixels
            )
        } else {
            .exactSize(
                widthPixels: resizeWidthPixels,
                heightPixels: resizeHeightPixels,
                strategy: exactResizeStrategy
            )
        }

        return .init(
            resizeMode: resizeMode,
            compression: compression
        )
    }

    func setResizeWidthText(
        _ newValue: String
    ) {
        resizeWidthText = newValue

        if keepsAspectRatio,
           let newWidthPixels = Int(newValue),
           newWidthPixels > 0 {
            let adjustedHeight = max(
                1,
                Int(
                    (
                        Double(newWidthPixels) /
                            max(lockedAspectRatio, Metrics.minimumAspectRatio)
                    )
                    .rounded()
                )
            )
            resizeHeightText = "\(adjustedHeight)"
        }

        didUpdateSettings()
    }

    func setResizeHeightText(
        _ newValue: String
    ) {
        resizeHeightText = newValue

        if keepsAspectRatio,
           let newHeightPixels = Int(newValue),
           newHeightPixels > 0 {
            let adjustedWidth = max(
                1,
                Int(
                    (
                        Double(newHeightPixels) *
                            max(lockedAspectRatio, Metrics.minimumAspectRatio)
                    )
                    .rounded()
                )
            )
            resizeWidthText = "\(adjustedWidth)"
        }

        didUpdateSettings()
    }

    func setKeepsAspectRatio(
        _ newValue: Bool
    ) {
        guard keepsAspectRatio != newValue else {
            return
        }

        keepsAspectRatio = newValue
        updateLockedAspectRatioIfPossible()
        didUpdateSettings()
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
            activeAlert = .invalidResizeSize
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

private extension BatchImageHomeModel {
    func didUpdateSettings() {
        updateLockedAspectRatioIfPossible()
        invalidateProcessedResults()
        persistSettingsIfPossible()
    }

    func updateLockedAspectRatioIfPossible() {
        guard let resizeWidthPixels,
              let resizeHeightPixels else {
            return
        }

        lockedAspectRatio = Double(resizeWidthPixels) /
            Double(max(1, resizeHeightPixels))
    }

    func persistSettingsIfPossible() {
        guard let resizeWidthPixels,
              let resizeHeightPixels else {
            return
        }

        settingsStore.save(
            .init(
                widthPixels: resizeWidthPixels,
                heightPixels: resizeHeightPixels,
                keepsAspectRatio: keepsAspectRatio,
                exactResizeStrategy: exactResizeStrategy,
                compression: compression
            )
        )
    }

    func supportsLossyCompression(
        for image: ImportedBatchImage
    ) -> Bool {
        let outputFormat = BatchImageProcessor.resolvedOutputFormat(
            for: image.originalFormat
        )

        return outputFormat.supportsLossyCompressionQuality
    }
}
