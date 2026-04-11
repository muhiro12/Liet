import MHDesign
import SwiftUI

struct BatchFeatureChooserView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let selectFeature: (BatchFeatureKind) -> Void

    var body: some View {
        List {
            Section {
                VStack(
                    alignment: .leading,
                    spacing: designMetrics.spacing.inline
                ) {
                    Text("Choose a feature")
                        .font(.headline)
                    Text("Resize a whole batch or create transparent PNG copies with separate settings.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, designMetrics.spacing.inline)
            }

            Section {
                ForEach(BatchFeatureKind.allCases) { feature in
                    featureButton(feature)
                }
            }

            Section {
                AdvertisementSection(.small)
            }
        }
        .listStyle(.insetGrouped)
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
            alignment: .center,
            spacing: designMetrics.layout.rowAccessorySpacing
        ) {
            Image(systemName: feature.systemImage)
                .font(.title3.weight(.semibold))
                .frame(width: BatchDesign.FeatureChooser.featureIconWidth)
                .foregroundStyle(.tint)

            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.inline
            ) {
                featureTitle(feature)
                    .font(.headline)
                featureSubtitle(feature)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: designMetrics.spacing.control)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
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
