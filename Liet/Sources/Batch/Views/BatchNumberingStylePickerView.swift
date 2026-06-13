import LietLibrary
import MHDesign
import SwiftUI

struct BatchNumberingStylePickerView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var numberingStyle: BatchImageNumberingStyle

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Numbering")
                .batchTextStyle(.bodyStrong)

            Picker("Numbering", selection: $numberingStyle) {
                Text("001")
                    .tag(BatchImageNumberingStyle.zeroPaddedThreeDigits)
                Text("1")
                    .tag(BatchImageNumberingStyle.plain)
            }
            .pickerStyle(.segmented)
        }
    }
}
