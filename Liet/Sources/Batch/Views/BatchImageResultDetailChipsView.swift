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
                    text: pngCompressionText(),
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
    }
}

private extension BatchImageResultDetailChipsView {
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

    func pngCompressionText() -> Text {
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
