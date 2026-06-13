import PhotosUI
import SwiftUI
import TipKit

struct BatchImageImportStepSection: View {
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var isPresentingFileImporter: Bool

    let isImporting: Bool
    let importedImageCount: Int
    let importFailureCount: Int?
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void
    let selectImagesTip: SelectImagesTip

    var body: some View {
        BatchStepSection(
            number: BatchDesign.Step.import,
            title: "Import"
        ) {
            BatchImageImportControlsView(
                selectedItems: $selectedItems,
                isPresentingFileImporter: $isPresentingFileImporter,
                isImporting: isImporting,
                importedImageCount: importedImageCount,
                importFailureCount: importFailureCount,
                reviewSelection: reviewSelection,
                clearSelection: clearSelection,
                selectImagesTip: selectImagesTip
            )
        }
    }
}
