import SwiftUI
import TipKit

struct BatchImageResultSummarySection: View {
    let processedImageCount: Int
    let failureCount: Int
    let jpegFallbackCount: Int
    let ignoredCompressionCount: Int
    let saveFeedback: BatchImageResultModel.SaveFeedback?

    private let processedResultsTip = ProcessedResultsTip()

    var body: some View {
        if hasResultChips {
            BatchSection(
                title: resultTitleText(processedImageCount)
            ) {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    BatchImageResultDetailChipsView(
                        failureCount: failureCount,
                        jpegFallbackCount: jpegFallbackCount,
                        ignoredCompressionCount: ignoredCompressionCount,
                        saveFeedback: saveFeedback
                    )
                }
            }
            .popoverTip(
                processedResultsTip,
                arrowEdge: .top
            )
        } else {
            resultTitleText(processedImageCount)
                .batchTextStyle(.screenTitle)
                .popoverTip(
                    processedResultsTip,
                    arrowEdge: .top
                )
        }
    }
}

private extension BatchImageResultSummarySection {
    var hasResultChips: Bool {
        failureCount > 0 ||
            jpegFallbackCount > 0 ||
            ignoredCompressionCount > 0 ||
            saveFeedback != nil
    }

    func resultTitleText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image ready")
        } else {
            Text("\(count) images ready")
        }
    }
}
