import LietLibrary
import SwiftUI
import TipKit

struct BatchImageProcessingSettingsStepView: View {
    @Bindable var model: BatchImageHomeModel
    let processingSetupTip: ProcessingSetupTip
    let resizeMethodTip: ResizeMethodTip
    let userPresetTip: UserPresetTip

    var body: some View {
        BatchImageProcessingSettingsStepSection(
            settingsSource: $model.settingsSource,
            keepsAspectRatio: $model.editableKeepsAspectRatio,
            referenceDimension: $model.editableReferenceDimension,
            referencePixels: $model.referencePixelsInputText,
            resizeWidth: $model.resizeWidthInputText,
            resizeHeight: $model.resizeHeightInputText,
            exactResizeStrategy: $model.exactResizeStrategy,
            namingTemplate: $model.editableNamingTemplate,
            customNamingPrefix: $model.customNamingPrefixInputText,
            numberingStyle: $model.editableNumberingStyle,
            compression: $model.compression,
            hasUserPresetSettings: model.hasUserPresetSettings,
            showsCustomNamingPrefixField: model.showsCustomNamingPrefixField,
            hasValidNaming: model.hasValidNaming,
            showsCompressionSection: model.showsCompressionSection,
            showsMixedCompressionHint: model.showsMixedCompressionHint,
            canSavePreset: model.canSaveCurrentAsUserPreset,
            processingSetupTip: processingSetupTip,
            resizeMethodTip: resizeMethodTip,
            userPresetTip: userPresetTip,
            savePreset: savePreset
        )
    }
}

private extension BatchImageProcessingSettingsStepView {
    func savePreset() {
        model.saveCurrentAsUserPreset()
    }
}
