import LietLibrary
import SwiftUI
import TipKit

struct BatchBackgroundRemovalSettingsStep: View {
    @Binding var settingsSource: BatchImageSettingsSource
    @Binding var namingTemplate: BatchImageNamingTemplate
    @Binding var customNamingPrefix: String
    @Binding var numberingStyle: BatchImageNumberingStyle
    @Binding var strength: Double
    @Binding var edgeSmoothing: Double
    @Binding var edgeExpansion: Double

    let hasUserPresetSettings: Bool
    let showsCustomNamingPrefixField: Bool
    let hasValidNaming: Bool
    let canSavePreset: Bool
    let processingSetupTip: ProcessingSetupTip
    let userPresetTip: UserPresetTip
    let savePreset: () -> Void

    var body: some View {
        BatchStepSection(
            number: BatchDesign.Step.processing,
            title: "Processing Settings"
        ) {
            BatchBackgroundRemovalSettingsContent(
                settingsSource: $settingsSource,
                namingTemplate: $namingTemplate,
                customNamingPrefix: $customNamingPrefix,
                numberingStyle: $numberingStyle,
                strength: $strength,
                edgeSmoothing: $edgeSmoothing,
                edgeExpansion: $edgeExpansion,
                hasUserPresetSettings: hasUserPresetSettings,
                showsCustomNamingPrefixField: showsCustomNamingPrefixField,
                hasValidNaming: hasValidNaming,
                canSavePreset: canSavePreset,
                processingSetupTip: processingSetupTip,
                userPresetTip: userPresetTip,
                savePreset: savePreset
            )
        }
    }
}
