import MHDesign
import SwiftUI

struct BatchImageResultDetailChipsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let failureCount: Int
    let jpegFallbackCount: Int
    let ignoredCompressionCount: Int
    let saveFeedback: BatchImageResultModel.SaveFeedback?

    var body: some View {
        HStack(
            spacing: designMetrics.spacing.control
        ) {
            if failureCount > 0 {
                BatchImageResultStatusChip(
                    kind: .failure(count: failureCount)
                )
            }

            if jpegFallbackCount > 0 {
                BatchImageResultStatusChip(
                    kind: .jpegFallback(count: jpegFallbackCount)
                )
            }

            if ignoredCompressionCount > 0 {
                BatchImageResultStatusChip(
                    kind: .pngCompressionIgnored
                )
            }

            if let saveFeedback {
                BatchImageResultStatusChip(
                    kind: .saveFeedback(saveFeedback)
                )
            }
        }
    }
}
