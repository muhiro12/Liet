import SwiftUI

struct BatchImageResultStatusChip: View {
    enum Kind {
        case failure(count: Int)
        case jpegFallback(count: Int)
        case pngCompressionIgnored
        case saveFeedback(BatchImageResultModel.SaveFeedback)
    }

    let kind: Kind

    var body: some View {
        BatchStatusChip(
            text: kind.text,
            systemImage: kind.systemImage,
            tone: kind.tone
        )
    }
}

private extension BatchImageResultStatusChip.Kind {
    var systemImage: String {
        switch self {
        case .failure:
            "exclamationmark.triangle.fill"
        case .jpegFallback:
            "arrow.triangle.2.circlepath"
        case .pngCompressionIgnored:
            "photo"
        case .saveFeedback:
            "checkmark.circle.fill"
        }
    }

    var text: Text {
        switch self {
        case let .failure(count):
            if count == 1 {
                Text("1 failed")
            } else {
                Text("\(count) failed")
            }
        case let .jpegFallback(count):
            if count == 1 {
                Text("1 JPEG fallback")
            } else {
                Text("\(count) JPEG fallback")
            }
        case .pngCompressionIgnored:
            Text("PNG output ignored compression")
        case let .saveFeedback(feedback):
            saveFeedbackText(feedback)
        }
    }

    var tone: BatchStatusChip.Tone {
        switch self {
        case .failure:
            .warning
        case .jpegFallback:
            .warning
        case .pngCompressionIgnored:
            .neutral
        case .saveFeedback:
            .success
        }
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
