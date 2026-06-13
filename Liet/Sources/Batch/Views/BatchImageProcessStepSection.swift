import SwiftUI
import TipKit

struct BatchImageProcessStepSection: View {
    let isProcessing: Bool
    let canProcess: Bool
    let runProcessingTip: RunProcessingTip
    let process: () -> Void

    var body: some View {
        BatchStepSection(
            number: BatchDesign.Step.process,
            title: "Process"
        ) {
            BatchProcessButtonView(
                isProcessing: isProcessing,
                canProcess: canProcess,
                runProcessingTip: runProcessingTip,
                process: process
            )
        }
    }
}
