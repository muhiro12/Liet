import MHDesign
import SwiftUI

struct BatchAdjustmentSliderView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let title: LocalizedStringKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    let valueText: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            HStack {
                Text(title)
                    .batchTextStyle(.bodyStrong)
                Spacer()
                Text(valueText)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: $value,
                in: range
            )
            .accessibilityLabel(Text(title))
            .accessibilityValue(valueText)
        }
    }
}
