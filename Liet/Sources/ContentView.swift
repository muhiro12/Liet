import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var model: BatchImageHomeModel = .init()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    var body: some View {
        @Bindable var model = model

        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredCompactColumn
        ) {
            BatchImageHomeView(
                model: model,
                selectedItems: $selectedItems,
                reviewSelection: showImportedPreview
            )
        } detail: {
            detailView()
        }
        .onChange(of: model.resultModel?.id) { _, resultID in
            guard resultID != nil else {
                return
            }

            showDetailColumn()
        }
        .onChange(of: model.importedImages.count) { _, importedImageCount in
            guard importedImageCount == 0 else {
                return
            }

            showSidebarColumn()
        }
    }
}

private extension ContentView {
    @ViewBuilder
    func detailView() -> some View {
        if let resultModel = model.resultModel {
            BatchImageResultView(
                model: resultModel,
                backToSettings: showSidebarColumn
            )
        } else if model.importedImages.isEmpty {
            BatchImageEmptyDetailView(
                backToSettings: showSidebarColumn
            )
        } else {
            BatchImageImportedPreviewView(
                importedImages: model.importedImages,
                backToSettings: showSidebarColumn
            )
        }
    }

    func showImportedPreview() {
        guard !model.importedImages.isEmpty else {
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
}
