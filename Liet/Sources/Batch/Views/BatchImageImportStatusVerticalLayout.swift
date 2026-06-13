import MHDesign
import SwiftUI

struct BatchImageImportStatusVerticalLayout: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            BatchSelectedImageCountText(
                importedImageCount: importedImageCount
            )

            if importedImageCount > 0 {
                HStack(
                    spacing: designMetrics.spacing.control
                ) {
                    BatchImageImportActionButtonsView(
                        importedImageCount: importedImageCount,
                        reviewSelection: reviewSelection,
                        clearSelection: clearSelection
                    )
                }
            }
        }
    }
}
