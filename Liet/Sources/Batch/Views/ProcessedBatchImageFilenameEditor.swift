import MHDesign
import SwiftUI

struct ProcessedBatchImageFilenameEditor: View {
    let defaultOutputStem: String
    let outputFilenameExtension: String
    let filenameStem: Binding<String>

    var body: some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: BatchDesign.ProcessedTile.filenameSpacing
        ) {
            TextField(
                defaultOutputStem,
                text: filenameStem
            )
            .textFieldStyle(.roundedBorder)
            .accessibilityLabel("Output filename")

            Text(".\(outputFilenameExtension)")
                .batchTextStyle(
                    .caption,
                    color: .secondary
                )
        }
    }
}
