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
                BatchImageProcessingStepsView(
                    model: model,
                    processingSetupTip: processingSetupTip,
                    runProcessingTip: runProcessingTip,
                    resizeMethodTip: resizeMethodTip,
                    userPresetTip: userPresetTip
                )
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
        .modifier(importInteractionModifier)
    }
}

private extension BatchImageHomeView {
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
