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

    private enum ResizeField: Hashable {
        case width
        case height
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
                model.activeAlert = nil
            }
        } message: {
            if let activeAlert = model.activeAlert {
                alertText(for: activeAlert)
            }
        }
    }
}

private extension BatchImageHomeView {
    var errorPresented: Binding<Bool> {
        Binding(
            get: {
                model.activeAlert != nil
            },
            set: { isPresented in
                if !isPresented {
                    model.activeAlert = nil
                }
            }
        )
    }

    var resizeWidthBinding: Binding<String> {
        Binding(
            get: {
                model.resizeWidthText
            },
            set: { newValue in
                model.setResizeWidthText(newValue)
            }
        )
    }

    var resizeHeightBinding: Binding<String> {
        Binding(
            get: {
                model.resizeHeightText
            },
            set: { newValue in
                model.setResizeHeightText(newValue)
            }
        )
    }

    var keepsAspectRatioBinding: Binding<Bool> {
        Binding(
            get: {
                model.keepsAspectRatio
            },
            set: { newValue in
                model.setKeepsAspectRatio(newValue)
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

            if model.showsCompressionSection {
                compressionSection()
            }
        }
    }

    func resizeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            Text("Output size")
                .font(.subheadline.weight(.medium))

            dimensionInputSection(
                title: Text("Width (px)"),
                placeholder: "1920",
                text: resizeWidthBinding,
                focusField: .width
            )

            dimensionInputSection(
                title: Text("Height (px)"),
                placeholder: "1080",
                text: resizeHeightBinding,
                focusField: .height
            )

            Toggle(
                "Keep aspect ratio",
                isOn: keepsAspectRatioBinding
            )

            if model.keepsAspectRatio {
                Text("Images stay within the target box and smaller images keep their original size.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                exactSizeSection()
            }
        }
    }

    private func dimensionInputSection(
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
        }
    }

    func exactSizeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Method")
                    .font(.subheadline.weight(.medium))

                Picker(selection: $model.exactResizeStrategy) {
                    Text("Stretch")
                        .tag(BatchExactResizeStrategy.stretch)
                    Text("Contain")
                        .tag(BatchExactResizeStrategy.contain)
                    Text("Crop")
                        .tag(BatchExactResizeStrategy.coverCrop)
                } label: {
                    Text("Method")
                }
                .pickerStyle(.segmented)

                Text(
                    """
                    Stretch fills the canvas exactly. Contain keeps the whole image inside the canvas. \
                    Crop fills the canvas by trimming from the center.
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
            selectedImageCountText(model.importedImages.count)
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

        if let importFailureCount = model.importFailureCount {
            importFailureText(importFailureCount)
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
                Text("Off")
                    .tag(BatchImageCompression.off)
                Text("High")
                    .tag(BatchImageCompression.high)
                Text("Medium")
                    .tag(BatchImageCompression.medium)
                Text("Low")
                    .tag(BatchImageCompression.low)
            }
            .pickerStyle(.segmented)

            if model.showsMixedCompressionHint {
                Text("PNG images keep their format and ignore the compression setting.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    func processButton() -> some View {
        Button {
            Task {
                model.processImages()
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
        Text("Processed images are always written as new files and default to the original name with a Liet suffix.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
