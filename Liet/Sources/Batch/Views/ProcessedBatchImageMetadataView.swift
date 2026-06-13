import MHDesign
import SwiftUI

struct ProcessedBatchImageMetadataView: View {
    let resolvedFilename: String
    let detailText: String

    var body: some View {
        Text(resolvedFilename)
            .batchTextStyle(.caption)
            .lineLimit(1)

        Text(detailText)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(BatchDesign.ProcessedTile.detailLineLimit)
    }
}
