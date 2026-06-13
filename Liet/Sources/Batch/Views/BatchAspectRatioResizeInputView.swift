import LietLibrary
import MHDesign
import SwiftUI

struct BatchAspectRatioResizeInputView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var referenceDimension: BatchResizeReferenceDimension
    @Binding var referencePixels: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                Text("Reference edge")
                    .batchTextStyle(.bodyStrong)

                Picker("Reference edge", selection: $referenceDimension) {
                    Text("Width")
                        .tag(BatchResizeReferenceDimension.width)
                    Text("Height")
                        .tag(BatchResizeReferenceDimension.height)
                }
                .pickerStyle(.segmented)
            }

            BatchDimensionInputView(
                text: $referencePixels,
                title: referencePixelsTitle,
                placeholder: referencePixelsPlaceholder
            )
        }
    }
}

private extension BatchAspectRatioResizeInputView {
    var referencePixelsTitle: Text {
        switch referenceDimension {
        case .width:
            Text("Width (px)")
        case .height:
            Text("Height (px)")
        }
    }

    var referencePixelsPlaceholder: String {
        switch referenceDimension {
        case .width:
            "1920"
        case .height:
            "1080"
        }
    }
}
