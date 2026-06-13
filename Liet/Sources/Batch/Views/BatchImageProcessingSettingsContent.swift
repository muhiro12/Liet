import LietLibrary
import SwiftUI
import TipKit

struct BatchImageProcessingSettingsContent: View {
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
        BatchSettingsSection(title: "Starting Point") {
            BatchSettingsSourcePickerView(
                selection: $settingsSource,
                hasUserPresetSettings: hasUserPresetSettings,
                processingSetupTip: processingSetupTip
            )
        }

        BatchSettingsSection(title: "Output Size") {
            BatchResizeOutputSizeView(
                keepsAspectRatio: $keepsAspectRatio,
                referenceDimension: $referenceDimension,
                referencePixels: $referencePixels,
                resizeWidth: $resizeWidth,
                resizeHeight: $resizeHeight,
                exactResizeStrategy: $exactResizeStrategy,
                resizeMethodTip: resizeMethodTip
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

        if showsCompressionSection {
            BatchSettingsSection(title: "Compression") {
                BatchCompressionPickerView(
                    compression: $compression,
                    showsMixedCompressionHint: showsMixedCompressionHint
                )
            }
            .transition(optionalProcessingSectionTransition)
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

private extension BatchImageProcessingSettingsContent {
    var optionalProcessingSectionTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: BatchDesign.Animation.sectionTransitionScale,
                anchor: .top
            )
        )
    }
}
