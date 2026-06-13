import MHDesign
import SwiftUI
import UIKit

struct BatchDimensionInputView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var text: String

    let title: Text
    let placeholder: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            title
                .batchTextStyle(.bodyStrong)

            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel(title)
        }
    }
}
