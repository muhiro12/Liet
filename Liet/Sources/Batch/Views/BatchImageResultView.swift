import MHDesign
import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct BatchImageResultView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchImageResultModel
    let backToSettings: (() -> Void)?

    @State private var activePreviewItem: BatchImagePreviewItem?

    private let processedResultsTip = ProcessedResultsTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            summarySection()
            AdvertisementSection(.medium)
            previewsSection()
            saveSection()
        }
        .batchScreen(
            title: nil as Text?,
            subtitle: nil as Text?
        )
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let backToSettings,
               horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    BatchToolbarIconButton(
                        systemImage: "sidebar.leading",
                        accessibilityLabel: "Back to Settings"
                    ) {
                        backToSettings()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                BatchToolbarIconButton(
                    systemImage: "questionmark.circle",
                    accessibilityLabel: "Show Tips Again"
                ) {
                    model.replayTips()
                }
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
    var columns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: BatchDesign.Grid.thumbnailColumnMinimum),
                spacing: designMetrics.spacing.control
            )
        ]
    }

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

    var hasResultChips: Bool {
        model.failureCount > 0 ||
            model.jpegFallbackCount > 0 ||
            model.ignoredCompressionCount > 0 ||
            model.saveFeedback != nil
    }

    @ViewBuilder
    func summarySection() -> some View {
        if hasResultChips {
            BatchSection(
                title: resultTitleText(model.processedImages.count)
            ) {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(
                        spacing: designMetrics.spacing.control
                    ) {
                        resultDetailChips()
                    }
                }
            }
            .popoverTip(
                processedResultsTip,
                arrowEdge: .top
            )
        } else {
            resultTitleText(model.processedImages.count)
                .batchTextStyle(.screenTitle)
                .popoverTip(
                    processedResultsTip,
                    arrowEdge: .top
                )
        }
    }

    func previewsSection() -> some View {
        BatchSection(title: Text("Processed images")) {
            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ) {
                ForEach(model.processedImages) { image in
                    ProcessedBatchImageTile(
                        image: image,
                        imageTapAction: {
                            activePreviewItem = .init(
                                processedImage: image,
                                displayName: model.resolvedFilename(for: image)
                            )
                        },
                        resolvedFilename: model.resolvedFilename(for: image),
                        filenameStem: filenameStemBinding(for: image)
                    )
                }
            }
        }
    }

    func saveSection() -> some View {
        BatchSection(title: Text("Save")) {
            BatchImageResultSaveSectionView(model: model)
        }
    }

    @ViewBuilder
    func resultDetailChips() -> some View {
        if model.failureCount > 0 {
            BatchStatusChip(
                text: resultFailureText(model.failureCount),
                systemImage: "exclamationmark.triangle.fill",
                tone: .warning
            )
        }

        if model.jpegFallbackCount > 0 {
            BatchStatusChip(
                text: jpegFallbackText(model.jpegFallbackCount),
                systemImage: "arrow.triangle.2.circlepath",
                tone: .warning
            )
        }

        if model.ignoredCompressionCount > 0 {
            BatchStatusChip(
                text: pngCompressionText(model.ignoredCompressionCount),
                systemImage: "photo",
                tone: .neutral
            )
        }

        if let saveFeedback = model.saveFeedback {
            BatchStatusChip(
                text: saveFeedbackText(saveFeedback),
                systemImage: "checkmark.circle.fill",
                tone: .success
            )
        }
    }

    func resultTitleText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image ready")
        } else {
            Text("\(count) images ready")
        }
    }

    func resultFailureText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 failed")
        } else {
            Text("\(count) failed")
        }
    }

    func jpegFallbackText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 JPEG fallback")
        } else {
            Text("\(count) JPEG fallback")
        }
    }

    func pngCompressionText(
        _: Int
    ) -> Text {
        Text("PNG output ignored compression")
    }

    func saveFeedbackText(
        _ feedback: BatchImageResultModel.SaveFeedback
    ) -> Text {
        switch feedback {
        case .exportedArchive:
            Text("ZIP saved to Files")
        case let .exportedFiles(count):
            if count == 1 {
                Text("1 saved to Files")
            } else {
                Text("\(count) saved to Files")
            }
        case let .savedToPhotos(count):
            if count == 1 {
                Text("1 saved to Photos")
            } else {
                Text("\(count) saved to Photos")
            }
        }
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
