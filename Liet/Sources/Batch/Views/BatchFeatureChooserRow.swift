import MHDesign
import SwiftUI

struct BatchFeatureChooserRow: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    let feature: BatchFeatureKind
    let selectFeature: (BatchFeatureKind) -> Void

    var body: some View {
        Button {
            selectFeature(feature)
        } label: {
            HStack(
                alignment: .center,
                spacing: designMetrics.spacing.control
            ) {
                Image(systemName: feature.systemImage)
                    .font(.title3.weight(.semibold))
                    .frame(width: BatchDesign.FeatureChooser.featureIconWidth)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: designMetrics.spacing.inline
                ) {
                    title
                        .font(.headline)
                    subtitle
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: designMetrics.spacing.control)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var title: Text {
        switch feature {
        case .resizeImages:
            Text("Resize Images")
        case .removeBackground:
            Text("Remove Background")
        }
    }

    var subtitle: Text {
        switch feature {
        case .resizeImages:
            Text("Apply one shared output size, compression, and naming setup to the full batch.")
        case .removeBackground:
            Text("Create transparent PNG copies with one shared background-removal setup.")
        }
    }
}
