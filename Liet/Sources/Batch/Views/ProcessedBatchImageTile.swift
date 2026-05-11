import MHDesign
import SwiftUI

struct ProcessedBatchImageTile: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let image: ProcessedBatchImage
    var imageTapAction: (() -> Void)?
    let resolvedFilename: String
    let filenameStem: Binding<String>

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.ProcessedTile.textSpacing
        ) {
            previewImage()
            filenameEditor()
            resolvedFilenameText()
            detailText()
        }
    }
}

private extension ProcessedBatchImageTile {
    func previewImage() -> some View {
        let imageView = BatchImagePreviewSurface(
            image: image.previewImage,
            showsTransparencyBackground: image.previewImage.batchHasAlphaChannel,
            tileSize: BatchDesign.TransparencyPreview.thumbnailTileSize,
            contentMode: .fill
        )
        .frame(maxWidth: .infinity)
        .frame(height: BatchDesign.ProcessedTile.imageHeight)
        .clipShape(
            RoundedRectangle(
                cornerRadius: designMetrics.cornerRadius.surface,
                style: .continuous
            )
        )

        return Group {
            if let imageTapAction {
                Button(
                    action: imageTapAction
                ) {
                    imageView
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Preview \(resolvedFilename)")
            } else {
                imageView
            }
        }
    }

    func filenameEditor() -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: BatchDesign.ProcessedTile.filenameSpacing
        ) {
            TextField(
                image.defaultOutputStem,
                text: filenameStem
            )
            .textFieldStyle(.roundedBorder)

            Text(".\(image.outputFilenameExtension)")
                .batchTextStyle(
                    .caption,
                    color: .secondary
                )
        }
    }

    func resolvedFilenameText() -> some View {
        Text(resolvedFilename)
            .batchTextStyle(.caption)
            .lineLimit(1)
    }

    func detailText() -> some View {
        Text(image.detailText)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(BatchDesign.ProcessedTile.detailLineLimit)
    }
}
