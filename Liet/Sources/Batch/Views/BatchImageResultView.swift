import SwiftUI
import TipKit
import UniformTypeIdentifiers

struct BatchImageResultView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let controlSpacing = 12.0
        static let gridSpacing = 12.0
        static let thumbnailColumnMinimum = 130.0
    }

    @Bindable var model: BatchImageResultModel
    let backToSettings: (() -> Void)?

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    @State private var activePreviewItem: BatchImagePreviewItem?

    private let processedResultsTip = ProcessedResultsTip()

    private let columns = [
        GridItem(
            .adaptive(minimum: Layout.thumbnailColumnMinimum),
            spacing: Layout.gridSpacing
        )
    ]

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                summarySection()
                previewsSection()
                BatchImageResultSaveSectionView(
                    model: model,
                    controlSpacing: Layout.controlSpacing
                )
            }
            .padding(Layout.contentPadding)
        }
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
            documents: model.exportDocuments,
            contentTypes: BatchImageProcessor.exportContentTypes,
            onCompletion: { result in
                model.handleFileExportCompletion(result)
            },
            onCancellation: {
                model.handleFileExportCancellation()
            }
        )
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

    var hasResultChips: Bool {
        model.failureCount > 0 ||
            model.jpegFallbackCount > 0 ||
            model.ignoredCompressionCount > 0 ||
            model.saveFeedback != nil
    }

    func summarySection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            resultTitleView()

            if hasResultChips {
                ScrollView(
                    .horizontal,
                    showsIndicators: false
                ) {
                    HStack(
                        spacing: Layout.controlSpacing
                    ) {
                        resultDetailChips()
                    }
                }
            }
        }
    }

    func previewsSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Processed images")
                .font(.title3.weight(.semibold))

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: Layout.gridSpacing
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

    func resultTitleView() -> some View {
        resultTitleText(model.processedImages.count)
            .font(.title2.weight(.semibold))
            .popoverTip(
                processedResultsTip,
                arrowEdge: .top
            )
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
        Text("PNG kept original")
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
