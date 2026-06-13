// swiftlint:disable type_contents_order
import LietLibrary
import MHDesign
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageHomeView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    let reviewSelection: (() -> Void)?
    let backToChooser: (() -> Void)?

    @State private var isPresentingFileImporter = false
    @State private var suppressesSelectedItemsDidChange = false

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()
    private let resizeMethodTip = ResizeMethodTip()
    private let userPresetTip = UserPresetTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            importStepSection()

            if model.showsProcessingStep {
                processingStepSection()
                    .transition(processingStepTransition)
                processStepSection()
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
        .navigationTitle("Resize Images")
        .navigationBarTitleDisplayMode(.large)
        .animation(
            processingAnimation,
            value: model.importedImages.count
        )
        .animation(
            processingAnimation,
            value: model.keepsAspectRatio
        )
        .animation(
            processingAnimation,
            value: model.showsCompressionSection
        )
        .toolbar {
            BatchHomeToolbar(backToChooser: backToChooser) {
                model.replayTips()
            }
        }
        .onChange(of: selectedItems) { _, newValue in
            if suppressesSelectedItemsDidChange {
                suppressesSelectedItemsDidChange = false
                return
            }

            Task {
                await model.importPhotos(from: newValue)
            }
        }
        .fileImporter(
            isPresented: $isPresentingFileImporter,
            allowedContentTypes: PhotoImportService.supportedImportContentTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileImportResult(result)
        } onCancellation: {
            // Keep the current selection unchanged when the picker is dismissed.
        }
        .alert("Error", isPresented: errorPresented) {
            Button("OK", role: .cancel) {
                model.activeAlert = nil
            }
        } message: {
            if let activeAlert = model.activeAlert {
                alertText(for: activeAlert)
            }
        }
    }
}

private extension BatchImageHomeView {
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

    var settingsSourceBinding: Binding<BatchImageHomeModel.SettingsSource> {
        Binding(
            get: {
                model.settingsSource
            },
            set: { newValue in
                model.settingsSource = newValue
            }
        )
    }

    func importStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.import,
            title: "Import"
        ) {
            BatchImageImportControlsView(
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
        }
    }

    func processingStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.processing,
            title: "Processing Settings"
        ) {
            settingsSourceSection()
            outputSizeSection()
            fileNamingSection()

            if model.showsCompressionSection {
                compressionSection()
                    .transition(optionalProcessingSectionTransition)
            }

            userPresetSection()
        }
    }

    func processStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.process,
            title: "Process"
        ) {
            BatchProcessButtonView(
                isProcessing: model.isProcessing,
                canProcess: model.canProcess,
                runProcessingTip: runProcessingTip
            ) {
                Task {
                    model.processImages()
                }
            }
        }
    }

    func outputSizeSection() -> some View {
        BatchSettingsSection(title: "Output Size") {
            BatchResizeOutputSizeView(
                keepsAspectRatio: keepsAspectRatioBinding,
                referenceDimension: referenceDimensionBinding,
                referencePixels: referencePixelsBinding,
                resizeWidth: resizeWidthBinding,
                resizeHeight: resizeHeightBinding,
                exactResizeStrategy: $model.exactResizeStrategy,
                resizeMethodTip: resizeMethodTip
            )
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

    func compressionSection() -> some View {
        BatchSettingsSection(title: "Compression") {
            BatchCompressionPickerView(
                compression: $model.compression,
                showsMixedCompressionHint: model.showsMixedCompressionHint
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

    func handleFileImportResult(
        _ result: Result<[URL], any Error>
    ) {
        switch result {
        case let .success(fileURLs):
            guard !fileURLs.isEmpty else {
                return
            }

            if !selectedItems.isEmpty {
                suppressesSelectedItemsDidChange = true
                selectedItems = []
            }

            Task {
                model.importFiles(from: fileURLs)
            }
        case .failure:
            model.importFailureCount = nil
            model.activeAlert = .importSelectionFailed
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

    var optionalProcessingSectionTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: BatchDesign.Animation.sectionTransitionScale,
                anchor: .top
            )
        )
    }
}
// swiftlint:enable type_contents_order
