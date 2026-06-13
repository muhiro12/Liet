import MHDesign
import SwiftUI

struct ImportedBatchImageTile: View {
    let image: ImportedBatchImage
    var imageTapAction: (() -> Void)?
    var projectedPixelSize: CGSize?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.ImportedTile.textSpacing
        ) {
            BatchImageThumbnailPreviewView(
                image: image.previewImage,
                height: BatchDesign.ImportedTile.imageHeight,
                accessibilityLabel: "Preview \(image.displayName)",
                imageTapAction: imageTapAction
            )

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
}
