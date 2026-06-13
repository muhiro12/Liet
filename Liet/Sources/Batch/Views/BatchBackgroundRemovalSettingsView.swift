import MHDesign
import SwiftUI

struct BatchBackgroundRemovalSettingsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var strength: Double
    @Binding var edgeSmoothing: Double
    @Binding var edgeExpansion: Double

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            BatchAdjustmentSliderView(
                title: "Strength",
                value: $strength,
                range: 0...1,
                valueText: percentageText(strength)
            )
            BatchAdjustmentSliderView(
                title: "Edge smoothing",
                value: $edgeSmoothing,
                range: 0...1,
                valueText: percentageText(edgeSmoothing)
            )
            BatchAdjustmentSliderView(
                title: "Edge expand / contract",
                value: $edgeExpansion,
                range: -1...1,
                valueText: signedPercentageText(edgeExpansion)
            )
            BatchStatusChip(
                "Exports PNG with transparency",
                systemImage: "sparkles",
                tone: .neutral
            )
        }
    }
}

private extension BatchBackgroundRemovalSettingsView {
    func percentageText(
        _ value: Double
    ) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    func signedPercentageText(
        _ value: Double
    ) -> String {
        let percentage = Int((value * 100).rounded())

        if percentage > 0 {
            return "+\(percentage)%"
        }

        return "\(percentage)%"
    }
}
