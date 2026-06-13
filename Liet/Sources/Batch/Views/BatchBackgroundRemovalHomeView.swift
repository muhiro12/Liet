// swiftlint:disable type_contents_order
import LietLibrary
import MHDesign
import PhotosUI
import SwiftUI
import TipKit

struct BatchBackgroundRemovalHomeView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchBackgroundRemovalHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    let reviewSelection: (() -> Void)?
    let backToChooser: (() -> Void)?

    @State private var isPresentingFileImporter = false
    @State private var suppressesSelectedItemsDidChange = false

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()
    private let userPresetTip = UserPresetTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            BatchImageImportStepSection(
                selectedItems: $selectedItems,
                isPresentingFileImporter: $isPresentingFileImporter,
                isImporting: model.isImporting,
                importedImageCount: model.importedImages.count,
                importFailureCount: model.importFailureCount,
                reviewSelection: reviewSelection,
                clearSelection: {
                    model.clearSelection()
                },
                selectImagesTip: selectImagesTip
            )

            if model.showsProcessingStep {
                processingStepSection()
                    .transition(processingStepTransition)
                BatchImageProcessStepSection(
                    isProcessing: model.isProcessing,
                    canProcess: model.canProcess,
                    runProcessingTip: runProcessingTip
                ) {
                    Task {
                        model.processImages()
                    }
                }
                .transition(processingStepTransition)
                AdvertisementSection(.small)
                    .transition(processingStepTransition)
            }
        }
        .batchScreen(
            title: nil as Text?,
            subtitle: nil as Text?
        )
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Remove Background")
        .navigationBarTitleDisplayMode(.large)
        .animation(
            processingAnimation,
            value: model.importedImages.count
        )
        .toolbar {
            BatchHomeToolbar(backToChooser: backToChooser) {
                model.replayTips()
            }
        }
        .modifier(importInteractionModifier)
    }
}

private extension BatchBackgroundRemovalHomeView {
    var importInteractionModifier: BatchImageImportInteractionModifier {
        BatchImageImportInteractionModifier(
            selectedItems: $selectedItems,
            isPresentingFileImporter: $isPresentingFileImporter,
            suppressesSelectedItemsDidChange: $suppressesSelectedItemsDidChange,
            errorPresented: errorPresented,
            alertMessage: {
                guard let activeAlert = model.activeAlert else {
                    return nil
                }

                return alertText(for: activeAlert)
            },
            dismissAlert: {
                model.activeAlert = nil
            },
            importPhotos: { items in
                await model.importPhotos(from: items)
            },
            importFiles: { fileURLs in
                model.importFiles(from: fileURLs)
            },
            handleImportFailure: {
                model.importFailureCount = nil
                model.activeAlert = .importSelectionFailed
            }
        )
    }

    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.activeAlert != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.activeAlert = nil
                }
            }
        )
    }

    var strengthBinding: Binding<Double> {
        Binding(
            get: {
                model.strength
            },
            set: { newValue in
                model.strength = newValue
            }
        )
    }

    var edgeSmoothingBinding: Binding<Double> {
        Binding(
            get: {
                model.edgeSmoothing
            },
            set: { newValue in
                model.edgeSmoothing = newValue
            }
        )
    }

    var edgeExpansionBinding: Binding<Double> {
        Binding(
            get: {
                model.edgeExpansion
            },
            set: { newValue in
                model.edgeExpansion = newValue
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

    var settingsSourceBinding: Binding<BatchBackgroundRemovalHomeModel.SettingsSource> {
        Binding(
            get: {
                model.settingsSource
            },
            set: { newValue in
                model.settingsSource = newValue
            }
        )
    }

    func processingStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.processing,
            title: "Processing Settings"
        ) {
            settingsSourceSection()
            fileNamingSection()
            backgroundRemovalSection()
            userPresetSection()
        }
    }

    func settingsSourceSection() -> some View {
        BatchSettingsSection(title: "Starting Point") {
            BatchSettingsSourcePickerView(
                selection: settingsSourceBinding,
                hasUserPresetSettings: model.hasUserPresetSettings,
                processingSetupTip: processingSetupTip
            )
        }
    }

    func fileNamingSection() -> some View {
        BatchSettingsSection(title: "File Naming") {
            BatchFileNamingSectionView(
                namingTemplate: namingTemplateBinding,
                customNamingPrefix: customNamingPrefixBinding,
                numberingStyle: numberingStyleBinding,
                showsCustomNamingPrefixField: model.showsCustomNamingPrefixField,
                hasValidNaming: model.hasValidNaming
            )
        }
    }

    func backgroundRemovalSection() -> some View {
        BatchSettingsSection(title: "Background Removal") {
            BatchBackgroundRemovalSettingsView(
                strength: strengthBinding,
                edgeSmoothing: edgeSmoothingBinding,
                edgeExpansion: edgeExpansionBinding
            )
        }
    }

    func userPresetSection() -> some View {
        BatchSettingsSection(title: "User Preset") {
            BatchUserPresetButtonView(
                canSavePreset: model.canSaveCurrentAsUserPreset,
                userPresetTip: userPresetTip
            ) {
                model.saveCurrentAsUserPreset()
            }
        }
    }

    var processingAnimation: Animation {
        .spring(
            response: BatchDesign.Animation.processingSpringResponse,
            dampingFraction: BatchDesign.Animation.processingSpringDampingFraction,
            blendDuration: BatchDesign.Animation.processingSpringBlendDuration
        )
    }

    var processingStepTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: BatchDesign.Animation.sectionTransitionScale,
                anchor: .top
            )
        )
    }
}
// swiftlint:enable type_contents_order
