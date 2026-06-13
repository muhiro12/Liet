import SwiftUI

struct BatchImageImportStatusRow: View {
    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            BatchImageImportStatusHorizontalLayout(
                importedImageCount: importedImageCount,
                reviewSelection: reviewSelection,
                clearSelection: clearSelection
            )
            BatchImageImportStatusVerticalLayout(
                importedImageCount: importedImageCount,
                reviewSelection: reviewSelection,
                clearSelection: clearSelection
            )
        }
    }
}
