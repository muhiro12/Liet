import SwiftUI

struct BatchImageFullscreenFailureView: View {
    var body: some View {
        VStack(
            spacing: BatchDesign.Fullscreen.detailSpacing
        ) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .accessibilityHidden(true)
            Text("Couldn't load the image preview.")
                .font(.headline)
            Text("Close this viewer and try again.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(BatchDesign.Fullscreen.secondaryTextOpacity))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}
