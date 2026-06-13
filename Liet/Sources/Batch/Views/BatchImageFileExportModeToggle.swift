import SwiftUI

struct BatchImageFileExportModeToggle: View {
    @Binding var exportsAsZIPArchive: Bool
    let isDisabled: Bool

    var body: some View {
        Toggle(
            "Export as ZIP",
            isOn: $exportsAsZIPArchive
        )
        .disabled(isDisabled)
    }
}
