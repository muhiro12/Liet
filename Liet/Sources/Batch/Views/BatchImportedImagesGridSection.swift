import SwiftUI
import TipKit

struct BatchImportedImagesGridSection: View {
    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSize: ((ImportedBatchImage) -> CGSize?)?
    let showsSelectionPreviewTip: Bool
    let openPreview: (ImportedBatchImage) -> Void
    private let selectionPreviewTip = SelectionPreviewTip()

    @ViewBuilder var body: some View {
        let sectionContent = BatchImportedImagesGridSectionContent(
            importedImages: importedImages,
            summaryText: summaryText,
            projectedPixelSize: projectedPixelSize,
            openPreview: openPreview
        )

        if showsSelectionPreviewTip {
            sectionContent
                .popoverTip(
                    selectionPreviewTip,
                    arrowEdge: .top
                )
        } else {
            sectionContent
        }
    }
}
