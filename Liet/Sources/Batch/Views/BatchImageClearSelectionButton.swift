import SwiftUI

struct BatchImageClearSelectionButton: View {
    let clearSelection: () -> Void

    var body: some View {
        Button(role: .destructive) {
            clearSelection()
        } label: {
            Label("Clear", systemImage: "xmark.circle")
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Clear imported images")
        .accessibilityHint("Removes the imported images from this batch.")
    }
}
