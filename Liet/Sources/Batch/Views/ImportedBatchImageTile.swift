import SwiftUI

struct ImportedBatchImageTile: View {
    private enum Layout {
        static let cornerRadius = 12.0
        static let textSpacing = 4.0
        static let imageHeight = 96.0
    }

    let image: ImportedBatchImage

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
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Layout.cornerRadius,
                        style: .continuous
                    )
                )

            Text(image.displayName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(image.detailText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }
}
