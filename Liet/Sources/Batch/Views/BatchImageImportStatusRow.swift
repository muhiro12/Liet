import MHDesign
import SwiftUI

struct BatchImageImportStatusRow: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let importedImageCount: Int
    let reviewSelection: (() -> Void)?
    let clearSelection: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            horizontalLayout
            verticalLayout
        }
    }
}

private extension BatchImageImportStatusRow {
    var horizontalLayout: some View {
        HStack(
            spacing: designMetrics.spacing.control
        ) {
            selectedImageCountText
                .batchTextStyle(.bodyStrong)

            Spacer(minLength: designMetrics.spacing.control)

            actionButtons
        }
    }

    var verticalLayout: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            selectedImageCountText
                .batchTextStyle(.bodyStrong)

            if importedImageCount > 0 {
                HStack(
                    spacing: designMetrics.spacing.control
                ) {
                    actionButtons
                }
            }
        }
    }

    @ViewBuilder var actionButtons: some View {
        if let reviewSelection,
           importedImageCount > 0 {
            Button {
                reviewSelection()
            } label: {
                Label("Review", systemImage: "eye")
            }
            .buttonStyle(.bordered)
        }

        if importedImageCount > 0 {
            Button {
                clearSelection()
            } label: {
                Label("Clear", systemImage: "xmark.circle")
            }
            .buttonStyle(.bordered)
        }
    }

    var selectedImageCountText: Text {
        if importedImageCount == 1 {
            Text("1 image selected")
        } else {
            Text("\(importedImageCount) images selected")
        }
    }
}
