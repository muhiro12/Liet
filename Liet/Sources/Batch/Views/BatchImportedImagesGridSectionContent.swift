import SwiftUI

struct BatchImportedImagesGridSectionContent: View {
    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSize: ((ImportedBatchImage) -> CGSize?)?
    let openPreview: (ImportedBatchImage) -> Void

    @ViewBuilder var body: some View {
        let grid = BatchImportedImagesGrid(
            importedImages: importedImages,
            projectedPixelSize: projectedPixelSize,
            openPreview: openPreview
        )

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

private extension BatchImportedImagesGridSectionContent {
    var selectionTitle: Text {
        if importedImages.count == 1 {
            Text("1 image selected")
        } else {
            Text("\(importedImages.count) images selected")
        }
    }
}
