import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var model: BatchImageHomeModel
    @State private var selectedItems: [PhotosPickerItem]
    @State private var columnVisibility: NavigationSplitViewVisibility
    @State private var preferredCompactColumn: NavigationSplitViewColumn

    init(
        model: BatchImageHomeModel = .init(),
        selectedItems: [PhotosPickerItem] = [],
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    ) {
        _model = State(initialValue: model)
        _selectedItems = State(initialValue: selectedItems)
        _columnVisibility = State(initialValue: columnVisibility)
        _preferredCompactColumn = State(initialValue: preferredCompactColumn)
    }

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
                settings: model.settings,
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

#Preview("iPhone Imported") {
    ContentView(
        model: .previewImported(),
        preferredCompactColumn: .detail
    )
}

#Preview("iPhone Result") {
    ContentView(
        model: .previewProcessed(),
        preferredCompactColumn: .detail
    )
}

#Preview(
    "iPad Imported",
    traits: .fixedLayout(width: 1194, height: 834)
) {
    ContentView(
        model: .previewImported()
    )
}

#Preview(
    "iPad Result",
    traits: .fixedLayout(width: 1194, height: 834)
) {
    ContentView(
        model: .previewProcessed()
    )
}

private extension BatchImageHomeModel {
    static func previewImported() -> BatchImageHomeModel {
        let model: BatchImageHomeModel = .init(
            settingsStore: .inMemory()
        )
        model.importedImages = ContentViewPreviewFactory.importedImages
        model.setReferencePixelsText("1080")
        return model
    }

    static func previewProcessed() -> BatchImageHomeModel {
        let model = previewImported()
        model.resultModel = .init(
            outcome: .init(
                processedImages: ContentViewPreviewFactory.processedImages,
                failureCount: 0,
                jpegFallbackCount: 0,
                ignoredCompressionCount: 0
            )
        )
        return model
    }
}

private enum ContentViewPreviewFactory {
    private static let temporaryDirectory = FileManager.default.temporaryDirectory

    static let importedImages: [ImportedBatchImage] = [
        makeImportedImage(
            filename: "preview-landscape.jpg",
            format: .jpeg,
            size: .init(width: 1_600, height: 900),
            selectionIndex: 1,
            color: .systemTeal
        ),
        makeImportedImage(
            filename: "preview-portrait.png",
            format: .png,
            size: .init(width: 900, height: 1_600),
            selectionIndex: 2,
            color: .systemOrange
        )
    ]

    static let processedImages: [ProcessedBatchImage] = [
        makeProcessedImage(
            filename: "preview-landscape-Liet.jpg",
            format: .jpeg,
            originalFormat: .jpeg,
            size: .init(width: 1_080, height: 608),
            color: .systemTeal
        ),
        makeProcessedImage(
            filename: "preview-portrait-Liet.png",
            format: .png,
            originalFormat: .png,
            size: .init(width: 1_080, height: 1_920),
            color: .systemOrange
        )
    ]

    static func makeImportedImage(
        filename: String,
        format: ImageFileFormat,
        size: CGSize,
        selectionIndex: Int,
        color: UIColor
    ) -> ImportedBatchImage {
        let url = temporaryDirectory.appendingPathComponent(filename)
        let previewImage = makePreviewImage(
            size: size,
            color: color
        )

        return .init(
            sourceURL: url,
            originalFilename: filename,
            originalFormat: format,
            pixelSize: size,
            previewImage: previewImage,
            selectionIndex: selectionIndex
        )
    }

    static func makeProcessedImage(
        filename: String,
        format: ImageFileFormat,
        originalFormat: ImageFileFormat,
        size: CGSize,
        color: UIColor
    ) -> ProcessedBatchImage {
        let url = temporaryDirectory.appendingPathComponent(filename)
        let previewImage = makePreviewImage(
            size: size,
            color: color
        )

        return .init(
            sourceID: .init(),
            outputURL: url,
            outputFilename: filename,
            outputFormat: format,
            originalFormat: originalFormat,
            pixelSize: size,
            previewImage: previewImage,
            usedJPEGFallback: false,
            ignoredCompressionSetting: false
        )
    }

    static func makePreviewImage(
        size: CGSize,
        color: UIColor
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true

        return UIGraphicsImageRenderer(
            size: size,
            format: format
        ).image { context in
            color.setFill()
            context.fill(
                CGRect(
                    origin: .zero,
                    size: size
                )
            )
        }
    }
}
