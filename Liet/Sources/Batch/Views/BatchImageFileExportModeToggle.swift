import SwiftUI

struct BatchImageFileExportModeToggle: View {
    @Binding var exportsAsZIPArchive: Bool

    var body: some View {
        Toggle(
            "Export as ZIP",
            isOn: $exportsAsZIPArchive
        )
    }
}
