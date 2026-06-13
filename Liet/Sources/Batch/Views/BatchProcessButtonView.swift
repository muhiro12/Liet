import SwiftUI
import TipKit

struct BatchProcessButtonView: View {
    let isProcessing: Bool
    let canProcess: Bool
    let runProcessingTip: RunProcessingTip
    let process: () -> Void

    var body: some View {
        Button {
            process()
        } label: {
            if isProcessing {
                ProgressView("Processing")
                    .frame(maxWidth: .infinity)
            } else {
                Label("Process", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(!canProcess)
        .popoverTip(
            runProcessingTip,
            arrowEdge: .top
        )
    }
}
