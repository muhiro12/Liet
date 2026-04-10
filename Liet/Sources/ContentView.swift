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
            sidebarView(
                resizeModel: resizeModel,
                backgroundRemovalModel: backgroundRemovalModel
            )
        } detail: {
            detailView(
                resizeModel: resizeModel,
                backgroundRemovalModel: backgroundRemovalModel
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
    @ViewBuilder
    func sidebarView(
        resizeModel: BatchImageHomeModel,
        backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    ) -> some View {
        switch selectedFeature {
        case .resizeImages:
            BatchImageHomeView(
                model: resizeModel,
                selectedItems: $resizeSelectedItems,
                reviewSelection: showImportedPreview,
                backToChooser: showFeatureChooser
            )
        case .removeBackground:
            BatchBackgroundRemovalHomeView(
                model: backgroundRemovalModel,
                selectedItems: $backgroundRemovalSelectedItems,
                reviewSelection: showImportedPreview,
                backToChooser: showFeatureChooser
            )
        case nil:
            BatchFeatureChooserView(selectFeature: selectFeature)
        }
    }

    @ViewBuilder
    func detailView(
        resizeModel: BatchImageHomeModel,
        backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    ) -> some View {
        switch selectedFeature {
        case .resizeImages:
            resizeDetailView(
                resizeModel: resizeModel
            )
        case .removeBackground:
            backgroundRemovalDetailView(
                backgroundRemovalModel: backgroundRemovalModel
            )
        case nil:
            BatchFeatureEmptyDetailView()
        }
    }

    @ViewBuilder
    func resizeDetailView(
        resizeModel: BatchImageHomeModel
    ) -> some View {
        if let resultModel = resizeModel.resultModel {
            BatchImageResultView(
                model: resultModel,
                backToSettings: showSidebarColumn
            )
        } else if resizeModel.importedImages.isEmpty {
            BatchImageEmptyDetailView(
                backToSettings: showSidebarColumn
            )
        } else {
            BatchImageImportedPreviewView(
                importedImages: resizeModel.importedImages,
                summaryText: resizeModel.selectionSummaryText,
                projectedPixelSizeResolver: resizeModel.projectedPixelSize(for:),
                backToSettings: showSidebarColumn
            )
        }
    }

    @ViewBuilder
    func backgroundRemovalDetailView(
        backgroundRemovalModel: BatchBackgroundRemovalHomeModel
    ) -> some View {
        if let resultModel = backgroundRemovalModel.resultModel {
            BatchImageResultView(
                model: resultModel,
                backToSettings: showSidebarColumn
            )
        } else if backgroundRemovalModel.importedImages.isEmpty {
            BatchImageEmptyDetailView(
                backToSettings: showSidebarColumn
            )
        } else {
            BatchImageImportedPreviewView(
                importedImages: backgroundRemovalModel.importedImages,
                summaryText: backgroundRemovalModel.selectionSummaryText,
                projectedPixelSizeResolver: backgroundRemovalModel.projectedPixelSize(for:),
                backToSettings: showSidebarColumn
            )
        }
    }

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
