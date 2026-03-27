// swiftlint:disable file_length
import Foundation
import LietLibrary
import Observation
import PhotosUI
import SwiftUI

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
    private(set) var backgroundRemoval: BatchBackgroundRemovalSettings
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
        backgroundRemoval = preferencesState.backgroundRemoval
        namingTemplate = preferencesState.namingTemplate
        customNamingPrefixText = preferencesState.customNamingPrefixText
        numberingStyle = preferencesState.numberingStyle
    }
}

extension BatchImageHomeModel {
    var showsProcessingStep: Bool {
        !importedImages.isEmpty
    }

    var canProcess: Bool {
        settings != nil &&
            !importedImages.isEmpty &&
            !isImporting &&
            !isProcessing
    }

    var canSaveCurrentAsUserPreset: Bool {
        currentPreferencesState.canSaveCurrentAsUserPreset
    }

    var hasUserPresetSettings: Bool {
        currentPreferencesState.hasUserPresetSettings
    }

    var referencePixels: Int? {
        currentPreferencesState.referencePixels
    }

    var exactWidthPixels: Int? {
        currentPreferencesState.exactWidthPixels
    }

    var exactHeightPixels: Int? {
        currentPreferencesState.exactHeightPixels
    }

    var showsExactResizeStrategy: Bool {
        !keepsAspectRatio
    }

    var showsCompressionSection: Bool {
        backgroundRemoval.isEnabled ||
            importedImages.contains { image in
                supportsLossyCompression(for: image)
            }
    }

    var showsMixedCompressionHint: Bool {
        backgroundRemoval.isEnabled == false &&
            showsCompressionSection &&
            importedImages.contains { image in
                image.originalFormat == .png
            }
    }

    var settings: BatchImageSettings? {
        currentPreferencesState.settings
    }

    var showsCustomNamingPrefixField: Bool {
        namingTemplate == .custom
    }

    var hasValidNaming: Bool {
        BatchImageNaming(
            template: namingTemplate,
            customPrefix: customNamingPrefixText,
            numberingStyle: numberingStyle
        ).isValid
    }

    func setReferenceDimension(
        _ newValue: BatchResizeReferenceDimension
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setReferenceDimension(newValue)
        }
    }

    func setReferencePixelsText(
        _ newValue: String
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setReferencePixelsText(newValue)
        }
    }

    func setResizeWidthText(
        _ newValue: String
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setResizeWidthText(newValue)
        }
    }

    func setResizeHeightText(
        _ newValue: String
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setResizeHeightText(newValue)
        }
    }

    func setKeepsAspectRatio(
        _ newValue: Bool
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setKeepsAspectRatio(newValue)
        }
    }

    func setBackgroundRemovalEnabled(
        _ newValue: Bool
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setBackgroundRemovalEnabled(newValue)
        }
    }

    func setBackgroundRemovalStrength(
        _ newValue: Double
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setBackgroundRemovalStrength(newValue)
        }
    }

    func setBackgroundRemovalEdgeSmoothing(
        _ newValue: Double
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setBackgroundRemovalEdgeSmoothing(newValue)
        }
    }

    func setBackgroundRemovalEdgeExpansion(
        _ newValue: Double
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setBackgroundRemovalEdgeExpansion(newValue)
        }
    }

    func setNamingTemplate(
        _ newValue: BatchImageNamingTemplate
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setNamingTemplate(newValue)
        }
    }

    func setCustomNamingPrefixText(
        _ newValue: String
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setCustomNamingPrefixText(newValue)
        }
    }

    func setNumberingStyle(
        _ newValue: BatchImageNumberingStyle
    ) {
        mutatePreferencesState { preferencesState in
            preferencesState.setNamingNumberingStyle(newValue)
        }
    }

    func applyUserPresetSettings() {
        let oldState = currentPreferencesState
        var newState = oldState
        newState.applyUserPresetSettings()
        applyUpdatedPreferencesState(
            oldState: oldState,
            newState: newState
        )
    }

    func applyLastUsedSettings() {
        let oldState = currentPreferencesState
        var newState = oldState
        newState.applyLastUsedSettings()
        applyUpdatedPreferencesState(
            oldState: oldState,
            newState: newState
        )
    }

    func saveCurrentAsUserPreset() {
        let oldState = currentPreferencesState
        var newState = oldState
        newState.saveCurrentAsUserPreset()

        guard newState != oldState else {
            return
        }

        applyPreferencesState(newState)
        savePreferences(newState.preferences)
        BatchImageTipSupport.markUserPresetSaved()
    }

    func importPhotos(
        from items: [PhotosPickerItem]
    ) async {
        let sessionID = beginImportSession()

        guard !items.isEmpty else {
            importedImages = []
            return
        }

        isImporting = true
        let result = await PhotoImportService.importImages(from: items)
        applyImportResult(
            result,
            sessionID: sessionID
        )
    }

    func importFiles(
        from fileURLs: [URL]
    ) {
        guard !fileURLs.isEmpty else {
            return
        }

        let sessionID = beginImportSession()
        isImporting = true
        let result = PhotoImportService.importImages(
            from: fileURLs
        )
        applyImportResult(
            result,
            sessionID: sessionID
        )
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
        let preferencesState = currentPreferencesState

        guard let settings = preferencesState.settings,
              let currentPersistedSettings = preferencesState.currentPersistedSettings else {
            activeAlert = .invalidResizeSize
            return
        }

        var updatedPreferencesState = preferencesState
        updatedPreferencesState.persistLastUsedSettings(
            currentPersistedSettings
        )
        applyPreferencesState(updatedPreferencesState)
        savePreferences(updatedPreferencesState.preferences)
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
            backgroundRemoval: backgroundRemoval,
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
        backgroundRemoval = preferencesState.backgroundRemoval
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
            backgroundRemoval: backgroundRemoval,
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
            oldState.backgroundRemoval != newState.backgroundRemoval ||
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
        let outputFormat = BatchImageProcessingPlanner.resolvedOutputFormat(
            for: image.originalFormat,
            heicEncoderAvailable: BatchImageProcessor.heicEncoderAvailable
        )

        return outputFormat.supportsLossyCompressionQuality
    }
}
// swiftlint:enable file_length
