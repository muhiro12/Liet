import SwiftUI

struct ContentBackgroundRemovalDetailView: View {
    let model: BatchBackgroundRemovalHomeModel
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
