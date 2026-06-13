import LietLibrary
import SwiftUI
import TipKit

struct BatchBackgroundRemovalSettingsStepView: View {
    @Bindable var model: BatchBackgroundRemovalHomeModel
    let processingSetupTip: ProcessingSetupTip
    let userPresetTip: UserPresetTip

    var body: some View {
        BatchBackgroundRemovalSettingsStep(
            settingsSource: settingsSourceBinding,
            namingTemplate: namingTemplateBinding,
            customNamingPrefix: customNamingPrefixBinding,
            numberingStyle: numberingStyleBinding,
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
    var namingTemplateBinding: Binding<BatchImageNamingTemplate> {
        Binding(
            get: {
                model.namingTemplate
            },
            set: { newValue in
                model.setNamingTemplate(newValue)
            }
        )
    }

    var customNamingPrefixBinding: Binding<String> {
        Binding(
            get: {
                model.customNamingPrefixText
            },
            set: { newValue in
                model.setCustomNamingPrefixText(newValue)
            }
        )
    }

    var numberingStyleBinding: Binding<BatchImageNumberingStyle> {
        Binding(
            get: {
                model.numberingStyle
            },
            set: { newValue in
                model.setNumberingStyle(newValue)
            }
        )
    }

    var settingsSourceBinding: Binding<BatchImageSettingsSource> {
        Binding(
            get: {
                model.settingsSource
            },
            set: { newValue in
                model.settingsSource = newValue
            }
        )
    }

    func savePreset() {
        model.saveCurrentAsUserPreset()
    }
}
