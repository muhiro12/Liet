import SwiftUI
import UIKit

struct BatchImageZoomableScrollView: UIViewRepresentable {
    private final class LayoutAwareScrollView: UIScrollView {
        var layoutDidChange: ((UIScrollView) -> Void)?

        override func layoutSubviews() {
            super.layoutSubviews()
            layoutDidChange?(self)
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate, UIScrollViewDelegate {
        static let centeringDivisor = 2.0
        static let minimumZoomScale: CGFloat = 1

        let contentView = UIView()
        let imageView = UIImageView()
        let backgroundTapRecognizer: UITapGestureRecognizer

        var maximumZoomScale: CGFloat

        private let backgroundTapAction: () -> Void
        private var lastBoundsSize: CGSize = .zero
        private var imageIdentifier: ObjectIdentifier?
        private var showsTransparencyBackground = false

        init(
            maximumZoomScale: CGFloat,
            backgroundTapAction: @escaping () -> Void
        ) {
            self.maximumZoomScale = maximumZoomScale
            self.backgroundTapAction = backgroundTapAction
            backgroundTapRecognizer = .init()
            super.init()

            backgroundTapRecognizer.addTarget(
                self,
                action: #selector(handleBackgroundTap(_:))
            )
            backgroundTapRecognizer.cancelsTouchesInView = false
            backgroundTapRecognizer.delegate = self
        }

        func setImage(
            _ image: UIImage
        ) -> Bool {
            let resolvedIdentifier = ObjectIdentifier(image)
            let imageChanged = imageIdentifier != resolvedIdentifier

            if imageChanged {
                imageView.image = image
                imageIdentifier = resolvedIdentifier
            }

            return imageChanged
        }

        func setTransparencyBackground(
            _ shouldShow: Bool
        ) {
            guard showsTransparencyBackground != shouldShow else {
                return
            }

            showsTransparencyBackground = shouldShow
            contentView.backgroundColor = if shouldShow {
                BatchImagePreviewBackground.patternColor(
                    tileSize: BatchDesign.TransparencyPreview.fullscreenTileSize
                )
            } else {
                .clear
            }
        }

        func updateLayout(
            for scrollView: UIScrollView,
            resetZoomScale: Bool
        ) {
            guard let image = imageView.image,
                  scrollView.bounds.width > 0,
                  scrollView.bounds.height > 0 else {
                return
            }

            let boundsChanged = scrollView.bounds.size != lastBoundsSize
            lastBoundsSize = scrollView.bounds.size

            scrollView.maximumZoomScale = maximumZoomScale
            scrollView.minimumZoomScale = Self.minimumZoomScale

            let needsLayoutUpdate = boundsChanged ||
                resetZoomScale ||
                contentView.frame.size == .zero

            if needsLayoutUpdate {
                let fittedSize = fittedImageSize(
                    imageSize: image.size,
                    containerSize: scrollView.bounds.size
                )

                contentView.frame = CGRect(
                    origin: .zero,
                    size: fittedSize
                )
                imageView.frame = contentView.bounds
                scrollView.contentSize = fittedSize
            }

            if resetZoomScale {
                scrollView.zoomScale = Self.minimumZoomScale
                scrollView.contentOffset = .zero
            }

            updateContentInset(for: scrollView)
        }

        func viewForZooming(
            in _: UIScrollView
        ) -> UIView? {
            contentView
        }

        func scrollViewDidZoom(
            _ scrollView: UIScrollView
        ) {
            updateContentInset(for: scrollView)
        }

        func gestureRecognizer(
            _: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
        ) -> Bool {
            true
        }

        @objc
        func handleBackgroundTap(
            _ recognizer: UITapGestureRecognizer
        ) {
            guard let scrollView = recognizer.view as? UIScrollView else {
                return
            }

            let contentFrame = contentView.convert(
                contentView.bounds,
                to: scrollView
            )
            let tapLocation = recognizer.location(
                in: scrollView
            )

            guard !contentFrame.contains(tapLocation) else {
                return
            }

            backgroundTapAction()
        }

        private func updateContentInset(
            for scrollView: UIScrollView
        ) {
            let horizontalInset = max(
                0,
                (scrollView.bounds.width - scrollView.contentSize.width) / Self.centeringDivisor
            )
            let verticalInset = max(
                0,
                (scrollView.bounds.height - scrollView.contentSize.height) / Self.centeringDivisor
            )

            scrollView.contentInset = .init(
                top: verticalInset,
                left: horizontalInset,
                bottom: verticalInset,
                right: horizontalInset
            )
        }

        private func fittedImageSize(
            imageSize: CGSize,
            containerSize: CGSize
        ) -> CGSize {
            guard imageSize.width > 0,
                  imageSize.height > 0,
                  containerSize.width > 0,
                  containerSize.height > 0 else {
                return containerSize
            }

            let widthScale = containerSize.width / imageSize.width
            let heightScale = containerSize.height / imageSize.height
            let scale = min(widthScale, heightScale)

            return .init(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )
        }
    }

    let image: UIImage
    let maximumZoomScale: CGFloat
    let showsTransparencyBackground: Bool
    let backgroundTapAction: () -> Void

    func makeCoordinator() -> Coordinator {
        .init(
            maximumZoomScale: maximumZoomScale,
            backgroundTapAction: backgroundTapAction
        )
    }

    func makeUIView(
        context: Context
    ) -> UIScrollView {
        let scrollView = LayoutAwareScrollView()
        scrollView.backgroundColor = .clear
        scrollView.bouncesZoom = true
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.minimumZoomScale = Coordinator.minimumZoomScale
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
        context.coordinator.setTransparencyBackground(showsTransparencyBackground)
        context.coordinator.maximumZoomScale = maximumZoomScale
        context.coordinator.updateLayout(
            for: scrollView,
            resetZoomScale: imageChanged
        )
    }
}
