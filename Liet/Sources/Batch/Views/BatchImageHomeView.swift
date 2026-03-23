import LietLibrary
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageHomeView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let cardSpacing = 16.0
        static let gridSpacing = 12.0
        static let thumbnailColumnMinimum = 110.0
        static let controlSpacing = 12.0
    }

    private enum Copy {
        static let importTitle = "Select images"
        static let importMessage =
            "Choose multiple photos, then apply one resize and compression setting to all of them."
        static let loadingMessage = "Loading images..."
        static let settingsTitle = "Settings"
        static let longEdgeTitle = "Long edge (px)"
        static let longEdgePlaceholder = "1920"
        static let longEdgeDetail = "Smaller images keep their original size."
        static let compressionTitle = "Compression"
        static let compressionDetail = "PNG keeps its format and ignores the compression quality setting."
        static let processTitle = "Process Images"
        static let processDetail = "Processed images are always written as new files."
        static let clearTitle = "Clear"
    }

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    @FocusState private var isLongEdgeFieldFocused: Bool

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()

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

                Button("Done") {
                    isLongEdgeFieldFocused = false
                }
            }
        }
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await model.importPhotos(from: newValue)
            }
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
            Text(Copy.settingsTitle)
                .font(.title3.weight(.semibold))
            longEdgeSection()

            if !model.importedImages.isEmpty {
                TipView(processingSetupTip)
            }

            compressionSection()
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
            Text(Copy.importTitle)
                .font(.title2.weight(.semibold))
            Text(Copy.importMessage)
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
                Button(Copy.clearTitle) {
                    selectedItems = []
                    model.clearSelection()
                }
            }
        }
    }

    @ViewBuilder
    func importFeedback() -> some View {
        if model.isImporting {
            ProgressView(Copy.loadingMessage)
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

    func longEdgeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text(Copy.longEdgeTitle)
                .font(.subheadline.weight(.medium))

            TextField(
                Copy.longEdgePlaceholder,
                text: $model.resizeLongEdgeText
            )
            .focused($isLongEdgeFieldFocused)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)

            Text(Copy.longEdgeDetail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func compressionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text(Copy.compressionTitle)
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

            Text(Copy.compressionDetail)
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
                Text(Copy.processTitle)
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
        Text(Copy.processDetail)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
