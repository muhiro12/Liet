import LietLibrary
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageHomeView: View {
    private enum Layout {
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let cardSpacing = 16.0
        static let cardPadding = 18.0
        static let cardCornerRadius = 20.0
        static let controlSpacing = 12.0
        static let buttonStackSpacing = 10.0
        static let stepBadgePadding = 10.0
    }

    private enum ResizeField: Hashable {
        case referencePixels
        case width
        case height
    }

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    let reviewSelection: (() -> Void)?
    @FocusState private var focusedResizeField: ResizeField?

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Layout.contentSpacing
            ) {
                importStepSection()

                if model.showsOutputSizeStep {
                    outputSizeStepSection()
                        .transition(stepTransition)
                }

                if model.showsExportSetupStep {
                    exportSetupStepSection()
                        .transition(stepTransition)
                }
            }
            .padding(Layout.contentPadding)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
        .animation(
            .snappy(duration: 0.32, extraBounce: 0),
            value: model.showsOutputSizeStep
        )
        .animation(
            .snappy(duration: 0.32, extraBounce: 0),
            value: model.showsExportSetupStep
        )
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

    var referencePixelsBinding: Binding<String> {
        Binding(
            get: {
                model.referencePixelsText
            },
            set: { newValue in
                model.setReferencePixelsText(newValue)
            }
        )
    }

    var referenceDimensionBinding: Binding<BatchResizeReferenceDimension> {
        Binding(
            get: {
                model.referenceDimension
            },
            set: { newValue in
                model.setReferenceDimension(newValue)
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
        stepCard(
            number: 1,
            title: "Import"
        ) {
            importHeader()
            selectionButton()
            selectionStatusRow()
            importFeedback()
            reviewSelectionButton()
        }
    }

    func outputSizeStepSection() -> some View {
        stepCard(
            number: 2,
            title: "Output Size"
        ) {
            resizeSection()
            savedSettingsSection()
            TipView(processingSetupTip)
        }
    }

    func exportSetupStepSection() -> some View {
        stepCard(
            number: 3,
            title: "Export Setup"
        ) {
            if model.showsCompressionSection {
                compressionSection()
            }

            processButton()
            processDetail()
        }
    }

    func importStepSection() -> some View {
        importSection()
    }

    func resizeSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            Toggle(
                "Keep aspect ratio",
                isOn: keepsAspectRatioBinding
            )

            if model.keepsAspectRatio {
                aspectRatioInputSection()
            } else {
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

                exactSizeSection()
            }
        }
    }

    func aspectRatioInputSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            VStack(
                alignment: .leading,
                spacing: Layout.controlSpacing
            ) {
                Text("Reference edge")
                    .font(.subheadline.weight(.medium))

                Picker("Reference edge", selection: referenceDimensionBinding) {
                    Text("Width")
                        .tag(BatchResizeReferenceDimension.width)
                    Text("Height")
                        .tag(BatchResizeReferenceDimension.height)
                }
                .pickerStyle(.segmented)
            }

            dimensionInputSection(
                title: Text(referencePixelsTitle),
                placeholder: referencePixelsPlaceholder,
                text: referencePixelsBinding,
                focusField: .referencePixels
            )

            Text("Each image keeps its aspect ratio. Liet calculates the other edge for every selected image and never upscales smaller images.")
                .font(.footnote)
                .foregroundStyle(.secondary)
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

    @ViewBuilder
    func reviewSelectionButton() -> some View {
        if let reviewSelection,
           !model.importedImages.isEmpty {
            Button("Review Selection") {
                reviewSelection()
            }
            .buttonStyle(.bordered)
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

    func savedSettingsSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text("Saved Settings")
                .font(.subheadline.weight(.medium))

            Text("Startup uses your saved default settings. Last used settings update automatically whenever the current setup is valid.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            VStack(
                alignment: .leading,
                spacing: Layout.buttonStackSpacing
            ) {
                Button("Apply Default") {
                    model.applyDefaultSettings()
                }
                .buttonStyle(.bordered)
                .disabled(!model.canApplyDefaultSettings)

                Button("Apply Last Used") {
                    model.applyLastUsedSettings()
                }
                .buttonStyle(.bordered)
                .disabled(!model.canApplyLastUsedSettings)

                Button("Save Current as Default") {
                    model.saveCurrentAsDefault()
                }
                .buttonStyle(.bordered)
                .disabled(!model.canSaveCurrentAsDefault)
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

    func stepCard<Content: View>(
        number: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            stepHeader(
                number: number,
                title: title
            )

            content()
        }
        .padding(Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(
                cornerRadius: Layout.cardCornerRadius,
                style: .continuous
            )
            .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: Layout.cardCornerRadius,
                style: .continuous
            )
            .strokeBorder(
                Color.primary.opacity(0.08),
                lineWidth: 1
            )
        }
    }

    func stepHeader(
        number: Int,
        title: String
    ) -> some View {
        HStack(
            spacing: Layout.controlSpacing
        ) {
            Text("Step \(number)")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, Layout.stepBadgePadding)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                )

            Text(title)
                .font(.title3.weight(.semibold))
        }
    }

    var stepTransition: AnyTransition {
        .move(edge: .bottom)
            .combined(with: .opacity)
    }

    var referencePixelsTitle: String {
        switch model.referenceDimension {
        case .width:
            "Width (px)"
        case .height:
            "Height (px)"
        }
    }

    var referencePixelsPlaceholder: String {
        switch model.referenceDimension {
        case .width:
            "1920"
        case .height:
            "1080"
        }
    }
}
