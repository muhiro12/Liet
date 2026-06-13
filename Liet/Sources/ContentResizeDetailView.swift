import SwiftUI

struct ContentResizeDetailView: View {
    let model: BatchImageHomeModel
    let backToSettings: () -> Void

    var body: some View {
        ContentBatchDetailView(
            resultModel: model.resultModel,
            importedImages: model.importedImages,
            summaryText: model.selectionSummaryText,
            projectedPixelSizeResolver: model.projectedPixelSize(for:),
            backToSettings: backToSettings
        )
    }
}
