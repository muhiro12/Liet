import SwiftUI

struct BatchImageFullscreenMetadataView: View {
    let displayName: String
    let detailText: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BatchDesign.Fullscreen.detailSpacing
        ) {
            Text(displayName)
                .font(.headline)
                .lineLimit(BatchDesign.Fullscreen.metadataLineLimit)

            Text(detailText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(BatchDesign.Fullscreen.secondaryTextOpacity))
                .lineLimit(BatchDesign.Fullscreen.metadataLineLimit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, BatchDesign.Fullscreen.metadataHorizontalPadding)
    }
}
