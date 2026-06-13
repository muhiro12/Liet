import MHDesign
import SwiftUI

struct BatchProcessedImagesGridSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let processedImages: [ProcessedBatchImage]
    let resolvedFilename: (ProcessedBatchImage) -> String
    let filenameStem: (ProcessedBatchImage) -> Binding<String>
    let openPreview: (ProcessedBatchImage) -> Void

    var body: some View {
        BatchSection(title: Text("Processed images")) {
            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ) {
                ForEach(processedImages) { image in
                    ProcessedBatchImageTile(
                        image: image,
                        imageTapAction: {
                            openPreview(image)
                        },
                        resolvedFilename: resolvedFilename(image),
                        filenameStem: filenameStem(image)
                    )
                }
            }
        }
    }
}

private extension BatchProcessedImagesGridSection {
    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: BatchDesign.Grid.thumbnailColumnMinimum),
                spacing: designMetrics.spacing.control
            )
        ]
    }
}
