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
                exportsAsZIPArchive: $model.exportsAsZIPArchive,
                isDisabled: model.isOutputSaveInProgress
            )
            BatchImageFileExportButton(
                fileExportMode: model.fileExportMode,
                isDisabled: model.isOutputSaveInProgress,
                saveDestinationTip: saveDestinationTip
            ) {
                model.beginFileExport()
            }
            BatchSaveToPhotosButton(
                isSaving: model.isSavingToPhotos,
                isDisabled: model.isOutputSaveInProgress
            ) {
                await model.saveToPhotos()
            }
        }
    }
}
