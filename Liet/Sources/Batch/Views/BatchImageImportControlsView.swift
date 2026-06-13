import MHDesign
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageImportControlsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var isPresentingFileImporter: Bool

    let isImporting: Bool
    let importedImageCount: Int
    let importFailureCount: Int?
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void
    let selectImagesTip: SelectImagesTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            BatchImageImportButtonsView(
                selectedItems: $selectedItems,
                isPresentingFileImporter: $isPresentingFileImporter,
                isImporting: isImporting,
                selectImagesTip: selectImagesTip
            )

            BatchImageImportStatusRow(
                importedImageCount: importedImageCount,
                reviewSelection: reviewSelection
            ) {
                selectedItems = []
                clearSelection()
            }

            BatchImageImportFeedbackView(
                isImporting: isImporting,
                importFailureCount: importFailureCount
            )
        }
    }
}
