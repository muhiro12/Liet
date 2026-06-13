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
            ProcessedBatchImageMetadataView(
                resolvedFilename: resolvedFilename,
                detailText: image.detailText
            )
        }
    }
}
