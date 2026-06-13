import MHDesign
import SwiftUI

struct BatchImageImportFeedbackView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let isImporting: Bool
    let importFailureCount: Int?

    var body: some View {
        if isImporting || importFailureCount != nil {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                if isImporting {
                    ProgressView("Loading images...")
                }

                if let importFailureCount {
                    BatchStatusChip(
                        text: importFailureText(importFailureCount),
                        systemImage: "exclamationmark.triangle.fill",
                        tone: .warning
                    )
                }
            }
        }
    }
}

private extension BatchImageImportFeedbackView {
    func importFailureText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image couldn't be loaded.")
        } else {
            Text("\(count) images couldn't be loaded.")
        }
    }
}
