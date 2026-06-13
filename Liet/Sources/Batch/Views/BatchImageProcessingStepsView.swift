import LietLibrary
import MHDesign
import SwiftUI
import TipKit

struct BatchImageProcessingStepsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchImageHomeModel
    let processingSetupTip: ProcessingSetupTip
    let runProcessingTip: RunProcessingTip
    let resizeMethodTip: ResizeMethodTip
    let userPresetTip: UserPresetTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            BatchImageProcessingSettingsStepView(
                model: model,
                processingSetupTip: processingSetupTip,
                resizeMethodTip: resizeMethodTip,
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

private extension BatchImageProcessingStepsView {
    func processImages() {
        Task {
            model.processImages()
        }
    }
}
