import MHDesign
import SwiftUI

struct BatchFeatureChooserView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let selectFeature: (BatchFeatureKind) -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            VStack(
                spacing: designMetrics.spacing.control
            ) {
                ForEach(BatchFeatureKind.allCases) { feature in
                    featureButton(feature)
                }
            }

            AdvertisementSection(.small)
        }
        .batchScreen(
            title: Text("Choose a feature"),
            subtitle: Text("Resize a whole batch or create transparent PNG copies with separate settings.")
        )
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
            alignment: .top,
            spacing: designMetrics.layout.rowAccessorySpacing
        ) {
            Image(systemName: feature.systemImage)
                .font(.title2.weight(.semibold))
                .frame(width: BatchDesign.FeatureChooser.featureIconWidth)
                .foregroundStyle(.tint)

            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                featureTitle(feature)
                    .batchTextStyle(.sectionTitle)
                featureSubtitle(feature)
                    .multilineTextAlignment(.leading)
                    .batchTextStyle(
                        .supporting,
                        color: .secondary
                    )
            }

            Spacer(minLength: designMetrics.spacing.control)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .batchSurfaceInset()
        .batchSurface()
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
