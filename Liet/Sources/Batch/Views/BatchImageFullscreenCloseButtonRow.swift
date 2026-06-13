import SwiftUI

struct BatchImageFullscreenCloseButtonRow: View {
    let dismissPreview: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button(role: .cancel) {
                dismissPreview()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: BatchDesign.Fullscreen.closeButtonImageSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(BatchDesign.Fullscreen.closeButtonPadding)
                    .background(
                        Circle()
                            .fill(.black.opacity(BatchDesign.Fullscreen.closeButtonBackgroundOpacity))
                    )
            }
            .padding(.top, BatchDesign.Fullscreen.closeButtonTopPadding)
            .accessibilityLabel("Close Preview")
            .accessibilityHint("Dismisses the full-screen preview.")
        }
        .frame(maxWidth: .infinity)
    }
}
