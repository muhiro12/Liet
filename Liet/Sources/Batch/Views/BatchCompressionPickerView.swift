import LietLibrary
import MHDesign
import SwiftUI

struct BatchCompressionPickerView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var compression: BatchImageCompression

    let showsMixedCompressionHint: Bool

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Picker("Compression", selection: $compression) {
                Text("Off")
                    .tag(BatchImageCompression.off)
                Text("High")
                    .tag(BatchImageCompression.high)
                Text("Medium")
                    .tag(BatchImageCompression.medium)
                Text("Low")
                    .tag(BatchImageCompression.low)
            }
            .pickerStyle(.segmented)

            if showsMixedCompressionHint {
                BatchStatusChip(
                    "PNG keeps original format",
                    systemImage: "photo",
                    tone: .neutral
                )
            }
        }
    }
}
