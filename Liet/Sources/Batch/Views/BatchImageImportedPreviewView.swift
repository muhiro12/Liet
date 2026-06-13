import MHDesign
import SwiftUI

struct BatchImageImportedPreviewView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @State private var activePreviewItem: BatchImagePreviewItem?

    let importedImages: [ImportedBatchImage]
    let summaryText: Text?
    let projectedPixelSizeResolver: ((ImportedBatchImage) -> CGSize?)?
    let backToSettings: (() -> Void)?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            BatchImportedImagesGridSection(
                importedImages: importedImages,
                summaryText: summaryText,
                projectedPixelSize: projectedPixelSizeResolver,
                showsSelectionPreviewTip: showsSelectionPreviewTip,
                openPreview: openPreview(for:)
            )
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
    var showsSelectionPreviewTip: Bool {
        summaryText == nil && projectedPixelSizeResolver == nil
    }

    func openPreview(
        for image: ImportedBatchImage
    ) {
        activePreviewItem = .init(
            importedImage: image
        )
    }
}
