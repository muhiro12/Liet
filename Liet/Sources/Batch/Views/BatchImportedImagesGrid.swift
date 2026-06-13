import MHDesign
import SwiftUI

struct BatchImportedImagesGrid: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let importedImages: [ImportedBatchImage]
    let projectedPixelSize: ((ImportedBatchImage) -> CGSize?)?
    let openPreview: (ImportedBatchImage) -> Void

    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            ForEach(importedImages) { image in
                ImportedBatchImageTile(
                    image: image,
                    imageTapAction: {
                        openPreview(image)
                    },
                    projectedPixelSize: projectedPixelSize?(image)
                )
            }
        }
    }
}

private extension BatchImportedImagesGrid {
    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: BatchDesign.Grid.thumbnailColumnMinimum),
                spacing: designMetrics.spacing.control
            )
        ]
    }
}
