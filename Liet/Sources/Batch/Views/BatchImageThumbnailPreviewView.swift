import MHDesign
import SwiftUI
import UIKit

struct BatchImageThumbnailPreviewView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let image: UIImage
    let height: CGFloat
    let accessibilityLabel: String
    let imageTapAction: (() -> Void)?

    var body: some View {
        if let imageTapAction {
            Button(
                action: imageTapAction
            ) {
                previewSurface
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
        } else {
            previewSurface
        }
    }
}

private extension BatchImageThumbnailPreviewView {
    var previewSurface: some View {
        BatchImagePreviewSurface(
            image: image,
            showsTransparencyBackground: image.batchHasAlphaChannel,
            tileSize: BatchDesign.TransparencyPreview.thumbnailTileSize,
            contentMode: .fill
        )
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(
            RoundedRectangle(
                cornerRadius: designMetrics.cornerRadius.surface,
                style: .continuous
            )
        )
    }
}
