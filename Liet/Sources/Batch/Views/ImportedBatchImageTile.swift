import SwiftUI

struct ImportedBatchImageTile: View {
    private enum Layout {
        static let cornerRadius = 12.0
        static let textSpacing = 4.0
        static let imageHeight = 96.0
        static let detailLineLimit = 3
    }

    let image: ImportedBatchImage
    var imageTapAction: (() -> Void)?
    var projectedPixelSize: CGSize?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: Layout.textSpacing
        ) {
            previewImage()

            Text(image.displayName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(image.detailText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(Layout.detailLineLimit)

            if let projectedPixelSize {
                projectedDetailText(for: projectedPixelSize)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(Layout.detailLineLimit)
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

    @ViewBuilder
    func previewImage() -> some View {
        let imageView = Image(uiImage: image.previewImage)
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
