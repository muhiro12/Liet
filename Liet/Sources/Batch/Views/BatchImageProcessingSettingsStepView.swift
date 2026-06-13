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
            settingsSource: settingsSourceBinding,
            keepsAspectRatio: keepsAspectRatioBinding,
            referenceDimension: referenceDimensionBinding,
            referencePixels: referencePixelsBinding,
            resizeWidth: resizeWidthBinding,
            resizeHeight: resizeHeightBinding,
            exactResizeStrategy: $model.exactResizeStrategy,
            namingTemplate: namingTemplateBinding,
            customNamingPrefix: customNamingPrefixBinding,
            numberingStyle: numberingStyleBinding,
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
    var resizeWidthBinding: Binding<String> {
        Binding(
            get: {
                model.resizeWidthText
            },
            set: { newValue in
                model.setResizeWidthText(newValue)
            }
        )
    }

    var resizeHeightBinding: Binding<String> {
        Binding(
            get: {
                model.resizeHeightText
            },
            set: { newValue in
                model.setResizeHeightText(newValue)
            }
        )
    }

    var referencePixelsBinding: Binding<String> {
        Binding(
            get: {
                model.referencePixelsText
            },
            set: { newValue in
                model.setReferencePixelsText(newValue)
            }
        )
    }

    var referenceDimensionBinding: Binding<BatchResizeReferenceDimension> {
        Binding(
            get: {
                model.referenceDimension
            },
            set: { newValue in
                model.setReferenceDimension(newValue)
            }
        )
    }

    var keepsAspectRatioBinding: Binding<Bool> {
        Binding(
            get: {
                model.keepsAspectRatio
            },
            set: { newValue in
                model.setKeepsAspectRatio(newValue)
            }
        )
    }

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
