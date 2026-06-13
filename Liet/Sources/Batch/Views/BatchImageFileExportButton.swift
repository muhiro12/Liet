import SwiftUI
import TipKit

struct BatchImageFileExportButton: View {
    let fileExportMode: BatchImageResultModel.FileExportMode
    let isDisabled: Bool
    let saveDestinationTip: SaveDestinationTip
    let beginFileExport: () -> Void

    var body: some View {
        Button(action: beginFileExport) {
            Label(
                title,
                systemImage: systemImage
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDisabled)
        .popoverTip(
            saveDestinationTip,
            arrowEdge: .top
        )
    }
}

private extension BatchImageFileExportButton {
    var systemImage: String {
        if fileExportMode == .zipArchive {
            "archivebox"
        } else {
            "folder"
        }
    }

    var title: String {
        if fileExportMode == .zipArchive {
            "Save ZIP to Files"
        } else {
            "Save to Files"
        }
    }
}
