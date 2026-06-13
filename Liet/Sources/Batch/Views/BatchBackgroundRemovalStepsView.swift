import LietLibrary
import MHDesign
import SwiftUI
import TipKit

struct BatchBackgroundRemovalStepsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchBackgroundRemovalHomeModel
    let processingSetupTip: ProcessingSetupTip
    let runProcessingTip: RunProcessingTip
    let userPresetTip: UserPresetTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            BatchBackgroundRemovalSettingsStepView(
                model: model,
                processingSetupTip: processingSetupTip,
                userPresetTip: userPresetTip
            )

            BatchImageProcessStepSection(
                isProcessing: model.isProcessing,
                canProcess: model.canProcess,
                runProcessingTip: runProcessingTip,
                process: processImages
            )

            AdvertisementSection(.small)
        }
    }
}

private extension BatchBackgroundRemovalStepsView {
    func processImages() {
        Task {
            model.processImages()
        }
    }
}
