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
                BatchBackgroundRemovalStepsView(
                    model: model,
                    processingSetupTip: processingSetupTip,
                    runProcessingTip: runProcessingTip,
                    userPresetTip: userPresetTip
                )
                .transition(BatchProcessingAnimation.sectionRevealTransition)
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
            BatchProcessingAnimation.stepReveal,
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
}
