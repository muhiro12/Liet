import PhotosUI
import SwiftUI

struct ContentSidebarView: View {
    let selectedFeature: BatchFeatureKind?
    let resizeModel: BatchImageHomeModel
    let backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    @Binding var resizeSelectedItems: [PhotosPickerItem]
    @Binding var backgroundRemovalSelectedItems: [PhotosPickerItem]
    let reviewSelection: () -> Void
    let selectFeature: (BatchFeatureKind) -> Void
    let backToChooser: () -> Void

    var body: some View {
        switch selectedFeature {
        case .resizeImages:
            BatchImageHomeView(
                model: resizeModel,
                selectedItems: $resizeSelectedItems,
                reviewSelection: reviewSelection,
                backToChooser: backToChooser
            )
        case .removeBackground:
            BatchBackgroundRemovalHomeView(
                model: backgroundRemovalModel,
                selectedItems: $backgroundRemovalSelectedItems,
                reviewSelection: reviewSelection,
                backToChooser: backToChooser
            )
        case nil:
            BatchFeatureChooserView(selectFeature: selectFeature)
        }
    }
}
