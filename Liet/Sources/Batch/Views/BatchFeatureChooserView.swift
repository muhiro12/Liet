import SwiftUI

struct BatchFeatureChooserView: View {
    private enum Layout {
        static let cardCornerRadius = 20.0
        static let cardPadding = 18.0
        static let cardSpacing = 14.0
        static let featureDescriptionSpacing = 6.0
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let featureIconWidth = 32.0
        static let headerSpacing = 8.0
        static let stepBorderLineWidth = 1.0
        static let stepBorderOpacity = 0.08
    }

    let selectFeature: (BatchFeatureKind) -> Void

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                VStack(
                    alignment: .leading,
                    spacing: Layout.headerSpacing
                ) {
                    Text("Choose a feature")
                        .font(.title2.weight(.semibold))
                    Text("Resize a whole batch or create transparent PNG copies with separate settings.")
                        .foregroundStyle(.secondary)
                }

                VStack(
                    spacing: Layout.cardSpacing
                ) {
                    ForEach(BatchFeatureKind.allCases) { feature in
                        featureButton(feature)
                    }
                }

                AdvertisementSection(.small)
            }
            .padding(Layout.contentPadding)
        }
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
    }
}

private extension BatchFeatureChooserView {
    func featureButton(
        _ feature: BatchFeatureKind
    ) -> some View {
        Button {
            selectFeature(feature)
        } label: {
            featureLabel(feature)
        }
        .buttonStyle(.plain)
    }

    func featureLabel(
        _ feature: BatchFeatureKind
    ) -> some View {
        HStack(
            spacing: Layout.cardSpacing
        ) {
            Image(systemName: feature.systemImage)
                .font(.title2.weight(.semibold))
                .frame(width: Layout.featureIconWidth)
                .foregroundStyle(.accent)

            VStack(
                alignment: .leading,
                spacing: Layout.featureDescriptionSpacing
            ) {
                featureTitle(feature)
                    .font(.headline)
                    .foregroundStyle(.primary)
                featureSubtitle(feature)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(
                cornerRadius: Layout.cardCornerRadius,
                style: .continuous
            )
            .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: Layout.cardCornerRadius,
                style: .continuous
            )
            .strokeBorder(
                Color.primary.opacity(Layout.stepBorderOpacity),
                lineWidth: Layout.stepBorderLineWidth
            )
        }
    }

    func featureTitle(
        _ feature: BatchFeatureKind
    ) -> Text {
        switch feature {
        case .resizeImages:
            Text("Resize Images")
        case .removeBackground:
            Text("Remove Background")
        }
    }

    func featureSubtitle(
        _ feature: BatchFeatureKind
    ) -> Text {
        switch feature {
        case .resizeImages:
            Text("Apply one shared output size, compression, and naming setup to the full batch.")
        case .removeBackground:
            Text("Create transparent PNG copies with one shared background-removal setup.")
        }
    }
}
