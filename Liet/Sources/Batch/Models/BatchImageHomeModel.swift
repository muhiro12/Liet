import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class BatchImageHomeModel {
    enum AlertState: Equatable {
        case invalidResizeSize
        case importSelectionFailed
        case processSelectionFailed
    }

    var importedImages: [ImportedBatchImage] = []
    private(set) var referenceDimension: BatchResizeReferenceDimension
    private(set) var referencePixelsText: String
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
    private var importSessionID: UUID = .init()

    init(
        settingsStore: BatchImageSettingsStore = .live()
    ) {
        self.settingsStore = settingsStore
        let persistedSettings = settingsStore.load() ?? .default
        referenceDimension = persistedSettings.referenceDimension
        referencePixelsText = "\(persistedSettings.referencePixels)"
        resizeWidthText = "\(persistedSettings.exactWidthPixels)"
        resizeHeightText = "\(persistedSettings.exactHeightPixels)"
        keepsAspectRatio = persistedSettings.resizeMode == .aspectRatioPreserved
        exactResizeStrategy = persistedSettings.exactResizeStrategy
        compression = persistedSettings.compression
    }
}

extension BatchImageHomeModel {
    var canProcess: Bool {
        settings != nil &&
            !importedImages.isEmpty &&
            !isImporting &&
            !isProcessing
    }

    var referencePixels: Int? {
        guard let value = Int(referencePixelsText),
              value > 0 else {
            return nil
        }

        return value
    }

    var exactWidthPixels: Int? {
        guard let value = Int(resizeWidthText),
              value > 0 else {
            return nil
        }

        return value
    }

    var exactHeightPixels: Int? {
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
        if keepsAspectRatio {
            guard let referencePixels else {
                return nil
            }

            return .init(
                resizeMode: .fitWithin(
                    referenceDimension: referenceDimension,
                    pixels: referencePixels
                ),
                compression: compression
            )
        }

        guard let exactWidthPixels,
              let exactHeightPixels else {
            return nil
        }

        return .init(
            resizeMode: .exactSize(
                widthPixels: exactWidthPixels,
                heightPixels: exactHeightPixels,
                strategy: exactResizeStrategy
            ),
            compression: compression
        )
    }

    func setReferenceDimension(
        _ newValue: BatchResizeReferenceDimension
    ) {
        guard referenceDimension != newValue else {
            return
        }

        referenceDimension = newValue
        didUpdateSettings()
    }

    func setReferencePixelsText(
        _ newValue: String
    ) {
        referencePixelsText = newValue
        didUpdateSettings()
    }

    func setResizeWidthText(
        _ newValue: String
    ) {
        resizeWidthText = newValue
        didUpdateSettings()
    }

    func setResizeHeightText(
        _ newValue: String
    ) {
        resizeHeightText = newValue
        didUpdateSettings()
    }

    func setKeepsAspectRatio(
        _ newValue: Bool
    ) {
        guard keepsAspectRatio != newValue else {
            return
        }

        keepsAspectRatio = newValue
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
        invalidateProcessedResults()
        persistSettingsIfPossible()
    }

    func persistSettingsIfPossible() {
        let persistedResizeMode: PersistedBatchResizeMode = keepsAspectRatio
            ? .aspectRatioPreserved
            : .exactSize
        let storedReferencePixels: Int

        if keepsAspectRatio {
            guard let referencePixels else {
                return
            }

            storedReferencePixels = referencePixels
        } else {
            storedReferencePixels = referencePixels ?? BatchResizeMode.defaultReferencePixels
        }

        let storedExactWidthPixels: Int
        let storedExactHeightPixels: Int

        if keepsAspectRatio {
            storedExactWidthPixels = exactWidthPixels ?? BatchResizeMode.defaultWidthPixels
            storedExactHeightPixels = exactHeightPixels ?? BatchResizeMode.defaultHeightPixels
        } else {
            guard let exactWidthPixels,
                  let exactHeightPixels else {
                return
            }

            storedExactWidthPixels = exactWidthPixels
            storedExactHeightPixels = exactHeightPixels
        }

        settingsStore.save(
            .init(
                resizeMode: persistedResizeMode,
                referenceDimension: referenceDimension,
                referencePixels: storedReferencePixels,
                exactWidthPixels: storedExactWidthPixels,
                exactHeightPixels: storedExactHeightPixels,
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
