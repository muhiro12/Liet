import LietLibrary
import SwiftUI
import TipKit

struct BatchBackgroundRemovalSettingsContent: View {
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
        BatchSettingsSection(title: "Starting Point") {
            BatchSettingsSourcePickerView(
                selection: $settingsSource,
                hasUserPresetSettings: hasUserPresetSettings,
                processingSetupTip: processingSetupTip
            )
        }

        BatchSettingsSection(title: "File Naming") {
            BatchFileNamingSectionView(
                namingTemplate: $namingTemplate,
                customNamingPrefix: $customNamingPrefix,
                numberingStyle: $numberingStyle,
                showsCustomNamingPrefixField: showsCustomNamingPrefixField,
                hasValidNaming: hasValidNaming
            )
        }

        BatchSettingsSection(title: "Background Removal") {
            BatchBackgroundRemovalSettingsView(
                strength: $strength,
                edgeSmoothing: $edgeSmoothing,
                edgeExpansion: $edgeExpansion
            )
        }

        BatchSettingsSection(title: "User Preset") {
            BatchUserPresetButtonView(
                canSavePreset: canSavePreset,
                userPresetTip: userPresetTip,
                savePreset: savePreset
            )
        }
    }
}
