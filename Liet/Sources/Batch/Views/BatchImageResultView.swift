import SwiftUI
import TipKit

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

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let processedResultsTip = ProcessedResultsTip()
    private let saveDestinationTip = SaveDestinationTip()

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
                saveSection()
            }
            .padding(Layout.contentPadding)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let backToSettings,
               horizontalSizeClass == .compact {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back to Settings") {
                        backToSettings()
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Show Tips Again") {
                    model.replayTips()
                }
            }
        }
        .fileExporter(
            isPresented: $model.isExportingFiles,
            documents: model.exportDocuments,
            contentTypes: BatchImageProcessor.exportContentTypes
        ) { result in
            model.handleFileExportCompletion(result)
        } onCancellation: {
            model.handleFileExportCancellation()
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

    func summarySection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            resultTitleText(model.processedImages.count)
                .font(.title2.weight(.semibold))

            resultDetailMessages()

            if let saveFeedback = model.saveFeedback {
                saveFeedbackText(saveFeedback)
                    .font(.subheadline.weight(.medium))
            }

            TipView(processedResultsTip)
        }
    }

    func previewsSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Processed images")
                .font(.title3.weight(.semibold))

            Text("Edit each export name before saving if needed.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: Layout.gridSpacing
            ) {
                ForEach(model.processedImages) { image in
                    ProcessedBatchImageTile(
                        image: image,
                        resolvedFilename: model.resolvedFilename(for: image),
                        filenameStem: filenameStemBinding(for: image)
                    )
                }
            }
        }
    }

    func saveSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Save")
                .font(.title3.weight(.semibold))

            Button("Save to Files") {
                model.beginFileExport()
            }
            .buttonStyle(.borderedProminent)
            .popoverTip(
                saveDestinationTip,
                arrowEdge: .top
            )

            Button {
                Task {
                    await model.saveToPhotos()
                }
            } label: {
                if model.isSavingToPhotos {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Save to Photos")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .disabled(model.isSavingToPhotos)
        }
    }

    @ViewBuilder
    func resultDetailMessages() -> some View {
        if model.failureCount > 0 {
            resultFailureText(model.failureCount)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }

        if model.jpegFallbackCount > 0 {
            jpegFallbackText(model.jpegFallbackCount)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }

        if model.ignoredCompressionCount > 0 {
            pngCompressionText(model.ignoredCompressionCount)
                .font(.footnote)
                .foregroundStyle(.secondary)
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
            Text("1 image couldn't be processed.")
        } else {
            Text("\(count) images couldn't be processed.")
        }
    }

    func jpegFallbackText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("1 image was exported as JPEG because the original format couldn't be preserved.")
        } else {
            Text("\(count) images were exported as JPEG because the original format couldn't be preserved.")
        }
    }

    func pngCompressionText(
        _ count: Int
    ) -> Text {
        if count == 1 {
            Text("PNG ignores the compression quality setting.")
        } else {
            Text("PNG images ignore the compression quality setting.")
        }
    }

    func saveFeedbackText(
        _ feedback: BatchImageResultModel.SaveFeedback
    ) -> Text {
        switch feedback {
        case let .exportedFiles(count):
            if count == 1 {
                Text("Exported 1 image to Files.")
            } else {
                Text("Exported \(count) images to Files.")
            }
        case let .savedToPhotos(count):
            if count == 1 {
                Text("Saved 1 image to Photos.")
            } else {
                Text("Saved \(count) images to Photos.")
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
