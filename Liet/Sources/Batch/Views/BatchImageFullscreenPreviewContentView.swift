import SwiftUI

struct BatchImageFullscreenPreviewContentView: View {
    let previewPhase: BatchImageFullscreenPreviewPhase
    let showsTransparencyBackground: Bool
    let dismissPreview: () -> Void

    var body: some View {
        ZStack {
            switch previewPhase {
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(image):
                BatchImageZoomableScrollView(
                    image: image,
                    maximumZoomScale: BatchDesign.Fullscreen.maximumZoomScale,
                    showsTransparencyBackground: showsTransparencyBackground,
                    backgroundTapAction: dismissPreview
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                BatchImageFullscreenFailureView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
