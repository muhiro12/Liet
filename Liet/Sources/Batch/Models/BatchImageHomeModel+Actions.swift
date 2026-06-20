import Foundation
import LietLibrary
import PhotosUI
import SwiftUI

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

    var referencePixels: Int? {
        currentPreferencesState.referencePixels
    }

    var exactWidthPixels: Int? {
        currentPreferencesState.exactWidthPixels
    }

    var exactHeightPixels: Int? {
        currentPreferencesState.exactHeightPixels
    }

    var editableReferenceDimension: BatchResizeReferenceDimension {
        get {
            referenceDimension
        }
        set {
            setReferenceDimension(newValue)
        }
    }

    var referencePixelsInputText: String {
        get {
            referencePixelsText
        }
        set {
            setReferencePixelsText(newValue)
        }
    }

    var resizeWidthInputText: String {
        get {
            resizeWidthText
        }
        set {
            setResizeWidthText(newValue)
        }
    }

    var resizeHeightInputText: String {
        get {
            resizeHeightText
        }
        set {
            setResizeHeightText(newValue)
        }
    }

    var editableKeepsAspectRatio: Bool {
        get {
            keepsAspectRatio
        }
        set {
            setKeepsAspectRatio(newValue)
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

    var selectionSummaryText: Text? {
        guard let settings else {
            return nil
        }

        if let referenceDimension = settings.referenceDimension,
           let referencePixels = settings.referencePixels {
            return switch referenceDimension {
            case .width:
                Text("Width \(referencePixels) px • Keep ratio")
            case .height:
                Text("Height \(referencePixels) px • Keep ratio")
            }
        }

        guard let exactWidthPixels = settings.exactWidthPixels,
              let exactHeightPixels = settings.exactHeightPixels,
              let exactResizeStrategy = settings.exactResizeStrategy else {
            return nil
        }

        return switch exactResizeStrategy {
        case .stretch:
            Text("\(exactWidthPixels)×\(exactHeightPixels) • Stretch")
        case .contain:
            Text("\(exactWidthPixels)×\(exactHeightPixels) • Contain")
        case .coverCrop:
            Text("\(exactWidthPixels)×\(exactHeightPixels) • Crop")
        }
    }

    func projectedPixelSize(
        for image: ImportedBatchImage
    ) -> CGSize? {
        guard let settings else {
            return nil
        }

        return BatchImageProcessor.projectedPixelSize(
            for: image,
            settings: settings
        )
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
        await Task.yield()
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
