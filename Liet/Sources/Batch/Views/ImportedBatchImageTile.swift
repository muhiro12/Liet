import MHDesign
import SwiftUI

struct ImportedBatchImageTile: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let image: ImportedBatchImage
    var imageTapAction: (() -> Void)?
    var projectedPixelSize: CGSize?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.ImportedTile.textSpacing
        ) {
            previewImage()

            Text(image.displayName)
                .batchTextStyle(.caption)
                .lineLimit(1)

            secondaryText(Text(image.detailText))

            if let projectedPixelSize {
                secondaryText(
                    projectedDetailText(for: projectedPixelSize)
                )
            }
        }
    }
}

private extension ImportedBatchImageTile {
    func projectedDetailText(
        for projectedPixelSize: CGSize
    ) -> Text {
        Text("Output • \(Int(projectedPixelSize.width))×\(Int(projectedPixelSize.height))")
    }

    func secondaryText(
        _ text: Text
    ) -> some View {
        text
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(BatchDesign.ImportedTile.detailLineLimit)
    }

    @ViewBuilder
    func previewImage() -> some View {
        let imageView = BatchImagePreviewSurface(
            image: image.previewImage,
            showsTransparencyBackground: image.previewImage.batchHasAlphaChannel,
            tileSize: BatchDesign.TransparencyPreview.thumbnailTileSize,
            contentMode: .fill
        )
        .frame(maxWidth: .infinity)
        .frame(height: BatchDesign.ImportedTile.imageHeight)
        .clipShape(
            RoundedRectangle(
                cornerRadius: designMetrics.radius.surface,
                style: .continuous
            )
        )

        if let imageTapAction {
            Button(
                action: imageTapAction
            ) {
                imageView
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Preview \(image.displayName)")
        } else {
            imageView
        }
    }
}
