import Foundation
import LietLibrary
import Observation

@MainActor
@Observable
final class BatchImageHomeModel {
    typealias SettingsSource = BatchImageSettingsSource

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
    private(set) var userPresetSettings: PersistedBatchImageSettings?
    private(set) var lastUsedSettings: PersistedBatchImageSettings
    private(set) var namingTemplate: BatchImageNamingTemplate
    private(set) var customNamingPrefixText: String
    private(set) var numberingStyle: BatchImageNumberingStyle
    var settingsSource: SettingsSource = .lastUsed {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               settingsSource != oldValue {
                let oldState = preferencesState(
                    settingsSource: oldValue
                )
                var newState = oldState
                newState.setSettingsSource(settingsSource)
                applyUpdatedPreferencesState(
                    oldState: oldState,
                    newState: newState
                )
            }
        }
    }
    var exactResizeStrategy: BatchExactResizeStrategy = .stretch {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               exactResizeStrategy != oldValue {
                let oldState = preferencesState(
                    exactResizeStrategy: oldValue
                )
                var newState = oldState
                newState.setExactResizeStrategy(exactResizeStrategy)

                if !newState.keepsAspectRatio {
                    BatchImageTipSupport.markExactResizeMethodConfigured()
                }

                applyUpdatedPreferencesState(
                    oldState: oldState,
                    newState: newState
                )
            }
        }
    }
    var compression: BatchImageCompression = .off {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               compression != oldValue {
                let oldState = preferencesState(
                    compression: oldValue
                )
                var newState = oldState
                newState.setCompression(compression)
                applyUpdatedPreferencesState(
                    oldState: oldState,
                    newState: newState
                )
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
    private var suppressesAutomaticSettingsDidChange = false

    init(
        settingsStore: BatchImageSettingsStore = .live()
    ) {
        self.settingsStore = settingsStore
        let preferencesState = BatchImagePreferencesState(
            preferences: settingsStore.load() ?? .default
        )
        referenceDimension = preferencesState.referenceDimension
        referencePixelsText = preferencesState.referencePixelsText
        resizeWidthText = preferencesState.resizeWidthText
        resizeHeightText = preferencesState.resizeHeightText
        keepsAspectRatio = preferencesState.keepsAspectRatio
        userPresetSettings = preferencesState.userPresetSettings
        lastUsedSettings = preferencesState.lastUsedSettings
        settingsSource = preferencesState.settingsSource
        exactResizeStrategy = preferencesState.exactResizeStrategy
        compression = preferencesState.compression
        namingTemplate = preferencesState.namingTemplate
        customNamingPrefixText = preferencesState.customNamingPrefixText
        numberingStyle = preferencesState.numberingStyle
    }
}

extension BatchImageHomeModel {
    var currentPreferencesState: BatchImagePreferencesState {
        .init(
            referenceDimension: referenceDimension,
            referencePixelsText: referencePixelsText,
            resizeWidthText: resizeWidthText,
            resizeHeightText: resizeHeightText,
            keepsAspectRatio: keepsAspectRatio,
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings,
            settingsSource: settingsSource,
            exactResizeStrategy: exactResizeStrategy,
            compression: compression,
            namingTemplate: namingTemplate,
            customNamingPrefixText: customNamingPrefixText,
            numberingStyle: numberingStyle
        )
    }

    func beginImportSession() -> UUID {
        let sessionID: UUID = .init()
        importSessionID = sessionID
        invalidateProcessedResults()
        activeAlert = nil
        importFailureCount = nil
        return sessionID
    }

    func resetImportSession() {
        importSessionID = .init()
    }

    func applyImportResult(
        _ result: PhotoImportService.Result,
        sessionID: UUID
    ) {
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

    func applyUpdatedPreferencesState(
        oldState: BatchImagePreferencesState,
        newState: BatchImagePreferencesState
    ) {
        guard newState != oldState else {
            return
        }

        let shouldInvalidateProcessedResults = hasEditableSettingsChanged(
            from: oldState,
            to: newState
        )
        applyPreferencesState(newState)

        if shouldInvalidateProcessedResults {
            invalidateProcessedResults()
        }
    }

    func applyPreferencesState(
        _ preferencesState: BatchImagePreferencesState
    ) {
        suppressesAutomaticSettingsDidChange = true
        defer {
            suppressesAutomaticSettingsDidChange = false
        }

        referenceDimension = preferencesState.referenceDimension
        referencePixelsText = preferencesState.referencePixelsText
        resizeWidthText = preferencesState.resizeWidthText
        resizeHeightText = preferencesState.resizeHeightText
        keepsAspectRatio = preferencesState.keepsAspectRatio
        userPresetSettings = preferencesState.userPresetSettings
        lastUsedSettings = preferencesState.lastUsedSettings
        settingsSource = preferencesState.settingsSource
        exactResizeStrategy = preferencesState.exactResizeStrategy
        compression = preferencesState.compression
        namingTemplate = preferencesState.namingTemplate
        customNamingPrefixText = preferencesState.customNamingPrefixText
        numberingStyle = preferencesState.numberingStyle
    }

    func preferencesState(
        settingsSource oldSettingsSource: SettingsSource? = nil,
        exactResizeStrategy oldExactResizeStrategy: BatchExactResizeStrategy? = nil,
        compression oldCompression: BatchImageCompression? = nil
    ) -> BatchImagePreferencesState {
        .init(
            referenceDimension: referenceDimension,
            referencePixelsText: referencePixelsText,
            resizeWidthText: resizeWidthText,
            resizeHeightText: resizeHeightText,
            keepsAspectRatio: keepsAspectRatio,
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings,
            settingsSource: oldSettingsSource ?? settingsSource,
            exactResizeStrategy: oldExactResizeStrategy ?? exactResizeStrategy,
            compression: oldCompression ?? compression,
            namingTemplate: namingTemplate,
            customNamingPrefixText: customNamingPrefixText,
            numberingStyle: numberingStyle
        )
    }

    func mutatePreferencesState(
        _ transform: (inout BatchImagePreferencesState) -> Void
    ) {
        let oldState = currentPreferencesState
        var newState = oldState
        transform(&newState)

        applyUpdatedPreferencesState(
            oldState: oldState,
            newState: newState
        )
    }

    func hasEditableSettingsChanged(
        from oldState: BatchImagePreferencesState,
        to newState: BatchImagePreferencesState
    ) -> Bool {
        oldState.referenceDimension != newState.referenceDimension ||
            oldState.referencePixelsText != newState.referencePixelsText ||
            oldState.resizeWidthText != newState.resizeWidthText ||
            oldState.resizeHeightText != newState.resizeHeightText ||
            oldState.keepsAspectRatio != newState.keepsAspectRatio ||
            oldState.exactResizeStrategy != newState.exactResizeStrategy ||
            oldState.compression != newState.compression ||
            oldState.namingTemplate != newState.namingTemplate ||
            oldState.customNamingPrefixText != newState.customNamingPrefixText ||
            oldState.numberingStyle != newState.numberingStyle
    }

    func savePreferences(
        _ preferences: PersistedBatchImagePreferences
    ) {
        settingsStore.save(preferences)
    }

    func supportsLossyCompression(
        for image: ImportedBatchImage
    ) -> Bool {
        let outputFormat = BatchImageProcessingOperations.resolvedOutputFormat(
            for: image.originalFormat,
            heicEncoderAvailable: BatchImageProcessor.heicEncoderAvailable
        )

        return outputFormat.supportsLossyCompressionQuality
    }
}
