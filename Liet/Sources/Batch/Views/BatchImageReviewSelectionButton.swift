import SwiftUI

struct BatchImageReviewSelectionButton: View {
    let reviewSelection: () -> Void

    var body: some View {
        Button(action: reviewSelection) {
            Label("Review", systemImage: "eye")
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Review imported images")
    }
}
