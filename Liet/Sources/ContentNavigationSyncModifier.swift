import SwiftUI

@MainActor
private struct ContentNavigationSyncModifier: ViewModifier {
    let selectedFeature: BatchFeatureKind?
    let resizeModel: BatchImageHomeModel
    let backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var preferredCompactColumn: NavigationSplitViewColumn

    func body(content: Content) -> some View {
        content
            .onChange(of: resizeModel.resultModel?.id) { _, resultID in
                guard selectedFeature == .resizeImages,
                      resultID != nil else {
                    return
                }

                showDetailColumn()
            }
            .onChange(of: backgroundRemovalModel.resultModel?.id) { _, resultID in
                guard selectedFeature == .removeBackground,
                      resultID != nil else {
                    return
                }

                showDetailColumn()
            }
            .onChange(of: resizeModel.importedImages.count) { _, importedImageCount in
                guard selectedFeature == .resizeImages,
                      importedImageCount == 0 else {
                    return
                }

                showSidebarColumn()
            }
            .onChange(
                of: backgroundRemovalModel.importedImages.count
            ) { _, importedImageCount in
                guard selectedFeature == .removeBackground,
                      importedImageCount == 0 else {
                    return
                }

                showSidebarColumn()
            }
    }
}

private extension ContentNavigationSyncModifier {
    func showDetailColumn() {
        columnVisibility = .automatic
        preferredCompactColumn = .detail
    }

    func showSidebarColumn() {
        columnVisibility = .automatic
        preferredCompactColumn = .sidebar
    }
}

extension View {
    @MainActor
    func contentNavigationSync(
        selectedFeature: BatchFeatureKind?,
        resizeModel: BatchImageHomeModel,
        backgroundRemovalModel: BatchBackgroundRemovalHomeModel,
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        preferredCompactColumn: Binding<NavigationSplitViewColumn>
    ) -> some View {
        modifier(
            ContentNavigationSyncModifier(
                selectedFeature: selectedFeature,
                resizeModel: resizeModel,
                backgroundRemovalModel: backgroundRemovalModel,
                columnVisibility: columnVisibility,
                preferredCompactColumn: preferredCompactColumn
            )
        )
    }
}
