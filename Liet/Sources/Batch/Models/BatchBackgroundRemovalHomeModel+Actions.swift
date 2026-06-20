import Foundation
import LietLibrary
import PhotosUI
import SwiftUI

extension BatchBackgroundRemovalHomeModel {
    var showsProcessingStep: Bool {
        !importedImages.isEmpty
    }

    var canProcess: Bool {
        currentPreferencesState.currentPersistedSettings != nil &&
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

    var isActiveAlertPresented: Bool {
        get {
            activeAlert != nil
        }
        set {
            if !newValue {
                activeAlert = nil
            }
        }
    }

    var editableNamingTemplate: BatchImageNamingTemplate {
        get {
            namingTemplate
        }
        set {
            setNamingTemplate(newValue)
        }
    }

    var customNamingPrefixInputText: String {
        get {
            customNamingPrefixText
        }
        set {
            setCustomNamingPrefixText(newValue)
        }
    }

    var editableNumberingStyle: BatchImageNumberingStyle {
        get {
            numberingStyle
        }
        set {
            setNumberingStyle(newValue)
        }
    }

    var showsCustomNamingPrefixField: Bool {
        namingTemplate == .custom
    }

    var hasValidNaming: Bool {
        currentPreferencesState.naming != nil
    }

    var selectionSummaryText: Text? {
        guard !importedImages.isEmpty else {
            return nil
        }

        return Text("Original size • Transparent PNG")
    }

    func projectedPixelSize(
        for image: ImportedBatchImage
    ) -> CGSize? {
        image.pixelSize
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
        resetImportSession()
        isImporting = false
        importedImages = []
        activeAlert = nil
        importFailureCount = nil
        invalidateProcessedResults()
    }

    func invalidateProcessedResults() {
        resultModel = nil
    }

    func processImages() async {
        let preferencesState = currentPreferencesState

        guard let currentPersistedSettings = preferencesState.currentPersistedSettings,
              let naming = preferencesState.naming else {
            activeAlert = .invalidConfiguration
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
        await Task.yield()
        let outcome = BatchBackgroundRemovalProcessor.process(
            images: importedImages,
            settings: preferencesState.settings,
            naming: naming
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
