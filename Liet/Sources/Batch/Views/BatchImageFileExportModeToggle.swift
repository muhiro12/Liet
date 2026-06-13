import SwiftUI

struct BatchImageFileExportModeToggle: View {
    @Binding var fileExportMode: BatchImageResultModel.FileExportMode

    var body: some View {
        Toggle(
            "Export as ZIP",
            isOn: exportsAsZIP
        )
    }
}

private extension BatchImageFileExportModeToggle {
    var exportsAsZIP: Binding<Bool> {
        Binding(
            get: {
                fileExportMode == .zipArchive
            },
            set: { newValue in
                fileExportMode = if newValue {
                    .zipArchive
                } else {
                    .files
                }
            }
        )
    }
}
