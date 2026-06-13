import LietLibrary
import MHDesign
import SwiftUI
import TipKit

struct BatchExactResizeMethodPickerView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var exactResizeStrategy: BatchExactResizeStrategy

    let resizeMethodTip: ResizeMethodTip

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Method")
                .batchTextStyle(.bodyStrong)

            Picker(selection: $exactResizeStrategy) {
                Text("Stretch")
                    .tag(BatchExactResizeStrategy.stretch)
                Text("Contain")
                    .tag(BatchExactResizeStrategy.contain)
                Text("Crop")
                    .tag(BatchExactResizeStrategy.coverCrop)
            } label: {
                Text("Method")
            }
            .pickerStyle(.segmented)
            .popoverTip(
                resizeMethodTip,
                arrowEdge: .top
            )
        }
    }
}
