import MHDesign
import SwiftUI

struct BatchImageImportStatusHorizontalLayout: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        HStack(
            spacing: designMetrics.spacing.control
        ) {
            BatchSelectedImageCountText(
                importedImageCount: importedImageCount
            )

            Spacer(minLength: designMetrics.spacing.control)

            BatchImageImportActionButtonsView(
                importedImageCount: importedImageCount,
                reviewSelection: reviewSelection,
                clearSelection: clearSelection
            )
        }
    }
}
