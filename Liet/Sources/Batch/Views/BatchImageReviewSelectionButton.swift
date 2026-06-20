import SwiftUI

struct BatchImageReviewSelectionButton: View {
    let reviewSelection: () -> Void

    var body: some View {
        Button(action: reviewSelection) {
            Label("Review Selection", systemImage: "eye")
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Review Selection")
    }
}
