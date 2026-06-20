import MHDesign
import SwiftUI

struct ProcessedBatchImageMetadataView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let resolvedFilename: String
    let detailText: String

    var body: some View {
        Text(resolvedFilename)
            .batchTextStyle(.caption)
            .lineLimit(resolvedFilenameLineLimit)

        Text(detailText)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(detailLineLimit)
    }

    private var resolvedFilenameLineLimit: Int {
        if dynamicTypeSize.isAccessibilitySize {
            BatchDesign.ProcessedTile.accessibilityResolvedFilenameLineLimit
        } else {
            BatchDesign.ProcessedTile.resolvedFilenameLineLimit
        }
    }

    private var detailLineLimit: Int? {
        if dynamicTypeSize.isAccessibilitySize {
            nil
        } else {
            BatchDesign.ProcessedTile.detailLineLimit
        }
    }
}
