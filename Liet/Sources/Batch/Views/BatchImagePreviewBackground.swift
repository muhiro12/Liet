import UIKit

enum BatchImagePreviewBackground {
    static func patternColor(
        tileSize: CGFloat
    ) -> UIColor {
        UIColor(
            patternImage: patternImage(
                tileSize: tileSize
            )
        )
    }
}

private extension BatchImagePreviewBackground {
    static let colorAlpha: CGFloat = 1
    static let darkWhiteComponent: CGFloat = 0.82
    static let lightWhiteComponent: CGFloat = 0.94
    static let patternDimensionMultiplier: CGFloat = 2
    static let lightColor = UIColor(white: lightWhiteComponent, alpha: colorAlpha)
    static let darkColor = UIColor(white: darkWhiteComponent, alpha: colorAlpha)

    static func patternImage(
        tileSize: CGFloat
    ) -> UIImage {
        let resolvedTileSize = max(1, tileSize)
        let patternSize = CGSize(
            width: resolvedTileSize * patternDimensionMultiplier,
            height: resolvedTileSize * patternDimensionMultiplier
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(
            size: patternSize,
            format: format
        ).image { rendererContext in
            lightColor.setFill()
            rendererContext.fill(
                CGRect(
                    origin: .zero,
                    size: patternSize
                )
            )

            darkColor.setFill()
            rendererContext.fill(
                CGRect(
                    x: 0,
                    y: 0,
                    width: resolvedTileSize,
                    height: resolvedTileSize
                )
            )
            rendererContext.fill(
                CGRect(
                    x: resolvedTileSize,
                    y: resolvedTileSize,
                    width: resolvedTileSize,
                    height: resolvedTileSize
                )
            )
        }
    }
}
