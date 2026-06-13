import SwiftUI

struct BatchImageImportActionButtonsView: View {
    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        if importedImageCount > 0 {
            if let reviewSelection {
                BatchImageReviewSelectionButton(
                    reviewSelection: reviewSelection
                )
            }

            BatchImageClearSelectionButton(
                clearSelection: clearSelection
            )
        }
    }
}
