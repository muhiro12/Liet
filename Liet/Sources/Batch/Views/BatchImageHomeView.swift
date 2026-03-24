// swiftlint:disable file_length type_contents_order
import LietLibrary
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageHomeView: View {
    private enum Layout {
        static let cardCornerRadius = 20.0
        static let cardPadding = 18.0
        static let cardSpacing = 16.0
        static let contentPadding = 20.0
        static let contentSpacing = 24.0
        static let controlSpacing = 12.0
        static let importStepNumber = 1
        static let processingStepNumber = 2
        static let processStepNumber = 3
        static let processingSpringBlendDuration = 0.12
        static let processingSpringDampingFraction = 0.88
        static let processingSpringResponse = 0.42
        static let sectionTransitionScale = 0.98
        static let stepBadgeFillOpacity = 0.14
        static let stepBadgePadding = 10.0
        static let stepBadgeVerticalPadding = 6.0
        static let stepBorderLineWidth = 1.0
        static let stepBorderOpacity = 0.08
        static let upscalingHint =
            """
            Each image keeps its aspect ratio. Liet calculates the other edge for every \
            selected image and never upscales smaller images.
            """
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
    @Namespace private var processingMorphNamespace

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

                if model.showsProcessingStep {
                    processingStepSection()
                        .transition(processingStepTransition)
                    processStepSection()
                        .transition(processingStepTransition)
                }
            }
            .padding(Layout.contentPadding)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Liet")
        .navigationBarTitleDisplayMode(.large)
        .animation(
            processingAnimation,
            value: model.importedImages.count
        )
        .animation(
            processingAnimation,
            value: model.keepsAspectRatio
        )
        .animation(
            processingAnimation,
            value: model.showsCompressionSection
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Show Tips Again") {
                    model.replayTips()
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedResizeField = nil
                }
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

    var settingsSourceBinding: Binding<BatchImageHomeModel.SettingsSource> {
        Binding(
            get: {
                model.settingsSource
            },
            set: { newValue in
                model.settingsSource = newValue
            }
        )
    }

    func importStepSection() -> some View {
        stepCard(
            number: Layout.importStepNumber,
            title: "Import"
        ) {
            importHeader()
            selectionButton()
            selectionStatusRow()
            importFeedback()
            reviewSelectionButton()
        }
    }

    func processingStepSection() -> some View {
        stepCard(
            number: Layout.processingStepNumber,
            title: "Processing Settings"
        ) {
            settingsSourceSection()
            outputSizeSection()

            if model.showsCompressionSection {
                compressionSection()
                    .transition(optionalProcessingSectionTransition)
            }

            TipView(processingSetupTip)
            userPresetSection()
        }
    }

    func processStepSection() -> some View {
        stepCard(
            number: Layout.processStepNumber,
            title: "Process"
        ) {
            processActionSection()
        }
    }

    func outputSizeSection() -> some View {
        settingsSection(title: "Output Size") {
            resizeSection()
        }
    }

    func settingsSourceSection() -> some View {
        settingsSection(title: "Starting Point") {
            Picker("Starting Point", selection: settingsSourceBinding) {
                Text("Last Used")
                    .tag(BatchImageHomeModel.SettingsSource.lastUsed)
                Text("User Preset")
                    .tag(BatchImageHomeModel.SettingsSource.userPreset)
                    .disabled(!model.hasUserPresetSettings)
                Text("Custom")
                    .tag(BatchImageHomeModel.SettingsSource.custom)
            }
            .pickerStyle(.segmented)

            Text(
                """
                Liet starts from your last used settings. User Preset keeps one setup you save \
                manually. Edit any value to switch to Custom.
                """
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
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

            resizeModeSection()
        }
    }

    @ViewBuilder
    func resizeModeSection() -> some View {
        ZStack(alignment: .topLeading) {
            if model.keepsAspectRatio {
                aspectRatioInputSection()
                    .matchedGeometryEffect(
                        id: "processing.resize.mode",
                        in: processingMorphNamespace
                    )
                    .transition(resizeModeTransition)
            } else {
                exactResizeInputSection()
                    .matchedGeometryEffect(
                        id: "processing.resize.mode",
                        in: processingMorphNamespace
                    )
                    .transition(resizeModeTransition)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

            Text(Layout.upscalingHint)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func exactResizeInputSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
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

    func settingsSection<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            Text(title)
                .font(.subheadline.weight(.medium))

            content()
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
        settingsSection(title: "Compression") {
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

    func userPresetSection() -> some View {
        settingsSection(title: "User Preset") {
            Text(
                "Save the current resize and compression settings to your one reusable user preset."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Button("Save as User Preset") {
                model.saveCurrentAsUserPreset()
            }
            .buttonStyle(.bordered)
            .disabled(!model.canSaveCurrentAsUserPreset)
        }
    }

    func processActionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            processButton()
            processDetail()
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
        Text(
            """
            Processed images are always written as new files and use the original name \
            with a Liet suffix when available.
            """
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    func stepCard<Content: View>(
        number: Int,
        title: LocalizedStringKey,
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
                Color.primary.opacity(Layout.stepBorderOpacity),
                lineWidth: Layout.stepBorderLineWidth
            )
        }
    }

    func stepHeader(
        number: Int,
        title: LocalizedStringKey
    ) -> some View {
        HStack(
            spacing: Layout.controlSpacing
        ) {
            Text("Step \(number)")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, Layout.stepBadgePadding)
                .padding(.vertical, Layout.stepBadgeVerticalPadding)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.accentColor.opacity(Layout.stepBadgeFillOpacity))
                )

            Text(title)
                .font(.title3.weight(.semibold))
        }
    }

    var processingAnimation: Animation {
        .spring(
            response: Layout.processingSpringResponse,
            dampingFraction: Layout.processingSpringDampingFraction,
            blendDuration: Layout.processingSpringBlendDuration
        )
    }

    var processingStepTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: Layout.sectionTransitionScale,
                anchor: .top
            )
        )
    }

    var optionalProcessingSectionTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: Layout.sectionTransitionScale,
                anchor: .top
            )
        )
    }

    var resizeModeTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: Layout.sectionTransitionScale,
                anchor: .top
            )
        )
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
// swiftlint:enable file_length type_contents_order
