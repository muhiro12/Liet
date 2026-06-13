import LietLibrary
import SwiftUI
import TipKit

struct BatchBackgroundRemovalSettingsStepView: View {
    @Bindable var model: BatchBackgroundRemovalHomeModel
    let processingSetupTip: ProcessingSetupTip
    let userPresetTip: UserPresetTip

    var body: some View {
        BatchBackgroundRemovalSettingsStep(
            settingsSource: $model.settingsSource,
            namingTemplate: $model.editableNamingTemplate,
            customNamingPrefix: $model.customNamingPrefixInputText,
            numberingStyle: $model.editableNumberingStyle,
            strength: $model.strength,
            edgeSmoothing: $model.edgeSmoothing,
            edgeExpansion: $model.edgeExpansion,
            hasUserPresetSettings: model.hasUserPresetSettings,
            showsCustomNamingPrefixField: model.showsCustomNamingPrefixField,
            hasValidNaming: model.hasValidNaming,
            canSavePreset: model.canSaveCurrentAsUserPreset,
            processingSetupTip: processingSetupTip,
            userPresetTip: userPresetTip,
            savePreset: savePreset
        )
    }
}

private extension BatchBackgroundRemovalSettingsStepView {
    func savePreset() {
        model.saveCurrentAsUserPreset()
    }
}
