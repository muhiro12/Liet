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
            BatchImageFileExportModeToggle(
                exportsAsZIPArchive: $model.exportsAsZIPArchive
            )
            BatchImageFileExportButton(
                fileExportMode: model.fileExportMode,
                isExporting: model.isExportingFiles || model.isExportingArchive,
                saveDestinationTip: saveDestinationTip
            ) {
                model.beginFileExport()
            }
            BatchSaveToPhotosButton(
                isSaving: model.isSavingToPhotos
            ) {
                await model.saveToPhotos()
            }
        }
    }
}
