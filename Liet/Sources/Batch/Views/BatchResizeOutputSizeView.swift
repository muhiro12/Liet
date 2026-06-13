import LietLibrary
import MHDesign
import SwiftUI
import TipKit

struct BatchResizeOutputSizeView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var keepsAspectRatio: Bool
    @Binding var referenceDimension: BatchResizeReferenceDimension
    @Binding var referencePixels: String
    @Binding var resizeWidth: String
    @Binding var resizeHeight: String
    @Binding var exactResizeStrategy: BatchExactResizeStrategy

    let resizeMethodTip: ResizeMethodTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            Toggle(
                "Keep aspect ratio",
                isOn: $keepsAspectRatio
            )

            BatchResizeModeInputView(
                keepsAspectRatio: keepsAspectRatio,
                referenceDimension: $referenceDimension,
                referencePixels: $referencePixels,
                resizeWidth: $resizeWidth,
                resizeHeight: $resizeHeight,
                exactResizeStrategy: $exactResizeStrategy,
                resizeMethodTip: resizeMethodTip
            )
        }
    }
}
