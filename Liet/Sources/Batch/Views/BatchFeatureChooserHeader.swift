import MHDesign
import SwiftUI

struct BatchFeatureChooserHeader: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Choose a feature")
                .font(.headline)
            Text("Resize a whole batch or create transparent PNG copies with separate settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, designMetrics.spacing.inline)
    }
}
