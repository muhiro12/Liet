import UIKit

final class BatchImageZoomableLayoutAwareScrollView: UIScrollView {
    var layoutDidChange: ((UIScrollView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDidChange?(self)
    }
}
