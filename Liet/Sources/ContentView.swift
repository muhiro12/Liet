import MHPlatform
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var resizeModel: BatchImageHomeModel
    @State private var backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    @State private var selectedFeature: BatchFeatureKind?
    @State private var resizeSelectedItems: [PhotosPickerItem]
    @State private var backgroundRemovalSelectedItems: [PhotosPickerItem]
    @State private var columnVisibility: NavigationSplitViewVisibility
    @State private var preferredCompactColumn: NavigationSplitViewColumn

    var body: some View {
        @Bindable var resizeModel = resizeModel
        @Bindable var backgroundRemovalModel = backgroundRemovalModel

        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ) {
            ContentSidebarView(
                selectedFeature: selectedFeature,
                resizeModel: resizeModel,
                backgroundRemovalModel: backgroundRemovalModel,
                resizeSelectedItems: $resizeSelectedItems,
                backgroundRemovalSelectedItems: $backgroundRemovalSelectedItems,
                reviewSelection: showImportedPreview,
                selectFeature: selectFeature,
                backToChooser: showFeatureChooser
            )
        } detail: {
            ContentDetailView(
                selectedFeature: selectedFeature,
                resizeModel: resizeModel,
                backgroundRemovalModel: backgroundRemovalModel,
                backToSettings: showSidebarColumn
            )
        }
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

    init(
        resizeModel: BatchImageHomeModel = .init(),
        backgroundRemovalModel: BatchBackgroundRemovalHomeModel = .init(),
        selectedFeature: BatchFeatureKind? = nil,
        resizeSelectedItems: [PhotosPickerItem] = [],
        backgroundRemovalSelectedItems: [PhotosPickerItem] = [],
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    ) {
        _resizeModel = State(initialValue: resizeModel)
        _backgroundRemovalModel = State(initialValue: backgroundRemovalModel)
        _selectedFeature = State(initialValue: selectedFeature)
        _resizeSelectedItems = State(initialValue: resizeSelectedItems)
        _backgroundRemovalSelectedItems = State(
            initialValue: backgroundRemovalSelectedItems
        )
        _columnVisibility = State(initialValue: columnVisibility)
        _preferredCompactColumn = State(initialValue: preferredCompactColumn)
    }
}

private extension ContentView {
    func selectFeature(
        _ feature: BatchFeatureKind
    ) {
        selectedFeature = feature
        showSidebarColumn()
    }

    func showFeatureChooser() {
        selectedFeature = nil
        showSidebarColumn()
    }

    func showImportedPreview() {
        switch selectedFeature {
        case .resizeImages:
            guard !resizeModel.importedImages.isEmpty else {
                return
            }
        case .removeBackground:
            guard !backgroundRemovalModel.importedImages.isEmpty else {
                return
            }
        case nil:
            return
        }

        showDetailColumn()
    }

    func showDetailColumn() {
        columnVisibility = .automatic
        preferredCompactColumn = .detail
    }

    func showSidebarColumn() {
        columnVisibility = .automatic
        preferredCompactColumn = .sidebar
    }
}

#Preview {
    ContentView()
        .mhAppRuntimeEnvironment(ContentViewPreviewFactory.previewRuntime)
}
