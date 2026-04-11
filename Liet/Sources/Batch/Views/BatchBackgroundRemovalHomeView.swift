// swiftlint:disable file_length type_contents_order
import LietLibrary
import MHDesign
import PhotosUI
import SwiftUI
import TipKit
import UIKit

struct BatchBackgroundRemovalHomeView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchBackgroundRemovalHomeModel
    @Binding var selectedItems: [PhotosPickerItem]
    let reviewSelection: (() -> Void)?
    let backToChooser: (() -> Void)?

    @State private var isPresentingFileImporter = false
    @State private var suppressesSelectedItemsDidChange = false

    private let selectImagesTip = SelectImagesTip()
    private let processingSetupTip = ProcessingSetupTip()
    private let runProcessingTip = RunProcessingTip()
    private let userPresetTip = UserPresetTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.section
        ) {
            importStepSection()

            if model.showsProcessingStep {
                processingStepSection()
                    .transition(processingStepTransition)
                processStepSection()
                    .transition(processingStepTransition)
                AdvertisementSection(.small)
                    .transition(processingStepTransition)
            }
        }
        .batchScreen(
            title: nil as Text?,
            subtitle: nil as Text?
        )
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Remove Background")
        .navigationBarTitleDisplayMode(.large)
        .animation(
            processingAnimation,
            value: model.importedImages.count
        )
        .toolbar {
            if let backToChooser {
                ToolbarItem(placement: .topBarLeading) {
                    BatchToolbarIconButton(
                        systemImage: "square.grid.2x2",
                        accessibilityLabel: "Choose Feature"
                    ) {
                        backToChooser()
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

private extension BatchBackgroundRemovalHomeView {
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

    var strengthBinding: Binding<Double> {
        Binding(
            get: {
                model.strength
            },
            set: { newValue in
                model.strength = newValue
            }
        )
    }

    var edgeSmoothingBinding: Binding<Double> {
        Binding(
            get: {
                model.edgeSmoothing
            },
            set: { newValue in
                model.edgeSmoothing = newValue
            }
        )
    }

    var edgeExpansionBinding: Binding<Double> {
        Binding(
            get: {
                model.edgeExpansion
            },
            set: { newValue in
                model.edgeExpansion = newValue
            }
        )
    }

    var namingTemplateBinding: Binding<BatchImageNamingTemplate> {
        Binding(
            get: {
                model.namingTemplate
            },
            set: { newValue in
                model.setNamingTemplate(newValue)
            }
        )
    }

    var customNamingPrefixBinding: Binding<String> {
        Binding(
            get: {
                model.customNamingPrefixText
            },
            set: { newValue in
                model.setCustomNamingPrefixText(newValue)
            }
        )
    }

    var numberingStyleBinding: Binding<BatchImageNumberingStyle> {
        Binding(
            get: {
                model.numberingStyle
            },
            set: { newValue in
                model.setNumberingStyle(newValue)
            }
        )
    }

    var settingsSourceBinding: Binding<BatchBackgroundRemovalHomeModel.SettingsSource> {
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
        BatchStepSection(
            number: BatchDesign.Step.import,
            title: "Import"
        ) {
            selectionButtons()
            selectionStatusRow()
            importFeedback()
        }
    }

    func processingStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.processing,
            title: "Processing Settings"
        ) {
            settingsSourceSection()
            fileNamingSection()
            backgroundRemovalSection()
            userPresetSection()
        }
    }

    func processStepSection() -> some View {
        BatchStepSection(
            number: BatchDesign.Step.process,
            title: "Process"
        ) {
            processButton()
        }
    }

    func settingsSourceSection() -> some View {
        settingsSection(title: "Starting Point") {
            Picker("Starting Point", selection: settingsSourceBinding) {
                Text("Last Used")
                    .tag(BatchBackgroundRemovalHomeModel.SettingsSource.lastUsed)
                Text("User Preset")
                    .tag(BatchBackgroundRemovalHomeModel.SettingsSource.userPreset)
                    .disabled(!model.hasUserPresetSettings)
                Text("Custom")
                    .tag(BatchBackgroundRemovalHomeModel.SettingsSource.custom)
            }
            .pickerStyle(.segmented)
            .popoverTip(
                processingSetupTip,
                arrowEdge: .top
            )
        }
    }

    func settingsSection<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text(title)
                .batchTextStyle(.bodyStrong)

            content()
        }
    }

    func fileNamingSection() -> some View {
        settingsSection(title: "File Naming") {
            VStack(
                alignment: .leading,
                spacing: designMetrics.spacing.control
            ) {
                namingTemplateSection()
                customNamingPrefixSection()
                numberingStyleSection()
            }
        }
    }

    func namingTemplateSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Template")
                .batchTextStyle(.bodyStrong)

            Picker("Template", selection: namingTemplateBinding) {
                Text("IMG")
                    .tag(BatchImageNamingTemplate.img)
                Text("Processed")
                    .tag(BatchImageNamingTemplate.processed)
                Text("Custom")
                    .tag(BatchImageNamingTemplate.custom)
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    func customNamingPrefixSection() -> some View {
        if model.showsCustomNamingPrefixField {
            dimensionInputSection(
                title: Text("Custom prefix"),
                placeholder: "prefix",
                text: customNamingPrefixBinding,
                keyboardType: .default
            )

            if !model.hasValidNaming {
                BatchStatusChip(
                    "Enter a custom prefix to enable processing",
                    systemImage: "text.cursor",
                    tone: .warning
                )
            }
        }
    }

    func numberingStyleSection() -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            Text("Numbering")
                .batchTextStyle(.bodyStrong)

            Picker("Numbering", selection: numberingStyleBinding) {
                Text("001")
                    .tag(BatchImageNumberingStyle.zeroPaddedThreeDigits)
                Text("1")
                    .tag(BatchImageNumberingStyle.plain)
            }
            .pickerStyle(.segmented)
        }
    }

    func backgroundRemovalSection() -> some View {
        settingsSection(title: "Background Removal") {
            backgroundRemovalControls()
        }
    }

    func backgroundRemovalControls() -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            adjustmentSlider(
                title: "Strength",
                value: strengthBinding,
                range: 0...1,
                valueText: percentageText(model.strength)
            )
            adjustmentSlider(
                title: "Edge smoothing",
                value: edgeSmoothingBinding,
                range: 0...1,
                valueText: percentageText(model.edgeSmoothing)
            )
            adjustmentSlider(
                title: "Edge expand / contract",
                value: edgeExpansionBinding,
                range: -1...1,
                valueText: signedPercentageText(model.edgeExpansion)
            )
            BatchStatusChip(
                "Exports PNG with transparency",
                systemImage: "sparkles",
                tone: .neutral
            )
        }
    }

    func dimensionInputSection(
        title: Text,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .numberPad
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            title
                .batchTextStyle(.bodyStrong)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
        }
    }

    func adjustmentSlider(
        title: LocalizedStringKey,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        valueText: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.inline
        ) {
            HStack {
                Text(title)
                    .batchTextStyle(.bodyStrong)
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

    func selectionButtons() -> some View {
        VStack(
            spacing: designMetrics.spacing.control
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
            spacing: designMetrics.spacing.control
        ) {
            selectedImageCountText(model.importedImages.count)
                .batchTextStyle(.bodyStrong)

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
                model.importFiles(from: fileURLs)
            }
        case .failure:
            model.importFailureCount = nil
            model.activeAlert = .importSelectionFailed
        }
    }

    var processingAnimation: Animation {
        .spring(
            response: BatchDesign.Animation.processingSpringResponse,
            dampingFraction: BatchDesign.Animation.processingSpringDampingFraction,
            blendDuration: BatchDesign.Animation.processingSpringBlendDuration
        )
    }

    var processingStepTransition: AnyTransition {
        .opacity.combined(
            with: .scale(
                scale: BatchDesign.Animation.sectionTransitionScale,
                anchor: .top
            )
        )
    }
}
// swiftlint:enable file_length type_contents_order
