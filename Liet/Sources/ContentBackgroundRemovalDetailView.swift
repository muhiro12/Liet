import SwiftUI

struct ContentBackgroundRemovalDetailView: View {
    let model: BatchBackgroundRemovalHomeModel
    let backToSettings: () -> Void

    var body: some View {
        if let resultModel = model.resultModel {
            BatchImageResultView(
                model: resultModel,
                backToSettings: backToSettings
            )
        } else if model.importedImages.isEmpty {
            BatchImageEmptyDetailView(
                backToSettings: backToSettings
            )
        } else {
            BatchImageImportedPreviewView(
                importedImages: model.importedImages,
                summaryText: model.selectionSummaryText,
                projectedPixelSizeResolver: model.projectedPixelSize(for:),
                backToSettings: backToSettings
            )
        }
    }
}
