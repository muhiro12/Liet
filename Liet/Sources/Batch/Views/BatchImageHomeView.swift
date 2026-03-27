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
    }

    @Bindable var model: BatchImageHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    let reviewSelection: (() -> Void)?
    @State private var isPresentingFileImporter = false
    @State private var suppressesSelectedItemsDidChange = false
    @Namespace private var processingMorphNamespace

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()
    private let resizeMethodTip = ResizeMethodTip()
    private let userPresetTip = UserPresetTip()

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
        .scrollDismissesKeyboard(.interactively)
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
        .animation(
            processingAnimation,
            value: model.backgroundRemoval.isEnabled
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BatchToolbarIconButton(
                    systemImage: "questionmark.circle",
                    accessibilityLabel: "Show Tips Again"
                ) {
                    model.replayTips()
                }
            }
        }
        .onChange(of: selectedItems) { _, newValue in
            if suppressesSelectedItemsDidChange {
                suppressesSelectedItemsDidChange = false
                return
            }

            Task {
                await model.importPhotos(from: newValue)
            }
        }
        .fileImporter(
            isPresented: $isPresentingFileImporter,
            allowedContentTypes: PhotoImportService.supportedImportContentTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileImportResult(result)
        } onCancellation: {
            // Keep the current selection unchanged when the picker is dismissed.
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

    var backgroundRemovalEnabledBinding: Binding<Bool> {
        Binding(
            get: {
                model.backgroundRemoval.isEnabled
            },
            set: { newValue in
                model.setBackgroundRemovalEnabled(newValue)
            }
        )
    }

    var backgroundRemovalStrengthBinding: Binding<Double> {
        Binding(
            get: {
                model.backgroundRemoval.strength
            },
            set: { newValue in
                model.setBackgroundRemovalStrength(newValue)
            }
        )
    }

    var backgroundRemovalEdgeSmoothingBinding: Binding<Double> {
        Binding(
            get: {
                model.backgroundRemoval.edgeSmoothing
            },
            set: { newValue in
                model.setBackgroundRemovalEdgeSmoothing(newValue)
            }
        )
    }

    var backgroundRemovalEdgeExpansionBinding: Binding<Double> {
        Binding(
            get: {
                model.backgroundRemoval.edgeExpansion
            },
            set: { newValue in
                model.setBackgroundRemovalEdgeExpansion(newValue)
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
            selectionButtons()
            selectionStatusRow()
            importFeedback()
        }
    }

    func processingStepSection() -> some View {
        stepCard(
            number: Layout.processingStepNumber,
            title: "Processing Settings"
        ) {
            settingsSourceSection()
            outputSizeSection()
            backgroundRemovalSection()

            if model.showsCompressionSection {
                compressionSection()
                    .transition(optionalProcessingSectionTransition)
            }

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
            .popoverTip(
                processingSetupTip,
                arrowEdge: .top
            )
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
                text: referencePixelsBinding
            )
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
                text: resizeWidthBinding
            )

            dimensionInputSection(
                title: Text("Height (px)"),
                placeholder: "1080",
                text: resizeHeightBinding
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

    func backgroundRemovalSection() -> some View {
        settingsSection(title: "Background Removal") {
            Toggle(
                "Remove background",
                isOn: backgroundRemovalEnabledBinding
            )

            if model.backgroundRemoval.isEnabled {
                backgroundRemovalControls()
                    .transition(optionalProcessingSectionTransition)
            }
        }
    }

    func backgroundRemovalControls() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.cardSpacing
        ) {
            adjustmentSlider(
                title: "Strength",
                value: backgroundRemovalStrengthBinding,
                range: 0...1,
                valueText: percentageText(
                    model.backgroundRemoval.strength
                )
            )
            adjustmentSlider(
                title: "Edge smoothing",
                value: backgroundRemovalEdgeSmoothingBinding,
                range: 0...1,
                valueText: percentageText(
                    model.backgroundRemoval.edgeSmoothing
                )
            )
            adjustmentSlider(
                title: "Edge expand / contract",
                value: backgroundRemovalEdgeExpansionBinding,
                range: -1...1,
                valueText: signedPercentageText(
                    model.backgroundRemoval.edgeExpansion
                )
            )
            BatchStatusChip(
                "Exports PNG with transparency",
                systemImage: "sparkles",
                tone: .neutral
            )
        }
    }

    private func dimensionInputSection(
        title: Text,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            title
                .font(.subheadline.weight(.medium))

            TextField(placeholder, text: text)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func adjustmentSlider(
        title: LocalizedStringKey,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        valueText: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(valueText)
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: value,
                in: range
            )
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
                .popoverTip(
                    resizeMethodTip,
                    arrowEdge: .top
                )
            }
        }
    }

    func selectionButtons() -> some View {
        VStack(
            spacing: Layout.controlSpacing
        ) {
            photosSelectionButton()
            filesSelectionButton()
        }
    }

    func photosSelectionButton() -> some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: nil,
            matching: .images,
            preferredItemEncoding: .current
        ) {
            Label("Import from Photos", systemImage: "photo.on.rectangle.angled")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(model.isImporting)
        .popoverTip(
            selectImagesTip,
            arrowEdge: .top
        )
    }

    func filesSelectionButton() -> some View {
        Button {
            isPresentingFileImporter = true
        } label: {
            Label("Import from Files", systemImage: "folder")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(model.isImporting)
    }

    func selectionStatusRow() -> some View {
        HStack(
            spacing: Layout.controlSpacing
        ) {
            selectedImageCountText(model.importedImages.count)
                .font(.subheadline.weight(.medium))

            Spacer()

            if let reviewSelection,
               !model.importedImages.isEmpty {
                Button {
                    reviewSelection()
                } label: {
                    Image(systemName: "eye")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(Text("Review Selection"))
            }

            if !model.importedImages.isEmpty {
                Button {
                    selectedItems = []
                    model.clearSelection()
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(Text("Clear"))
            }
        }
    }

    @ViewBuilder
    func importFeedback() -> some View {
        if model.isImporting {
            ProgressView("Loading images...")
        }

        if let importFailureCount = model.importFailureCount {
            BatchStatusChip(
                text: importFailureText(importFailureCount),
                systemImage: "exclamationmark.triangle.fill",
                tone: .warning
            )
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
            .disabled(model.backgroundRemoval.isEnabled)

            if model.backgroundRemoval.isEnabled {
                BatchStatusChip(
                    "Transparent PNG output ignores compression",
                    systemImage: "drop",
                    tone: .neutral
                )
            }

            if model.showsMixedCompressionHint {
                BatchStatusChip(
                    "PNG keeps original format",
                    systemImage: "photo",
                    tone: .neutral
                )
            }
        }
    }

    func userPresetSection() -> some View {
        settingsSection(title: "User Preset") {
            Button {
                model.saveCurrentAsUserPreset()
            } label: {
                Label("Save Preset", systemImage: "bookmark")
            }
            .buttonStyle(.bordered)
            .disabled(!model.canSaveCurrentAsUserPreset)
            .popoverTip(
                userPresetTip,
                arrowEdge: .top
            )
        }
    }

    func processActionSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            processButton()
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
                Label("Process", systemImage: "play.fill")
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

    func percentageText(
        _ value: Double
    ) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    func signedPercentageText(
        _ value: Double
    ) -> String {
        let percentage = Int((value * 100).rounded())

        if percentage > 0 {
            return "+\(percentage)%"
        }

        return "\(percentage)%"
    }

    func handleFileImportResult(
        _ result: Result<[URL], any Error>
    ) {
        switch result {
        case let .success(fileURLs):
            guard !fileURLs.isEmpty else {
                return
            }

            if !selectedItems.isEmpty {
                suppressesSelectedItemsDidChange = true
                selectedItems = []
            }

            Task {
                await model.importFiles(from: fileURLs)
            }
        case .failure:
            model.importFailureCount = nil
            model.activeAlert = .importSelectionFailed
        }
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
