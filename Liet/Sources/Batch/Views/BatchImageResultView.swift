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
                model.errorMessage = nil
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private extension BatchImageResultView {
    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.errorMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.errorMessage = nil
                }
            }
        )
    }

    func summarySection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text(model.titleText)
                .font(.title2.weight(.semibold))

            ForEach(model.detailMessages, id: \.self) { message in
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let saveMessage = model.saveMessage {
                Text(saveMessage)
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

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: Layout.gridSpacing
            ) {
                ForEach(model.processedImages) { image in
                    ProcessedBatchImageTile(image: image)
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
}
