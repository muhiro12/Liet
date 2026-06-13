import MHDesign
import SwiftUI

struct BatchCustomNamingPrefixView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var customNamingPrefix: String

    let showsCustomNamingPrefixField: Bool
    let hasValidNaming: Bool

    var body: some View {
        if showsCustomNamingPrefixField {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                Text("Custom prefix")
                    .batchTextStyle(.bodyStrong)

                TextField("prefix", text: $customNamingPrefix)
                    .textFieldStyle(.roundedBorder)

                if !hasValidNaming {
                    BatchStatusChip(
                        "Enter a custom prefix to enable processing",
                        systemImage: "text.cursor",
                        tone: .warning
                    )
                }
            }
        }
    }
}
