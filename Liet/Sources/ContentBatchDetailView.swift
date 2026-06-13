import SwiftUI

struct ContentBatchDetailView: View {
    let resultModel: BatchImageResultModel?
    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSizeResolver: ((ImportedBatchImage) -> CGSize?)?
    let backToSettings: () -> Void

    var body: some View {
        if let resultModel {
            BatchImageResultView(
                model: resultModel,
                backToSettings: backToSettings
            )
        } else if importedImages.isEmpty {
            BatchImageEmptyDetailView(
                backToSettings: backToSettings
            )
        } else {
            BatchImageImportedPreviewView(
                importedImages: importedImages,
                summaryText: summaryText,
                projectedPixelSizeResolver: projectedPixelSizeResolver,
                backToSettings: backToSettings
            )
        }
    }
}
