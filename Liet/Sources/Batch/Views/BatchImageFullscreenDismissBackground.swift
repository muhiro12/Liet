import SwiftUI

struct BatchImageFullscreenDismissBackground: View {
    let dismissPreview: () -> Void

    var body: some View {
        Button {
            dismissPreview()
        } label: {
            Color.black
                .ignoresSafeArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close Preview")
        .accessibilityHidden(true)
    }
}
