import LietLibrary
import PhotosUI
import SwiftUI
import TipKit

// swiftlint:disable closure_body_length

struct BatchImageHomeView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let cardSpacing = 16.0
        static let gridSpacing = 12.0
        static let thumbnailColumnMinimum = 110.0
        static let controlSpacing = 12.0
    }

    private enum ResizeField: Hashable {
        case longEdge
        case shortEdge
    }

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    @FocusState private var focusedResizeField: ResizeField?

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()

    private let columns = [
        GridItem(.adaptive(minimum: Layout.thumbnailColumnMinimum), spacing: Layout.gridSpacing)
    ]

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                importSection()
                settingsSection()
                actionSection()
            }
            .padding(Layout.contentPadding)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Show Tips Again") {
                    model.replayTips()
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") { focusedResizeField = nil }
            }
        }
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await model.importPhotos(from: newValue)
            }
        }
        .alert("Error", isPresented: errorPresented) {
            Button("OK", role: .cancel) {
                model.errorMessage = nil
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private extension BatchImageHomeView {
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

    func importSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            importHeader()
            selectionButton()
            selectionStatusRow()
            importFeedback()
            importedImageGrid()
        }
    }

    func settingsSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            Text("Settings")
                .font(.title3.weight(.semibold))

            resizeSection()

            if !model.importedImages.isEmpty {
                TipView(processingSetupTip)
            }

            compressionSection()
        }
    }

    func resizeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Resize mode")
                    .font(.subheadline.weight(.medium))

                Picker(selection: $model.resizeModeSelection) {
                    Text("Long edge")
                        .tag(BatchImageHomeModel.ResizeInputMode.longEdge)
                    Text("Short edge")
                        .tag(BatchImageHomeModel.ResizeInputMode.shortEdge)
                    Text("Exact size")
                        .tag(BatchImageHomeModel.ResizeInputMode.exactSize)
                } label: {
                    Text("Resize mode")
                }
                .pickerStyle(.segmented)
            }

            if model.isLongEdgeMode {
                edgeInputSection(
                    title: Text("Long edge (px)"),
                    placeholder: "1920",
                    text: $model.resizeLongEdgeText,
                    focusField: .longEdge
                )
            }

            if model.isShortEdgeMode {
                edgeInputSection(
                    title: Text("Short edge (px)"),
                    placeholder: "1080",
                    text: $model.resizeShortEdgeText,
                    focusField: .shortEdge
                )
            }

            if model.isExactSizeMode {
                exactSizeSection()
            }
        }
    }

    private func edgeInputSection(
        title: Text,
        placeholder: String,
        text: Binding<String>,
        focusField: ResizeField
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            title
                .font(.subheadline.weight(.medium))

            TextField(placeholder, text: text)
                .focused($focusedResizeField, equals: focusField)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            Text("Smaller images keep their original size.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func exactSizeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            edgeInputSection(
                title: Text("Long edge (px)"),
                placeholder: "1920",
                text: $model.resizeLongEdgeText,
                focusField: .longEdge
            )

            edgeInputSection(
                title: Text("Short edge (px)"),
                placeholder: "1080",
                text: $model.resizeShortEdgeText,
                focusField: .shortEdge
            )

            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Method")
                    .font(.subheadline.weight(.medium))

                Picker(selection: $model.exactResizeStrategy) {
                    Text("Contain")
                        .tag(BatchExactResizeStrategy.contain)
                    Text("Cover Crop")
                        .tag(BatchExactResizeStrategy.coverCrop)
                } label: {
                    Text("Method")
                }
                .pickerStyle(.segmented)

                Text(
                    """
                    Contain keeps the whole image in the target canvas. \
                    Cover Crop fills the canvas by cropping from the center.
                    """
                )
                .font(.footnote)
                .foregroundStyle(.secondary)

                Text("Contain may leave padding when the image and target aspect ratios differ.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    func actionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            processButton()
            processDetail()
        }
    }

    func importHeader() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Select images")
                .font(.title2.weight(.semibold))
            Text("Choose multiple photos, then apply one resize and compression setting to all of them.")
                .foregroundStyle(.secondary)
        }
    }

    func selectionButton() -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: nil,
            matching: .images,
            preferredItemEncoding: .current
        ) {
            Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .popoverTip(
            selectImagesTip,
            arrowEdge: .top
        )
    }

    func selectionStatusRow() -> some View {
        HStack {
            Text(model.selectedImageCountText)
                .font(.subheadline.weight(.medium))

            Spacer()

            if !model.importedImages.isEmpty {
                Button("Clear") {
                    selectedItems = []
                    model.clearSelection()
                }
            }
        }
    }

    @ViewBuilder
    func importFeedback() -> some View {
        if model.isImporting {
            ProgressView("Loading images...")
        }

        if let importMessage = model.importMessage {
            Text(importMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    func importedImageGrid() -> some View {
        if !model.importedImages.isEmpty {
            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: Layout.gridSpacing
            ) {
                ForEach(model.importedImages) { image in
                    ImportedBatchImageTile(image: image)
                }
            }
        }
    }

    func compressionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Compression")
                .font(.subheadline.weight(.medium))

            Picker("Compression", selection: $model.compression) {
                Text("High")
                    .tag(BatchImageCompression.high)
                Text("Medium")
                    .tag(BatchImageCompression.medium)
                Text("Low")
                    .tag(BatchImageCompression.low)
            }
            .pickerStyle(.segmented)

            Text("PNG keeps its format and ignores the compression quality setting.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func processButton() -> some View {
        Button {
            Task {
                await model.processImages()
            }
        } label: {
            if model.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Process Images")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(!model.canProcess)
        .popoverTip(
            runProcessingTip,
            arrowEdge: .top
        )
    }

    func processDetail() -> some View {
        Text("Processed images are always written as new files.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

// swiftlint:enable closure_body_length
