// swiftlint:disable file_length type_contents_order
import LietLibrary
import PhotosUI
import SwiftUI
import TipKit
import UIKit

struct BatchBackgroundRemovalHomeView: View {
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
                    AdvertisementSection(.small)
                        .transition(processingStepTransition)
                }
            }
            .padding(Layout.contentPadding)
        }
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
            fileNamingSection()
            backgroundRemovalSection()
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
            spacing: Layout.controlSpacing
        ) {
            Text(title)
                .font(.subheadline.weight(.medium))

            content()
        }
    }

    func fileNamingSection() -> some View {
        settingsSection(title: "File Naming") {
            VStack(
                alignment: .leading,
                spacing: Layout.cardSpacing
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
            spacing: Layout.controlSpacing
        ) {
            Text("Template")
                .font(.subheadline.weight(.medium))

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
            spacing: Layout.controlSpacing
        ) {
            Text("Numbering")
                .font(.subheadline.weight(.medium))

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
            spacing: Layout.cardSpacing
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

    private func dimensionInputSection(
        title: Text,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .numberPad
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: Layout.controlSpacing
        ) {
            title
                .font(.subheadline.weight(.medium))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
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
                model.importFiles(from: fileURLs)
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
}
// swiftlint:enable file_length type_contents_order
