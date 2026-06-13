import MHDesign
import PhotosUI
import SwiftUI
import TipKit

struct BatchImageImportButtonsView: View {
    @Environment(\.mhDesignMetrics)
    private var designMetrics

    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var isPresentingFileImporter: Bool

    let isImporting: Bool
    let selectImagesTip: SelectImagesTip

    var body: some View {
        VStack(
            spacing: designMetrics.spacing.control
        ) {
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
            .disabled(isImporting)
            .popoverTip(
                selectImagesTip,
                arrowEdge: .top
            )

            Button {
                isPresentingFileImporter = true
            } label: {
                Label("Import from Files", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isImporting)
        }
    }
}
