// swiftlint:disable file_length
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

    enum SettingsSource: String, CaseIterable {
        case lastUsed
        case userPreset
        case custom
    }

    var importedImages: [ImportedBatchImage] = []
    private(set) var referenceDimension: BatchResizeReferenceDimension
    private(set) var referencePixelsText: String
    private(set) var resizeWidthText: String
    private(set) var resizeHeightText: String
    private(set) var keepsAspectRatio: Bool
    private(set) var userPresetSettings: PersistedBatchImageSettings?
    private(set) var lastUsedSettings: PersistedBatchImageSettings
    var settingsSource: SettingsSource = .lastUsed {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               settingsSource != oldValue {
                didSelectSettingsSource()
            }
        }
    }
    var exactResizeStrategy: BatchExactResizeStrategy = .stretch {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               exactResizeStrategy != oldValue {
                didChangeSettings()
            }
        }
    }
    var compression: BatchImageCompression = .off {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               compression != oldValue {
                didChangeSettings()
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
        let persistedPreferences = settingsStore.load() ?? .default
        let initialSettings = persistedPreferences.lastUsedSettings
        referenceDimension = initialSettings.referenceDimension
        referencePixelsText = "\(initialSettings.referencePixels)"
        resizeWidthText = "\(initialSettings.exactWidthPixels)"
        resizeHeightText = "\(initialSettings.exactHeightPixels)"
        keepsAspectRatio = initialSettings.resizeMode == .aspectRatioPreserved
        userPresetSettings = persistedPreferences.userPresetSettings
        lastUsedSettings = persistedPreferences.lastUsedSettings
        exactResizeStrategy = initialSettings.exactResizeStrategy
        compression = initialSettings.compression
        settingsSource = .lastUsed
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
        guard let currentPersistedSettings else {
            return false
        }

        return currentPersistedSettings != userPresetSettings
    }

    var hasUserPresetSettings: Bool {
        userPresetSettings != nil
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
        didChangeSettings()
    }

    func setReferencePixelsText(
        _ newValue: String
    ) {
        referencePixelsText = newValue
        didChangeSettings()
    }

    func setResizeWidthText(
        _ newValue: String
    ) {
        resizeWidthText = newValue
        didChangeSettings()
    }

    func setResizeHeightText(
        _ newValue: String
    ) {
        resizeHeightText = newValue
        didChangeSettings()
    }

    func setKeepsAspectRatio(
        _ newValue: Bool
    ) {
        guard keepsAspectRatio != newValue else {
            return
        }

        keepsAspectRatio = newValue
        didChangeSettings()
    }

    func applyUserPresetSettings() {
        guard hasUserPresetSettings else {
            return
        }

        settingsSource = .userPreset
    }

    func applyLastUsedSettings() {
        settingsSource = .lastUsed
    }

    func saveCurrentAsUserPreset() {
        guard let currentPersistedSettings else {
            return
        }

        userPresetSettings = currentPersistedSettings
        setSettingsSourceWithoutApplying(.userPreset)
        savePreferences()
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
        guard let settings,
              let currentPersistedSettings else {
            activeAlert = .invalidResizeSize
            return
        }

        persistLastUsedSettings(currentPersistedSettings)
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
    var currentPersistedSettings: PersistedBatchImageSettings? {
        let persistedResizeMode: PersistedBatchResizeMode = keepsAspectRatio
            ? .aspectRatioPreserved
            : .exactSize
        let storedReferencePixels: Int

        if keepsAspectRatio {
            guard let referencePixels else {
                return nil
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
                return nil
            }

            storedExactWidthPixels = exactWidthPixels
            storedExactHeightPixels = exactHeightPixels
        }

        return .init(
            resizeMode: persistedResizeMode,
            referenceDimension: referenceDimension,
            referencePixels: storedReferencePixels,
            exactWidthPixels: storedExactWidthPixels,
            exactHeightPixels: storedExactHeightPixels,
            exactResizeStrategy: exactResizeStrategy,
            compression: compression
        )
    }

    func didChangeSettings() {
        invalidateProcessedResults()
        setSettingsSourceWithoutApplying(.custom)
    }

    func didSelectSettingsSource() {
        switch settingsSource {
        case .lastUsed:
            replaceCurrentSettings(with: lastUsedSettings)
        case .userPreset:
            guard let userPresetSettings else {
                setSettingsSourceWithoutApplying(.lastUsed)
                return
            }

            replaceCurrentSettings(with: userPresetSettings)
        case .custom:
            break
        }
    }

    func persistLastUsedSettings(
        _ settings: PersistedBatchImageSettings
    ) {
        lastUsedSettings = settings
        if settingsSource == .custom {
            setSettingsSourceWithoutApplying(.lastUsed)
        }
        savePreferences()
    }

    func setSettingsSourceWithoutApplying(
        _ newValue: SettingsSource
    ) {
        guard settingsSource != newValue else {
            return
        }

        suppressesAutomaticSettingsDidChange = true
        settingsSource = newValue
        suppressesAutomaticSettingsDidChange = false
    }

    func replaceCurrentSettings(
        with settings: PersistedBatchImageSettings
    ) {
        suppressesAutomaticSettingsDidChange = true
        defer {
            suppressesAutomaticSettingsDidChange = false
        }

        referenceDimension = settings.referenceDimension
        referencePixelsText = "\(settings.referencePixels)"
        resizeWidthText = "\(settings.exactWidthPixels)"
        resizeHeightText = "\(settings.exactHeightPixels)"
        keepsAspectRatio = settings.resizeMode == .aspectRatioPreserved
        exactResizeStrategy = settings.exactResizeStrategy
        compression = settings.compression

        invalidateProcessedResults()
    }

    func savePreferences() {
        settingsStore.save(
            .init(
                userPresetSettings: userPresetSettings,
                lastUsedSettings: lastUsedSettings
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
// swiftlint:enable file_length
