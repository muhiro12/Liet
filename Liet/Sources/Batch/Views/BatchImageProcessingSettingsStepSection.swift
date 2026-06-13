import LietLibrary
import SwiftUI
import TipKit

struct BatchImageProcessingSettingsStepSection: View {
    @Binding var settingsSource: BatchImageSettingsSource
    @Binding var keepsAspectRatio: Bool
    @Binding var referenceDimension: BatchResizeReferenceDimension
    @Binding var referencePixels: String
    @Binding var resizeWidth: String
    @Binding var resizeHeight: String
    @Binding var exactResizeStrategy: BatchExactResizeStrategy
    @Binding var namingTemplate: BatchImageNamingTemplate
    @Binding var customNamingPrefix: String
    @Binding var numberingStyle: BatchImageNumberingStyle
    @Binding var compression: BatchImageCompression

    let hasUserPresetSettings: Bool
    let showsCustomNamingPrefixField: Bool
    let hasValidNaming: Bool
    let showsCompressionSection: Bool
    let showsMixedCompressionHint: Bool
    let canSavePreset: Bool
    let processingSetupTip: ProcessingSetupTip
    let resizeMethodTip: ResizeMethodTip
    let userPresetTip: UserPresetTip
    let savePreset: () -> Void

    var body: some View {
        BatchStepSection(
            number: BatchDesign.Step.processing,
            title: "Processing Settings"
        ) {
            BatchImageProcessingSettingsContent(
                settingsSource: $settingsSource,
                keepsAspectRatio: $keepsAspectRatio,
                referenceDimension: $referenceDimension,
                referencePixels: $referencePixels,
                resizeWidth: $resizeWidth,
                resizeHeight: $resizeHeight,
                exactResizeStrategy: $exactResizeStrategy,
                namingTemplate: $namingTemplate,
                customNamingPrefix: $customNamingPrefix,
                numberingStyle: $numberingStyle,
                compression: $compression,
                hasUserPresetSettings: hasUserPresetSettings,
                showsCustomNamingPrefixField: showsCustomNamingPrefixField,
                hasValidNaming: hasValidNaming,
                showsCompressionSection: showsCompressionSection,
                showsMixedCompressionHint: showsMixedCompressionHint,
                canSavePreset: canSavePreset,
                processingSetupTip: processingSetupTip,
                resizeMethodTip: resizeMethodTip,
                userPresetTip: userPresetTip,
                savePreset: savePreset
            )
        }
    }
}
