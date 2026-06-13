import SwiftUI

struct ContentDetailView: View {
    let selectedFeature: BatchFeatureKind?
    let resizeModel: BatchImageHomeModel
    let backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    let backToSettings: () -> Void

    var body: some View {
        switch selectedFeature {
        case .resizeImages:
            ContentResizeDetailView(
                model: resizeModel,
                backToSettings: backToSettings
            )
        case .removeBackground:
            ContentBackgroundRemovalDetailView(
                model: backgroundRemovalModel,
                backToSettings: backToSettings
            )
        case nil:
            BatchFeatureEmptyDetailView()
        }
    }
}
