import SwiftUI

struct ImportedBatchImageTile: View {
    private enum Layout {
        static let cornerRadius = 12.0
        static let textSpacing = 4.0
        static let imageHeight = 96.0
        static let detailLineLimit = 3
    }

    let image: ImportedBatchImage
    let projectedPixelSize: CGSize?

    init(
        image: ImportedBatchImage,
        projectedPixelSize: CGSize? = nil
    ) {
        self.image = image
        self.projectedPixelSize = projectedPixelSize
    }

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

            Text(image.displayName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(image.detailText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(Layout.detailLineLimit)

            if let projectedDetailText {
                Text(projectedDetailText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(Layout.detailLineLimit)
            }
        }
    }
}

private extension ImportedBatchImageTile {
    var projectedDetailText: String? {
        guard let projectedPixelSize else {
            return nil
        }

        return "Output • \(Int(projectedPixelSize.width))×\(Int(projectedPixelSize.height))"
    }
}
