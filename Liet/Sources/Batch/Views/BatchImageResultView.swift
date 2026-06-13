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
                filenameStem: filenameStemBinding(for:),
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
        .alert(
            "Error",
            isPresented: errorPresented
        ) {
            Button("OK", role: .cancel) {
                model.activeError = nil
            }
        } message: {
            if let activeError = model.activeError {
                errorText(for: activeError)
            }
        }
        .fullScreenCover(item: $activePreviewItem) { item in
            BatchImageFullscreenPreviewView(
                item: item
            )
        }
    }
}

private extension BatchImageResultView {
    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.activeError != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.activeError = nil
                }
            }
        )
    }

    func openPreview(
        for image: ProcessedBatchImage
    ) {
        activePreviewItem = .init(
            processedImage: image,
            displayName: model.resolvedFilename(for: image)
        )
    }

    func errorText(
        for error: any Error
    ) -> Text {
        if let batchError = error as? BatchImageServiceError {
            return batchServiceErrorText(for: batchError)
        }

        return Text(error.localizedDescription)
    }

    func batchServiceErrorText(
        for error: BatchImageServiceError
    ) -> Text {
        switch error {
        case .failedToCreateArchive:
            Text("Couldn't create the ZIP archive.")
        case .failedToCreateExportFolder:
            Text("Couldn't create the export folder.")
        case .failedToLoadImageData:
            Text("Couldn't load one of the selected images.")
        case .failedToCreateImageSource:
            Text("Couldn't read one of the selected images.")
        case .failedToReadImageProperties:
            Text("Couldn't inspect one of the selected images.")
        case .failedToCreateThumbnail:
            Text("Couldn't generate an image preview.")
        case .failedToEncodeImage:
            Text("Couldn't write one of the processed images.")
        case .failedToRemoveBackground:
            Text("Couldn't remove the background from one of the images.")
        case .photoLibraryPermissionDenied:
            Text("Photo Library access is required to save images.")
        case .photoLibrarySaveFailed:
            Text("Couldn't save the processed images to Photos.")
        }
    }

    func filenameStemBinding(
        for image: ProcessedBatchImage
    ) -> Binding<String> {
        Binding(
            get: {
                model.editableFilenameStem(for: image)
            },
            set: { newValue in
                model.setEditableFilenameStem(
                    newValue,
                    for: image
                )
            }
        )
    }
}
