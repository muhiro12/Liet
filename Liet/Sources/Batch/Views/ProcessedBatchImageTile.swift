import SwiftUI

struct ProcessedBatchImageTile: View {
    private enum Layout {
        static let cornerRadius = 12.0
        static let textSpacing = 4.0
        static let imageHeight = 112.0
        static let detailLineLimit = 2
    }

    let image: ProcessedBatchImage

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Layout.textSpacing
        ) {
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

            Text(image.outputFilename)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(image.detailText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(Layout.detailLineLimit)
        }
    }
}
