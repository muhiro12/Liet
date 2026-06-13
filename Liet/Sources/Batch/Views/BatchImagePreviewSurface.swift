import SwiftUI
import UIKit

struct BatchImagePreviewSurface: View {
    let image: UIImage
    let showsTransparencyBackground: Bool
    let tileSize: CGFloat
    let contentMode: ContentMode

    var body: some View {
        ZStack {
            if showsTransparencyBackground {
                Color(
                    uiColor: BatchImagePreviewBackground.patternColor(
                        tileSize: tileSize
                    )
                )
            }

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .accessibilityHidden(true)
        }
        .clipped()
    }
}
