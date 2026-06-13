import MHDesign
import SwiftUI
import UniformTypeIdentifiers

struct BatchImageResultView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchImageResultModel
    let backToSettings: (() -> Void)?

    @State private var activePreviewItem: BatchImagePreviewItem?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            BatchImageResultSummarySection(
                processedImageCount: model.processedImages.count,
                failureCount: model.failureCount,
                jpegFallbackCount: model.jpegFallbackCount,
                ignoredCompressionCount: model.ignoredCompressionCount,
                saveFeedback: model.saveFeedback
            )
            AdvertisementSection(.medium)
            BatchProcessedImagesGridSection(
                processedImages: model.processedImages,
                resolvedFilename: { image in
                    model.resolvedFilename(for: image)
                },
                filenameStem: { image in
                    $model[filenameStemFor: image.id]
                },
                openPreview: openPreview(for:)
            )
            BatchImageResultSaveSection(model: model)
        }
        .batchScreen(
            title: nil as Text?,
            subtitle: nil as Text?
        )
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            BatchDetailToolbar(backToSettings: backToSettings) {
                model.replayTips()
            }
        }
        .fileExporter(
            isPresented: $model.isExportingFiles,
            document: model.exportFolderDocument,
            contentType: .folder,
            defaultFilename: model.exportFolderFilenameStem
        ) { result in
            model.handleFileExportCompletion(result)
        }
        .fileExporter(
            isPresented: $model.isExportingArchive,
            document: model.exportArchiveDocument,
            contentType: .zip,
            defaultFilename: model.exportArchiveFilenameStem
        ) { result in
            model.handleArchiveExportCompletion(result)
        }
        .batchImageResultErrorAlert(model: model)
        .fullScreenCover(item: $activePreviewItem) { item in
            BatchImageFullscreenPreviewView(
                item: item
            )
        }
    }
}

private extension BatchImageResultView {
    func openPreview(
        for image: ProcessedBatchImage
    ) {
        activePreviewItem = .init(
            processedImage: image,
            displayName: model.resolvedFilename(for: image)
        )
    }
}
