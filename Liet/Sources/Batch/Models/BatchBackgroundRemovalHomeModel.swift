import Foundation
import LietLibrary
import Observation

@MainActor
@Observable
final class BatchBackgroundRemovalHomeModel {
    typealias SettingsSource = BatchImageSettingsSource

    enum AlertState: Equatable {
        case invalidConfiguration
        case importSelectionFailed
        case processSelectionFailed
    }

    var importedImages: [ImportedBatchImage] = []
    private(set) var userPresetSettings: PersistedBatchBackgroundRemovalSettings?
    private(set) var lastUsedSettings: PersistedBatchBackgroundRemovalSettings
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
    var strength: Double = BatchBackgroundRemovalSettings.default.strength {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               strength != oldValue {
                let oldState = preferencesState(
                    strength: oldValue
                )
                var newState = oldState
                newState.setStrength(strength)
                applyUpdatedPreferencesState(
                    oldState: oldState,
                    newState: newState
                )
            }
        }
    }
    var edgeSmoothing: Double = BatchBackgroundRemovalSettings.default.edgeSmoothing {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               edgeSmoothing != oldValue {
                let oldState = preferencesState(
                    edgeSmoothing: oldValue
                )
                var newState = oldState
                newState.setEdgeSmoothing(edgeSmoothing)
                applyUpdatedPreferencesState(
                    oldState: oldState,
                    newState: newState
                )
            }
        }
    }
    var edgeExpansion: Double = BatchBackgroundRemovalSettings.default.edgeExpansion {
        didSet {
            if !suppressesAutomaticSettingsDidChange,
               edgeExpansion != oldValue {
                let oldState = preferencesState(
                    edgeExpansion: oldValue
                )
                var newState = oldState
                newState.setEdgeExpansion(edgeExpansion)
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

    private let settingsStore: BatchBackgroundRemovalSettingsStore
    private var importSessionID: UUID = .init()
    private var suppressesAutomaticSettingsDidChange = false

    init(
        settingsStore: BatchBackgroundRemovalSettingsStore = .live()
    ) {
        self.settingsStore = settingsStore
        let preferencesState = BatchBackgroundRemovalPreferencesState(
            preferences: settingsStore.load() ?? .default
        )
        userPresetSettings = preferencesState.userPresetSettings
        lastUsedSettings = preferencesState.lastUsedSettings
        settingsSource = preferencesState.settingsSource
        strength = preferencesState.strength
        edgeSmoothing = preferencesState.edgeSmoothing
        edgeExpansion = preferencesState.edgeExpansion
        namingTemplate = preferencesState.namingTemplate
        customNamingPrefixText = preferencesState.customNamingPrefixText
        numberingStyle = preferencesState.numberingStyle
    }
}

extension BatchBackgroundRemovalHomeModel {
    var currentPreferencesState: BatchBackgroundRemovalPreferencesState {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings,
            settingsSource: settingsSource,
            strength: strength,
            edgeSmoothing: edgeSmoothing,
            edgeExpansion: edgeExpansion,
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
        oldState: BatchBackgroundRemovalPreferencesState,
        newState: BatchBackgroundRemovalPreferencesState
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
        _ preferencesState: BatchBackgroundRemovalPreferencesState
    ) {
        suppressesAutomaticSettingsDidChange = true
        defer {
            suppressesAutomaticSettingsDidChange = false
        }

        userPresetSettings = preferencesState.userPresetSettings
        lastUsedSettings = preferencesState.lastUsedSettings
        settingsSource = preferencesState.settingsSource
        strength = preferencesState.strength
        edgeSmoothing = preferencesState.edgeSmoothing
        edgeExpansion = preferencesState.edgeExpansion
        namingTemplate = preferencesState.namingTemplate
        customNamingPrefixText = preferencesState.customNamingPrefixText
        numberingStyle = preferencesState.numberingStyle
    }

    func preferencesState(
        settingsSource oldSettingsSource: SettingsSource? = nil,
        strength oldStrength: Double? = nil,
        edgeSmoothing oldEdgeSmoothing: Double? = nil,
        edgeExpansion oldEdgeExpansion: Double? = nil
    ) -> BatchBackgroundRemovalPreferencesState {
        .init(
            userPresetSettings: userPresetSettings,
            lastUsedSettings: lastUsedSettings,
            settingsSource: oldSettingsSource ?? settingsSource,
            strength: oldStrength ?? strength,
            edgeSmoothing: oldEdgeSmoothing ?? edgeSmoothing,
            edgeExpansion: oldEdgeExpansion ?? edgeExpansion,
            namingTemplate: namingTemplate,
            customNamingPrefixText: customNamingPrefixText,
            numberingStyle: numberingStyle
        )
    }

    func mutatePreferencesState(
        _ transform: (inout BatchBackgroundRemovalPreferencesState) -> Void
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
        from oldState: BatchBackgroundRemovalPreferencesState,
        to newState: BatchBackgroundRemovalPreferencesState
    ) -> Bool {
        oldState.strength != newState.strength ||
            oldState.edgeSmoothing != newState.edgeSmoothing ||
            oldState.edgeExpansion != newState.edgeExpansion ||
            oldState.namingTemplate != newState.namingTemplate ||
            oldState.customNamingPrefixText != newState.customNamingPrefixText ||
            oldState.numberingStyle != newState.numberingStyle
    }

    func savePreferences(
        _ preferences: BatchBackgroundRemovalPreferences
    ) {
        settingsStore.save(preferences)
    }
}
