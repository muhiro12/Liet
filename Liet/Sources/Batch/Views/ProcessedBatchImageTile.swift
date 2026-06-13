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
            ProcessedBatchImageFilenameEditor(
                defaultOutputStem: image.defaultOutputStem,
                outputFilenameExtension: image.outputFilenameExtension,
                filenameStem: filenameStem
            )
            resolvedFilenameText()
            detailText()
        }
    }
}

private extension ProcessedBatchImageTile {
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
