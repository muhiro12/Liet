import SwiftUI

struct ProcessedBatchImageTile: View {
    private enum Layout {
        static let cornerRadius = 12.0
        static let textSpacing = 6.0
        static let imageHeight = 112.0
        static let detailLineLimit = 2
        static let filenameSpacing = 6.0
    }

    let image: ProcessedBatchImage
    let resolvedFilename: String
    let filenameStem: Binding<String>

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Layout.textSpacing
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
        Image(uiImage: image.previewImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.imageHeight)
            .accessibilityHidden(true)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Layout.cornerRadius,
                    style: .continuous
                )
            )
    }

    func filenameEditor() -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: Layout.filenameSpacing
        ) {
            TextField(
                image.defaultOutputStem,
                text: filenameStem
            )
            .textFieldStyle(.roundedBorder)

            Text(".\(image.outputFilenameExtension)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func resolvedFilenameText() -> some View {
        Text(resolvedFilename)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
    }

    func detailText() -> some View {
        Text(image.detailText)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(Layout.detailLineLimit)
    }
}
