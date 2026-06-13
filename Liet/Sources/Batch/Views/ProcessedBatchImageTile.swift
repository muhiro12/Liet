import MHDesign
import SwiftUI

struct ProcessedBatchImageTile: View {
    let image: ProcessedBatchImage
    var imageTapAction: (() -> Void)?
    let resolvedFilename: String
    let filenameStem: Binding<String>

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.ProcessedTile.textSpacing
        ) {
            BatchImageThumbnailPreviewView(
                image: image.previewImage,
                height: BatchDesign.ProcessedTile.imageHeight,
                accessibilityLabel: "Preview \(resolvedFilename)",
                imageTapAction: imageTapAction
            )
            filenameEditor()
            resolvedFilenameText()
            detailText()
        }
    }
}

private extension ProcessedBatchImageTile {
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
