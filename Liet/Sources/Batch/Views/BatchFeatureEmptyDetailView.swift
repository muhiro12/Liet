import SwiftUI

struct BatchFeatureEmptyDetailView: View {
    var body: some View {
        ContentUnavailableView(
            "Choose a feature to start",
            systemImage: "square.grid.2x2"
        )
        .batchEmptyStateLayout()
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}
