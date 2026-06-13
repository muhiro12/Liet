import SwiftUI
import UIKit

struct BatchImageZoomableScrollView: UIViewRepresentable {
    let image: UIImage
    let imageAccessibilityLabel: String
    let maximumZoomScale: CGFloat
    let showsTransparencyBackground: Bool
    let backgroundTapAction: () -> Void

    func makeCoordinator() -> BatchImageZoomableScrollViewCoordinator {
        .init(
            maximumZoomScale: maximumZoomScale,
            backgroundTapAction: backgroundTapAction
        )
    }

    func makeUIView(
        context: Context
    ) -> UIScrollView {
        let scrollView = BatchImageZoomableLayoutAwareScrollView()
        scrollView.backgroundColor = .clear
        scrollView.bouncesZoom = true
        scrollView.delegate = context.coordinator
        context.coordinator.setScrollView(scrollView)
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = BatchImageZoomableScrollViewCoordinator.minimumZoomScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let contentView = context.coordinator.contentView
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true

        let imageView = context.coordinator.imageView
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit

        contentView.addSubview(imageView)
        scrollView.addSubview(contentView)
        scrollView.addGestureRecognizer(
            context.coordinator.backgroundTapRecognizer
        )
        scrollView.layoutDidChange = { [coordinator = context.coordinator] scrollView in
            coordinator.updateLayout(
                for: scrollView,
                resetZoomScale: false
            )
        }

        return scrollView
    }

    func updateUIView(
        _ scrollView: UIScrollView,
        context: Context
    ) {
        let imageChanged = context.coordinator.setImage(image)
        context.coordinator.setImageAccessibilityLabel(imageAccessibilityLabel)
        context.coordinator.setTransparencyBackground(showsTransparencyBackground)
        context.coordinator.maximumZoomScale = maximumZoomScale
        context.coordinator.updateLayout(
            for: scrollView,
            resetZoomScale: imageChanged
        )
    }
}
