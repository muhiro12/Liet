import MHDesign
import SwiftUI
import TipKit

struct BatchImageImportedPreviewView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @State private var activePreviewItem: BatchImagePreviewItem?

    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSizeResolver: ((ImportedBatchImage) -> CGSize?)?
    let backToSettings: (() -> Void)?
    private let selectionPreviewTip = SelectionPreviewTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            previewsSection()
        }
        .batchScreen(
            title: nil as Text?,
            subtitle: nil as Text?
        )
        .fullScreenCover(item: $activePreviewItem) { item in
            BatchImageFullscreenPreviewView(
                item: item
            )
        }
        .navigationTitle("Selection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            BatchDetailToolbar(backToSettings: backToSettings) {
                BatchImageTipSupport.resetTips()
            }
        }
    }
}

private extension BatchImageImportedPreviewView {
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

    @ViewBuilder
    func previewsSection() -> some View {
        if summaryText == nil,
           projectedPixelSizeResolver == nil {
            previewsGridSection()
                .popoverTip(
                    selectionPreviewTip,
                    arrowEdge: .top
                )
        } else {
            previewsGridSection()
        }
    }

    @ViewBuilder
    func previewsGridSection() -> some View {
        let grid = LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            ForEach(importedImages) { image in
                ImportedBatchImageTile(
                    image: image,
                    imageTapAction: {
                        activePreviewItem = .init(
                            importedImage: image
                        )
                    },
                    projectedPixelSize: projectedPixelSize(for: image)
                )
            }
        }

        if let summaryText {
            BatchSection(
                title: selectionTitle,
                accessory: AnyView(
                    BatchStatusChip(
                        text: summaryText,
                        systemImage: "arrow.up.left.and.arrow.down.right",
                        tone: .accent
                    )
                )
            ) {
                grid
            }
        } else {
            BatchSection(title: selectionTitle) {
                grid
            }
        }
    }

    func projectedPixelSize(
        for image: ImportedBatchImage
    ) -> CGSize? {
        projectedPixelSizeResolver?(image)
    }
}
