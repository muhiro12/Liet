import MHDesign
import SwiftUI
import TipKit

struct BatchImageResultSummarySection: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

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
                    HStack(
                        spacing: designMetrics.spacing.control
                    ) {
                        resultDetailChips
                    }
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

    @ViewBuilder var resultDetailChips: some View {
        if failureCount > 0 {
            BatchStatusChip(
                text: resultFailureText(failureCount),
                systemImage: "exclamationmark.triangle.fill",
                tone: .warning
            )
        }

        if jpegFallbackCount > 0 {
            BatchStatusChip(
                text: jpegFallbackText(jpegFallbackCount),
                systemImage: "arrow.triangle.2.circlepath",
                tone: .warning
            )
        }

        if ignoredCompressionCount > 0 {
            BatchStatusChip(
                text: pngCompressionText(ignoredCompressionCount),
                systemImage: "photo",
                tone: .neutral
            )
        }

        if let saveFeedback {
            BatchStatusChip(
                text: saveFeedbackText(saveFeedback),
                systemImage: "checkmark.circle.fill",
                tone: .success
            )
        }
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

    func resultFailureText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 failed")
        } else {
            Text("\(count) failed")
        }
    }

    func jpegFallbackText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 JPEG fallback")
        } else {
            Text("\(count) JPEG fallback")
        }
    }

    func pngCompressionText(
        _: Int
    ) -> Text {
        Text("PNG output ignored compression")
    }

    func saveFeedbackText(
        _ feedback: BatchImageResultModel.SaveFeedback
    ) -> Text {
        switch feedback {
        case .exportedArchive:
            Text("ZIP saved to Files")
        case let .exportedFiles(count):
            if count == 1 {
                Text("1 saved to Files")
            } else {
                Text("\(count) saved to Files")
            }
        case let .savedToPhotos(count):
            if count == 1 {
                Text("1 saved to Photos")
            } else {
                Text("\(count) saved to Photos")
            }
        }
    }
}
