import LietLibrary
import MHDesign
import SwiftUI
import TipKit

struct BatchExactResizeInputView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var resizeWidth: String
    @Binding var resizeHeight: String
    @Binding var exactResizeStrategy: BatchExactResizeStrategy

    let resizeMethodTip: ResizeMethodTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            BatchDimensionInputView(
                text: $resizeWidth,
                title: Text("Width (px)"),
                placeholder: "1920"
            )

            BatchDimensionInputView(
                text: $resizeHeight,
                title: Text("Height (px)"),
                placeholder: "1080"
            )

            BatchExactResizeMethodPickerView(
                exactResizeStrategy: $exactResizeStrategy,
                resizeMethodTip: resizeMethodTip
            )
        }
    }
}
