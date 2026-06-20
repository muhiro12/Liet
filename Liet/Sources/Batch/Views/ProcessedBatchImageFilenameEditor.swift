import MHDesign
import SwiftUI

struct ProcessedBatchImageFilenameEditor: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let defaultOutputStem: String
    let outputFilenameExtension: String
    let filenameStem: Binding<String>

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(
                alignment: .leading,
                spacing: BatchDesign.ProcessedTile.filenameSpacing
            ) {
                filenameField
                extensionText
            }
        } else {
            HStack(
                alignment: .firstTextBaseline,
                spacing: BatchDesign.ProcessedTile.filenameSpacing
            ) {
                filenameField
                extensionText
            }
        }
    }

    private var filenameField: some View {
        TextField(
            defaultOutputStem,
            text: filenameStem
        )
        .textFieldStyle(.roundedBorder)
        .accessibilityLabel("Output filename")
        .accessibilityHint("The file extension is added automatically.")
    }

    private var extensionText: some View {
        Text(".\(outputFilenameExtension)")
            .batchTextStyle(
                .caption,
                color: .secondary
            )
    }
}
