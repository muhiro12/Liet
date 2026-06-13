import UIKit

final class BatchImageZoomableScrollViewCoordinator:
    NSObject,
    UIGestureRecognizerDelegate,
    UIScrollViewDelegate {
    static let centeringDivisor = 2.0
    static let accessibilityZoomScaleMultiplier: CGFloat = 2
    static let minimumZoomScale: CGFloat = 1

    let contentView = UIView()
    let imageView = UIImageView()
    let backgroundTapRecognizer: UITapGestureRecognizer

    var maximumZoomScale: CGFloat

    private let backgroundTapAction: () -> Void
    private var lastBoundsSize: CGSize = .zero
    private var imageIdentifier: ObjectIdentifier?
    private var showsTransparencyBackground = false
    private weak var scrollView: UIScrollView?

    private lazy var zoomInAccessibilityAction: UIAccessibilityCustomAction = .init(
        name: "Zoom In",
        target: self,
        selector: #selector(handleZoomInAccessibilityAction(_:))
    )

    private lazy var zoomOutAccessibilityAction: UIAccessibilityCustomAction = .init(
        name: "Zoom Out",
        target: self,
        selector: #selector(handleZoomOutAccessibilityAction(_:))
    )

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

    func setScrollView(
        _ scrollView: UIScrollView
    ) {
        self.scrollView = scrollView
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

    func setImageAccessibilityLabel(
        _ label: String
    ) {
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = label
        imageView.accessibilityTraits = .image
        imageView.accessibilityCustomActions = [
            zoomInAccessibilityAction,
            zoomOutAccessibilityAction
        ]
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

    @objc
    func handleZoomInAccessibilityAction(
        _: UIAccessibilityCustomAction
    ) -> Bool {
        adjustZoomScale(
            by: Self.accessibilityZoomScaleMultiplier
        )
    }

    @objc
    func handleZoomOutAccessibilityAction(
        _: UIAccessibilityCustomAction
    ) -> Bool {
        adjustZoomScale(
            by: 1 / Self.accessibilityZoomScaleMultiplier
        )
    }
}

private extension BatchImageZoomableScrollViewCoordinator {
    func adjustZoomScale(
        by multiplier: CGFloat
    ) -> Bool {
        guard let scrollView else {
            return false
        }

        let resolvedZoomScale = min(
            max(
                scrollView.zoomScale * multiplier,
                Self.minimumZoomScale
            ),
            scrollView.maximumZoomScale
        )

        guard resolvedZoomScale != scrollView.zoomScale else {
            return false
        }

        scrollView.setZoomScale(
            resolvedZoomScale,
            animated: true
        )

        return true
    }

    func updateContentInset(
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

    func fittedImageSize(
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
