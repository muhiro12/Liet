import MHDesign
import SwiftUI
import TipKit

struct BatchImportedImagesGridSection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSize: ((ImportedBatchImage) -> CGSize?)?
    let showsSelectionPreviewTip: Bool
    let openPreview: (ImportedBatchImage) -> Void
    private let selectionPreviewTip = SelectionPreviewTip()

    @ViewBuilder var body: some View {
        if showsSelectionPreviewTip {
            gridSection
                .popoverTip(
                    selectionPreviewTip,
                    arrowEdge: .top
                )
        } else {
            gridSection
        }
    }
}

private extension BatchImportedImagesGridSection {
    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: BatchDesign.Grid.thumbnailColumnMinimum),
                spacing: designMetrics.spacing.control
            )
        ]
    }

    var selectionTitle: Text {
        if importedImages.count == 1 {
            Text("1 image selected")
        } else {
            Text("\(importedImages.count) images selected")
        }
    }

    @ViewBuilder var gridSection: some View {
        let grid = LazyVGrid(
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

        if let summaryText {
            BatchSection(
                title: selectionTitle,
                accessory: {
                    BatchStatusChip(
                        text: summaryText,
                        systemImage: "arrow.up.left.and.arrow.down.right",
                        tone: .accent
                    )
                },
                content: {
                    grid
                }
            )
        } else {
            BatchSection(title: selectionTitle) {
                grid
            }
        }
    }
}
