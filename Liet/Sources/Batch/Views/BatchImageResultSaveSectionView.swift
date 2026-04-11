import MHDesign
import SwiftUI
import TipKit

struct BatchImageResultSaveSectionView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Bindable var model: BatchImageResultModel

    private let saveDestinationTip = SaveDestinationTip()

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: designMetrics.spacing.control
        ) {
            exportAsZIPToggle
            exportButton
            photosButton
        }
    }
}

private extension BatchImageResultSaveSectionView {
    var exportAsZIPToggle: some View {
        Toggle(
            "Export as ZIP",
            isOn: exportsAsZIPBinding
        )
    }

    var exportsAsZIPBinding: Binding<Bool> {
        Binding(
            get: {
                model.fileExportMode == .zipArchive
            },
            set: { newValue in
                model.fileExportMode = if newValue {
                    .zipArchive
                } else {
                    .files
                }
            }
        )
    }

    var exportButton: some View {
        Button {
            model.beginFileExport()
        } label: {
            Label(
                fileExportButtonTitle,
                systemImage: fileExportButtonSystemImage
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .popoverTip(
            saveDestinationTip,
            arrowEdge: .top
        )
    }

    var fileExportButtonSystemImage: String {
        if model.fileExportMode == .zipArchive {
            "archivebox"
        } else {
            "folder"
        }
    }

    var fileExportButtonTitle: String {
        if model.fileExportMode == .zipArchive {
            "ZIP Archive"
        } else {
            "Files"
        }
    }

    var photosButton: some View {
        Button {
            Task {
                await model.saveToPhotos()
            }
        } label: {
            photosButtonLabel
        }
        .buttonStyle(.bordered)
        .disabled(model.isSavingToPhotos)
    }

    @ViewBuilder var photosButtonLabel: some View {
        if model.isSavingToPhotos {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else {
            Label("Photos", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
        }
    }
}
